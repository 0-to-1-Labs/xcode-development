---
name: feature-tdd
description: Add or change a feature in an app using the factory SDLC: update the spec, write a failing test, implement, run make check, playtest in the simulator, commit with a Conventional Commit. Use when asked to add, implement, change, or fix any behavior in an app under apps/.
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
---

# Feature loop

Work from `apps/<Name>` in an xcode-development workspace. Follow the steps in
order. Do not skip the test.

1. **Spec**: Read `docs/SPEC.md`. If the feature changes rules or screens,
   update the spec first in one or two lines.
2. **Branch**: `git switch -c feat/<short-name>` (or `fix/`).
3. **Test first**: Write a Swift Testing test in `Tests/` for the behavior.
   Put logic in an `@Observable` model or a plain struct so it is testable
   without views. Run `make test-unit` and confirm it fails for the right reason.
4. **Implement**: Smallest change that passes. Keep views thin.
5. **Gate**: `make check`. Fix lint and test failures. Paste the summary.
6. **Playtest**: with the `xcode` MCP connected, use `RenderPreview` for the
   view, then run Apple's `device-interaction` skill as a subagent to tap through
   the flow. Otherwise `make run` then `make screenshot` and Read it. Repeat
   on iPad if the layout changed. Check that a child could use it: big targets,
   no reading required for the youngest player, no dead ends.
7. **Commit**: `git commit -m "feat(<area>): <what changed>"`. One feature per commit.
8. **Report**: what changed, test counts, screenshot path, anything left out.

## Constraints

- Never add a network call, SDK, package, or Info.plist permission. See `docs/PRIVACY.md`.
- Never add `@unchecked Sendable`, `try!`, or force unwraps to make a build pass.
- UI tests are XCTest in `UITests/`. Add one per new screen, with accessibility identifiers.
- If the feature needs a decision from the user (rules, art direction, difficulty), ask before writing code.
