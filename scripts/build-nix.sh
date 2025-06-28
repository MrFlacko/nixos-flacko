#!/usr/bin/env bash
set -euo pipefail

CONFIG="$HOME/.config/nix-config"
TARGET="/etc/nixos"
BRANCH="main"

deploy() {
  sudo rm -rf "$TARGET"/*
  sudo cp -ra "$CONFIG"/* "$TARGET"
  sudo chmod +x "$TARGET"/setup/*.sh
}

rebuild() {
  nh os switch -f '<nixpkgs/nixos>' -- -I nixos-config="$TARGET/configuration.nix"
}

push_commit() {
  cd "$CONFIG"
  git add .
  read -rp "Commit title: " t
  echo "Opening nano to add details…"
  GIT_EDITOR=nano git commit -e -m "$t"
  git push origin "$BRANCH"
}

deploy && rebuild && {
  read -rp "Build succeeded. Commit to Git? [y/N] " yn
  [[ $yn =~ ^[Yy]$ ]] && push_commit || echo "Skipping commit."
}
