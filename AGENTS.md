# AGENTS.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

## This repo (project-specific)

`workstation` is a bash-only Linux bootstrap script (Ubuntu-like +
Fedora KDE). Key context agents must know:

- **Branch:** `prebuilt-only` is the active branch. It installs every
  tool as a prebuilt binary (apt/dnf, Flatpak, GitHub releases,
  `curl | sh`, `bun`/`npm`). The `master` branch is a separate
  compile-from-source variant with phases/levels — don't mix the two.
- **No secrets.** Config files ship with placeholders (e.g.
  `# export GITHUB_MCP_PAT=<YOUR_TOKEN_HERE>`). Never commit real
  tokens. `.gitignore` blocks `*.env`, `*.key`, `id_rsa`, `*.kdbx`,
  `.aws/`, etc.
- **`skills/` is the source of truth** for the user's personal agent
  skills. `configs/centralize-skills.sh` syncs to `~/.agents/skills/`
  (for Trae); `configs/sync-skills.sh` syncs to
  `~/.{claude,config/opencode,gemini,kilocode}/skills/`. Don't
  recommend removing `skills/` from the repo — it's how a fresh
  machine gets all the user's skills installed.
- **Sudo + system files.** `setup.sh` runs with sudo and modifies
  `/etc/hosts`, `/etc/resolv.conf`, `/etc/apt`, `/etc/yum.repos.d`,
  systemd timers, cron, firewall rules, browser extension policies.
  Two scripts (`focus-mode.sh`, `dns-nextdns.sh`) set the immutable
  bit via `chattr +i` — the undo command (`sudo chattr -i <file>`) is
  printed at the end of each.
- **Hardening scripts abort, not warn.** Firewall, ClamAV,
  unattended-upgrades, NextDNS, focus-mode, npm-security failures
  abort `setup.sh` (via `run_hardening` in setup.sh). Don't change
  these to `|| warn` — a silent hardening failure is a security
  posture regression.
- **MCP consent gate.** `configs/lab-mcp-consent.sh` is interactive
  (TTY-only). It never auto-registers MCPs. Don't bypass it.
- **Idempotency expected.** Re-running `./setup.sh` should be safe.
  `pkg_is_installed` requires `install ok installed` (not
  deinstalled-but-config-remaining). `flatpak_install_if_missing`
  checks `flatpak info` first. `is_installed` uses `command -v`, not
  `which`.
- **Bash style:** `#!/usr/bin/env bash`, `set -euo pipefail`,
  snake_case, 2-space indent, `name() {` (no `function` keyword),
  `command -v` (not `which`), `safe_curl` (not bare `curl`).

## General LLM coding guidelines

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.
