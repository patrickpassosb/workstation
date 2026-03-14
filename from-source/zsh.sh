#!/usr/bin/env bash
set -euo pipefail

VERSION=zsh-5.9.1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed zsh && [[ "$(zsh --version)" == *"${VERSION#zsh-}"* ]]; then
  log "zsh ${VERSION#zsh-} is already installed, skipping."
  exit 0
fi

ensure_build_deps build-essential autoconf libncurses-dev texinfo yodl

clone_or_pull https://github.com/zsh-users/zsh.git zsh "$VERSION"

cd "$SRC_DIR/zsh"

log "Building zsh $VERSION ..."
./Util/preconfig
./configure --prefix="$INSTALL_PREFIX"
make -j"$(nproc)"
sudo make install

# Ensure zsh is listed in /etc/shells
if ! grep -qx "$INSTALL_PREFIX/bin/zsh" /etc/shells; then
  log "Adding $INSTALL_PREFIX/bin/zsh to /etc/shells"
  echo "$INSTALL_PREFIX/bin/zsh" | sudo tee -a /etc/shells >/dev/null
fi

log "zsh $VERSION installed successfully."

cleanup_source zsh
