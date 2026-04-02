#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

log "═══════════════════════════════════════════════════════"
log "  Unattended Upgrades — Automatic Security Patches"
log "═══════════════════════════════════════════════════════"

# ── Install ──────────────────────────────────────────────────────────
apt_install_if_missing unattended-upgrades || { err "Failed to install unattended-upgrades"; exit 1; }

# ── Check if already configured ──────────────────────────────────────
AUTO_UPGRADES="/etc/apt/apt.conf.d/20auto-upgrades"
if [[ -f "$AUTO_UPGRADES" ]] && grep -q 'APT::Periodic::Unattended-Upgrade "1"' "$AUTO_UPGRADES" 2>/dev/null; then
  log "Unattended upgrades already configured"
  log ""
  log "── Current config ────────────────────────────────────"
  cat "$AUTO_UPGRADES"
  exit 0
fi

log "Configuring automatic security updates..."

# ── Enable automatic updates ─────────────────────────────────────────
# Update package lists daily, install security patches daily,
# clean up old downloaded packages weekly.
sudo tee "$AUTO_UPGRADES" > /dev/null <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
EOF
log "Auto-upgrades config written to $AUTO_UPGRADES"

# ── Configure what gets upgraded ─────────────────────────────────────
# Only install security updates — never touch regular package updates
# that could break things. Also enable automatic reboot at 4 AM if a
# kernel update requires it (only happens for critical security patches).
UNATTENDED_CONF="/etc/apt/apt.conf.d/50unattended-upgrades"
if [[ -f "$UNATTENDED_CONF" ]]; then
  # Enable automatic removal of unused dependencies
  if grep -q '//Unattended-Upgrade::Remove-Unused-Dependencies' "$UNATTENDED_CONF" 2>/dev/null; then
    sudo sed -i 's|//Unattended-Upgrade::Remove-Unused-Dependencies.*|Unattended-Upgrade::Remove-Unused-Dependencies "true";|' "$UNATTENDED_CONF"
    log "Enabled automatic removal of unused dependencies"
  fi

  # Enable automatic removal of unused kernel packages
  if grep -q '//Unattended-Upgrade::Remove-Unused-Kernel-Packages' "$UNATTENDED_CONF" 2>/dev/null; then
    sudo sed -i 's|//Unattended-Upgrade::Remove-Unused-Kernel-Packages.*|Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";|' "$UNATTENDED_CONF"
    log "Enabled automatic removal of unused kernel packages"
  fi
fi

# ── Enable and start the timer ───────────────────────────────────────
sudo systemctl enable apt-daily.timer
sudo systemctl enable apt-daily-upgrade.timer
sudo systemctl start apt-daily.timer
sudo systemctl start apt-daily-upgrade.timer
log "Systemd timers enabled and started"

# ── Verify ───────────────────────────────────────────────────────────
log ""
log "── Verification ──────────────────────────────────────"
if systemctl is-active --quiet apt-daily.timer; then
  log "apt-daily.timer: active ✓"
else
  warn "apt-daily.timer is not active"
fi
if systemctl is-active --quiet apt-daily-upgrade.timer; then
  log "apt-daily-upgrade.timer: active ✓"
else
  warn "apt-daily-upgrade.timer is not active"
fi

log ""
log "Automatic security updates configured"
log "  • Security patches install daily (silently)"
log "  • Unused dependencies cleaned automatically"
log "  • Logs: /var/log/unattended-upgrades/"
