# UI SDK no-UI calls vs Headless products

Two different products share the word "headless". Pick from the table. Do not mix calls across binaries.

| | UI SDK | Headless product |
|--|--------|------------------|
| What the host embeds | The Lens UI SDK flavor (Receipts, Checks, Remote Models, …) | A separate Headless binary: receipts or credit cards |
| Who owns the camera | Lens, unless the host only passes files it already has | The host |
| No-UI entry on that binary | iOS `VeryfiLens.uploadImages(paths:)` and `headlessUpload`. Android `VeryfiLens.uploadImages` | Headless `process` APIs on `VeryfiLensHeadless` |
| Delegate | `VeryfiLensDelegate` | iOS and Android both use `VeryfiLensHeadlessDelegate`. Callback shape stays in the platform skill |

## UI SDK — Lens presents UI

Camera, gallery, or files. iOS: `showCamera`, `showGallery`, `showDocumentBrowser`, SwiftUI covers. Android `VeryfiLens` has `showCamera()`, `showGallery()`, and `showDocumentBrowser()`. Parameter lists stay in the Android skill.

## UI SDK — host already has files

Still the **UI SDK**. Configure that SDK, then upload. There is no Headless binary in this path.

| Platform | Call | Confirmed |
|----------|------|-----------|
| iOS | `uploadImages(paths:)` for image or PDF paths. Share Extension sets `shareExtensionModeIsOn = true`. Main app leaves it false | iOS skill |
| iOS | `headlessUpload(images:)` (up to 4, document type `receipt`) or `headlessUpload(url:)` for in-memory images or one URL | iOS skill |
| Android | `VeryfiLens.uploadImages(paths:)` and `uploadImages(uris:)` | `VeryfiLens.kt` |
| Android | `headlessUpload` | **Unconfirmed.** No `headless*` method on the UI facade |
| Plugins | no-UI upload | **Unconfirmed** until the plugins skill names the method |

iOS `headlessUpload` is a method on the UI SDK. It is not `VeryfiLensHeadless`.

A Share Extension on iOS uses `uploadImages(paths:)`, not `headlessUpload`.

## Headless products — host owns the camera

Separate artifacts. iOS schemes and sources: Headless Receipts and Headless Credit Cards, type `VeryfiLensHeadless`, host calls `process(buffer:)` and may upload. Android modules: `veryfilens-headless-receipts` and `veryfilens-headless-creditcards`, type `VeryfiLensHeadless`, with `processFrame(frame:)` and `processGalleryImage(image:)`.

Do not call UI SDK `showCamera` on a Headless binary. Do not call Headless `process` on the UI SDK.

Headless settings are **Unconfirmed** as a drop-in of `VeryfiLensSettings`. iOS Headless uses its own settings type. Apply Headless recipes only from the platform skill.

## Which row to pick

| Host situation | Product |
|----------------|---------|
| Lens camera, gallery, or files UI | UI SDK |
| Share sheet or other short-lived process with file paths | UI SDK `uploadImages` |
| Images already in memory, iOS, no camera | UI SDK `headlessUpload` |
| Custom camera, detection and crop still from Lens utils | UI SDK `utils` after configure (iOS). Android equivalent is **Unconfirmed** here |
| Custom camera, receipts, no Lens UI | Headless receipts |
| Custom camera, credit cards, no Lens UI | Headless credit cards |

Credit card extraction on the UI SDK is the CreditCards flavor with on-device engine. That is still the UI SDK. Headless credit cards is the other binary.
