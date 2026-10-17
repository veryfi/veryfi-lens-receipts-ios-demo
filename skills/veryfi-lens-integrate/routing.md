# Source inference and platform routing

Infer one platform, then open that skill. Do not answer install or callback syntax here.

## Inference order

1. **User statement.** "Android", "SwiftUI", "React Native", "Flutter", "Cordova", "Capacitor", "MAUI", ".NET" wins over folder layout.
2. **Plugin markers** win when the repo also contains `ios/` and `android/`. Those folders are the plugin's native shells.
3. **Native project markers** when no plugin marker matches.
4. **One question** when more than one row still matches, or none do.

SDK repos are not host apps. `veryfi-lens-ios` and `veryfi-lens-android` are the products. If the user is editing SDK source, this router does not apply. If they are integrating a host and the open workspace is an SDK repo, ask which host project to change.

## Signals

| Platform | Strong signals | Skill |
|----------|----------------|-------|
| iOS | `Package.swift` depending on Veryfi Lens, `Podfile` `VeryfiLens`, `.xcodeproj` / `.xcworkspace`, Swift UIKit or SwiftUI host, `Info.plist` | [../veryfi-lens-ios-integrate/SKILL.md](../veryfi-lens-ios-integrate/SKILL.md) |
| Android | `settings.gradle` / `settings.gradle.kts`, `com.veryfi.lens` imports, `AndroidManifest.xml`, Kotlin or Java host, Maven `nexus.veryfi.com` | [../veryfi-lens-android-integrate/SKILL.md](../veryfi-lens-android-integrate/SKILL.md) |
| React Native | `package.json` with `@veryfi/react-native-veryfi-lens`, `metro.config.js`, `react-native` | Plugins skill |
| Flutter | `pubspec.yaml` package `veryfi`, git host `repo.veryfi.com/shared/lens/flutter-plugin-veryfi-lens.git`. Docs require `flutter >= 3.19.3` | Plugins skill |
| Cordova | `config.xml`, `@veryfi/cordova-plugin-veryfi-lens` | Plugins skill |
| Capacitor | `capacitor.config.ts` / `capacitor.config.json`, `@veryfi/veryfi-lens-capacitor` | Plugins skill |
| .NET MAUI | MAUI `.csproj`, `UseMaui`, package `VeryfiLens.Maui` (public docs). A local checkout README also names `VeryfiLens.Sdk` | Plugins skill |
| .NET Legacy | Xamarin / `net-android` / `net-ios` binding projects. Docs name `VeryfiLensiOSNetBinding` and `VeryfiLenAndroidNetBinding` | Plugins skill |

Package names above are routing signals from the public Lens installation pages (https://docs.veryfi.com/lens/mobile/receipts/installation/) and, for MAUI `VeryfiLens.Sdk`, from the local `veryfi-lens-xamarin-plugin` README. Confirm the package id in the plugins skill before adding a dependency. The `1.x` ref printed in the Flutter docs example is an illustration; do not pin it from memory.

## Plugins skill lookup

Use [../veryfi-lens-plugins-integrate/SKILL.md](../veryfi-lens-plugins-integrate/SKILL.md).
The plugin repositories are read-only source references; generated integration material stays in
this repository's `.cursor/` directory. Absence of the local plugins skill is not permission to
invent plugin init methods.

## Android skill lookup

Use [../veryfi-lens-android-integrate/SKILL.md](../veryfi-lens-android-integrate/SKILL.md).
The Android SDK checkout is read-only evidence; generated integration material stays in this
repository's `.cursor/` directory. Android facts not verified by the local Android skill remain
**Unconfirmed**.

## What the sibling skill owns

Install, credentials storage, plist or manifest, `configure`, delegates, and the exact presentation call. Shared recipe ids and conflict rules stay here so each platform skill applies the same product choices.

## Engine strings

The extraction engine uses one shared value on the wire. Syntax belongs to the platform skill.

| Intent | iOS (`VeryfiLensSettings`) | Android (`ExtractionEngine`) | Plugin / JSON |
|--------|----------------------------|------------------------------|---------------|
| Veryfi API processing | `.cloudAPI` | `VeryfiCloudAPI` | `api` |
| On-device | `.inApp` | `VeryfiInApp` | `mobile` |
| No Process a Document | `.none` | `None` | `none` |

Android enum values were read from `VeryfiLensSettings.kt`. Plugin dictionaries use the JSON column; the plugins skill confirms the key name. iOS catalog calls that key `dataExtractionEngine`.

On-device extraction is for `credit_card`, `code`, and `barcode`. Credit card data stays on device. `.none` / `none` is valid for any document type.
