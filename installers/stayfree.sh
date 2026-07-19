#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

# StayFree is a browser extension for screen-time tracking.
# There is no standalone desktop app to install via a package manager.
# The Chrome Web Store URL below is the direct extension page; Firefox
# is the same extension on AMO.

log "StayFree is a browser extension — no desktop install needed."
log "  Chrome:  https://chrome.google.com/webstore/detail/stayfree/mkjknkfhfhkapgibfmmajbdbmimgphhb"
log "  Firefox: https://addons.mozilla.org/en-US/firefox/addon/stayfree/"
log "If you use managed browser extension policies (configs/browser-extensions.sh),"
log "add the Chrome extension ID 'mkjknkfhfhkapgibfmmajbdbmimgphhb' there."
