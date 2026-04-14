#!/usr/bin/env bash
set -euo pipefail

VERSION=GIMP_2_10_38
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

flatpak_install_if_missing org.gimp.GIMP
