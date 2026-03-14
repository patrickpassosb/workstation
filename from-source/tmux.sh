#!/usr/bin/env bash
set -euo pipefail

VERSION=3.5a

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed tmux && [[ "$(tmux -V)" == *"$VERSION"* ]]; then
  log "tmux $VERSION is already installed, skipping."
  exit 0
fi

ensure_build_deps build-essential autoconf automake libevent-dev libncurses-dev bison pkg-config

clone_or_pull https://github.com/tmux/tmux.git tmux "$VERSION"

cd "$SRC_DIR/tmux"

log "Building tmux $VERSION ..."
sh autogen.sh
./configure --prefix="$INSTALL_PREFIX"
make -j"$(nproc)"
sudo make install

log "tmux $VERSION installed successfully."

cleanup_source tmux
