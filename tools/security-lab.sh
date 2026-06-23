#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

LAB_DIR="${SECURITY_LAB_DIR:-$HOME/hacking}"

for dir in \
  "$LAB_DIR" \
  "$LAB_DIR/targets" \
  "$LAB_DIR/wordlists" \
  "$LAB_DIR/tools" \
  "$LAB_DIR/findings" \
  "$LAB_DIR/sandboxes" \
  "$LAB_DIR/containers" \
  "$LAB_DIR/proxy/caido" \
  "$LAB_DIR/proxy/burp"; do
  mkdir -p "$dir"
done

readme="$LAB_DIR/README.md"
if [[ ! -f "$readme" ]]; then
  cat > "$readme" <<'EOF'
# Security Lab

Use this workspace for authorized testing only.

- `targets/` - local labs, CTFs, or owned target notes.
- `wordlists/` - downloaded or generated wordlists.
- `tools/` - cloned helper repos such as MCP servers.
- `findings/` - reports, screenshots, and reproduction notes.
- `sandboxes/` - disposable project copies.
- `containers/` - Docker bind-mount workspace.
- `proxy/caido` and `proxy/burp` - proxy-specific projects and exports.

Prefer the Docker wrappers installed by this workstation setup when a tool does
not need direct host integration.

Container wrappers (nuclei-docker, aflpp-docker) default to the `lab-none`
internal Docker network (no internet egress). Run with `LAB_RELAXED=1` to use
the host network when a workflow needs it (e.g. nuclei template updates,
AFL++ LLVM plugin fetches).
EOF
fi

agents_md="$LAB_DIR/AGENTS.md"
if [[ ! -f "$agents_md" ]]; then
  cat > "$agents_md" <<'EOF'
# Security Lab — Agent Policy

This workspace is for **authorized** testing only.

- Do not run any tool that executes code or sends data to a remote service
  without explicit user confirmation in the current session.
- Do not register MCP servers. Suggest the command; let the user run it.
- Do not modify Burp / Caido extensions, tokens, or licenses.
- All findings belong in `~/hacking/findings/`. Do not write to `$HOME`.
- Container wrappers (nuclei-docker, aflpp-docker) default to the
  `lab-none` internal network. Do not pass `--network=host` without
  the user setting `LAB_RELAXED=1`.
EOF
  log "Wrote agent policy: $agents_md"
fi

docker_network_ensure lab-none

log "Security lab directories ready at $LAB_DIR"
