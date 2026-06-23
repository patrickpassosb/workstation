#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

LAB_DIR="${SECURITY_LAB_DIR:-$HOME/hacking}"
TOOLS_DIR="${SECURITY_TOOLS_DIR:-$LAB_DIR/tools}"
OSS_FUZZ_GEN_REPO="${OSS_FUZZ_GEN_REPO:-https://github.com/google/oss-fuzz-gen.git}"
OSS_FUZZ_GEN_DIR="${OSS_FUZZ_GEN_DIR:-$TOOLS_DIR/oss-fuzz-gen}"

mkdir -p "$TOOLS_DIR"

if [[ -d "$OSS_FUZZ_GEN_DIR/.git" ]]; then
  log "Updating OSS-Fuzz-Gen repo: $OSS_FUZZ_GEN_DIR"
  git -C "$OSS_FUZZ_GEN_DIR" fetch --prune origin
  if [[ -z "$(git -C "$OSS_FUZZ_GEN_DIR" status --porcelain)" ]]; then
    git -C "$OSS_FUZZ_GEN_DIR" pull --ff-only || warn "OSS-Fuzz-Gen pull skipped"
  else
    warn "OSS-Fuzz-Gen repo has local changes; fetched only"
  fi
else
  log "Cloning OSS-Fuzz-Gen repo..."
  git clone "$OSS_FUZZ_GEN_REPO" "$OSS_FUZZ_GEN_DIR"
fi

warn "OSS-Fuzz-Gen requires Docker and model/API configuration. This script clones the tool only; configure credentials manually."
