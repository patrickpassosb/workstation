#!/usr/bin/env bash
# Docker: prebuilt install from Docker's official distro repository.
set -euo pipefail

VERSION=v28.0.4
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

if is_installed docker; then
  log "docker is already installed: $(docker --version)"
elif is_fedora_like; then
  log "Adding Docker Fedora repository..."
  add_dnf_repo https://download.docker.com/linux/fedora/docker-ce.repo
  sudo dnf install -y docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin
else
  log "Adding Docker apt repository..."
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(get_ubuntu_codename) stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt-get update -y
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin
fi

# Start the daemon and grant the current user access. Without this the
# security-lab network check in setup.sh silently fails on a fresh install.
if command -v systemctl >/dev/null 2>&1; then
  if ! systemctl is-active --quiet docker 2>/dev/null; then
    log "Enabling and starting docker daemon"
    sudo systemctl enable --now docker || warn "Failed to start docker daemon"
  fi
  if [[ -n "${SUDO_USER:-}" ]]; then
    target_user="$SUDO_USER"
  else
    target_user="${USER:-$(whoami)}"
  fi
  if getent group docker >/dev/null 2>&1 && ! id -nG "$target_user" 2>/dev/null | grep -qw docker; then
    log "Adding $target_user to the docker group (re-login required)"
    sudo usermod -aG docker "$target_user" || warn "Failed to add $target_user to docker group"
  fi
fi
