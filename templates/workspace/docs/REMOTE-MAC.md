# Building on a remote Mac

Use another Mac for long test runs, an iPad matrix, or CI. Set its ssh alias
as `REMOTE_MAC_HOST` in `~/.config/xcode-development/env`, with key-based auth.

## Requirements on the remote Mac

| Need | Why |
|------|-----|
| Apple Silicon, macOS 26.6+ | Xcode 27 does not run on Intel or older macOS. |
| Xcode 27 installed, license accepted | `xcodebuild` |
| A logged-in GUI session (auto-login, never sleep) | Simulators do not run from a bare ssh session. |
| Homebrew: xcodegen, swiftlint, xcbeautify, swift-format, lefthook, jq | The Makefile |

Check and prepare it with the `remote-mac` skill, which runs
`scripts/remote-mac/setup.sh` from the plugin. It asks before large downloads.

## Offload a run

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/remote-mac/remote-build.sh" <AppName> test-ipad
```

It rsyncs the app (no build output, no `.git`, no local signing config), runs
the make target, and copies `build/results` back to `apps/<AppName>/build/remote-<host>/`.
Device installs always happen on the Mac the device is plugged into.

## CI on push

Each app can ship a GitHub Actions workflow or a GitLab CI file
(`new-app --ci github|gitlab`). Both run simulator-only jobs with signing
disabled. Register a runner that runs as the logged-in GUI user, not inside
Docker, and keep that session logged in.

## Gotchas

- Signing for device builds over ssh needs the login keychain unlocked.
  Simulator builds need no signing, which is why the Makefile disables it.
- Do not run two `xcodebuild` processes that share DerivedData at once.
- The first build after an Xcode update is slow while the module cache fills.
