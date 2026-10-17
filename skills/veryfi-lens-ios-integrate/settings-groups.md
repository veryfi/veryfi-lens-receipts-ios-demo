# Settings groups (future internal helpers)

Not public SDK types. When adding Demo or internal factories later, use these IDs. Each group mutates `VeryfiLensSettings` only.

Compose: **ExtractionMode** + **CaptureFlow** + **CaptureSources** + **QualityGate** + **MultiPage** + optional extras + **Chrome** + **Branding**.

## ExtractionMode

| ID | Flags | Use |
|----|-------|-----|
| `CloudProcess` | `dataExtractionEngine = .cloudAPI` (`"api"`), `uploadWithoutProcessingIsOn = false` | Veryfi API processing |
| `InApp` | `dataExtractionEngine = .inApp` (`"mobile"`) | Only `credit_card`, `code`, `barcode`; those types always extract locally. Credit card data is never sent to the backend. |
| `DecoupledLocalPackage` | `dataExtractionEngine = .none` (`"none"`), `uploadWithoutProcessingIsOn = false`, `autoDeleteLocalResourcesAfterProcessing = false` | Any `documentTypes`. No extract; metadata + enabled preprocessing. Retain `local_package_path`; customer owns upload and Process a Document |
| `DecoupledRemotePackage` | `dataExtractionEngine = .none` (`"none"`), `uploadWithoutProcessingIsOn = true` | Any type. Lens uploads; Process a Document is not called. Customer processes using remote `bucket` / `package_path` |
| `VisualOnly` | `dataExtractionEngine = .none` (`"none"`), `uploadWithoutProcessingIsOn = false` | Any type. Local package/PDF, no extract |

## CaptureFlow

| ID | Flags |
|----|-------|
| `ReviewThenSubmit` | `autoSubmitDocumentOnCapture = false`, `batchUploadOnCamera = false`, `imagePreviewIsOn = true` |
| `AutoSubmit` | `autoSubmitDocumentOnCapture = true`, `batchUploadOnCamera = false` |
| `BatchToMaxThenReview` | `batchUploadOnCamera = true`, `autoSubmitDocumentOnCapture = false`, `packageMaxScans` set |

Do not combine AutoSubmit with BatchToMaxThenReview.

## CaptureSources

| ID | Flags |
|----|-------|
| `CameraOnly` | `galleryIsOn = false`, `browseIsOn = false`, `showBrowserButton = false`, `dictateIsOn = false` (obsolete; not partner available) |
| `CameraPlusGallery` | `galleryIsOn = true`; set `galleryButtonWithFilesIsOn = false` for Photos only |
| `CameraPlusFiles` | Choose an entry point: More menu (`moreMenuIsOn = true`, `browseIsOn = true`), dedicated top-right button (`showBrowserButton = true`), or gallery-control Photos/Files menu (`galleryIsOn = true`, `galleryButtonWithFilesIsOn = true`) |
| `FilesFirst` | Present `showDocumentBrowser(in:)` / `.documentBrowser` as the standalone primary flow; camera source flags are not required |

`galleryOtherIsOn` / `browseOtherIsOn` only if `other` is in `documentTypes` and those sources should differ.

`autoCropGalleryIsOn` / `autoCropBrowserIsOn` are optional best-effort overlays for paper photos/scans and also require `autoDocDetectionAndCropIsOn`. Do not assume every import is cropped: internal digital-copy checks preserve known screenshots/digital copies, and an original-file PDF is not page-cropped.

## QualityGate

| ID | Flags |
|----|-------|
| `Lenient` | `allowSubmitUndetectedDocsIsOn = true` — legacy umbrella permits no-document and blur warnings. `allowSubmitBlurredDocsIsOn` is redundant while this is true. |
| `Balanced` | `blurDetectionIsOn = true`, `allowSubmitUndetectedDocsIsOn = false`, `allowSubmitBlurredDocsIsOn = true` — require a detected rectangle but let users accept blur. |
| `StrictBanking` | `allowSubmitUndetectedDocsIsOn = false`, side and size check validators on, crop layout on retake, `captureMarginRatio = 0.08`. `validateCheckCorners` stays off unless the customer wants it. |

## MultiPage

| ID | Flags |
|----|-------|
| `SingleFrame` | `stitchIsOn = false`, `multiplePagesCaptureIsOn = false` — one image keeps only the larger crop |
| `StitchToPdf` | `stitchIsOn = true`, `multiplePagesCaptureIsOn = true`, `singleScanPackages = false`, `returnStitchedPDF = true` |
| `SeparatePackages` | `multipleDocumentsIsOn = true`, `stitchIsOn = true`, `singleScanPackages = true` — bypass the same-transaction alert and force every image into its own package. Leave `singleScanPackages = false` to let the user choose in the alert. |

## Compliance

| ID | Flags |
|----|-------|
| `NoGalleryBackup` | `backupDocsToGallery = false`, `backupDocsToiCloud = false` — do not fill the user's Photos or iCloud with copies of their documents |
| `KeepLocalResources` | `autoDeleteLocalResourcesAfterProcessing = false` — host owns `FileManager` / `clearLensStorage()`; required when several packages must stay on disk |
| `NoScreenshotSubmit` | `allowSubmittingScreenshots = false` — rejects imported images classified as screenshots. Device screenshots of the camera UI are `enableScreenshots`. |
| `DeviceBlocklist` | `deviceBlockListIsOn = true` |
| `SameFileSession` | `sameFileUploadPreventionPolicy = .session` |
| `SameFileAlways` | `.always` + `dataExtractionEngine = .cloudAPI` |

Local fraud detection and local field detection are extra paid features. Their settings request
the behavior, but the validated account/backend entitlement must enable it. Field detection also
requires the Field Detection or Remote Models flavor.

## IdentityExtras

| ID | Flags |
|----|-------|
| `BackOptional` | matching `*BackIsOn = true`, `*BackIsRequired = false` |
| `BackRequired` | `*BackIsOn` and `*BackIsRequired = true`; `packageMaxScans = 2` for any-document backs |
| `FaceVerify` | `identityVerificationIsOn = true` |
| `CropLayoutGuide` | Pure fixed frame: `cropLayoutIsOn = true` with automatic detection/crop off. Hybrid frame + green box: `cropLayoutWithAutoDetection = true` (does not also require `cropLayoutIsOn`), with green-box colors in `docDetectFillUIColor` / `docDetectStrokeUIColor`. Shape with width + height/aspect ratio + corner radius: sharp rectangle → rounded card → circular-looking square guide. The saved crop stays rectangular. Overlay and tip settings focus and instruct placement. For checks: `cropLayoutShowDelay` reveals the guide later; `forceCropLayoutOnRetake` shows it immediately after a no-document retake. |

## BankingExtras

| ID | Flags |
|----|-------|
| `CheckBack` | `checkSequenceMode = true` (recommended front-then-back UI), `checksBackIsOn`, `forceLandscapeImage` |
| `CheckValidation` | `validateCheckSides`, `validateCheckSize`, and the allow-submit flags. `validateCheckCorners` stays off unless the customer wants it: the check is mostly algorithmic and can be aggressive. |
| `CheckTiff` | `retrieveCheckTiffIsOn`, optional `rejectInvalidCheckTIFF`. Remote Models flavor only. The Checks-specific flavor does not include the TIFF model yet because of its size. |

## Chrome

| ID | Flags |
|----|-------|
| `GuideAnimation` | Automatic frequency: `showGuideShortCounter` (receipt), `showGuideCounter` (long receipt), `showPrescriptionLabelGuideCounter` (box/bottle). Lifetime: `animationDisplayDuration` (`0` waits for dismissal/mode change). Replay: `showHelpButton = true` + `showDefaultScanningGuide = true` forces the current supported guide without incrementing its counter; false routes Help to the host callback. Independent of crop-layout guides and the batch mascot. |
| `CameraHelpOrInfo` | One shared control: (a) Help + built-in guide, (b) Help + `onHelpButtonClicked(_:)` host presentation, or (c) `showInfoButton` + full-camera `VeryfiInfoView`. Do not combine Help and `showInfoButton` expecting two buttons; Help wins. `cameraInfoView` is an independent safe-area top banner and can be replaced live with `utils.updateCameraInfoView(_:)`. |
| `Minimal` | `moreMenuIsOn = false` (drops stored More-menu overrides), `moreSettingsMenuIsOn = false`, `shareLogsIsOn = false`, `showiCloudBackupOption = false`, `showSupermanModeIsOn = false` |
| `FullDemo` | more menu on, logs share, document type strip — **not** for most clients |

## Branding

Apply last: submit button colors, fonts, alert colors, `docDetectFillUIColor`, crop-layout colors, field-pill colors, `customLensStrings`, `brandImage`, `cameraInfoView`. Never required for a first successful scan.

## Mapping recipes → groups

| Recipe | Groups |
|--------|--------|
| `decoupled-capture` | DecoupledLocalPackage + ReviewThenSubmit + CameraPlusGallery + Balanced + StitchToPdf + Minimal |
| `decoupled-remote-package` | DecoupledRemotePackage + ReviewThenSubmit + CameraPlusGallery + Balanced + StitchToPdf + Minimal |
| `cgp-expense` | CloudProcess + ReviewThenSubmit + CameraPlusGallery + Balanced + StitchToPdf + Minimal |
| `banking-checks` | CloudProcess + ReviewThenSubmit + CameraPlusGallery + StrictBanking + SingleFrame + CheckBack + CheckValidation + Minimal |
| `any-documents` | CloudProcess + ReviewThenSubmit + CameraOnly + Balanced + IdentityExtras + Minimal. Marketed as Any-Documents (`any_document` + `anyDocumentTemplate`). Nutrition facts, US passport, driver license, and prescription labels are shortcut flavors. |
| `visual-scan-to-pdf` | VisualOnly + AutoSubmit + StitchToPdf + Minimal |
| `cpg-barcode` / `cpg-code` / `credit-cards` | InApp + CameraOnly + Minimal |
