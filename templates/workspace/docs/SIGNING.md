# Signing and device install

Current mode: **free Apple ID, Personal Team**. No paid membership.

## What the free Personal Team gives you

| Item | Limit | Source |
|------|-------|--------|
| App IDs | 10 per 7 days | [Apple: Compare memberships](https://developer.apple.com/support/compare-memberships/) |
| Devices | 3, expire after 7 days | same |
| Apps per device | 3 at a time | same |
| Provisioning profile life | 7 days, then rebuild and reinstall | same |
| Push, iCloud, Game Center, In-App Purchase, TestFlight | not available | [Apple DTS](https://developer.apple.com/forums/thread/811929), [Compare memberships](https://developer.apple.com/support/compare-memberships/) |

Developer Mode must be on for each iPhone or iPad: Settings > Privacy & Security > Developer Mode, then restart. [Apple docs](https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device)

## One-time setup

1. Open Xcode > Settings > Accounts. Add your Apple ID. Xcode creates a Personal Team.
2. Find the Team ID: select the account, then the Personal Team. Copy the ID.
3. Put it in `~/.config/xcode-development/env` as `DEVELOPMENT_TEAM=XXXXXXXXXX`. The Makefile reads it at `make generate`. Never commit the Team ID into an app repo.
4. Plug in each device once and trust the computer. Xcode 27 Device Hub can pair iOS 27 devices over Wi-Fi after that.

## Weekly reinstall

Profiles expire after 7 days. The app stops launching. Run from the app directory:

```bash
make install-device        # builds, signs, installs, launches
```

No data is lost. Reinstalling over an existing app keeps its container.

## Command-line install flow

```bash
xcrun devicectl list devices
xcodebuild -scheme <App> -destination 'generic/platform=iOS' -allowProvisioningUpdates build
xcrun devicectl device install app --device <id> <path>/<App>.app
xcrun devicectl device process launch --console --device <id> <bundle id>
```

`ios-deploy` does not work on iOS 17 or later. Use `devicectl`. [Source](https://github.com/react-native-community/cli/issues/2610)

## Path to the paid program ($99 per year)

Enroll at <https://developer.apple.com/programs/enroll/>. It needs an Apple ID with two-factor auth, a legal name, and a credit card.

What changes:

| Item | Paid |
|------|------|
| Profile life | 1 year |
| Devices | 100 per device family per membership year |
| TestFlight | up to 100 internal and 10,000 external testers |
| Capabilities | push, iCloud, Game Center, IAP, Sign in with Apple |
| App Store | yes |

Steps to switch:

1. Enroll and wait for approval (usually 1 to 2 days).
2. In Xcode > Accounts, the paid team appears next to the Personal Team.
3. Set `DEVELOPMENT_TEAM` in `~/.config/xcode-development/env` to the new Team ID.
4. Regenerate each app: `make generate` then `make install-device`.
5. For TestFlight: add an `archive` and `upload` step. See `docs/SDLC.md` > Release.

Nothing in the templates needs to change. The Team ID is injected at generate time.
