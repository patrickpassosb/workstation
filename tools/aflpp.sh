#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

LAB_DIR="${SECURITY_LAB_DIR:-$HOME/hacking}"
TOOLS_DIR="${SECURITY_TOOLS_DIR:-$LAB_DIR/tools}"
AFLPP_MCP_REPO="${AFLPP_MCP_REPO:-https://github.com/kevin-valerio/aflpp-mcp.git}"
AFLPP_MCP_DIR="${AFLPP_MCP_DIR:-$TOOLS_DIR/aflpp-mcp}"
# Pin to a specific commit of the third-party aflpp-mcp repo for
# supply-chain safety (this repo is cloned WITH submodules). Set
# AFLPP_MCP_COMMIT to enforce it; without it, the script logs the
# resolved HEAD so you can pin it later.
AFLPP_MCP_COMMIT="${AFLPP_MCP_COMMIT:-}"
# Prefer a pinned image digest over the mutable :latest tag. Set
# AFLPP_DOCKER_IMAGE to image@sha256:... to pin; defaults to :latest
# for convenience but logs a warning with the resolved digest.
IMAGE="${AFLPP_DOCKER_IMAGE:-aflplusplus/aflplusplus:latest}"

mkdir -p "$TOOLS_DIR"

if is_installed docker; then
  log "Pulling AFL++ Docker image: $IMAGE"
  docker pull "$IMAGE" || warn "AFL++ image pull failed; the wrapper can still pull/run it later"
  if [[ "$IMAGE" != *@sha256:* ]]; then
    warn "AFLPP_DOCKER_IMAGE uses a mutable tag ($IMAGE); pin a digest for reproducibility:"
    log "  resolved digest: $(docker inspect --format='{{index .RepoDigests 0}}' "$IMAGE" 2>/dev/null || echo 'not yet pulled')"
  fi
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

if [[ -n "$AFLPP_MCP_COMMIT" ]]; then
  log "Pinning AFL++ MCP to commit $AFLPP_MCP_COMMIT"
  git -C "$AFLPP_MCP_DIR" checkout "$AFLPP_MCP_COMMIT" \
    || { err "AFL++ MCP checkout of $AFLPP_MCP_COMMIT failed"; exit 1; }
  git -C "$AFLPP_MCP_DIR" submodule update --init --recursive \
    || warn "AFL++ MCP submodule update after pin failed"
else
  warn "AFLPP_MCP_COMMIT not set — using HEAD of default branch."
  log "  resolved HEAD: $(git -C "$AFLPP_MCP_DIR" rev-parse HEAD)"
  log "  to pin, set AFLPP_MCP_COMMIT=$(git -C "$AFLPP_MCP_DIR" rev-parse HEAD) and rerun"
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
