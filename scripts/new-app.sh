#!/usr/bin/env bash
# Scaffold a new app under apps/<Name> in the current workspace.
# Usage: new-app.sh <Name> [--kind app|game] [--platform ios] [--display "Name"]
#                   [--remote github|gitlab|none] [--ci github|gitlab|none]
#   Name       PascalCase, letters and digits (targets and bundle id)
#   --kind     app (SwiftUI) or game (SwiftUI + SpriteKit). Default: app
#   --platform ios today. macos, watchos, tvos, visionos are reserved.
#   --display  Human name under the icon. Default: Name
#   --remote   Create a remote repo with gh or glab and push. Default: none
#   --ci       Which CI file to include. Default: same as --remote
set -euo pipefail

PLUGIN="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$HOME/.config/xcode-development/env"
NAME="${1:?Usage: new-app.sh <Name> [--kind app|game] [--display \"Name\"] [--remote github|gitlab]}"; shift
KIND="app"; PLATFORM="ios"; DISPLAY="$NAME"; REMOTE="none"; CI=""
while [ $# -gt 0 ]; do
  case "$1" in
    --kind) KIND="$2"; shift 2 ;;
    --platform) PLATFORM="$2"; shift 2 ;;
    --display) DISPLAY="$2"; shift 2 ;;
    --remote) REMOTE="$2"; shift 2 ;;
    --ci) CI="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done
CI="${CI:-$REMOTE}"

[[ "$NAME" =~ ^[A-Z][A-Za-z0-9]*$ ]] || { echo "Name must be PascalCase letters/digits, e.g. BubblePop" >&2; exit 2; }
[[ "$KIND" == "app" || "$KIND" == "game" ]] || { echo "--kind must be app or game" >&2; exit 2; }
[[ "$REMOTE" =~ ^(github|gitlab|none)$ ]] || { echo "--remote must be github, gitlab, or none" >&2; exit 2; }
[[ "$CI" =~ ^(github|gitlab|none)$ ]] || { echo "--ci must be github, gitlab, or none" >&2; exit 2; }
TEMPLATE="$PLUGIN/templates/$PLATFORM"
[ -d "$TEMPLATE" ] || { avail=""; for d in "$PLUGIN"/templates/*/; do n=$(basename "$d"); [ "$n" != workspace ] && avail="$avail $n"; done; echo "No template for platform '$PLATFORM' yet. Available:$avail" >&2; exit 2; }
[ -d apps ] || { echo "Run from a workspace root (no apps/ directory here). Create one with init.sh." >&2; exit 1; }
DEST="$PWD/apps/$NAME"
[ ! -e "$DEST" ] || { echo "$DEST already exists" >&2; exit 1; }

BUNDLE_PREFIX=""
[ -f "$ENV_FILE" ] && BUNDLE_PREFIX=$(grep '^BUNDLE_PREFIX=' "$ENV_FILE" | cut -d= -f2- || true)
[ -n "$BUNDLE_PREFIX" ] || { echo "BUNDLE_PREFIX is not set in $ENV_FILE. Run init.sh first." >&2; exit 1; }

echo "Creating $DEST (platform=$PLATFORM kind=$KIND display='$DISPLAY' bundle=$BUNDLE_PREFIX.$NAME)"
mkdir -p "$DEST"
rsync -a --exclude 'game' --exclude 'ci' --exclude 'Configs/Local.xcconfig' "$TEMPLATE/" "$DEST/"
mkdir -p "$DEST/scripts"; cp "$PLUGIN/scripts/app/"*.sh "$DEST/scripts/"; chmod +x "$DEST/scripts/"*.sh

if [ "$KIND" = "game" ]; then
  rm -f "$DEST/Sources/Features/CounterModel.swift" "$DEST/Tests/CounterModelTests.swift"
  mkdir -p "$DEST/Sources/Game"
  cp "$TEMPLATE/game/Sources/Game/"*.swift "$DEST/Sources/Game/"
  cp "$TEMPLATE/game/Tests/"*.swift "$DEST/Tests/"
  cp "$TEMPLATE/game/UITests/LaunchUITests.swift" "$DEST/UITests/LaunchUITests.swift"
  cp "$TEMPLATE/game/ContentView.swift" "$DEST/Sources/Features/ContentView.swift"
fi
case "$CI" in
  github) mkdir -p "$DEST/.github/workflows"; cp "$TEMPLATE/ci/github-actions.yml" "$DEST/.github/workflows/ci.yml" ;;
  gitlab) cp "$TEMPLATE/ci/gitlab-ci.yml" "$DEST/.gitlab-ci.yml" ;;
esac

find "$DEST" -depth -name '*__APP_NAME__*' | while read -r f; do mv "$f" "${f//__APP_NAME__/$NAME}"; done
find "$DEST" -type f \( -name '*.swift' -o -name '*.yml' -o -name '*.yaml' -o -name '*.md' -o -name 'Makefile' -o -name '*.xcconfig*' -o -name '*.json' \) -print0 \
  | xargs -0 sed -i '' -e "s/__APP_NAME__/$NAME/g" -e "s/__BUNDLE_PREFIX__/$BUNDLE_PREFIX/g" -e "s/__DISPLAY_NAME__/$DISPLAY/g"

cd "$DEST"
git init -q -b main
command -v lefthook >/dev/null 2>&1 && lefthook install >/dev/null 2>&1 || true
command -v xcodegen >/dev/null 2>&1 && XCODE_DEV_ENV="$ENV_FILE" make generate >/dev/null || true
git add -A
git -c commit.gpgsign=false commit -q -m "chore: scaffold $NAME from xcode-development template ($PLATFORM $KIND)"
echo "Initialized git repo with first commit."

slug=$(echo "$NAME" | sed -E 's/([a-z0-9])([A-Z])/\1-\2/g' | tr '[:upper:]' '[:lower:]')
case "$REMOTE" in
  github)
    owner=$(grep '^GITHUB_OWNER=' "$ENV_FILE" | cut -d= -f2- || true)
    path="${owner:+$owner/}$slug"
    echo "Creating GitHub repo $path (private)"
    gh repo create "$path" --private --source . --remote origin --push --description "$DISPLAY (xcode-development)" ;;
  gitlab)
    group=$(grep '^GITLAB_GROUP=' "$ENV_FILE" | cut -d= -f2- || true)
    path="${group:+$group/}$slug"
    echo "Creating GitLab repo $path (private)"
    glab repo create "$path" --private --description "$DISPLAY (xcode-development)" --remoteName origin -y
    git push -u origin main ;;
esac

cat <<MSG

Next (from $DEST):
  make run          # iPhone simulator
  make run-ipad     # iPad simulator
  make check        # lint + build + test
Edit docs/SPEC.md first. Then build features with tests.
MSG
