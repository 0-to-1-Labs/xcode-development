# Research log (2026-10-06)

Facts that shaped the setup, with sources. "Verified" means read in the source.

## Xcode, SDKs, Swift
- Xcode 27.0 is current stable (2026-09-14). Swift 6.4. SDKs for iOS/iPadOS 27. Requires macOS 26.6+ on Apple Silicon. Deployment floor iOS 17. Verified: https://developer.apple.com/documentation/xcode-release-notes/xcode-27-release-notes , https://developer.apple.com/support/xcode/
- Xcode 27.1 RC and 27.2 beta exist. Verified: https://developer.apple.com/documentation/xcode-release-notes
- App Store download is 3.1 GB; simulator runtimes are separate. Verified: https://apps.apple.com/us/app/xcode/id497799835
- `xcodes` CLI 2.1.0 (2026-09-14) still works for scripted installs. Verified: https://github.com/XcodesOrg/xcodes/releases
- iOS 27 SDK makes the UIScene lifecycle mandatory. SwiftUI `App` is fine. Verified: https://dev.classmethod.jp/en/articles/xcode-27-ios-27-beta-release-notes/

## Adoption
- iOS 26 on 79% of iPhones (Apple, June 2026). iOS 27 16%, iOS 26 75% (TelemetryDeck, Sept 2026). Verified: https://developer.apple.com/support/app-store/ , https://telemetrydeck.com/survey/apple/iOS/majorSystemVersions/

## Signing
- Personal Team: 10 App IDs, 3 devices, 3 apps per device, 7-day profiles. Verified: https://developer.apple.com/support/compare-memberships/
- Push and iCloud unavailable to Personal Teams. Verified: https://developer.apple.com/forums/thread/811929
- Developer Mode required on iOS 16+. Verified: https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device
- Paid program: 100 devices per family per year, TestFlight. Verified: https://developer.apple.com/help/account/devices/devices-overview/
- `ios-deploy` fails on iOS 17+; use `xcrun devicectl`. Verified: https://github.com/react-native-community/cli/issues/2610

## Frameworks
- SpriteKit not deprecated in iOS 26 SDK. Verified: https://developer.apple.com/forums/thread/826562
- SpriteKit frame-rate regression on iOS 26.x, open bug. Verified: https://developer.apple.com/forums/thread/816719
- SceneKit deprecated at WWDC25; RealityKit recommended. Verified: https://developer.apple.com/videos/play/wwdc2025/288/
- `SpriteView` for SwiftUI hosting. Verified: https://developer.apple.com/documentation/spritekit/spriteview
- Xcode 26 new-project defaults: Swift 5 mode, MainActor default isolation, approachable concurrency. Verified: https://www.donnywals.com/setting-default-actor-isolation-in-xcode-26/ , https://developer.apple.com/forums/thread/791600
- Liquid Glass adoption guidance. Verified: https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass
- Apple ships agent guidance docs inside Xcode (IDEIntelligenceChat AdditionalDocumentation). Verified: https://www.ameyalambat.com/blog/swiftui-skills

## Tooling
- XcodeGen 2.46.0 (2026-07-16), Homebrew core. Open Xcode 26 issues #1620, #1556. Verified: https://github.com/yonaskolb/XcodeGen
- SwiftPM cannot produce an iOS .app bundle. Verified: https://forums.swift.org/t/how-to-build-sample-app-in-swiftpm/71984
- MobileBuildMCP (was XcodeBuildMCP), v2.7.1, `brew install mobilebuildmcp`. Verified: https://github.com/getsentry/MobileBuildMCP
- Apple Xcode MCP via `xcrun mcpbridge`, Xcode GUI required. Verified: https://developer.apple.com/documentation/xcode/giving-external-agents-access-to-xcode
- SwiftLint 0.65.1; swift-format 604.0.0 bundled as `swift format`. Verified: https://github.com/realm/SwiftLint , https://github.com/swiftlang/swift-format
- xcbeautify recommended over xcpretty. Verified: https://docs.fastlane.tools/best-practices/xcodebuild-formatters/
- lefthook 2.1.x, single binary. Verified: https://github.com/evilmartians/lefthook
- Swift Testing default for unit tests; UI tests remain XCTest. Verified: https://developer.apple.com/documentation/xcode/adding-tests-to-your-xcode-project , https://developer.apple.com/videos/play/wwdc2025/344/

## Xcode 27 agent features
- External agent access and `claude mcp add --transport stdio xcode -- xcrun mcpbridge`. Verified: https://developer.apple.com/documentation/xcode/giving-external-agents-access-to-xcode
- Agent config, plugins, ACP, AGENTS.md. Verified: https://developer.apple.com/documentation/xcode/extending-and-customizing-agents , https://developer.apple.com/documentation/xcode/setting-up-coding-intelligence , https://developer.apple.com/forums/thread/833246
- Headless `mcp-server`, security layer, lldb-mcp, simctl reboot. Verified: https://developer.apple.com/documentation/xcode-release-notes/xcode-27-release-notes
- Headless mode walkthrough with Claude Code. Verified: https://mehmetbaykar.com/posts/how-to-run-xcode-27-mcp-server-headless-with-claude-code/
- Exported skills and plugin for Claude Code. Verified: https://dev.classmethod.jp/en/articles/xcode-agent-skills-claude-code/ , https://www.avanderlee.com/ai-development/using-xcode-27s-agent-skills-in-claude-codex-and-cursor/
- xcodebuild and Xcode do not share incremental build state; separate DerivedData. Verified: https://dev.to/isekai_kara_no_dev/-use-xcode-mcp-instead-of-xcodebuild-to-save-disk-space-and-time-in-agentic-ios-development-2m4j
- Security guidance from Apple engineers on agents. Verified: https://developer.apple.com/forums/thread/828029
- WWDC26 "Xcode, agents, and you" (259) and "Speedrun your game port with agentic coding" (357). Verified: https://developer.apple.com/videos/play/wwdc2026/259/ , https://developer.apple.com/videos/play/wwdc2026/357/
- Game Porting Toolkit 4 Claude plugin: Metal/D3D porting skills, not relevant to SpriteKit. Verified: https://github.com/apple/game-porting-toolkit
- Local verification 2026-10-06: `tools/list` returned 54 tools from server "xcode-tools" v25317; `xcrun agent plugin path --plugin-format claude` yielded 15 skills; `xcrun mcp-server status` reported Permission enabled, running.

## Remote Macs
- Simulator needs a logged-in GUI session. Verified: https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/testing_with_xcode/chapters/08-automation.html
- Simulator builds with signing disabled avoid keychain issues. Verified: https://docs.codemagic.io/yaml-code-signing/ios-simulator-builds/
- Keychain over SSH sequence. Verified: https://developer.apple.com/forums/thread/690665

## Git strategy
- Claude Code tool issues with submodules. Verified: https://claudeissues.com/issue/21994-bug-git-submodule-add-silently-fails-via-bash-tool
- Xcode has no submodule support. Verified: https://developer.apple.com/forums/thread/681752

## Privacy
- COPPA 2025 amendments. Verified: https://www.whitecase.com/insight-alert/unpacking-ftcs-coppa-amendments-what-you-need-know
- Apple "Helping Protect Kids Online" 2025. Verified: https://developer.apple.com/support/downloads/Helping-Protect-Kids-Online-2025.pdf
