#!/usr/bin/env bash
# Telegram Desktop (Nicegram) - extremely complex build.
set -euo pipefail

VERSION=v5.12.1
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

flatpak_install_if_missing org.telegram.desktop
