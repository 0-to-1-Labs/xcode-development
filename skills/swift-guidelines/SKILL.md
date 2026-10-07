---
name: swift-guidelines
description: Modern Swift 6.4, SwiftUI, and SpriteKit conventions for iOS 26/27 and the APIs to avoid. Load before writing or editing any .swift file, SwiftUI view, @Observable model, SpriteKit scene, or when a Swift concurrency or deprecation warning appears.
allowed-tools: Read, Grep, Glob
---

# Swift guidelines (iOS 26 minimum, Xcode 27, Swift 6.4)

## Use these

| Instead of | Use |
|-----------|-----|
| `ObservableObject`, `@Published`, `@StateObject`, `@ObservedObject` | `@Observable` class, `@State` to own it, `@Bindable` for bindings, `@Environment(Type.self)` |
| `NavigationView` | `NavigationStack` |
| `.foregroundColor` | `.foregroundStyle` |
| `.cornerRadius(r)` | `.clipShape(.rect(cornerRadius: r))` |
| `.onChange(of:) { new in }` | `.onChange(of: value) { old, new in }` |
| `@Environment(\.presentationMode)` | `@Environment(\.dismiss)` |
| `PreviewProvider` | `#Preview { }` |
| `.tabItem` | `Tab("Name", systemImage:) { }` |
| XCTest for unit tests | Swift Testing: `@Test`, `#expect`, `#require` |
| `DispatchQueue.main.async` | `@MainActor` context or `Task { @MainActor in }` |
| `Timer.scheduledTimer` in views | `TimelineView` or `.task { for await _ in ... }` |

UI tests stay on XCTest (`XCUIApplication`). Swift Testing has no UI automation.

## Concurrency, as configured in project.yml

- Swift 5 language mode, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`,
  approachable concurrency on. Most code is main-actor by default.
- CPU-heavy work: mark the function `@concurrent` (Swift 6.2+) or use
  `Task.detached`. A bare `nonisolated` now runs on the caller's actor.
- Never add `@unchecked Sendable` or `nonisolated(unsafe)` to silence a warning.
- Do not add `@MainActor` to every type. It is already the default.

## SwiftUI

- iOS 26 Liquid Glass applies automatically. Do not put custom backgrounds on
  toolbars, tab bars, or sheets. Use `.glassEffect()` sparingly. Guard with
  `if #available(iOS 26, *)` only if the deployment target is below 26.
- Views are small structs. Logic lives in `@Observable` models with tests.
- iPad: use `NavigationSplitView` for list-detail, `ViewThatFits` and size
  classes for width-dependent layout. Test landscape.
- Kids: min 60-point tap targets, `.font(.largeTitle)` or bigger for key text,
  SF Symbols plus words, haptics via `.sensoryFeedback`.
- Accessibility identifiers on anything a UI test will touch.

## SpriteKit

- Host with `SpriteView(scene:preferredFramesPerSecond: 60)` inside SwiftUI.
- `scene.scaleMode = .resizeFill`; size the scene from `GeometryReader`.
- Keep game state in the scene or a model, not in the view.
- Known iOS 26.x frame-rate bug: cap at 60 fps and test on a real device.
- SceneKit is deprecated. For 3D, use RealityKit.

## Data

- Small state: `@AppStorage` or a Codable JSON file in Application Support.
- Structured local data: SwiftData, local store only. No CloudKit.

## Look it up before guessing

- `DocumentationSearch` (Xcode MCP, `query` plus optional `frameworks`) searches
  the locally installed Apple docs semantically. Use it for any iOS 26/27 API
  before web search.
- Apple's skills load when `CLAUDE_CODE_PLUGIN_DIRS` is exported in the shell profile:
  `xcode-integration:swiftui-specialist`, `swiftui-whats-new-27`,
  `modernize-tests`, and the three `accessibility-*-specialist` skills.
  Invoke the SwiftUI ones when designing a screen.

## Apple's own agent docs

After Xcode is installed, read specific files in
`/Applications/Xcode.app/Contents/PlugIns/IDEIntelligenceChat.framework/Versions/A/Resources/AdditionalDocumentation/`
when working on SwiftUI composition, Liquid Glass, concurrency, or SwiftData.
