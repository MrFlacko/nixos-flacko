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

# Can just run out of the Config DIR
rebuild() {
  nh os switch -f '<nixpkgs/nixos>' -- -I nixos-config="$TARGET/configuration.nix" --quiet 
}

update() {
  sudo nix-channel --update
  nh os switch -f '<nixpkgs/nixos>' -- -I nixos-config="$TARGET/configuration.nix" --quiet
}

rebuild_fast() {
  sudo nixos-rebuild switch -I nixos-config=/etc/nixos/configuration.nix
}

clean() {
  sudo nix-collect-garbage --delete-older-than 7d
  echo "Optomizing Space..."
  sudo nix-store --optimise
}

gitpush() {
  read -rp "Commit to Git? [y/N] " yn
  [[ ! "$yn" =~ ^[Yy]$ ]] && exit_script
  cd "$CONFIG"
  command git add .
  read -rp "Commit title: " t
  echo "Opening nano to add details…"
  GIT_EDITOR=nano git commit -e -m "$t"
  command git push origin "$BRANCH"
}

help() {
  echo 'Usage: build-nix [option]'
  echo
  echo "Options:"
  echo "  --fast    Run fast rebuild, skipping git and clean"
  echo "  --git     Commit and push config"
  echo "  --clean   Clean old generations and optimise store"
  echo "  --update  Updates and builds"
  echo "  --deploy  Copy config to /etc/nixos"
  echo "  --help    Show this help message"
}

exit_script() {
  echo Closing.
  exit 0
}

[[ ${1:-} == "--fast" ]] && deploy && rebuild_fast && exit_script
[[ ${1:-} == "--git" ]] && gitpush && exit_script
[[ ${1:-} == "--clean" ]] && clean && exit_script
[[ ${1:-} == "--update" ]] && deploy && update && clean && gitpush && exit_script
[[ ${1:-} == "--deploy" ]] && deploy && exit_script
[[ ${1:-} == "--help" ]] && help && exit_script
[[ -z ${1:-} ]] && deploy && rebuild && gitpush && exit_script
help