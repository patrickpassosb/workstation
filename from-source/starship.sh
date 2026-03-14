#!/usr/bin/env bash
set -euo pipefail

VERSION=v1.22.1

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed starship && [[ "$(starship --version)" == *"${VERSION#v}"* ]]; then
  log "starship ${VERSION#v} is already installed, skipping."
  exit 0
fi

require_cmd cargo

clone_or_pull https://github.com/starship/starship.git starship "$VERSION"

cd "$SRC_DIR/starship"

log "Building starship $VERSION ..."
cargo build --release

sudo install -m 0755 target/release/starship "$INSTALL_PREFIX/bin/starship"

log "starship ${VERSION#v} installed successfully."
log "To activate starship, add the appropriate init line to your shell config:"
log '  Bash: eval "$(starship init bash)"'
log '  Zsh:  eval "$(starship init zsh)"'
log '  Fish: starship init fish | source'

cleanup_source starship
