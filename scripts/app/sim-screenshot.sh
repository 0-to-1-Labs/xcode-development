#!/usr/bin/env bash
# Screenshot a booted simulator. Usage: sim-screenshot.sh "<simulator name>" <out dir>
set -euo pipefail
SIM_NAME="${1:?simulator name}"
OUT_DIR="${2:-build/screenshots}"
udid=$(xcrun simctl list devices -j \
  | jq -r --arg n "$SIM_NAME" '[.devices | to_entries[] | select(.key | test("iOS")) | .value[] | select(.name == $n and .state == "Booted") | .udid] | last')
[ -n "$udid" ] && [ "$udid" != "null" ] || { echo "'$SIM_NAME' is not booted. Run: make run" >&2; exit 1; }
mkdir -p "$OUT_DIR"
slug=$(echo "$SIM_NAME" | tr -cs '[:alnum:]' '-' | sed 's/-$//')
file="$OUT_DIR/$(date +%Y%m%d-%H%M%S)-$slug.png"
xcrun simctl io "$udid" screenshot "$file" >/dev/null
echo "$file"
