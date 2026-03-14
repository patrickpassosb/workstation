#!/usr/bin/env bash
set -euo pipefail

VERSION=jq-1.7.1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed jq && [[ "$(jq --version)" == *"${VERSION#jq-}"* ]]; then
  log "jq ${VERSION#jq-} is already installed, skipping."
  exit 0
fi

ensure_build_deps build-essential autoconf automake libtool

clone_or_pull https://github.com/jqlang/jq.git jq "$VERSION"

cd "$SRC_DIR/jq"

log "Building jq $VERSION ..."
git submodule update --init
autoreconf -i
./configure --prefix="$INSTALL_PREFIX" --with-oniguruma=builtin
make -j"$(nproc)"
sudo make install

log "jq $VERSION installed successfully."

cleanup_source jq
