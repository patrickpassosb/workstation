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

# ── Distro helpers ────────────────────────────────────────────────────
# On Linux Mint (and other Ubuntu derivatives), VERSION_CODENAME and
# lsb_release -cs return the Mint codename (e.g. "zena"), but third-party
# apt repos need the underlying Ubuntu codename (e.g. "noble").
get_ubuntu_codename() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}"
  else
    lsb_release -cs 2>/dev/null || echo "noble"
  fi
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

# ── GitHub latest release ────────────────────────────────────────────
# Fetches the latest release tag from a GitHub repo.
#   github_latest_tag <owner/repo>
# Returns the tag name (e.g. "v0.25.0").
github_latest_tag() {
  local repo="$1"
  local tag
  tag="$(curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" \
    | grep -m1 '"tag_name"' | cut -d'"' -f4 | tr -d '[:space:]')"
  echo "$tag"
}

# ── GitHub release installer ─────────────────────────────────────────
# Downloads a binary release from GitHub and installs it.
#   github_release_install <owner/repo> <tag> <asset_filename> <binary_name>
# The asset is downloaded, extracted (tar.gz/zip), and the binary is
# installed to $INSTALL_PREFIX/bin/.
github_release_install() {
  local repo="$1"      # e.g. "jesseduffield/lazygit"
  local tag="$2"       # e.g. "v0.50.0"
  local asset="$3"     # e.g. "lazygit_0.50.0_Linux_x86_64.tar.gz"
  local binary="$4"    # e.g. "lazygit"

  if is_installed "$binary"; then
    log "$binary is already installed: $(command -v "$binary")"
    return 0
  fi

  local url="https://github.com/${repo}/releases/download/${tag}/${asset}"
  local tmp_dir
  tmp_dir="$(mktemp -d)"

  log "Downloading ${repo} ${tag} from GitHub releases..."
  curl -fSL "$url" -o "$tmp_dir/$asset"

  case "$asset" in
    *.tar.gz|*.tgz) tar -xzf "$tmp_dir/$asset" -C "$tmp_dir" ;;
    *.zip)          unzip -o "$tmp_dir/$asset" -d "$tmp_dir" ;;
  esac

  local bin_path
  bin_path="$(find "$tmp_dir" -name "$binary" -type f -print -quit)"
  if [[ -z "$bin_path" ]]; then
    err "Binary '$binary' not found in release archive"
    rm -rf "$tmp_dir"
    return 1
  fi

  sudo install -m 0755 "$bin_path" "${INSTALL_PREFIX}/bin/${binary}"
  rm -rf "$tmp_dir"
  log "Installed $binary to ${INSTALL_PREFIX}/bin/${binary}"
}

# ── NVM/npm helpers ──────────────────────────────────────────────────
ensure_nvm() {
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    # shellcheck disable=SC1091
    source "$NVM_DIR/nvm.sh"
    return 0
  fi
  warn "NVM is not installed. Install it first (installers/nvm.sh or setup.sh)."
  return 1
}

ensure_node() {
  if is_installed node; then return 0; fi
  if ensure_nvm; then
    nvm use default 2>/dev/null || nvm use --lts 2>/dev/null || true
    if is_installed node; then return 0; fi
  fi
  warn "Node.js is not available. Install it first (tools/nodejs.sh)."
  return 1
}
