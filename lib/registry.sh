#!/usr/bin/env bash
# Tool → build-level registry.
# Level 0: everything prebuilt.  Level 3: everything compiled from source.

declare -A TOOL_BUILD_LEVEL=(
  # Level 1 — small Rust/Go CLIs
  [ripgrep]=1 [fd]=1 [fzf]=1 [lazygit]=1 [lazydocker]=1 [opencode]=1
  # Level 2 — core system tools + developer utilities
  [zsh]=2 [git]=2 [tmux]=2 [htop]=2 [jq]=2 [flameshot]=2
  [starship]=2 [uv]=2 [gh]=2 [tailscale]=2 [docker]=2 [easyeffects]=2
  # Level 3 — heavy apps + Node.js CLIs
  [obs]=3 [gimp]=3 [audacity]=3 [telegram]=3 [bitwarden]=3 [nodejs]=3
  [codex]=3 [gemini-cli]=3 [kilo-cli]=3 [vercel-cli]=3 [context-hub]=3 [claude-code]=3
)

# get_tool_mode <tool> <level>
# Returns "prebuilt" or "build" based on whether the selected level is high
# enough to compile this tool from source.
get_tool_mode() {
  local tool="$1" level="$2"
  local build_level="${TOOL_BUILD_LEVEL[$tool]:-99}"
  if (( level >= build_level )); then echo "build"; else echo "prebuilt"; fi
}
