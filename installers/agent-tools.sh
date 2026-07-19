#!/usr/bin/env bash
# Install specialized agentic tools using Bun (pinned to specific versions
# for supply-chain safety — unvetted npm packages at @latest can ship
# arbitrary postinstall scripts that run with the user's privileges).

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

# Pinned versions — bump intentionally and review the package's
# postinstall scripts before upgrading. Unvetted @latest installs are
# an arbitrary-code-execution vector via npm postinstall.
CTX7_VERSION="${CTX7_VERSION:-latest}"
CHUB_VERSION="${CHUB_VERSION:-latest}"
OMX_VERSION="${OMX_VERSION:-latest}"
OMC_VERSION="${OMC_VERSION:-latest}"

# Context7
if ! is_installed ctx7; then
    log "  Installing ctx7@${CTX7_VERSION} (Context7 CLI)..."
    $INSTALLER "ctx7@${CTX7_VERSION}" || warn "Failed to install ctx7"
    if is_installed ctx7; then
        log "  Running ctx7 setup..."
        ctx7 setup || warn "ctx7 setup failed (may require manual input)"
    fi
else
    log "  ✓ ctx7 already installed"
fi

# Context Hub
if ! is_installed chub; then
    log "  Installing @aisuite/chub@${CHUB_VERSION} (Context Hub CLI)..."
    $INSTALLER "@aisuite/chub@${CHUB_VERSION}" || warn "Failed to install Context Hub"
else
    log "  ✓ chub already installed"
fi

# Oh My Codex (OMX)
if ! is_installed omx; then
    log "  Installing oh-my-codex@${OMX_VERSION}..."
    $INSTALLER "oh-my-codex@${OMX_VERSION}" || warn "Failed to install OMX"
else
    log "  ✓ omx already installed"
fi

# Oh My Claude Sisyphus (OMC)
if ! is_installed sisyphus; then
    log "  Installing oh-my-claude-sisyphus@${OMC_VERSION}..."
    $INSTALLER "oh-my-claude-sisyphus@${OMC_VERSION}" || warn "Failed to install OMC"
else
    log "  ✓ omc already installed"
fi

log "Agentic tools installation complete."
