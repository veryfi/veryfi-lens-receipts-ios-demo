# OCR code, caps

Same install as [strips](ocr-code-strips.md). One pod, `VeryfiLens-OCR`. No dedicated SPM. The only settings change from the strips template is `ocrType = .caps`.

`OCRType.caps` string is `"caps"`. Uploader parameter `ocrType.param` is `"pepsico_caps"`.

Client settings type: `VeryfiLensSettings()`. Do not use `VeryfiLensCodeSettings`.

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

Public installation URL was not fetched. **Unconfirmed** docs page.

## Permissions

| Key | When |
|-----|------|
| `NSCameraUsageDescription` | Camera. Caps are held close to the lens |
| `NSPhotoLibraryUsageDescription` | not required while gallery is off |
| `NSPhotoLibraryAddUsageDescription` | not required |
| `NSLocationWhenInUseUsageDescription` | not required |

## Settings

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
settings.ocrType = .caps
settings.ocrRegex = "[A-Z0-9]{10}" // replace with the customer's pattern
```

`continuousAutoFocus` matters more for caps than for a flat strip: macro lens when available, near autofocus, and a center refocus when the preview center blurs. That behavior is the settings-catalog description of the flag.

Chrome defaults match strips (`ocrBorderColor` `"#287cf6"`, stroke `10`, radius `85`). `ocrViewHeight` default `8` is a short strip-shaped window. Whether caps should use a different `ocrViewHeight` / `ocrRadius` is **Unconfirmed**. Leave the defaults unless the host has a measured frame.

`ocrRegex` must be the customer’s cap pattern. The placeholder is from the shared code recipe.

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

Success is delivered, then the camera close is scheduled on the main queue (`imageProcessorDidProcessOCR`).

SwiftUI camera cover is the other path. One presentation only.

`shareOCRFeedback()` shares the last code-scan logs after a failed or sample scan the host wants to send. It does not return the OCR text.

## Callbacks

Same direct `OCRResult.json` as strips. On the processed success, `ocr_type` is `"caps"`.

| Key | Meaning |
|-----|---------|
| `ocr_text` | Text |
| `ocr_score` | Double |
| `ocr_uuid` | Local id and document-ready session id |
| `ocr_image` | `Documents/ocrImage.jpg` on success. `""` on live update |
| `ocr_type` | `"caps"` after processing. `""` on `veryfiLensUpdate` because the update helper does not set `ocrType` |

Document-ready uses `document_type` `mobile_ocr` plus `ocr_text` and `ocr_score` (`NetworkHelper`). The delegate payload is still the table above, not that request body.

`veryfiLensClose` is the camera dismiss. `veryfiLensError` is configure and credential failure.

## Conflicts and do-not

- Do not leave `ocrType` at the SDK default `.strips` if the product is caps. The default is strips, so this template must assign `.caps`.
- Do not ship strips and caps in one settings object. One `ocrType` per configure. Call `utils.update(settings:)` only if the host switches mode without a full reconfigure. `update` does not re-validate credentials. Whether the OCR detector reloads the caps graph on `update` without a new `configure` is **Unconfirmed**. Prefer a fresh `configure` when switching strips and caps.
- Do not set `documentTypes` to `barcode`.
- Do not set `.cloudAPI` for the live read.
- Do not install `veryfi-lens-spm`.
- Do not use `VeryfiLensCodeSettings`.

## Source

- [ocr-code-strips.md](ocr-code-strips.md) — shared binary and callback path
- [flavor-matrix.md](../flavor-matrix.md)
- [recipes.md](../recipes.md) — `ocrType = .caps` for bottle caps
- [OCRType.swift](../../../VeryfiLensEngine/Shared/Models/OCRType.swift)
- [OCRResult.swift](../../../VeryfiLensEngine/Shared/Models/OCRResult.swift)
- [settings-catalog.md](../settings-catalog.md) — `continuousAutoFocus`
- [VeryfiLensSettings.swift](../../../Veryfi-Lens/Public/Model/VeryfiLensSettings.swift) — `ocrType` default `.strips`
