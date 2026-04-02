#!/usr/bin/env bash
set -euo pipefail

VERSION=bun-v1.2.9
MODE="${1:-build}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

case "$MODE" in
  prebuilt)
    if is_installed bun; then
      log "bun is already installed: $(bun --version)"
    else
      log "Installing bun via official installer..."
      curl -fsSL https://bun.sh/install | bash
      # Source bun env so it's available in the current session
      if [[ -f "$HOME/.bun/bin/bun" ]]; then
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
        log "bun installed: $(bun --version)"
      fi
    fi
    ;;
  clone)
    clone_or_pull https://github.com/oven-sh/bun.git bun "$VERSION"
    log "bun $VERSION cloned to $SRC_DIR/bun"
    log "To build manually (requires Zig, C/C++ toolchain, and CMake):"
    log "  sudo apt install build-essential cmake ninja-build python3 pkg-config"
    log "  # Install Zig: https://ziglang.org/download/"
    log "  cd $SRC_DIR/bun"
    log "  cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release"
    log "  ninja -C build"
    log "  sudo install -m 0755 build/bun $INSTALL_PREFIX/bin/bun"
    ;;
  build)
    clone_or_pull https://github.com/oven-sh/bun.git bun "$VERSION"
    ensure_build_deps build-essential cmake ninja-build python3 pkg-config
    if ! is_installed zig; then
      warn "Zig compiler is required to build bun from source."
      warn "Install Zig from: https://ziglang.org/download/"
      warn "Falling back to prebuilt install..."
      curl -fsSL https://bun.sh/install | bash
      if [[ -f "$HOME/.bun/bin/bun" ]]; then
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
        log "bun installed (prebuilt fallback): $(bun --version)"
      fi
      exit 0
    fi
    log "Building bun $VERSION..."
    cd "$SRC_DIR/bun"
    cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
    ninja -C build
    sudo install -m 0755 build/bun "$INSTALL_PREFIX/bin/bun"
    log "bun installed to $INSTALL_PREFIX/bin/bun"
    ;;
  *) err "Unknown mode: $MODE (use prebuilt, clone, or build)"; exit 1 ;;
esac
