# __WORKSPACE_NAME__

Personal iPhone and iPad apps and games, built with Claude Code and the
`xcode-development` plugin. Not for the App Store unless you choose that later.
Each app lives in `apps/<Name>/` as its own git repo. This workspace holds the
shared rules. Always start Claude Code from this directory.

## Layout

| Path | What |
|------|------|
| `apps/<Name>/` | One app per directory. Own git repo. Ignored by this workspace. |
| `packages/` | Shared Swift packages, only when two apps need the same code. |
| `docs/` | SDLC, SIGNING, PRIVACY, XCODE-AGENTS, REMOTE-MAC. |

Templates, scripts, and skills come from the plugin. Skills: `new-app`,
`build-test`, `run-sim`, `install-device`, `feature-tdd`, `app-review`,
`remote-mac`, `swift-guidelines`.

## Commands

| Task | Where | Command |
|------|-------|---------|
| Check the toolchain | workspace | `${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh` (ask for the `bootstrap` step) |
| New app or game | workspace | `new-app` skill, or `"${CLAUDE_PLUGIN_ROOT}/scripts/new-app.sh" <Name> --kind app\|game --display "Name"` |
| Build / test / lint gate | `apps/<Name>` | `make check` |
| Build, test, unit only, UI only | `apps/<Name>` | `make build`, `make test`, `make test-unit`, `make test-ui` |
| iPad | `apps/<Name>` | `make build-ipad`, `make test-ipad`, `make run-ipad` |
| Run and look | `apps/<Name>` | `make run`, `make screenshot` (then Read the PNG) |
| Regenerate after `project.yml` edit | `apps/<Name>` | `make generate` |
| Format / lint fix | `apps/<Name>` | `make format`, `make lint-fix` |
| Install on a device | `apps/<Name>` | `make install-device` |
| Offload to a remote Mac | workspace | `remote-mac` skill |

## Stack

Xcode 27, Swift 6.4, iOS 26.0 minimum, SwiftUI, SpriteKit for 2D games,
XcodeGen (`project.yml` is the source of truth; `.xcodeproj` is generated and
ignored), Swift Testing for unit tests, XCTest for UI tests, SwiftLint +
swift-format via lefthook, xcbeautify for build output, Xcode 27 MCP tools for
simulator control and docs, Conventional Commits. Bundle prefix: `__BUNDLE_PREFIX__`.

## Rules for Claude

1. **Done means `make check` passed** and you showed the output. Then `make run`
   and `make screenshot`, and look at the screenshot. Never say "should work".
2. **Test first.** Every behavior change gets a Swift Testing test. Logic lives
   in `@Observable` models, not views.
3. **Both device families.** Check iPhone and iPad for any layout change.
4. **Privacy first** (`docs/PRIVACY.md`): no network, analytics, ads, SDKs,
   accounts, external links, or permission strings. Ask before any of these.
5. **Git per app.** Run git commands from inside `apps/<Name>`. Never `git add`
   app files from the workspace root. No submodules. No force push.
6. **Never touch signing or secrets.** Do not read or write
   `~/.config/xcode-development/env`, `Configs/Local.xcconfig`, `.env`, keys,
   or profiles. Do not run `security`, `sudo`, or change `xcode-select`.
7. **Use the scripts.** Scaffold with the `new-app` skill, run with `make`. Do
   not hand-roll `xcodebuild` lines unless debugging the Makefile itself.
8. **Modern APIs only.** Follow the `swift-guidelines` skill. No deprecated
   SwiftUI APIs, no `@unchecked Sendable`, no force unwraps.
9. **Small commits, Conventional Commits.** `feat(game): add double jump`.
10. **Ask when the design is the user's call**: game rules, art style,
    difficulty, who it is for. Do not guess at fun.

## Xcode and agents

The plugin connects the `xcode` MCP server (`xcrun mcpbridge`). Apple's own
`xcode-integration` skills load when `CLAUDE_CODE_PLUGIN_DIRS` is exported in
the shell profile (see `docs/XCODE-AGENTS.md`).

- First time per app: `XcodeOpenWorkspace` on `apps/<Name>/<Name>.xcodeproj`
  (or `make xcode-open`). The user approves the folder once.
- Iterate with `XcodeRefreshCodeIssuesInFile`, `BuildProject`, `RunSomeTests`,
  `RenderPreview`. Finish with `make check`.
- Verify UI with Apple's `device-interaction` skill as a subagent, then
  `DeviceInteractionEndSession`.
- Look up any Apple API with `DocumentationSearch` before web search.
- Never edit `.pbxproj` (a hook blocks it). Change `project.yml`.

## Signing

Free Personal Team by default: 7-day profiles, 3 apps per device, no iCloud
or Game Center. Reinstall weekly with `make install-device`. Paid path in
`docs/SIGNING.md`.
