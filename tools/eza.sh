#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed eza; then
  log "eza is already installed: $(eza --version | head -1)"
else
  if pkg_available eza; then
    pkg_install_if_missing eza
  else
    # Fall back to GitHub release (always latest)
    log "eza not in distro repos — installing latest from GitHub release..."
    tag=""
    tag="$(github_latest_tag 'eza-community/eza')"
    # eza ships per-arch tarballs; pick the right one for this host.
    case "$(uname -m)" in
      x86_64|amd64)   eza_arch="x86_64-unknown-linux-gnu" ;;
      aarch64|arm64)  eza_arch="aarch64-unknown-linux-gnu" ;;
      *)
        warn "eza has no prebuilt binary for $(uname -m); skipping."
        exit 0
        ;;
    esac
    asset="eza_${eza_arch}.tar.gz"
    github_release_install "eza-community/eza" "$tag" "$asset" "eza"
  fi
fi
