# Feature: Agentic Environment Setup

## Problem
Currently, the workstation setup does not have a centralized skill directory for AI agents, nor does it install the latest specialized agentic tools (`ctx7`, `chub`, `omx`, etc.) optimized for the "Agentic Coding" workflow.

## Proposed Solution
Extend the existing `setup.sh` orchestrator with a dedicated "Agentic Environment" phase.

## Requirements
1. **Centralize Agent Skills**:
    - Directory: `~/.agents/skills`
    - Source Skills: `skills/get-api-docs`, `skills/ralph-implement`, `skills/ralph-init`, `skills/ralph-interview`, `skills/ralph-loop`.
    - Context Skill: `/home/patrick/.gemini/extensions/context7/plugins/claude/context7/skills/documentation-lookup/`
    - Integration: Add path to `~/.gemini/antigravity/skills.txt`.

2. **Install Agent Tools (using Bun)**:
    - Global Tools: `ctx7`, `@aisuite/chub`, `oh-my-codex`, `oh-my-claude-sisyphus`.
    - Special Installs: `bunx oh-my-openagent install`.
    - Setup Tasks: `ctx7 setup`.

3. **Modernize Voquill Installer**:
    - Update `installers/voquill.sh` to use the official `curl -fsSL https://voquill.github.io/apt/install.sh | bash` method.

4. **Integration**:
    - Register tools in `lib/registry.sh` (Level 1).
    - Call scripts from `setup.sh`.

## Success Criteria
- [ ] `~/.agents/skills` contains local and context skills.
- [ ] `ctx7`, `chub`, `omx`, `omc` are installed and available in the shell.
- [ ] `voquill` install command is the `curl` version.
- [ ] `setup.sh` runs these without errors.
