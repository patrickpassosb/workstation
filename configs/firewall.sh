#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

log "═══════════════════════════════════════════════════════"
log "  Firewall — UFW (Uncomplicated Firewall)"
log "═══════════════════════════════════════════════════════"

# ── Install UFW ──────────────────────────────────────────────────────
apt_install_if_missing ufw || { err "Failed to install UFW"; exit 1; }

# ── Check if already enabled ─────────────────────────────────────────
if sudo ufw status | grep -q "Status: active"; then
  log "UFW is already active"
  log ""
  log "── Current rules ─────────────────────────────────────"
  sudo ufw status verbose
  log ""
  log "Firewall already configured — skipping. To reset: sudo ufw reset"
  exit 0
fi

log "Configuring UFW firewall..."

# ── Defaults ─────────────────────────────────────────────────────────
# Deny all incoming traffic by default — only explicitly allowed services
# can accept connections. Allow all outgoing traffic (web browsing, updates,
# API calls, etc.)
log "Setting defaults: deny incoming, allow outgoing"
sudo ufw default deny incoming
sudo ufw default allow outgoing

# ── SSH ──────────────────────────────────────────────────────────────
# Allow SSH (port 22) so you're never locked out.
# Rate-limit SSH: blocks an IP if it attempts 6+ connections in 30 seconds
# (protects against brute-force without needing Fail2Ban).
log "Allowing SSH (port 22) with rate-limiting"
sudo ufw limit 22/tcp comment 'SSH - rate limited'

# ── Tailscale ────────────────────────────────────────────────────────
# Allow all traffic on the Tailscale interface (tailscale0).
# Tailscale already authenticates devices via WireGuard, so all traffic
# on this interface is trusted (your personal VPN mesh).
if ip link show tailscale0 > /dev/null 2>&1 || is_installed tailscale; then
  log "Allowing all traffic on Tailscale interface (tailscale0)"
  sudo ufw allow in on tailscale0 comment 'Tailscale VPN'
fi

# ── Development ports (local only) ──────────────────────────────────
# Allow common dev server ports but ONLY from localhost/LAN.
# This lets you develop locally without exposing ports to the internet.
# These rules cover: Vite (5173), Next.js/React (3000), generic (8080/8000).
for port in 3000 5173 8000 8080; do
  sudo ufw allow from 127.0.0.0/8 to any port "$port" proto tcp \
    comment "Dev server (localhost) - port $port"
done

# Also allow dev ports from Tailscale subnet (100.64.0.0/10) so you can
# access dev servers from your other Tailscale devices.
if ip link show tailscale0 > /dev/null 2>&1 || is_installed tailscale; then
  for port in 3000 5173 8000 8080; do
    sudo ufw allow from 100.64.0.0/10 to any port "$port" proto tcp \
      comment "Dev server (Tailscale) - port $port"
  done
fi

# ── Logging ──────────────────────────────────────────────────────────
# Low-level logging: logs blocked connections without being noisy.
# Logs go to /var/log/ufw.log for debugging.
log "Enabling low-level logging"
sudo ufw logging low

# ── Enable ───────────────────────────────────────────────────────────
log "Enabling UFW firewall..."
echo "y" | sudo ufw enable

# ── Verify ───────────────────────────────────────────────────────────
log ""
log "── Verification ──────────────────────────────────────"
sudo ufw status verbose

log ""
log "Firewall configuration complete"
log ""
log "── Quick reference ───────────────────────────────────"
log "  sudo ufw status          # show current rules"
log "  sudo ufw allow 80/tcp    # open a port"
log "  sudo ufw delete allow 80 # close a port"
log "  sudo ufw disable         # temporarily disable"
log "  sudo ufw reset           # remove all rules and start over"
