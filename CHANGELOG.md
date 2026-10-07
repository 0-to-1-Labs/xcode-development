# Changelog

## v1.0.0 — 2026-10-06

First release.

- `/xcode-development:init` scaffolds a workspace: CLAUDE.md, `apps/`,
  `packages/`, docs, Claude Code settings, and git hooks.
- `new-app` creates an iPhone/iPad app (`--kind app`) or SpriteKit game
  (`--kind game`) from an XcodeGen template with Swift Testing, XCTest UI
  tests, SwiftLint, swift-format, lefthook, a Makefile, and optional GitHub
  or GitLab remote and CI.
- Skills: `build-test`, `run-sim`, `install-device`, `feature-tdd`,
  `app-review`, `remote-mac`, `swift-guidelines`.
- Hooks: session status line, a guard that blocks edits to generated
  `.pbxproj` files and signing secrets, and advisory lint on every Swift edit.
- Xcode 27 MCP server (`xcrun mcpbridge`) wired in; docs for headless mode
  and Apple's `xcode-integration` skills plugin.
- Platforms: iOS and iPadOS. macOS, watchOS, tvOS, and visionOS templates are
  planned; `new-app --platform` is reserved for them.
