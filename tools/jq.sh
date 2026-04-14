#!/usr/bin/env bash
set -euo pipefail

VERSION=jq-1.7.1
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

apt_install_if_missing jq
