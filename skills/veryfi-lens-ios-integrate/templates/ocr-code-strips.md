# OCR code, strips

Same binary as [caps](ocr-code-caps.md). Pod `VeryfiLens-OCR`. No dedicated SPM repo. Do not install `veryfi-lens-spm`.

`ocrType = .strips` selects strips. `OCRType.strips` string is `"strips"`. The document-ready / uploader parameter `ocrType.param` is `"pepsico_codes"`. Caps use `"pepsico_caps"`.

Public installation URL was not fetched. **Unconfirmed** docs page. Pod name is `VeryfiLens-OCR`.

Client settings type: `VeryfiLensSettings()`. Do not use `VeryfiLensCodeSettings`.

On-device read uses `.inApp`. `OCREventsHelper` then posts document-ready with `document_type` rewritten to `mobile_ocr` and includes `ocr_text` and `ocr_score`. The text is in that notification and in the delegate payload. This is not a credit-card PAN path.

## Artifact and import

| | |
|--|--|
| Pod | `VeryfiLens-OCR` |
| Dedicated SPM | **No** |
| XCFramework file name | `VeryfiLens.xcframework` |
| Import | `import VeryfiLens` |

```swift
import VeryfiLens
```

## Permissions

| Key | When |
|-----|------|
| `NSCameraUsageDescription` | Camera |
| `NSPhotoLibraryUsageDescription` | not required while gallery is off |
| `NSPhotoLibraryAddUsageDescription` | not required |
| `NSLocationWhenInUseUsageDescription` | not required |

## Settings

CPG code recipe from [recipes.md](../recipes.md), strips mode, plus base hardening.

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
settings.documentTypes = ["code"]
settings.showDocumentTypes = false
settings.autoCaptureIsOn = true
settings.galleryIsOn = false
settings.stitchIsOn = false
settings.moreMenuIsOn = false
settings.autoLightDetectionIsOn = false
settings.continuousAutoFocus = true
settings.ocrType = .strips
settings.ocrRegex = "[A-Z0-9]{10}" // replace with the customer's pattern
```

`ocrRegex` is the customer’s pattern. The example is the recipe placeholder, not a universal code format. Empty `ocrRegex` is the SDK default. Whether an empty pattern still autocaptures is **Unconfirmed**. Set the customer’s expression.

Optional chrome, SDK defaults: `ocrBorderColor` `"#287cf6"`, `ocrBorderStroke` `10`, `ocrRadius` `85`, `ocrViewWidth` `85`, `ocrViewHeight` `8`, `ocrViewCornerRadius` `20`. The Demo code subclass sets border `"#00FA6CFF"` and does not change the view size. This template leaves the SDK chrome defaults. Assign them only when the host has a brand color.

`continuousAutoFocus` is for codes held close to the lens.

Remote Models flavor (not this binary) downloads strip vs caps graphs from `ocrType`. This OCR flavor embeds its models. Which file is strips versus caps inside `VeryfiLens-OCR` is **Unconfirmed** beyond the runtime enum.

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

A finished code closes the camera: `imageProcessorDidProcessOCR` sends success, then `closeLens()` on the main queue.

SwiftUI: `.veryfiLensFullScreenCover(isPresented:flow: .camera)`.

`VeryfiLens.shared().shareOCRFeedback()` shares the last code-scan logs. No camera UI. Call it after a scan the host wants to report. It is not required for a normal read.

## Callbacks

OCR success is `OCRResult.json` passed directly to `veryfiLensSuccess`. It does not use the package envelope `status: "done"`.

| Key | Meaning |
|-----|---------|
| `ocr_text` | Matched text. `""` if nil |
| `ocr_score` | Double |
| `ocr_uuid` | Local id. Also the document-ready `session_id` |
| `ocr_image` | `Documents/ocrImage.jpg` after success saves the crop. `""` on the live update |
| `ocr_type` | `"strips"` on the processed callback, because the presenter sets `result.ocrType` from settings. The live update path does not set `ocrType`, so the key is `""` there |

`veryfiLensUpdate` is the live `OCREventsHelper.update` payload, same keys, image still empty.

`veryfiLensClose` follows the scheduled camera dismiss.

`veryfiLensError` is for configure and credential failures. OCR mismatch strings are **Unconfirmed**. A read that never matches simply does not call success.

`PackageUploader.inAppAPIProcessing` is the credit-card package path. This camera path does not wait for it.

## Conflicts and do-not

- Do not set `ocrType` to `.caps` in a strips integration. Use [ocr-code-caps.md](ocr-code-caps.md). The binary can do both. The setting picks one.
- Do not set `documentTypes` to `barcode`. That is the barcodes flavor.
- Do not set `.cloudAPI` for the live read.
- Do not set `stitchIsOn` true.
- Do not install `veryfi-lens-spm`.
- Do not use `VeryfiLensCodeSettings`.
- `ocrRegex` on a receipts flavor is ignored. This template is the code flavor, where the regex applies.

## Source

- [flavor-matrix.md](../flavor-matrix.md)
- [recipes.md](../recipes.md) — `cpg-code`
- [OCRType.swift](../../../VeryfiLensEngine/Shared/Models/OCRType.swift)
- [OCRResult.swift](../../../VeryfiLensEngine/Shared/Models/OCRResult.swift)
- [OCREventsHelper.swift](../../../Veryfi-Lens/Helpers/OCREventsHelper.swift)
- [CameraPresenter.swift](../../../Veryfi-Lens/Scenes/Camera/CameraPresenter.swift) — `imageProcessorDidProcessOCR`
- [VeryfiLensSettings.swift](../../../Veryfi-Lens/Public/Model/VeryfiLensSettings.swift) — `ocrType` default `.strips`, `ocrRegex` default `""`
- [NetworkHelper.swift](../../../VeryfiLensEngine/Shared/Upload/Networking/API/NetworkHelper.swift) — `mobile_ocr`
- [Pipeline.swift](../../../fastlane/swift/FastlaneSwiftRunner/Pipeline.swift) — `.ocr` not in `supportsSPM`
