# Xcode 27 and agents

Verified on 2026-10-06 against Xcode 27.0 (27A266a). Sources are in the
plugin's `docs/RESEARCH.md`.

## What Xcode gives an external agent

`xcrun mcpbridge` is a stdio MCP server. The plugin registers it as the
`xcode` server. It exposes about 54 tools. The ones that matter:

| Group | Tools | Use for |
|-------|-------|---------|
| Build | `BuildProject`, `GetBuildLog`, `XcodeRefreshCodeIssuesInFile` | Incremental builds that share Xcode's state. Live diagnostics for one file in seconds. |
| Test | `GetTestList`, `RunSomeTests`, `RunAllTests`, `XcodeListTestPlans` | Run one test fast, all tests before finishing. |
| Run and debug | `RunProject`, `StopProject`, `GetConsoleOutput`, `InvokeDebuggerCommand`, `RunCodeSnippet` | Launch, read OSLog, run lldb commands, try an API without a test. |
| See the UI | `RenderPreview` | Snapshot a `#Preview` in light, dark, sizes, orientations. |
| Drive the app | `DeviceInteractionStartWorkspaceSession`, `DeviceInteractionInstallAndRun`, `DeviceInteractionSynthesize`, `DeviceInteractionEndSession` | Install, tap, swipe, type on a simulator or device. Returns a screenshot path and a UI hierarchy with hit points. Always end the session. |
| Docs | `DocumentationSearch` | Semantic search over the locally installed Apple docs. Use before web search for any Apple API. |
| Project | `GetTargetBuildSettings`, `UpdateTargetBuildSetting`, `AddInfoPlist`, `AddEntitlement`, `XcodeNewTarget` | Read settings. In this factory, write them in `project.yml` instead. |
| Files | `XcodeRead`, `XcodeGrep`, `XcodeGlob`, `XcodeWrite`, `XcodeUpdate` | Project-structure paths. Normal Read/Edit tools are fine here too. |
| Headless | `XcodeListWorkspaces`, `XcodeOpenWorkspace`, `XcodeCloseWorkspace` | Target a project without the Xcode window. |

Also present: string catalog tools (need Apple's `translation` skills), and
App Store Connect crash and performance tools (not relevant without the paid program).

## Two modes

**Windowed**: Xcode.app is open with the project. The bridge binds to the
frontmost workspace. Xcode shows an alert when an agent connects.

**Headless** (new in 27.0, preview): `xcrun mcp-server` runs XcodeService
without a window. Xcode does not need to be open. Tools take a
`workspaceIdentifier`.

```bash
xcrun mcp-server status                              # is it on, which workspaces
xcrun mcp-server open apps/<Name>/<Name>.xcodeproj   # register a project
xcrun mcp-server show-logs                           # agent activity log
```

Admin-only (sudo, not for Claude): `enable`, `disable`, `approve <id> --always`,
`allow-folder <path> --always`, `deny`, `clear-permissions`, `reset-all`.

## The "Always" setting

Xcode > Settings > Intelligence > Model Context Protocol >
"Allow External Agents to Use Xcode Tools" = **Always**. Changing it needs an
admin password. State file:
`~/Library/Group Containers/group.com.apple.dt.Xcode.SecureSettingsContainer/CodingAssistant/HeadlessPermissions/mcp-server.json`.

With Always, bridge connections succeed without a per-connection dialog. In
headless mode, code-signed agents get durable grants per folder tree.

Apple's guidance:
- Do not use `--unsafe-always-allow-all-agents` on a desk machine.
- Xcode 27 can also monitor and limit filesystem access by agents and the
  processes they spawn (Intelligence settings). Turn it on if the kids run agents.
- Agent output is code you did not write. Keep `make check` as the gate.

## Apple's skills for Claude Code

Xcode ships 15 skills as a Claude Code plugin named `xcode-integration`:

```bash
xcrun agent plugin path --plugin-format claude
# ~/Library/Developer/Xcode/CodingAssistant/ExportedPlugins/27A266a/claude
```

The path contains the Xcode build number and changes with every update, so
resolve it at shell startup instead of hardcoding it. In `~/.zshrc`:

```bash
export CLAUDE_CODE_PLUGIN_DIRS="$(xcrun agent plugin path --plugin-format claude 2>/dev/null)"
```

Plain `claude` then loads the plugin. `--plugin-dir` would do the same for one
session only, and settings.json has no key for local plugin directories.

Skills worth using here: `swiftui-specialist`, `swiftui-whats-new-27`,
`device-interaction` (run as a subagent after any UI change), `modernize-tests`,
`accessibility-dynamic-type-specialist`, `accessibility-voiceover-specialist`,
`accessibility-sufficient-contrast-specialist`. Skip App Intents, UIKit
modernization, C bounds safety, and document-based apps unless an app needs them.

Apple also ships iOS 26 reference markdown at
`/Applications/Xcode.app/Contents/PlugIns/IDEIntelligenceChat.framework/Versions/A/Resources/AdditionalDocumentation/`.
The iOS 27 material is in the skills' `references/` folders.

## Rules that follow from this

1. `xcodebuild` and Xcode do not share incremental build state. The Makefile
   builds into `build/DerivedData` so the two never collide. Use `make` for CI
   and remote Macs; use `BuildProject` when iterating with Xcode open.
2. Never edit `.pbxproj`. A PreToolUse hook blocks it. Edit `project.yml`.
3. After any UI change, run the `device-interaction` skill as a subagent or
   `make run && make screenshot`, and look at the result.
4. Use `DocumentationSearch` before guessing at an iOS 26 or 27 API.
5. End device sessions. They are expensive.

## Coming in Xcode 27.2

`GetCodeCoverage` tool, a JSON `.xcproj` project format meant for agents, and a
destination parameter on `RenderPreview`. XcodeGen does not target `.xcproj`
yet; revisit when it does.
