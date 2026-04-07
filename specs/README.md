# Workstation Setup Specifications Index

> This is the lookup table for the Ralph autonomous loop. Rich keywords improve search hits.

## How to Use
When implementing features, ALWAYS search this document first. Find relevant existing code before writing new code.

---

## Core Systems

### Setup Orchestrator
**Code:** `setup.sh`, `lib/helpers.sh`, `lib/registry.sh`
**Keywords:** bash script, Linux setup, automated workstation, phase levels, bootstrap, modular installers
**Status:** Existing

### Tool Installers
**Code:** `installers/`, `tools/`
**Keywords:** voquill, antigravity, rustup, nvm, nodejs, binary download, apt repository, global npm
**Status:** Existing

### Configuration & Skills
**Code:** `configs/`, `skills/`
**Keywords:** dotfiles, sync skills, agentic environment, centralized skills, context lookup
**Status:** Existing

### System-Level Focus Control
**Spec:** `specs/features/system-focus.md`
**Plan:** `specs/implementation-plans/system-focus-plan.md`
**Code:** `configs/focus-mode.sh`
**Keywords:** focus mode, block domains, etchosts, immutability, productivity, tiktok, netflix, adult sites, chattr, workstation setup, focus-protection, distraction-free, deep-work, core-config
**Status:** Planning

---

## Conventions
**Code Style:** Shell scripting with `set -euo pipefail`. Use `log`, `warn`, `err` from `lib/helpers.sh`.
**Testing:** Manual validation via script execution and output checks.
