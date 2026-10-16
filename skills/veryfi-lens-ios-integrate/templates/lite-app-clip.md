# Lite (App Clip)

Lite is a separate framework, `VeryfiLensLite`. It is the App Clip build (`APP_CLIP` compile condition, product `VeryfiLens-Lite`). It is not `Veryfi-Lens-Core` and it is not the Full `VeryfiLens` module.

The Lite target compiles `VeryfiLens.swift` and `VeryfiLensSwiftUI.swift`. It does not compile `VeryfiLensCore.swift`. Call sites still say `VeryfiLens.shared()`, `VeryfiLensSettings()`, and `VeryfiLensCredentials`, after `import VeryfiLensLite`.

No dedicated SPM repo is published. `supportsSPM` is false. The names `veryfi-lens-spm-lite` are comments in `SPM.swift`, not a package. Install with CocoaPods `VeryfiLens-Lite` or by embedding `VeryfiLensLite.xcframework`.

## Artifact and import

| | |
|--|--|
| Pod | `VeryfiLens-Lite` |
| Dedicated SPM | **No** |
| XCFramework | `VeryfiLensLite.xcframework` |
| Module | `VeryfiLensLite` |
| Deployment target on the Lite framework target | iOS 15.0 |

```swift
import VeryfiLensLite
```

Public methods that exist on this binary because it compiles `VeryfiLens.swift`: `configure`, `showCamera`, `showGallery`, `showDocumentBrowser`, `showCrop`, `lensVC`, `closeCamera`, `uploadImages`, `headlessUpload`, `shareOCRFeedback`, `allowReuploadingFiles`.

Absent, because they live only in `VeryfiLensCore.swift`: `showVoice(in:)`, `showEmail(in:)`, `attachDocumentTo(documentId:in:)`.

SwiftUI modifiers and `VeryfiLens.shared().cameraView()` are compiled. Lite is not `VERYFI_LENS_CORE`, so the camera representable is included. SwiftUI helpers are documented as iOS 15+, which matches this target’s deployment target.

## Permissions

| Key | When |
|-----|------|
| `NSCameraUsageDescription` | Camera. Required for an App Clip scan |
| `NSPhotoLibraryUsageDescription` | only if gallery is on. This template turns gallery off |
| `NSPhotoLibraryAddUsageDescription` | only if `backupDocsToGallery` is true |
| `NSLocationWhenInUseUsageDescription` | only if `locationServicesIsOn` is true |

Under `APP_CLIP`, configure calls `LocationHelper.shared().updateLocation()` after assigning `isLocationUpdateOn`. Whether that prompts when `locationServicesIsOn` is false is **Unconfirmed**. This template keeps location off and does not add a location usage string.

## What the binary contains

The Lite resource build phase includes `crop_ios_v28.tflite`, `crop_card_ios_v25.tflite`, `crop_stitch_v18.tflite`, `simple_ocr_v4.tflite`, `local_extraction_v13.tflite`, `mobile_words_spm_v4.model`, `lcd_detect_v14.tflite`, `LongReceiptPreviewView.xib`, and the legacy matcher JSON files `driver_license.json`, `ine.json`, `health_care.json`, `passport.json`, `colombian_id.json`.

It does not list a check TIFF, a barcode model, or a credit-card detector model. Do not point Lite at checks, barcodes, or credit cards.

The legacy JSON files are the deprecated `anyDocumentType` matchers. Do not set `anyDocumentType`. Whether Any-Documents templates run on Lite is **Unconfirmed**.

The target’s Swift flags include `VERYFI_LENS_FIELD_DETECTION` and `VERYFI_HAS_SENTENCEPIECE`, and the field-extraction model file is in the resource phase. `documentFieldsToDetect` still does nothing without the paid account entitlement. This template leaves that list empty.

The in-repo App Clip host (`Lens-Clip/LensWrapper.swift`) reads document types from the invocation URL and otherwise selects `receipt`. This template uses that single type.

## Settings

`VeryfiLensSettings()` inside the Lite module. The Lens-Clip sample defaults the engine string to `"none"` and `uploadWithoutProcessingIsOn` to true when the URL does not say `"api"`. That is a host choice for a short-lived clip, not the SDK default (the SDK default engine is `.cloudAPI`). This template follows the clip sample: capture and upload a package, and let the customer process it. Switch to `.cloudAPI` and `uploadWithoutProcessingIsOn = false` when the clip itself should call Process a Document.

```swift
let settings = VeryfiLensSettings()
settings.ignoreRemoteSettings = true
settings.backupDocsToGallery = false
settings.backupDocsToiCloud = false
settings.moreSettingsMenuIsOn = false
settings.moreMenuIsOn = false
settings.autoCaptureOtherIsOn = false
settings.showNoDocumentDetectedWarning = false
settings.dictateIsOn = false
settings.locationServicesIsOn = false
settings.enableScreenshots = true
settings.galleryIsOn = false

settings.documentTypes = ["receipt"]
settings.showDocumentTypes = false
settings.dataExtractionEngine = .none
settings.uploadWithoutProcessingIsOn = true
settings.autoDeleteLocalResourcesAfterProcessing = false
settings.autoCaptureIsOn = false
settings.autoDocDetectionAndCropIsOn = true
settings.stitchIsOn = false
settings.packageMaxScans = 1
```

`uploadWithoutProcessingIsOn` applies only with `.none`. Success `data` then carries remote `bucket` and `package_path`. The clip’s backend processes that package. Local zip retention is optional on this remote-package path. `autoDeleteLocalResourcesAfterProcessing = false` is set so a clip that also reads image paths is not racing the SDK delete. The host still has to delete what it kept.

App Clip size limits are **Unconfirmed** in this pack. Do not quote an XCFramework file size as the clip’s installed size.

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

The Lens-Clip sample embeds `VeryfiLens.shared().lensVC()` instead of `showCamera`. Either path is valid after configure returns true. Use one.

SwiftUI: `.veryfiLensFullScreenCover(isPresented:flow: .camera)` from the Lite module.

Do not call Core-only `showVoice` or `showEmail`.

## Callbacks

Same `VeryfiLensDelegate` as the UI SDK. With this recipe, success is decoupling, not a Process a Document payload.

```swift
func veryfiLensSuccess(_ json: [String: Any]) {
    guard let data = json["data"] as? [String: Any],
          let bucket = data["bucket"] as? String,
          let packagePath = data["package_path"] as? String else { return }
    // Customer backend calls Process a Document with bucket and package_path.
}
```

`status` `"done"` still marks that success. `veryfiLensUpdate` may include image paths while the package is built. `veryfiLensClose` is the camera session ending. Empty credentials: `veryfiLensError` `msg` `invalid_credentials`.

If the engine is changed to `.cloudAPI`, success `data` is the API extract instead of `bucket` / `package_path`. Drop `uploadWithoutProcessingIsOn` in that case. The flag is ignored unless the engine is `.none`.

## Conflicts and do-not

- Do not `import VeryfiLens` against the Lite XCFramework. The module name is `VeryfiLensLite`.
- Do not add the Full package `veryfi-lens-spm` to an App Clip and call it Lite.
- Do not call `showVoice`, `showEmail`, or `attachDocumentTo`.
- Do not set `anyDocumentType` because those JSON files are in the binary.
- Do not set `documentTypes` to `check`, `barcode`, or `credit_card` on this resource list.
- Do not leave `backupDocsToGallery` true in a clip.
- Do not overlap `showCamera` and a SwiftUI cover.
- `headlessUpload` on this class is the UI SDK helper, not `VeryfiLensHeadless`.

## Source

- [flavor-matrix.md](../flavor-matrix.md)
- [implementation.md](../implementation.md) — configure, delegate, remote-package decoupling
- [LensWrapper.swift](../../../Lens-Clip/LensWrapper.swift) — in-repo App Clip host
- [VeryfiLens.swift](../../../Veryfi-Lens/Public/VeryfiLens.swift) — public entry compiled into Lite
- [VeryfiLensCore.swift](../../../Veryfi-Lens/Public/VeryfiLensCore.swift) — not a member of the Lite target
- [VeryfiLensLite.modulemap](../../../Veryfi-Lens/Resources/VeryfiLensLite.modulemap)
- [SPM.swift](../../../fastlane/swift/FastlaneSwiftRunner/SPM.swift) — lite repo commented out
- [Pipeline.swift](../../../fastlane/swift/FastlaneSwiftRunner/Pipeline.swift) — `supportsSPM` false for `.lite`
- Lite target `IPHONEOS_DEPLOYMENT_TARGET` 15.0 and `SWIFT_ACTIVE_COMPILATION_CONDITIONS` `APP_CLIP` in `Veryfi-Lens.xcodeproj`
