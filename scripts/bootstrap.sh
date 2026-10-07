#!/usr/bin/env bash
# Idempotent environment bootstrap for xcode-development.
# Safe to re-run. Installs Homebrew tools, checks Xcode, writes the env file.
# Usage: scripts/bootstrap.sh [--no-xcode-setup]
set -euo pipefail

NO_XCODE_SETUP=0
for a in "$@"; do
  case "$a" in
    --no-xcode-setup) NO_XCODE_SETUP=1 ;;
  esac
done

ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$*"; }
fail() { printf '  \033[31m✗\033[0m %s\n' "$*"; }
hdr()  { printf '\n\033[1m%s\033[0m\n' "$*"; }

hdr "Machine"
echo "  $(sw_vers -productName) $(sw_vers -productVersion), $(sysctl -n machdep.cpu.brand_string), $(( $(sysctl -n hw.memsize) / 1073741824 )) GB"
if [ "$(uname -m)" != "arm64" ]; then fail "Xcode 27 needs Apple Silicon. This is $(uname -m)."; exit 1; fi

hdr "Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  fail "Homebrew missing. Install from https://brew.sh then re-run."; exit 1
fi
ok "$(brew --version | head -1)"

# name:check-command
FORMULAE=(
  xcodegen
  swiftlint
  xcbeautify
  swift-format
  lefthook
  shellcheck
  jq
  glab
)
hdr "Homebrew formulae"
missing=()
for f in "${FORMULAE[@]}"; do
  if brew list --formula "$f" >/dev/null 2>&1; then ok "$f $(brew list --versions "$f" | awk '{print $2}')"; else missing+=("$f"); fi
done
if [ ${#missing[@]} -gt 0 ]; then
  echo "  Installing: ${missing[*]}"
  brew install "${missing[@]}"
fi

hdr "Env file"
ENV_DIR="$HOME/.config/xcode-development"; ENV_FILE="$ENV_DIR/env"
mkdir -p "$ENV_DIR"
if [ ! -f "$ENV_FILE" ]; then
  cat > "$ENV_FILE" <<'ENV'
# xcode-development settings. Not in git. Claude is told not to read this file.
# Apple Personal Team ID from Xcode > Settings > Accounts. Needed for device installs only.
DEVELOPMENT_TEAM=
# Reverse-DNS prefix for bundle ids.
BUNDLE_PREFIX=
# For new-app --remote github / gitlab. Empty = your own account or namespace.
GITHUB_OWNER=
GITLAB_GROUP=
# For the remote-mac skill: ssh host alias of an Apple Silicon Mac with Xcode.
REMOTE_MAC_HOST=
ENV
  ok "Wrote $ENV_FILE (fill in DEVELOPMENT_TEAM for device installs)"
else
  ok "$ENV_FILE exists"
fi

hdr "Xcode"
XCODE_APP="/Applications/Xcode.app"
if [ ! -d "$XCODE_APP" ]; then
  fail "Xcode.app not found."
  if [ -d /Applications/Xcode.appdownload ]; then warn "An App Store download is in progress (/Applications/Xcode.appdownload). Wait for it, then re-run."; fi
  echo "  Install options:"
  echo "    App Store:  open 'macappstore://apps.apple.com/app/id497799835'"
  echo "    xcodes CLI: brew install xcodesorg/made/xcodes aria2 && xcodes install --latest --experimental-unxip"
  echo "  Re-run this script after Xcode is installed."
  exit 0
fi
ok "Found $XCODE_APP"

if [ "$NO_XCODE_SETUP" = "1" ]; then warn "Skipping xcode-select, license, and platform download (--no-xcode-setup)"; exit 0; fi

current=$(xcode-select -p 2>/dev/null || true)
if [ "$current" != "$XCODE_APP/Contents/Developer" ]; then
  echo "  Pointing xcode-select at Xcode.app (needs sudo)"
  sudo xcode-select -s "$XCODE_APP"
fi
ok "xcode-select: $(xcode-select -p)"

if ! xcodebuild -checkFirstLaunchStatus >/dev/null 2>&1; then
  echo "  Accepting license and running first launch (needs sudo)"
  sudo xcodebuild -license accept
  sudo xcodebuild -runFirstLaunch
fi
ok "$(xcodebuild -version | tr '\n' ' ')"

if ! xcrun simctl list runtimes 2>/dev/null | grep -q 'iOS'; then
  echo "  Downloading the iOS simulator platform (several GB, one time)"
  xcodebuild -downloadPlatform iOS
fi
ok "iOS runtimes: $(xcrun simctl list runtimes | grep iOS | sed 's/ (.*//' | tr '\n' ',' | sed 's/,$//')"

hdr "Xcode agent integration"
if xcrun mcp-server status >/dev/null 2>&1; then
  xcrun mcp-server status 2>/dev/null | sed 's/^/  /'
else
  warn "xcrun mcp-server not available (needs Xcode 27+)"
fi
if plugin=$(xcrun agent plugin path --plugin-format claude 2>/dev/null | tail -1) && [ -d "$plugin" ]; then
  ok "Apple skills plugin: $plugin ($(find "$plugin/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ') skills)"
  if [ -z "${CLAUDE_CODE_PLUGIN_DIRS:-}" ]; then
    warn "CLAUDE_CODE_PLUGIN_DIRS is not set. Add to ~/.zshrc: export CLAUDE_CODE_PLUGIN_DIRS=\"$(xcrun agent plugin path --plugin-format claude 2>/dev/null)\""
  else
    ok "CLAUDE_CODE_PLUGIN_DIRS is set"
  fi
else
  warn "Apple skills plugin not found. Open Xcode once, then re-run."
fi
if [ -f "$HOME/Library/Group Containers/group.com.apple.dt.Xcode.SecureSettingsContainer/CodingAssistant/HeadlessPermissions/mcp-server.json" ]; then
  ok "External agent access: $(cat "$HOME/Library/Group Containers/group.com.apple.dt.Xcode.SecureSettingsContainer/CodingAssistant/HeadlessPermissions/mcp-server.json")"
else
  warn "External agent access not configured. Xcode > Settings > Intelligence > Model Context Protocol > Always."
fi

hdr "Versions"
printf '  %-14s %s\n' xcodebuild "$(xcodebuild -version | head -1)" \
  swift "$(swift --version 2>&1 | head -1 | sed 's/.*Swift version /Swift /;s/ (.*//')" \
  xcodegen "$(xcodegen --version)" swiftlint "$(swiftlint version)" \
  xcbeautify "$(xcbeautify --version)" swift-format "$(swift format --version 2>/dev/null || echo n/a)" \
  lefthook "$(lefthook version)" glab "$(glab --version | awk '{print $2}')"

echo
ok "Bootstrap complete."
