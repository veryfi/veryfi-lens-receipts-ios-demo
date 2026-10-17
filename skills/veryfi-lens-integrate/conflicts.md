# Core conflicts

Run after the recipe. The iOS pack has the full matrix: [../veryfi-lens-ios-integrate/conflicts.md](../veryfi-lens-ios-integrate/conflicts.md). This file is the set that should be checked on every platform. Flag **names** below were found on both iOS and Android `VeryfiLensSettings` unless a row says iOS-only. Runtime behavior on Android and plugins is owned by that skill; if it is silent, mark the symptom **Unconfirmed** rather than copying an iOS-only consequence.

Prefer unsetting the extra flag.

## Binary and engine

| Combination | What goes wrong | Fix |
|-------------|-----------------|-----|
| Flavor models do not include the document types | Weak or missing detection | Match the flavor. Narrow the types |
| `mobile` / in-app except on `credit_card`, `code`, or `barcode` | No on-device extract for receipts and other types | `api` for API extract, or `none` for capture-only |
| `credit_card` with `api` or `none` | Card data must stay on device | `mobile`. Card data is never sent to the backend |
| `uploadWithoutProcessingIsOn` true while engine is not `none` | Flag applies only with `none` | Set engine `none` for remote-package decoupling |
| `none` plus expecting extracted JSON fields | Lens does not call Process a Document | `api`, or `mobile` for the three on-device types |
| `none` local package (`uploadWithoutProcessingIsOn` false) with local auto-delete left true | No retained `local_package_path` | `autoDeleteLocalResourcesAfterProcessing` false |
| Field detection or fraud detection settings with no paid entitlement | Feature stays off | Entitlement plus a supporting flavor. Settings do not unlock it |
| Check TIFF on the Checks-specific flavor | TIFF model is not in that binary (size) | Remote Models. iOS flag `retrieveCheckTiffIsOn`. Android flag name **Unconfirmed** |
| Quoting XCFramework or AAR size as app size | Wrong install impact | Measure the final build with the SDK and without it |

## Configure, files, privacy

| Combination | What goes wrong | Fix |
|-------------|-----------------|-----|
| Present or `uploadImages` before configure succeeds | Not configured | Wait for configure success |
| Empty credentials | `invalid_credentials` on iOS | Non-empty client id, username, API key, and URL |
| `ignoreRemoteSettings` false | Dashboard can override the recipe | `true` unless remote control is the product |
| `backupDocsToGallery` left at default true | Every scan is copied to Photos | `false` unless the host wants those copies |
| `autoDeleteLocalResourcesAfterProcessing` true while the host reads files later, or several packages are in flight | Paths disappear or shared copies are overwritten | `false`, and the host deletes. Or copy immediately in `update` for one sequential document |
| iOS `backupDocsToiCloud` true | Copies land in the user's iCloud | Leave false. Android property **not found** on `VeryfiLensSettings` |
| iOS gallery backup without the photo-add usage string | Permission failure | Plist, or turn the backup off |
| iOS location flag without a location usage string | Permission failure | Plist, or leave location off |

## Capture UX

| Combination | What goes wrong | Fix |
|-------------|-----------------|-----|
| Auto-submit and batch-until-max together | Two policies for when the camera ends | Pick one |
| Close-on-submit and submit-without-close both true | Contradictory submit UX | Pick one. Winner if both are true is **Unconfirmed** |
| `showDocumentTypes` false with more than one document type | User cannot switch types | Turn the picker on, or use one type |
| `other` in the type list and `autoCaptureOtherIsOn` true while auto-capture is false | `other` still auto-captures | Set `autoCaptureOtherIsOn` false |
| `dictateIsOn` left at default true | iOS: obsolete, not partner available | Leave false |
| UI SDK `headlessUpload` / `uploadImages` described as the Headless SDK | Wrong binary and wrong camera owner | [no-ui-vs-headless.md](no-ui-vs-headless.md) |
| iOS Share Extension calling `uploadImages` with `shareExtensionModeIsOn` false | Extension does full storage and thumbnail work | Set the flag true in the extension only |
| Two Lens presentations at once (iOS `showCamera` plus a SwiftUI cover) | Double UI | One presentation |

## Any-Documents and checks

| Combination | What goes wrong | Fix |
|-------------|-----------------|-----|
| `anyDocumentType` set | Deprecated local regex OCR | Use `anyDocumentTemplate` |
| Nutrition facts, passport, driver license, or prescription labels treated as their own product | Wrong flavor story | Any-Documents shortcuts. Contact support for another template |
| `anyDocumentBackIsOn` when `packageMaxScans` is not 2, or on a check / license / insurance card | Back prompt does not run that way on iOS | iOS: exactly 2 and active type `any_document`. Other types use their own back flags. Android behavior **Unconfirmed** |
| `multiplePagesCaptureIsOn` used as the multi-package switch | Different features | Pages-in-one-image vs the submit-preview question (`multipleDocumentsIsOn` on iOS) |
