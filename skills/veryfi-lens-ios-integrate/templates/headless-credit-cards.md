# Headless credit cards

No Lens camera. The host owns `AVCaptureSession` and passes `CMSampleBuffer`s to `VeryfiLensHeadless`.

Pod `VeryfiLensHeadless-CreditCards`. No dedicated SPM repo is published. `veryfi-lens-spm-headless-credit-cards` is a comment in `SPM.swift`, and `supportsSPM` is false. The public [headless credit cards installation](https://docs.veryfi.com/lens/mobile/headless/credit_cards/installation/) page shows the correct pod and the Full SPM URL `veryfi-lens-spm.git`. Do not use that SPM URL. Install the pod or embed `VeryfiLensHeadlessCreditCards.xcframework`.

Settings type: `VeryfiLensCreditCardsSettings`. It conforms to `VeryfiLensHeadlessSettings`. It is not `VeryfiLensSettings` and it is not `VeryfiLensCreditCardSolutionSettings`.

Credentials type: `VeryfiLensHeadlessCredentials`.

## Artifact and import

| | |
|--|--|
| Pod | `VeryfiLensHeadless-CreditCards` |
| Dedicated SPM | **No** |
| XCFramework | `VeryfiLensHeadlessCreditCards.xcframework` |
| Import | `import VeryfiLensHeadlessCreditCards` |

```swift
import VeryfiLensHeadlessCreditCards
import AVFoundation
```

`upload(images:)` and `upload(url:)` are not a credit-card path. `CreditCardUploader.init` returns nil, so `VeryfiLensHeadless.upload` fails the uploader check and reports `veryfiLensError` with `"No valid credentials"` even after a successful configure. Capture with `process(buffer:)`.

## Permissions

The host presents the camera, so the host’s capture session needs `NSCameraUsageDescription`.

This path does not pick from Photos or write a Lens gallery backup. Photo library usage strings are not required by the SDK call itself. Location is not a setting on `VeryfiLensCreditCardsSettings`.

## Settings

Public properties and defaults from `VeryfiLensCreditCardsSettings`:

| Property | Default |
|----------|---------|
| `documentType` | `.creditCard` (not a settable string list) |
| `detectCardNumber` | `true` |
| `detectCardHolderName` | `true` |
| `detectCardCVC` | `true` |
| `detectCardDate` | `true` |
| `marginTop` | `100` |
| `marginBottom` | `50` |
| `autoCaptureMode` | `.accuracy` |

`autoCaptureMode` is `VeryfiLensHeadlessAutoCaptureMode`: `.none`, `.speed`, `.normal`, `.accuracy`. Unknown raw strings in `init(with:)` fall through to `.normal`. The parameterless `init()` keeps `.accuracy`.

`frameCount`, `maxPhaseTries`, `maxTries`, and `maxCount` are derived from the mode. Do not assign them.

```swift
let settings = VeryfiLensCreditCardsSettings()
settings.detectCardNumber = true
settings.detectCardHolderName = true
settings.detectCardDate = true
settings.detectCardCVC = true
settings.autoCaptureMode = .accuracy
settings.marginTop = 80
settings.marginBottom = 30
```

Margins are in the units the detector uses. The values `80` and `30` are the in-repo headless sample, not the class defaults (`100` and `50`). Use the defaults unless the host’s frame needs the sample inset.

Passing `VeryfiLensReceiptSettings` into this binary fails the processor cast. The delegate gets `Wrong VeryfiLensHeadlessSettings instance is used. Make sure VeryfiLensHeadlessSettings instance is used`.

There is no `dataExtractionEngine` on this settings type. Extraction is on device. `CardProcessor.documentIsProcessed` posts document-ready with boolean presence flags (`card_number`, `card_dates`, `card_name`, `card_cvc`, `card_type`), `sdk` `lens-headless-credit-card`, and `data_extraction_engine` `mobile`. The PAN is not in that body. It is in the delegate `data`.

## Lifecycle and presentation

The host creates the camera. Lens does not present a view controller.

```swift
let credentials = VeryfiLensHeadlessCredentials(
    clientId: "<clientId>",
    username: "<username>",
    apiKey: "<apiKey>",
    url: "https://api.veryfi.com"
)
let settings = VeryfiLensCreditCardsSettings()

VeryfiLensHeadless.shared().delegate = self
VeryfiLensHeadless.shared().configure(with: credentials, settings: settings) { success in
    guard success else { return }
    VeryfiLensHeadless.shared().startProcessingBuffer()
}

func captureOutput(_ output: AVCaptureOutput,
                   didOutput sampleBuffer: CMSampleBuffer,
                   from connection: AVCaptureConnection) {
    VeryfiLensHeadless.shared().process(buffer: sampleBuffer)
}
```

Stop and close when the host leaves the screen:

```swift
VeryfiLensHeadless.shared().stopProcessingBuffer()
VeryfiLensHeadless.shared().close()
```

`reset()` clears detector state between cards. `updateSettings(_:)` replaces flags on the live processor. The sample turns off `detectCardNumber` after a number is already filled so the next frames look for the remaining fields. That pattern is host logic. The API is `VeryfiLensHeadless.shared().updateSettings(VeryfiLensCreditCardsSettings())`.

`setCameraSessionQueue(_:)` exists on `VeryfiLensHeadless`. The credit-card `CardProcessor.setCameraSessionQueue` body is empty. Calling it is harmless and does not wire the card detector. **Unconfirmed** whether a future card processor will use the queue.

`processWithBlock`, `crop`, and `rotate` are on the shared headless class. The card flow’s autocapture is `process(buffer:)`.

Configure with an empty credential field calls `completion(false)` and, once a delegate exists, `veryfiLensError` with message `invalid_credentials` and `data.empty_fields`.

## Callbacks

`VeryfiLensHeadlessDelegate` has the four required methods and no `onHelpButtonClicked`.

Autocapture updates and success use `VeryfiLensUpdateResponse`:

| Event | `status` | `msg` | `data` |
|-------|----------|-------|--------|
| Live update | `inprogress` | `autocapture` | `CreditCard.headelessJSON` |
| Finished read | `done` | `autocapture` | same dictionary |

`headelessJSON` keys:

| Key | Value |
|-----|--------|
| `card_number` | PAN string |
| `card_name` | Holder |
| `card_type` | Brand |
| `card_dates` | `[date, date2]` strings. Missing dates are `""` |
| `card_cvc` | CVC |
| `card_uuid` | Local UUID |
| `card_is_invalid` | `(!isValidLuhn).description` string, not a Bool |

These keys differ from the UI SDK’s `credit_card_number` / `credit_card_holder_name` dictionary.

`veryfiLensError` carries processor failures (`autoCaptureOnError` → `VeryfiLensErrorResponse`). The exact `msg` strings for blur or low confidence are **Unconfirmed** in this template. Handle the callback without assuming a closed list.

`veryfiLensClose` is part of the delegate. The card autocapture path shown above emits update and success, not close. Close is emitted if an uploader calls `documentUploaderDidStart`. The credit-card uploader is never created (`init` returns nil).

## Conflicts and do-not

- Do not `import VeryfiLens` or call `VeryfiLens.shared().showCamera`.
- Do not construct `VeryfiLensSettings` or `VeryfiLensCreditCardSolutionSettings` for `configure`.
- Do not call `upload(images:)` or `upload(url:)` on this product.
- Do not install `veryfi-lens-spm`.
- Do not log `card_number` or `card_cvc` in analytics.
- A wrong settings class is a hard failure string, not a silent fallback.

## Source

- [flavor-matrix.md](../flavor-matrix.md)
- [VeryfiLensHeadless.swift](../../../VeryfiLensHeadless/Public/VeryfiLensHeadless.swift)
- [VeryfiLensHeadlessSettings.swift](../../../VeryfiLensHeadless/Public/VeryfiLensHeadlessSettings.swift)
- [VeryfiEngineCredentials.swift](../../../VeryfiLensHeadless/Public/VeryfiEngineCredentials.swift)
- [VeryfiLensCreditCardsSettings.swift](../../../VeryfiLensHeadless/Headless%20Credit%20Cards/VeryfiLensCreditCardsSettings.swift)
- [CardProcessor.swift](../../../VeryfiLensHeadless/Headless%20Credit%20Cards/Image%20Processing/CardProcessor.swift)
- [CreditCardUploader.swift](../../../VeryfiLensHeadless/Headless%20Credit%20Cards/CreditCardUploader.swift) — `init` returns nil
- [CreditCard.swift](../../../VeryfiLensEngine/Shared/Models/CreditCard.swift) — `headelessJSON`
- [SPM.swift](../../../fastlane/swift/FastlaneSwiftRunner/SPM.swift) — headless credit-card repo commented out
- [Headless credit cards installation](https://docs.veryfi.com/lens/mobile/headless/credit_cards/installation/)
