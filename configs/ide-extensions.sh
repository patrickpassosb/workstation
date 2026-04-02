#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

log "═══════════════════════════════════════════════════════"
log "  IDE Extensions (Cursor + Antigravity)"
log "═══════════════════════════════════════════════════════"

# ── Shared extensions (installed in both IDEs) ───────────────────────
SHARED_EXTENSIONS=(
  "github.vscode-github-actions"
  "mechatroner.rainbow-csv"
  "ms-azuretools.vscode-containers"
  "ms-azuretools.vscode-docker"
  "ms-python.debugpy"
  "ms-python.python"
  "ms-python.vscode-python-envs"
  "ms-vscode.makefile-tools"
  "nomicfoundation.hardhat-solidity"
  "pkief.material-icon-theme"
  "adpyke.codesnap"
  "meta.pyrefly"
  "qwtel.sqlite-viewer"
  "tomoki1207.pdf"
  "zhuangtongfa.material-theme"
)

# ── Cursor-only extensions ───────────────────────────────────────────
CURSOR_ONLY=()

# ── Antigravity-only extensions ──────────────────────────────────────
ANTIGRAVITY_ONLY=()

# ── Installer ────────────────────────────────────────────────────────
install_extensions() {
  local ide_cmd="$1"
  local ide_name="$2"
  shift 2
  local -a extensions=("$@")
  local failed=()

  for ext in "${extensions[@]}"; do
    if "$ide_cmd" --install-extension "$ext" >/dev/null 2>&1; then
      log "  ✓ $ext"
    else
      warn "  ✗ $ext"
      failed+=("$ext")
    fi
  done

  if [[ ${#failed[@]} -gt 0 ]]; then
    warn "$ide_name: ${#failed[@]} extension(s) failed: ${failed[*]}"
  fi
}

# IDE extensions need to install as the regular user, not root
if [[ "$(id -u)" -eq 0 ]]; then
  warn "IDE extensions should be installed as your regular user, not root."
  warn "Run after setup:  bash $SCRIPT_DIR/ide-extensions.sh"
  exit 0
fi

# ── Cursor ───────────────────────────────────────────────────────────
if is_installed cursor; then
  log ""
  log "── Cursor ────────────────────────────────────────────"
  CURSOR_ALL=("${SHARED_EXTENSIONS[@]}" "${CURSOR_ONLY[@]}")
  install_extensions cursor "Cursor" "${CURSOR_ALL[@]}"
  log "Cursor: ${#CURSOR_ALL[@]} extensions"
else
  warn "Cursor not installed — skipping"
fi

# ── Antigravity ──────────────────────────────────────────────────────
if is_installed antigravity; then
  log ""
  log "── Antigravity ───────────────────────────────────────"
  ANTIGRAVITY_ALL=("${SHARED_EXTENSIONS[@]}" "${ANTIGRAVITY_ONLY[@]}")
  install_extensions antigravity "Antigravity" "${ANTIGRAVITY_ALL[@]}"
  log "Antigravity: ${#ANTIGRAVITY_ALL[@]} extensions"
else
  warn "Antigravity not installed — skipping"
fi
