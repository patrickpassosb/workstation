#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

# StayFree is a browser extension for screen-time tracking.
# There is no standalone desktop app to install via a package manager.

warn "StayFree is a browser extension. Install from your browser's extension store."
warn "  Chrome: https://chrome.google.com/webstore/detail/stayfree"
warn "  Firefox: https://addons.mozilla.org/en-US/firefox/addon/stayfree/"

log "No automated installation needed for StayFree."
