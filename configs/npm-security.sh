#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

log "═══════════════════════════════════════════════════════"
log "  Package Manager Security (npm)"
log "═══════════════════════════════════════════════════════"

if is_installed npm; then
  # Check current status
  current=$(npm config get ignore-scripts 2>/dev/null || echo "false")
  
  if [[ "$current" == "true" ]]; then
    log "npm ignore-scripts is already enabled"
  else
    log "Setting npm ignore-scripts=true globally"
    # Set it deeply just in case
    npm config set ignore-scripts true -g
    # Also set it for the user
    npm config set ignore-scripts true
    log "npm will no longer auto-execute hidden scripts during install."
    log "If a package fails to compile Native C++ binding (like sqlite3 or esbuild),"
    log "you can manually allow it via: npm rebuild <package-name>"
  fi
else
  warn "npm not installed yet — skipping npm security hardening."
fi
