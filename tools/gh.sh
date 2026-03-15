#!/usr/bin/env bash
set -euo pipefail

VERSION=v2.69.0
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    if is_installed gh; then
      log "gh is already installed: $(gh --version | head -1)"
    else
      log "Adding GitHub CLI apt repository..."
      add_apt_repo "github-cli" \
        "https://cli.github.com/packages/githubcli-archive-keyring.gpg" \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/github-cli-archive-keyring.gpg] https://cli.github.com/packages stable main"
      apt_install_if_missing gh
    fi
    ;;
  clone)
    clone_or_pull https://github.com/cli/cli.git gh "$VERSION"
    log "gh $VERSION cloned to $SRC_DIR/gh"
    log "To build manually (requires Go):"
    log "  cd $SRC_DIR/gh"
    log "  make bin/gh"
    log "  sudo install -m 0755 bin/gh $INSTALL_PREFIX/bin/gh"
    ;;
  build)
    clone_or_pull https://github.com/cli/cli.git gh "$VERSION"
    require_cmd go
    log "Building gh $VERSION..."
    cd "$SRC_DIR/gh"
    make bin/gh
    sudo install -m 0755 bin/gh "$INSTALL_PREFIX/bin/gh"
    log "gh installed to $INSTALL_PREFIX/bin/gh"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
