# Barcodes

Pod `VeryfiLens-Barcodes`. No dedicated SPM repo is published. Do not install `veryfi-lens-spm`.

Public installation URL was not fetched. **Unconfirmed** docs page. Pod name is `VeryfiLens-Barcodes`.

Client settings type: `VeryfiLensSettings()`. Do not use `VeryfiLensBarcodesSettings`.

On-device barcode reads use `.inApp`. The payload returned to the host is local. `BarcodeEventsHelper` also calls document-ready with engine `.inApp` and `documentType` `barcode`. That notification is not the barcode payload.

## Artifact and import

| | |
|--|--|
| Pod | `VeryfiLens-Barcodes` |
| Dedicated SPM | **No** |
| XCFramework file name | `VeryfiLens.xcframework` |
| Import | `import VeryfiLens` |

```swift
import VeryfiLens
```

## Permissions

| Key | When |
|-----|------|
| `NSCameraUsageDescription` | Camera. This recipe is camera-only |
| `NSPhotoLibraryUsageDescription` | not required while gallery is off |
| `NSPhotoLibraryAddUsageDescription` | not required |
| `NSLocationWhenInUseUsageDescription` | not required |

## Settings

CPG barcode recipe from [recipes.md](../recipes.md), plus base hardening.

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

settings.dataExtractionEngine = .inApp
settings.documentTypes = ["barcode"]
settings.showDocumentTypes = false
settings.autoCaptureIsOn = true
settings.galleryIsOn = false
settings.stitchIsOn = false
settings.moreMenuIsOn = false
settings.autoLightDetectionIsOn = false
settings.continuousAutoFocus = true
settings.dewarpingIsOn = true
settings.cleanBorderIsOn = true
settings.autoRotateIsOn = true
```

`continuousAutoFocus` is the close-up focus path for small codes.

`ocrType` / `ocrRegex` belong to the code flavor, not barcodes.

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

A recognized barcode closes the Lens camera from `CameraPresenter.imageProcessorDidProcessBarcode` after the success callback is sent (`closeLens()` on the main queue).

One special case stays in the normal submit flow: `cropLayoutWithAutoDetection` (or the image-processing crop layout) together with auto-capture, `uploadWithoutProcessingIsOn`, and `dataExtractionEngine == .none`. This template does not use that combination.

SwiftUI camera cover is the other presentation path.

## Callbacks

Barcode success is not the package `status: "done"` envelope. `BarcodeEventsHelper.success` passes `BarcodeResult.json` straight to `veryfiLensSuccess`:

| Key | Meaning |
|-----|---------|
| `barcode_uuid` | Local id. Also the document-ready package id |
| `barcodes` | Array of items |

Each item:

| Key | Meaning |
|-----|---------|
| `data` | Payload string |
| `score` | Float |
| `image` | Path `Documents/barcodeImage{index}.jpg` when a cropped image was saved. Empty string if none |
| `type` | Symbology string on the processed-image callback. The live update path in `imageProcessorDidUpdateBarcode` does not set `type` |
| `bounding_region` | `[CGFloat]`. Empty on the live update path |

`veryfiLensUpdate` receives the same JSON shape during live detection (`imageProcessorDidUpdateBarcode`), without `type`, `bounding_region`, or an image path.

`veryfiLensClose` follows the scheduled camera close. It is not the barcode payload.

`veryfiLensError` is still used for configure and credential failures.

`PackageUploader.inAppAPIProcessing` only succeeds when metadata contains `credit_card`. The barcode camera path does not go through that method. It calls `veryfiLensSuccess` from `BarcodeEventsHelper`. Do not wait for a second package-uploader success.

## Conflicts and do-not

- Do not set `.cloudAPI` for the live barcode read. `.inApp` is the on-device engine for `barcode`.
- Do not set `ocrRegex` or `documentTypes` to `code` on this binary. Code is the OCR flavor.
- Do not set `stitchIsOn` true.
- Do not turn gallery on unless the host is testing import. Gallery barcode behavior is **Unconfirmed** in this template.
- Do not install `veryfi-lens-spm`.
- Do not use `VeryfiLensBarcodesSettings`.
- `shareOCRFeedback()` shares the last **code**-scan logs (`LogHelper.shareLastScanAsFailed(for: .code)`). It is not the barcode result API.

## Source

- [flavor-matrix.md](../flavor-matrix.md)
- [recipes.md](../recipes.md) — `cpg-barcode`
- [BarcodeResult.swift](../../../VeryfiLensEngine/Shared/Models/BarcodeResult.swift)
- [BarcodeEventsHelper.swift](../../../Veryfi-Lens/Helpers/BarcodeEventsHelper.swift)
- [CameraPresenter.swift](../../../Veryfi-Lens/Scenes/Camera/CameraPresenter.swift) — `imageProcessorDidProcessBarcode`
- [Pipeline.swift](../../../fastlane/swift/FastlaneSwiftRunner/Pipeline.swift)
