# Long receipts

Pod `VeryfiLens-LongReceipts`. Dedicated SPM repo `veryfi-lens-spm-long-receipts`.

The public [long receipts installation](https://docs.veryfi.com/lens/mobile/long-receipts/installation/) page shows the matching pod and the Full SPM URL `veryfi-lens-spm.git`. Use the dedicated repo from the matrix, not the Full package.

Client settings type: `VeryfiLensSettings()`. Do not use `VeryfiLensLongReceiptsSettings`.

## Artifact and import

| | |
|--|--|
| Pod | `VeryfiLens-LongReceipts` |
| Dedicated SPM | Yes. Repo `veryfi-lens-spm-long-receipts`. Public mirror URL **Unconfirmed** |
| XCFramework file name | `VeryfiLens.xcframework` |
| Import | `import VeryfiLens` |

```swift
import VeryfiLens
```

## Permissions

| Key | When |
|-----|------|
| `NSCameraUsageDescription` | Camera. Long-receipt capture is a camera flow |
| `NSPhotoLibraryUsageDescription` | only if `galleryIsOn` or `showGallery`. This template leaves gallery at the SDK default `true`, so include this key |
| `NSPhotoLibraryAddUsageDescription` | only if gallery backup is on. This template sets backup false |
| `NSLocationWhenInUseUsageDescription` | only if location is on. This template sets it false |

SDK default `galleryIsOn` is `true` (`VeryfiLensSettings`). This template does not turn gallery off, because the long-receipt recipe does not. Contacts and Calendar strings remain **Unconfirmed**.

## Settings

Recipe from [recipes.md](../recipes.md) plus base hardening. Single type, so the picker stays off.

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
settings.moreMenuIsOn = false

settings.documentTypes = ["long_receipt"]
settings.showDocumentTypes = false
settings.stitchIsOn = true
settings.multiplePagesCaptureIsOn = true
settings.returnStitchedPDF = true
settings.dataExtractionEngine = .cloudAPI
settings.autoCaptureIsOn = false
```

`multiplePagesCaptureIsOn` keeps every crop in one image when several long-receipt sections are in the frame. It does not split photos into separate packages. `multipleDocumentsIsOn` is the submit-preview question, and this recipe does not turn it on.

Guide counters, if the host wants the built-in long-receipt animation: `showGuideCounter` (not `showGuideShortCounter`, which is the short-receipt counter). Zero disables the automatic guide. See the GuideAnimation overlay in [recipes.md](../recipes.md).

Retain files across a multi-part session:

```swift
settings.autoDeleteLocalResourcesAfterProcessing = false
```

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

SwiftUI camera cover is the other presentation path. Do not present both.

Stitch progress arrives on `veryfiLensUpdate` (`img_original_paths` / `images` for stitched PDF path updates). Submit still ends in `veryfiLensSuccess` when cloud processing finishes.

## Callbacks

Standard `VeryfiLensDelegate`. Success `status` is `"done"` for `.cloudAPI`. `document_type` on success is `long_receipt` when the package type is set.

`img_stitched_pdf_path` is the stitched PDF key documented in [implementation.md](../implementation.md#json-shape-common-keys). Copy it during `update` or `success` if local auto-delete is still true.

Close without a success means the user left the camera.

## Conflicts and do-not

- Do not put `long_receipt` on the receipts-only or checks binary.
- Do not set `showDocumentTypes` true for this single-type list unless more types are added, and only if those types exist in this flavor.
- Do not treat `multiplePagesCaptureIsOn` as the “separate packages” switch.
- Do not set `.inApp`.
- Do not enable `documentFieldsToDetect` on this flavor. The long-receipt Demo subclass sets that list. It is a paid Field Detection feature and is not part of this recipe.
- Do not set `dictateIsOn`.
- `stitchIsOn` with `singleScanPackages` true is a conflicting package shape. `singleScanPackages` defaults to false. Set it false explicitly when a host build may have changed it and stitch-to-PDF is required.

## Source

- [flavor-matrix.md](../flavor-matrix.md)
- [recipes.md](../recipes.md) — Long receipts
- [implementation.md](../implementation.md)
- [VeryfiLensSettings.swift](../../../Veryfi-Lens/Public/Model/VeryfiLensSettings.swift) — `galleryIsOn` default true
- [SPM.swift](../../../fastlane/swift/FastlaneSwiftRunner/SPM.swift) — `.longReceipt`
