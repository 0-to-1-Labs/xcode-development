# __WORKSPACE_NAME__

iPhone and iPad apps and games built with Claude Code and the
[xcode-development](https://github.com/0-to-1-Labs/xcode-development) plugin.
Each app lives in `apps/<Name>/` as its own git repository.

```bash
claude                      # from this directory
# > make a new game called BubblePop for my 6 year old
cd apps/BubblePop
make run                    # iPhone simulator
make run-ipad               # iPad simulator
make check                  # lint + build + test
```

| Doc | Purpose |
|-----|---------|
| `CLAUDE.md` | Rules and commands Claude follows |
| `docs/SDLC.md` | Idea to spec to tests to playtest, definition of done |
| `docs/SIGNING.md` | Free Personal Team today, paid program later |
| `docs/PRIVACY.md` | Privacy and kid-safety defaults |
| `docs/XCODE-AGENTS.md` | Xcode 27 MCP tools, headless mode, Apple's skills |
| `docs/REMOTE-MAC.md` | Offloading builds to another Mac |
