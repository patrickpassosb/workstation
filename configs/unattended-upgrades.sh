#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

log "═══════════════════════════════════════════════════════"
log "  Unattended Upgrades — Automatic Security Patches"
log "═══════════════════════════════════════════════════════"

if is_fedora_like; then
  pkg_install_if_missing dnf-automatic || { err "Failed to install dnf-automatic"; exit 1; }

  DNF_AUTOMATIC="/etc/dnf/automatic.conf"
  if [[ -f "$DNF_AUTOMATIC" ]]; then
    # Back up the existing config before in-place editing so the user
    # can recover any prior customizations.
    if ! sudo test -f "${DNF_AUTOMATIC}.bak"; then
      sudo cp -a "$DNF_AUTOMATIC" "${DNF_AUTOMATIC}.bak"
      log "Backed up $DNF_AUTOMATIC → ${DNF_AUTOMATIC}.bak"
    fi
    sudo sed -i \
      -e 's/^upgrade_type = .*/upgrade_type = security/' \
      -e 's/^apply_updates = .*/apply_updates = yes/' \
      "$DNF_AUTOMATIC"
    log "Configured $DNF_AUTOMATIC for automatic security updates"
  else
    warn "$DNF_AUTOMATIC not found after dnf-automatic install"
  fi

  sudo systemctl enable --now dnf-automatic-install.timer

  log ""
  log "── Verification ──────────────────────────────────────"
  if systemctl is-active --quiet dnf-automatic-install.timer; then
    log "dnf-automatic-install.timer: active"
  else
    warn "dnf-automatic-install.timer is not active"
  fi

  log ""
  log "Automatic security updates configured"
  log "  • Fedora security patches install via dnf-automatic"
  log "  • Config: $DNF_AUTOMATIC"
  exit 0
fi

# ── Install ──────────────────────────────────────────────────────────
pkg_install_if_missing unattended-upgrades || { err "Failed to install unattended-upgrades"; exit 1; }

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
# clean up old downloaded packages weekly. Back up any existing config
# file first so the user can recover prior customizations.
if [[ -f "$AUTO_UPGRADES" ]] && ! sudo test -f "${AUTO_UPGRADES}.bak"; then
  sudo cp -a "$AUTO_UPGRADES" "${AUTO_UPGRADES}.bak"
  log "Backed up $AUTO_UPGRADES → ${AUTO_UPGRADES}.bak"
fi
sudo tee "$AUTO_UPGRADES" > /dev/null <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
EOF
log "Auto-upgrades config written to $AUTO_UPGRADES"

# ── Configure what gets upgraded ─────────────────────────────────────
# Only install security updates — never touch regular package updates
# that could break things. Back up 50unattended-upgrades before any
# in-place sed edits so the original defaults are recoverable.
UNATTENDED_CONF="/etc/apt/apt.conf.d/50unattended-upgrades"
if [[ -f "$UNATTENDED_CONF" ]]; then
  if ! sudo test -f "${UNATTENDED_CONF}.bak"; then
    sudo cp -a "$UNATTENDED_CONF" "${UNATTENDED_CONF}.bak"
    log "Backed up $UNATTENDED_CONF → ${UNATTENDED_CONF}.bak"
  fi
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
