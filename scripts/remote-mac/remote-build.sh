#!/usr/bin/env bash
# Sync an app to a remote Mac over ssh and run a make target there.
# Usage: remote-build.sh <AppName> [make target] [host]
#   host defaults to REMOTE_MAC_HOST in ~/.config/xcode-development/env.
# Requirements on the remote: Apple Silicon, Xcode 27+, a logged-in GUI session
# (simulators need one), Homebrew tools (see setup.sh). Key-based ssh.
set -euo pipefail
ENV_FILE="$HOME/.config/xcode-development/env"
APP="${1:?app name}"; TARGET="${2:-test}"; HOST="${3:-}"
if [ -z "$HOST" ] && [ -f "$ENV_FILE" ]; then HOST=$(grep '^REMOTE_MAC_HOST=' "$ENV_FILE" | cut -d= -f2- || true); fi
[ -n "$HOST" ] || { echo "No host. Pass one or set REMOTE_MAC_HOST in $ENV_FILE." >&2; exit 2; }
SRC="$PWD/apps/$APP/"
[ -d "$SRC" ] || { echo "No app at $SRC (run from the workspace root)" >&2; exit 1; }
REMOTE_DIR="xcode-development/apps/$APP"   # relative to the remote home

echo "Syncing $APP to $HOST:~/$REMOTE_DIR"
ssh -o BatchMode=yes "$HOST" "mkdir -p $REMOTE_DIR"
rsync -az --delete --exclude build --exclude '*.xcodeproj' --exclude .git --exclude Configs/Local.xcconfig "$SRC" "$HOST:$REMOTE_DIR/"

echo "Running make $TARGET on $HOST"
set +e
ssh -o BatchMode=yes "$HOST" "export PATH=/opt/homebrew/bin:\$PATH; cd $REMOTE_DIR && make $TARGET"
status=$?
set -e
if [ "$status" = "0" ]; then
  mkdir -p "$SRC/build/remote-$HOST"
  rsync -az "$HOST:$REMOTE_DIR/build/results/" "$SRC/build/remote-$HOST/" 2>/dev/null || true
  echo "Results copied to apps/$APP/build/remote-$HOST/"
fi
exit "$status"
