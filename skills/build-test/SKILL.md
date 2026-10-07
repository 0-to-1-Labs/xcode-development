---
name: build-test
description: Build, test, and lint an iOS app in apps/<Name> with make or Xcode 27 MCP tools, and diagnose xcodebuild, Swift Testing, XCTest, SwiftLint, or swift-format failures. Use when asked to build, test, run tests, check, verify, fix a build error, or before claiming any code change is done.
allowed-tools: Bash, Read, Edit, Grep, Glob
---

# Build and test

## The gate

From `apps/<Name>`: `make check` (lint, build, test). A change is done only
when it passes and you showed the summary. Never say "should work".

| Goal | make | Xcode MCP (project open or registered) |
|------|------|-----------------------------------------|
| Fast diagnostics for one file | `make build` | `XcodeRefreshCodeIssuesInFile` (seconds) |
| Build | `make build` / `make build-ipad` | `BuildProject`, then `GetBuildLog` severity=error |
| Unit tests | `make test-unit` | `GetTestList`, then `RunSomeTests` |
| Everything | `make test` / `make test-ipad` | `RunAllTests` |
| Try an API without a test | | `RunCodeSnippet` |
| Lint | `make lint`; fix with `make format` then `make lint-fix` | |
| After editing `project.yml` | `make generate` | |

Use MCP tools while iterating with Xcode state warm. Use `make` for the final
gate, CI, and remote Macs. They build into different DerivedData folders, so
mixing them is safe.

## Reading failures

- Output goes through xcbeautify. The first `error:` line is the cause. Fix that one, rerun.
- Test details: `xcrun xcresulttool get test-results summary --path build/results/iphone.xcresult`
- "No available simulator": `make sims`. Empty means `xcodebuild -downloadPlatform iOS`.
- Hung simulator: `xcrun simctl shutdown all`, retry.
- Stale state: `make clean && make generate`.
- Concurrency errors: see `swift-guidelines`. No `@unchecked Sendable`.
- New file not compiled: XcodeGen picks up everything under `Sources/`, `Tests/`, `UITests/`. Run `make generate`.
- Never edit `.pbxproj`. Change `project.yml`.
