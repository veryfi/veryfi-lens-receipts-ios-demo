# Business cards

Pod `VeryfiLens-BusinessCards`. No dedicated SPM repo is published. Do not install `veryfi-lens-spm` for this flavor.

Public installation URL was not fetched. **Unconfirmed** docs page. Pod name is `VeryfiLens-BusinessCards`.

There is no business-card block in [recipes.md](../recipes.md). Settings below are the flavor’s document type from the skill table, cloud extraction (business cards are not an `.inApp` type), a single hidden picker, stitch off (card recipe rule), and base hardening. Gallery is turned off to match the other card camera recipe. The SDK default of `galleryIsOn` is true, so the assignment is required. Turn gallery on only if the host wants Photos import. Whether this binary detects a business card in a gallery image is **Unconfirmed**.

Client settings type: `VeryfiLensSettings()`. Do not use `VeryfiLensBusinessCardsSettings`. That Demo subclass also sets `anyDocumentType = "passport"`, which is the deprecated local regex matcher and must not be copied.

## Artifact and import

| | |
|--|--|
| Pod | `VeryfiLens-BusinessCards` |
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
| `NSPhotoLibraryUsageDescription` | only if gallery is turned back on |
| `NSPhotoLibraryAddUsageDescription` | only if gallery backup is on |
| `NSLocationWhenInUseUsageDescription` | only if location is on |

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

settings.dataExtractionEngine = .cloudAPI
settings.documentTypes = ["business_card"]
settings.showDocumentTypes = false
settings.autoCaptureIsOn = false
settings.galleryIsOn = false
settings.stitchIsOn = false
settings.moreMenuIsOn = false
settings.returnStitchedPDF = true
```

`autoCaptureIsOn` stays false (SDK default and the usual review-then-submit card flow). Auto-capture for business cards is **Unconfirmed** as a product default, so this template does not turn it on.

`cameraProcessingMode` is documented for `any_document`. Whether the business-card detector reads that enum is **Unconfirmed**. Leave it unset.

`returnStitchedPDF` true with `stitchIsOn` false asks for a PDF of the capture without a multi-image stitch. If the host only wants the cloud JSON, set `returnStitchedPDF` false. The PDF flag’s exact output for a one-image business card is **Unconfirmed** beyond “the recipe used for other single-frame forms sets it true.”

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

SwiftUI: `.veryfiLensFullScreenCover(isPresented:flow: .camera)`.

Cloud extraction needs a network path after configure. Configure itself validates credentials.

## Callbacks

Standard `VeryfiLensDelegate`. Success `status` `"done"` is the Process a Document payload for `.cloudAPI`. Field names inside `data` are the business-card API response. This pack does not list those API fields. Do not invent them.

`veryfiLensUpdate` still carries image paths. Copy them immediately if `autoDeleteLocalResourcesAfterProcessing` stays at its default true.

`document_type` on success is `business_card` when the package type is set.

## Conflicts and do-not

- Do not set `anyDocumentType`.
- Do not set `.inApp`.
- Do not set `stitchIsOn` true.
- Do not set `cameraProcessingMode` unless support says this flavor honors it.
- Do not install the Full SPM package.
- Do not use the Demo business-card settings subclass.
- `showDocumentTypes` stays false for this one-type list.

## Source

- [flavor-matrix.md](../flavor-matrix.md)
- [SKILL.md](../SKILL.md) — flavor row `business_card`, `.inApp` limited to credit card, code, and barcode
- [conflicts.md](../conflicts.md) — stitch off for cards
- [VeryfiLensSettings.swift](../../../Veryfi-Lens/Public/Model/VeryfiLensSettings.swift) — `galleryIsOn` default true, `autoCaptureIsOn` default false
- [DocumentType.swift](../../../VeryfiLensEngine/Shared/Models/DocumentType.swift) — `business_card`
- [Pipeline.swift](../../../fastlane/swift/FastlaneSwiftRunner/Pipeline.swift) — no business-card SPM case
