#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

log "═══════════════════════════════════════════════════════"
log "  ClamAV — Antivirus & Malware Scanner"
log "═══════════════════════════════════════════════════════"

# ── Install ──────────────────────────────────────────────────────────
if is_installed clamscan && is_installed freshclam; then
  log "ClamAV is already installed."
else
  log "Installing ClamAV and daemon..."
  # clamav = scanner, clamav-daemon = background service
  apt_install_if_missing clamav || true
  apt_install_if_missing clamav-daemon || true
fi

# ── Stop freshclam daemon temporarily to run manual update ───────────
if systemctl is-active --quiet clamav-freshclam; then
  sudo systemctl stop clamav-freshclam
fi

log "Updating virus definitions (this may take a minute)..."
sudo freshclam --quiet || warn "Freshclam update returned non-zero (might be temporarily blocked or already updated)"

# Restart background updater
sudo systemctl start clamav-freshclam
sudo systemctl enable clamav-freshclam >/dev/null 2>&1

# ── Create weekly scan script ────────────────────────────────────────
SCAN_SCRIPT="/etc/cron.weekly/clamav-scan"

log "Setting up weekly automated scan at $SCAN_SCRIPT"
sudo tee "$SCAN_SCRIPT" > /dev/null <<'EOF'
#!/usr/bin/env bash
# Runs a weekly background scan of high-risk user directories.
# Logs output to /var/log/clamav/weekly-scan.log

LOG_FILE="/var/log/clamav/weekly-scan.log"
TARGET_DIRS="/home/*/Downloads /home/*/GitHub /home/*/src"

mkdir -p "$(dirname "$LOG_FILE")"
echo "=== Starting Weekly Scan: $(date) ===" >> "$LOG_FILE"

# Run nice/ionice to prevent scan from slowing down the system
nice -n 15 ionice -c 2 -n 7 clamscan -r --infected --detect-pua=yes --exclude-dir="\.git" $TARGET_DIRS >> "$LOG_FILE" 2>&1

echo "=== Finished Weekly Scan: $(date) ===" >> "$LOG_FILE"
EOF

sudo chmod +x "$SCAN_SCRIPT"

log "ClamAV configured:"
log "  • Virus definitions auto-update in the background (freshclam)"
log "  • Weekly background scan of Downloads and GitHub directories"
log "  • Scan logs: /var/log/clamav/weekly-scan.log"
log "  • To scan a file manually: clamscan payload.js"
