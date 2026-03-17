#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed antigravity || dpkg -s antigravity >/dev/null 2>&1; then
  log "Antigravity IDE is already installed."
  exit 0
fi

log "Installing Antigravity IDE..."

# Add Antigravity apt repo
GPG_KEY="/etc/apt/keyrings/antigravity-repo-key.gpg"
REPO_LIST="/etc/apt/sources.list.d/antigravity.list"

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg \
  | sudo gpg --dearmor --yes -o "$GPG_KEY"

echo "deb [signed-by=${GPG_KEY}] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" \
  | sudo tee "$REPO_LIST" > /dev/null

sudo apt-get update -y
sudo apt-get install -y antigravity

log "Antigravity IDE installed"
