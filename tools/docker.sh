#!/usr/bin/env bash
# This script clones the Docker CLI source only.
# For the full Docker daemon (dockerd), install docker-ce from Docker's official apt repository.
set -euo pipefail

VERSION=v28.0.4

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

clone_or_pull https://github.com/docker/cli.git docker-cli "$VERSION"

log "Docker CLI $VERSION cloned to $SRC_DIR/docker-cli"
log "To build manually (requires Go and build-essential):"
log "  cd $SRC_DIR/docker-cli"
log "  make binary"
log "  sudo install -m 0755 build/docker $INSTALL_PREFIX/bin/docker"
log "Note: This builds the CLI only. For the daemon, install docker-ce from Docker's official apt repo."
