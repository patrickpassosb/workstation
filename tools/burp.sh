#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

LAB_DIR="${SECURITY_LAB_DIR:-$HOME/hacking}"
mkdir -p "$LAB_DIR/proxy/burp"

if is_installed burpsuite; then
  log "Burp Suite is already installed: $(command -v burpsuite)"
elif [[ -x /opt/BurpSuiteCommunity/BurpSuiteCommunity ]]; then
  log "Burp Suite Community is already installed: /opt/BurpSuiteCommunity/BurpSuiteCommunity"
else
  warn "Burp Suite is not installed automatically. Install Community/Professional from PortSwigger, then use $LAB_DIR/proxy/burp for projects."
fi

warn "The Burp MCP extension is installed inside Burp from the BApp Store; this script does not alter Burp extensions or licenses."
