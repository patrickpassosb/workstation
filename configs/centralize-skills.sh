#!/usr/bin/env bash
# Centralize agent skills into ~/.agents/skills

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

CENTRAL_DIR="$HOME/.agents/skills"
ANTIGRAVITY_CONFIG="$HOME/.gemini/antigravity/skills.txt"

log "═══════════════════════════════════════════════════════"
log "  Agent Skills Centralization"
log "═══════════════════════════════════════════════════════"

# 1. Create central directory
mkdir -p "$CENTRAL_DIR"
log "Ensured central skill directory: $CENTRAL_DIR"

# 2. Sync local skills from this repository
LOCAL_SKILLS=(
    "get-api-docs"
    "ralph-implement"
    "ralph-init"
    "ralph-interview"
    "ralph-loop"
)

log "Syncing local skills..."
for skill in "${LOCAL_SKILLS[@]}"; do
    SRC="$SCRIPT_DIR/../skills/$skill"
    if [[ -d "$SRC" ]]; then
        cp -r "$SRC" "$CENTRAL_DIR/"
        log "  ✓ $skill"
    else
        warn "  ✗ Skill not found in repo: $skill"
    fi
done

# 3. Sync external Context7 documentation-lookup skill
# Path provided in implementation plan
CONTEXT7_SKILL="/home/patrick/.gemini/extensions/context7/plugins/claude/context7/skills/documentation-lookup"

log "Syncing Context7 external skills..."
if [[ -d "$CONTEXT7_SKILL" ]]; then
    # We copy the folder to the central dir
    cp -r "$CONTEXT7_SKILL" "$CENTRAL_DIR/"
    log "  ✓ documentation-lookup (Context7)"
else
    warn "  ✗ Context7 skill not found at: $CONTEXT7_SKILL"
fi

# 4. Register path in Antigravity configuration
log "Updating Antigravity skills registration..."
mkdir -p "$(dirname "$ANTIGRAVITY_CONFIG")"
touch "$ANTIGRAVITY_CONFIG"

if ! grep -qF "$CENTRAL_DIR" "$ANTIGRAVITY_CONFIG"; then
    echo "$CENTRAL_DIR" >> "$ANTIGRAVITY_CONFIG"
    log "  ✓ Added $CENTRAL_DIR to $ANTIGRAVITY_CONFIG"
else
    log "  ✓ $CENTRAL_DIR already registered"
fi

log "Skills centralization complete."
