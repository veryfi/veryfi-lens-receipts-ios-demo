# Checks

Pod `VeryfiLens-Cheques` (Cheques spelling). Dedicated SPM repo `veryfi-lens-spm-checks`.

The public [checks installation](https://docs.veryfi.com/lens/mobile/checks/installation/) page shows that pod and the Full SPM URL. Use `veryfi-lens-spm-checks` for SPM.

Bank-check TIFF is not in this specific flavor. The TIFF model is large. TIFF needs the Remote Models flavor and `retrieveCheckTiffIsOn`. This template does not set that flag.

Client settings type: `VeryfiLensSettings()`. Do not use `VeryfiLensChecksSettings`.

## Artifact and import

| | |
|--|--|
| Pod | `VeryfiLens-Cheques` |
| Dedicated SPM | Yes. Repo `veryfi-lens-spm-checks`. Public mirror URL **Unconfirmed** |
| XCFramework file name | `VeryfiLens.xcframework` |
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

## Settings

Banking recipe from [recipes.md](../recipes.md), plus base hardening. Capture only on this flavor: cloud extract of the check images, no TIFF block.

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
settings.documentTypes = ["check"]
settings.showDocumentTypes = false
settings.stitchIsOn = false
settings.autoCaptureIsOn = false
settings.galleryIsOn = true
settings.browseIsOn = true
settings.moreMenuIsOn = false
settings.checksBackIsOn = true
settings.checksBackIsRequired = false
settings.checkSequenceMode = true
settings.forceLandscapeImage = true
settings.autoSelectManualCropIsOn = true
settings.autoRotateIsOn = true
settings.autoSkewCorrectionIsOn = false
settings.captureMarginRatio = 0.08
settings.checksCropMargin = 2
settings.checksMinAspectRatio = 1.9
settings.checksMaxAspectRatio = 2.85
settings.forceCropLayoutOnRetake = true
settings.cropLayoutShowDelay = 15.0
settings.cropLayoutAspectRatio = 2.18
settings.cropLayoutWidth = UIDevice.current.userInterfaceIdiom == .pad ? 42 : 60
settings.cropLayoutCornerRadius = 5
settings.cropLayoutOverlayAlpha = 0.3
settings.validateCheckSize = true
settings.validateCheckSides = true
settings.validateCheckCorners = false
settings.allowSubmitCheckSideNotDetected = true
settings.allowSubmitCheckCornersNotDetected = true
settings.allowSubmitUndetectedDocsIsOn = false
settings.returnStitchedPDF = true
```

`checksBackIsRequired = true` when both sides are mandatory. `validateCheckCorners = true` is optional and can be aggressive.

`browseIsOn` does not show a Browse row while `moreMenuIsOn` is false. Gallery import still uses `galleryIsOn`. Standalone Files uses `showDocumentBrowser(in:)`.

Back of a check uses `checksBackIsOn` / `checkSequenceMode`, not `anyDocumentBackIsOn`.

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

Front-then-back is inside the Lens camera when `checkSequenceMode` is true. The host presents once.

SwiftUI: `.veryfiLensFullScreenCover` with `.camera`. One path only.

## Callbacks

Standard `VeryfiLensDelegate`. Cloud success `status` is `"done"`. Check image paths use the usual `img_original_path` / `img_paths` update messages.

`img_check_front_tiff_path` and `img_check_back_tiff_path` appear only when `retrieveCheckTiffIsOn` is on, which this Checks flavor does not support. Do not read those keys on this binary.

`allowSubmitUndetectedDocsIsOn` is false. Users can still continue when side or corner checks fail because `allowSubmitCheckSideNotDetected` and `allowSubmitCheckCornersNotDetected` are true. If those allow-anyway flags are also false, the camera can trap the user.

## Conflicts and do-not

- Do not set `retrieveCheckTiffIsOn` or `rejectInvalidCheckTIFF` on this flavor.
- Do not set `stitchIsOn` true.
- Do not set `autoSubmitDocumentOnCapture` or `batchUploadOnCamera` with this recipe.
- Do not use `anyDocumentBackIsOn` for the check back.
- Do not set `packageMaxScans` to 1 when a back image is required. The SDK default is 10, which fits a front and a back. This recipe leaves that default.
- Do not set `.inApp`.
- Do not install the Full SPM package in place of `veryfi-lens-spm-checks`.

## Source

- [flavor-matrix.md](../flavor-matrix.md)
- [recipes.md](../recipes.md) — `banking-checks`
- [conflicts.md](../conflicts.md) — TIFF flavor limit, check back flags
- [implementation.md](../implementation.md) — TIFF path keys
- [VeryfiLensSettings.swift](../../../Veryfi-Lens/Public/Model/VeryfiLensSettings.swift)
- [SPM.swift](../../../fastlane/swift/FastlaneSwiftRunner/SPM.swift) — `.checks`
