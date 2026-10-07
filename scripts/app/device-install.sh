#!/usr/bin/env bash
# Install a signed .app on the first connected iPhone/iPad and launch it.
# Usage: device-install.sh <path/to/App.app> <bundle id> [device id]
set -euo pipefail
APP_PATH="${1:?path to .app}"
BUNDLE_ID="${2:?bundle id}"
DEVICE="${3:-}"

if [ -z "$DEVICE" ]; then
  json=$(mktemp)
  xcrun devicectl list devices --json-output "$json" >/dev/null
  DEVICE=$(jq -r '[.result.devices[] | select(.connectionProperties.pairingState == "paired" or .properties.pairingState == "paired")][0].identifier // empty' "$json")
  rm -f "$json"
fi
[ -n "$DEVICE" ] || { echo "No paired device found. Plug in the device, trust this Mac, enable Developer Mode, then run: xcrun devicectl list devices" >&2; exit 1; }

echo "Installing on device $DEVICE"
xcrun devicectl device install app --device "$DEVICE" "$APP_PATH"
echo "Launching $BUNDLE_ID"
xcrun devicectl device process launch --terminate-existing --device "$DEVICE" "$BUNDLE_ID"
echo "Done. Free Personal Team profiles expire in 7 days. Re-run 'make install-device' then."
