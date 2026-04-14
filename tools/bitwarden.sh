#!/usr/bin/env bash
# Bitwarden Desktop is a TypeScript/Electron app.
set -euo pipefail

VERSION=desktop-v2025.1.3
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

flatpak_install_if_missing com.bitwarden.desktop
