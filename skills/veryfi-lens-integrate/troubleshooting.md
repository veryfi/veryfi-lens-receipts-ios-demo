# Troubleshooting

Match the symptom, then apply the fix in the platform skill. Do not add flags that [conflicts.md](conflicts.md) tells you to remove.

| Symptom | Look at | Next step |
|---------|---------|-----------|
| Camera opens and never detects the document | Flavor vs document types | Confirm the binary includes those models. Narrow types or switch flavor |
| Configure completion is false, or `invalid_credentials` | Credentials | All four fields non-empty: client id, username, API key, URL. Set the delegate before configure so the error is not dropped (iOS) |
| Upload or present says the SDK is not configured | Call order | Present and `uploadImages` only after configure succeeds |
| Receipts requested with on-device engine | Engine | `mobile` is only `credit_card`, `code`, `barcode`. Use `api` or `none` |
| Card numbers appear in a cloud payload, or the host set `api` for cards | Engine | `mobile` on the CreditCards flavor or the Headless credit-cards product. Card data stays on device |
| Success JSON has no extracted fields | Engine `none`, or webhook | `none` does not call Process a Document. `webhookIsOn` can delay success; iOS default is false. Android webhook behavior **Unconfirmed** here |
| `local_package_path` missing on a local decoupled scan | Auto-delete | `autoDeleteLocalResourcesAfterProcessing` false, then read the path from success |
| Remote decoupled success has no `bucket` / `package_path` | Engine pair | `none` and `uploadWithoutProcessingIsOn` true |
| Image paths from `update` are gone on `success` | Auto-delete | Copy during `update`, or set auto-delete false and delete in the host |
| User Photos fills with document copies | `backupDocsToGallery` | Set false. Hide the More menu if users can turn the copy back on (iOS) |
| Dashboard changed flags the app set in code | `ignoreRemoteSettings` | Set true unless remote control is intended |
| `other` auto-captures after auto-capture was turned off | `autoCaptureOtherIsOn` | Set false. Default is true on iOS and Android |
| Check TIFF never appears | Flavor | Remote Models. The Checks-specific flavor omits that model because of size (iOS) |
| App size blamed on the zip/AAR/XCFramework | Measurement | Compare the installed app with the SDK linked and removed |
| Custom camera plus `uploadImages` feels like the wrong product | Product choice | Files the host already has: UI SDK upload. Live custom camera: Headless product. See [no-ui-vs-headless.md](no-ui-vs-headless.md) |
| iOS Share Extension is slow or dies mid-upload | `shareExtensionModeIsOn` | True in the extension, false in the main app. Use `uploadImages`, not `headlessUpload` |
| Android host calls `headlessUpload` | Method | That method is not on the Android UI facade. Use `uploadImages` or the Headless module |
| Two cameras or a camera that will not dismiss | Overlapping present calls | One presentation path |
| Users cannot switch receipt vs invoice | `showDocumentTypes` | On when more than one type is configured (iOS) |
| Blur or "no document" loop | Submit policy | iOS: `allowSubmitUndetectedDocsIsOn` is a legacy umbrella. Details in the iOS conflicts pack. Do not invent a second blur API |
| Local fraud or field detection stays off | Entitlement | Paid features. Flavor and flags are not enough |

If the row is marked **Unconfirmed** for this platform, stop and read the sibling skill. Do not add a workaround API.
