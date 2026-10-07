---
name: init
description: Set up a new xcode-development workspace in the current directory for building personal iPhone and iPad apps and games with Claude Code. Use when the user runs /xcode-development:init, asks to initialize, set up, or bootstrap an Xcode or iOS workspace, or wants to start building Apple apps in an empty folder.
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/init.sh *), Bash(${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh *), Read, AskUserQuestion
---

# Initialize a workspace

Creates CLAUDE.md, `apps/`, `packages/`, `docs/`, Claude Code settings, and git
hooks in the current directory. Apps are created later with the `new-app` skill.

## Steps

1. Confirm the current directory is the intended workspace. It should be empty
   or nearly so. Do not run this inside an existing app or another project.
2. Ask for the bundle id prefix if the user has not given one. It is reverse
   DNS, for example `com.example` or `family.smith`. It must not collide with
   an App Store app the user owns.
3. Run:
   ```bash
   "${CLAUDE_PLUGIN_ROOT}/scripts/init.sh" --bundle-prefix <prefix> --name "<Workspace Name>"
   ```
   Add `--force` only if the user wants existing workspace files overwritten.
4. Run the toolchain check and show its output:
   ```bash
   "${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh" --no-xcode-setup
   ```
   If Xcode is missing, say so and stop. Xcode 27 needs an Apple Silicon Mac on
   macOS 26.6 or later, a 3 GB App Store download, and an Apple ID.
   If `xcode-select` or the license step is needed, give the user the two
   `sudo` commands from the output. Claude does not run `sudo`.
5. Tell the user about three one-time steps, each outside Claude's reach:
   - Xcode > Settings > Intelligence > Model Context Protocol > Allow External
     Agents = Always, so the `xcode` MCP server connects without prompts.
   - `export CLAUDE_CODE_PLUGIN_DIRS="$(xcrun agent plugin path --plugin-format claude 2>/dev/null)"`
     in `~/.zshrc`, so Apple's 15 Xcode skills load.
   - For device installs: add an Apple ID in Xcode > Settings > Accounts and put
     the Team ID in `~/.config/xcode-development/env` as `DEVELOPMENT_TEAM`.
6. Suggest the first app: "Say: make a new game called <Name> for <who>."

## Rules

- Never write the Team ID, bundle prefix, or any secret into the workspace.
  The env file in `~/.config/xcode-development/` holds them.
- Restart Claude Code after init so the workspace CLAUDE.md and settings load.
