#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

SKILLS_SRC="$SCRIPT_DIR/../skills"

log "==============================================="
log "  Syncing Agent Skills to all CLIs"
log "==============================================="

# All CLIs that support the Agent Skills standard (SKILL.md)
SKILL_TARGETS=(
  "$HOME/.claude/skills"
  "$HOME/.config/opencode/skills"
  "$HOME/.gemini/skills"
  "$HOME/.kilocode/skills"
)

# Also sync as legacy Claude Code commands for /slash-command support
CLAUDE_COMMANDS="$HOME/.claude/commands"

if [[ ! -d "$SKILLS_SRC" ]]; then
  warn "No skills directory found at $SKILLS_SRC"
  exit 0
fi

synced=0
for skill_dir in "$SKILLS_SRC"/*/; do
  [[ -d "$skill_dir" ]] || continue
  skill_name="$(basename "$skill_dir")"
  skill_file="$skill_dir/SKILL.md"

  if [[ ! -f "$skill_file" ]]; then
    warn "No SKILL.md in $skill_dir — skipping"
    continue
  fi

  # Sync the WHOLE skill dir (not just SKILL.md) so that skills which
  # reference sibling files (references/, assets/, prompt templates,
  # TypeScript helpers, etc.) remain functional at the install path.
  # Use `cp -r` with a trailing slash on the source so the *contents*
  # of the source dir land inside the target dir.
  for target in "${SKILL_TARGETS[@]}"; do
    mkdir -p "$target/$skill_name"
    rm -rf "$target/$skill_name"
    cp -r "$skill_dir" "$target/$skill_name"
  done

  # Also install SKILL.md as a Claude Code legacy command (enables
  # /skill-name slash command). Only the SKILL.md is used for the
  # slash-command surface — sibling files aren't needed there.
  mkdir -p "$CLAUDE_COMMANDS"
  cp "$skill_file" "$CLAUDE_COMMANDS/${skill_name}.md"

  log "Synced skill: $skill_name"
  synced=$((synced + 1))
done

log "Synced $synced skill(s) to ${#SKILL_TARGETS[@]} CLIs"
