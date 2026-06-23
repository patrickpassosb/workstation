#!/usr/bin/env bash
# Patch Ubuntu-derived third-party apt sources so they point at the
# underlying Ubuntu codename. Some third-party repos hard-code the
# distro codename (e.g. Linux Mint's "zena") in their sources.list,
# which breaks apt update when the next Mint release ships.
#
# No-op on Fedora (Docker comes from a dnf repo with no codename).

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/helpers.sh
source "$SCRIPT_DIR/lib/helpers.sh"

if is_fedora_like; then
  log "fix-sources: Fedora has no codename-bearing apt sources — skipping"
  exit 0
fi

if ! is_ubuntu_like; then
  log "fix-sources: not an Ubuntu-derived distro ($(distro_id)) — skipping"
  exit 0
fi

target_codename="$(get_ubuntu_codename)"
[[ -n "$target_codename" ]] || { warn "fix-sources: could not detect Ubuntu codename"; exit 0; }

patched=()
checked=()

for src in /etc/apt/sources.list.d/docker.list /etc/apt/sources.list.d/insync.list; do
  if [[ ! -f "$src" ]]; then
    continue
  fi
  checked+=("$src")
  # Capture the codenames actually present in the file (one occurrence is typical).
  present="$(grep -oE '[a-z]+' "$src" 2>/dev/null | sort -u || true)"
  if grep -qF "$target_codename" "$src" 2>/dev/null; then
    log "fix-sources: $src already references $target_codename — no change"
    continue
  fi
  # Find the first non-target codename in the file and rewrite it.
  replacement_done=0
  for old in $present; do
    [[ "$old" == "$target_codename" ]] && continue
    [[ "$old" == "stable" || "$old" == "main" || "$old" == "component" ]] && continue
    [[ ${#old} -lt 4 ]] && continue
    if sudo sed -i "s/$old/$target_codename/g" "$src"; then
      log "fix-sources: $src: rewrote $old -> $target_codename"
      patched+=("$src")
      replacement_done=1
      break
    fi
  done
  if [[ $replacement_done -eq 0 ]]; then
    log "fix-sources: $src: no codename-bearing lines to patch"
  fi
done

if [[ ${#checked[@]} -eq 0 ]]; then
  log "fix-sources: no docker.list or insync.list found — nothing to patch"
elif [[ ${#patched[@]} -eq 0 ]]; then
  log "fix-sources: all sources already aligned with $target_codename"
fi
