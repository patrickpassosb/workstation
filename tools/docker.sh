#!/usr/bin/env bash
# Docker: prebuilt installs docker-ce from Docker's official apt repo.
# Build mode compiles the CLI only (not the daemon).
set -euo pipefail

VERSION=v28.0.4
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    if is_installed docker; then
      log "docker is already installed: $(docker --version)"
    else
      log "Adding Docker apt repository..."
      sudo install -m 0755 -d /etc/apt/keyrings
      sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        -o /etc/apt/keyrings/docker.asc
      sudo chmod a+r /etc/apt/keyrings/docker.asc
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(get_ubuntu_codename) stable" \
        | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
      sudo apt-get update -y
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io \
        docker-buildx-plugin docker-compose-plugin
    fi
    ;;
  clone)
    clone_or_pull https://github.com/docker/cli.git docker-cli "$VERSION"
    log "Docker CLI $VERSION cloned to $SRC_DIR/docker-cli"
    log "To build manually (requires Go and build-essential):"
    log "  cd $SRC_DIR/docker-cli"
    log "  make binary"
    log "  sudo install -m 0755 build/docker $INSTALL_PREFIX/bin/docker"
    log "Note: This builds the CLI only. For the daemon, install docker-ce from Docker's official apt repo."
    ;;
  build)
    clone_or_pull https://github.com/docker/cli.git docker-cli "$VERSION"
    require_cmd go
    ensure_build_deps build-essential
    log "Building Docker CLI $VERSION..."
    cd "$SRC_DIR/docker-cli"
    make binary
    sudo install -m 0755 build/docker "$INSTALL_PREFIX/bin/docker"
    log "Docker CLI installed to $INSTALL_PREFIX/bin/docker"
    log "Note: This is the CLI only. For the daemon, install docker-ce from Docker's official apt repo."
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
