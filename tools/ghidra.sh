#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

LAB_DIR="${SECURITY_LAB_DIR:-$HOME/hacking}"
TOOLS_DIR="${SECURITY_TOOLS_DIR:-$LAB_DIR/tools}"
GHIDRA_MCP_REPO="${GHIDRA_MCP_REPO:-https://github.com/bethington/ghidra-mcp.git}"
GHIDRA_MCP_DIR="${GHIDRA_MCP_DIR:-$TOOLS_DIR/ghidra-mcp}"
# Pin to a specific commit of the third-party ghidra-mcp repo for
# supply-chain safety. Set GHIDRA_MCP_COMMIT (e.g. to a known-good
# SHA from your last review) to enforce it; without it, the script
# logs the resolved HEAD so you can pin it later.
GHIDRA_MCP_COMMIT="${GHIDRA_MCP_COMMIT:-}"

ensure_local_bin_dir
mkdir -p "$TOOLS_DIR"

install_first_available_pkg java-21-openjdk openjdk-21-jdk || warn "Java 21 install skipped"
install_first_available_pkg maven || warn "Maven install skipped"
pkg_install_if_missing python3 python3-pip || true

ghidra_run=""
if [[ -n "${GHIDRA_HOME:-}" && -x "${GHIDRA_HOME}/ghidraRun" ]]; then
  ghidra_run="${GHIDRA_HOME}/ghidraRun"
elif is_installed ghidraRun; then
  ghidra_run="$(command -v ghidraRun)"
else
  if [[ -x "$HOME/.local/ghidraRun" ]]; then
    ghidra_run="$HOME/.local/ghidraRun"
  else
    ghidra_run="$(find "$HOME/.local" -maxdepth 3 -name ghidraRun -type f -print 2>/dev/null | head -n 1)"
  fi
  if [[ -n "$ghidra_run" ]]; then
    ln -sf "$ghidra_run" "$HOME/.local/bin/ghidraRun"
    log "Linked Ghidra launcher: $HOME/.local/bin/ghidraRun"
  fi
fi

if [[ -z "$ghidra_run" ]]; then
  warn "Ghidra itself is not installed automatically. Install Ghidra 12.1+ under ~/.local, then rerun this script."
else
  log "Ghidra launcher found: $ghidra_run"
fi

if [[ -d "$GHIDRA_MCP_DIR/.git" ]]; then
  log "Updating Ghidra MCP repo: $GHIDRA_MCP_DIR"
  git -C "$GHIDRA_MCP_DIR" fetch --prune origin
  if [[ -z "$(git -C "$GHIDRA_MCP_DIR" status --porcelain)" ]]; then
    git -C "$GHIDRA_MCP_DIR" pull --ff-only || warn "Ghidra MCP pull skipped"
  else
    warn "Ghidra MCP repo has local changes; fetched only"
  fi
else
  log "Cloning Ghidra MCP repo..."
  git clone "$GHIDRA_MCP_REPO" "$GHIDRA_MCP_DIR"
fi

if [[ -n "$GHIDRA_MCP_COMMIT" ]]; then
  log "Pinning Ghidra MCP to commit $GHIDRA_MCP_COMMIT"
  # Use reset --hard (not checkout) so a dirty or diverged tree from
  # a prior pull doesn't cause the pin to fail. The repo was either
  # just cloned (clean) or pulled --ff-only above (clean unless the
  # upstream force-pushed); reset --hard to the pinned commit is safe.
  git -C "$GHIDRA_MCP_DIR" fetch --prune origin
  if ! git -C "$GHIDRA_MCP_DIR" reset --hard "$GHIDRA_MCP_COMMIT"; then
    err "Ghidra MCP reset to $GHIDRA_MCP_COMMIT failed"
    exit 1
  fi
else
  warn "GHIDRA_MCP_COMMIT not set — using HEAD of default branch."
  log "  resolved HEAD: $(git -C "$GHIDRA_MCP_DIR" rev-parse HEAD)"
  log "  to pin, set GHIDRA_MCP_COMMIT=$(git -C "$GHIDRA_MCP_DIR" rev-parse HEAD) and rerun"
fi

warn "Ghidra MCP deploy is intentionally manual because it can modify Ghidra user config and launch Ghidra."
log "Deploy later with: cd '$GHIDRA_MCP_DIR' && python3 -m tools.setup deploy --ghidra-path '<path-to-ghidra>'"
