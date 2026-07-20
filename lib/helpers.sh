#!/usr/bin/env bash
# Shared helper functions for setup scripts.

set -euo pipefail

# ── Defaults ──────────────────────────────────────────────────────────
INSTALL_PREFIX="${INSTALL_PREFIX:-/usr/local}"

# ── Logging ───────────────────────────────────────────────────────────
log()  { printf '[INFO]  %s\n' "$*"; }
warn() { printf '[WARN]  %s\n' "$*"; }
err()  { printf '[ERROR] %s\n' "$*"; }

# ── Safe curl ─────────────────────────────────────────────────────────
# Wrapper that enforces --fail, retries, timeouts, and TLS hardening
# on every network fetch. Pass through any extra curl args after the
# URL.
#
#   safe_curl <url> [extra curl args...]
#   safe_curl -o <path> <url> [extra curl args...]
#
# Note on --no-config: an earlier version of this helper passed
# --no-config to prevent curl from reading ~/.curlrc as root. Modern
# curl (>= 8.x) rejects --no-config ("the given option cannot be
# reversed with a --no- prefix"), which broke every safe_curl call.
# We drop the flag — curl does not read ~/.curlrc when invoked with
# explicit args (and the caller can pass -q if they really want to
# suppress it).
safe_curl() {
  local out=""
  if [[ "$1" == "-o" ]]; then
    out="$2"
    shift 2
  fi
  local url="$1"
  shift
  if [[ -n "$out" ]]; then
    curl --fail --retry 3 --retry-delay 2 --connect-timeout 30 --max-time 600 \
      --proto '=https' --tlsv1.2 -sSL -o "$out" "$url" "$@"
  else
    curl --fail --retry 3 --retry-delay 2 --connect-timeout 30 --max-time 600 \
      --proto '=https' --tlsv1.2 -sSL "$url" "$@"
  fi
}

# Download a URL to a caller-provided output path, verifying its SHA256.
# The caller owns the output file and is responsible for cleanup.
#
#   download_and_verify <url> <expected_sha256> <out_path>
download_and_verify() {
  local url="$1" expected="$2" out="$3"
  if ! safe_curl -o "$out" "$url"; then
    err "Download failed: $url"
    return 1
  fi
  local actual
  actual="$(sha256sum "$out" | cut -d' ' -f1)"
  if [[ "$actual" != "$expected" ]]; then
    err "Checksum mismatch for $url"
    err "  expected: $expected"
    err "  actual:   $actual"
    return 1
  fi
}

# Download a URL to a caller-provided output path, verifying a detached
# PGP signature. Caller must supply the signing key via `gpg --import`
# beforehand.
#
#   download_and_verify_sig <url> <sig_url> <out_path>
download_and_verify_sig() {
  local url="$1" sig_url="$2" out="$3"
  local sig
  sig="$(mktemp)"
  trap 'rm -f "$sig"' RETURN
  if ! safe_curl -o "$out" "$url"; then
    err "Download failed: $url"
    return 1
  fi
  if ! safe_curl -o "$sig" "$sig_url"; then
    err "Signature download failed: $sig_url"
    return 1
  fi
  if ! gpg --verify "$sig" "$out" 2>/dev/null; then
    err "GPG signature verification failed for $url"
    return 1
  fi
}

# Download an installer script to a temp file, verify its SHA256 if
# provided, then execute it with the provided args. Use this instead of
# `curl ... | sh` so the bytes that run are the bytes that were
# verified. The temp file is cleaned up via a RETURN trap (safe here —
# the script is executed inside the function before return).
#
#   run_installer_script <url> [expected_sha256] [args...]
#   run_installer_script <url> "" [args...]      # no verification
run_installer_script() {
  local url="$1" expected="${2:-}"
  shift 2
  local tmp
  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' RETURN
  if ! safe_curl -o "$tmp" "$url"; then
    err "Installer download failed: $url"
    return 1
  fi
  if [[ -n "$expected" ]]; then
    local actual
    actual="$(sha256sum "$tmp" | cut -d' ' -f1)"
    if [[ "$actual" != "$expected" ]]; then
      err "Installer checksum mismatch for $url"
      err "  expected: $expected"
      err "  actual:   $actual"
      return 1
    fi
  else
    warn "Running installer without checksum verification: $url"
    log "  downloaded SHA256: $(sha256sum "$tmp" | cut -d' ' -f1)"
  fi
  bash "$tmp" "$@"
}

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

ensure_local_bin_dir() {
  mkdir -p "$HOME/.local/bin"
}

install_user_executable() {
  local target="$1"
  mkdir -p "$(dirname "$target")"
  cat > "$target"
  chmod 0755 "$target"
}

# ── Distro helpers ────────────────────────────────────────────────────
os_release_value() {
  local key="$1"
  if [[ -n "${WORKSTATION_DISTRO_OVERRIDE:-}" ]]; then
    case "$key" in
      ID) echo "$WORKSTATION_DISTRO_OVERRIDE" ;;
      ID_LIKE) echo "" ;;
      VERSION_ID) echo "" ;;
    esac
    return 0
  fi
  if [[ -f /etc/os-release ]]; then
    (
      # shellcheck disable=SC1091
      . /etc/os-release
      case "$key" in
        ID) echo "${ID:-}" ;;
        ID_LIKE) echo "${ID_LIKE:-}" ;;
        VERSION_ID) echo "${VERSION_ID:-}" ;;
      esac
    )
  fi
}

distro_id() {
  os_release_value ID
}

distro_id_like() {
  os_release_value ID_LIKE
}

is_fedora_like() {
  local id id_like
  id="$(distro_id)"
  id_like="$(distro_id_like)"
  [[ "$id" == "fedora" || "$id" == "rhel" || "$id" == "centos" || "$id_like" == *"fedora"* || "$id_like" == *"rhel"* ]]
}

is_ubuntu_like() {
  local id id_like
  id="$(distro_id)"
  id_like="$(distro_id_like)"
  [[ "$id" == "ubuntu" || "$id" == "debian" || "$id" == "pop" || "$id" == "linuxmint" || "$id_like" == *"ubuntu"* || "$id_like" == *"debian"* ]]
}

pkg_manager() {
  if is_fedora_like; then
    echo "dnf"
  elif is_ubuntu_like; then
    echo "apt"
  else
    echo "unknown"
  fi
}

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

# ── Package helpers ──────────────────────────────────────────────────
pkg_is_installed() {
  local pkg="$1"
  case "$(pkg_manager)" in
    apt)
      # dpkg -s returns success for deinstalled-but-config-remaining
      # packages (Status: deinstall ok config-files). Require a fully
      # installed package so pkg_install_if_missing doesn't skip
      # reinstalling a package whose binary was removed.
      dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q '^install ok installed$'
      ;;
    dnf) rpm -q "$pkg" >/dev/null 2>&1 ;;
    *) return 1 ;;
  esac
}

pkg_available() {
  local pkg="$1"
  case "$(pkg_manager)" in
    apt) apt-cache show "$pkg" >/dev/null 2>&1 ;;
    dnf) dnf -q list "$pkg" >/dev/null 2>&1 ;;
    *) return 1 ;;
  esac
}

pkg_update() {
  case "$(pkg_manager)" in
    apt) sudo apt-get update -y ;;
    dnf) sudo dnf makecache -y ;;
    *) err "Unsupported Linux distribution: $(distro_id)"; return 1 ;;
  esac
}

pkg_cleanup() {
  case "$(pkg_manager)" in
    apt)
      sudo apt-get autoclean -y
      sudo apt-get autoremove -y
      ;;
    dnf)
      sudo dnf autoremove -y || true
      sudo dnf clean packages || true
      ;;
    *) warn "No cleanup action for unsupported distribution: $(distro_id)" ;;
  esac
}

pkg_install_if_missing() {
  local pkg
  for pkg in "$@"; do
    if pkg_is_installed "$pkg"; then
      log "Package already installed: $pkg"
      continue
    fi
    if pkg_available "$pkg"; then
      log "Installing package: $pkg"
      case "$(pkg_manager)" in
        apt) sudo apt-get install -y "$pkg" ;;
        dnf) sudo dnf install -y "$pkg" ;;
      esac
    else
      warn "Package not found: $pkg"
      return 1
    fi
  done
}

install_first_available_pkg() {
  local pkg
  for pkg in "$@"; do
    if pkg_available "$pkg"; then
      pkg_install_if_missing "$pkg"
      return 0
    fi
  done
  warn "None of these packages were available: $*"
  return 1
}

ensure_dnf_config_manager() {
  if ! is_fedora_like; then
    return 0
  fi
  sudo dnf install -y 'dnf5-command(config-manager)' \
    || sudo dnf install -y dnf5-plugins \
    || sudo dnf install -y dnf-plugins-core \
    || true
}

add_dnf_repo() {
  local repo_url="$1"

  if ! is_fedora_like; then
    warn "DNF repository requested on non-dnf distro ($(distro_id)): $repo_url"
    return 1
  fi

  ensure_dnf_config_manager
  if command -v dnf-3 >/dev/null 2>&1; then
    sudo dnf-3 config-manager --add-repo "$repo_url"
  else
    sudo dnf config-manager addrepo --from-repofile="$repo_url" \
      || sudo dnf config-manager --add-repo "$repo_url"
  fi
}

# ── APT compatibility helpers ────────────────────────────────────────
apt_install_if_missing() {
  if ! is_ubuntu_like; then
    warn "apt package requested on non-apt distro ($(distro_id)): $*"
    return 1
  fi
  pkg_install_if_missing "$@"
}

add_apt_repo() {
  local name="$1"       # e.g. "brave-browser"
  local gpg_url="$2"    # URL to the GPG key
  local repo_line="$3"  # full deb [...] line

  if ! is_ubuntu_like; then
    warn "APT repository requested on non-apt distro ($(distro_id)): $name"
    return 1
  fi

  # Validate name — it flows into a path under /etc/apt/keyrings/ and
  # /etc/apt/sources.list.d/, so reject anything that could traverse.
  if [[ ! "$name" =~ ^[A-Za-z0-9._-]+$ ]]; then
    err "add_apt_repo: invalid repo name '$name' (must match ^[A-Za-z0-9._-]+\$)"
    return 1
  fi

  sudo install -d -m 0755 /etc/apt/keyrings
  if [[ ! -f "/etc/apt/keyrings/${name}-archive-keyring.gpg" ]]; then
    log "Adding GPG key for $name"
    # Download as the user (curl reads ~/.curlrc — avoid as root), then
    # install into the keyring as root. RETURN trap ensures the temp
    # file is cleaned up on any return path (including set -e aborts
    # from sudo install).
    local tmp_key
    tmp_key="$(mktemp)"
    trap 'rm -f "$tmp_key"' RETURN
    if safe_curl -o "$tmp_key" "$gpg_url"; then
      sudo install -m 0644 "$tmp_key" "/etc/apt/keyrings/${name}-archive-keyring.gpg"
    else
      err "Failed to download GPG key from $gpg_url"
      return 1
    fi
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

# ── GitHub latest release ────────────────────────────────────────────
# Fetches the latest release tag from a GitHub repo.
#   github_latest_tag <owner/repo>
# Returns the tag name (e.g. "v0.25.0").
# Uses GITHUB_TOKEN env var if present to avoid 60/hr unauthenticated
# rate limit. Returns non-zero on failure (callers should handle).
github_latest_tag() {
  local repo="$1"
  local auth_args=()
  if [[ -n "${GITHUB_TOKEN:-${GH_TOKEN:-}}" ]]; then
    auth_args=(-H "Authorization: Bearer ${GITHUB_TOKEN:-${GH_TOKEN}}")
  fi
  safe_curl "https://api.github.com/repos/${repo}/releases/latest" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "${auth_args[@]}" \
    | grep -m1 '"tag_name"' | cut -d'"' -f4 | tr -d '[:space:]'
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
  safe_curl -o "$tmp_dir/$asset" "$url"

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

# ── Bun-preferred Node package installers ────────────────────────────
# Bun is ~10-20x faster than npm. Fall back to npm when bun isn't available.
bun_or_npm_install_global() {
  local pkg="$1"
  if is_installed bun; then
    log "  Using bun (global): $pkg"
    bun install -g "$pkg"
  else
    log "  Using npm (global): $pkg"
    npm install -g "$pkg"
  fi
}

bun_or_npm_install() {
  if is_installed bun; then
    log "  Using bun install (cwd: $(pwd))"
    bun install
  else
    log "  Using npm install (cwd: $(pwd))"
    npm install
  fi
}

# Install a Node/TS global CLI via bun (or npm fallback). Ensures Node
# is available first. Use this for any npm-package-backed CLI so the
# boilerplate (ensure_node + log + install) lives in one place.
#   install_node_cli <log_label> <npm_package>
install_node_cli() {
  local label="$1" pkg="$2"
  ensure_node
  log "Installing $label..."
  bun_or_npm_install_global "$pkg"
}

# ── Security lab helpers ─────────────────────────────────────────────
# Idempotently create an internal Docker network with no egress.
# Used by hardened container wrappers to prevent accidental exfiltration.
docker_network_ensure() {
  local net="$1"
  if ! is_installed docker; then
    return 0
  fi
  if docker network inspect "$net" >/dev/null 2>&1; then
    return 0
  fi
  log "Creating internal Docker network: $net (no internet egress)"
  docker network create --internal "$net" >/dev/null 2>&1 \
    || warn "Failed to create $net; wrappers will fall back to host network"
}

# Install a hardened Docker wrapper to ~/.local/bin/<name>.
#   install_docker_wrapper <name> <image> <mount_path>
# The wrapper:
#   - bind-mounts $PWD at <mount_path> (rw)
#   - runs as the current user (no root in container)
#   - drops all capabilities, blocks suid escalation
#   - mounts the filesystem read-only except the project dir
#   - defaults to the internal 'lab-none' network (no egress)
#   - honors LAB_RELAXED=1 to switch to --network=host (escape hatch)
install_docker_wrapper() {
  local name="$1"
  local image="$2"
  local mount="$3"
  local target="$HOME/.local/bin/$name"

  ensure_local_bin_dir

  install_user_executable "$target" <<EOF
#!/usr/bin/env bash
set -euo pipefail

image='$image'
mount='$mount'
relaxed="\${LAB_RELAXED:-0}"

if [[ "\$relaxed" == "1" ]]; then
  network_args=(--network=host)
  printf '[WARN] LAB_RELAXED=1: $name is using host network (egress enabled)\\n' >&2
else
  network_args=(--network=lab-none)
fi

tty_args=()
if [[ -t 0 && -t 1 ]]; then
  tty_args=(-it)
fi

exec docker run --rm "\${tty_args[@]}" \
  --read-only \
  --cap-drop=ALL \
  --security-opt=no-new-privileges \
  -u "\$(id -u):\$(id -g)" \
  -v "\$PWD:\${mount}:rw" \
  -w "\${mount}" \
  "\${network_args[@]}" \
  "\$image" "\$@"
EOF

  log "Installed hardened wrapper: $target (use LAB_RELAXED=1 to allow egress)"
}

# Install a cautious uvx wrapper to ~/.local/bin/<name>.
#   install_uvx_wrapper <name> <pkg> [warn_message]
install_uvx_wrapper() {
  local name="$1"
  local pkg="$2"
  local warn_msg="${3:-This tool can execute commands or send data to a remote service.}"
  local target="$HOME/.local/bin/$name"

  ensure_local_bin_dir

  install_user_executable "$target" <<EOF
#!/usr/bin/env bash
set -euo pipefail

printf '[WARN] %s\\n' "\$0: $warn_msg" >&2
exec uvx "$pkg@latest" "\$@"
EOF

  log "Installed cautious wrapper: $target"
}
