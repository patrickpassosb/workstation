#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

log "═══════════════════════════════════════════════════════"
log "  Installing all tools (prebuilt)"
log "═══════════════════════════════════════════════════════"

FAILED=()
INSTALLED=()
SKIPPED=()

run_tool() {
  local name="$1"
  local script="$SCRIPT_DIR/${name}.sh"
  log "── $name ────────────────────────────────────"
  if [[ ! -f "$script" ]]; then
    warn "Script not found: $script"
    SKIPPED+=("$name")
    return
  fi
  if bash "$script"; then
    INSTALLED+=("$name")
  else
    warn "Failed: $name"
    FAILED+=("$name")
  fi
}

# Inline pkg_install_if_missing for pure one-liner tools (no script).
# Replaces the dozen+ 9-line wrapper scripts that just sourced
# helpers.sh and called pkg_install_if_missing <name>.
run_pkg_tool() {
  local name="$1"
  log "── $name ────────────────────────────────────"
  if pkg_install_if_missing "$name"; then
    INSTALLED+=("$name")
  else
    warn "Failed: $name"
    FAILED+=("$name")
  fi
}

# Core system. These are pure pkg_install_if_missing one-liners that
# were previously one wrapper script per tool. They are data-driven
# here to eliminate the boilerplate.
log "── Core system ────────────────────────────────────────"
for name in zsh git tmux htop jq fzf ripgrep; do
  run_pkg_tool "$name"
done

# Knowledge base
for name in obsidian; do
  run_tool "$name"
done

# Developer utilities (bat and fd have distro-specific binary-name
# fallbacks, so they keep their own scripts; the rest are one-liners).
log "── Developer utilities ────────────────────────────────"
for name in bat fd; do
  run_tool "$name"
done
for name in eza delta zoxide flameshot uv bun starship gh docker lazygit lazydocker opencode tailscale easyeffects; do
  run_tool "$name"
done

# Node.js runtime (needed by some MCP/security tooling)
for name in nodejs; do
  run_tool "$name"
done

# Security lab (skippable via --skip-security-lab on setup.sh)
if [[ "${SKIP_SECURITY_LAB:-0}" == "1" ]]; then
  log "Skipping security lab (SKIP_SECURITY_LAB=1)"
else
  for name in security-lab semgrep codeql nuclei snyk-agent-scan caido burp ghidra aflpp oss-fuzz-gen; do
    run_tool "$name"
  done
fi

# Heavy apps via Flatpak. These were previously one wrapper script per
# app, each calling flatpak_install_if_missing <app_id>. Data-driven
# here for the same reason as the apt one-liners above.
log "── Flatpak apps ───────────────────────────────────────"
# Format: "log_label:flatpak_app_id"
FLATPAK_APPS=(
  "obs:com.obsproject.Studio"
  "telegram:org.telegram.desktop"
  "audacity:org.audacityteam.Audacity"
  "gimp:org.gimp.GIMP"
  "bitwarden:com.bitwarden.desktop"
)
for entry in "${FLATPAK_APPS[@]}"; do
  label="${entry%%:*}"
  app_id="${entry#*:}"
  log "── $label ────────────────────────────────────"
  if flatpak_install_if_missing "$app_id"; then
    INSTALLED+=("$label")
  else
    warn "Failed: $label"
    FAILED+=("$label")
  fi
done

# Node.js CLIs (need Node installed first).
# These were previously one wrapper script per CLI (codex.sh, kilo-cli.sh,
# vercel-cli.sh, context-hub.sh, claude-code.sh) — each 9 lines of the
# same ensure_node + log + bun_or_npm_install_global boilerplate. They
# are now data-driven here to eliminate the duplication. opencode is
# kept as its own script (tools/opencode.sh) because it has extra
# postinstall logic that the others don't.
log ""
log "═══════════════════════════════════════════════════════"
log "  Node.js/TS CLIs"
log "═══════════════════════════════════════════════════════"

# Format: "log_label:npm_package". Keep these at @latest by default;
# bump to a pinned version (pkg@x.y.z) intentionally when reviewing.
NODE_CLIS=(
  "codex:@openai/codex"
  "kilo-cli:kilocode"
  "vercel-cli:vercel"
  "context-hub:@aisuite/chub"
  "claude-code:@anthropic-ai/claude-code"
)
for entry in "${NODE_CLIS[@]}"; do
  label="${entry%%:*}"
  pkg="${entry#*:}"
  log "── $label ────────────────────────────────────"
  if install_node_cli "$label" "$pkg"; then
    INSTALLED+=("$label")
  else
    warn "Failed: $label"
    FAILED+=("$label")
  fi
done

log ""
log "═══════════════════════════════════════════════════════"
log "  Tools summary"
log "═══════════════════════════════════════════════════════"
log "Installed: ${INSTALLED[*]:-none}"
[[ ${#SKIPPED[@]} -gt 0 ]] && warn "Skipped: ${SKIPPED[*]}"
[[ ${#FAILED[@]} -gt 0 ]] && err "Failed: ${FAILED[*]}"

[[ ${#FAILED[@]} -eq 0 ]]
