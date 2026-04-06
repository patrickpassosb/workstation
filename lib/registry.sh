#!/usr/bin/env bash
# Tool → build-level registry for Phase 1 (CLI Tools & Small Apps).
# Level 0: everything prebuilt.  Level 10: everything compiled from source.
#
# Phase 2 tools (desktop apps) are set to level 99 so they're always
# pre-built during Phase 1. They'll get their own phase later.

declare -A TOOL_BUILD_LEVEL=(
  # Level 1 — Node.js CLIs (trivial npm builds)
  [codex]=1 [claude-code]=1 [gemini-cli]=1 [kilo-cli]=1 [vercel-cli]=1 [context-hub]=1
  [ctx7]=1 [chub]=1 [omx]=1 [omo]=1 [omc]=1
  # Level 2 — small Go CLIs (single go build, seconds)
  [fzf]=2 [lazygit]=2 [lazydocker]=2 [opencode]=2
  # Level 3 — small Rust CLIs (fast cargo build, ~1 min each)
  [ripgrep]=3 [fd]=3 [bat]=3 [eza]=3 [delta]=3 [zoxide]=3
  # Level 4 — heavier builds (5-10 min, more CPU; Rust/Zig)
  [starship]=4 [uv]=4 [bun]=4
  # Level 5 — Go projects with complex build systems (make, multiple binaries)
  [gh]=5 [tailscale]=5 [docker]=5
  # Level 6 — CMake/Meson with Qt/GTK dependencies
  [flameshot]=6 [easyeffects]=6
  # Level 7 — autotools intro (./autogen.sh && ./configure && make)
  [htop]=7 [jq]=7
  # Level 8 — autotools with more dependencies
  [tmux]=8 [zsh]=8
  # Level 9 — complex make system, many optional deps
  [git]=9
  # Level 10 — compile a language runtime from C++ (30+ min)
  [nodejs]=10
  # Phase 2 tools — always pre-built in Phase 1
  [obs]=99 [gimp]=99 [audacity]=99 [telegram]=99 [bitwarden]=99
)

LEVEL_NAMES=(
  [0]="Pre-built"
  [1]="First steps"
  [2]="Go basics"
  [3]="Rust basics"
  [4]="Rust medium"
  [5]="Official repos"
  [6]="CMake & Meson"
  [7]="Autotools intro"
  [8]="Core system"
  [9]="Core infrastructure"
  [10]="Full source"
)

LEVEL_DESCRIPTIONS=(
  [0]="install everything pre-built, no compilation"
  [1]="6 Node.js CLIs (npm build)"
  [2]="+ 4 Go CLIs (fzf, lazygit, lazydocker, opencode)"
  [3]="+ 6 Rust CLIs (ripgrep, fd, bat, eza, delta, zoxide)"
  [4]="+ 3 heavier builds (starship, uv, bun)"
  [5]="+ 3 Go projects (gh, tailscale, docker CLI)"
  [6]="+ 2 CMake/Meson apps (flameshot, easyeffects)"
  [7]="+ 2 autotools builds (htop, jq)"
  [8]="+ 2 system tools (tmux, zsh)"
  [9]="+ git from source"
  [10]="+ Node.js from source — compile everything"
)

# get_tool_mode <tool> <level>
# Returns "prebuilt" or "clone" based on whether the selected level is high
# enough to build this tool from source.
# "clone" means: clone the repo + print build instructions (you build manually).
# "prebuilt" means: install the pre-built binary automatically.
# "build" (automatic compilation) is only used via direct standalone invocation.
get_tool_mode() {
  local tool="$1" level="$2"
  local build_level="${TOOL_BUILD_LEVEL[$tool]:-99}"
  if (( level >= build_level )); then echo "clone"; else echo "prebuilt"; fi
}
