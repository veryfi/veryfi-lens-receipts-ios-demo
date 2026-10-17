# Conflicts and support footguns

Run after applying a recipe. Prefer fixing by **unsetting** extras rather than adding more flags.

## Hard failures / silent bad UX

| Combination | Symptom | Fix |
|-------------|---------|-----|
| XCFramework flavor ≠ `documentTypes` | Missing models, poor/no detection | Match flavor; narrow types |
| `.inApp` except on `credit_card`, `code`, or `barcode` | No on-device extract; receipts and other types never use in-app | `.cloudAPI` for API extract, or `.none` for capture-only |
| `credit_card` with `.cloudAPI` or `.none` | Card data must stay on device | `.inApp`. Credit card data is never sent to the backend. |
| `.cloudAPI` with no network / bad credentials | Configure fail or upload errors | Fix creds/URL; handle `veryfiLensError` |
| `sameFileUploadPreventionPolicy = .always` without `.cloudAPI` | Policy cannot confirm uploads | Use `.session` or cloud engine |
| `documentFieldsToDetect` without paid account/backend entitlement or Field Detection/Remote Models flavor | Local fields stay off | Confirm entitlement and use a supporting flavor; the setting alone cannot unlock it |
| `fraudDetectionIsOn` without paid account/backend entitlement | Local fraud detection stays off | Ask support/account owner to enable the feature; the setting alone cannot unlock it |
| `retrieveCheckTiffIsOn` on the Checks-specific flavor | No TIFF; that model is not bundled there yet (size) | Remote Models flavor, which downloads the model after install |
| Quoting XCFramework or AAR file size as app size | Wrong install impact | Measure the final build with the SDK linked and without it. [SDK binary sizes](https://docs.veryfi.com/lens/mobile/settings/sdk_binary_sizes/) |
| `browseIsOn = true` with `moreMenuIsOn = false`, expecting a Browse row | No More-menu entry | Enable More, use `showBrowserButton`, use the gallery Photos/Files menu, or present `showDocumentBrowser(in:)` standalone |
| `uploadImages` or present UI before `configure` completion true | `not configured` | Wait for configure |
| Share Extension calling `uploadImages` with `shareExtensionModeIsOn = false` | Extension does the full storage upload and thumbnail work | Set `shareExtensionModeIsOn = true` in the extension |
| Overlapping `showCamera` + SwiftUI cover | Double presentation | One path only |
| `autoDeleteLocalResourcesAfterProcessing = true` + host reads files later | Empty or overwritten paths | Set false (host owns deletion) or copy immediately in `update` |
| `autoDeleteLocalResourcesAfterProcessing = true` + several packages in flight | Shared session copies overwrite; package folders are gone | Set false so each package keeps its own files |
| `backupDocsToGallery = true` without Photo Add usage string | Permission crash/prompt surprise | Plist or set false |
| `locationServicesIsOn` without location plist | Permission issues | Plist or set false |

## Competing submit / session behavior

| Combination | Problem | Fix |
|-------------|---------|-----|
| `autoSubmitDocumentOnCapture` + `batchUploadOnCamera` | Two “when do we leave camera” policies | Pick CaptureFlow.AutoSubmit **or** BatchToMaxThenReview |
| `autoSubmitDocumentOnCapture` + `imagePreviewIsOn` | Preview is gallery/browse; camera still auto-submits | OK if intentional; don’t expect camera preview |
| `closeCameraOnSubmit` + `submitWithoutClose` | Contradictory submit UX | Pick one (Unconfirmed winner if both true) |
| `afterScanCloseCameraIsOn = false` | Hides the More menu “Close camera after submit” row. Does not change capture flow by itself | Leave true if that row should stay. `closeCameraOnSubmit = false` is the capture–submit loop; true ends the session |

## Detection vs user can proceed

| Combination | Problem | Fix |
|-------------|---------|-----|
| `allowSubmitUndetectedDocsIsOn = false` + `validateCheck*` without allow-anyway | Users trapped | Keep `allowSubmitCheck*NotDetected = true` or relax undetected |
| `blurDetectionIsOn` + both submit flags false + poor lighting | Blur warning has no continue option, causing repeated retakes | Torch / `tryAgainLightIsOn` / raise threshold / set `allowSubmitBlurredDocsIsOn = true` |
| `allowSubmitUndetectedDocsIsOn = true` while trying to block blur with `allowSubmitBlurredDocsIsOn = false` | Blur is still allowed because the legacy undetected flag is an umbrella | Set both false to block both; or undetected false + blurred true to block missing rectangles but allow blur |
| `autoDocDetectionAndCropIsOn = false` + no crop layout | User has no guide | Enable detect or `cropLayoutIsOn` |
| `cropLayoutIsOn = true` while automatic detection/crop stays on | Pure fixed-frame mode does not activate as expected | Turn automatic detection/crop off for a fixed frame, or use `cropLayoutWithAutoDetection = true` for frame + green box |
| Circular-looking crop layout assumed to make a circular image | UI is circular but saved crop is still the rectangular bounds | Treat corner radius as visual framing, not an output mask |
| `showDefaultScanningGuide = true` while `showHelpButton = false` | No Help control exists to replay the built-in guide | Turn on Help, or use the automatic guide counters only |
| `showHelpButton = true` plus `showInfoButton != nil` expecting two controls | Both use the same camera control; Help wins, so the `VeryfiInfoView` does not open from that button | Pick Help (built-in or delegate callback) or `showInfoButton`. Use independent `cameraInfoView` for an always-visible banner |
| `showGuide*Counter = 0` while expecting an automatic guide | Built-in guide does not auto-show | Set the matching counter above zero; `animationDisplayDuration` only controls how long a shown guide stays visible |
| `autoCropGalleryIsOn` / `autoCropBrowserIsOn` on non-paper or digital copies | Detection may crop an interface panel or other false rectangle | Internal screenshot/digital-copy checks skip known cases; still treat auto-crop as best effort and test the customer's sources |
| Import auto-crop flag on while `autoDocDetectionAndCropIsOn = false` | No import auto-crop | Enable both settings |
| `showNoDocumentDetectedWarning = false` + strict undetected gates | Alert is hidden, which is the usual choice, but users can still be stuck if submit-without-detection is off | Keep `allowSubmitUndetectedDocsIsOn = true`, or leave the warning on while debugging |
| `enableScreenshots` used as the screenshot-file policy, or the reverse | Imported screenshots still submit, or the camera UI stays capturable | `allowSubmittingScreenshots = false` rejects imported images the detector classifies as screenshots. `enableScreenshots = false` blanks the camera and submit screens in device screenshots and screen recordings |
| `pdfPreviewIsOn` without deciding `pdfEditIsOn` | Preview images and the packaged file are different choices | Preview keeps the original PDF and sends that file. Edit packages the image copy and discards the original. Pick per client. |

## Types and UI

| Combination | Problem | Fix |
|-------------|---------|-----|
| `showDocumentTypes = false` with more than one `documentTypes` entry | User cannot switch types on the camera | Turn the picker on, or set a single type |
| `documentTypes` includes `other` + `autoCaptureOtherIsOn = true` + `autoCaptureIsOn = false` | `other` still auto-captures | Set `autoCaptureOtherIsOn = false` |
| `cameraProcessingMode` without `any_document` | May be ignored | Set mode only for any-document (Unconfirmed for ID types) |
| `anyDocumentBackIsOn` with `packageMaxScans != 2` | Back prompt skipped | Set `packageMaxScans` to exactly 2 and use active type `any_document` |
| `anyDocumentBackIsOn` on check, driver license, or insurance card | Those types ignore this flag | Use `checkSequenceMode` / `checksBackIsOn`, `driverLicenseBackIsOn`, or `insuranceCardBackIsOn` |
| `stitchOtherIsOn` without `other` in types | Dead flag | Add `other` or skip |
| `galleryOtherIsOn` / `browseOtherIsOn` vs main gallery/browse | Split UX for `other` | Align unless product wants split |

## Packaging

| Combination | Problem | Fix |
|-------------|---------|-----|
| `stitchIsOn` + `singleScanPackages` + `returnStitchedPDF` | Package vs one PDF semantics | Pick MultiPage.StitchToPdf **or** SeparatePackages |
| `multiplePagesCaptureIsOn` used to split several photos into packages, or the reverse | Side-by-side pages stay one crop, or the same-transaction alert never appears | `multiplePagesCaptureIsOn` keeps every crop in one image (false keeps the larger one). `multipleDocumentsIsOn` asks on submit preview, with stitch on, whether several images are separate packages |
| `stitchIsOn = true` on checks/cards | Wrong UX | `stitchIsOn = false` for those recipes |
| `packageMaxScans = 1` + back-of-doc required | Cannot capture back | Raise max scans |
| `browserMultipleSelectionIsOn` with `packageMaxScans = 1` | Multi-select capped to 1 | Raise max or disable multi |

## Remote, menus, privacy

| Combination | Problem | Fix |
|-------------|---------|-----|
| `ignoreRemoteSettings = false` | Dashboard silently overrides local recipe | Set true unless remote control is the product |
| `moreMenuIsOn = true` | End users persist overrides for auto capture, auto torch, gallery backup, iCloud backup, Superman mode, and close-camera-after-submit | Set false to hide the menu and discard those stored overrides |
| `moreSettingsMenuIsOn = true` | Extra More > Settings entry. Does not reset More-menu overrides | Set false unless that screen is wanted |
| `backupDocsToGallery` default true left unchanged | Every scan is copied into the user's Photos library | Set false unless the host wants those copies |
| `backupDocsToiCloud = true` | Every scan is copied into the user's iCloud | Leave false unless the host wants those copies |
| `dictateIsOn` default true | Obsolete voice control is not partner available | Leave false |

## Engine pairing

| Combination | Problem | Fix |
|-------------|---------|-----|
| `dataExtractionEngine = .none` + expecting JSON extract | No API fields | `.cloudAPI` or `.inApp` |
| `.none` + `uploadWithoutProcessingIsOn = false` + local resources auto-delete | No retained `local_package_path` for local decoupling | Set `autoDeleteLocalResourcesAfterProcessing = false` |
| `uploadWithoutProcessingIsOn = true` without `.none` | Flag only applies with `.none`; other engines still process | Set `dataExtractionEngine = .none` for remote-package decoupling |
| `.none` + cloud-only response flags | Lens does not call Process a Document; flags do not shape the customer's later request | Set API options on the customer's backend request |
| `.none` + `sameFileUploadPreventionPolicy = .always` | Persistent policy requires Lens `.cloudAPI` confirmation | Use `.session` or `.none` |
| `webhookIsOn` + host only listens for immediate `success` | Missed results | Handle async or turn webhook off |
| `anyDocumentType` set | Deprecated local regex OCR, not a template | Leave empty; use `anyDocumentTemplate` |
| `useLegacyModels = false` | Debug-only flag; SDK currently forces true (legacy crop models) | Leave the default; do not set |
| `ocrRegex` on receipts flavor | Ignored | Code flavor |
