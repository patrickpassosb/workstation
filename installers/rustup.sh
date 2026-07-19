#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed rustc; then
  log "Rust is already installed: $(rustc --version)"
  exit 0
fi

log "Installing Rust via rustup (latest)..."
# Set RUSTUP_INSTALLER_SHA256 to verify the install script. Without it,
# the script is still downloaded-then-executed (not piped to sh). rustup
# itself verifies the downloaded binary's signature after install.
run_installer_script \
  "https://sh.rustup.rs" \
  "${RUSTUP_INSTALLER_SHA256:-}" \
  -y

# Source cargo env so subsequent commands in this session can find rustc/cargo
if [[ -f "$HOME/.cargo/env" ]]; then
  # shellcheck disable=SC1091
  source "$HOME/.cargo/env"
fi

log "Rust installed: $(rustc --version)"
