---
name: app-review
description: Review Swift, SwiftUI, and SpriteKit code in an app under apps/ for correctness, concurrency, kid-safety, privacy, and template conventions before merge or commit. Use when asked to review, check, audit, or critique app code, or before merging a feature branch.
allowed-tools: Bash, Read, Grep, Glob
---

# iOS code review

Review the diff (`git diff main...HEAD` in the app repo) against this list.
Report only real findings with file and line. No style nits that lint already covers.

## Correctness
- State lives in `@Observable` models, not scattered `@State` copies of the same value.
- No force unwraps, `try!`, or `fatalError` on user-reachable paths.
- `onChange`, `task`, and timers cancel or stop when the view goes away.
- SpriteKit: scene size follows the view (`scaleMode = .resizeFill` or explicit sizing); nodes removed when done; no per-frame allocations in `update(_:)`.
- iPad: layout works in landscape and split view. No hardcoded 390-point widths.

## Concurrency (Swift 5 mode, MainActor default)
- Background work uses `Task.detached` or `@concurrent`, not `nonisolated` alone.
- No `@unchecked Sendable` or `nonisolated(unsafe)` without a comment explaining why.
- UIKit/SpriteKit callbacks stay on the main actor.

## Privacy (`docs/PRIVACY.md`)
- No `URLSession`, sockets, analytics, ads, or third-party packages.
- No new `INFOPLIST_KEY_NS*UsageDescription` keys in `project.yml`.
- No external links, share sheets, in-app purchases, or account flows.
- Content and language suit the audience named in `docs/SPEC.md` (for kids, the youngest player).

## Tests and conventions
- Every behavior change has a unit test. Every new screen has a UI smoke test.
- `make check` passes. Ask for the output if it was not shown.
- Deprecated APIs: `NavigationView`, `foregroundColor`, `cornerRadius`, one-arg `onChange`, `presentationMode`, `PreviewProvider`, `tabItem`. Flag them.
- Commit messages follow Conventional Commits.

Finish with a verdict: **merge**, **merge after fixes** (list them), or **do not merge** (why).
