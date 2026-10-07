---
name: new-app
description: Scaffold a new iPhone/iPad app or SpriteKit game under apps/<Name> in an xcode-development workspace, with tests, lint, hooks, Makefile, and optional GitHub or GitLab remote. Use when the user wants to start a new app, game, or project, or says "create", "new app", "new game", "scaffold", or "start building <something>".
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/new-app.sh *), Bash(make *), Bash(git *), Read, Write, Edit, AskUserQuestion
---

# New app

Creates `apps/<Name>` as its own git repository from the plugin template.
Run from the workspace root (the directory with `apps/` and `CLAUDE.md`).

## Steps

1. Get three facts. Ask only for the ones missing from the request:
   - **Name**: PascalCase, letters and digits, e.g. `BubblePop`.
   - **Kind**: `app` (SwiftUI utility) or `game` (SwiftUI + SpriteKit).
     Pick `game` if the user says game, play, score, level, or sprite.
   - **Display name**: what shows under the icon. Default to the Name with spaces.
2. Run:
   ```bash
   "${CLAUDE_PLUGIN_ROOT}/scripts/new-app.sh" <Name> --kind <app|game> --display "<Display Name>"
   ```
   Add `--remote github` or `--remote gitlab` only if the user asked for a
   remote. That creates a private repo with `gh` or `glab` and pushes `main`.
   `--ci github|gitlab` adds a CI file without creating a remote.
   `--platform` defaults to `ios`; other platforms are not available yet.
3. Fill `apps/<Name>/docs/SPEC.md` with the user. One page. Who uses it, what
   it does, what "done" looks like. For a kids' game, the youngest player sets
   the content bar.
4. Verify: `cd apps/<Name> && make check`. Then `make run` and `make screenshot`,
   and Read the screenshot. Report its path.
5. Register with Xcode: `make xcode-open`, or call `XcodeOpenWorkspace` with the
   absolute `.xcodeproj` path. The first time, the user approves the folder in a
   macOS dialog (Always Allow).
6. Commit the spec inside the app repo: `git commit -am "docs: write spec"`.

## Rules

- Never create an app by hand. Always use the script so every app matches.
- Do not edit the plugin's template for one app's needs. Change the app.
- The workspace `.gitignore` excludes `apps/*`. Do not `git add` apps from the
  workspace root.
