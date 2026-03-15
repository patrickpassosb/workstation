#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

log "═══════════════════════════════════════════════════════"
log "  Browser Extensions (auto-install, removable)"
log "═══════════════════════════════════════════════════════"

CHROME_WEBSTORE="https://clients2.google.com/service/update2/crx"

# ── Brave extensions ─────────────────────────────────────────────────
BRAVE_EXTENSIONS=(
  "cjpalhdlnbpafiamejdnhcphjbkeiagm"  # uBlock Origin
  "nngceckbapebfimnlniiiahkandclblb"  # Bitwarden Password Manager
  "kbfnbcaeplbcioakkpcpgfkobkghlhen"  # Grammarly
  "fmkadmapgofadopljbjfkapdkoienihi"  # React Developer Tools
  "nkbihfbeogaeaoehlefnkodbefgpgknn"  # MetaMask
  "elfaihghhjjoknimpccccmkioofjjfkf"  # StayFree
  "khncfooichmfjbepaaaebmommgaepoid"  # Unhook (YouTube)
  "bhlhnicpbhignbdhedgjhgdocnmhomnp"  # ColorZilla
  "blaaajhemilngeeffpbfkdjjoefldkok"  # LeechBlock NG
  "jdcfmebflppkljibgpdlboifpcaalolg"  # Méliuz
  "lknmjhcajhfbbglglccadlfdjbaiifig"  # Meet Transcribe
)

# ── Chrome extensions ────────────────────────────────────────────────
CHROME_EXTENSIONS=(
  "eeijfnjmjelapkebgockoeaadonbchdd"  # Antigravity
  "fcoeoabgfenejglbffodgkkbkcdhcgfn"  # Claude
)

install_policy() {
  local policy_dir="$1"
  local policy_file="$policy_dir/managed/extensions.json"
  shift
  local -a ext_ids=("$@")

  # Build ExtensionSettings with normal_installed mode (user can uninstall)
  local settings="{"
  local first=true
  for id in "${ext_ids[@]}"; do
    if [[ "$first" == "true" ]]; then
      first=false
    else
      settings+=","
    fi
    settings+=$'\n'"    \"${id}\": {"
    settings+=$'\n'"      \"installation_mode\": \"normal_installed\","
    settings+=$'\n'"      \"update_url\": \"${CHROME_WEBSTORE}\""
    settings+=$'\n'"    }"
  done
  settings+=$'\n'"  }"

  sudo mkdir -p "$policy_dir/managed"
  sudo tee "$policy_file" > /dev/null <<EOF
{
  "ExtensionSettings": ${settings}
}
EOF
  log "Policy written: $policy_file (${#ext_ids[@]} extensions)"
}

# ── Install Brave policy ────────────────────────────────────────────
BRAVE_POLICY_DIR="/etc/brave/policies"
if is_installed brave-browser || is_installed brave-browser-stable; then
  install_policy "$BRAVE_POLICY_DIR" "${BRAVE_EXTENSIONS[@]}"
  log "Brave: ${#BRAVE_EXTENSIONS[@]} extensions will be auto-installed on next launch"
else
  warn "Brave browser not found — skipping Brave extension policy"
fi

# ── Install Chrome policy ───────────────────────────────────────────
CHROME_POLICY_DIR="/etc/opt/chrome/policies"
if is_installed google-chrome || is_installed google-chrome-stable; then
  install_policy "$CHROME_POLICY_DIR" "${CHROME_EXTENSIONS[@]}"
  log "Chrome: ${#CHROME_EXTENSIONS[@]} extensions will be auto-installed on next launch"
else
  warn "Google Chrome not found — skipping Chrome extension policy"
fi

log ""
log "── Notes ─────────────────────────────────────────────"
log "  Extensions are installed on next browser launch."
log "  You can uninstall any extension normally from the browser."
log "  To remove this policy:"
log "    sudo rm $BRAVE_POLICY_DIR/managed/extensions.json"
log "    sudo rm $CHROME_POLICY_DIR/managed/extensions.json"
log ""
log "  Extension settings (uBlock filters, LeechBlock rules, etc.)"
log "  are best restored via Brave Sync / Chrome Sync — just sign in."
