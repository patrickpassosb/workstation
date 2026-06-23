#!/usr/bin/env bash
# Centralize agent skills into ~/.agents/skills

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

CENTRAL_DIR="$HOME/.agents/skills"

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
# Override with CONTEXT7_SKILL=/path/to/skill when this directory does not exist.
CONTEXT7_SKILL="${CONTEXT7_SKILL:-$HOME/.gemini/extensions/context7/plugins/claude/context7/skills/documentation-lookup}"

log "Syncing Context7 external skills..."
if [[ -d "$CONTEXT7_SKILL" ]]; then
    # We copy the folder to the central dir
    cp -r "$CONTEXT7_SKILL" "$CENTRAL_DIR/"
    log "  ✓ documentation-lookup (Context7)"
else
    warn "  ✗ Context7 skill not found at: $CONTEXT7_SKILL"
fi

# 4. Register each central skill as a symlink inside Trae IDE's skills dir.
# Trae scans ~/.trae/skills/ for skill subdirs; symlinking each central skill
# makes the whole central pool visible to Trae without copying.
TRAE_SKILLS_DIR="$HOME/.trae/skills"
log "Registering central skills with Trae IDE ($TRAE_SKILLS_DIR)..."
mkdir -p "$TRAE_SKILLS_DIR"

added=0
already=0
conflict=0
for skill_dir in "$CENTRAL_DIR"/*/; do
    [[ -d "$skill_dir" ]] || continue
    skill_name="$(basename "$skill_dir")"
    target="$TRAE_SKILLS_DIR/$skill_name"
    if [[ -L "$target" ]]; then
        log "  ✓ $skill_name (already symlinked)"
        already=$((already + 1))
    elif [[ -e "$target" ]]; then
        warn "  ⚠ $skill_name already exists as a real file/dir — not overwriting"
        conflict=$((conflict + 1))
    else
        ln -s "$skill_dir" "$target"
        log "  ✓ $skill_name (symlinked)"
        added=$((added + 1))
    fi
done
log "Trae: $added added, $already already linked, $conflict conflicts left for manual review"

log "Skills centralization complete."
