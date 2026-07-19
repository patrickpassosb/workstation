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

# 2. Sync ALL local skills from this repository (full-dir copy, like
# sync-skills.sh, so sibling files like references/, assets/, prompt
# templates, TypeScript helpers are preserved). Previously this was a
# hardcoded 5-name list (get-api-docs + ralph-*); new skills had to be
# added to the list manually. Iterating skills/*/ makes every skill in
# the repo available to Trae automatically.
SKILLS_SRC="$SCRIPT_DIR/../skills"
synced=0
skipped=0
if [[ -d "$SKILLS_SRC" ]]; then
  log "Syncing local skills from $SKILLS_SRC..."
  for skill_dir in "$SKILLS_SRC"/*/; do
    [[ -d "$skill_dir" ]] || continue
    skill_name="$(basename "$skill_dir")"
    if [[ ! -f "$skill_dir/SKILL.md" ]]; then
      warn "  ✗ $skill_name: no SKILL.md — skipping"
      skipped=$((skipped + 1))
      continue
    fi
    rm -rf "$CENTRAL_DIR/$skill_name"
    cp -r "$skill_dir" "$CENTRAL_DIR/$skill_name"
    log "  ✓ $skill_name"
    synced=$((synced + 1))
  done
else
  warn "Skills source directory not found: $SKILLS_SRC"
fi
log "Local skills: $synced synced, $skipped skipped"

# 3. Sync external Context7 documentation-lookup skill (third-party,
# from the Gemini extension install path). Override with
# CONTEXT7_SKILL=/path/to/skill when this directory does not exist.
CONTEXT7_SKILL="${CONTEXT7_SKILL:-$HOME/.gemini/extensions/context7/plugins/claude/context7/skills/documentation-lookup}"

log "Syncing Context7 external skills..."
if [[ -d "$CONTEXT7_SKILL" ]]; then
    # Copy the folder to the central dir
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
