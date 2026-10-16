# Clarifications (internal + public docs)

Answer these so this skill, header comments on `VeryfiLensSettings`, and Docusaurus stay aligned. Until answered, the skill uses **conservative** defaults and marks items **Unconfirmed**.

Status: **Open**. Update this file when product/engineering replies; then refresh catalog/recipes.

## 1. `showDocumentTypes` vs `documentTypes`

**Resolved.** `documentTypes` is the capture list. One type works with the picker hidden. More than one type needs `showDocumentTypes = true` so the user can switch between them on the camera. The picker does not enable the types by itself.

## 2. Close / submit sequence

Flags: `afterScanCloseCameraIsOn` (shows the More menu “Close camera after submit” row; it is not an auto-capture switch), `closeCameraOnSubmit` (the value that row overrides while `moreMenuIsOn` is true), `submitWithoutClose`, `clearSessionOnBack`, `autoSubmitDocumentOnCapture`, `batchUploadOnCamera` (Superman mode seed).

**Ask:** Exact sequence after capture vs after submit. Winner if close-on-submit and submit-without-close are both true.

## 3. `.none` vs `uploadWithoutProcessingIsOn` — resolved from runtime

Both are decoupling (`dataExtractionEngine = .none`; no Process a Document from Lens):

- `uploadWithoutProcessingIsOn = false`: local package. With `autoDeleteLocalResourcesAfterProcessing = false`, success `data` includes `local_package_path`.
- `uploadWithoutProcessingIsOn = true`: Lens uploads; success `data` keeps remote `bucket` and `package_path` for the customer to process.

## 4. Remote `lens_settings`

Merge in `VeryfiLensUtils` unless `ignoreRemoteSettings`. Default false. Demo subclasses set true.

**Ask:** Which keys merge. Should third-party clients default `ignoreRemoteSettings = true`? Document the override as a support footgun.

## 5. `backupDocsToGallery` and `backupDocsToiCloud`

**Resolved.** Both copy every scan into the user's own storage: Photos for gallery (SDK default true) and iCloud (default false). Hosts that do not want users filled with document copies should set both false. The More menu can turn them back on while it is visible. Do not change the stored gallery default in this pass; existing apps already ship with true.

## 6. `autoCaptureOtherIsOn` default `true`

Independent of `autoCaptureIsOn`.

**Ask:** Intentional? Docs should warn that turning auto-capture off does not disable `other`.

## 7. Back-of-document vs `packageMaxScans`

**Resolved for any document.** The back prompt runs only when the active type is `any_document`, `anyDocumentBackIsOn` is true, and `packageMaxScans` is exactly 2. `anyDocumentBackIsRequired` forces that back. Checks, driver licenses, and insurance cards use their own back flags and do not use `anyDocumentBack*`.

**Still open:** whether `packageMaxScans == 2` is also required for `driverLicenseBack*` and `insuranceCardBack*`. Runtime only checks those flags, the matching document type, and a single front scan.

## 8. `multipleDocumentsIsOn` vs `multiplePagesCaptureIsOn`

**Resolved.** `multiplePagesCaptureIsOn` recognizes every cropped page in one image (side-by-side receipts become two documents; false keeps the larger crop). `multipleDocumentsIsOn` enables the submit-preview choice when stitch is on and more than one image is ready: choosing “no, not the same transaction” sends each image as its own package. Related setting `singleScanPackages = true` bypasses that alert and forces every image into its own package.

## 9. `computeIsOn` / `gpuIsOn` / `boostModeIsOn`

Defaults true / true / false. Uploader configuration includes compute and boost.

**Ask:** Client-safe defaults. Who should change them (AM vs app)? Side effects on latency, cost, thermal.

## 10. `categories` vs `categoriesList` / Collect Upfront

`categories`: `[String]`. `categoriesList`: `[VeryfiLensCategory]`. Also `coreTags`, `customers`, `costCodes`. `collectNotesIsOn`: notes-only sheet; ignored by Veryfi-owned app (full sheet).

**Ask:** When Collect Upfront appears for third-party apps. Relationship between string `categories` and `categoriesList`.

## 11. Public `VeryfiLens*Settings` subclasses

Skill: **do not recommend**; configure `VeryfiLensSettings()` + recipes. Subclasses are Demo-colored, set `ignoreRemoteSettings`, and some override `json` incompletely.

**Ask:** Confirm they stay public but undocumented for clients, or later mark internal (breaking if anyone used them). Skill assumes no client should use them.

## 12. Info.plist

[Veryfi-Lens/Resources/README.md](../../Veryfi-Lens/Resources/README.md) lists Camera, Location, Photo Library, **Contacts**, **Calendar**, and mentions “Wombat”.

**Ask:** Required keys for current UI SDK flavors. Confirm Contacts/Calendar are stale. Replacement install path (SPM/CocoaPods) for Docusaurus.

## Extra doc bugs found while cataloging

- `documentTypes` supported-values list is incomplete (`check`, cards, IDs, etc. missing).
- `cameraProcessingMode` “only any_document” vs `DocumentType.isCard` for passport/DL/insurance/business card.

## Suggested homes (skill already in this repo)

| Place | Why |
|-------|-----|
| `.cursor/skills/veryfi-lens-ios-integrate/` (this pack) | Agents in the Lens repo |
| `~/.cursor/skills/veryfi-lens-ios-integrate/` | Engineer laptop; copy into client machines. Never `~/.cursor/skills-cursor/` |
| Client repo `.cursor/skills/` | Customer engineers; zip this folder |
| Public Docusaurus | Same group IDs + recipes for humans; paste SKILL.md as “Cursor pack” |
| Later: internal factory in Demo | Same IDs as [settings-groups.md](settings-groups.md); still `VeryfiLensSettings` |
