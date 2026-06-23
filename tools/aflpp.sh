#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

LAB_DIR="${SECURITY_LAB_DIR:-$HOME/hacking}"
TOOLS_DIR="${SECURITY_TOOLS_DIR:-$LAB_DIR/tools}"
AFLPP_MCP_REPO="${AFLPP_MCP_REPO:-https://github.com/kevin-valerio/aflpp-mcp.git}"
AFLPP_MCP_DIR="${AFLPP_MCP_DIR:-$TOOLS_DIR/aflpp-mcp}"
IMAGE="${AFLPP_DOCKER_IMAGE:-aflplusplus/aflplusplus:latest}"

mkdir -p "$TOOLS_DIR"

if is_installed docker; then
  log "Pulling AFL++ Docker image: $IMAGE"
  docker pull "$IMAGE" || warn "AFL++ image pull failed; the wrapper can still pull/run it later"
  install_docker_wrapper aflpp-docker "$IMAGE" /src
  log "Run: aflpp-docker -h"
  log "Run with internet egress (e.g. for LLVM plugin fetches): LAB_RELAXED=1 aflpp-docker afl-fuzz ..."
else
  warn "Docker is not available; AFL++ container wrapper skipped"
fi

if [[ -d "$AFLPP_MCP_DIR/.git" ]]; then
  log "Updating AFL++ MCP repo: $AFLPP_MCP_DIR"
  git -C "$AFLPP_MCP_DIR" fetch --prune origin
  if [[ -z "$(git -C "$AFLPP_MCP_DIR" status --porcelain)" ]]; then
    git -C "$AFLPP_MCP_DIR" pull --ff-only || warn "AFL++ MCP pull skipped"
  else
    warn "AFL++ MCP repo has local changes; fetched only"
  fi
  git -C "$AFLPP_MCP_DIR" submodule update --init --recursive || warn "AFL++ MCP submodule update failed"
else
  log "Cloning AFL++ MCP repo with submodules..."
  git clone --recurse-submodules "$AFLPP_MCP_REPO" "$AFLPP_MCP_DIR"
fi

if ensure_node; then
  (
    cd "$AFLPP_MCP_DIR"
    bun_or_npm_install
    if is_installed bun; then
      bun run build
    else
      npm run build
    fi
  ) || warn "AFL++ MCP build failed"
fi

warn "MCP server registration is gated by configs/lab-mcp-consent.sh; run setup.sh to review and approve."
