#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

ensure_node
log "Installing opencode..."
bun_or_npm_install_global opencode-ai  # bucket (a): postinstall downloads platform binary from opencode.ai release infra
# npm with --ignore-scripts (or bun installing to its own global prefix) leaves
# a 479-byte error shim at bin/opencode.exe. Run the postinstall explicitly so
# the real ELF binary is in place before this script returns.
if [ -f "$(npm root -g)/opencode-ai/postinstall.mjs" ]; then
  node "$(npm root -g)/opencode-ai/postinstall.mjs" \
    || warn "opencode-ai postinstall failed; the wrapper will exit with an error until it is re-run"
fi
