#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

REGISTRY="$SCRIPT_DIR/lab-mcps.json"

if [[ ! -f "$REGISTRY" ]]; then
  warn "MCP registry not found: $REGISTRY"
  exit 0
fi

if ! is_installed python3; then
  warn "python3 is required to read $REGISTRY; skipping MCP consent"
  exit 0
fi

if [[ ! -t 0 ]]; then
  log "MCP consent: stdin is not a TTY; skipping prompts (run setup.sh interactively to review)"
  exit 0
fi

log "═══════════════════════════════════════════════════════"
log "  Security Lab — MCP consent"
log "═══════════════════════════════════════════════════════"
log "Each MCP below can execute commands in this lab. Registration is"
log "intentionally manual: this prompt only prints commands; you run them."
log ""

python3 - "$REGISTRY" <<'PY' || true
import json, os, sys
data = json.load(open(sys.argv[1]))
for mcp in data.get("mcps", []):
    print(f"--- {mcp['id']} ({mcp['name']}) ---")
    print(f"Purpose: {mcp['purpose']}")
    print(f"Repo:    {mcp['repo']}")
    print("Permissions:")
    for p in mcp.get("permissions", []):
        print(f"  - {p}")
    print(f"Register: {mcp['register_command']}")
    print()
PY

APPROVED=()
while IFS= read -r line; do
  id="$(printf '%s' "$line" | awk '{print $1}')"
  choice="$(printf '%s' "$line" | awk '{print $2}')"
  if [[ "$choice" =~ ^[Yy]$ ]]; then
    APPROVED+=("$id")
  fi
done < <(
  python3 - "$REGISTRY" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
for mcp in data.get("mcps", []):
    try:
        ans = input(f"Register {mcp['id']}? [y/N] ")
    except EOFError:
        sys.exit(0)
    print(f"{mcp['id']} {ans}")
PY
)

if [[ ${#APPROVED[@]} -eq 0 ]]; then
  log "No MCPs approved; nothing to do."
  exit 0
fi

log ""
log "Approved MCPs. Run these commands yourself (the agent CLI is not in this script's PATH):"
log ""
python3 - "$REGISTRY" "${APPROVED[@]}" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
approved = set(sys.argv[2:])
for mcp in data.get("mcps", []):
    if mcp["id"] in approved:
        print(f"  {mcp['register_command']}")
PY
log ""
log "After registering, restart your coding agent (codex/claude-code) so the new MCPs are picked up."
