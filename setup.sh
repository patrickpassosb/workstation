#!/usr/bin/env bash
set -euo pipefail

# Prebuilt-only workstation setup.
# Runs unattended. Installs every tool as a prebuilt binary (no compilation).
# Usage: ./setup.sh [--skip-security-lab]

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

# Parse CLI flags
SKIP_SECURITY_LAB=0
for arg in "$@"; do
  case "$arg" in
    --skip-security-lab) SKIP_SECURITY_LAB=1 ;;
    --with-security-lab) SKIP_SECURITY_LAB=0 ;;
    -h|--help)
      cat <<'USAGE'
Usage: ./setup.sh [--skip-security-lab] [--with-security-lab]

  --skip-security-lab  Skip Nuclei, Semgrep, CodeQL, Snyk, MCPs, Ghidra, etc.
  --with-security-lab  Install the security lab (default).
USAGE
      exit 0
      ;;
    *) warn "Unknown argument: $arg" ;;
  esac
done
export SKIP_SECURITY_LAB

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

  if dconf list /org/cinnamon/desktop/keybindings/ >/dev/null 2>&1; then
    dconf write /org/cinnamon/desktop/keybindings/custom-list "['custom0']"
    dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom0/name "'Flameshot'"
    dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom0/command "'$flameshot_cmd'"
    dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom0/binding "['Print']"
    dconf write /org/cinnamon/desktop/keybindings/media-keys/screenshot "@as []"
    log "Configured Print Screen → Flameshot (Cinnamon)"
    shortcut_set=true
  fi

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

  local cosmic_shortcuts_dir="$HOME/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1"
  if [[ -d "$cosmic_shortcuts_dir" ]]; then
    local sa_file="$cosmic_shortcuts_dir/system_actions"
    if [[ -f "$sa_file" ]] && grep -q 'Screenshot:' "$sa_file"; then
      sed -i "s|Screenshot:.*|Screenshot: \"$flameshot_cmd\",|" "$sa_file"
    elif [[ -f "$sa_file" ]]; then
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

  if [[ "${XDG_CURRENT_DESKTOP:-}" == *"KDE"* ]] || command -v kwriteconfig6 >/dev/null 2>&1 || command -v kwriteconfig5 >/dev/null 2>&1; then
    warn "KDE detected. Bind Print Screen to '$flameshot_cmd' in System Settings -> Shortcuts."
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
# Preflight
# ══════════════════════════════════════════════════════════════════════
log "═══════════════════════════════════════════════════════"
log "  Preflight"
log "═══════════════════════════════════════════════════════"

if ! ping -c 1 -W 3 8.8.8.8 >/dev/null 2>&1; then
  err "No internet connectivity. Aborting."
  exit 1
fi
log "Internet connectivity OK"

require_cmd sudo
require_cmd curl
case "$(pkg_manager)" in
  apt) require_cmd apt-get ;;
  dnf) require_cmd dnf ;;
  *)
    err "Unsupported Linux distribution: $(distro_id)"
    exit 1
    ;;
esac

# ══════════════════════════════════════════════════════════════════════
# Bootstrap
# ══════════════════════════════════════════════════════════════════════
log ""
log "═══════════════════════════════════════════════════════"
log "  Bootstrap"
log "═══════════════════════════════════════════════════════"

log "Refreshing package index"
pkg_update

if is_fedora_like; then
  sudo dnf group install -y "Development Tools" || warn "Fedora Development Tools group install failed"
  for pkg in ca-certificates curl wget gnupg2 flatpak unzip fontconfig xdg-user-dirs xclip wl-clipboard util-linux-user findutils tar gzip python3 python3-pip; do
    pkg_install_if_missing "$pkg" || true
  done
  for pkg in kio-extras timeshift v4l2loopback; do
    pkg_install_if_missing "$pkg" || true
  done
else
  for pkg in build-essential ca-certificates curl wget gnupg software-properties-common flatpak unzip python3 python3-pip; do
    pkg_install_if_missing "$pkg" || true
  done

  for pkg in gnome-sushi folder-color-common timeshift vlc v4l2loopback-utils xclip; do
    pkg_install_if_missing "$pkg" || true
  done
fi

if is_installed flatpak; then
  if ! flatpak remotes --columns=name 2>/dev/null | grep -qx flathub; then
    log "Adding Flathub remote"
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  else
    log "Flathub remote already configured"
  fi
fi

VIDEOS_DIR="$(xdg-user-dir VIDEOS 2>/dev/null || echo "$HOME/Videos")"
for dir in "$HOME/TEMP" "$HOME/AppImage" "$VIDEOS_DIR/OBS Rec"; do
  mkdir -p "$dir"
done

for dir in "$HOME/GitHub" "$HOME/GitHub/forks" "$HOME/GitHub/learning" "$HOME/GitHub/work"; do
  mkdir -p "$dir"
done
log "Folders created (TEMP, AppImage, $VIDEOS_DIR/OBS Rec, GitHub/{forks,learning,work})"

BOOKMARKS_FILE="$HOME/.config/gtk-3.0/bookmarks"
mkdir -p "$(dirname "$BOOKMARKS_FILE")"
touch "$BOOKMARKS_FILE"
for dir in "$HOME/TEMP" "$HOME/AppImage" "$VIDEOS_DIR/OBS Rec"; do
  encoded="file://$(echo "$dir" | sed 's/ /%20/g')"
  if ! grep -qF "$encoded" "$BOOKMARKS_FILE" 2>/dev/null; then
    echo "$encoded" >> "$BOOKMARKS_FILE"
    log "Added Nautilus bookmark: $dir"
  fi
done

# Patch any third-party apt sources that hard-code a stale distro codename
# (e.g. Linux Mint's "zena" in an insync.list). No-op on Fedora.
bash "$SCRIPT_DIR/fix-sources.sh" || warn "fix-sources.sh reported issues"

install_jetbrains_mono_nerd_font || warn "Font installation failed"

# ══════════════════════════════════════════════════════════════════════
# Toolchains (rustup + nvm — still needed for Node/Rust-based CLIs)
# ══════════════════════════════════════════════════════════════════════
log ""
log "═══════════════════════════════════════════════════════"
log "  Toolchains"
log "═══════════════════════════════════════════════════════"

bash "$SCRIPT_DIR/installers/rustup.sh" || warn "Rustup installation failed"

if [[ -f "$HOME/.cargo/env" ]]; then
  source "$HOME/.cargo/env"
fi

bash "$SCRIPT_DIR/installers/nvm.sh" || warn "NVM installation failed"

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
# shellcheck disable=SC1091
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

if ! command -v node >/dev/null 2>&1 && command -v nvm >/dev/null 2>&1; then
  log "No Node.js version found. Installing LTS..."
  nvm install --lts
  nvm alias default lts/*
fi

# ══════════════════════════════════════════════════════════════════════
# Tools (all prebuilt)
# ══════════════════════════════════════════════════════════════════════
log ""
bash "$SCRIPT_DIR/tools/install-all.sh" || warn "Some tool installations failed"

# ══════════════════════════════════════════════════════════════════════
# Installers (proprietary apps + agentic tools)
# ══════════════════════════════════════════════════════════════════════
log ""
bash "$SCRIPT_DIR/installers/install-all.sh" || warn "Some installers failed"
bash "$SCRIPT_DIR/installers/agent-tools.sh" || warn "Agent tools installation failed"

# ══════════════════════════════════════════════════════════════════════
# Configs
# ══════════════════════════════════════════════════════════════════════
log ""
log "═══════════════════════════════════════════════════════"
log "  Configs"
log "═══════════════════════════════════════════════════════"

bash "$SCRIPT_DIR/configs/restore-configs.sh" || warn "Config restore failed"
bash "$SCRIPT_DIR/configs/obsidian-vault.sh" || warn "Obsidian vault setup failed"
bash "$SCRIPT_DIR/configs/startup-apps.sh" || warn "Startup apps failed"
bash "$SCRIPT_DIR/configs/ide-extensions.sh" || warn "IDE extensions failed"
bash "$SCRIPT_DIR/configs/browser-extensions.sh" || warn "Browser extensions failed"
bash "$SCRIPT_DIR/configs/defaults.sh" || warn "Default apps/wallpaper failed"
bash "$SCRIPT_DIR/configs/sync-skills.sh" || warn "Skills sync failed"
bash "$SCRIPT_DIR/configs/centralize-skills.sh" || warn "Skills centralization failed"
bash "$SCRIPT_DIR/configs/npm-security.sh" || warn "NPM security setup failed"
bash "$SCRIPT_DIR/configs/unattended-upgrades.sh" || warn "Unattended upgrades setup failed"
bash "$SCRIPT_DIR/configs/firewall.sh" || warn "Firewall setup failed"
bash "$SCRIPT_DIR/configs/clamav.sh" || warn "ClamAV setup failed"
bash "$SCRIPT_DIR/configs/dns-nextdns.sh" || warn "DNS/NextDNS setup failed"
bash "$SCRIPT_DIR/configs/focus-mode.sh" || warn "Focus Mode setup failed"

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

# Terminal font
NERD_FONT="JetBrainsMonoNL Nerd Font"
NERD_FONT_SIZE=12

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

if is_installed cosmic-term; then
  COSMIC_CFG="$HOME/.config/cosmic/com.system76.CosmicTerm/v1"
  mkdir -p "$COSMIC_CFG"
  echo "\"${NERD_FONT}\"" > "$COSMIC_CFG/font_family"
  echo "${NERD_FONT_SIZE}" > "$COSMIC_CFG/font_size"
  log "COSMIC Terminal font set to ${NERD_FONT} ${NERD_FONT_SIZE}"
fi

# SSH config (remember key after first unlock). Does NOT generate a key.
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

configure_flameshot_shortcut || warn "Flameshot shortcut setup was not fully applied"

if command -v flatpak >/dev/null 2>&1 && flatpak info org.flameshot.Flameshot >/dev/null 2>&1; then
  flatpak override --user org.flameshot.Flameshot --socket=session-bus
  log "Flameshot Flatpak clipboard access granted"
fi

# Post-install verification for agentic tools
log ""
log "── Agentic Tool Verification ────────────────────────"
for tool in ctx7 chub omx omo sisyphus voquill; do
  if is_installed "$tool"; then
    log "  ✓ $tool is available"
  else
    warn "  ✗ $tool not found in PATH"
  fi
done

log ""
log "── Security Lab Verification ────────────────────────"
ensure_local_bin_dir

check_path() {
  local name="$1"
  if is_installed "$name"; then
    log "  ✓ $name is available"
  else
    warn "  ✗ $name not found in PATH"
  fi
}

check_artifact() {
  local label="$1"
  shift
  local found=0
  for path in "$@"; do
    if [[ -e $path ]]; then
      log "  ✓ $label ($path)"
      found=1
      break
    fi
  done
  if [[ $found -eq 0 ]]; then
    warn "  ✗ $label not found (looked: $*)"
  fi
}

check_path obsidian-app
check_path semgrep
check_artifact "codeql CLI" \
  "$HOME/.local/bin/codeql" \
  "$HOME/.local/codeql/codeql"
check_artifact "nuclei wrapper" \
  "$HOME/.local/bin/nuclei-docker"
check_artifact "AFL++ wrapper" \
  "$HOME/.local/bin/aflpp-docker"
check_path snyk-agent-scan-safe
check_path caido
check_path ghidraRun

if is_installed docker && docker network inspect lab-none >/dev/null 2>&1; then
  log "  ✓ lab-none Docker network (no egress)"
else
  warn "  ✗ lab-none Docker network is not present"
fi

if [[ -f "$HOME/hacking/AGENTS.md" ]]; then
  log "  ✓ ~/hacking/AGENTS.md (agent policy)"
else
  warn "  ✗ ~/hacking/AGENTS.md is missing"
fi

log ""
log "── MCP consent ──────────────────────────────────────"
if [[ -t 0 ]]; then
  bash "$SCRIPT_DIR/configs/lab-mcp-consent.sh" || warn "MCP consent step was skipped or failed"
else
  log "  (non-interactive: skipping MCP consent; run setup.sh in a TTY to review)"
fi

log ""
log "── Post-setup summary ───────────────────────────────"
bash "$SCRIPT_DIR/configs/summary.sh" || warn "summary.sh reported issues"

# ══════════════════════════════════════════════════════════════════════
# Cleanup
# ══════════════════════════════════════════════════════════════════════
log ""
log "═══════════════════════════════════════════════════════"
log "  Cleanup"
log "═══════════════════════════════════════════════════════"

pkg_cleanup
if is_installed flatpak; then
  flatpak update -y || true
fi

log ""
log "═══════════════════════════════════════════════════════"
log "  Setup complete!"
log "═══════════════════════════════════════════════════════"
log "You may need to log out/in for all changes to take effect."
