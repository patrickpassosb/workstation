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
  if grep -qF "$target_codename" "$src" 2>/dev/null; then
    log "fix-sources: $src already references $target_codename — no change"
    continue
  fi

  # Parse only the suite/codename column of each `deb ...` line (the
  # 3rd whitespace-separated field after "deb [options]"). The previous
  # implementation grepped every [a-z]+ token in the file — which
  # included URL components like "docker", "download", "com" — and rewrote
  # the first one, corrupting URLs.
  #   e.g. `deb [arch=amd64 signed-by=...] https://download.docker.com/linux/ubuntu noble stable`
  #                                                     ^^^^^^  ^^^^^  ^^^^^  ^^^^^  <- URL tokens, NOT codenames
  # Only `noble` (the suite field) should ever be rewritten.
  replacement_done=0
  while IFS= read -r line; do
    # Strip leading "deb" and any "[...]" options block.
    stripped="${line#deb}"
    stripped="${stripped#\ \[[^\]]*\]}"
    # Now the first whitespace-separated token is the URL, the second is
    # the suite/codename, the rest is components.
    suite="$(printf '%s' "$stripped" | awk '{print $2}')"
    [[ -z "$suite" ]] && continue
    [[ "$suite" == "$target_codename" ]] && continue
    [[ "$suite" == "stable" || "$suite" == "main" ]] && continue
    # Use a quoted sed substitution to avoid regex interpretation of the
    # (letters-only) suite token.
    if sudo sed -i "s|${suite}|${target_codename}|g" "$src"; then
      log "fix-sources: $src: rewrote suite $suite -> $target_codename"
      patched+=("$src")
      replacement_done=1
      break
    fi
  done < <(grep -E '^deb[[:space:]]' "$src" 2>/dev/null)

  if [[ $replacement_done -eq 0 ]]; then
    log "fix-sources: $src: no codename-bearing lines to patch"
  fi
done

if [[ ${#checked[@]} -eq 0 ]]; then
  log "fix-sources: no docker.list or insync.list found — nothing to patch"
elif [[ ${#patched[@]} -eq 0 ]]; then
  log "fix-sources: all sources already aligned with $target_codename"
fi
