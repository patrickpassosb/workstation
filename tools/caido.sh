#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

LAB_DIR="${SECURITY_LAB_DIR:-$HOME/hacking}"
mkdir -p "$LAB_DIR/proxy/caido"

if is_installed caido; then
  log "Caido is already installed: $(caido --version 2>/dev/null || command -v caido)"
else
  warn "Caido is not installed automatically. Install Caido from https://caido.io/download, then keep projects under $LAB_DIR/proxy/caido."
fi

warn "Caido MCP/Skills usually require app-side token/config steps; this script creates the workspace but does not register credentials."
