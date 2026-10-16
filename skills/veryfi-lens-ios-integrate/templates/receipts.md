# Receipts

Receipts-specific binary. Pod `VeryfiLens-Receipts`, SPM repo `veryfi-lens-spm-receipts`. Same public types as the Full UI SDK: `VeryfiLens`, `VeryfiLensSettings`, `VeryfiLensCredentials`.

The public [receipts installation](https://docs.veryfi.com/lens/mobile/receipts/installation/) page currently shows `pod 'VeryfiLens'` and `veryfi-lens-spm.git`. That is the Full artifact. Use this template’s pod and SPM repo when the customer bought the receipts flavor.

Client settings type: `VeryfiLensSettings()`. `VeryfiLensReceiptsSettings` is a Demo subclass. Do not use it. The headless type `VeryfiLensReceiptSettings` is a different product. See [headless-receipts.md](headless-receipts.md).

## Artifact and import

| | |
|--|--|
| Pod | `VeryfiLens-Receipts` |
| Dedicated SPM | Yes. Repo `veryfi-lens-spm-receipts`. Public host URL for this repo name is **Unconfirmed** (docs still show the Full URL) |
| XCFramework file name | `VeryfiLens.xcframework` (the pod selects the receipts binary) |
| Import | `import VeryfiLens` |

```swift
import VeryfiLens
```

## Permissions

| Key | When |
|-----|------|
| `NSCameraUsageDescription` | Camera |
| `NSPhotoLibraryUsageDescription` | Gallery in this recipe |
| `NSPhotoLibraryAddUsageDescription` | only if gallery backup is on. This template sets it false |
| `NSLocationWhenInUseUsageDescription` | only if location is on. This template sets it false |

Contacts and Calendar keys from the legacy README are **Unconfirmed**. iOS 13+ UIKit, SwiftUI helpers documented as iOS 15+.

## Settings

Same property set as the CGP / expense recipe. The receipts flavor’s type list is `receipt`, `invoice`, and `other`. Do not add `long_receipt` on this binary. Use [long-receipts.md](long-receipts.md).

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

Several in-flight packages, or files read after the callback:

```swift
settings.autoDeleteLocalResourcesAfterProcessing = false
```

`documentFieldsToDetect` is a paid feature. The receipts flavor is not the Field Detection flavor. Leave the list empty unless support confirms both the entitlement and that this binary includes the model.

## Lifecycle and presentation

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

SwiftUI: `.veryfiLensFullScreenCover(isPresented:flow: .camera)`. One presentation at a time.

`uploadImages(paths:)` after a successful configure packages existing files with cloud extraction. The document type is the first `documentTypes` entry (`receipt` in this recipe). Share Extension: set `shareExtensionModeIsOn = true` only in the extension.

`headlessUpload(images:)` on `VeryfiLens` is the UI SDK helper (max 4, type `receipt`). The no-UI product is [headless-receipts.md](headless-receipts.md).

## Callbacks

`VeryfiLensDelegate`: `veryfiLensClose`, `veryfiLensError`, `veryfiLensSuccess`, `veryfiLensUpdate`. Shapes: [implementation.md](../implementation.md#delegate).

Cloud success uses `status` `"done"`. Update events carry thumbnail and original paths (`msg` `img_original_path` and related keys). Close is the end of the camera session, including cancel.

Copy files during `update` when local auto-delete stays true. `utils.getImages(from:)` and `getZipPath(for:)` work only while those files still exist.

## Conflicts and do-not

- Do not install `veryfi-lens-spm` and expect the receipts-only binary.
- Do not use `VeryfiLensReceiptsSettings` or `VeryfiLensReceiptSettings` with this UI SDK.
- Do not set `.inApp`, `ocrRegex`, check flags, or `cameraProcessingMode`.
- Do not set `autoCaptureOtherIsOn` true while `autoCaptureIsOn` is false and `other` is in the list.
- `showDocumentTypes` must stay true for this three-type list.
- `stitchIsOn` true with `singleScanPackages` true fights the stitched-PDF recipe. This template keeps `singleScanPackages` false.
- Gallery backup stays off. The SDK default is true.

## Source

- [flavor-matrix.md](../flavor-matrix.md)
- [recipes.md](../recipes.md) — `cgp-expense`
- [implementation.md](../implementation.md)
- [conflicts.md](../conflicts.md)
- [VeryfiLens.swift](../../../Veryfi-Lens/Public/VeryfiLens.swift)
- [VeryfiLensSettings.swift](../../../Veryfi-Lens/Public/Model/VeryfiLensSettings.swift)
- [SPM.swift](../../../fastlane/swift/FastlaneSwiftRunner/SPM.swift) — `.receipts` → `veryfi-lens-spm-receipts`
