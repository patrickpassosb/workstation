#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if ! is_installed uvx && ! is_installed uv; then
  warn "uv/uvx is required for Snyk Agent Scan. Run tools/uv.sh first."
  exit 1
fi

install_uvx_wrapper snyk-agent-scan-safe snyk-agent-scan \
  "Snyk Agent Scan can execute configured MCP/tool commands. Use only with trusted configs."

log "Set SNYK_TOKEN before use: export SNYK_TOKEN=..."
log "Or run: snyk-agent-scan-safe auth"
log "Run: snyk-agent-scan-safe --help"
