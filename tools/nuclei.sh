#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

IMAGE="${NUCLEI_DOCKER_IMAGE:-projectdiscovery/nuclei:latest}"
WRAPPER="$HOME/.local/bin/nuclei-docker"

if ! is_installed docker; then
  warn "Docker is required for the isolated Nuclei wrapper. Run tools/docker.sh first."
  exit 1
fi

log "Pulling Nuclei Docker image: $IMAGE"
docker pull "$IMAGE" || warn "Nuclei image pull failed; the wrapper can still pull/run it later"

install_docker_wrapper nuclei-docker "$IMAGE" /work
log "Run: nuclei-docker -h"
log "Run with internet egress (e.g. for template updates): LAB_RELAXED=1 nuclei-docker -t templates"
