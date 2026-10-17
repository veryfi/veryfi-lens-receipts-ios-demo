# Clarifications

Conservative defaults are already in the recipe. Items marked **Unconfirmed** stay unresolved. Do not invent a winner.

## Resolved, and already applied

- `documentTypes` is the capture list. One type works with the picker hidden. More than one type needs `showDocumentTypes` true so the user can switch.
- `backupDocsToGallery` copies every scan into Photos (SDK default true). `backupDocsToiCloud` copies every scan into iCloud (default false). Hosts that do not want that set both false.
- `multiplePagesCaptureIsOn` keeps every crop in one image. `multipleDocumentsIsOn` is the submit-preview question, with stitch on, about sending each image as its own package.
- `.none` with `uploadWithoutProcessingIsOn` false is a local package. True uploads and returns `bucket` and `package_path` without calling Process a Document.
- Any-document back prompt runs only for active type `any_document`, `anyDocumentBackIsOn` true, and `packageMaxScans` exactly 2. Checks, driver licenses, and insurance cards use their own back flags.
- Any-Documents (`any_document` plus `anyDocumentTemplate`) is the broad product. Nutrition facts, US passport, driver license, and prescription labels are shortcut flavors. Contact support for another template.

## Unconfirmed, shared

- Winner if `closeCameraOnSubmit` and `submitWithoutClose` are both true. Exact sequence after capture versus after submit.
- Which dashboard `lens_settings` keys merge when `ignoreRemoteSettings` is false.
- Whether `autoCaptureOtherIsOn` defaulting to true is intentional. The recipe sets it false anyway.
- Whether `packageMaxScans == 2` is also required for `driverLicenseBack*` and `insuranceCardBack*`. Runtime checks those flags, the matching type, and a single front scan. Those ID flags are not this recipe.
- Who should change `computeIsOn`, `gpuIsOn`, and `boostModeIsOn`, and the latency, cost, and thermal effects. Leave the defaults.
- When Collect Upfront appears for third-party apps, and how `categories` relates to `categoriesList`.
- Whether Demo `VeryfiLens*Settings` subclasses stay public but undocumented. Client code still uses `VeryfiLensSettings()` only.
- Whether Contacts and Calendar usage strings are required. Treat the legacy README list as stale until product confirms them.
- Whether `cameraProcessingMode` is ignored when `documentTypes` does not include `any_document`. Leave it unset on this flavor unless a note below says otherwise.
- Coupling of `defaultSelectedDocumentType` to analytics.

## Unconfirmed for this flavor

- Whether this receipts binary includes the field-detection model. Leave `documentFieldsToDetect` empty unless support confirms entitlement and the model.
- `defaultSelectedDocumentType` analytics coupling.
- Contacts and Calendar plist keys.
