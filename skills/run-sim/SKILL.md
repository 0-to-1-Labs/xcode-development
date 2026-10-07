---
name: run-sim
description: Launch an app in the iPhone or iPad simulator, take screenshots, read logs, render SwiftUI previews, and drive the UI (tap, swipe, type) through Xcode 27's MCP tools so Claude can see and verify what it built. Use when asked to run the app, show it, screenshot it, try it, check how it looks, verify a screen, or test interactively.
allowed-tools: Bash, Read, Agent
---

# Run and look

Two paths. Pick by situation.

## Path A: Xcode MCP tools (preferred when the `xcode` MCP server is connected)

First time per project: call `XcodeOpenWorkspace` with the absolute path to
`apps/<Name>/<Name>.xcodeproj`. macOS asks the user to approve the agent and
the folder once. If the tool answers "isn't approved", tell the user to click
**Always Allow** in the dialog, or run once:
`sudo xcrun mcp-server allow-folder <workspace path> --always`.

| Need | Tool |
|------|------|
| Snapshot a SwiftUI `#Preview` (light, dark, text sizes, orientation) | `RenderPreview` |
| Install and launch on a simulator | `DeviceInteractionStartWorkspaceSession` then `DeviceInteractionInstallAndRun` |
| Tap, swipe, type, and get a screenshot plus UI hierarchy | `DeviceInteractionSynthesize` (use hierarchy hit points, not guesses) |
| Finish | `DeviceInteractionEndSession` (always; sessions are expensive) |
| App logs | `GetConsoleOutput` with a regex filter |
| Pick the device | `XcodeListRunDestinations`, `XcodeSwitchRunDestination` by displayTitle |

For a full verification pass after a UI change, run Apple's `device-interaction`
skill as a subagent (available when `CLAUDE_CODE_PLUGIN_DIRS` is exported):

```
Agent: subagent_type general-purpose
prompt: "Using the device-interaction skill, verify <feature> on apps/<Name>.
Launch, screenshot, read the hierarchy, tap through <flow>, report UI defects."
```

Check iPhone and iPad for every layout change.

## Path B: Makefile (headless, CI, remote Macs, or when MCP is unavailable)

From `apps/<Name>`:

```bash
make run              # newest iPhone simulator
make run-ipad         # newest iPad simulator
make screenshot       # build/screenshots/<timestamp>-<device>.png, then Read it
make screenshot-ipad
make sims             # which simulators the Makefile picked
xcrun simctl ui booted appearance dark
xcrun simctl ui booted content_size extra-large
xcrun simctl spawn booted log stream --predicate 'subsystem == "<bundle id>"'
```

Always Read the screenshot PNG. Report what you saw, not what you expected.

## Rules

- Install and launch via the tools or `make`, never by hand, so the build is fresh.
- `make` builds into `build/DerivedData`; Xcode builds into its own. They do not collide.
- Shut extra simulators down: `xcrun simctl shutdown all`. Never `erase all` or `delete all`.
