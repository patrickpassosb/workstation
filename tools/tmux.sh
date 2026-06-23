#!/usr/bin/env bash
set -euo pipefail

VERSION=3.5a
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

pkg_install_if_missing tmux
