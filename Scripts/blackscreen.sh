#!/usr/bin/env bash
# Safely blank screen with DPMS while blocking virtual/game inputs from waking it.
set -euo pipefail

STATE="/run/user/$(id -u)/_vp.ids"
mkdir -p "$(dirname "$STATE")"

# Identify and disable known virtual/game-generated input devices
xinput \
  | grep -Ei 'XTEST|Virtual|SDL|Steam|HIDAPI|Gamepad|Controller|XInput' \
  | sed -n 's/.*id=\([0-9]\+\).*/\1/p' > "$STATE" || true

while read -r id; do
  [[ -n "${id:-}" ]] && xinput set-prop "$id" "Device Enabled" 0 2>/dev/null || true
done < "$STATE"

# Turn screen off
xset dpms force off

# Wait for first real mouse move or click, then restore
xinput test-xi2 --root \
  | grep -m1 -E 'EVENT type (17|18) \(Raw(Motion|ButtonPress)\)' >/dev/null

# Re-enable virtual/game input devices
while read -r id; do
  [[ -n "${id:-}" ]] && xinput set-prop "$id" "Device Enabled" 1 2>/dev/null || true
done < "$STATE"

rm -f "$STATE"
