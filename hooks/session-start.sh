#!/usr/bin/env bash
# Prints a short status line at session start. Never fails the session.
set +e
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
echo "xcode-development | branch: $(git branch --show-current 2>/dev/null || echo '-')"
if [ -d /Applications/Xcode.app ]; then
  echo "Xcode: $(xcodebuild -version 2>/dev/null | tr '\n' ' ')"
else
  echo "Xcode: NOT INSTALLED (install Xcode 27, then run the init skill bootstrap step)"
fi
apps=$(find apps -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | tr '\n' ' ')
echo "Apps: ${apps:-none yet}"
booted=$(xcrun simctl list devices booted 2>/dev/null | grep -E 'iPhone|iPad' | sed 's/^ *//' | cut -d'(' -f1 | tr '\n' ',' | sed 's/,$//')
[ -n "$booted" ] && echo "Booted simulators: $booted"
exit 0
