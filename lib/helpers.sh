#!/usr/bin/env bash
# Shared helper functions for setup scripts.

set -euo pipefail

# ── Defaults ──────────────────────────────────────────────────────────
SRC_DIR="${SRC_DIR:-$HOME/src}"
INSTALL_PREFIX="${INSTALL_PREFIX:-/usr/local}"

# ── Logging ───────────────────────────────────────────────────────────
log()  { printf '[INFO]  %s\n' "$*"; }
warn() { printf '[WARN]  %s\n' "$*"; }
err()  { printf '[ERROR] %s\n' "$*"; }

# ── Dependency checks ────────────────────────────────────────────────
require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    err "Required command not found: $1"
    exit 1
  fi
}

is_installed() {
  command -v "$1" >/dev/null 2>&1
}

# ── APT helpers ───────────────────────────────────────────────────────
apt_install_if_missing() {
  local pkg="$1"
  if dpkg -s "$pkg" >/dev/null 2>&1; then
    log "APT package already installed: $pkg"
    return 0
  fi
  if apt-cache show "$pkg" >/dev/null 2>&1; then
    log "Installing APT package: $pkg"
    sudo apt-get install -y "$pkg"
    return 0
  fi
  warn "APT package not found: $pkg"
  return 1
}

ensure_build_deps() {
  log "Ensuring build dependencies: $*"
  for pkg in "$@"; do
    apt_install_if_missing "$pkg" || true
  done
}

add_apt_repo() {
  local name="$1"       # e.g. "brave-browser"
  local gpg_url="$2"    # URL to the GPG key
  local repo_line="$3"  # full deb [...] line

  sudo install -d -m 0755 /etc/apt/keyrings
  if [[ ! -f "/etc/apt/keyrings/${name}-archive-keyring.gpg" ]]; then
    log "Adding GPG key for $name"
    sudo curl -fsSLo "/etc/apt/keyrings/${name}-archive-keyring.gpg" "$gpg_url"
  fi
  echo "$repo_line" | sudo tee "/etc/apt/sources.list.d/${name}.list" >/dev/null
  sudo apt-get update -y
}

# ── Flatpak helper ────────────────────────────────────────────────────
flatpak_install_if_missing() {
  local app_id="$1"
  if ! command -v flatpak >/dev/null 2>&1; then
    warn "Flatpak is not available. Skipping $app_id"
    return 1
  fi
  if flatpak info "$app_id" >/dev/null 2>&1; then
    log "Flatpak app already installed: $app_id"
    return 0
  fi
  log "Installing Flatpak app: $app_id"
  flatpak install -y flathub "$app_id"
}

# ── Git / source helpers ─────────────────────────────────────────────
clone_or_pull() {
  local repo_url="$1"   # e.g. https://github.com/zsh-users/zsh.git
  local name="$2"       # directory name under $SRC_DIR
  local version="${3:-}" # optional tag/branch to checkout

  local dest="$SRC_DIR/$name"
  mkdir -p "$SRC_DIR"

  if [[ -d "$dest/.git" ]]; then
    log "Updating existing source: $name"
    git -C "$dest" fetch --tags --force
  else
    log "Cloning $repo_url → $dest"
    git clone "$repo_url" "$dest"
  fi

  if [[ -n "$version" ]]; then
    log "Checking out $version"
    git -C "$dest" checkout "$version"
  fi
}

