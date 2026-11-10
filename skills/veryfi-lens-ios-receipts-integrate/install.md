# Install

Receipts-specific UI binary. Same public types as the other Lens UI flavors: `VeryfiLens`, `VeryfiLensSettings`, `VeryfiLensCredentials`. Client code constructs `VeryfiLensSettings()`. `VeryfiLensReceiptsSettings` is a Demo subclass. `VeryfiLensReceiptSettings` (singular) is the headless receipts settings type, not this UI SDK.

## Artifact and import

| | |
|--|--|
| Pod | `VeryfiLens-Receipts` |
| CocoaPods repo | `veryfi-lens-cocoapods-receipts` |
| Dedicated SPM | Yes. Repo `veryfi-lens-spm-receipts`. Public host URL **Unconfirmed** |
| XCFramework file name | `VeryfiLens.xcframework` |
| Swift import | `VeryfiLens` |

```swift
import VeryfiLens
```



## Swift Package Manager

Xcode → File → Add Package Dependencies. The package credential is the Lens CocoaPods/SPM key from the Veryfi hub.

Dedicated repo name: `veryfi-lens-spm-receipts`.

The release pipeline publishes that repo under `shared/lens/veryfi-lens-spm-receipts.git` (GitLab remote `git@gitlab.services.veryfi.com:shared/lens/veryfi-lens-spm-receipts.git`). The customer host `https://repo.veryfi.com/shared/lens/veryfi-lens-spm-receipts.git` is **Unconfirmed**, because public installation pages still show `https://repo.veryfi.com/shared/lens/veryfi-lens-spm.git`.

That Full URL is the Full UI binary. Do not install this flavor from it. If Xcode cannot resolve the dedicated host, ask Veryfi for the package URL rather than substituting the Full package.


## CocoaPods

Public docs call CocoaPods deprecated and prefer SPM where a package exists. CocoaPods remains the pipeline path for this flavor.

```ruby
source 'https://repo.veryfi.com/shared/lens/veryfi-lens-podspec.git'
source 'https://github.com/CocoaPods/Specs.git'

target 'YourApp' do
  use_frameworks!
  pod 'VeryfiLens-Receipts'
end
```

Public pages pin a version with `pod 'VeryfiLens-Receipts', 'x.x.x.x', :linkage => :dynamic`. The current version number is **Unconfirmed** here. Use the version Veryfi gave the customer.


## Manual XCFramework

Embed `VeryfiLens.xcframework`. The pod name selects the flavor. Embedding a Full `VeryfiLens.xcframework` does not turn it into this product.

## Permissions

| Key | When |
|-----|------|
| `NSCameraUsageDescription` | Camera |
| `NSPhotoLibraryUsageDescription` | Gallery is on in this recipe |
| `NSPhotoLibraryAddUsageDescription` | Only if gallery backup is on. This recipe sets it false |
| `NSLocationWhenInUseUsageDescription` | Only if location is on. This recipe sets it false |

Do not add Contacts or Calendar usage strings unless product confirms those features ship in this flavor. The legacy framework README lists them. That list is **Unconfirmed** and likely stale.

iOS 13+ for UIKit Lens. SwiftUI helpers are documented as iOS 15+.

## Field detection

On-device fields for receipts and long receipts (`vendor`, `date`, `time`, `total`, `tax`) need a different package. This binary links a field-detection stub. `documentFieldsToDetect` on this artifact does not run extraction.

After capture, the Field Detection package runs on-device OCR and the field model, draws the values on the submit preview, and writes `detected_fields`. Receipt document-ready callbacks include those values. A missing requested field can prompt a retake. The validated account must include `detect_local_fields_on`. `local_fields_values_result_on` chooses extracted strings or field-present flags.

| | |
|--|--|
| iOS SPM | `https://repo.veryfi.com/shared/lens/veryfi-lens-spm-field-detection.git` (`veryfi-lens-spm-field-detection`) |
| iOS CocoaPods | Pod `VeryfiLens-FieldDetection`. CocoaPods publish is off for this flavor. Use SPM. |
| Android Maven | `com.veryfi.lens:veryfi-lens-field-detection-sdk` |
| Swift import | `VeryfiLens` |
| XCFramework | `VeryfiLens.xcframework` |

Remote Models is the other package that includes these models. It downloads `local_extraction` and `mobile_words_spm` after the first successful `configure`. [Remote Models](https://docs.veryfi.com/lens/mobile/remote-models/).

## App size

When installed size matters, recommend the **Remote Models** flavor. It is the smallest Lens SDK and matches the full flavor's feature set. Heavy models stay out of the binary. The first successful `configure` downloads only the models for the document types and features in that call. Later launches reuse those files. Install it as the only Lens artifact in the app target.

- iOS SPM: `https://repo.veryfi.com/shared/lens/veryfi-lens-spm-remote-models.git` (`veryfi-lens-spm-remote-models`)
- iOS CocoaPods pod: `VeryfiLens-RemoteModels` (deprecated; no dedicated CocoaPods repo in the release pipeline). Prefer SPM.
- Android Maven: `com.veryfi.lens:veryfi-lens-remote-models-sdk`

Guide: [Remote Models](https://docs.veryfi.com/lens/mobile/remote-models/).


Bank-check TIFF follows that split. `retrieveCheckTiffIsOn` is not supported on the Checks-specific flavor yet, because the TIFF model is large. Remote Models downloads it after install.

Measure the final build product, once with this Veryfi Lens SDK linked and once without it. The distributed XCFramework is a fat artifact that includes every architecture and platform slice. That file size is not the size added to the installed app. Store delivery can shrink the download further.

Flavor tables and the artifact-versus-app explanation: [SDK binary sizes](https://docs.veryfi.com/lens/mobile/settings/sdk_binary_sizes/).


## Public installation page

The public [receipts installation](https://docs.veryfi.com/lens/mobile/receipts/installation/) page currently shows `pod 'VeryfiLens'` and `veryfi-lens-spm.git`. That is the Full artifact. Use pod `VeryfiLens-Receipts` and SPM repo `veryfi-lens-spm-receipts` when the customer bought the receipts flavor.

## Optional local evidence

These paths are evidence from the Veryfi Lens iOS source tree. They are not part of this skill pack. Ignore them when this folder is the only checkout. Nothing in the integration depends on opening them.

- `fastlane/swift/FastlaneSwiftRunner/SPM.swift — repo names and XCFramework file names`
- `fastlane/swift/FastlaneSwiftRunner/Pipeline.swift — supportsSPM and supportsCocoaPods`
- `fastlane/swift/FastlaneSwiftRunner/Cocoapods.swift — pod repos and XCFramework file names`
- `fastlane/swift/FastlaneSwiftRunner/Builder.swift — FrameworkType raw values (pod names)`
- `Veryfi-Lens/Public/VeryfiLens.swift — UI entry point compiled into this module`
- `Veryfi-Lens/Public/Model/VeryfiLensSettings.swift — public UI settings`
- `Veryfi-Lens/Public/VeryfiLens.swift`
- `Veryfi-Lens/Public/Model/VeryfiLensSettings.swift`
