# Implementation Plan: Agentic Environment Setup

## Goal
Implement the centralized agent skills and install specialized agentic tools as part of the workstation setup scripts.

## Tasks
- [x] **Phase 1: Skills Centralization**
    - [x] Create `configs/centralize-skills.sh` script.
    - [x] Implement skill directory creation (`~/.agents/skills`).
    - [x] Implement skill copying (6 local + 1 external).
    - [x] Implement `~/.gemini/antigravity/skills.txt` update.
    - [x] Integrate into `setup.sh` (Phase 1, Configs & Auth section).

- [x] **Phase 2: Tools Installation**
    - [x] Create `installers/agent-tools.sh` script.
    - [x] Implement `bun install -g` for `ctx7`, `@aisuite/chub`, `oh-my-codex`, and `oh-my-claude-sisyphus`.
    - [x] Implement `ctx7 setup`.
    - [x] Implement `bunx oh-my-openagent install`.
    - [x] Integrate into `setup.sh` (Phase 1, Installers section).

- [x] **Phase 3: Voquill Modernization**
    - [x] Modify `installers/voquill.sh` to use the `curl -fsSL https://voquill.github.io/apt/install.sh | bash` method.

- [x] **Phase 4: Registry Update**
    - [x] Add `ctx7`, `chub`, `omx`, `omo`, and `omc` to the `TOOL_BUILD_LEVEL` registry in `lib/registry.sh` (Level 1).

- [x] **Phase 5: Verification**
    - [x] Add post-install validation checks to `setup.sh`.
    - [x] Run `./setup.sh --level 1 --skip-tools --skip-configs` (or equivalent) to verify bash changes.
