# Headless receipts

No Lens camera UI. The host owns capture, or it already has images, and calls `VeryfiLensHeadless`.

Pod `VeryfiLensHeadless-Receipts`. Dedicated SPM repo `veryfi-lens-spm-headless-receipts`.

The public [headless receipts installation](https://docs.veryfi.com/lens/mobile/headless/receipts/installation/) page shows the matching pod and the Full SPM URL `veryfi-lens-spm.git`. Use the dedicated repo, not the Full package.

Settings type: `VeryfiLensReceiptSettings` (singular Receipt). It conforms to `VeryfiLensHeadlessSettings`. It is not `VeryfiLensSettings` and it is not the Demo UI class `VeryfiLensReceiptsSettings`.

Credentials: `VeryfiLensHeadlessCredentials`.

The uploader hardcodes `dataExtractionEngine: .cloudAPI`, `uploadWithoutProcessing: false`, `async: false`, and `deleteLocalResources: true`. There is no engine enum on this settings type. Cloud Process a Document is what a successful upload does. Local package retention cannot be turned off with a public flag.

## Artifact and import

| | |
|--|--|
| Pod | `VeryfiLensHeadless-Receipts` |
| Dedicated SPM | Yes. Repo `veryfi-lens-spm-headless-receipts`. Public mirror URL **Unconfirmed** |
| XCFramework | `VeryfiLensHeadlessReceipts.xcframework` |
| Import | `import VeryfiLensHeadlessReceipts` |

```swift
import VeryfiLensHeadlessReceipts
import AVFoundation
```

`VeryfiLens.shared().headlessUpload` is the UI SDK helper. Do not use it with this module.

## Permissions

| Key | When |
|-----|------|
| `NSCameraUsageDescription` | Host camera that feeds `process(buffer:)` |
| `NSPhotoLibraryAddUsageDescription` | `backupImagesToGallery = true` (default false) |
| `NSPhotoLibraryUsageDescription` | not required for `upload(images:)` of images the host already decoded |
| `NSLocationWhenInUseUsageDescription` | **Unconfirmed**. `ReceiptsUploader` reads `LocationHelper.shared().location` for each scan. This settings type has no `locationServicesIsOn`. Whether that read prompts is **Unconfirmed**. Do not add a location string unless a build shows a prompt |

iCloud backup (`backupImagesToiCloud`, default false) uses the host’s iCloud entitlement, not a usage-description key. **Unconfirmed** which entitlement string the uploader requires beyond the flag.

## Settings

`documentType` is a `DocumentType`, default `.receipt` (`"receipt"`). This is not `documentTypes: [String]`.

Leave `documentType` at `.receipt` on this binary. Other `DocumentType` values are **Unconfirmed** here. The product name and uploader are receipts.

Flags the uploader actually reads:

```swift
let settings = VeryfiLensReceiptSettings()
settings.documentType = .receipt
settings.autoCaptureIsOn = true
settings.isAutoRotationEnabled = true
settings.isSkewCorrectionOn = true
settings.isDewarpingOn = true
settings.cleanBorderIsOn = false
settings.returnStitchedPDF = false
settings.backupImagesToGallery = false
settings.backupImagesToiCloud = false
settings.autoDeleteAfterProcessing = false
settings.boostModeIsOn = false
settings.computeIsOn = false
settings.boundingBoxesIsOn = false
settings.confidenceDetailsIsOn = false
settings.parseAddressIsOn = false
settings.detectBlurResponseIsOn = false
settings.barcodeExtractionIsOn = false
```

`autoDeleteAfterProcessing` is the server-side delete flag. It is not local file retention. Local deletion is hardcoded `deleteLocalResources: true` in `ReceiptsUploader`.

`isGPUOn` defaults true. `pdfFormatIsOn` defaults true and is passed to the packager even though it is omitted from `json`. `noCompress` and `noCompressOnWifi` default false. `stitchedPDFPixelDensityMultiplier` defaults `2.0`.

`autoCaptureFrameConfidence` defaults `10`. `autoCaptureMarginRatio` defaults `0`.

A `VeryfiLensCreditCardsSettings` instance on this binary fails the cast. Error string: `Wrong VeryfiLensHeadlessSettings instance is used. Make sure VeryfiLensHeadlessSettings instance is used`.

## Lifecycle and presentation

Configure, then either upload files the host already has, or run a live detector and upload the crops.

```swift
let credentials = VeryfiLensHeadlessCredentials(
    clientId: "<clientId>",
    username: "<username>",
    apiKey: "<apiKey>",
    url: "https://api.veryfi.com"
)

VeryfiLensHeadless.shared().delegate = self
VeryfiLensHeadless.shared().configure(with: credentials, settings: settings) { success in
    guard success else { return }
    VeryfiLensHeadless.shared().upload(images: images) // at most 4; extras are dropped
}
```

`upload(url:)` sends one file URL. `upload(images:)` caps at 4 (`prefix(upTo: 4)` when `count > 4`).

Live preview, after configure:

```swift
VeryfiLensHeadless.shared().setCameraSessionQueue(sessionQueue)
VeryfiLensHeadless.shared().startProcessingBuffer()
VeryfiLensHeadless.shared().processWithBlock(buffer: sampleBuffer) { rectangles, buffer in
    let converted = VeryfiLensHeadless.shared().adjustedRectangles(
        rectangles,
        for: buffer,
        videoPreviewLayer: previewLayer
    )
    // Host draws `converted`. RectangleFeature is part of this public method signature.
}
```

Still image:

```swift
let rotated = VeryfiLensHeadless.shared().rotate(image: image)
VeryfiLensHeadless.shared().crop(image: rotated) { cropped in
    VeryfiLensHeadless.shared().upload(images: cropped)
}
```

`crop(image:for:completion:)` uses host-supplied rectangles. `detectedDocuments(for:videoPreviewLayer:)` is the other rectangle read.

When the screen goes away:

```swift
VeryfiLensHeadless.shared().stopProcessingBuffer()
VeryfiLensHeadless.shared().close()
```

`RectangleFeature.h` is listed in the explicit private module `VeryfiLensHeadlessReceipts_Private`. The in-repo demo calls these methods with `import VeryfiLensHeadlessReceipts` only. Do not import the private module in client code.

## Callbacks

`VeryfiLensHeadlessDelegate`: close, error, success, update. No help callback.

`upload(images:)` calls `documentUploaderDidStart` with a `VeryfiLensCloseResponse` before the network upload. That invokes `veryfiLensClose` at **upload start**, with queue count and scan count. It does not mean the user dismissed a camera. `upload(url:)` does not call that start/close helper.

Progress and the cloud result then arrive on `veryfiLensUpdate` and `veryfiLensSuccess` from `PackageUploader` via `ReceiptsUploader`. Success `status` is `"done"` for `.cloudAPI`. The JSON shape matches the UI SDK package success in [implementation.md](../implementation.md#delegate). `document_type` is the settings `documentType` raw string (`receipt` by default).

Because `deleteLocalResources` is hardcoded true, image paths in `update` can disappear when processing finishes. Copy during `update`. There is no `autoDeleteLocalResourcesAfterProcessing` on `VeryfiLensReceiptSettings`.

`backupImagesToGallery` true copies into Photos and needs the add-usage string.

Empty credentials: `completion(false)` and `veryfiLensError` message `invalid_credentials`, `data.empty_fields`, same pattern as the UI SDK once the delegate is set.

Calls made before configure, or after credentials fail validation, report `veryfiLensError` with `"No valid credentials"`.

## Conflicts and do-not

- Do not pass `VeryfiLensSettings` or `VeryfiLensReceiptsSettings` into `configure`.
- Do not set a `dataExtractionEngine`. The uploader is cloud API.
- Do not expect `local_package_path`. Local resources are deleted (`deleteLocalResources: true`) and `uploadWithoutProcessing` is false, so this is not the decoupling handoff.
- Do not use `VeryfiLens.shared().headlessUpload` or `uploadImages(paths:)`.
- Do not install the Full `veryfi-lens-spm` package for this product.
- Do not import `VeryfiLensHeadlessReceipts_Private`.
- Gallery backup defaults false. Leave it false unless the host wants Photos filled.

## Source

- [flavor-matrix.md](../flavor-matrix.md)
- [implementation.md](../implementation.md) — package success keys
- [VeryfiLensHeadless.swift](../../../VeryfiLensHeadless/Public/VeryfiLensHeadless.swift)
- [VeryfiLensReceiptSettings.swift](../../../VeryfiLensHeadless/Headless%20Receipts/VeryfiLensReceiptSettings.swift)
- [ReceiptsUploader.swift](../../../VeryfiLensHeadless/Headless%20Receipts/ReceiptsUploader.swift)
- [VeryfiLensHeadlessReceipt.modulemap](../../../VeryfiLensHeadless/Supported/VeryfiLensHeadlessReceipt.modulemap)
- [SPM.swift](../../../fastlane/swift/FastlaneSwiftRunner/SPM.swift) — `.headlessReceipts`
- [Headless receipts installation](https://docs.veryfi.com/lens/mobile/headless/receipts/installation/)
