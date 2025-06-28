#!/usr/bin/env nix-shell
#!nix-shell -i bash -p git rustc cargo coreutils bash

set -euo pipefail

# 1) Dump your original EDID
mkdir -p ~/edid-dump
sudo cp /sys/class/drm/card1-DP-2/edid ~/edid-dump/orig.edid

# 2) Clone & build edid-gen
rm -rf ~/edid-gen-src
git clone https://github.com/nibon7/edid-gen.git ~/edid-gen-src
cd ~/edid-gen-src
cargo build --release

# 3) Generate a fresh EDID for 2560×1440@60
~/edid-gen-src/target/release/edid-gen \
  2560 1440 \
  --output ~/edid-dump/edid-2560x1440.bin \
  --timing-name "2560x1440@60" \
  60

# 4) Check file size
stat -c%s ~/edid-dump/edid-2560x1440.bin && echo "bytes"

echo "
Run the following commands now as this needs to happen outside Nix shell

mkdir -p ~/.config/nix-config/edid && cp ~/edid-dump/edid-2560x1440.bin ~/.config/nix-config/edid/edid-2560x1440.bin
"