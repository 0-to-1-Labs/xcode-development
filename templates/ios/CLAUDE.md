# __DISPLAY_NAME__

Personal iOS app from an xcode-development workspace (`../../CLAUDE.md` has the shared rules).
Read `docs/SPEC.md` before changing behavior.

## Commands

| Task | Command |
|------|---------|
| Regenerate project after editing `project.yml` | `make generate` |
| Build | `make build` or `make build-ipad` |
| Test (all) | `make test` or `make test-ipad` |
| Unit tests only | `make test-unit` |
| Lint and format check | `make lint` |
| Auto-format | `make format` |
| Run in simulator | `make run` or `make run-ipad` |
| Screenshot | `make screenshot` |
| Install on a device | `make install-device` |
| Definition of done | `make check` |

## Layout

```
project.yml         XcodeGen spec (source of truth, .xcodeproj is generated)
Sources/App/        @main App struct
Sources/Features/   Views and models, one folder per feature
Sources/Game/       SpriteKit scenes (games only)
Sources/Resources/  Assets.xcassets, string catalogs
Tests/              Swift Testing unit tests
UITests/            XCTest UI tests
docs/SPEC.md        What this app is
scripts/            Simulator and device helpers used by the Makefile
```

## Rules for this app

- Logic goes in `@Observable` models. Views stay thin. Test the models.
- Add a unit test with every behavior change. Add a UI test for every new screen.
- Run `make check` before saying a task is done. Paste the summary line.
- Git commands run from this directory. This is its own repository.
- Never add a network call, SDK, or permission string. See factory `docs/PRIVACY.md`.
