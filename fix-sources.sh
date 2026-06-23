#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/helpers.sh"

if ! is_ubuntu_like; then
  warn "fix-sources.sh only applies to Ubuntu/Mint apt sources — skipping on $(distro_id)."
  exit 0
fi

sudo sed -i 's/zena/noble/g' /etc/apt/sources.list.d/docker.list /etc/apt/sources.list.d/insync.list
