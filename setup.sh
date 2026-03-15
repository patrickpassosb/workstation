#!/usr/bin/env bash
set -euo pipefail

# Pop!_OS Setup Orchestrator
# Modular setup for a fresh Pop!_OS installation.
# Usage: ./setup.sh [--level 0|1|2|3] [--skip-tools] [--skip-installers] [--skip-configs]

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

# ── Parse flags ───────────────────────────────────────────────────────
LEVEL=""
SKIP_TOOLS=false
SKIP_INSTALLERS=false
SKIP_CONFIGS=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --level)
      LEVEL="$2"
      shift 2
      ;;
    --level=*)
      LEVEL="${1#--level=}"
      shift
      ;;
    --skip-tools|--skip-source) SKIP_TOOLS=true; shift ;;
    --skip-installers) SKIP_INSTALLERS=true; shift ;;
    --skip-configs)    SKIP_CONFIGS=true; shift ;;
    --help|-h)
      echo "Usage: ./setup.sh [--level 0|1|2|3] [--skip-tools] [--skip-installers] [--skip-configs]"
      echo ""
      echo "Levels:"
      echo "  0  No-compile     — all pre-built (apt, flatpak, npm, GitHub releases)   ~15 min"
      echo "  1  Beginner       — 6 small Rust/Go CLIs compiled from source            ~30 min"
      echo "  2  Intermediate   — 18 tools compiled from source                        ~1-2 hours"
      echo "  3  Hard mode      — all 30 tools compiled from source                    ~3-5 hours"
      exit 0
      ;;
    *) warn "Unknown flag: $1"; shift ;;
  esac
done

# ── Interactive level prompt if not specified ─────────────────────────
if [[ -z "$LEVEL" ]]; then
  echo ""
  echo "Select a build level:"
  echo ""
  echo "  0  No-compile     — all pre-built (apt, flatpak, npm, GitHub releases)   ~15 min"
  echo "  1  Beginner       — 6 small Rust/Go CLIs compiled from source            ~30 min"
  echo "  2  Intermediate   — 18 tools compiled from source                        ~1-2 hours"
  echo "  3  Hard mode      — all 30 tools compiled from source                    ~3-5 hours"
  echo ""
  read -rp "Level [0-3]: " LEVEL
fi

if [[ ! "$LEVEL" =~ ^[0-3]$ ]]; then
  err "Invalid level: $LEVEL (must be 0, 1, 2, or 3)"
  exit 1
fi

LEVEL_NAMES=("No-compile" "Beginner" "Intermediate" "Hard mode")
log "Selected level: $LEVEL — ${LEVEL_NAMES[$LEVEL]}"

# ── gsettings helpers ─────────────────────────────────────────────────
set_gsettings_if_key_exists() {
  local schema="$1" key="$2" value="$3"
  if gsettings list-keys "$schema" 2>/dev/null | grep -qx "$key"; then
    gsettings set "$schema" "$key" "$value" || warn "Failed to set $schema::$key"
  fi
}

configure_flameshot_shortcut() {
  if ! command -v gsettings >/dev/null 2>&1; then
    warn "gsettings not found. Skipping shortcut setup."
    return 1
  fi

  local flameshot_cmd
  if is_installed flameshot; then
    flameshot_cmd="$(command -v flameshot) gui"
  elif command -v flatpak >/dev/null 2>&1 && flatpak info org.flameshot.Flameshot >/dev/null 2>&1; then
    flameshot_cmd="flatpak run org.flameshot.Flameshot gui"
  else
    warn "Flameshot not found. Cannot configure Print Screen shortcut."
    return 1
  fi

  local media_schema="org.gnome.settings-daemon.plugins.media-keys"
  local kb_path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
  local kb_schema="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${kb_path}"

  local current
  current="$(gsettings get "$media_schema" custom-keybindings 2>/dev/null || echo '[]')"
  current="${current#@as }"

  local updated
  if [[ "$current" == "[]" ]]; then
    updated="['${kb_path}']"
  elif [[ "$current" == *"${kb_path}"* ]]; then
    updated="$current"
  else
    updated="${current%]}, '${kb_path}']"
  fi

  gsettings set "$media_schema" custom-keybindings "$updated"
  gsettings set "$kb_schema" name "'Flameshot'"
  gsettings set "$kb_schema" command "'$flameshot_cmd'"
  gsettings set "$kb_schema" binding "'Print'"

  set_gsettings_if_key_exists "$media_schema" screenshot "[]"
  set_gsettings_if_key_exists "$media_schema" screenshot-window "[]"
  set_gsettings_if_key_exists "$media_schema" screenshot-area "[]"
  set_gsettings_if_key_exists org.gnome.shell.keybindings show-screenshot-ui "[]"
  set_gsettings_if_key_exists org.gnome.shell.keybindings show-screen-recording-ui "[]"

  log "Configured Print Screen → Flameshot"
}

install_jetbrains_mono_nerd_font() {
  local font_dir="$HOME/.local/share/fonts"
  if ls "$font_dir"/JetBrainsMono*.ttf >/dev/null 2>&1; then
    log "JetBrains Mono Nerd Font already installed"
    return 0
  fi

  log "Installing JetBrains Mono Nerd Font"
  local tmp_zip="/tmp/JetBrainsMono-nerd.zip"
  curl -fL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" -o "$tmp_zip"
  mkdir -p "$font_dir"
  unzip -o "$tmp_zip" -d "$font_dir" '*.ttf'
  rm -f "$tmp_zip"
  fc-cache -f "$font_dir"
  log "JetBrains Mono Nerd Font installed"
}

# ══════════════════════════════════════════════════════════════════════
# Phase 0: Preflight
# ══════════════════════════════════════════════════════════════════════
log "═══════════════════════════════════════════════════════"
log "  Phase 0: Preflight"
log "═══════════════════════════════════════════════════════"

if ! ping -c 1 -W 3 8.8.8.8 >/dev/null 2>&1; then
  err "No internet connectivity. Aborting."
  exit 1
fi
log "Internet connectivity OK"

require_cmd sudo
require_cmd apt-get
require_cmd curl

# ══════════════════════════════════════════════════════════════════════
# Phase 1: Bootstrap
# ══════════════════════════════════════════════════════════════════════
log ""
log "═══════════════════════════════════════════════════════"
log "  Phase 1: Bootstrap"
log "═══════════════════════════════════════════════════════"

log "Refreshing package index"
sudo apt-get update -y

# Base build tools
for pkg in build-essential ca-certificates curl wget gnupg software-properties-common flatpak unzip; do
  apt_install_if_missing "$pkg" || true
done

# Small apt utilities
for pkg in gnome-sushi folder-color timeshift vlc v4l2loopback-utils; do
  apt_install_if_missing "$pkg" || true
done

# Enable Flathub
if is_installed flatpak; then
  if ! flatpak remotes --columns=name 2>/dev/null | grep -qx flathub; then
    log "Adding Flathub remote"
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  else
    log "Flathub remote already configured"
  fi
fi

# Create productivity folders
for dir in "$HOME/TEMP" "$HOME/AppImage" "$HOME/Vídeos/OBS Rec"; do
  mkdir -p "$dir"
done
log "Productivity folders created"

# Add Nautilus bookmarks
BOOKMARKS_FILE="$HOME/.config/gtk-3.0/bookmarks"
mkdir -p "$(dirname "$BOOKMARKS_FILE")"
touch "$BOOKMARKS_FILE"
for dir in "$HOME/TEMP" "$HOME/AppImage" "$HOME/Vídeos/OBS Rec"; do
  encoded="file://$(echo "$dir" | sed 's/ /%20/g')"
  if ! grep -qF "$encoded" "$BOOKMARKS_FILE" 2>/dev/null; then
    echo "$encoded" >> "$BOOKMARKS_FILE"
    log "Added Nautilus bookmark: $dir"
  fi
done

# Install JetBrains Mono Nerd Font (needed for starship)
install_jetbrains_mono_nerd_font || warn "Font installation failed"

# ══════════════════════════════════════════════════════════════════════
# Phase 2: Toolchains (rustup + nvm)
# ══════════════════════════════════════════════════════════════════════
log ""
log "═══════════════════════════════════════════════════════"
log "  Phase 2: Toolchains"
log "═══════════════════════════════════════════════════════"

bash "$SCRIPT_DIR/installers/rustup.sh" || warn "Rustup installation failed"

# Source cargo env for subsequent builds
if [[ -f "$HOME/.cargo/env" ]]; then
  source "$HOME/.cargo/env"
fi

bash "$SCRIPT_DIR/installers/nvm.sh" || warn "NVM installation failed"

# Source nvm for subsequent installs
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
# shellcheck disable=SC1091
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

# ══════════════════════════════════════════════════════════════════════
# Phase 3: Tools (level-based: prebuilt or build)
# ══════════════════════════════════════════════════════════════════════
if [[ "$SKIP_TOOLS" == "false" ]]; then
  log ""
  bash "$SCRIPT_DIR/tools/install-all.sh" "$LEVEL" || warn "Some tool installations failed"
else
  log ""
  log "Skipping tools (--skip-tools)"
fi

# ══════════════════════════════════════════════════════════════════════
# Phase 4: Installers
# ══════════════════════════════════════════════════════════════════════
if [[ "$SKIP_INSTALLERS" == "false" ]]; then
  log ""
  bash "$SCRIPT_DIR/installers/install-all.sh" || warn "Some installers failed"
else
  log ""
  log "Skipping installers (--skip-installers)"
fi

# ══════════════════════════════════════════════════════════════════════
# Phase 5: Configs & Auth
# ══════════════════════════════════════════════════════════════════════
log ""
log "═══════════════════════════════════════════════════════"
log "  Phase 5: Configs & Auth"
log "═══════════════════════════════════════════════════════"

if [[ "$SKIP_CONFIGS" == "false" ]]; then
  bash "$SCRIPT_DIR/configs/restore-configs.sh" || warn "Config restore failed"
else
  log "Skipping config restore (--skip-configs)"
fi

# Configure Flameshot as Print Screen
configure_flameshot_shortcut || warn "Flameshot shortcut setup was not fully applied"

# SSH key generation
if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
  echo
  read -rp "Generate a new SSH key? [y/N]: " gen_ssh
  if [[ "$gen_ssh" =~ ^[Yy] ]]; then
    ssh-keygen -t ed25519 -C "$(git config user.email 2>/dev/null || echo "$USER@$(hostname)")" -f "$HOME/.ssh/id_ed25519"
    log "SSH key generated. Add it to GitHub: cat ~/.ssh/id_ed25519.pub"
  fi
else
  log "SSH key already exists"
fi

# Reminders
log ""
log "── Post-setup reminders ──────────────────────────────"
log "  • Run: sudo tailscale up       (join your Tailnet)"
log "  • Run: gh auth login            (authenticate GitHub CLI)"
log "  • Add SSH key to GitHub:  cat ~/.ssh/id_ed25519.pub"

# ══════════════════════════════════════════════════════════════════════
# Phase 6: Cleanup
# ══════════════════════════════════════════════════════════════════════
log ""
log "═══════════════════════════════════════════════════════"
log "  Phase 6: Cleanup"
log "═══════════════════════════════════════════════════════"

sudo apt-get autoclean -y
sudo apt-get autoremove -y
if is_installed flatpak; then
  flatpak update -y || true
fi

log ""
log "═══════════════════════════════════════════════════════"
log "  Setup complete! (Level $LEVEL — ${LEVEL_NAMES[$LEVEL]})"
log "═══════════════════════════════════════════════════════"
log "You may need to log out/in for all changes to take effect."
