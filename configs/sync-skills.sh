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

  # Sync to each CLI's skills directory
  for target in "${SKILL_TARGETS[@]}"; do
    mkdir -p "$target/$skill_name"
    cp "$skill_file" "$target/$skill_name/SKILL.md"
  done

  # Also install as a Claude Code legacy command (enables /skill-name slash command)
  mkdir -p "$CLAUDE_COMMANDS"
  cp "$skill_file" "$CLAUDE_COMMANDS/${skill_name}.md"

  log "Synced skill: $skill_name"
  synced=$((synced + 1))
done

log "Synced $synced skill(s) to ${#SKILL_TARGETS[@]} CLIs"
