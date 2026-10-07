# Decisions

Why the plugin is built the way it is. Dates are absolute. Sources in `RESEARCH.md`.

## 2026-10-06

### D1. XcodeGen generates every project
`project.yml` is tracked; `.xcodeproj` is gitignored. One YAML file the agent
can read and edit, clean diffs, Homebrew core, no account, releases in 2026.
Tuist is the alternative if Swift manifests or many modules become valuable.
Known gap: XcodeGen does not yet handle Xcode 26 `.icon` bundles, so the
template uses a classic `AppIcon.appiconset`.

### D2. Native SwiftUI, SpriteKit for 2D games
One toolchain, free signing, builds from the CLI, LLMs know the API.
SpriteKit is not deprecated (iOS 26 SDK headers checked by Apple DTS, May 2026).
SceneKit is deprecated; use RealityKit for 3D. Godot or Unity only if the kids
want cross-platform publishing or a visual editor.

### D3. iOS 26.0 minimum deployment target
Xcode 27 cannot target below iOS 17. iOS 26 + 27 cover about 91% of devices
(TelemetryDeck, Sept 2026). Family devices are current. Raise to 27 when every
family device runs it.

### D4. Swift 5 language mode, MainActor default isolation, approachable concurrency
Matches Xcode 26/27 new-project defaults. Concurrency diagnostics stay warnings,
which keeps agent-generated SpriteKit and delegate code building. Flip
`SWIFT_VERSION` to `6.0` in `project.yml` per app when its code is clean.

### D5. Swift Testing for unit tests, XCTest for UI tests
Swift Testing is Apple's default for new projects. UI automation still
requires XCTest.

### D6. SwiftLint plus swift-format, run by lefthook
swift-format ships in the Xcode toolchain and formats. SwiftLint lints with a
larger rule set. Overlapping formatting rules are disabled in `.swiftlint.yml`.
lefthook is a single Go binary; no Node or Python needed.

### D7. Independent nested repos under apps/, ignored by the workspace
Submodules have documented failures with Claude Code
tools and confuse Xcode. Each app has its own history and remote. The workspace
never tracks app code. Shared code goes in `packages/` when two apps need it.

### D8. Host-agnostic remotes
`new-app --remote github|gitlab` uses `gh` or `glab`. Default is no remote.
CI templates ship for GitHub Actions and GitLab CI; both are simulator-only.

### D9. Free Personal Team signing by default, paid path documented
7-day reinstall is acceptable for family use. `SIGNING.md`
has the upgrade path. The Team ID lives in `~/.config/xcode-development/env`, never in git.

### D10. Xcode 27 MCP bridge for simulator control, previews, and docs
`xcrun mcpbridge` (54 tools, verified locally) covers build, test, run, SwiftUI
previews, device interaction with screenshots and UI hierarchy, and semantic
documentation search. Headless `xcrun mcp-server` removes the need for an open
Xcode window. Apple's `xcode-integration` plugin (15 skills) loads
via `CLAUDE_CODE_PLUGIN_DIRS` in the shell profile. MobileBuildMCP was evaluated and dropped: redundant,
and its Homebrew install failed against the current Command Line Tools.
Revisit if a headless CI runner needs simulator UI automation without Xcode's
MCP; `npx -y mobilebuildmcp@latest mcp` is the fallback.

### D11. Simulator builds never sign
`CODE_SIGNING_ALLOWED=NO` for all simulator targets. Keeps headless Macs and
CI free of keychain problems. Only `make install-device` signs.

### D12. Per-app helper scripts are copied, not referenced
`new-app` copies `sim-run.sh`, `sim-screenshot.sh`, and `device-install.sh`
into each app's `scripts/`. Apps stay self-contained for CI and remote Macs.

### D13. Platforms
iOS and iPadOS ship first. `new-app --platform` and `templates/<platform>/`
are the extension points for macOS, watchOS, tvOS, and visionOS.
