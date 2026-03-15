#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

log "═══════════════════════════════════════════════════════"
log "  Startup Applications"
log "═══════════════════════════════════════════════════════"

AUTOSTART_DIR="$HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"

# ── EasyEffects (flatpak) ────────────────────────────────────────────
if flatpak info com.github.wwmm.easyeffects >/dev/null 2>&1; then
  cat > "$AUTOSTART_DIR/com.github.wwmm.easyeffects.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=com.github.wwmm.easyeffects
X-XDP-Autostart=com.github.wwmm.easyeffects
Exec=flatpak run --command=easyeffects com.github.wwmm.easyeffects --service-mode --hide-window
X-Flatpak=com.github.wwmm.easyeffects
EOF
  log "Added autostart: EasyEffects"
else
  warn "EasyEffects not installed — skipping autostart"
fi

# ── StayFree ─────────────────────────────────────────────────────────
if is_installed stayfree-desktop || [[ -f /opt/StayFree/stayfree-desktop ]]; then
  cat > "$AUTOSTART_DIR/stayfree-desktop.desktop" <<'EOF'
[Desktop Entry]
Name=StayFree
Exec=/opt/StayFree/stayfree-desktop %U
Terminal=false
Type=Application
Icon=stayfree-desktop
StartupWMClass=StayFree
Comment=Analytics to help you understand and control your pc usage
Categories=Utility;
X-GNOME-Autostart-enabled=true
NoDisplay=false
Hidden=false
EOF
  log "Added autostart: StayFree"
else
  warn "StayFree not installed — skipping autostart"
fi

log "Startup applications configured"
