#!/usr/bin/env bash
set -euo pipefail

VERSION=Audacity-3.7.3
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

flatpak_install_if_missing org.audacityteam.Audacity
