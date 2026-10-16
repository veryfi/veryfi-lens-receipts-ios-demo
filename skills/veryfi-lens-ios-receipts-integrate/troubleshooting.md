# Troubleshooting

Match the symptom, then change the fewest flags. Prefer unsetting an extra flag over adding another one.

## Build and install

| Symptom | Cause | Fix |
|---------|-------|-----|
| Detection never finds the document | XCFramework flavor does not contain those models | Stay on this flavor’s document types. Settings cannot add models the binary omitted |
| App size quoted from the XCFramework file | Fat binary includes every architecture slice | Measure the final app with the SDK linked and with it removed. [SDK binary sizes](https://docs.veryfi.com/lens/mobile/settings/sdk_binary_sizes/) |
| Full package installed | `veryfi-lens-spm.git` or pod `VeryfiLens` | Use the pod, SPM repo, and XCFramework in [install.md](install.md) |
| Contacts or Calendar prompt | Legacy README keys were copied | Leave those usage strings out unless product confirms the feature. **Unconfirmed** / likely stale |

## Configure and launch

| Symptom | Cause | Fix |
|---------|-------|-----|
| `completion(false)` or `invalid_credentials` | Empty client id, username, API key, or URL | Fill all four. Set the delegate before `configure` |
| Present or upload says the SDK is not configured | Called before `completion(true)` | Wait for configure |
| Settings in code are ignored | `ignoreRemoteSettings` false, or More menu stored overrides | Set `ignoreRemoteSettings` true. Set `moreMenuIsOn` false |
| `device_blocked` | `deviceBlockListIsOn` and the server blocklist | Expected when that flag is on. It needs network and credentials |
| Two cameras, or a camera that will not dismiss | `showCamera` and a SwiftUI cover together | One presentation path |

## Capture and privacy

| Symptom | Cause | Fix |
|---------|-------|-----|
| Photos fills with document copies | `backupDocsToGallery` left at default true, or the user toggled it | Set false. Keep the More menu off |
| iCloud fills with copies | `backupDocsToiCloud` true, or the More iCloud row | Leave false. Hide the row with `showiCloudBackupOption` false or hide the menu |
| `other` auto-captures after auto-capture was turned off | `autoCaptureOtherIsOn` default true | Set false |
| No Browse row | `browseIsOn` true while `moreMenuIsOn` is false | Turn the More menu on, or use `showBrowserButton`, the gallery Photos/Files menu, or `showDocumentBrowser(in:)` |
| Blur loop | Undetected and blurred submit flags both false, in poor light | Torch, `tryAgainLightIsOn`, a higher threshold, or `allowSubmitBlurredDocsIsOn` true. Undetected true is a legacy umbrella that also allows blur |
| Glare blocks capture | `glareDetectionIsOn` | Leave it false unless the host asked for the current detector |
| Import was not cropped | Auto-crop is best effort | Needs `autoDocDetectionAndCropIsOn` plus the gallery or browser auto-crop flag. Screenshots, digital copies, and original-file PDFs can stay uncropped |
| Users cannot switch types | More than one `documentTypes` entry and `showDocumentTypes` false | Turn the picker on, or ship a single type |
| Help and info look like one button | They share one control | Pick Help or `showInfoButton`. Use `cameraInfoView` for a banner |

## Upload and callbacks

| Symptom | Cause | Fix |
|---------|-------|-----|
| Image paths from `update` are gone later | `autoDeleteLocalResourcesAfterProcessing` true | Copy during `update`, or set false and delete in the host |
| Several packages overwrite `Documents/image.jpg` | Auto-delete true with more than one package in flight | Set `autoDeleteLocalResourcesAfterProcessing` false |
| Success has no extracted fields | Engine `.none`, or `webhookIsOn` | `.none` does not call Process a Document. Webhooks can delay success. This recipe’s engine is documented in [settings.md](settings.md) |
| `local_package_path` missing | Local decoupling with auto-delete still true | Set `autoDeleteLocalResourcesAfterProcessing` false |
| Remote decoupling has no `bucket` or `package_path` | `uploadWithoutProcessingIsOn` without `.none` | Set both: engine `.none` and the flag true |
| Share Extension is slow or dies | `shareExtensionModeIsOn` false inside the extension | Set true only in the extension. Use `uploadImages`, not `headlessUpload` |
| `image_is_screenshot` | `allowSubmittingScreenshots` false | Expected for imported images the detector classifies as screenshots. `enableScreenshots` is the device screenshot switch and is a different flag |
| Duplicate uploads still go through | `.always` without `.cloudAPI` | Use `.session`, or cloud extraction, then `allowReuploadingFiles` when a resubmit is required |
| Local fraud or field detection stays off | Entitlement or flavor | Paid and backend-gated. Field detection also needs Field Detection or Remote Models |
| Check TIFF never appears | Checks-specific binary, or the flag is off | Remote Models and `retrieveCheckTiffIsOn`. This is not a settings-only fix on the Checks flavor |


## Conflicts

| Combination | What happens | Fix |
|-------------|--------------|-----|
| Flavor binary and `documentTypes` disagree | Missing models, weak or no detection | Keep this flavor’s types |
| `.inApp` on a type other than `credit_card`, `code`, or `barcode` | No on-device extract | `.cloudAPI` for API extract, or `.none` for capture-only |
| `credit_card` with `.cloudAPI` or `.none` | Card data must stay on device | Use the credit-card flavor and `.inApp`. Do not send PAN to the backend |
| `uploadImages` or UI before configure succeeds | Not configured | Wait for `completion(true)` |
| Overlapping `showCamera` and a SwiftUI cover | Double presentation | One path |
| `autoDeleteLocalResourcesAfterProcessing` true and the host reads files later | Empty or overwritten paths | Set false, or copy inside `update` |
| `backupDocsToGallery` true without the Photo Add usage string | Permission failure | Add the plist key or set the flag false |
| `locationServicesIsOn` without a location usage string | Permission failure | Plist, or leave the flag false |
| `autoSubmitDocumentOnCapture` and `batchUploadOnCamera` both true | Two “when do we leave the camera” policies | Pick one |
| `closeCameraOnSubmit` and `submitWithoutClose` both true | Contradictory submit UX | Pick one. The winner is **Unconfirmed** |
| `showDocumentTypes` false with more than one type | User cannot switch types | Turn the picker on, or use one type |
| `stitchIsOn` and `singleScanPackages` and `returnStitchedPDF` together | Package versus one-PDF semantics | Pick stitch-to-PDF or separate packages |
| `multiplePagesCaptureIsOn` used as the separate-packages switch | Side-by-side pages stay one crop, or the same-transaction alert never appears | Pages-in-one-image is `multiplePagesCaptureIsOn`. Separate packages are `multipleDocumentsIsOn` with stitch |
| `ignoreRemoteSettings` false | Dashboard overrides the recipe | Set true unless remote control is the product |
| `moreMenuIsOn` true | Users persist backup, torch, auto-capture, Superman, and close-after-submit | Set false unless that menu is wanted |
| `browseIsOn` true, `moreMenuIsOn` false, expecting a Browse row | No row | Another Files entry point, or turn the menu on |
| `showHelpButton` and `showInfoButton` both set | One control; Help wins | Pick one. Banner is `cameraInfoView` |
| `allowSubmittingScreenshots` and `enableScreenshots` treated as one switch | Imported screenshots still submit, or the camera UI stays capturable | They are independent |
| `fraudDetectionIsOn` or `documentFieldsToDetect` without entitlement | Feature stays off | Account and backend must enable the paid feature. Field detection also needs its flavor |
| `retrieveCheckTiffIsOn` on the Checks-specific flavor | No TIFF | Remote Models |
| `anyDocumentType` set | Deprecated local regex OCR | Leave empty. Templates use `anyDocumentTemplate` on Any-Documents |
| `useLegacyModels` set false | Debug-only; the SDK currently forces true | Leave the default |
| `dictateIsOn` true | Obsolete voice control | Leave false |
| Share Extension `uploadImages` with `shareExtensionModeIsOn` false | Extension does the full storage upload | Set the flag true in the extension only |

### This flavor

- Do not install `veryfi-lens-spm` and expect the receipts-only binary.
- Do not use `VeryfiLensReceiptsSettings` or `VeryfiLensReceiptSettings` with `VeryfiLens.shared()`.
- Do not set `.inApp`, `ocrRegex`, check flags, or `cameraProcessingMode`.
- Do not set `autoCaptureOtherIsOn` true while `autoCaptureIsOn` is false and `other` is in the list.
- `showDocumentTypes` stays true for this three-type list.
- Do not set `long_receipt` on this binary.
