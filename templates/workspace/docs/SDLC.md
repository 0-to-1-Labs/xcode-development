# SDLC: from idea to a kid playing it

Small loops. Every loop ends with something you can tap on a screen.

## 1. Idea to spec (15 minutes, with the kid)

1. Use the `new-app` skill: "make a new game called <Name>".
2. Fill `apps/<Name>/docs/SPEC.md` together. One page. Who plays, what it does,
   rules, screens, what is out, and a "done when" checklist.
3. Commit: `docs: write spec`.

## 2. Feature loop (repeat)

Use the `feature-tdd` skill. Each pass:

| Step | Command or action |
|------|-------------------|
| Branch | `git switch -c feat/<name>` |
| Test first | Write a Swift Testing test. `make test-unit` fails. |
| Implement | Smallest change. Views thin, logic in models. |
| Gate | `make check` (lint, build, test) passes. |
| Playtest | `make run`, `make screenshot`, look at it. iPad too. |
| Commit | `feat(<area>): ...` Conventional Commit. |

Merge to `main` with a fast-forward or a squash. Solo work needs no merge request.
Use a GitLab MR when you want the `ios-review` skill or CI to run first.

## 3. Playtest on a device (weekly)

`make install-device`. Hand it to the kid. Watch, do not explain. Write what
confused them into `docs/SPEC.md` under a "Playtest notes" heading. Those notes
become the next features. Profiles expire in 7 days, so reinstall weekly.

## 4. Release (later)

Not needed for family use. When the paid program is active:

1. Bump `MARKETING_VERSION` in `project.yml`. Tag `v<version>`.
2. `xcodebuild -scheme <App> -destination 'generic/platform=iOS' archive -archivePath build/<App>.xcarchive`
3. `xcodebuild -exportArchive -archivePath build/<App>.xcarchive -exportOptionsPlist ExportOptions.plist -exportPath build/export`
4. Upload with `xcrun altool` or Transporter for TestFlight.
Add an `ExportOptions.plist` and a `make archive` target then. Not before.

## Conventions

**Branches**: `main` is always buildable. Work on `feat/`, `fix/`, `chore/`.

**Commits**: Conventional Commits, enforced by lefthook.
`feat`, `fix`, `chore`, `docs`, `test`, `refactor`, `perf`, `build`, `ci`, `style`, `revert`.
Scope is the feature or area: `feat(game): add double jump`.

**Hooks** (lefthook, installed by `new-app` or `make hooks`):

| Hook | Runs |
|------|------|
| pre-commit | swift-format lint, SwiftLint strict, secret file check |
| commit-msg | Conventional Commit format |
| pre-push | `make test-unit` |

Skip once with `LEFTHOOK=0 git commit`. Do not skip habitually.

**CI**: `new-app --ci github|gitlab` adds a workflow (lint, iPhone tests, iPad
tests). Until a macOS runner exists, local `make check` is the gate.

## Definition of done

A task is done when all of these are true:

- [ ] `make check` passes and the output was shown.
- [ ] A screenshot from the simulator was taken and looked at (iPhone, and iPad if layout changed).
- [ ] New behavior has a unit test. New screens have a UI test.
- [ ] `docs/SPEC.md` matches what the app does.
- [ ] No network, SDK, or permission was added (see `PRIVACY.md`).
- [ ] Committed with a Conventional Commit on a branch or `main`.
