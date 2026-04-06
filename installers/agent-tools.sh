#!/usr/bin/env bash
# Install specialized agentic tools using Bun

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

log "═══════════════════════════════════════════════════════"
log "  Agentic Tools Installation"
log "═══════════════════════════════════════════════════════"

# 1. Ensure Bun is available
if ! is_installed bun; then
    warn "Bun is not installed. Attempting to install tools with npm fallback..."
    INSTALLER="npm install -g"
    RUNNER="npx"
else
    log "Using Bun for tool installation"
    INSTALLER="bun install -g"
    RUNNER="bunx"
fi

# 2. Global Node tools
log "Installing global agentic tools..."

# Context7
if ! is_installed ctx7; then
    log "  Installing ctx7 (Context7 CLI)..."
    $INSTALLER ctx7 || warn "Failed to install ctx7"
    if is_installed ctx7; then
        log "  Running ctx7 setup..."
        ctx7 setup || warn "ctx7 setup failed (may require manual input)"
    fi
else
    log "  ✓ ctx7 already installed"
fi

# Context Hub
if ! is_installed chub; then
    log "  Installing @aisuite/chub (Context Hub CLI)..."
    $INSTALLER @aisuite/chub || warn "Failed to install Context Hub"
else
    log "  ✓ chub already installed"
fi

# Oh My Codex (OMX)
if ! is_installed omx; then
    log "  Installing oh-my-codex..."
    $INSTALLER oh-my-codex@latest || warn "Failed to install OMX"
else
    log "  ✓ omx already installed"
fi

# Oh My Claude Sisyphus (OMC)
if ! is_installed sisyphus; then
    log "  Installing oh-my-claude-sisyphus..."
    $INSTALLER oh-my-claude-sisyphus@latest || warn "Failed to install OMC"
else
    log "  ✓ omc already installed"
fi

# 3. Oh My OpenAgent (OMO)
log "Installing oh-my-openagent..."
if ! is_installed omo; then
    $RUNNER oh-my-openagent install || warn "Failed to install OMO"
else
    log "  ✓ omo already installed"
fi

log "Agentic tools installation complete."
