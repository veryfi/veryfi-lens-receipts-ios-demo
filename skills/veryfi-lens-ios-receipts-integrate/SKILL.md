---
name: veryfi-lens-ios-receipts-integrate
description: >-
  Integrates the Veryfi Lens iOS Receipts UI SDK. Covers pod VeryfiLens-Receipts, SPM repo veryfi-lens-spm-receipts, VeryfiLensSettings, credentials, configure, camera gallery and Files entry points, VeryfiLensDelegate callbacks, and uploadImages. Use when adding receipt, invoice, or other capture with the receipts flavor, wiring listeners, or fixing capture, upload, or extraction on iOS.
---

# Veryfi Lens iOS Receipts

Walk a host app from install to a working first scan. Change the fewest flags. Do not invent SDK APIs.

**Public settings type:** `VeryfiLensSettings()`. Never recommend `VeryfiLensReceiptsSettings`, `VeryfiLensChecksSettings`, or other Demo `VeryfiLens*Settings` subclasses.

**No SDK schema changes.** The recipe is property assignments only.

## Quick flow

Use this when the host already asked for this flavor and did not leave a choice open.

Assumptions:

- UIKit or SwiftUI Lens camera
- Types `receipt`, `invoice`, and `other`, with the picker on
- Cloud Process a Document (`.cloudAPI`)
- Review, then submit. Gallery on. More menu off, so the Browse row is hidden
- Backups off, location off, dictate off


1. Install the artifact and plist keys in [install.md](install.md).
2. Apply the recipe in [settings.md](settings.md).
3. Run the conflict table in [troubleshooting.md](troubleshooting.md#conflicts).
4. `configure`, then present, as in [implementation.md](implementation.md).
5. Implement [callbacks.md](callbacks.md).
6. Track [checklist.md](checklist.md).

State those assumptions in the sample. Do not ask extra questions on this path.

## Guided flow

Ask only what is still missing:

| Topic | Options |
|-------|---------|
| UI | UIKit or SwiftUI |
| Documents | `receipt`, `invoice`, `other`. A long receipt needs the long-receipts binary |
| Extract | Cloud API, or decoupled `.none` (local zip, or Lens upload without Process a Document) |
| UX | Review then submit, auto-submit, or batch until `packageMaxScans` then review |
| Sources | Camera, gallery, standalone Files, or a Share Extension via `uploadImages` |
| Privacy | Photos backup, iCloud backup, location, keep local files after process |

If the host needs a document type this binary does not ship, stop. Say which types this flavor supports. Do not retarget `documentTypes` onto models this XCFramework does not contain. Any-Documents templates, including nutrition facts, US passport, driver license, and prescription labels, are a different solution. Contact support for a template that is not already confirmed. Credit-card capture stays on the credit-card flavor and on device. Bank-check TIFF needs Remote Models.

## Workflow

```
Lens integrate:
- [ ] Install artifact and plist
- [ ] Recipe on VeryfiLensSettings
- [ ] Conflict check
- [ ] configure and delegate
- [ ] One presentation, or uploadImages when the host already has files
- [ ] close / update / success / error
```

Read one level deep, and only inside this folder:

- [install.md](install.md) — artifact, SPM or CocoaPods, plist, app size
- [implementation.md](implementation.md) — credentials, configure, present, Files and gallery, uploadImages, utils
- [settings.md](settings.md) — recipe and the public settings catalog
- [callbacks.md](callbacks.md) — delegate payloads
- [troubleshooting.md](troubleshooting.md) — symptoms and conflicts
- [clarifications.md](clarifications.md) — Unconfirmed items
- [checklist.md](checklist.md) — done when

## Warnings

- Leave `backupDocsToGallery` and `backupDocsToiCloud` false unless the host wants every scan copied into Photos or iCloud. Gallery backup still defaults to true. Hide the More menu, or the iCloud row, so a user cannot turn the copies back on.
- Any-Documents is marketed as a broad solution: `any_document` plus `anyDocumentTemplate`. The template list is not closed. Nutrition facts, US passport, driver license, and prescription labels are shortcut flavors of Any-Documents, not separate products. Contact support for another template, including one that is not supported yet. Do not set `anyDocumentType` (deprecated local regex OCR). This binary is not that solution.
- Credit card data is local only and is never sent to the backend. `.inApp` (`"mobile"`) is only for `credit_card`, `code`, and `barcode`.
- Local fraud detection (`fraudDetectionIsOn`) and local field detection (`documentFieldsToDetect`) are paid features gated by the validated account and backend entitlement. Settings cannot unlock them. Field detection also needs the Field Detection or Remote Models flavor.
- Bank-check TIFF (`retrieveCheckTiffIsOn`) requires Remote Models. It is not in the Checks-specific flavor yet, because the TIFF model is large.
- When size matters, recommend Remote Models. Measure the final app with the SDK linked and with it removed. Do not quote the XCFramework file size. [SDK binary sizes](https://docs.veryfi.com/lens/mobile/settings/sdk_binary_sizes/).
- `uploadImages(paths:)` and `headlessUpload` on `VeryfiLens` are UI SDK helpers. They are not the Headless product (`VeryfiLensHeadless`).
- Public UI settings are `VeryfiLensSettings()`. Do not use Demo subclasses in client code.
- Headless products use `VeryfiLensCreditCardsSettings` or `VeryfiLensReceiptSettings` (singular), `VeryfiLensHeadlessCredentials`, and `VeryfiLensHeadless.shared()`.
- Leave `dictateIsOn` false. It is obsolete and not partner available. The SDK default is still true.
- Leave `ignoreRemoteSettings` true unless the host wants dashboard `lens_settings` to override the recipe.
- Leave `glareDetectionIsOn` false unless the host explicitly wants the current glare gate. It is a suboptimal algorithmic detector.


## Suggestions

- After the first scan works, add branding and `customLensStrings` last. They are not required for a successful scan.
- If users import photos of paper, `autoCropGalleryIsOn` is best effort and also needs `autoDocDetectionAndCropIsOn`.
- If several packages stay in flight, set `autoDeleteLocalResourcesAfterProcessing` false and delete in the host.
- If installed size matters, ask Veryfi about Remote Models. Do not drop `invoice` or `other` from this binary to chase a smaller XCFramework file.
- Local field detection is a paid add-on on the Field Detection or Remote Models flavor. This receipts recipe leaves that list empty.
- A host that already owns the camera wants the Headless receipts SDK (`VeryfiLensHeadless`, `VeryfiLensReceiptSettings`), which is a different binary. `headlessUpload` on this UI SDK is not that product.


## Do not

- Do not set `dictateIsOn`, `anyDocumentType`, or `useLegacyModels`.
- Do not leave `backupDocsToGallery` at its default true.
- Do not enable `moreMenuIsOn` unless end users should override auto capture, torch, backups, Superman mode, and close-after-submit.
- Do not promise bank-check TIFF, credit-card extraction, or on-device receipt fields from this binary.
- Do not quote the XCFramework size as the app install delta.
- Do not call `VeryfiLensUtils()` yourself. Use `VeryfiLens.shared().utils` after configure.


## Output

When generating host code, produce:

1. Info.plist keys actually needed
2. `configure` plus a retained delegate
3. One presentation path
4. The recipe’s `VeryfiLensSettings` mutations, with a one-line comment on each non-obvious flag
5. A short conflict note if any residual risk remains
