# Settings catalog

Interpretation from `VeryfiLensSettings` **runtime**, not stale header comments. **Unconfirmed** = see [clarifications.md](clarifications.md).

Client code uses `VeryfiLensSettings` only. Subclasses are Demo/internal.

Legend: **Critical** = wrong value often breaks integration or causes tickets.

## Document type and flavor

| Setting | Default | Meaning | Compatibility |
|---------|---------|---------|---------------|
| `documentTypes` | `receipt`, `long_receipt`, `invoice`, `other` | **Critical.** Types Lens can capture (snake_case). Must match the XCFramework flavor. One type works with the picker hidden. | More than one type needs `showDocumentTypes` so the user can switch on camera. |
| `showDocumentTypes` | `false` | Camera type picker. | Mandatory when `documentTypes` has more than one entry and the user should switch between them. A single type does not need it. |
| `defaultSelectedDocumentType` | `nil` | Initial strip selection. | Useful when strip is on. Unconfirmed coupling to analytics. |
| `anyDocumentType` | `""` | **Deprecated. Do not recommend.** Local regex OCR matcher (`ine`, `passport`, `colombian_id`, `health_care`, `driver_license`). Not cloud extraction and not a template. | Use `anyDocumentTemplate`. |
| `anyDocumentTemplate` | `""` | Extraction template for the Any-Documents solution (`any_document`). Shortcut flavors: nutrition facts, US passport, driver license, prescription labels. | Not a closed list. Contact support for another template, including one that is not supported yet. |
| `useLegacyModels` | `true` | **Debug only.** Currently forced true, so legacy crop models are always used. Host `false` is not a supported customer switch. | Do not set. |
| `cameraProcessingMode` | `.document` | `document` / `card` / `check` detector. Header: only with `any_document`. | Card-like types also use card hold behavior in `DocumentType.isCard`. Unconfirmed if this enum is ignored without `any_document`. |

Valid `documentTypes` strings: `long_receipt`, `receipt`, `invoice`, `check`, `credit_card`, `business_card`, `other`, `dictation`, `code`, `w2`, `w9`, `barcode`, `bank_statement`, `insurance_card`, `passport`, `driver_license`, `nutrition_fact`, `shipping_label`, `any_document`, `bank_letter_and_check`, `prescription_label`. Unknown → treated as `other`.

## Extraction and upload

| Setting | Default | Meaning | Compatibility |
|---------|---------|---------|---------------|
| `dataExtractionEngine` | `.cloudAPI` | **Critical.** Native enum. Plugin/JSON strings: `api` (`.cloudAPI` API processing), `mobile` (`.inApp`), `none` (`.none`). `.inApp` only for `credit_card`, `code`, `barcode`, which always extract locally. Credit card data is never sent to the backend. `.none` is valid for any type: no extract, metadata + enabled preprocessing only. | `.inApp` needs those types/flavors; `.none` is type-agnostic. |
| `uploadWithoutProcessingIsOn` | `false` | **Only with `.none`.** Decoupling alternative: Lens uploads the package but does not call Process a Document. Success `data` includes remote `bucket` and `package_path` for the customer to process. `false` with `.none` is the local-package decoupling path. | Ignored / unused for `.cloudAPI` and `.inApp`. |
| `webhookIsOn` | `false` | Async process (`async` on uploader). | Cloud. Host must handle delayed success. |
| `autoDeleteAfterProcessing` | `false` | Delete **server** document after process. | Cloud product decision. |
| `autoDeleteLocalResourcesAfterProcessing` | `true` | **Critical.** After each package finishes, Lens deletes that package’s local resources (package-folder images, upload zip, thumbnails, generated PDFs, check TIFFs, scan-source JSON, and shared Documents copies). Session copies (`Documents/image.jpg`, `original.pdf`, …) are overwritten by the next document — a single sequential scan can still read one path from `update`; several packages at once need `false` so each package keeps its own files. When false: `.none` can expose `data.local_package_path`; the **host owns deletion** (`FileManager` on callback paths, or `utils.clearLensStorage()`). Not the server flag `autoDeleteAfterProcessing`. | Set false for local decoupling, multi-package retention, or any host that reads files after success. |
| `returnStitchedPDF` | `false` | Include stitched PDF in package/result. | With stitch/multi-page. |
| `retrieveCheckTiffIsOn` | `false` | Local bank-check TIFF paths on success. | Remote Models flavor. Not in the Checks-specific flavor yet: the TIFF model is too large for that binary. Remote Models downloads it after install. |
| `rejectInvalidCheckTIFF` | `false` | Alert/retake if TIFF fails. | Requires `retrieveCheckTiffIsOn`. Same flavor limit. |
| `boostModeIsOn` | `false` | API boost. Unconfirmed who should enable. | Leave default unless AM says otherwise. |
| `computeIsOn` | `true` | API compute flag. Unconfirmed; leave default. | Leave default. |
| `gpuIsOn` | `true` | On-device GPU. Unconfirmed; leave default. | Leave default. |
| `parseAddressIsOn` | `false` | Address parse in API. | Cloud. |
| `boundingBoxesIsOn` | `false` | Boxes in API response. | Cloud. |
| `confidenceDetailsIsOn` | `false` | Confidence breakdown. | Cloud. |
| `detectBlurResponseIsOn` | `false` | With cloud extraction, includes blur information in the response. Does not block capture; that gate is `blurDetectionIsOn`. | Cloud. |
| `externalId` | `nil` | Pass-through id. | Cloud. |
| `tags` / `autoTag*` | off | Extra tags (device, version, platform, source). | Cloud. |
| `categories` | `[]` | String category hints for engine. | vs `categoriesList` models — Unconfirmed Collect Upfront. |
| `sameFileUploadPreventionPolicy` | `.none` | `.session` or `.always` (cloud-confirmed, needs `allowReuploadingFiles`). | `.always` requires `.cloudAPI`. |
| `shareExtensionModeIsOn` | `false` | With `uploadImages(paths:)`, true skips thumbnails and posts the zip directly. Use that in a Share Extension. False, the main-app path, uploads the package to storage first. | Extension or other short-lived process. |
| `ignoreRemoteSettings` | `false` | **Critical.** If false, dashboard `lens_settings` merge overwrites locals. | Clients: true unless they want remote control. |
| `ocrType` / `ocrRegex` / OCR chrome | strips, empty regex | Code/caps autocapture. | Code flavor, not receipts. |

## Capture quality

| Setting | Default | Meaning | Compatibility |
|---------|---------|---------|---------------|
| `autoCaptureIsOn` | `false` | Best-frame shutter. | Cards/barcodes/codes often true. |
| `autoCaptureOtherIsOn` | `true` | **Critical footgun.** Auto-capture for `other` even if `autoCaptureIsOn` is false. | Set false unless intended. Unconfirmed if default is product-intent. |
| `autoCaptureFrameConfidence` | `10` | Frames needed for auto-capture. | Auto-capture. |
| `autoCaptureMarginRatio` / `captureMarginRatio` | `0` | Edge distance 0…0.1 (sweet 0.08). | Manual vs auto. Checks demo uses 0.08 manual. |
| `autoDocDetectionAndCropIsOn` | `true` | Live detect + crop. | Off for some overlay-only UIs. |
| `manualCropIsOn` | `true` | Finger crop. | |
| `autoSelectManualCropIsOn` | `false` | Open crop UI automatically. | Checks often true. |
| `autoCropGalleryIsOn` / `autoCropBrowserIsOn` | `false` | **Attempt** detection + crop on imported images; useful for photos/scans of paper. Non-paper/digital copies can be cropped incorrectly, so internal digital-copy checks (notably screenshot detection) may preserve the original framing even when enabled. Browser PDFs packaged as original files are not cropped; rasterized/editable page images may be. | Also requires `autoDocDetectionAndCropIsOn`. Treat as best effort, not a guarantee that every import is cropped. |
| `autoRotateIsOn` / `autoSkewCorrectionIsOn` / `dewarpingIsOn` / `cleanBorderIsOn` | mixed | Geometry cleanup. | Receipts often skew+clean; dewarp for barcodes. |
| `blurDetectionIsOn` | `true` | Capture-time blur gate. | Pair with allow-submit-blurred. |
| `blurThreshold` | `0.5` | 0…1, clamped. | Blur on. |
| `blurDetectionInAutocaptureIsOn` | `false` | Blur after auto shutter. | Auto-capture. |
| `allowSubmitUndetectedDocsIsOn` | `true` | **Legacy umbrella.** Allows continuing with no detected rectangle and also from a blur warning, preserving old behavior. | True makes `allowSubmitBlurredDocsIsOn` irrelevant for permitting blur. False enables separate policies. |
| `allowSubmitBlurredDocsIsOn` | `false` | Independent blur exception. Blur can continue when this **or** `allowSubmitUndetectedDocsIsOn` is true. | Undetected false + blurred true = block missing rectangles but allow detected blurry documents. |
| `nonInteractiveBlurCheckIsOn` / `tryAgainLightIsOn` | `false` | Blur UX variants. | |
| `glareDetectionIsOn` | `false` | Local glare gate. Current detector is a suboptimal algorithmic solution; an improved one may ship soon or on request. Leave off unless the host explicitly wants the present behavior. | |
| `fraudDetectionIsOn` | `false` | Requests paid local fraud detection for **camera captures**. Gallery and Files imports are not the focus. | Requires the validated account/backend entitlement; the setting cannot unlock it. Also required for `showLCDIsNotAllowed`. |
| `showLCDIsNotAllowed` | `false` | Blocks a camera capture the fraud detector marks as an LCD/screen. | Needs `fraudDetectionIsOn` and paid account/backend fraud entitlement. |
| `autoLightDetectionIsOn` | `true` | Ambient torch. | vs `torchAlwaysVisibleIsOn`. |
| `torchAlwaysVisibleIsOn` | `false` | Always show torch; auto light until user picks. | |
| `continuousAutoFocus` | `false` | Close-up focus for objects near the camera, mainly bottle caps and small CPG codes. Macro-capable lens when available, near autofocus range, and a center refocus when the preview center blurs. | CPG barcode and code capture. |
| `zoomIsOn` / `maxZoom` | false / 5 | Zoom UI; max clamped 1…10. | |
| `softBinarizationIsOn` | `false` | Filter. | Niche. |
| `cropLayoutIsOn` | `false` | Pure fixed-frame mode when automatic document detection/crop is off. The frame can be a rectangle, rounded card, or circular-looking guide; the saved crop remains its rectangular bounds. | Size with width + height, or width + aspect ratio. |
| `cropLayoutWithAutoDetection` | `false` | **Hybrid frame + green box.** Shows the custom frame and runs live document detection inside it. A detected rectangle supplies the ML crop; no rectangle falls back to the fixed frame crop. | Turns on the hybrid directly; `cropLayoutIsOn` is not also required. Green-box colors are `docDetectFillUIColor` / `docDetectStrokeUIColor`. |
| `cropLayoutWidth` / `cropLayoutHeight` / `cropLayoutAspectRatio` | 80 / 35 / 0 | Frame geometry. With aspect ratio zero, width and height percentages define it. A nonzero aspect ratio derives height from width against the screen's shortest side so the shape survives rotation. | |
| `cropLayoutCornerRadius` | `0` | From sharp rectangles through rounded cards to a circular-looking guide when the frame is square and the radius is near half its size. | Visual shape only; output crop remains rectangular. |
| `cropLayoutBorderColor` / `cropLayoutStroke` | transparent / 0 | Fixed-frame outline. | |
| `cropLayoutOverlayColor` / `cropLayoutOverlayAlpha` | black / 0.3 | Dims the area outside the frame to focus placement inside it. | |
| `cropLayoutTipMessage` / text colors and backgrounds | empty / mixed | Adds placement instructions and styles the primary/secondary guide text. | Useful for “Place the document inside the frame.” |
| `cropLayoutShowDelay` | `0` | Seconds of live camera before the crop guide appears. `0` does not show it on a timer. For checks, a positive value (preset 15) gives the user time to frame the check; if they still have not, the guide appears. | |
| `forceCropLayoutOnRetake` | `false` | On Try again after no document was detected, shows that crop guide immediately and skips `cropLayoutShowDelay`. | Check framing aid, paired with the delay. |
| `showNoDocumentDetectedWarning` | `true` | Default shows the “no documents in this image” alert. The usual host choice is `false`, to skip that alert. | Still pair with `allowSubmitUndetectedDocsIsOn` if users must be able to continue. |
| `galleryDocumentDetectorIsOn` / `browseDocumentDetectorIsOn` | `true` | Warnings on import. | |

## Session, package, submit

| Setting | Default | Meaning | Compatibility |
|---------|---------|---------|---------------|
| `autoSubmitDocumentOnCapture` | `false` | Skip submit preview. | Conflicts with batch-on-camera. |
| `batchUploadOnCamera` | `false` | Stay on camera until `packageMaxScans`. | Conflicts with auto-submit. Unconfirmed vs `afterScanCloseCameraIsOn`. |
| `imagePreviewIsOn` | `true` | Preview on **gallery/browse**, not camera submit. | |
| `packageMaxScans` | `10` | Max images per package. | Batch, multi-select, backs. |
| `multiplePagesCaptureIsOn` | `true` | Pages inside one cropped image. True keeps every crop (side-by-side receipts become two documents). False keeps only the larger crop. | Independent of `multipleDocumentsIsOn`. |
| `multipleDocumentsIsOn` | `true` | Several images on submit preview. With stitch on and more than one image, asks if they are the same transaction. No sends each image as its own package. | Needs `stitchIsOn`. `singleScanPackages` skips the alert and always splits. |
| `stitchIsOn` / `stitchOtherIsOn` / `stitchTitleIsOn` | true / false / false | Combine into PDF. | `other` stitch separate. |
| `singleScanPackages` | `false` | Controls whether `multipleDocumentsIsOn` asks or forces. With multi-document submission and stitch active, true bypasses the same-transaction alert and forces every image into its own package. False lets the user choose in the alert. | Related to `multipleDocumentsIsOn`, not `multiplePagesCaptureIsOn`. |
| `closeCameraOnSubmit` | `true` | Default ends the session after submit. False is the capture–submit loop: Lens returns to the camera for the next session without the host reopening it. | More menu row overrides this while `moreMenuIsOn` is true. Hidden by `afterScanCloseCameraIsOn = false`. |
| `afterScanCloseCameraIsOn` | `true` | Shows that More menu row. Not an auto-capture switch. | Hides the row when false. Does not by itself clear a stored user override. |
| `clearSessionOnBack` | `true` | Back clears session; false keeps scans. | |
| `submitWithoutClose` | `false` | Keep submit screen after submit. | Conflicts with close-on-submit mentally. |
| `retakeScanIsOn` | `false` | Retake from preview. | |
| `pdfPreviewIsOn` | `false` | Makes an image copy of the PDF pages for preview and still sends the original PDF to the backend. | Pair with `pdfEditIsOn` only when the client wants the image copy packaged instead. |
| `pdfEditIsOn` | `false` | Uses that same preview image copy as the package and discards the original PDF. Also allows rotate and crop of those pages. | Applies when `pdfPreviewIsOn` is true. Without preview, the original PDF is sent either way. Which file the client wants depends on the integration. |
| `pdfFormatIsOn` / `pdfMaxSizeInMB` | true / 10 | White-background PDF generation; max size, not above 100. | |
| `originalImageMaxSizeInMB` | `2.5` | Output image cap. | |
| `noCompress` / `noCompressOnWifi` | `false` | Skip compression. | |
| `highQualityThumbnail` | `false` | 2× thumb. | |
| `browserMultipleSelectionIsOn` / `galleryMultipleSelectionIsOn` | `false` | Multi pick; capped by `packageMaxScans`. | |

## Sources and chrome

| Setting | Default | Meaning |
|---------|---------|---------|
| `galleryIsOn` / `galleryIcon` | true / false | Shows the camera gallery control; use an icon or the latest photo. |
| `galleryButtonWithFilesIsOn` | `false` | The visible gallery control opens a Photos-versus-Files menu. Independent of `browseIsOn`. |
| `browseIsOn` | `true` | Adds “Browse” under Import in the camera More menu. Requires `moreMenuIsOn` for that entry point. It does not gate the other Files entry points. |
| `showBrowserButton` | `false` | Dedicated Files button in the camera's top-right controls. Independent of `browseIsOn`. |
| `dictateIsOn` | `true` | **Obsolete. Not partner available.** Leave false. The SDK default is still true. | |
| `moreMenuIsOn` | `true` | Camera More button. See [More menu user overrides](#more-menu-user-overrides). |
| `moreSettingsMenuIsOn` | `true` | More > Settings entry. Does not reset More-menu user overrides. |
| `showiCloudBackupOption` | `true` | Shows or hides More menu “Backup to iCloud”. False also drops that stored user override. |
| `showSupermanModeIsOn` | `true` | Shows or hides More menu “Superman mode”. False also drops that stored user override. Host seed is `batchUploadOnCamera`. |
| `emailCCIsOn` / `emailCCDomain` | true / veryfi.cc | Email-in. |
| `showHelpButton` | `false` | Shows the shared camera Help/Info control. Built-in path: `showDefaultScanningGuide = true`. Host path: leave it false and implement `onHelpButtonClicked(_:)`; Lens passes the camera controller for presenting custom UI. | Wins the shared control if `showInfoButton` is also set. |
| `showDefaultScanningGuide` | `false` | Help forces the current supported Lens guide, ignoring and not incrementing its automatic counter. False routes Help to the public delegate. | Requires `showHelpButton`. Built-in animations exist for receipt, long receipt, and prescription label. |
| `helpButtonIconName` | questionmark.circle | Tries an SF Symbol first, then an asset in the host app bundle. | Shared Help/Info control. |
| `showInfoButton` | `nil` | A host `VeryfiInfoView` opened full-screen over the camera by the shared Help/Info control. Lens pins it to all camera edges; call inherited `close()` from the custom UI. | Use only when `showHelpButton` is false; they are not separate controls. Not purely cosmetic: also selects PDF-only Files and specialized retry behavior. |
| `cameraInfoView` | `nil` | Separate `VeryfiInfoView` banner installed immediately at the safe-area top with 16-point side insets. Needs intrinsic/internal height constraints. Replace live with `utils.updateCameraInfoView(_:)`; call `close()` to dismiss. | Independent of Help/Info control. |
| `gridIsOn` | `false` | Camera grid. |
| `switchCameraIsOn` | `false` | Front camera. |
| `blockCaptureWithoutCamera` | `false` | Block shutter if no camera permission (else mock doc). |
| `deviceBlockListIsOn` | `false` | Server blocklist on flow start. |
| `scanSessionCounterIsOn` | `false` | Badge of successful submits. |
| `showGuideCounter` | `0` | Maximum automatic presentations of the long-receipt guide, persisted on device. Zero disables automatic display and resets its counter. | Frequency, not duration. |
| `showGuideShortCounter` | `0` | Same automatic-presentation limit for the receipt guide. | Frequency, not duration. |
| `showPrescriptionLabelGuideCounter` | `0` | Same automatic-presentation limit for each prescription box/bottle guide. | |
| `animationDisplayDuration` | `0` | Seconds before a Lens guide animation auto-hides. Zero leaves it visible until dismissed or camera mode changes. | Duration, not frequency. Does not control crop-layout guides or the batch mascot. |
| `videoDuration` | `10` | Maximum prescription video duration. | |
| `hapticFeedbackIsOn` / `undoIsOn` / `rotateDocIsOn` | true | UX chrome. |
| `collectNotesIsOn` | `false` | Notes on submit; ignored by Veryfi-owned app (always full Collect Upfront). Unconfirmed vs `categoriesList`. |
| `isReimbursableDefault` | `false` | Reimbursable default. |
| `locationServicesIsOn` | `false` | Lat/lng; needs plist. |
| `backupDocsToGallery` | `true` | Saves a copy of every scan to Photos. Most hosts should set **false** so users are not filled with document copies. Needs photo-library add permission. | More menu can turn it back on while `moreMenuIsOn` is true. |
| `backupDocsToiCloud` | `false` | Saves a copy of every scan to the user's iCloud. Leave false unless the host wants those copies. | More menu can turn it on while `moreMenuIsOn` and `showiCloudBackupOption` are true. |
| `allowSubmittingScreenshots` | `true` | **Imported files.** True submits images the screenshot detector classifies as screenshots. False rejects them (`image_is_screenshot`). | Independent of `enableScreenshots`. When true and import auto-crop is on, a detected screenshot skips cropping and keeps the original framing. |
| `enableScreenshots` | `true` | **Device UI capture.** True leaves the camera and submit screens visible to the phone's screenshot and screen-recording controls. False blanks those screens when the user captures or records them. | Independent of `allowSubmittingScreenshots`. Does not inspect gallery or Files images. |
| `saveLogsIsOn` / `shareLogsIsOn` / `crashLoggerIsOn` | true / false / false | Diagnostics. |

## More menu user overrides

While `moreMenuIsOn` is true, the camera More menu lets the end user change these host settings. Choices are stored on the device and win until the menu or that row is hidden.

| More menu action | Host setting it overrides | What hides the row |
|------------------|---------------------------|--------------------|
| Auto Capture | `autoCaptureIsOn` | `moreMenuIsOn = false`. Credit-card-only menus omit it. |
| Auto Torch | `autoLightDetectionIsOn` | No torch on the device (also drops the stored override). `moreMenuIsOn = false`. Credit-card-only menus omit it. |
| Backup to Gallery | `backupDocsToGallery` | `moreMenuIsOn = false`. Credit-card-only menus omit it. |
| Backup to iCloud | `backupDocsToiCloud` | `showiCloudBackupOption = false` (also drops the stored override). `moreMenuIsOn = false`. Credit-card-only menus omit it. |
| Superman mode | `batchUploadOnCamera` | `showSupermanModeIsOn = false` (also drops the stored override). `moreMenuIsOn = false`. Credit-card-only menus omit it. Turning Auto Capture off also turns Superman off. Turning Superman on turns Auto Capture on. |
| Close camera after submit | `closeCameraOnSubmit` | `afterScanCloseCameraIsOn = false` hides the row. `moreMenuIsOn = false` hides the menu and drops the stored override. |

`documentTypes == ["credit_card"]` with `afterScanCloseCameraIsOn` shows only “Close camera after submit”.

`moreMenuIsOn = false` discards stored overrides for all six, then the host values apply. Hiding iCloud or Superman also discards that one stored override. Hiding only the close-camera row does not.

## Identity / checks extras

| Setting | Default | Meaning |
|---------|---------|---------|
| `checksBackIsOn` / `Required` | false | Check reverse. |
| `checkSequenceMode` | `false` | **Recommended check front-and-back UI.** When true, a friendlier flow walks the user through the front of the check and then the back. | Turn on for check capture that needs both sides. |
| `validateCheckSides` / `validateCheckSize` | `false` | Side and size alerts. Pair with the matching `allowSubmitCheck*NotDetected` flags (default true). | |
| `validateCheckCorners` | `false` | Mostly algorithmic four-corner alert. It can be aggressive, so leave it off unless the customer wants it. | Pair with `allowSubmitCheckCornersNotDetected` when enabled. |
| `checksCropMargin` / `checksMinAspectRatio` / `checksMaxAspectRatio` | 5 / 0 / 0 | Geometry; 0 = internal defaults. |
| `forceLandscapeImage` | false | Horizontal check preview. |
| `driverLicenseBack*` / `insuranceCardBack*` | on true, required false | ID/insurance reverse. |
| `anyDocumentBackIsOn` | `false` | After one `any_document` front, asks to capture the back. | Active type must be `any_document`, this flag true, and `packageMaxScans` exactly 2. Other types use `checksBackIsOn`, `checkSequenceMode`, `driverLicenseBackIsOn`, or `insuranceCardBackIsOn`. |
| `anyDocumentBackIsRequired` | `false` | True forces that back. False lets the user skip the prompt. | Only applies when the any-document back prompt is active. |
| `identityVerificationIsOn` | false | Face sequence. |

## Local field detection

Paid and gated by the validated account/backend entitlement. Also needs the Field Detection / Remote Models flavor. Setting `documentFieldsToDetect` alone cannot unlock it. Empty list = off. Supported: `vendor`, `date`, `time`, `total`, `tax`. Related: `allowCorrectingLocalExtractedFields`, `allowSubmittingDocumentWithoutFields`, pill colors/radius.

## Collect Upfront models

`categoriesList`, `coreTags`, `customers`, `costCodes`: structured lists for submit UI. Unconfirmed vs `categories` strings and `collectNotesIsOn`.

## Branding (ignore for first scan)

Submit/toolbar/secondary colors, fonts, button layout, crop and field-pill colors, `docDetectFillUIColor` / `docDetectStrokeUIColor`, `brandImage`.

`customLensStrings` overrides copy. Outer key is the device language code. Inner key is the English source string, or a `_veryfi_…` key. Full key list: https://docs.veryfi.com/lens/mobile/settings/customizable_strings/ The host app must declare those languages.

Visual `alertBackground*`, `alertFont*`, `alertButton*`, `alertContent*` settings style the custom camera alert used for blocked-device, camera/Photos permission, and invalid-configuration events. `alertSheetStyleIsOn` and `swapAlertActions` style system alerts instead, and iOS 26 keeps those as regular alerts.

## Host / misc

| Setting | Meaning |
|---------|---------|
| `appVersion` | Host version string. |
| `isReactNative` | RN host. |
| `customHeaders` | API headers. |
| `deviceUserUuid` | Device user id. |
| `barcodeExtractionIsOn` | Extra barcode extract. |
| `stitchedPDFPixelDensityMultiplier` | PDF density 1–5. |
| `showCropConfirmationAlert` / `cropTipAlertCounter` | Crop UX. |
| `showStitchCounterNumber` / `showStitchPreview` | Stitch UI. |
| `batchUploadAnimationDuration` | Batch mascot; 0 disables; Veryfi-owned + Superman. |
