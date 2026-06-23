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

# ── Flameshot ─────────────────────────────────────────────────────────
if is_installed flameshot; then
  cat > "$AUTOSTART_DIR/flameshot.desktop" <<'EOF'
[Desktop Entry]
Name=Flameshot
Exec=flameshot
Terminal=false
Type=Application
Icon=flameshot
Comment=Screenshot tool
Categories=Utility;
X-GNOME-Autostart-enabled=true
NoDisplay=false
Hidden=false
EOF
  log "Added autostart: Flameshot"
elif command -v flatpak >/dev/null 2>&1 && flatpak info org.flameshot.Flameshot >/dev/null 2>&1; then
  cat > "$AUTOSTART_DIR/org.flameshot.Flameshot.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Flameshot
Exec=flatpak run org.flameshot.Flameshot
Terminal=false
Icon=flameshot
Comment=Screenshot tool
Categories=Utility;
X-GNOME-Autostart-enabled=true
NoDisplay=false
Hidden=false
X-Flatpak=org.flameshot.Flameshot
EOF
  log "Added autostart: Flameshot (flatpak)"
else
  warn "Flameshot not installed — skipping autostart"
fi

log "Startup applications configured"
