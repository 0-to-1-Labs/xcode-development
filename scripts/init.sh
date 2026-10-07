#!/usr/bin/env bash
# Scaffold an xcode-development workspace into the current directory.
# Usage: init.sh [--bundle-prefix com.example] [--name "Family Apps"] [--no-git] [--force]
#   The workspace holds one git-ignored app repo per directory under apps/.
set -euo pipefail

PLUGIN="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="$HOME/.config/xcode-development"; ENV_FILE="$ENV_DIR/env"
PREFIX=""; NAME="$(basename "$PWD")"; NO_GIT=0; FORCE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --bundle-prefix) PREFIX="$2"; shift 2 ;;
    --name) NAME="$2"; shift 2 ;;
    --no-git) NO_GIT=1; shift ;;
    --force) FORCE=1; shift ;;
    -h|--help) sed -n '2,5p' "$0"; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done

if [ -f CLAUDE.md ] && [ "$FORCE" != "1" ]; then
  echo "CLAUDE.md already exists here. Re-run with --force to overwrite the workspace files." >&2; exit 1
fi
if [ -z "$PREFIX" ]; then
  default="local.$(id -un | tr -cd '[:alnum:]' | tr '[:upper:]' '[:lower:]')"
  read -r -p "Bundle id prefix (reverse DNS, e.g. com.example) [$default]: " PREFIX
  PREFIX="${PREFIX:-$default}"
fi
[[ "$PREFIX" =~ ^[A-Za-z][A-Za-z0-9-]*(\.[A-Za-z][A-Za-z0-9-]*)+$ ]] || { echo "Bundle prefix must look like com.example" >&2; exit 2; }

echo "Creating workspace '$NAME' in $PWD (bundle prefix $PREFIX)"
rsync -a "$PLUGIN/templates/workspace/" ./
sed -i '' -e "s/__WORKSPACE_NAME__/$NAME/g" -e "s/__BUNDLE_PREFIX__/$PREFIX/g" CLAUDE.md README.md

mkdir -p "$ENV_DIR"
if [ ! -f "$ENV_FILE" ]; then
  cat > "$ENV_FILE" <<ENV
# xcode-development settings. Not in git. Claude is told not to read this file.
# Apple Team ID from Xcode > Settings > Accounts. Needed for device installs only.
DEVELOPMENT_TEAM=
# Reverse-DNS prefix for new bundle ids.
BUNDLE_PREFIX=$PREFIX
# For new-app --remote github: owner or org. Empty = your account.
GITHUB_OWNER=
# For new-app --remote gitlab: group path. Empty = your namespace.
GITLAB_GROUP=
# For the remote-mac skill: an ssh host alias for an Apple Silicon Mac with Xcode.
REMOTE_MAC_HOST=
ENV
  echo "Wrote $ENV_FILE"
else
  grep -q '^BUNDLE_PREFIX=' "$ENV_FILE" || echo "BUNDLE_PREFIX=$PREFIX" >> "$ENV_FILE"
fi

if [ "$NO_GIT" != "1" ]; then
  [ -d .git ] || git init -q -b main
  command -v lefthook >/dev/null 2>&1 && lefthook install >/dev/null 2>&1 || true
fi

cat <<MSG

Workspace ready. Next:
  "$PLUGIN/scripts/bootstrap.sh"        # verify Xcode and tools
  "$PLUGIN/scripts/new-app.sh" MyGame --kind game --display "My Game"
Read CLAUDE.md and docs/SDLC.md.
MSG
