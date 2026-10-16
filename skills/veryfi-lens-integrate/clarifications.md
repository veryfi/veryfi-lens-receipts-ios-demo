# Clarifications

Until a sibling skill or the iOS pack answers these, keep the conservative behavior and mark the claim **Unconfirmed**. Do not invent an API to close a row.

## 1. Android and plugins skill files

**Open.** Expected paths are in [routing.md](routing.md). This router must not grow install samples to compensate for a missing file.

## 2. Android `headlessUpload`

**Resolved for the UI facade.** `VeryfiLens.kt` exposes `uploadImages` overloads and no `headless*` method. iOS `headlessUpload` stays iOS-only.

## 3. Plugin no-UI upload method names

**Open.** Package ids are documented. The method that uploads existing files without Lens UI is **Unconfirmed** for React Native, Flutter, Cordova, Capacitor, and .NET until the plugins skill names it.

## 4. `backupDocsToiCloud` on Android

**Open.** Not present on Android `VeryfiLensSettings` at the time of this pack. iOS-only until the Android skill adds a property.

## 5. Android check TIFF flag and per-flavor Maven ids

**Open.** iOS uses `retrieveCheckTiffIsOn` on Remote Models. Android flavor families are listed in `AI_CONTEXT.md`. The TIFF flag name and the Maven artifact id for each flavor are **Unconfirmed** here. The public quick start's `com.veryfi.lens:veryfi-lens-sdk` is the receipts walkthrough coordinate only.

## 6. Headless settings type

**Open beyond iOS.** iOS Headless uses `VeryfiLensHeadlessSettings`, not `VeryfiLensSettings`. Do not copy UI recipes onto Headless until the platform skill says the fields exist.

## 7. Partner dictate on Android

**Open.** Both platforms default `dictateIsOn` to true. iOS skill: obsolete, not partner available. Android ships dictation on `veryfilens-core`. This router still leaves the flag false.

## 8. Close-on-submit vs submit-without-close

**Open.** Inherited from the iOS clarifications. If both are true, do not guess the winner.

## 9. Settings subclasses in public docs

**Resolved for iOS.** The public quick start still shows `VeryfiLensReceiptsSettings` / `VeryfiLensChecksSettings`. The iOS skill forbids those subclasses in client code. Use `VeryfiLensSettings` plus a recipe id. Android and plugin preset types stay **Unconfirmed**; do not add them from this router.

## 10. Any-document back prompt on Android

**Open.** iOS requires active type `any_document`, `anyDocumentBackIsOn`, and `packageMaxScans == 2`. Do not state that Android uses the same gate until the Android skill does.
