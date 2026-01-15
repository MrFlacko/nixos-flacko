#!/usr/bin/env bash
set -euo pipefail

CONFIG="$HOME/.config/nix-config"
TARGET="/etc/nixos"
BRANCH="main"

deploy() {
  sudo rm -rf "$TARGET"/*
  sudo cp -ra "$CONFIG"/* "$TARGET"
  sudo chmod +x "$TARGET"/Scripts/*.sh
}

rebuild() {
  sudo nix-channel --update
  nh os switch -f '<nixpkgs/nixos>' -- -I nixos-config="$TARGET/configuration.nix" 
}

rebuild_fast() {
  sudo nixos-rebuild switch --no-reexec -I nixos-config=/etc/nixos/configuration.nix
}

clean() {
  sudo nix-collect-garbage --delete-older-than 30d
}

push_commit() {
  cd "$CONFIG"
  git add .
  read -rp "Commit title: " t
  echo "Opening nano to add details…"
  GIT_EDITOR=nano git commit -e -m "$t"
  git push origin "$BRANCH"
}

deploy
[[ ${1:-} == "--fast" ]] && rebuild_fast
[[ ${1:-} != "--fast" ]] && rebuild && clean && {
  read -rp "Build succeeded. Commit to Git? [y/N] " yn
  [[ $yn =~ ^[Yy]$ ]] && push_commit || echo "Skipping commit."
}