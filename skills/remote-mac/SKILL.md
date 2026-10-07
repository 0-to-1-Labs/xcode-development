---
name: remote-mac
description: Run an app's build or test suite on another Mac over ssh, or check and prepare that Mac as an Xcode build host or CI runner. Use when asked to offload, run remotely, use a Mac mini or build server, run a long test matrix elsewhere, or set up CI for iOS.
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/remote-mac/*), Bash(ssh *), Read
---

# Remote Mac

The remote Mac must be Apple Silicon on macOS 26.6+ with Xcode 27 and a
logged-in GUI session (simulators need one). Its ssh alias goes in
`~/.config/xcode-development/env` as `REMOTE_MAC_HOST`. Claude cannot read
that file; pass the host explicitly if the user names it.

## Check readiness

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/remote-mac/setup.sh" [host]
```
It reports architecture, macOS, Xcode, and GUI session, installs the Homebrew
tools, and prints the `sudo` steps for the user. It asks before big downloads.

## Offload a run

From the workspace root:
```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/remote-mac/remote-build.sh" <AppName> <make target> [host]
```
Use it for the iPad matrix while iPhone runs locally, long UI suites, or
when the local Mac is busy. Results land in `apps/<AppName>/build/remote-<host>/`.
Device installs always happen on the Mac the device is plugged into.

## CI on push

`new-app --ci github|gitlab` adds a simulator-only pipeline. Register a runner
that runs as the logged-in GUI user, not in Docker. Details in `docs/REMOTE-MAC.md`.
