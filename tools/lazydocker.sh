#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

VERSION="${VERSION:-$(github_latest_tag jesseduffield/lazydocker 2>/dev/null || echo v0.25.0)}"

case "$MODE" in
  prebuilt)
    local_ver="${VERSION#v}"
    case "$(uname -m)" in
      x86_64)  arch="x86_64" ;;
      aarch64) arch="arm64" ;;
      *)       err "Unsupported architecture: $(uname -m)"; exit 1 ;;
    esac
    github_release_install "jesseduffield/lazydocker" "$VERSION" \
      "lazydocker_${local_ver}_Linux_${arch}.tar.gz" "lazydocker"
    ;;
  clone)
    clone_or_pull https://github.com/jesseduffield/lazydocker.git lazydocker "$VERSION"
    log "lazydocker $VERSION cloned to $SRC_DIR/lazydocker"
    log "To build manually (requires Go):"
    log "  cd $SRC_DIR/lazydocker"
    log "  go build -o lazydocker ."
    log "  sudo install -m 0755 lazydocker $INSTALL_PREFIX/bin/lazydocker"
    ;;
  build)
    clone_or_pull https://github.com/jesseduffield/lazydocker.git lazydocker "$VERSION"
    require_cmd go
    log "Building lazydocker $VERSION..."
    cd "$SRC_DIR/lazydocker"
    go build -o lazydocker .
    sudo install -m 0755 lazydocker "$INSTALL_PREFIX/bin/lazydocker"
    log "lazydocker installed to $INSTALL_PREFIX/bin/lazydocker"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
