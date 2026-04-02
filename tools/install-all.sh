#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"
source "$SCRIPT_DIR/../lib/registry.sh"

LEVEL="${1:-0}"
BUILD_INSTRUCTIONS="${SRC_DIR}/BUILD_INSTRUCTIONS.md"
CLONED_TOOLS=()

log "═══════════════════════════════════════════════════════"
log "  Phase 1: Tools — Level $LEVEL: ${LEVEL_NAMES[$LEVEL]}"
log "  ${LEVEL_DESCRIPTIONS[$LEVEL]}"
log "═══════════════════════════════════════════════════════"

FAILED=()
SKIPPED=()
INSTALLED=()

# ── Build instructions generator ─────────────────────────────────────
init_build_instructions() {
  mkdir -p "$(dirname "$BUILD_INSTRUCTIONS")"
  cat > "$BUILD_INSTRUCTIONS" <<EOF
# Build Instructions — Phase 1, Level $LEVEL (${LEVEL_NAMES[$LEVEL]})

These tools were cloned to \`$SRC_DIR/\`. Build them yourself to learn how each one works.
After building, run the install command to make the tool available system-wide.

When you're done learning, you can also run \`./tools/<name>.sh build\` to compile automatically.

---

EOF
}

append_build_instructions() {
  local name="$1"
  case "$name" in
    # ── Level 1: Node.js CLIs ──
    codex)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## codex
\`\`\`bash
cd $SRC_DIR/codex/codex-cli
npm install
npm run build
sudo npm link
\`\`\`

EOF
      ;;
    claude-code)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## claude-code
\`\`\`bash
cd $SRC_DIR/claude-code
npm install
npm run build
sudo npm link
\`\`\`

EOF
      ;;
    gemini-cli)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## gemini-cli
\`\`\`bash
cd $SRC_DIR/gemini-cli
npm install
npm run build
sudo npm link
\`\`\`

EOF
      ;;
    kilo-cli)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## kilo-cli
\`\`\`bash
cd $SRC_DIR/kilocode
npm install
npm run build
sudo npm link
\`\`\`

EOF
      ;;
    vercel-cli)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## vercel-cli
\`\`\`bash
cd $SRC_DIR/vercel
npm install
npx turbo run build --filter=vercel
cd packages/cli
sudo npm link
\`\`\`

EOF
      ;;
    context-hub)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## context-hub
\`\`\`bash
cd $SRC_DIR/context-hub
npm install
npm run build
sudo npm link
\`\`\`

EOF
      ;;
    # ── Level 2: Go CLIs ──
    fzf)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## fzf
\`\`\`bash
cd $SRC_DIR/fzf
go build -o fzf .
sudo install -m 0755 fzf $INSTALL_PREFIX/bin/fzf
\`\`\`

EOF
      ;;
    lazygit)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## lazygit
\`\`\`bash
cd $SRC_DIR/lazygit
go build -o lazygit .
sudo install -m 0755 lazygit $INSTALL_PREFIX/bin/lazygit
\`\`\`

EOF
      ;;
    lazydocker)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## lazydocker
\`\`\`bash
cd $SRC_DIR/lazydocker
go build -o lazydocker .
sudo install -m 0755 lazydocker $INSTALL_PREFIX/bin/lazydocker
\`\`\`

EOF
      ;;
    opencode)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## opencode
\`\`\`bash
cd $SRC_DIR/opencode
go build -o opencode ./cmd/opencode
sudo install -m 0755 opencode $INSTALL_PREFIX/bin/opencode
\`\`\`

EOF
      ;;
    # ── Level 3: Rust CLIs ──
    ripgrep)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## ripgrep
\`\`\`bash
cd $SRC_DIR/ripgrep
cargo build --release
sudo install -m 0755 target/release/rg $INSTALL_PREFIX/bin/rg
\`\`\`

EOF
      ;;
    fd)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## fd
\`\`\`bash
cd $SRC_DIR/fd
cargo build --release
sudo install -m 0755 target/release/fd $INSTALL_PREFIX/bin/fd
\`\`\`

EOF
      ;;
    bat)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## bat
\`\`\`bash
cd $SRC_DIR/bat
cargo build --release
sudo install -m 0755 target/release/bat $INSTALL_PREFIX/bin/bat
\`\`\`

EOF
      ;;
    eza)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## eza
\`\`\`bash
cd $SRC_DIR/eza
cargo build --release
sudo install -m 0755 target/release/eza $INSTALL_PREFIX/bin/eza
\`\`\`

EOF
      ;;
    delta)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## delta
\`\`\`bash
cd $SRC_DIR/delta
cargo build --release
sudo install -m 0755 target/release/delta $INSTALL_PREFIX/bin/delta
\`\`\`

EOF
      ;;
    zoxide)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## zoxide
\`\`\`bash
cd $SRC_DIR/zoxide
cargo build --release
sudo install -m 0755 target/release/zoxide $INSTALL_PREFIX/bin/zoxide
\`\`\`

EOF
      ;;
    # ── Level 4: Heavy Rust ──
    starship)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## starship
\`\`\`bash
cd $SRC_DIR/starship
cargo build --release
sudo install -m 0755 target/release/starship $INSTALL_PREFIX/bin/starship
\`\`\`

EOF
      ;;
    uv)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## uv
\`\`\`bash
cd $SRC_DIR/uv
cargo build --release
sudo install -m 0755 target/release/uv $INSTALL_PREFIX/bin/uv
# If uvx exists:
# sudo install -m 0755 target/release/uvx $INSTALL_PREFIX/bin/uvx
\`\`\`

EOF
      ;;
    bun)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## bun
\`\`\`bash
# Install build dependencies first:
sudo apt install build-essential cmake ninja-build python3 pkg-config
# Install Zig: https://ziglang.org/download/

cd $SRC_DIR/bun
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
ninja -C build
sudo install -m 0755 build/bun $INSTALL_PREFIX/bin/bun
\`\`\`

EOF
      ;;
    # ── Level 5: Go with make ──
    gh)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## gh (GitHub CLI)
\`\`\`bash
cd $SRC_DIR/gh
make bin/gh
sudo install -m 0755 bin/gh $INSTALL_PREFIX/bin/gh
\`\`\`

EOF
      ;;
    tailscale)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## tailscale
\`\`\`bash
cd $SRC_DIR/tailscale
go build -o tailscale ./cmd/tailscale
go build -o tailscaled ./cmd/tailscaled
sudo install -m 0755 tailscale $INSTALL_PREFIX/bin/tailscale
sudo install -m 0755 tailscaled $INSTALL_PREFIX/sbin/tailscaled
\`\`\`

EOF
      ;;
    docker)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## docker (CLI only)
\`\`\`bash
cd $SRC_DIR/docker-cli
make binary
sudo install -m 0755 build/docker $INSTALL_PREFIX/bin/docker
\`\`\`
Note: This builds the CLI only. For the daemon, install docker-ce from Docker's official apt repo.

EOF
      ;;
    # ── Level 6: CMake/Meson ──
    flameshot)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## flameshot
\`\`\`bash
# Install build dependencies first:
sudo apt install build-essential cmake qtbase5-dev qttools5-dev-tools qttools5-dev libqt5svg5-dev libqt5dbus5 pkg-config

cd $SRC_DIR/flameshot
mkdir -p build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX ..
make -j\$(nproc)
sudo make install
\`\`\`

EOF
      ;;
    easyeffects)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## easyeffects
\`\`\`bash
# Install build dependencies first:
sudo apt install build-essential meson ninja-build pkg-config libgtk-4-dev \\
  libadwaita-1-dev libpipewire-0.3-dev liblilv-dev libsigc++-3.0-dev \\
  libsamplerate0-dev libsndfile1-dev libbs2b-dev librubberband-dev libebur128-dev \\
  liblsp-plug-in-dev libfftw3-dev libgsl-dev libspeexdsp-dev libnlopt-dev libfmt-dev

cd $SRC_DIR/easyeffects
meson setup _build --prefix=$INSTALL_PREFIX
ninja -C _build
sudo ninja -C _build install
\`\`\`

EOF
      ;;
    # ── Level 7: Autotools ──
    htop)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## htop
\`\`\`bash
# Install build dependencies first:
sudo apt install build-essential autoconf automake libncursesw5-dev

cd $SRC_DIR/htop
./autogen.sh
./configure --prefix=$INSTALL_PREFIX
make -j\$(nproc)
sudo make install
\`\`\`

EOF
      ;;
    jq)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## jq
\`\`\`bash
# Install build dependencies first:
sudo apt install build-essential autoconf automake libtool

cd $SRC_DIR/jq
git submodule update --init
autoreconf -i
./configure --prefix=$INSTALL_PREFIX --with-oniguruma=builtin
make -j\$(nproc)
sudo make install
\`\`\`

EOF
      ;;
    # ── Level 8: Core system ──
    tmux)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## tmux
\`\`\`bash
# Install build dependencies first:
sudo apt install build-essential autoconf automake libevent-dev libncurses-dev bison pkg-config

cd $SRC_DIR/tmux
sh autogen.sh
./configure --prefix=$INSTALL_PREFIX
make -j\$(nproc)
sudo make install
\`\`\`

EOF
      ;;
    zsh)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## zsh
\`\`\`bash
# Install build dependencies first:
sudo apt install build-essential autoconf libncurses-dev texinfo yodl

cd $SRC_DIR/zsh
./Util/preconfig
./configure --prefix=$INSTALL_PREFIX
make -j\$(nproc)
sudo make install
\`\`\`

EOF
      ;;
    # ── Level 9: Git ──
    git)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## git
\`\`\`bash
# Install build dependencies first:
sudo apt install build-essential libssl-dev libcurl4-openssl-dev libexpat1-dev gettext zlib1g-dev

cd $SRC_DIR/git
make prefix=$INSTALL_PREFIX -j\$(nproc) all
sudo make prefix=$INSTALL_PREFIX install
\`\`\`

EOF
      ;;
    # ── Level 10: Node.js ──
    nodejs)
      cat >> "$BUILD_INSTRUCTIONS" <<EOF
## Node.js
WARNING: This takes 30+ minutes and is very CPU intensive.
\`\`\`bash
# Install build dependencies first:
sudo apt install build-essential python3 g++ make

cd $SRC_DIR/node
./configure --prefix=$INSTALL_PREFIX
make -j\$(nproc)
sudo make install
\`\`\`

EOF
      ;;
  esac
}

# ── Tool runner ──────────────────────────────────────────────────────
run_tool() {
  local name="$1"
  local mode
  mode="$(get_tool_mode "$name" "$LEVEL")"
  local script="$SCRIPT_DIR/${name}.sh"

  log "── $name ($mode) ────────────────────────────────────"
  if [[ ! -f "$script" ]]; then
    warn "Script not found: $script"
    SKIPPED+=("$name")
    return
  fi
  if bash "$script" "$mode"; then
    INSTALLED+=("$name")
    if [[ "$mode" == "clone" ]]; then
      CLONED_TOOLS+=("$name")
      append_build_instructions "$name"
    fi
  else
    warn "Failed: $name"
    FAILED+=("$name")
  fi
}

# ── Initialize build instructions file ───────────────────────────────
if (( LEVEL > 0 )); then
  init_build_instructions
fi

# ── Core system tools ────────────────────────────────────────────────
for name in zsh git tmux htop jq; do
  run_tool "$name"
done

# ── Developer utilities ──────────────────────────────────────────────
for name in bat eza delta zoxide flameshot uv bun ripgrep fd starship fzf gh docker lazygit lazydocker opencode tailscale easyeffects; do
  run_tool "$name"
done

# ── Heavy apps (always pre-built in Phase 1) ─────────────────────────
for name in nodejs obs telegram audacity gimp bitwarden; do
  run_tool "$name"
done

# ── Node.js CLIs (need Node installed first) ─────────────────────────
log ""
log "═══════════════════════════════════════════════════════"
log "  Node.js/TS CLIs"
log "═══════════════════════════════════════════════════════"

for name in codex gemini-cli kilo-cli vercel-cli context-hub claude-code; do
  run_tool "$name"
done

# ── Summary ──────────────────────────────────────────────────────────
log ""
log "═══════════════════════════════════════════════════════"
log "  Tools summary — Phase 1, Level $LEVEL (${LEVEL_NAMES[$LEVEL]})"
log "═══════════════════════════════════════════════════════"
log "Installed: ${INSTALLED[*]:-none}"
[[ ${#SKIPPED[@]} -gt 0 ]] && warn "Skipped: ${SKIPPED[*]}"
[[ ${#FAILED[@]} -gt 0 ]] && err "Failed: ${FAILED[*]}"

if [[ ${#CLONED_TOOLS[@]} -gt 0 ]]; then
  log ""
  log "── Build these yourself ────────────────────────────"
  log "  Cloned: ${CLONED_TOOLS[*]}"
  log "  Instructions: $BUILD_INSTRUCTIONS"
  log ""
  log "  Or compile any tool automatically:"
  log "    ./tools/<name>.sh build"
fi

[[ ${#FAILED[@]} -eq 0 ]]
