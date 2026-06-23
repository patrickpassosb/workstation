#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

VAULT_REPO="${OBSIDIAN_VAULT_REPO:-https://github.com/patrickpassosb/obsidian-vault.git}"
VAULT_DIR="${OBSIDIAN_VAULT_DIR:-$HOME/Documents/Obsidian Vault}"
VAULT_ID="${OBSIDIAN_VAULT_ID:-f44ad3882fd559bb}"
CONFIG_FILE="$HOME/.config/obsidian/obsidian.json"

mkdir -p "$(dirname "$VAULT_DIR")" "$(dirname "$CONFIG_FILE")"

if [[ -d "$VAULT_DIR/.git" ]]; then
  current_remote="$(git -C "$VAULT_DIR" remote get-url origin 2>/dev/null || true)"
  if [[ -n "$current_remote" && "$current_remote" != "$VAULT_REPO" ]]; then
    warn "Existing Obsidian vault remote differs: $current_remote"
  fi
  log "Updating Obsidian vault repo: $VAULT_DIR"
  git -C "$VAULT_DIR" fetch --prune origin || warn "Vault fetch failed"
  if [[ -z "$(git -C "$VAULT_DIR" status --porcelain)" ]]; then
    git -C "$VAULT_DIR" pull --ff-only || warn "Vault pull skipped"
  else
    warn "Vault has local changes; fetched only and skipped pull"
  fi
elif [[ -d "$VAULT_DIR" && -n "$(find "$VAULT_DIR" -mindepth 1 -maxdepth 1 -print -quit)" ]]; then
  warn "Obsidian vault directory exists and is not a git repo: $VAULT_DIR"
else
  log "Cloning Obsidian vault..."
  git clone "$VAULT_REPO" "$VAULT_DIR"
fi

if ! is_installed python3; then
  warn "python3 is required to update Obsidian config; skipping obsidian.json update"
  exit 0
fi

python3 - "$CONFIG_FILE" "$VAULT_ID" "$VAULT_DIR" <<'PY'
import json
import pathlib
import sys
import time

config_path = pathlib.Path(sys.argv[1])
vault_id = sys.argv[2]
vault_dir = str(pathlib.Path(sys.argv[3]).expanduser())

if config_path.exists():
    try:
        data = json.loads(config_path.read_text())
    except json.JSONDecodeError:
        data = {}
else:
    data = {}

vaults = data.setdefault("vaults", {})
vault = vaults.setdefault(vault_id, {})
vault["path"] = vault_dir
vault["ts"] = int(time.time() * 1000)
vault["open"] = True
data["cli"] = True

config_path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")
PY

if is_installed obsidian; then
  log "Obsidian CLI detected: $(command -v obsidian)"
else
  warn "Obsidian CLI is enabled in config, but the CLI binary is installed from inside Obsidian after first launch."
fi

log "Obsidian vault configured: $VAULT_DIR"
