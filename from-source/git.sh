#!/usr/bin/env bash
set -euo pipefail

VERSION=v2.48.1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed git && [[ "$(git --version)" == *"${VERSION#v}"* ]]; then
  log "git ${VERSION#v} is already installed, skipping."
  exit 0
fi

ensure_build_deps build-essential libssl-dev libcurl4-openssl-dev libexpat1-dev gettext zlib1g-dev

clone_or_pull https://github.com/git/git.git git "$VERSION"

cd "$SRC_DIR/git"

log "Building git $VERSION ..."
make prefix="$INSTALL_PREFIX" -j"$(nproc)" all
sudo make prefix="$INSTALL_PREFIX" install

log "git $VERSION installed successfully."

cleanup_source git
