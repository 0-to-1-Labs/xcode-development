---
name: install-device
description: Build a signed app and install it on a physical iPhone or iPad with xcrun devicectl, using the free Personal Team. Use when asked to put the app on a phone, iPad, or device, install for the kids, or when a previously installed app stopped opening after 7 days.
allowed-tools: Bash, Read, AskUserQuestion
---

# Install on a device

Free Personal Team limits: 7-day profiles, 3 apps per device, 3 devices,
10 app IDs per week. No push, iCloud, or Game Center. Full detail in
`docs/SIGNING.md`.

## Preconditions

1. `DEVELOPMENT_TEAM` is set in `~/.config/xcode-development/env`. Claude cannot read
   that file. Ask the user to confirm it is set, or run `make generate` and check
   that `Configs/Local.xcconfig` is non-empty with `wc -c`.
2. The device is plugged in once, trusted, and has Developer Mode on
   (Settings > Privacy & Security > Developer Mode).
3. `xcrun devicectl list devices` shows it as paired.

## Steps

```bash
cd apps/<Name>
make install-device        # builds with -allowProvisioningUpdates, installs, launches
```

If the user has more than one device, pass the id:
```bash
scripts/device-install.sh build/DerivedData/Build/Products/Debug-iphoneos/<Name>.app <bundle id> <device id>   # from apps/<Name>
```

## Common errors

- "No signing certificate" or "No profiles": the Apple ID is not added in
  Xcode > Settings > Accounts, or Team ID is wrong. Xcode GUI fixes this once.
- "Maximum number of apps for free development profiles": delete an older
  self-signed app from the device.
- App installed but will not open after a week: profile expired. Rerun the command.
- Over Wi-Fi: Xcode 27 can pair iOS 27 devices wirelessly. USB is more reliable.

Remind the user to reinstall every 7 days, or see `docs/SIGNING.md` for the paid path.
