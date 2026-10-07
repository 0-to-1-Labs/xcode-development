# Kid safety and privacy defaults

These apps are for one family. They are not on the App Store. The rules
below still apply because they keep the kids safe and keep the apps simple.

## Default rules

| Rule | Why |
|------|-----|
| No analytics, crash reporting, or telemetry SDKs | Nothing leaves the device. |
| No ads | Ever. |
| No network calls | No `URLSession`, no `NSAppTransportSecurity` exceptions. If a feature truly needs network, ask the parent first and record the reason in the app CLAUDE.md. |
| No accounts, sign-in, or email | No identity to leak. |
| No camera, mic, location, contacts, or photo access | Do not add a usage string to `Info.plist` unless the game needs it and the parent agreed. |
| No third-party Swift packages that phone home | Prefer Apple frameworks. Audit any package before adding it. |
| No external links or share sheets | Kids stay inside the app. |
| Data stays on device | `@AppStorage`, JSON files, or local SwiftData. No CloudKit. |
| Age-appropriate content only | Match the youngest intended player. |

Claude must ask before adding a network call, an SDK, or a permission string.

## Device-side tools for parents

- **Guided Access** locks an iPad to one app, with an optional timer. Triple-click the side button.
- **Screen Time** sets per-app limits.

## Why this maps to COPPA

COPPA covers personal data of children under 13: names, contact data,
persistent identifiers, photos, audio, video, and biometrics. The simplest
way to comply is to collect nothing. These defaults do that.

Sources: [FTC COPPA amendments, 2025](https://www.whitecase.com/insight-alert/unpacking-ftcs-coppa-amendments-what-you-need-know),
[Apple: Helping Protect Kids Online, 2025](https://developer.apple.com/support/downloads/Helping-Protect-Kids-Online-2025.pdf).
