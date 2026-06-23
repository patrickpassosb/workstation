#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

CODEQL_DIR="${CODEQL_DIR:-$HOME/.local/codeql}"
BIN_DIR="$HOME/.local/bin"

ensure_local_bin_dir

if is_installed codeql; then
  log "CodeQL is already installed: $(codeql version --format=terse 2>/dev/null | head -n 1 || command -v codeql)"
  exit 0
fi

if [[ -x "$CODEQL_DIR/codeql" ]]; then
  ln -sf "$CODEQL_DIR/codeql" "$BIN_DIR/codeql"
  log "Linked existing CodeQL CLI: $BIN_DIR/codeql"
  exit 0
fi

case "$(uname -m)" in
  x86_64) ;;
  *)
    warn "CodeQL bundle is x86_64-only on Linux; skipping (host: $(uname -m))"
    exit 0
    ;;
esac

if [[ -e "$CODEQL_DIR" ]]; then
  err "CodeQL path exists but is not executable: $CODEQL_DIR"
  exit 1
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

log "Downloading latest CodeQL bundle..."
curl -fL "https://github.com/github/codeql-action/releases/latest/download/codeql-bundle-linux64.tar.gz" \
  -o "$tmp_dir/codeql-bundle-linux64.tar.gz"

mkdir -p "$HOME/.local"
tar -xzf "$tmp_dir/codeql-bundle-linux64.tar.gz" -C "$HOME/.local"
ln -sf "$CODEQL_DIR/codeql" "$BIN_DIR/codeql"

log "CodeQL installed at $CODEQL_DIR"
