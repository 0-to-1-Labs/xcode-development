#!/usr/bin/env bash
# Boot a simulator, install an .app, launch it, and stream its log for a moment.
# Usage: sim-run.sh "<simulator name>" <path/to/App.app> <bundle id>
set -euo pipefail

SIM_NAME="${1:?simulator name}"
APP_PATH="${2:?path to .app}"
BUNDLE_ID="${3:?bundle id}"

udid=$(xcrun simctl list devices available -j \
  | jq -r --arg n "$SIM_NAME" '[.devices | to_entries[] | select(.key | test("iOS")) | .value[] | select(.name == $n) | .udid] | last')
[ -n "$udid" ] && [ "$udid" != "null" ] || { echo "No available simulator named '$SIM_NAME'. Run: make sims" >&2; exit 1; }

state=$(xcrun simctl list devices -j | jq -r --arg u "$udid" '.devices[][] | select(.udid == $u) | .state')
if [ "$state" != "Booted" ]; then
  echo "Booting $SIM_NAME ($udid)..."
  xcrun simctl boot "$udid"
fi
xcrun simctl bootstatus "$udid" -b >/dev/null
open -a Simulator --args -CurrentDeviceUDID "$udid" >/dev/null 2>&1 || true

echo "Installing $APP_PATH"
xcrun simctl install "$udid" "$APP_PATH"
echo "Launching $BUNDLE_ID"
xcrun simctl terminate "$udid" "$BUNDLE_ID" >/dev/null 2>&1 || true
pid=$(xcrun simctl launch "$udid" "$BUNDLE_ID" | awk -F': ' '{print $2}')
echo "Running (pid $pid) on $SIM_NAME [$udid]"
echo "Screenshot: xcrun simctl io $udid screenshot shot.png"
echo "Logs:       xcrun simctl spawn $udid log stream --predicate 'subsystem == \"$BUNDLE_ID\"'"
