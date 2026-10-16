# Flavor and install matrix

Release facts come from `Pipeline.supportsSPM`, `Pipeline.supportsCocoaPods`, `SPM.spmRepoName`, `SPM.frameworkName`, `Cocoapods.frameworkName`, `Cocoapods.cocoapodsRepo`, and `Builder.FrameworkType.rawValue` (that raw value is the podspec name).

Public install pages often paste the Full package URL even when the pipeline publishes a different repo, or when it publishes no dedicated SPM repo. Follow this matrix. Do not install a trimmed flavor from the Full package.

## How to install

**Swift Package Manager.** Xcode → File → Add Package Dependencies. Credentials are the Lens CocoaPods/SPM key from the Veryfi hub. The only public package URL confirmed on the docs site is:

`https://repo.veryfi.com/shared/lens/veryfi-lens-spm.git`

That URL is the **Full** UI binary. Dedicated repos in the table below are published by the iOS release pipeline to `shared/lens/<repo>.git` (GitLab remote `git@gitlab.services.veryfi.com:shared/lens/<repo>.git`). The same `https://repo.veryfi.com/shared/lens/<repo>.git` host for those other repo names is **Unconfirmed**, because the public installation pages checked below still show `veryfi-lens-spm.git`.

Commented repo names in `SPM.swift` (`veryfi-lens-spm-lite`, `veryfi-lens-spm-headless-credit-cards`) are not published. `supportsSPM` is false for those cases.

**CocoaPods.** Public docs call CocoaPods deprecated and prefer SPM. It remains the pipeline path for every flavor in this matrix (`supportsCocoaPods` is false only for Prescription Labels, Field Detection, and Remote Models, which are outside this matrix).

```ruby
source 'https://repo.veryfi.com/shared/lens/veryfi-lens-podspec.git'
source 'https://github.com/CocoaPods/Specs.git'

target 'YourApp' do
  use_frameworks!
  pod 'POD_NAME'
end
```

Replace `POD_NAME` with the pod column. Version pin syntax on the public pages is `pod 'POD_NAME', 'x.x.x.x', :linkage => :dynamic`. The current version number is **Unconfirmed** here; use the version Veryfi gave the customer.

**Manual XCFramework.** Embed the file in the XCFramework column. UI flavors other than Lite all ship a file named `VeryfiLens.xcframework`. The pod name is what selects the flavor. Embedding a Full `VeryfiLens.xcframework` does not turn it into Checks or OCR.

## Matrix

| Template | Pod (`FrameworkType.rawValue`) | Dedicated SPM | SPM repo | XCFramework | Swift import | CocoaPods repo |
|----------|--------------------------------|---------------|----------|-------------|--------------|----------------|
| [Full](templates/full.md) | `VeryfiLens` | Yes | `veryfi-lens-spm` | `VeryfiLens.xcframework` | `VeryfiLens` | `veryfi-lens-cocoapods` |
| [Receipts](templates/receipts.md) | `VeryfiLens-Receipts` | Yes | `veryfi-lens-spm-receipts` | `VeryfiLens.xcframework` | `VeryfiLens` | `veryfi-lens-cocoapods-receipts` |
| [Long receipts](templates/long-receipts.md) | `VeryfiLens-LongReceipts` | Yes | `veryfi-lens-spm-long-receipts` | `VeryfiLens.xcframework` | `VeryfiLens` | `veryfi-lens-cocoapods-long-receipts` |
| [Lite App Clip](templates/lite-app-clip.md) | `VeryfiLens-Lite` | **No** | none published | `VeryfiLensLite.xcframework` | `VeryfiLensLite` | `veryfi-lens-cocoapods-lite` |
| [Checks](templates/checks.md) | `VeryfiLens-Cheques` | Yes | `veryfi-lens-spm-checks` | `VeryfiLens.xcframework` | `VeryfiLens` | `veryfi-lens-cocoapods-cheques` |
| [Credit cards UI](templates/credit-cards-ui.md) | `VeryfiLens-CreditCards` | **No** | none published | `VeryfiLens.xcframework` | `VeryfiLens` | `veryfi-lens-cocoapods-credit-cards` |
| [Business cards](templates/business-cards.md) | `VeryfiLens-BusinessCards` | **No** | none published | `VeryfiLens.xcframework` | `VeryfiLens` | `veryfi-lens-cocoapods-business-cards` |
| [Barcodes](templates/barcodes.md) | `VeryfiLens-Barcodes` | **No** | none published | `VeryfiLens.xcframework` | `VeryfiLens` | `veryfi-lens-cocoapods-barcodes` |
| [Headless credit cards](templates/headless-credit-cards.md) | `VeryfiLensHeadless-CreditCards` | **No** | none published | `VeryfiLensHeadlessCreditCards.xcframework` | `VeryfiLensHeadlessCreditCards` | `veryfi-lens-headless-cocoapods-credit-cards` |
| [Headless receipts](templates/headless-receipts.md) | `VeryfiLensHeadless-Receipts` | Yes | `veryfi-lens-spm-headless-receipts` | `VeryfiLensHeadlessReceipts.xcframework` | `VeryfiLensHeadlessReceipts` | `veryfi-lens-headless-cocoapods-receipts` |
| [OCR strips](templates/ocr-code-strips.md) / [OCR caps](templates/ocr-code-caps.md) | `VeryfiLens-OCR` | **No** | none published | `VeryfiLens.xcframework` | `VeryfiLens` | `veryfi-lens-cocoapods-ocr` |
| [W-2](templates/w2.md) | `VeryfiLens-W2` | **No** | none published | `VeryfiLens.xcframework` | `VeryfiLens` | `veryfi-lens-cocoapods-w2` |
| [W-9](templates/w9.md) | `VeryfiLens-W9` | **No** | none published | `VeryfiLens.xcframework` | `VeryfiLens` | `veryfi-lens-cocoapods-w9` |

OCR strips and OCR caps are one binary. `ocrType` selects the mode.

There is also an internal Full package `veryfi-lens-spm-internal` (`SPM` `isCore: true`). That is not a customer package. The word Core in that flag is not the Lite App Clip, and it is not `Veryfi-Lens-Core` (`VeryfiLensCore.swift`).

## Public installation pages checked

These pages were fetched while writing this matrix. Each one shows SPM `https://repo.veryfi.com/shared/lens/veryfi-lens-spm.git`.

| Page | Pod the page shows | Matrix correction |
|------|--------------------|-------------------|
| [Receipts installation](https://docs.veryfi.com/lens/mobile/receipts/installation/) | `VeryfiLens` | That is the **Full** pod and the Full SPM repo. The receipts-specific pod is `VeryfiLens-Receipts` and the receipts SPM repo is `veryfi-lens-spm-receipts`. |
| [Long receipts installation](https://docs.veryfi.com/lens/mobile/long-receipts/installation/) | `VeryfiLens-LongReceipts` | Pod matches. Dedicated SPM repo is `veryfi-lens-spm-long-receipts`, not `veryfi-lens-spm`. |
| [Checks installation](https://docs.veryfi.com/lens/mobile/checks/installation/) | `VeryfiLens-Cheques` | Pod matches, including the Cheques spelling. Dedicated SPM repo is `veryfi-lens-spm-checks`. |
| [Headless receipts installation](https://docs.veryfi.com/lens/mobile/headless/receipts/installation/) | `VeryfiLensHeadless-Receipts` | Pod matches. Dedicated SPM repo is `veryfi-lens-spm-headless-receipts`. |
| [Headless credit cards installation](https://docs.veryfi.com/lens/mobile/headless/credit_cards/installation/) | `VeryfiLensHeadless-CreditCards` | Pod matches. No dedicated SPM repo is published. Do not use `veryfi-lens-spm` for this product. |

Public installation URLs for Credit Cards UI, Business Cards, Barcodes, OCR, W-2, W-9, and Lite were **not** fetched. Pod and SPM columns above still come from the release pipeline. **Unconfirmed** which public URL, if any, documents those pages.

## Client types

UI templates (Full through W-9, including Lite) construct `VeryfiLensSettings()`. Demo subclasses such as `VeryfiLensReceiptsSettings`, `VeryfiLensChecksSettings`, `VeryfiLensCodeSettings`, `VeryfiLensCreditCardSolutionSettings`, `VeryfiLensBusinessCardsSettings`, `VeryfiLensBarcodesSettings`, `VeryfiLensW2Settings`, and `VeryfiLensW9Settings` are not the client contract.

Headless templates use different types:

| Product | Settings type | Entry |
|---------|---------------|--------|
| Headless credit cards | `VeryfiLensCreditCardsSettings` | `VeryfiLensHeadless.shared()` |
| Headless receipts | `VeryfiLensReceiptSettings` | `VeryfiLensHeadless.shared()` |

`VeryfiLensReceiptSettings` (headless, singular Receipt) is not `VeryfiLensReceiptsSettings` (Demo UI subclass).

Lite imports `VeryfiLensLite` and still uses `VeryfiLens` / `VeryfiLensSettings` / `VeryfiLensCredentials`. It compiles `VeryfiLens.swift`, not `VeryfiLensCore.swift`. Core-only methods `showVoice(in:)`, `showEmail(in:)`, and `attachDocumentTo(documentId:in:)` are absent from the Lite target.

## Source

- [SPM.swift](../../fastlane/swift/FastlaneSwiftRunner/SPM.swift) — repo names, commented lite and headless-credit-card repos, XCFramework file names
- [Pipeline.swift](../../fastlane/swift/FastlaneSwiftRunner/Pipeline.swift) — `supportsSPM`, `supportsCocoaPods`
- [Cocoapods.swift](../../fastlane/swift/FastlaneSwiftRunner/Cocoapods.swift) — pod repos and XCFramework file names
- [Builder.swift](../../fastlane/swift/FastlaneSwiftRunner/Builder.swift) — `FrameworkType` raw values (pod names) and output paths
