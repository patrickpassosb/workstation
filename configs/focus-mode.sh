#!/usr/bin/env bash
set -euo pipefail

# Focus Mode — Deep Block (Porn + Betting), curated + full list.
# This is the ONE-WAY, STICKY version: after setup, /etc/hosts is made
# immutable so the blocks cannot be easily bypassed or accidentally removed.
# Deliberately no "off" toggle — the point of focus mode is friction.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

HOSTS_FILE="/etc/hosts"
MARK_START="# >>> workstation-focus (DO NOT EDIT) >>>"
MARK_END="# <<< workstation-focus <<<"
LIST_FILE="$SCRIPT_DIR/blocklists/porn-betting.txt"
CORE_FILE="$SCRIPT_DIR/blocklists/porn-betting-core.txt"

log "═══════════════════════════════════════════════════════"
log "  Focus Mode — Deep Block (Porn + Betting)"
log "═══════════════════════════════════════════════════════"

# ── Unlock if already immutable (only during setup, to update) ──────
unlock() {
  if lsattr "$HOSTS_FILE" 2>/dev/null | grep -q "^....i"; then
    log "Unlocking $HOSTS_FILE for updates..."
    sudo chattr -i "$HOSTS_FILE"
  fi
}
lock() {
  log "Locking $HOSTS_FILE (immutable)..."
  sudo chattr +i "$HOSTS_FILE" || warn "Failed to lock $HOSTS_FILE"
}

unlock

# Back up original hosts once
if [[ ! -f "${HOSTS_FILE}.orig" ]]; then
  sudo cp "$HOSTS_FILE" "${HOSTS_FILE}.orig"
  log "Backed up original hosts to ${HOSTS_FILE}.orig"
fi

# Strip any prior focus block (idempotent re-run), keep original content
if grep -qF "$MARK_START" "$HOSTS_FILE"; then
  sudo sed -i "/${MARK_START}/,/${MARK_END}/d" "$HOSTS_FILE"
  log "Removed previous focus block"
fi

# ── Append the full block ────────────────────────────────────────────
{
  echo ""
  echo "$MARK_START"
  # Curated core first (top visited sites), then the full list.
  if [[ -f "$CORE_FILE" ]]; then
    while IFS= read -r d; do
      [[ -z "$d" || "$d" == \#* ]] && continue
      echo "127.0.0.1 $d"
    done < "$CORE_FILE"
  fi
  if [[ -f "$LIST_FILE" ]]; then
    while IFS= read -r d; do
      [[ -z "$d" || "$d" == \#* ]] && continue
      echo "127.0.0.1 $d"
    done < "$LIST_FILE"
  fi
  echo "$MARK_END"
} | sudo tee -a "$HOSTS_FILE" > /dev/null

CORE_COUNT=$(grep -cvE '^\s*(#|$)' "$CORE_FILE" 2>/dev/null || echo 0)
FULL_COUNT=$(grep -cvE '^\s*(#|$)' "$LIST_FILE" 2>/dev/null || echo 0)
log "Focus block applied: $CORE_COUNT curated + $FULL_COUNT full-list domains."

lock
log "Focus Mode complete. /etc/hosts is now immutable."
