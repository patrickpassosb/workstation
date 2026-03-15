#!/usr/bin/env bash
set -euo pipefail

VERSION=v0.50.0
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    local_ver="${VERSION#v}"
    case "$(uname -m)" in
      x86_64)  arch="x86_64" ;;
      aarch64) arch="arm64" ;;
      *)       err "Unsupported architecture: $(uname -m)"; exit 1 ;;
    esac
    github_release_install "jesseduffield/lazygit" "$VERSION" \
      "lazygit_${local_ver}_Linux_${arch}.tar.gz" "lazygit"
    ;;
  clone)
    clone_or_pull https://github.com/jesseduffield/lazygit.git lazygit "$VERSION"
    log "lazygit $VERSION cloned to $SRC_DIR/lazygit"
    log "To build manually (requires Go):"
    log "  cd $SRC_DIR/lazygit"
    log "  go build -o lazygit ."
    log "  sudo install -m 0755 lazygit $INSTALL_PREFIX/bin/lazygit"
    ;;
  build)
    clone_or_pull https://github.com/jesseduffield/lazygit.git lazygit "$VERSION"
    require_cmd go
    log "Building lazygit $VERSION..."
    cd "$SRC_DIR/lazygit"
    go build -o lazygit .
    sudo install -m 0755 lazygit "$INSTALL_PREFIX/bin/lazygit"
    log "lazygit installed to $INSTALL_PREFIX/bin/lazygit"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
