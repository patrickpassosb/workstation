#!/usr/bin/env bash
# This script builds the Docker CLI only.
# For the full Docker daemon (dockerd), install docker-ce from Docker's official apt repository.
set -euo pipefail

VERSION=v28.0.4

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed docker && [[ "$(docker --version 2>&1)" == *"${VERSION#v}"* ]]; then
  log "docker CLI $VERSION is already installed, skipping."
  exit 0
fi

ensure_build_deps build-essential

require_cmd go

clone_or_pull https://github.com/docker/cli.git docker-cli "$VERSION"

cd "$SRC_DIR/docker-cli"

log "Building Docker CLI $VERSION ..."
make binary

sudo install -m 0755 build/docker "$INSTALL_PREFIX/bin/docker"

log "Docker CLI $VERSION installed successfully."
warn "Note: This builds the Docker CLI only. For the daemon, install docker-ce from Docker's official apt repository."

cleanup_source docker-cli
