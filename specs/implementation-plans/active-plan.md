# Implementation Plan: Agentic Environment Setup

## Goal
Implement the centralized agent skills and install specialized agentic tools as part of the workstation setup scripts.

## Tasks
- [ ] **Phase 1: Skills Centralization**
    - [ ] Create `configs/centralize-skills.sh` script.
    - [ ] Implement skill directory creation (`~/.agents/skills`).
    - [ ] Implement skill copying (6 local + 1 external).
    - [ ] Implement `~/.gemini/antigravity/skills.txt` update.
    - [ ] Integrate into `setup.sh` (Phase 1, Configs & Auth section).

- [ ] **Phase 2: Tools Installation**
    - [ ] Create `installers/agent-tools.sh` script.
    - [ ] Implement `bun install -g` for `ctx7`, `@aisuite/chub`, `oh-my-codex`, and `oh-my-claude-sisyphus`.
    - [ ] Implement `ctx7 setup`.
    - [ ] Implement `bunx oh-my-openagent install`.
    - [ ] Integrate into `setup.sh` (Phase 1, Installers section).

- [ ] **Phase 3: Voquill Modernization**
    - [ ] Modify `installers/voquill.sh` to use the `curl -fsSL https://voquill.github.io/apt/install.sh | bash` method.

- [ ] **Phase 4: Registry Update**
    - [ ] Add `ctx7`, `chub`, `omx`, `omo`, and `omc` to the `TOOL_BUILD_LEVEL` registry in `lib/registry.sh` (Level 1).

- [ ] **Phase 5: Verification**
    - [ ] Add post-install validation checks to `setup.sh`.
    - [ ] Run `./setup.sh --level 1 --skip-tools --skip-configs` (or equivalent) to verify bash changes.
