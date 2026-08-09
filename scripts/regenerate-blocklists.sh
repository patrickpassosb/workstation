#!/usr/bin/env bash
set -euo pipefail
# Regenerate configs/blocklists/porn-betting.txt (long tail) from StevenBlack.
# The curated core (porn-betting-core.txt) is hand-maintained for top sites +
# Brazilian betting brands. This rebuilds the long-tail file, excluding the
# core to avoid duplicates.
#
# Usage: ./scripts/regenerate-blocklists.sh

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
CORE="$REPO_ROOT/configs/blocklists/porn-betting-core.txt"
OUT="$REPO_ROOT/configs/blocklists/porn-betting.txt"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

log() { printf '[INFO] %s\n' "$*"; }

log "Downloading StevenBlack lists..."
curl -fsSL "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-porn-only/hosts" -o "$TMP/gp.hosts"
curl -fsSL "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-only/hosts" -o "$TMP/g.hosts"

log "Curating registrable domains and excluding core..."
python3 - "$TMP/gp.hosts" "$TMP/g.hosts" "$CORE" "$OUT" <<'PY'
import re, sys
SRC_GP, SRC_G, CORE_PATH, OUT = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]

MSUFF = {'co.uk','com.br','net.br','com.au','co.in','com.mx','com.ar','com.tr',
         'co.za','com.es','co.il','com.pt','com.pl','com.de','com.fr','co.nz',
         'com.vn','co.id','com.co','com.sg'}

def reg(dom):
    p = dom.split('.')
    if len(p) <= 2:
        return dom
    if len(p) >= 3 and '.'.join(p[-2:]) in MSUFF:
        return '.'.join(p[-3:]) if len(p) > 3 else dom
    return '.'.join(p[-2:])

def load(path):
    out = set()
    for line in open(path):
        m = re.match(r'^0\.0\.0\.0\s+([A-Za-z0-9.-]+)$', line.strip())
        if m:
            out.add(reg(m.group(1).lower().lstrip('.')))
    return out

doms = load(SRC_GP) | load(SRC_G)
clean = sorted(x for x in doms if re.fullmatch(r'[a-z0-9.-]+\.[a-z]{2,}', x) and '..' not in x)
core = set(l.strip().lower() for l in open(CORE_PATH) if l.strip() and not l.startswith('#'))
# Always-allow domains (original spec): keep YouTube/Reddit/Twitch/LinkedIn usable.
ALWAYS_ALLOW = {'youtube.com','reddit.com','twitch.tv','linkedin.com',
                'www.reddit.com','old.reddit.com','m.youtube.com'}
remaining = [x for x in clean if x not in core and x not in ALWAYS_ALLOW]

header = [
    "# Full porn + betting blocklist (long tail)",
    "# Source: StevenBlack/hosts alternates gambling-porn-only + gambling-only",
    "# https://github.com/StevenBlack/hosts",
    "# Regenerate: ./scripts/regenerate-blocklists.sh",
    "# Registrable domains only; curated core (porn-betting-core.txt) excluded to avoid dupes.",
    "",
]
with open(OUT, 'w') as f:
    f.write('\n'.join(header + remaining) + '\n')
print("long-tail domains:", len(remaining))
PY

log "Done. Written to $OUT"
