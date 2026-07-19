#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

log "═══════════════════════════════════════════════════════"
log "  DNS — NextDNS over TLS (systemd-resolved)"
log "═══════════════════════════════════════════════════════"

# ── NextDNS config ID ────────────────────────────────────────────────
NEXTDNS_ID="${NEXTDNS_ID:-ab1bb7}"

# ── Preflight ────────────────────────────────────────────────────────
if ! systemctl list-unit-files systemd-resolved.service >/dev/null 2>&1; then
  warn "systemd-resolved is not available on this system — skipping NextDNS setup"
  exit 0
fi

if is_fedora_like && ! systemctl is-active --quiet systemd-resolved; then
  warn "systemd-resolved is available but not active on Fedora."
  warn "Skipping NextDNS setup to avoid changing Fedora KDE DNS behavior implicitly."
  warn "Enable systemd-resolved first if you want this script to manage DNS-over-TLS."
  exit 0
fi

require_cmd nmcli

# ── Configure systemd-resolved ──────────────────────────────────────
# Prefer a drop-in override (/etc/systemd/resolved.conf.d/nextdns.conf)
# over editing /etc/systemd/resolved.conf directly — a drop-in preserves
# the distro's main file and survives future package upgrades.
RESOLVED_DROPIN_DIR="/etc/systemd/resolved.conf.d"
RESOLVED_DROPIN="$RESOLVED_DROPIN_DIR/nextdns.conf"
EXPECTED_DNS="45.90.28.0#${NEXTDNS_ID}.dns.nextdns.io"

if grep -q "$EXPECTED_DNS" "$RESOLVED_DROPIN" 2>/dev/null; then
  log "systemd-resolved already configured for NextDNS ($NEXTDNS_ID)"
else
  log "Writing $RESOLVED_DROPIN with NextDNS ($NEXTDNS_ID)"
  sudo install -d -m 0755 "$RESOLVED_DROPIN_DIR"
  # Back up the existing main resolved.conf (if any custom settings are
  # present there) so the user can recover them after the drop-in takes
  # precedence. The drop-in doesn't overwrite the main file, but a
  # backup is cheap insurance against confusion later.
  if [[ -f /etc/systemd/resolved.conf ]] && ! sudo test -f /etc/systemd/resolved.conf.bak; then
    sudo cp -a /etc/systemd/resolved.conf /etc/systemd/resolved.conf.bak
    log "Backed up /etc/systemd/resolved.conf → /etc/systemd/resolved.conf.bak"
  fi
  sudo tee "$RESOLVED_DROPIN" >/dev/null <<EOF
[Resolve]
DNS=45.90.28.0#${NEXTDNS_ID}.dns.nextdns.io
DNS=2a07:a8c0::#${NEXTDNS_ID}.dns.nextdns.io
DNS=45.90.30.0#${NEXTDNS_ID}.dns.nextdns.io
DNS=2a07:a8c1::#${NEXTDNS_ID}.dns.nextdns.io
DNSOverTLS=yes
EOF
  sudo systemctl restart systemd-resolved
  log "systemd-resolved restarted"
fi

# ── Symlink resolv.conf ─────────────────────────────────────────────
STUB="/run/systemd/resolve/stub-resolv.conf"
if [[ "$(readlink -f /etc/resolv.conf)" != "$STUB" ]]; then
  log "Linking /etc/resolv.conf → $STUB"
  sudo ln -sf "$STUB" /etc/resolv.conf
else
  log "/etc/resolv.conf already points to stub resolver"
fi

# ── Disable DHCP DNS on NetworkManager connections ──────────────────
# Apply to all ethernet and wifi connections so DHCP never overrides DNS.
while IFS=: read -r name type; do
  [[ "$type" == "802-3-ethernet" || "$type" == "802-11-wireless" ]] || continue

  changed=false
  for prop in ipv4.ignore-auto-dns ipv6.ignore-auto-dns; do
    current=$(nmcli -g "$prop" connection show "$name" 2>/dev/null || echo "")
    if [[ "$current" != "yes" ]]; then
      nmcli connection modify "$name" "$prop" yes || {
        warn "Failed to modify $prop on $name — leaving it unchanged"
        continue
      }
      changed=true
    fi
  done

  if [[ "$changed" == "true" ]]; then
    log "Disabled DHCP DNS on connection: $name"
    # Reapply only if the connection is currently active
    if nmcli -t -f NAME connection show --active | grep -qxF "$name"; then
      log "Reactivating: $name"
      nmcli connection down "$name" >/dev/null 2>&1 || true
      nmcli connection up "$name" >/dev/null 2>&1 || true
    fi
  else
    log "DHCP DNS already disabled on: $name"
  fi
done < <(nmcli -t -f NAME,TYPE connection show)

# ── Disable Brave's built-in Secure DNS ─────────────────────────────
# Brave's own DoH resolver bypasses the system stub and breaks NextDNS.
# Setting mode to "off" makes Brave use the system resolver (which is
# already NextDNS over TLS via systemd-resolved).
BRAVE_LOCAL_STATE="$HOME/.config/BraveSoftware/Brave-Browser/Local State"

if [[ -f "$BRAVE_LOCAL_STATE" ]]; then
  current_mode=$(python3 -c "
import json, sys
with open(sys.argv[1]) as f:
    s = json.load(f)
print(s.get('dns_over_https', {}).get('mode', ''))
" "$BRAVE_LOCAL_STATE" 2>/dev/null || echo "")

  if [[ "$current_mode" == "off" ]]; then
    log "Brave Secure DNS already disabled"
  else
    if pgrep -x brave >/dev/null 2>&1; then
      warn "Brave is running — close it first, then re-run this script"
      warn "Brave overwrites Local State on exit, so changes would be lost"
    else
      python3 -c "
import json, sys
path = sys.argv[1]
with open(path) as f:
    s = json.load(f)
s.setdefault('dns_over_https', {})['mode'] = 'off'
s['dns_over_https']['templates'] = ''
with open(path, 'w') as f:
    json.dump(s, f, separators=(',', ':'))
" "$BRAVE_LOCAL_STATE"
      log "Brave Secure DNS disabled (will use system resolver)"
    fi
  fi
else
  log "Brave not installed — skipping browser DNS config"
fi

# ── Verify ───────────────────────────────────────────────────────────
log ""
log "── Verification ──────────────────────────────────────"

# Check global DNS
if resolvectl status 2>/dev/null | grep -q "$NEXTDNS_ID"; then
  log "Global DNS: NextDNS ($NEXTDNS_ID) ✓"
else
  warn "Global DNS does not show NextDNS — check resolvectl status"
fi

# Check DNSOverTLS
if resolvectl status 2>/dev/null | grep -q "+DNSOverTLS"; then
  log "DNS-over-TLS: enabled ✓"
else
  warn "DNS-over-TLS may not be active"
fi

# Check resolv.conf
if grep -q "127.0.0.53" /etc/resolv.conf 2>/dev/null; then
  log "resolv.conf: stub resolver (127.0.0.53) ✓"
else
  warn "resolv.conf is not using the stub resolver"
fi

log ""
log ""
log "DNS configuration complete"
log "Test at: https://test.nextdns.io (expect status: ok, protocol: DOT)"

# ── Lock resolv.conf ────────────────────────────────────────────────
# Making it immutable prevents accidental or malicious changes. To
# edit /etc/resolv.conf later, unlock it first:
#   sudo chattr -i /etc/resolv.conf
if lsattr /etc/resolv.conf 2>/dev/null | grep -q "^....i"; then
  sudo chattr -i /etc/resolv.conf
fi
log "Locking /etc/resolv.conf (making it immutable)..."
if sudo chattr +i /etc/resolv.conf; then
  log "  /etc/resolv.conf is now immutable. Unlock with: sudo chattr -i /etc/resolv.conf"
else
  warn "Failed to lock /etc/resolv.conf (might be on a tmpfs)"
fi
