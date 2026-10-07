# xcode-development

A Claude Code plugin for building personal and family iPhone and iPad apps and
games with Xcode 27. One command sets up a workspace. One skill scaffolds an
app with tests, lint, hooks, and CI. The rest of the skills carry a small team
(or one parent and some kids) from idea to a playable build on a real device.

Privacy-first by default: no network, analytics, ads, SDKs, or accounts unless
you ask. Free Apple Personal Team signing works out of the box.

## Install

```
/plugin marketplace add 0-to-1-Labs/claude-marketplace
/plugin install xcode-development@0-to-1-labs
```

Requirements: an Apple Silicon Mac on macOS 26.6 or later, Xcode 27 from the
App Store, Homebrew. Optional: `gh` or `glab` for remotes.

## Quick start

```bash
mkdir ~/family-apps && cd ~/family-apps
claude
# > /xcode-development:init
# > make a new game called BubblePop for my 6 year old
```

Then from `apps/BubblePop`:

```bash
make run          # iPhone simulator
make run-ipad     # iPad simulator
make check        # lint + build + test, the definition of done
make install-device
```

## What you get

| Piece | Detail |
|-------|--------|
| `/xcode-development:init` | Workspace with CLAUDE.md, `apps/`, docs, Claude settings, git hooks |
| `new-app` | XcodeGen project (`project.yml` is the source of truth), SwiftUI app or SpriteKit game, Swift Testing unit tests, XCTest UI smoke test, SwiftLint + swift-format, lefthook, Makefile, optional GitHub/GitLab remote and CI |
| `build-test` | `make check`, failure triage, Xcode MCP build and test tools |
| `run-sim` | Simulator launch, screenshots, SwiftUI previews, UI driving through Xcode 27's MCP tools |
| `install-device` | Signed build to a plugged-in iPhone or iPad with `devicectl`, 7-day reinstall handling |
| `feature-tdd` | Spec, failing test, implement, gate, playtest, Conventional Commit |
| `app-review` | Correctness, concurrency, privacy, and convention review before merge |
| `remote-mac` | Offload builds to another Mac over ssh; prepare it as a CI runner |
| `swift-guidelines` | Modern Swift 6.4 / SwiftUI / SpriteKit rules and the deprecated APIs to avoid |
| Hooks | Session status line; a guard that blocks edits to generated `.pbxproj` files and signing secrets; advisory lint on every Swift edit |
| MCP | Xcode 27's `xcrun mcpbridge` server: build, test, run, previews, device interaction, documentation search |

## Xcode 27 and agents

Xcode 27 ships an MCP server and 15 Apple-written skills. The plugin connects
the server. To load Apple's skills too, add this to `~/.zshrc`:

```bash
export CLAUDE_CODE_PLUGIN_DIRS="$(xcrun agent plugin path --plugin-format claude 2>/dev/null)"
```

In Xcode > Settings > Intelligence > Model Context Protocol, set "Allow
External Agents to Use Xcode Tools" to Always. The workspace docs cover
headless mode, folder approval, and which tools to use when.

## Opinions baked in

- iOS 26.0 minimum. Xcode 27 cannot target lower than iOS 17 anyway.
- Swift 5 language mode with MainActor default isolation, matching Xcode's
  new-project defaults, so agent-written code compiles with warnings instead
  of errors while you iterate.
- Simulator builds never sign. Only `make install-device` does.
- One app, one git repo. No submodules. Shared code goes in `packages/`.
- `make check` must pass before any task is called done.

`docs/DECISIONS.md` has the reasoning and `docs/RESEARCH.md` the sources.

## Platforms

iOS and iPadOS today. `new-app --platform` and `templates/<platform>/` are the
extension points for macOS, watchOS, tvOS, and visionOS.

## Settings file

`~/.config/xcode-development/env` holds `DEVELOPMENT_TEAM`, `BUNDLE_PREFIX`,
`GITHUB_OWNER`, `GITLAB_GROUP`, and `REMOTE_MAC_HOST`. The workspace settings
deny Claude read access to it.

## License

MIT
