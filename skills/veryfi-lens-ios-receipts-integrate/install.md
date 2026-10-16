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

## App size

When installed size matters, recommend the **Remote Models** flavor. A specific flavor embeds its models in the binary. Remote Models keeps that binary smaller and downloads most of the heavy model resources after install, only for the features the host turned on.

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
