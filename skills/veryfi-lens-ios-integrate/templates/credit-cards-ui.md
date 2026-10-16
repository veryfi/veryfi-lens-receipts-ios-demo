# Credit cards (Lens UI)

Pod `VeryfiLens-CreditCards`. No dedicated SPM repo is published. `supportsSPM` has no credit-card case. Do not add `veryfi-lens-spm`. Install the pod or embed the credit-card `VeryfiLens.xcframework` Veryfi supplied for this flavor.

Public installation URL for this UI flavor was not fetched. **Unconfirmed** whether a docs page exists. Pod name is `Builder.FrameworkType.creditCards` (`VeryfiLens-CreditCards`).

This is the Lens camera UI, not headless. Headless uses `VeryfiLensHeadless` and `VeryfiLensCreditCardsSettings`. See [headless-credit-cards.md](headless-credit-cards.md).

Client settings type: `VeryfiLensSettings()`. Do not use `VeryfiLensCreditCardSolutionSettings`.

Card data stays on device. `.inApp` (`"mobile"`) is required. `veryfiLensSuccess` `data` is the on-device extraction.

`inAppAPIProcessing` also calls `packageIsReadyToUpload`, which posts document-ready with `document_type` `credit_card`, engine `mobile`, and no PAN fields. `NetworkHelper.documentReady` adds OCR or barcode bodies only for `code` and `barcode`. `forceUsingPatnerEndpoint` follows `DocumentType.isCard`, which is business card, insurance card, passport, and driver license. `creditCard` is not in that set, so a credit-card package does not force the partner endpoint through this flag. The PAN stays in the delegate payload.

## Artifact and import

| | |
|--|--|
| Pod | `VeryfiLens-CreditCards` |
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
| `NSPhotoLibraryUsageDescription` | not required while gallery stays off |
| `NSPhotoLibraryAddUsageDescription` | not required. Backup stays off |
| `NSLocationWhenInUseUsageDescription` | not required. Location stays off |

## Settings

Credit-card recipe from [recipes.md](../recipes.md), plus base hardening.

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

`cropLayoutWithAutoDetection` is the hybrid frame plus green box. Do not also require `cropLayoutIsOn`. The saved crop is still the frame’s rectangular bounds.

`.cloudAPI` and `.none` must not be used for a card number. Those engines are the wrong place for card data.

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

SwiftUI camera cover is the other path. Gallery and Files are off in this recipe. Do not call `showGallery` unless `galleryIsOn` is turned on for a reason support agreed to. Whether the credit-card flavor detects a card in a gallery photo is **Unconfirmed**.

## Callbacks

`veryfiLensSuccess` for `.inApp` merges the on-device card dictionary into `data`. Keys from `CreditCard.json`:

| Key | Meaning |
|-----|---------|
| `credit_card_number` | PAN string |
| `credit_card_holder_name` | Name |
| `credit_card_date` | Date string. A second date is appended with `/` when present |
| `credit_card_type` | Brand string |
| `credit_card_cvv` | CVC |
| `credit_card_id` | Local UUID |
| `credit_card_is_invalid` | String from `(!isValidLuhn).description`, not a Bool |

`status` on that package success is `"done"`. If no card dictionary was stored, `inAppAPIProcessing` reports failure message `No data was extracted using VeryfiInApp engine`.

`data` may also gain `detected_fields`, `img_paths`, or `local_package_path` from `successData(merging:)`. Field detection is not part of this recipe.

The package is cleared after the in-app success. Copy the card fields inside `veryfiLensSuccess` before relying on image paths. Local auto-delete still defaults to true.

`veryfiLensClose` is the camera session ending. Card success and close are both delivered. The exact ordering beyond “success is emitted, then the camera close runs” is **Unconfirmed** for the UI coordinator versus the barcode/OCR path, which calls success and then schedules `closeLens()` on the main queue.

## Conflicts and do-not

- Do not set `dataExtractionEngine` to `.cloudAPI` or `.none`.
- Do not send the PAN to your own logs by default. The SDK success payload contains it so the host can use it.
- Do not use `VeryfiLensCreditCardsSettings` with `VeryfiLens.shared()`. That class is headless.
- Do not use `VeryfiLensCreditCardSolutionSettings`.
- Do not set `stitchIsOn` true.
- Do not install `veryfi-lens-spm` for this flavor.
- `showHelpButton` and `showInfoButton` still share one camera control if you add them later.

## Source

- [flavor-matrix.md](../flavor-matrix.md)
- [recipes.md](../recipes.md) — `credit-cards`
- [Pipeline.swift](../../../fastlane/swift/FastlaneSwiftRunner/Pipeline.swift) — credit cards omitted from `supportsSPM`
- [CreditCard.swift](../../../VeryfiLensEngine/Shared/Models/CreditCard.swift) — `json` keys
- [PackageUploader.swift](../../../VeryfiLensEngine/Shared/Upload/PackageUploader/PackageUploader.swift) — `inAppAPIProcessing`
- [VeryfiLens.swift](../../../Veryfi-Lens/Public/VeryfiLens.swift)
