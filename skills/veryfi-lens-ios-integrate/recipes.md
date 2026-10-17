# Recipes

Apply on a fresh `VeryfiLensSettings()`. Do not use `VeryfiLens*Settings` subclasses.

Always apply **base hardening**, then **one** industry recipe, then optional overlays from [settings-groups.md](settings-groups.md). Skip flags the host did not ask for.

Group IDs in comments match future internal helpers (`ExtractionMode.CloudProcess`, etc.).

## Base hardening (every client)

```swift
let settings = VeryfiLensSettings()
settings.ignoreRemoteSettings = true          // unless host wants dashboard overrides
settings.backupDocsToGallery = false          // otherwise every scan is copied into Photos
settings.backupDocsToiCloud = false           // otherwise every scan is copied into iCloud
settings.moreSettingsMenuIsOn = false
settings.autoCaptureOtherIsOn = false         // SDK default true
settings.showNoDocumentDetectedWarning = false // usual choice: skip the no-document alert
settings.dictateIsOn = false                  // obsolete; not partner available
settings.locationServicesIsOn = false
settings.enableScreenshots = true             // device screenshots of camera UI; imported files are allowSubmittingScreenshots
```

If the host displays captured files after callbacks, or keeps several in-flight packages:

```swift
settings.autoDeleteLocalResourcesAfterProcessing = false  // host owns FileManager / clearLensStorage()
```

## CGP / expense (`cgp-expense`)

**Groups:** ExtractionMode.CloudProcess, CaptureFlow.ReviewThenSubmit, CaptureSources.CameraPlusGallery, QualityGate.Balanced, MultiPage.StitchToPdf (optional), Chrome.Minimal

**Flavor:** Receipts or Full. Field Detection only if using `documentFieldsToDetect`.
Local field detection is a paid feature gated by the validated account/backend entitlement;
the flavor and setting do not unlock it by themselves.

```swift
settings.dataExtractionEngine = .cloudAPI
settings.documentTypes = ["receipt", "invoice", "other"]
settings.showDocumentTypes = true             // required to switch when more than one document type is set
settings.defaultSelectedDocumentType = "receipt"
settings.autoSubmitDocumentOnCapture = false
settings.batchUploadOnCamera = false
settings.imagePreviewIsOn = true
settings.galleryIsOn = true
settings.browseIsOn = true
settings.showBrowserButton = false
settings.dictateIsOn = false                  // obsolete; not partner available
settings.autoCaptureIsOn = false
settings.autoDocDetectionAndCropIsOn = true
settings.autoRotateIsOn = true
settings.autoSkewCorrectionIsOn = true
settings.cleanBorderIsOn = true
settings.dewarpingIsOn = false
settings.stitchIsOn = true
settings.stitchOtherIsOn = false
settings.multipleDocumentsIsOn = true        // submit preview can send each image as its own package
settings.multiplePagesCaptureIsOn = true      // side-by-side pages in one photo stay separate crops
settings.singleScanPackages = false
settings.returnStitchedPDF = true
settings.packageMaxScans = 10
settings.moreMenuIsOn = false
settings.closeCameraOnSubmit = true          // false keeps the camera open for the next capture–submit loop
settings.sameFileUploadPreventionPolicy = .session
settings.allowSubmittingScreenshots = true    // imported screenshot files; device UI capture is enableScreenshots
settings.webhookIsOn = false                  // true if host uses async webhooks
settings.autoDeleteAfterProcessing = false    // server-side delete; product decision
```

Paid Field Detection feature only. Confirm the account/backend entitlement first, then use the
Field Detection or Remote Models flavor:

```swift
settings.documentFieldsToDetect = ["vendor", "date", "time", "total", "tax"]
settings.allowCorrectingLocalExtractedFields = true
settings.allowSubmittingDocumentWithoutFields = true
```

**Do not set:** check/ID/OCR-only flags, `ocrRegex`, `cameraProcessingMode`, `uploadWithoutProcessingIsOn`.

## Banking / checks (`banking-checks`)

**Groups:** ExtractionMode.CloudProcess, CaptureFlow.ReviewThenSubmit, CaptureSources.CameraPlusGallery (optional), QualityGate.StrictBanking, MultiPage.SingleFrame, BankingExtras.*, Chrome.Minimal

**Flavor:** Checks for capture. Bank-check TIFF is not in that specific flavor yet because the TIFF model is large. Use Remote Models when `retrieveCheckTiffIsOn` is needed, and whenever SDK size is a concern: most heavy models download after install. Measure the final app with the SDK linked and without it. The XCFramework and AAR file sizes are not the installed size. [SDK binary sizes](https://docs.veryfi.com/lens/mobile/settings/sdk_binary_sizes/).

```swift
settings.dataExtractionEngine = .cloudAPI
settings.documentTypes = ["check"]
settings.showDocumentTypes = false
settings.stitchIsOn = false
settings.autoCaptureIsOn = false
settings.galleryIsOn = true
settings.browseIsOn = true
settings.moreMenuIsOn = false
settings.checksBackIsOn = true
settings.checksBackIsRequired = false         // true if both sides always required
settings.checkSequenceMode = true             // recommended front-then-back check UI
settings.forceLandscapeImage = true
settings.autoSelectManualCropIsOn = true
settings.autoRotateIsOn = true
settings.autoSkewCorrectionIsOn = false
settings.captureMarginRatio = 0.08
settings.checksCropMargin = 2
settings.checksMinAspectRatio = 1.9
settings.checksMaxAspectRatio = 2.85
settings.forceCropLayoutOnRetake = true       // failed check detection: show the guide immediately
settings.cropLayoutShowDelay = 15.0           // after 15s still on camera, show the check guide
settings.cropLayoutAspectRatio = 2.18
settings.cropLayoutWidth = UIDevice.current.userInterfaceIdiom == .pad ? 42 : 60
settings.cropLayoutCornerRadius = 5
settings.cropLayoutOverlayAlpha = 0.3
settings.validateCheckSize = true
settings.validateCheckSides = true
settings.validateCheckCorners = false         // optional; algorithmic and can be aggressive — customer choice
settings.allowSubmitCheckSideNotDetected = true
settings.allowSubmitCheckCornersNotDetected = true
settings.allowSubmitUndetectedDocsIsOn = false
settings.returnStitchedPDF = true
```

Remote Models flavor only (not the Checks-specific flavor):

```swift
settings.retrieveCheckTiffIsOn = true         // TIFF model downloads after install
settings.rejectInvalidCheckTIFF = true        // hard-fail if TIFF cannot be built
```

**Do not set:** `autoSubmitDocumentOnCapture`, `batchUploadOnCamera`, receipt stitch, `documentFieldsToDetect` unless that flavor exists.

## Any-Documents (`any-documents`)

**Groups:** ExtractionMode.CloudProcess, CaptureSources.CameraOnly (typical), IdentityExtras, QualityGate.Balanced, Chrome.Minimal

This is the **Any-Documents** solution: `documentTypes` is `any_document` and `anyDocumentTemplate` names the document. The template list is not closed. A type that is not supported yet can be arranged later. Contact support for any template other than the ones already confirmed for the account.

Shortcut flavors of Any-Documents: nutrition facts, US passport, driver license, and prescription labels. A shortcut flavor is the same solution with a narrower binary, not a separate product.

```swift
settings.dataExtractionEngine = .cloudAPI
settings.documentTypes = ["any_document"]
settings.anyDocumentTemplate = "us_passport"  // or the template support confirmed, e.g. us_driver_license
// do not set anyDocumentType — deprecated local regex OCR
settings.showDocumentTypes = false
settings.cameraProcessingMode = .card         // valid only for any_document; .document for a page-shaped label
settings.stitchIsOn = false
settings.galleryIsOn = false                  // true only if product allows photo import
settings.browseIsOn = false
settings.moreMenuIsOn = false
settings.autoCaptureIsOn = false
settings.autoRotateIsOn = true
settings.cleanBorderIsOn = true
settings.autoDocDetectionAndCropIsOn = true
settings.returnStitchedPDF = true
```

Back of an any document. The prompt runs only when the active type is `any_document`, `anyDocumentBackIsOn` is true, and `packageMaxScans` is exactly 2. `anyDocumentBackIsRequired` forces the back; false lets the user skip.

```swift
settings.anyDocumentBackIsOn = true
settings.anyDocumentBackIsRequired = false    // true to force the back
settings.packageMaxScans = 2                  // must be exactly 2
```

Optional: `identityVerificationIsOn = true` for a face sequence.

**Do not set:** dedicated ID back flags (`driverLicenseBackIsOn`, `insuranceCardBackIsOn`), check validators, `ocrType`, credit-card in-app engine, or `anyDocumentType`.

## Decoupled capture — customer processes with Veryfi API (`decoupled-capture`)

**Groups:** ExtractionMode.DecoupledLocalPackage, CaptureFlow.ReviewThenSubmit, CaptureSources.CameraPlusGallery, QualityGate.Balanced, MultiPage.StitchToPdf (optional), Chrome.Minimal

Use this when Lens should capture and package, but the customer owns Process a Document. Two alternatives, both with `dataExtractionEngine = .none`:

1. **Local package** (`uploadWithoutProcessingIsOn = false`): host reads `local_package_path` and uploads the zip.
2. **Remote package** (`uploadWithoutProcessingIsOn = true`): Lens uploads; Process a Document is not called. Host processes later with success `bucket` and `package_path`.

### Local package (default)

```swift
settings.dataExtractionEngine = .none
settings.uploadWithoutProcessingIsOn = false  // local zip; customer owns upload + Process a Document
settings.autoDeleteLocalResourcesAfterProcessing = false // host owns files; required to retain zip + per-package images
settings.returnStitchedPDF = true             // optional; zip remains the canonical handoff
settings.autoSubmitDocumentOnCapture = false
settings.batchUploadOnCamera = false
settings.imagePreviewIsOn = true
settings.autoDocDetectionAndCropIsOn = true
settings.autoRotateIsOn = true
settings.autoSkewCorrectionIsOn = true
settings.cleanBorderIsOn = true
settings.multiplePagesCaptureIsOn = true
settings.multipleDocumentsIsOn = true
settings.singleScanPackages = false
settings.stitchIsOn = true
settings.packageMaxScans = 10
settings.galleryIsOn = true
settings.browseIsOn = true
settings.showBrowserButton = true
settings.moreMenuIsOn = false
settings.webhookIsOn = false                  // Process a Document is owned by the customer
settings.autoDeleteAfterProcessing = false    // Lens cloud process flag; unused here
settings.sameFileUploadPreventionPolicy = .session // .always requires Lens `.cloudAPI` confirmation
```

In `veryfiLensSuccess`, prefer `data.local_package_path`, fallback `VeryfiLens.shared().utils.getZipPath(for: packageID)`. See [implementation.md](implementation.md#decoupled-capture-customer-owned-process-a-document).

**Do not set:** `.cloudAPI`, `.inApp`, `webhookIsOn`, Lens cloud response flags (`boundingBoxesIsOn`, `confidenceDetailsIsOn`, `parseAddressIsOn`, `detectBlurResponseIsOn`, `boostModeIsOn`, `computeIsOn`), or `sameFileUploadPreventionPolicy = .always`. Put process options on the customer's Process a Document request.

### Overlay: remote package (`decoupled-remote-package`)

Same recipe, then:

```swift
settings.dataExtractionEngine = .none         // required; this flag only applies with `.none`
settings.uploadWithoutProcessingIsOn = true   // Lens uploads; does not call Process a Document
```

In `veryfiLensSuccess`, read `data.bucket` and `data.package_path` (also `document_type`, `external_id` if set). Forward those to the customer's backend Process a Document call. Local zip retention is optional because the handoff is remote.

## Visual / local scan-to-PDF (`visual-scan-to-pdf`)

**Groups:** ExtractionMode.VisualOnly, CaptureFlow.AutoSubmit, MultiPage.StitchToPdf, Chrome.Minimal

```swift
settings.dataExtractionEngine = .none
settings.uploadWithoutProcessingIsOn = false  // visual-only local PDF; not remote-package decoupling
settings.autoSubmitDocumentOnCapture = true
settings.returnStitchedPDF = true
settings.autoDeleteLocalResourcesAfterProcessing = false
settings.autoCaptureIsOn = false
settings.autoDocDetectionAndCropIsOn = true
settings.autoRotateIsOn = false
settings.autoSkewCorrectionIsOn = true
settings.dewarpingIsOn = false
settings.cleanBorderIsOn = false
settings.multiplePagesCaptureIsOn = true
settings.multipleDocumentsIsOn = true
settings.singleScanPackages = false
settings.stitchIsOn = true
settings.showDocumentTypes = false
settings.documentTypes = ["receipt"]          // detection model; not cloud extract
settings.moreMenuIsOn = false
settings.galleryIsOn = true
settings.showBrowserButton = true
settings.browseIsOn = true
```

**Do not set:** webhook, boost/compute for extraction, field detection, check backs.

## CPG / barcode (`cpg-barcode`)

**Flavor:** Barcodes. **Groups:** ExtractionMode.InApp, CaptureFlow.AutoSubmit-ish (auto shutter), CaptureSources.CameraOnly

```swift
settings.dataExtractionEngine = .inApp
settings.documentTypes = ["barcode"]
settings.showDocumentTypes = false
settings.autoCaptureIsOn = true
settings.galleryIsOn = false
settings.stitchIsOn = false
settings.moreMenuIsOn = false
settings.autoLightDetectionIsOn = false
settings.continuousAutoFocus = true          // small codes held close to the camera
settings.dewarpingIsOn = true
settings.cleanBorderIsOn = true
settings.autoRotateIsOn = true
```

## CPG / code OCR (`cpg-code`)

**Flavor:** OCR/Code.

```swift
settings.dataExtractionEngine = .inApp
settings.documentTypes = ["code"]
settings.showDocumentTypes = false
settings.autoCaptureIsOn = true
settings.galleryIsOn = false
settings.stitchIsOn = false
settings.moreMenuIsOn = false
settings.autoLightDetectionIsOn = false
settings.continuousAutoFocus = true          // bottle caps and small codes held close to the camera
settings.ocrType = .strips                    // .caps for bottle caps
settings.ocrRegex = "[A-Z0-9]{10}"            // replace with the customer’s pattern
```

## Credit cards (`credit-cards`)

**Flavor:** CreditCards. **Groups:** ExtractionMode.InApp, CaptureSources.CameraOnly

Credit card data is never sent to the backend. Extraction stays on device and the result is returned to the host. `.inApp` (`"mobile"`) is the engine for that local extraction. It is also the only on-device engine for `code` and `barcode`. Other document types need `.cloudAPI` or `.none`.

```swift
settings.dataExtractionEngine = .inApp
settings.documentTypes = ["credit_card"]
settings.showDocumentTypes = false
settings.autoCaptureIsOn = true
settings.galleryIsOn = false
settings.stitchIsOn = false
settings.moreMenuIsOn = false
settings.autoLightDetectionIsOn = false
settings.autoRotateIsOn = true
settings.cropLayoutWithAutoDetection = true
settings.cropLayoutWidth = 80
settings.cropLayoutHeight = 25
settings.cropLayoutCornerRadius = 15
settings.cropLayoutStroke = 16
settings.cropLayoutBorderColor = "#FFFFFFFF"
```

## Tax / statements (W2, W9, bank statement)

Same pattern as CGP but a single type and usually stitch off for single-page forms:

```swift
settings.dataExtractionEngine = .cloudAPI
settings.documentTypes = ["w2"]               // w9, bank_statement
settings.showDocumentTypes = false
settings.autoCaptureIsOn = false
settings.stitchIsOn = false
settings.galleryIsOn = true
settings.browseIsOn = true
settings.moreMenuIsOn = false
settings.autoRotateIsOn = true
settings.cleanBorderIsOn = true
settings.returnStitchedPDF = true
```

## Long receipts

```swift
settings.documentTypes = ["long_receipt"]
settings.showDocumentTypes = false
settings.stitchIsOn = true
settings.multiplePagesCaptureIsOn = true
settings.returnStitchedPDF = true
settings.dataExtractionEngine = .cloudAPI
```

## Overlay: CaptureFlow.BatchToMaxThenReview

After a review-based recipe:

```swift
settings.batchUploadOnCamera = true
settings.autoSubmitDocumentOnCapture = false
settings.packageMaxScans = 10                 // preview opens at max
```

## Overlay: CaptureFlow.AutoSubmit

```swift
settings.autoSubmitDocumentOnCapture = true
settings.batchUploadOnCamera = false
```

## Overlay: CaptureSources.FilesFirst

Files/iCloud Drive can be exposed through any of these independent entry points:

```swift
// Camera More menu > Import > Browse
settings.moreMenuIsOn = true
settings.browseIsOn = true

// Or: dedicated Files button in the camera's top-right controls
settings.showBrowserButton = true

// Or: the camera gallery control opens a Photos/Files menu
settings.galleryIsOn = true
settings.galleryButtonWithFilesIsOn = true
```

Choose only the camera entry points the product needs. `browseIsOn` controls the More-menu row; it does not gate the dedicated button or the gallery-control menu.

For a standalone Files solution with no camera, present `showDocumentBrowser(in:)` from UIKit or `.documentBrowser` with the SwiftUI Lens presentation helper. The standalone API does not require any of the camera entry-point flags above.

## Overlay: CropLayout.FrameOrHybrid

The layout is a framing/focus tool: width, height or aspect ratio, and corner radius can make a sharp document rectangle, rounded card, or circular-looking square guide. Border, dimmed outside overlay, and `cropLayoutTipMessage` direct the user to place the subject inside it. The captured crop remains the frame's rectangular bounds.

Pick one behavior:

```swift
// Pure fixed frame: turn automatic document crop off.
settings.autoDocDetectionAndCropIsOn = false
settings.cropLayoutIsOn = true
```

```swift
// Hybrid frame + live green-box detection. cropLayoutIsOn is not also required.
settings.cropLayoutWithAutoDetection = true
settings.docDetectFillUIColor = "#00FF0066"
settings.docDetectStrokeUIColor = "#00FF00FF"
```

Shape and focus styling shared by either mode:

```swift
settings.cropLayoutWidth = 80
settings.cropLayoutHeight = 35               // used when aspect ratio is 0
settings.cropLayoutAspectRatio = 0           // nonzero derives height from width across rotation
settings.cropLayoutCornerRadius = 16          // increase toward half a square frame for a circle
settings.cropLayoutBorderColor = "#FFFFFFFF"
settings.cropLayoutStroke = 3
settings.cropLayoutOverlayColor = "#000000"
settings.cropLayoutOverlayAlpha = 0.45
settings.cropLayoutTipMessage = "Place the document inside the frame"
```

In hybrid mode, Lens detects/crops a document inside the frame and shows the green box. If no rectangle is found, the fixed layout crop is used.

## Overlay: GuideAnimation

Built-in guide animations exist for receipt, long receipt, and prescription-label capture. Frequency and lifetime are separate:

```swift
settings.showGuideShortCounter = 2            // receipt: auto-show at most twice
settings.showGuideCounter = 2                 // long receipt: auto-show at most twice
settings.showPrescriptionLabelGuideCounter = 2
settings.animationDisplayDuration = 10        // auto-hide each guide after 10s; 0 waits for dismissal/mode change
```

The counters persist on device. Zero disables automatic display (and resets receipt/long-receipt counters when settings are applied).

To let users replay the current supported Lens guide:

```swift
settings.showHelpButton = true
settings.showDefaultScanningGuide = true      // Help forces replay and does not increment the counter
```

With `showDefaultScanningGuide = false`, Help calls the host's `onHelpButtonClicked`. These animated guides are independent of the crop-layout framing guide and `batchUploadAnimationDuration`.

Help/Info custom UI uses one shared camera control. Pick one:

```swift
// Host presents a custom UIViewController from onHelpButtonClicked(_:)
settings.showHelpButton = true
settings.showDefaultScanningGuide = false
```

```swift
// Lens opens a host VeryfiInfoView full-screen over the camera.
settings.showHelpButton = false
settings.showInfoButton = ClientCameraInfoView()
```

`cameraInfoView` is separate and can coexist with either choice:

```swift
settings.cameraInfoView = ClientCameraBannerView() // top safe-area banner
// Later, while the camera is open:
VeryfiLens.shared().utils.updateCameraInfoView(ClientCameraBannerView())
```

Both custom view classes subclass `VeryfiInfoView`; call inherited `close()` to dismiss. See [implementation.md](implementation.md#help-custom-screens-and-camera-banners).

## Overlay: Compliance.Strict

```swift
settings.allowSubmittingScreenshots = false
settings.fraudDetectionIsOn = true             // paid/backend-gated; camera captures only
settings.showLCDIsNotAllowed = true
settings.deviceBlockListIsOn = true           // needs network + credentials
settings.sameFileUploadPreventionPolicy = .always // requires .cloudAPI
```

`.always` needs `VeryfiLens.shared().allowReuploadingFiles(withIdentifiers:)` if users must resubmit.
Local fraud detection remains off unless the validated account/backend entitlement enables it;
the setting cannot unlock the paid feature.

## Overlay: KeepLocalResources

Use when the host must keep files from **more than one** package (queue, batch, parallel submits). A single sequential document can leave the default `true` if it copies from `update` immediately.

```swift
settings.autoDeleteLocalResourcesAfterProcessing = false
```

The host then owns deletion: `VeryfiLens.shared().utils.clearLensStorage()` for everything, or `FileManager.fileExists` + `removeItem` on callback paths. See [implementation.md](implementation.md#local-resources-and-who-deletes-them).
