#!/usr/bin/env bash
# After Claude writes or edits a .swift file, run swift-format lint and SwiftLint
# on that one file and surface problems. Advisory only: never blocks.
set +e
input=$(cat)
file=$(echo "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -n "$file" ] || exit 0
case "$file" in *.swift) ;; *) exit 0 ;; esac
[ -f "$file" ] || exit 0

out=""
if command -v swift >/dev/null 2>&1 && [ -d /Applications/Xcode.app ]; then
  r=$(swift format lint --strict "$file" 2>&1 | head -20); [ -n "$r" ] && out="$out$r\n"
fi
if command -v swiftlint >/dev/null 2>&1; then
  # Run from the app dir so .swiftlint.yml applies.
  dir=$(dirname "$file"); while [ "$dir" != "/" ] && [ ! -f "$dir/.swiftlint.yml" ]; do dir=$(dirname "$dir"); done
  if [ -f "$dir/.swiftlint.yml" ]; then
    r=$(cd "$dir" && swiftlint lint --quiet "$file" 2>/dev/null | head -20); [ -n "$r" ] && out="$out$r\n"
  fi
fi
if [ -n "$out" ]; then
  printf 'Lint findings for %s (fix before finishing):\n%b' "$file" "$out"
fi
exit 0
