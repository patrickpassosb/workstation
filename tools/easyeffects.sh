#!/usr/bin/env bash
set -euo pipefail

VERSION=v7.1.9
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

flatpak_install_if_missing com.github.wwmm.easyeffects
