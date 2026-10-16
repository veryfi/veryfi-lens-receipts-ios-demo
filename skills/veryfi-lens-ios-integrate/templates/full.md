# Full UI (most complete published UI binary)

Use the `VeryfiLens` pod / `veryfi-lens-spm` package. This is the broadest UI artifact the release pipeline names `VeryfiLens`. It is not a substitute for Checks, Credit Cards, OCR, Barcodes, W-2, W-9, Lite, or either Headless product. Those have their own templates.

Which extra models this binary embeds beyond receipts, invoices, and `other` is **Unconfirmed**. Do not add `long_receipt`, `check`, `credit_card`, `code`, `barcode`, `w2`, or `w9` here unless support confirms this binary contains those models. Long receipts have [their own template](long-receipts.md).

Client settings type: `VeryfiLensSettings()`. Do not use a `VeryfiLens*Settings` subclass.

## Artifact and import

See [flavor-matrix.md](../flavor-matrix.md).

| | |
|--|--|
| Pod | `VeryfiLens` |
| Dedicated SPM | Yes. Repo `veryfi-lens-spm`. Public URL `https://repo.veryfi.com/shared/lens/veryfi-lens-spm.git` |
| XCFramework | `VeryfiLens.xcframework` |
| Import | `import VeryfiLens` |

The public [receipts installation](https://docs.veryfi.com/lens/mobile/receipts/installation/) page documents this Full package (`pod 'VeryfiLens'` and `veryfi-lens-spm`). The receipts-specific artifact is a different row in the matrix.

```swift
import VeryfiLens
```

## Permissions

| Key | When |
|-----|------|
| `NSCameraUsageDescription` | `showCamera` or embedded `lensVC()` |
| `NSPhotoLibraryUsageDescription` | `galleryIsOn` or `showGallery` |
| `NSPhotoLibraryAddUsageDescription` | only if `backupDocsToGallery` is true. This template sets it false |
| `NSLocationWhenInUseUsageDescription` | only if `locationServicesIsOn` is true. This template sets it false |

Do not add Contacts or Calendar usage strings from the legacy framework README. Those keys are **Unconfirmed** / likely stale. See [implementation.md](../implementation.md).

UIKit Lens is documented as iOS 13+. SwiftUI helpers are documented as iOS 15+. A public quick start that says iOS 12.1 is **Unconfirmed** against that.

## Settings

Base hardening, then the CGP / expense recipe. One type list. `showDocumentTypes` stays true because more than one type is set.

```swift
let settings = VeryfiLensSettings()
settings.ignoreRemoteSettings = true
settings.backupDocsToGallery = false
settings.backupDocsToiCloud = false
settings.moreSettingsMenuIsOn = false
settings.autoCaptureOtherIsOn = false
settings.showNoDocumentDetectedWarning = false
settings.dictateIsOn = false
settings.locationServicesIsOn = false
settings.enableScreenshots = true

settings.dataExtractionEngine = .cloudAPI
settings.documentTypes = ["receipt", "invoice", "other"]
settings.showDocumentTypes = true
settings.defaultSelectedDocumentType = "receipt"
settings.autoSubmitDocumentOnCapture = false
settings.batchUploadOnCamera = false
settings.imagePreviewIsOn = true
settings.galleryIsOn = true
settings.browseIsOn = true
settings.showBrowserButton = false
settings.autoCaptureIsOn = false
settings.autoDocDetectionAndCropIsOn = true
settings.autoRotateIsOn = true
settings.autoSkewCorrectionIsOn = true
settings.cleanBorderIsOn = true
settings.dewarpingIsOn = false
settings.stitchIsOn = true
settings.stitchOtherIsOn = false
settings.multipleDocumentsIsOn = true
settings.multiplePagesCaptureIsOn = true
settings.singleScanPackages = false
settings.returnStitchedPDF = true
settings.packageMaxScans = 10
settings.moreMenuIsOn = false
settings.closeCameraOnSubmit = true
settings.sameFileUploadPreventionPolicy = .session
settings.allowSubmittingScreenshots = true
settings.webhookIsOn = false
settings.autoDeleteAfterProcessing = false
```

If the host reads files after the callback, or keeps several packages in flight:

```swift
settings.autoDeleteLocalResourcesAfterProcessing = false
```

Paid local field detection is optional and off in this template. It needs the account entitlement and the Field Detection or Remote Models flavor. This Full binary is **Unconfirmed** as a field-detection flavor.

## Lifecycle and presentation

Set the delegate before `configure`. Present only after `completion(true)`.

```swift
let credentials = VeryfiLensCredentials(
    clientId: "<clientId>",
    username: "<username>",
    apiKey: "<apiKey>",
    url: "https://api.veryfi.com"
)

VeryfiLens.shared().delegate = self
VeryfiLens.shared().configure(with: credentials, settings: settings) { success in
    DispatchQueue.main.async {
        guard success else { return }
        VeryfiLens.shared().showCamera(in: self)
    }
}
```

One presentation path. UIKit alternatives: `showGallery(in:)`, `showDocumentBrowser(in:)`, `lensVC()`. SwiftUI: `.veryfiLensFullScreenCover(isPresented:flow:)` with `VeryfiLensFlow.camera`. Do not also call `showCamera` for the same session.

Files the host already has: `uploadImages(paths:)` after configure. That path always uses cloud extraction. Share Extension: `shareExtensionModeIsOn = true` only inside the extension.

`VeryfiLens.shared().headlessUpload` is the in-memory helper on this UI SDK (up to 4 images, type `receipt`). It is not the Headless Receipts product.

## Callbacks

Implement all four `VeryfiLensDelegate` methods. JSON keys and `status` values: [implementation.md](../implementation.md#delegate).

- `veryfiLensUpdate` is progress and file paths, not a finished extract.
- `veryfiLensSuccess` with `status` `"done"` is the cloud extract when `.cloudAPI` is set.
- `veryfiLensClose` means the UI session ended. It does not replace success.
- `veryfiLensError` with `msg` `invalid_credentials` means empty credential fields.

With `autoDeleteLocalResourcesAfterProcessing` left at the SDK default `true`, copy paths inside `update` / `success` before the next capture. When it is false, the host deletes with `FileManager` or `VeryfiLens.shared().utils.clearLensStorage()`.

## Conflicts and do-not

- Do not set `documentTypes` to a family this template does not list.
- Do not set `.inApp`. Receipts are not an on-device extract type.
- Do not set `ocrRegex`, `ocrType`, `cameraProcessingMode`, check validators, or `uploadWithoutProcessingIsOn` on this recipe.
- Do not set `dictateIsOn` true.
- Do not leave `backupDocsToGallery` at its SDK default `true`.
- Do not turn `moreMenuIsOn` on unless end users should override capture, torch, backup, Superman mode, and close-after-submit.
- `browseIsOn` only adds Browse under More. This template also leaves the More menu off, so Browse is hidden. Files still open from `showDocumentBrowser(in:)` or, if you set it, `showBrowserButton`.
- `autoCaptureOtherIsOn` must stay false while `other` is in the type list and auto-capture is off. Otherwise `other` still auto-captures.

## Source

- [flavor-matrix.md](../flavor-matrix.md)
- [recipes.md](../recipes.md) — CGP / expense and base hardening
- [implementation.md](../implementation.md)
- [conflicts.md](../conflicts.md)
- [VeryfiLens.swift](../../../Veryfi-Lens/Public/VeryfiLens.swift)
- [VeryfiLensSettings.swift](../../../Veryfi-Lens/Public/Model/VeryfiLensSettings.swift)
- [VeryfiLensCredentials.swift](../../../Veryfi-Lens/Public/Model/VeryfiLensCredentials.swift)
- [SPM.swift](../../../fastlane/swift/FastlaneSwiftRunner/SPM.swift) — `veryfi-lens-spm` for `.full`
