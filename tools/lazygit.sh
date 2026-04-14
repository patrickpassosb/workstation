#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

VERSION="${VERSION:-$(github_latest_tag jesseduffield/lazygit 2>/dev/null || echo v0.50.0)}"

local_ver="${VERSION#v}"
case "$(uname -m)" in
  x86_64)  arch="x86_64" ;;
  aarch64) arch="arm64" ;;
  *)       err "Unsupported architecture: $(uname -m)"; exit 1 ;;
esac
github_release_install "jesseduffield/lazygit" "$VERSION" \
  "lazygit_${local_ver}_Linux_${arch}.tar.gz" "lazygit"
