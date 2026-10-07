#!/usr/bin/env bash
# Check and prepare a remote Mac as a build host. Prints each step and asks
# before the large ones. Usage: setup.sh [host]  (default: REMOTE_MAC_HOST)
set -euo pipefail
ENV_FILE="$HOME/.config/xcode-development/env"
HOST="${1:-}"
if [ -z "$HOST" ] && [ -f "$ENV_FILE" ]; then HOST=$(grep '^REMOTE_MAC_HOST=' "$ENV_FILE" | cut -d= -f2- || true); fi
[ -n "$HOST" ] || { echo "No host. Pass one or set REMOTE_MAC_HOST in $ENV_FILE." >&2; exit 2; }
run() { ssh -o BatchMode=yes "$HOST" "$@"; }
ask() { read -r -p "$1 [y/N] " a; [[ "$a" =~ ^[Yy]$ ]]; }

echo "== $HOST =="
arch=$(run 'uname -m'); ver=$(run 'sw_vers -productVersion')
echo "arch=$arch macOS=$ver"
[ "$arch" = "arm64" ] || { echo "Xcode 27 needs Apple Silicon. $HOST is $arch." >&2; exit 1; }
if [ "$(printf '%s\n26.6\n' "$ver" | sort -V | head -1)" != "26.6" ]; then
  echo "macOS $ver is below 26.6, which Xcode 27 requires. Update first:"
  echo "  ssh $HOST 'sudo softwareupdate --install --os-only --restart --agree-to-license'"; exit 0
fi
if ! run 'who | grep -q console'; then
  echo "No GUI session on $HOST. Simulators need one. Enable auto-login and keep the Mac awake."; fi
if ! run 'test -d /Applications/Xcode.app'; then
  echo "Xcode is not installed on $HOST. Options:"
  echo "  A) Screen Share, sign in to the App Store, install Xcode."
  echo "  B) ssh $HOST 'brew install xcodesorg/made/xcodes aria2 && xcodes install --latest --experimental-unxip'"
  exit 0
fi
echo "== Homebrew tools =="
run 'PATH=/opt/homebrew/bin:$PATH brew install xcodegen swiftlint xcbeautify swift-format lefthook jq' 2>&1 | tail -2
echo "== Xcode first run (needs sudo on $HOST; run these there if they fail) =="
run 'sudo -n xcode-select -s /Applications/Xcode.app && sudo -n xcodebuild -license accept && sudo -n xcodebuild -runFirstLaunch' 2>&1 | tail -2 || cat <<MSG
  sudo xcode-select -s /Applications/Xcode.app
  sudo xcodebuild -license accept
  sudo xcodebuild -runFirstLaunch
MSG
if ask "Download the iOS simulator platform on $HOST now (several GB)?"; then run 'xcodebuild -downloadPlatform iOS'; fi
cat <<MSG

== CI runner (optional, manual) ==
Register a runner that runs as the logged-in GUI user, not in Docker:
  GitHub Actions: https://docs.github.com/actions/hosting-your-own-runners (svc.sh installs a LaunchAgent)
  GitLab:         brew install gitlab-runner && gitlab-runner register --executor shell --tag-list ios
Keep the GUI session logged in. Simulators do not run without one.
MSG
