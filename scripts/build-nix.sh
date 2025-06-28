#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="$HOME/.config/nix-config"
TARGET_DIR="/etc/nixos"
BRANCH="main"

deploy() {
  sudo rm -rf "${TARGET_DIR:?}"/*
  sudo cp -ra "$CONFIG_DIR"/* "$TARGET_DIR"
  sudo chmod +x "$TARGET_DIR"/setup/*.sh
}

rebuild() {
  nh os switch -f '<nixpkgs/nixos>' \
    -- -I nixos-config="$TARGET_DIR/configuration.nix"
}

commit_and_push() {
  cd "$CONFIG_DIR"
  git add .
  read -rp "Commit title: " title
  read -rp "Commit details: " details
  git commit -m "$title" -m "$details"
  git push origin "$BRANCH"
}

main() {
  deploy
  if rebuild; then
    commit_and_push
  else
    echo "⛔ Build failed. Aborting commit." >&2
    exit 1
  fi
}

main
