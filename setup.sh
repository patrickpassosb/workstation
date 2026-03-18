#!/usr/bin/env bash
set -euo pipefail

# Linux Workstation Setup Orchestrator
# Modular setup for a fresh Linux installation.
# Usage: ./setup.sh [--phase 1] [--level 0-10] [--skip-tools] [--skip-installers] [--skip-configs]

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"
source "$SCRIPT_DIR/lib/registry.sh"

# ── Parse flags ───────────────────────────────────────────────────────
PHASE=""
LEVEL=""
SKIP_TOOLS=false
SKIP_INSTALLERS=false
SKIP_CONFIGS=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --phase)
      PHASE="$2"
      shift 2
      ;;
    --phase=*)
      PHASE="${1#--phase=}"
      shift
      ;;
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
      cat <<'HELP'
Usage: ./setup.sh [--phase 1] [--level 0-10] [--skip-tools] [--skip-installers] [--skip-configs]

Phases:
  1   CLI Tools & Small Apps (only phase implemented — Phases 2-10 in docs/roadmap.md)

Levels (Phase 1):
  0   Pre-built          — install everything pre-built, no compilation
  1   First steps        — 6 Node.js CLIs (npm build)
  2   Go basics          — + 4 Go CLIs (fzf, lazygit, lazydocker, opencode)
  3   Rust basics        — + 2 Rust CLIs (ripgrep, fd)
  4   Rust medium        — + 2 heavier Rust builds (starship, uv)
  5   Official repos     — + 3 Go projects (gh, tailscale, docker CLI)
  6   CMake & Meson      — + 2 CMake/Meson apps (flameshot, easyeffects)
  7   Autotools intro    — + 2 autotools builds (htop, jq)
  8   Core system        — + 2 system tools (tmux, zsh)
  9   Core infrastructure— + git from source
  10  Full source        — + Node.js from source — compile everything

Flags:
  --skip-tools         skip tool installation entirely
  --skip-installers    skip proprietary app installers
  --skip-configs       skip dotfile restoration
HELP
      exit 0
      ;;
    *) warn "Unknown flag: $1"; shift ;;
  esac
done

# ── Interactive phase prompt ──────────────────────────────────────────
if [[ -z "$PHASE" ]]; then
  echo ""
  echo "Select a phase:"
  echo ""
  echo "  1   CLI Tools & Small Apps (implemented)"
  echo "  2-10 Coming soon — see docs/roadmap.md"
  echo ""
  read -rp "Phase [1]: " PHASE
  PHASE="${PHASE:-1}"
fi

if [[ "$PHASE" != "1" ]]; then
  err "Phase $PHASE is not yet implemented. See docs/roadmap.md for the roadmap."
  exit 1
fi

# ── Interactive level prompt ──────────────────────────────────────────
if [[ -z "$LEVEL" ]]; then
  echo ""
  echo "Select a level for Phase 1 — CLI Tools & Small Apps:"
  echo ""
  for i in $(seq 0 10); do
    printf "  %-3s %-20s — %s\n" "$i" "${LEVEL_NAMES[$i]}" "${LEVEL_DESCRIPTIONS[$i]}"
  done
  echo ""
  read -rp "Level [0-10]: " LEVEL
fi

if [[ ! "$LEVEL" =~ ^([0-9]|10)$ ]]; then
  err "Invalid level: $LEVEL (must be 0-10)"
  exit 1
fi

log "Selected: Phase $PHASE, Level $LEVEL — ${LEVEL_NAMES[$LEVEL]}"

# ── gsettings helpers ─────────────────────────────────────────────────
set_gsettings_if_key_exists() {
  local schema="$1" key="$2" value="$3"
  if gsettings list-keys "$schema" 2>/dev/null | grep -qx "$key"; then
    gsettings set "$schema" "$key" "$value" || warn "Failed to set $schema::$key"
  fi
}

configure_flameshot_shortcut() {
  local flameshot_cmd
  if is_installed flameshot; then
    flameshot_cmd="flameshot gui"
  elif command -v flatpak >/dev/null 2>&1 && flatpak info org.flameshot.Flameshot >/dev/null 2>&1; then
    flameshot_cmd="flatpak run org.flameshot.Flameshot gui"
  else
    warn "Flameshot not found. Cannot configure Print Screen shortcut."
    return 1
  fi

  local shortcut_set=false

  # Cinnamon (Linux Mint)
  if dconf list /org/cinnamon/desktop/keybindings/ >/dev/null 2>&1; then
    dconf write /org/cinnamon/desktop/keybindings/custom-list "['custom0']"
    dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom0/name "'Flameshot'"
    dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom0/command "'$flameshot_cmd'"
    dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom0/binding "['Print']"
    # Disable default screenshot on Print Screen
    dconf write /org/cinnamon/desktop/keybindings/media-keys/screenshot "@as []"
    log "Configured Print Screen → Flameshot (Cinnamon)"
    shortcut_set=true
  fi

  # GNOME / Pop!_OS
  if command -v gsettings >/dev/null 2>&1 && gsettings list-keys org.gnome.settings-daemon.plugins.media-keys >/dev/null 2>&1; then
    local media_schema="org.gnome.settings-daemon.plugins.media-keys"
    local kb_path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
    local kb_schema="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${kb_path}"

    gsettings set "$media_schema" custom-keybindings "['${kb_path}']"
    gsettings set "$kb_schema" name "'Flameshot'"
    gsettings set "$kb_schema" command "'$flameshot_cmd'"
    gsettings set "$kb_schema" binding "'Print'"

    set_gsettings_if_key_exists "$media_schema" screenshot "[]"
    set_gsettings_if_key_exists "$media_schema" screenshot-window "[]"
    set_gsettings_if_key_exists "$media_schema" screenshot-area "[]"
    set_gsettings_if_key_exists org.gnome.shell.keybindings show-screenshot-ui "[]"
    set_gsettings_if_key_exists org.gnome.shell.keybindings show-screen-recording-ui "[]"

    log "Configured Print Screen → Flameshot (GNOME)"
    shortcut_set=true
  fi

  # COSMIC (Pop!_OS 24.04+)
  local cosmic_shortcuts_dir="$HOME/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1"
  if [[ -d "$cosmic_shortcuts_dir" ]]; then
    local sa_file="$cosmic_shortcuts_dir/system_actions"
    if [[ -f "$sa_file" ]] && grep -q 'Screenshot:' "$sa_file"; then
      sed -i "s|Screenshot:.*|Screenshot: \"$flameshot_cmd\",|" "$sa_file"
    elif [[ -f "$sa_file" ]]; then
      # Append Screenshot entry before closing brace
      sed -i "\$i\\    Screenshot: \"$flameshot_cmd\"," "$sa_file"
    else
      cat > "$sa_file" <<SEOF
{
    Screenshot: "$flameshot_cmd",
}
SEOF
    fi
    log "Configured Print Screen → Flameshot (COSMIC)"
    shortcut_set=true
  fi

  if [[ "$shortcut_set" == "false" ]]; then
    warn "Could not configure Flameshot shortcut — unsupported desktop"
  fi
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
log "  Bootstrap"
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

# Create GitHub workspace folders
for dir in "$HOME/GitHub" "$HOME/GitHub/forks" "$HOME/GitHub/learning" "$HOME/GitHub/work"; do
  mkdir -p "$dir"
done
log "Folders created (TEMP, AppImage, OBS Rec, GitHub/{forks,learning,work})"

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
# Toolchains (rustup + nvm)
# ══════════════════════════════════════════════════════════════════════
log ""
log "═══════════════════════════════════════════════════════"
log "  Toolchains"
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

# Ensure a Node.js version is available (nvm.sh may have just installed nvm without a node version)
if ! command -v node >/dev/null 2>&1 && command -v nvm >/dev/null 2>&1; then
  log "No Node.js version found. Installing LTS..."
  nvm install --lts
  nvm alias default lts/*
fi

# ══════════════════════════════════════════════════════════════════════
# Tools (level-based: prebuilt or build)
# ══════════════════════════════════════════════════════════════════════
if [[ "$SKIP_TOOLS" == "false" ]]; then
  log ""
  bash "$SCRIPT_DIR/tools/install-all.sh" "$LEVEL" || warn "Some tool installations failed"
else
  log ""
  log "Skipping tools (--skip-tools)"
fi

# ══════════════════════════════════════════════════════════════════════
# Installers
# ══════════════════════════════════════════════════════════════════════
if [[ "$SKIP_INSTALLERS" == "false" ]]; then
  log ""
  bash "$SCRIPT_DIR/installers/install-all.sh" || warn "Some installers failed"
else
  log ""
  log "Skipping installers (--skip-installers)"
fi

# ══════════════════════════════════════════════════════════════════════
# Configs & Auth
# ══════════════════════════════════════════════════════════════════════
log ""
log "═══════════════════════════════════════════════════════"
log "  Configs & Auth"
log "═══════════════════════════════════════════════════════"

if [[ "$SKIP_CONFIGS" == "false" ]]; then
  bash "$SCRIPT_DIR/configs/restore-configs.sh" || warn "Config restore failed"
  bash "$SCRIPT_DIR/configs/startup-apps.sh" || warn "Startup apps failed"
  bash "$SCRIPT_DIR/configs/ide-extensions.sh" || warn "IDE extensions failed"
  bash "$SCRIPT_DIR/configs/browser-extensions.sh" || warn "Browser extensions failed"
  bash "$SCRIPT_DIR/configs/defaults.sh" || warn "Default apps/wallpaper failed"
  bash "$SCRIPT_DIR/configs/dns-nextdns.sh" || warn "DNS/NextDNS setup failed"
else
  log "Skipping config restore (--skip-configs)"
fi

# Set zsh as default shell
if is_installed zsh; then
  if [[ "$SHELL" != "$(which zsh)" ]]; then
    log "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
    log "Zsh set as default shell (takes effect on next login)"
  else
    log "Zsh is already the default shell"
  fi
fi

# Set terminal font to JetBrains Mono Nerd Font
NERD_FONT="JetBrainsMonoNL Nerd Font"
NERD_FONT_SIZE=12

# GNOME Terminal
if is_installed gnome-terminal; then
  PROFILE_ID=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d "'")
  if [[ -n "$PROFILE_ID" ]]; then
    PROFILE_PATH="/org/gnome/terminal/legacy/profiles:/:${PROFILE_ID}/"
    dconf write "${PROFILE_PATH}use-system-font" "false"
    dconf write "${PROFILE_PATH}font" "'${NERD_FONT} ${NERD_FONT_SIZE}'"
    log "GNOME Terminal font set to ${NERD_FONT} ${NERD_FONT_SIZE}"
  else
    log "No GNOME Terminal profile found — open the terminal once first"
  fi
fi

# Alacritty
if is_installed alacritty; then
  ALACRITTY_CFG="$HOME/.config/alacritty/alacritty.toml"
  mkdir -p "$(dirname "$ALACRITTY_CFG")"
  if ! grep -q "font" "$ALACRITTY_CFG" 2>/dev/null; then
    cat >> "$ALACRITTY_CFG" <<EOF

[font]
size = ${NERD_FONT_SIZE}

[font.normal]
family = "${NERD_FONT}"
EOF
    log "Alacritty font set to ${NERD_FONT} ${NERD_FONT_SIZE}"
  else
    log "Alacritty already has font config — skipping"
  fi
fi

# COSMIC Terminal (Pop!_OS)
if is_installed cosmic-term; then
  COSMIC_CFG="$HOME/.config/cosmic/com.system76.CosmicTerm/v1"
  mkdir -p "$COSMIC_CFG"
  echo "\"${NERD_FONT}\"" > "$COSMIC_CFG/font_family"
  echo "${NERD_FONT_SIZE}" > "$COSMIC_CFG/font_size"
  log "COSMIC Terminal font set to ${NERD_FONT} ${NERD_FONT_SIZE}"
fi

# SSH config (remember key after first unlock, no ssh-add needed after reboot)
SSH_CONFIG="$HOME/.ssh/config"
mkdir -p "$HOME/.ssh"
if [[ ! -f "$SSH_CONFIG" ]]; then
  cat > "$SSH_CONFIG" <<'EOF'
Host *
  AddKeysToAgent yes
  IdentityFile ~/.ssh/id_ed25519
EOF
  chmod 600 "$SSH_CONFIG"
  log "SSH config created (AddKeysToAgent enabled)"
else
  log "SSH config already exists — skipping"
fi

# Starship prompt config
STARSHIP_CFG="$HOME/.config/starship.toml"
if [[ ! -f "$STARSHIP_CFG" ]]; then
  mkdir -p "$(dirname "$STARSHIP_CFG")"
  cp "$SCRIPT_DIR/configs/starship.toml" "$STARSHIP_CFG"
  log "Starship config installed"
else
  log "Starship config already exists — skipping"
fi

# Configure Flameshot as Print Screen
configure_flameshot_shortcut || warn "Flameshot shortcut setup was not fully applied"

# SSH key generation
if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
  echo
  read -rp "Generate a new SSH key? [y/N]: " gen_ssh
  if [[ "$gen_ssh" =~ ^[Yy] ]]; then
    ssh-keygen -t ed25519 -C "$(git config user.email 2>/dev/null || echo "$USER@$(hostname)")" -f "$HOME/.ssh/id_ed25519"
    log "SSH key generated"
  fi
else
  log "SSH key already exists"
fi

# GitHub authentication (SSH key upload + CLI auth in one step)
if is_installed gh; then
  if ! gh auth status >/dev/null 2>&1; then
    echo
    read -rp "Authenticate with GitHub now? (uploads SSH key + authenticates CLI) [y/N]: " do_gh
    if [[ "$do_gh" =~ ^[Yy] ]]; then
      log "Starting GitHub authentication..."
      log "A browser window will open. Paste the code shown in the terminal."
      gh auth login -p ssh -h github.com -w
      log "GitHub CLI authenticated and SSH key uploaded"
    fi
  else
    log "GitHub CLI already authenticated"
  fi
fi

# Reminders
log ""
log "── Post-setup reminders ──────────────────────────────"
log "  • Run: sudo tailscale up       (join your Tailnet)"

# ══════════════════════════════════════════════════════════════════════
# Cleanup
# ══════════════════════════════════════════════════════════════════════
log ""
log "═══════════════════════════════════════════════════════"
log "  Cleanup"
log "═══════════════════════════════════════════════════════"

sudo apt-get autoclean -y
sudo apt-get autoremove -y
if is_installed flatpak; then
  flatpak update -y || true
fi

log ""
log "═══════════════════════════════════════════════════════"
log "  Setup complete! Phase $PHASE, Level $LEVEL — ${LEVEL_NAMES[$LEVEL]}"
log "═══════════════════════════════════════════════════════"
log "You may need to log out/in for all changes to take effect."
