#!/usr/bin/env bash
# npm install safety policy
# ----------------------------
# Global installs use --ignore-scripts (set in configs/npm-security.sh).
# Postinstalls are only run for packages in NPM_POSTINSTALL_ALLOWLIST.
# Add a package to that list only if you trust its postinstall
# (typically: it downloads a signed binary from the package author's
# release infra).
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

NPM_POSTINSTALL_ALLOWLIST=(
  opencode-ai  # downloads platform binary from opencode.ai release infra
)

for pkg in "${NPM_POSTINSTALL_ALLOWLIST[@]}"; do
  pkg_root="$(npm root -g)/$pkg"
  if [ ! -d "$pkg_root" ]; then
    log "  skip postinstall, package not installed: $pkg"
    continue
  fi
  postinstall=""
  for candidate in postinstall.mjs postinstall.js postinstall; do
    if [ -f "$pkg_root/$candidate" ]; then
      postinstall="$pkg_root/$candidate"
      break
    fi
  done
  if [ -z "$postinstall" ]; then
    log "  skip postinstall, no script found for: $pkg"
    continue
  fi
  log "  running postinstall for trusted package: $pkg"
  node "$postinstall" || warn "  postinstall failed for $pkg"
done
