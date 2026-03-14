#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

log()  { printf '[INFO]  %s\n' "$*"; }
warn() { printf '[WARN]  %s\n' "$*"; }

BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

# Step 1: Backup existing configs
log "Backing up existing configs to $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
for f in .zshrc .bashrc .gitconfig; do
  if [[ -f "$HOME/$f" ]]; then
    cp "$HOME/$f" "$BACKUP_DIR/$f"
    log "Backed up ~/$f"
  fi
done

# Step 2: Copy sanitized configs
log "Restoring configs from $SCRIPT_DIR"
cp "$SCRIPT_DIR/zshrc"     "$HOME/.zshrc"
cp "$SCRIPT_DIR/bashrc"    "$HOME/.bashrc"
cp "$SCRIPT_DIR/gitconfig" "$HOME/.gitconfig"
log "Configs restored"

# Step 3: Prompt for secrets
echo
read -rp "Enter your GITHUB_MCP_PAT (or press Enter to skip): " pat
if [[ -n "$pat" ]]; then
  # Append to both shell configs
  echo "export GITHUB_MCP_PAT=$pat" >> "$HOME/.zshrc"
  echo "export GITHUB_MCP_PAT=$pat" >> "$HOME/.bashrc"
  log "GITHUB_MCP_PAT written to ~/.zshrc and ~/.bashrc"
else
  log "Skipped GITHUB_MCP_PAT — you can set it later in ~/.zshrc and ~/.bashrc"
fi

log "Done. Previous configs saved in $BACKUP_DIR"
