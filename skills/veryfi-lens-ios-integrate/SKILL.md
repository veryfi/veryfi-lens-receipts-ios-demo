---
name: veryfi-lens-ios-integrate
description: >-
  Integrates the Veryfi Lens iOS SDK: XCFramework flavor, credentials, configure,
  VeryfiLensSettings recipes, UIKit/SwiftUI presentation, VeryfiLensDelegate callbacks,
  CocoaPods/SPM, receipts, long receipts, checks, cards, barcodes, OCR, W2/W9,
  Lite App Clip, and headless receipts or credit cards.
  Use when adding Veryfi Lens to an iOS app, choosing a flavor template, wiring listeners, or
  reducing Lens support tickets about capture, upload, or extraction.
---

# Veryfi Lens iOS integration

Walk a host app from install to a working first scan. Prefer changing the **fewest** flags. Do not invent SDK APIs.

**Public type for settings:** `VeryfiLensSettings()`. Never recommend `VeryfiLensReceiptsSettings`, `VeryfiLensChecksSettings`, or other `VeryfiLens*Settings` subclasses — those are Demo/internal presets, not a client contract.

**No SDK schema changes.** Recipes are property assignments only.

## Workflow

Copy and track:

```
Lens integrate:
- [ ] Intake
- [ ] Flavor vs documentTypes
- [ ] Install + Info.plist + credentials
- [ ] Recipe on VeryfiLensSettings
- [ ] Conflict check
- [ ] configure + delegate
- [ ] Present UI (or headless)
- [ ] Handle close / update / success / error
```

Read references as needed (one level deep):

- [implementation.md](implementation.md) — install, configure, present, delegates, utils
- [recipes.md](recipes.md) — use-case property sets
- [settings-groups.md](settings-groups.md) — conceptual groups for later internal helpers
- [conflicts.md](conflicts.md) — incompatible flags
- [settings-catalog.md](settings-catalog.md) — flag meanings
- [clarifications.md](clarifications.md) — Unconfirmed semantics
- [flavor-matrix.md](flavor-matrix.md) — pod, dedicated SPM, module, XCFramework
- Product templates (open the one row that matches the host):

| Product | Template |
|---------|----------|
| Full / most complete UI | [templates/full.md](templates/full.md) |
| Receipts | [templates/receipts.md](templates/receipts.md) |
| Long receipts | [templates/long-receipts.md](templates/long-receipts.md) |
| Lite App Clip | [templates/lite-app-clip.md](templates/lite-app-clip.md) |
| Checks | [templates/checks.md](templates/checks.md) |
| Credit cards UI | [templates/credit-cards-ui.md](templates/credit-cards-ui.md) |
| Business cards | [templates/business-cards.md](templates/business-cards.md) |
| Barcodes | [templates/barcodes.md](templates/barcodes.md) |
| Headless credit cards | [templates/headless-credit-cards.md](templates/headless-credit-cards.md) |
| Headless receipts | [templates/headless-receipts.md](templates/headless-receipts.md) |
| OCR code strips | [templates/ocr-code-strips.md](templates/ocr-code-strips.md) |
| OCR code caps | [templates/ocr-code-caps.md](templates/ocr-code-caps.md) |
| W-2 | [templates/w2.md](templates/w2.md) |
| W-9 | [templates/w9.md](templates/w9.md) |

### 1. Intake

Ask only what is missing:

| Topic | Options |
|-------|---------|
| UI | UIKit, SwiftUI, custom UI + `utils`, Headless SDK |
| Documents | receipts/invoices, long receipts, checks, cards, IDs, insurance, W2/W9, bank statements, barcodes/codes, any_document, visual-only PDF |
| Industry | CGP/expense, banking, Any-Documents, CPG, visual/scan-to-PDF |
| Extract | Cloud API (`.cloudAPI` / `"api"`), on-device (`.inApp` / `"mobile"`: only `credit_card`, `code`, `barcode`; credit card data is never sent to the backend), decoupled `.none` (`"none"`: any type) — local zip or Lens upload without Process a Document |
| UX | Review then submit, auto-submit, batch until max then review |
| Sources | Camera, gallery, Files, dictate |
| Privacy | Photos backup, location, keep local files after process |

### 2. Flavor

The XCFramework **must** ship models for `documentTypes`. Settings cannot fix a receipts-only binary scanning checks.

When SDK size is a concern, recommend the **Remote Models** flavor. A specific flavor (Checks, Receipts, and the rest) embeds its models in the binary. Remote Models keeps that binary smaller and downloads most of the heavy model resources after install, only for the features the host turned on. Bank-check TIFF is one of those: it is not in the Checks-specific flavor yet because the TIFF model is large, and it is supported on Remote Models. Size tables and how published artifacts relate to the installed app: [SDK binary sizes](https://docs.veryfi.com/lens/mobile/settings/sdk_binary_sizes/).

Measure size on the final build product, once with the Veryfi Lens SDK linked and once without it. The distributed XCFramework size and the Android AAR size are fat artifacts that include every architecture and platform slice. Neither number is the size added to the installed app.

| Flavor family | Typical `documentTypes` |
|---------------|-------------------------|
| Full / Receipts | `receipt`, `invoice`, `other` (+ `long_receipt` if that flavor) |
| Checks | `check`. Capture only. Check TIFF is not in this specific flavor yet (model size). |
| Remote Models | Recommended when size matters. Downloads heavy models after install. Supports bank-check TIFF (`retrieveCheckTiffIsOn`). |
| CreditCards | `credit_card`. Local extraction only. Card data is never sent to the backend. |
| BusinessCards | `business_card` |
| OCR / Code | `code` |
| Barcodes | `barcode` |
| W2 / W9 / BankStatements | `w2` / `w9` / `bank_statement` |
| Any-Documents | `any_document` + `anyDocumentTemplate`. Not a closed list: contact support for another template, including one not supported yet. |
| Any-Documents shortcuts | Nutrition facts, US passport, driver license, and prescription labels. These are Any-Documents with a shortcut flavor, not a separate product. |
| Field Detection | receipts + `documentFieldsToDetect`. Paid and gated by validated account/backend entitlement. |
| Lite | App Clip framework `VeryfiLensLite`. Same `VeryfiLens` / `VeryfiLensSettings` types after `import VeryfiLensLite`. Not Core. See [templates/lite-app-clip.md](templates/lite-app-clip.md). |
| Core | `VeryfiLensCore.swift` (`showVoice`, `showEmail`, `attachDocumentTo`). Not Lite, and not one of these templates. |
| Headless Receipts / Credit Cards | no Lens UI; own camera |

If flavor is unknown, say so and pick the narrowest `documentTypes` that match the documents. If size is a concern, say so and recommend Remote Models.

Then open [flavor-matrix.md](flavor-matrix.md) and the matching template. A flavor with **no dedicated SPM** must not be installed from `veryfi-lens-spm`. That package is the Full UI binary. Lite is `VeryfiLensLite`, not Core. Headless products use `VeryfiLensHeadless` plus their own settings types, not `VeryfiLensSettings`.

### 3. Install

See [implementation.md](implementation.md). Required plist: Camera. Photo Library if gallery or backup. Location only if `locationServicesIsOn`. Do not add Contacts/Calendar unless the host already uses those Lens features (legacy README is stale — Unconfirmed).

### 4. Settings recipe

Start from `VeryfiLensSettings()`, then apply **one** recipe from [recipes.md](recipes.md). Overlay branding last.

If the customer owns Process a Document, use a decoupling recipe with `dataExtractionEngine = .none`. Local zip: `uploadWithoutProcessingIsOn = false` and keep `local_package_path`. Remote package: `uploadWithoutProcessingIsOn = true` so Lens uploads but does not extract; the host processes later with success `bucket` / `package_path`.

Conservative defaults (always, unless the host wants the opposite):

```swift
settings.ignoreRemoteSettings = true
settings.backupDocsToGallery = false  // otherwise every scan is copied into Photos
settings.backupDocsToiCloud = false   // otherwise every scan is copied into iCloud
settings.moreSettingsMenuIsOn = false
settings.autoCaptureOtherIsOn = false  // default true is a footgun
settings.showNoDocumentDetectedWarning = false  // usual choice: skip the no-document alert
settings.dictateIsOn = false  // obsolete; not partner available
```

If the host displays captured files after callbacks, or submits **several packages** before consuming files:

```swift
settings.autoDeleteLocalResourcesAfterProcessing = false
```

A single sequential document can keep the default `true` if the host copies from `update` immediately. When false, the host owns deletion (`clearLensStorage()` or `FileManager` on callback paths).

Then run [conflicts.md](conflicts.md).

### 5. Configure and delegate

Order:

1. Build credentials + settings
2. Set `VeryfiLens.shared().delegate` (weak; keep the object alive)
3. `configure(with:settings:completion:)`
4. Present only after `completion(true)` (and prefer waiting if validation can still fail)

Empty credentials → `veryfiLensError` with `msg` `invalid_credentials`. Do not call UI until configured.

### 6. Present

**UIKit:** `showCamera(in:)`, `showGallery(in:)`, `showDocumentBrowser(in:)`, or embed `lensVC()`.

**SwiftUI:** `.veryfiLensFullScreenCover` / `.veryfiLensSheet` with `VeryfiLensFlow`. Do not also call `showCamera` on the same presentation.

**No UI, files the host already has:** `uploadImages(paths:)`. This is the path for a Share Extension and for any other lightweight context that should not open the camera. In the extension, set `shareExtensionModeIsOn = true`. In the main app, leave it false.

**No UI, in memory:** `headlessUpload(images:)` (up to 4, type `receipt`) or `headlessUpload(url:)`, or the Headless product SDK.

Files can enter camera through More > Import > Browse (`moreMenuIsOn` + `browseIsOn`), a dedicated top-right button (`showBrowserButton`), or a Photos/Files menu on the gallery control (`galleryIsOn` + `galleryButtonWithFilesIsOn`). These are independent. For Files without camera, use `showDocumentBrowser(in:)` or SwiftUI `.documentBrowser`; no camera source flag is required.

Do not overlap two Lens presentations.

### 7. Delegates

Implement all four required methods. JSON keys are snake_case. Package success uses `status` `"done"`. Barcode and OCR code successes pass `BarcodeResult` / `OCRResult` JSON directly, without that envelope. See [implementation.md](implementation.md) and the barcode and OCR templates.

Warn if `autoDeleteLocalResourcesAfterProcessing` is true and the host copies files from `update`. If they process several packages at once, set it false and tell them they own deletion (`clearLensStorage()` or `FileManager` on callback paths). See [implementation.md](implementation.md#local-resources-and-who-deletes-them).

## Do not

- Set `dictateIsOn` (obsolete; not partner available; leave false)
- Set `anyDocumentType` (deprecated local regex OCR; use `anyDocumentTemplate`)
- Treat nutrition facts, US passport, driver license, or prescription labels as a product separate from Any-Documents. They are shortcut flavors of that solution. Contact support for another Any-Documents template.
- Set `useLegacyModels` (debug only; SDK currently forces it true)
- Use `VeryfiLens*Settings` subclasses in client sample code. Headless is the exception: `VeryfiLensCreditCardsSettings` and `VeryfiLensReceiptSettings` are the public headless settings types, not the Demo UI subclasses.
- Install a trimmed, Lite, OCR, card, barcode, W-2, W-9, or headless credit-card flavor from the Full package `veryfi-lens-spm` when [flavor-matrix.md](flavor-matrix.md) says that flavor has no dedicated SPM, or when it names a different SPM repo.
- Enable `moreMenuIsOn` unless end users should override auto capture, auto light, gallery/iCloud backup, Superman mode, and close-camera-after-submit. Hiding the menu discards those stored overrides. Hide individual rows with `showiCloudBackupOption`, `showSupermanModeIsOn`, and `afterScanCloseCameraIsOn`.
- Enable `moreSettingsMenuIsOn` unless the product wants the More > Settings entry. It does not reset More-menu overrides.
- Set `.inApp` except for `credit_card`, `code`, or `barcode` (only in-app types; they always extract locally with this engine). Credit card data is never sent to the backend.
- Set `cameraProcessingMode` unless `documentTypes` includes `any_document` (may be ignored otherwise — Unconfirmed for card types that already use card detectors)
- Promise that `autoCropGalleryIsOn` / `autoCropBrowserIsOn` crop every import. They are best effort for paper photos/scans; internal digital-copy checks can preserve screenshots/digital copies, and original-file PDFs are not page-cropped.
- Turn on `glareDetectionIsOn` unless the host explicitly wants the current glare gate. It is a suboptimal algorithmic detector; a better one may ship soon or on request.
- Treat `allowSubmittingScreenshots` and `enableScreenshots` as one switch. The first rejects imported images the detector classifies as screenshots. The second blanks the camera and submit screens in device screenshots and screen recordings.
- Treat `multiplePagesCaptureIsOn` and `multipleDocumentsIsOn` as one switch. The first keeps every crop in one image (false keeps the larger one). The second asks on submit preview whether several images should be separate packages.
- Set both `showHelpButton` and `showInfoButton` expecting two camera buttons. They share one control and Help wins. Use the Help delegate for a host-presented screen, `showInfoButton` for a full-camera `VeryfiInfoView`, and `cameraInfoView` for an independent top banner.
- Leave `backupDocsToGallery` or `backupDocsToiCloud` on unless the host wants users' Photos or iCloud filled with copies of their documents. Gallery still defaults true. Hide the More menu, or the iCloud row, so users cannot turn the copies back on.
- Call `VeryfiLensUtils()` yourself. Use `VeryfiLens.shared().utils` after `configure`.
- Use `headlessUpload` from a Share Extension. Use `uploadImages(paths:)` and set `shareExtensionModeIsOn = true` there. Leave that flag false in the main app.
- Leave `ignoreRemoteSettings = false` unless the host wants dashboard `lens_settings` to override local flags
- Promise bank-check TIFF on the Checks-specific flavor. It is not supported there yet because the TIFF model is large. Use the Remote Models flavor with `retrieveCheckTiffIsOn`.
- Quote the XCFramework or AAR file size as the size added to the app. Measure the final build with the Veryfi Lens SDK linked and with it removed. See [SDK binary sizes](https://docs.veryfi.com/lens/mobile/settings/sdk_binary_sizes/).
- Treat `browseIsOn` as a global Files-import gate. It only adds Browse to the camera More menu. `showBrowserButton`, `galleryButtonWithFilesIsOn`, and standalone `showDocumentBrowser(in:)` are independent entry points.
- Promise that `fraudDetectionIsOn` or `documentFieldsToDetect` unlocks the corresponding local model feature. Local fraud detection and local field detection are paid features gated by the validated account/backend entitlement; the appropriate flavor and settings are also required.

## Output

When generating host code, produce:

1. Info.plist keys actually needed
2. `configure` + delegate class
3. One presentation path
4. The recipe’s `VeryfiLensSettings` mutations with a one-line comment per non-obvious flag
5. A short conflict note if any residual risk remains
