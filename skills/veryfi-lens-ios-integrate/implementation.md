# Implementation

Client contract: `configure` → present or headless process → `VeryfiLensDelegate`.

Public surface: `Veryfi-Lens/Public/` (`VeryfiLens`, `VeryfiLensSettings`, `VeryfiLensCredentials`, `VeryfiLensUtils`, SwiftUI wrappers).

## Credentials

```swift
let credentials = VeryfiLensCredentials(
    clientId: "<clientId>",
    username: "<username>",
    apiKey: "<apiKey>",
    url: "https://api.veryfi.com" // or the URL Veryfi gave the customer
)
```

Store secrets in the host’s secure config, not in git. All four fields must be non-empty for a normal configure. Empty fields → `veryfiLensError` with `msg`: `invalid_credentials` and `data.empty_fields`.

Set `delegate` before or immediately after `configure` so that error is not dropped (`reportPendingInvalidCredentialsIfNeeded`).

## Configure

```swift
let settings = VeryfiLensSettings()
// apply recipe from recipes.md

VeryfiLens.shared().delegate = self // retain this object

VeryfiLens.shared().configure(with: credentials, settings: settings) { success in
    DispatchQueue.main.async {
        guard success else { return }
        // present Lens
    }
}
```

`completion(true)` means validation produced a usable `UserInfo` (or cached previous access). Remote `lens_settings` merge into settings unless `ignoreRemoteSettings == true`.

Validation also returns account entitlements. Local fraud detection and local field detection are
extra paid features gated by that backend response. `fraudDetectionIsOn` and
`documentFieldsToDetect` only request entitled capabilities; settings cannot unlock them. Local
field detection additionally requires the Field Detection or Remote Models flavor.

If validation fails: `completion(false)`, `lensConfigurationFailedNotification`, and typically a no-access error path. `utils` before configure notifies `VeryfiLens is not configured`.

Reconfigure by calling `configure` again. Live tweaks: `VeryfiLens.shared().utils.update(settings:)` after a successful configure (does not re-run full validate).

`appVersion`: optional host app version string for analytics.

`isReactNative`: set true only in RN hosts.

`customHeaders`: extra HTTP headers on Lens API requests.

## Info.plist

| Key | When |
|-----|------|
| `NSCameraUsageDescription` | Camera flow |
| `NSPhotoLibraryUsageDescription` | Gallery pick |
| `NSPhotoLibraryAddUsageDescription` | `backupDocsToGallery` |
| `NSLocationWhenInUseUsageDescription` | `locationServicesIsOn` |
| `NSLocationAlwaysAndWhenInUseUsageDescription` | only if the host already uses always-location; not required by default |

Do **not** add Contacts/Calendar usage strings unless product confirms those Lens features are in the shipped flavor (legacy framework README lists them — Unconfirmed / likely stale).

iOS 13+ for UIKit Lens; SwiftUI helpers documented as iOS 15+.

## SDK binary size

Recommend the **Remote Models** flavor when the host cares about app size. A specific flavor embeds its models in the binary. Remote Models keeps that binary smaller and downloads most of the heavy resources after install, only for the features the settings turn on. Bank-check TIFF follows that split: the Checks-specific flavor does not support it yet because the TIFF model is large, and Remote Models does, via `retrieveCheckTiffIsOn`.

Measure the final build product, once with the Veryfi Lens SDK dependency and once without it. The distributed XCFramework size and the Android AAR size are not that number. Both artifacts are fat binaries that include every supported architecture and platform slice. The app build keeps the slice for the target device, and store delivery can shrink the download further. Flavor tables and the artifact-versus-app explanation: [SDK binary sizes](https://docs.veryfi.com/lens/mobile/settings/sdk_binary_sizes/).

## Present — UIKit

Call only when configured:

| Method | Role |
|--------|------|
| `showCamera(in:)` | Full Lens camera |
| `showGallery(in:)` | Photo library import |
| `showDocumentBrowser(in:)` | Standalone Files / iCloud Drive import; no camera and no camera source flags required |
| `lensVC()` | Embeddable camera `UIViewController` (host presents it) |
| `showCrop(in:image:completion:)` | Manual crop of an existing image |
| `closeCamera(in:)` | Dismiss camera flow |
| `headlessUpload(images:)` | Up to 4 images, no UI |
| `headlessUpload(url:)` | File URL, no UI |
| `uploadImages(paths:)` | Paths; share extension with `shareExtensionModeIsOn` |

`deviceBlockListIsOn` may close the flow with `msg` `device_blocked`.

### Files/browser entry points

The document browser can be opened from several independent places:

- **More menu:** `moreMenuIsOn = true` plus `browseIsOn = true` adds Import > Browse.
- **Camera top-right button:** `showBrowserButton = true` opens Files directly. It does not require `browseIsOn`.
- **Camera gallery control:** `galleryIsOn = true` plus `galleryButtonWithFilesIsOn = true` changes that control into a Photos-versus-Files menu. It does not require `browseIsOn`.
- **Standalone:** `showDocumentBrowser(in:)` (UIKit) or `.documentBrowser` (SwiftUI) presents Files/iCloud Drive without opening camera. It does not require any of those camera flags.

Use one or more camera entry points according to the host UX. `browseIsOn` is specifically the More-menu option; it is not a global Files-import permission switch.

## Present — SwiftUI

Configure and set delegate the same way. Prefer modifiers over wrapping `showCamera` in a representable.

```swift
.veryfiLensFullScreenCover(isPresented: $showLens, flow: .camera)
.veryfiLensSheet(isPresented: $showGallery, flow: .gallery)
.veryfiLensSheet(isPresented: $showFiles, flow: .documentBrowser)
```

Item-based: `@State var activeFlow: VeryfiLensFlow?` + `.veryfiLensFullScreenCover(item: $activeFlow)`.

Also: `VeryfiLensFlowView`, `VeryfiLens.shared().cameraView()`, `VeryfiLensCameraView` (full SDK, not Core). Session end posts `Notification.Name.veryfiLensDidClose`; built-in modifiers dismiss automatically.

Keep a `VeryfiLensDelegate` (NSObject bridge is fine). SwiftUI does not replace callbacks.

Do not present UIKit `showCamera` and a SwiftUI cover at the same time.

## Headless vs file paths

| Path | Use |
|------|-----|
| `uploadImages(paths:)` | Host already has image or PDF **paths**. No Lens UI. Share Extensions and other short-lived processes. Cloud extraction. |
| `headlessUpload(images:)` / `headlessUpload(url:)` | In-memory images (first 4) or one URL. No Lens UI. Document type is `receipt`. Extraction follows `dataExtractionEngine`. |
| `VeryfiLensHeadless` product | Host owns the camera; `process(buffer:)` plus optional upload; `VeryfiLensHeadlessDelegate` |

Custom UI with detection and crop uses `VeryfiLens.shared().utils` after configure. Do not construct `VeryfiLensUtils()`.

### `uploadImages(paths:)`

Call after `configure` returns true. The same `VeryfiLensDelegate` reports close, progress, success, and errors. `nil` reads `Documents/image.jpg`. Images are capped by `packageMaxScans` (clamped to 1...10). The document type is the first `documentTypes` entry, or `receipt`. This path always uses cloud extraction.

In a Share Extension, set `shareExtensionModeIsOn = true` before configure. Lens then skips thumbnails and posts the package zip directly, which fits a short-lived extension. Leave the flag false in the main app so `uploadImages` uploads the package to storage and then processes it.

Copy a shared attachment into the extension container when the original URL is not readable, and pass that local path. Load credentials from the app group; the extension does not have the host app's in-memory session.

```swift
let settings = VeryfiLensSettings()
settings.shareExtensionModeIsOn = true          // extension only
settings.documentTypes = ["receipt"]
settings.nonInteractiveBlurCheckIsOn = true     // optional: drop a blurred image
settings.allowSubmittingScreenshots = false     // optional: reject screenshot files

VeryfiLens.shared().delegate = self
VeryfiLens.shared().configure(with: credentials, settings: settings) { success in
    guard success else { return }
    VeryfiLens.shared().uploadImages(paths: [localPath])
}
```

A bad file is reported on `veryfiLensError` and skipped. `msg` can be `invalid_file`, `empty_file`, `invalid_pdf_file`, `image_too_small`, `empty_image`, `invalid_image`, or `blurred_image`. A screenshot rejection stops the call.

## Public functions

`VeryfiLens.shared()` is the entry point. Set `delegate` before `configure`. Read `credentials`, `settings`, and `utils` from that instance.

| `VeryfiLens` | Role |
|--------------|------|
| `configure(with:settings:completion:)` | Validate credentials and apply settings. Present or upload only after `true`. |
| `showCamera(in:)` / `showGallery(in:)` / `showDocumentBrowser(in:)` | Lens UI. One presentation at a time. |
| `showCrop(in:image:completion:)` | Manual crop of an image the host already has. |
| `lensVC()` | Embeddable camera controller. |
| `closeCamera(in:)` | Dismiss the camera flow. |
| `uploadImages(paths:)` | No UI. Image and PDF paths. Share Extension when `shareExtensionModeIsOn` is true. |
| `headlessUpload(images:)` / `headlessUpload(url:)` | No UI. In-memory images or one URL. Type `receipt`. |
| `allowReuploadingFiles(withIdentifiers:)` | Clears `.always` duplicate hashes from a success `file_hashes`. |
| `shareOCRFeedback()` | Shares the last code-scan logs. |

`utils` is available after a successful configure:

| `VeryfiLens.shared().utils` | Role |
|------------------------------|------|
| `update(settings:)` | Replace settings and the uploader configuration. Does not re-validate credentials. |
| `updateCameraInfoView(_:)` | Replace the camera banner. Does not accept nil. |
| `packagesInQueue()` | Package ids still queued. |
| `retryAllPackages()` / `retryPackage(with:metadata:imageSourceTag:)` | Retry queued uploads. |
| `discardAllPackages()` / `discardPackage(with:)` | Upload queue only. Does not delete retained files after success. |
| `clearLensStorage()` | Queue plus package folders, zips, PDFs, TIFFs, thumbnails, and shared originals. |
| `getImages(from:)` / `getMetaData(from:)` / `getPdfURL(from:)` / `getZipPath(for:)` | Read artifacts while they still exist. |
| `base64(for:)` | Base64 string for `Data`. |
| `version` | SDK version string. |
| `isLensCameraCircleChromeStyleActive` | Circular camera chrome on iOS 26 when the SDK major version is 3 or newer. |
| `debugNativeModelsInventory()` / `resetDownloadedNativeModelsStateForDebugging()` | Demo diagnostics for the Remote Models flavor. |

## Delegate

```swift
@objc protocol VeryfiLensDelegate: AnyObject {
    func veryfiLensClose(_ json: [String: Any])
    func veryfiLensError(_ json: [String: Any])
    func veryfiLensSuccess(_ json: [String: Any])
    func veryfiLensUpdate(_ json: [String: Any])
    @objc optional func onHelpButtonClicked(_ presentingViewController: UIViewController)
}
```

`onHelpButtonClicked` only if `showHelpButton == true` and `showDefaultScanningGuide == false`. If `showDefaultScanningGuide == true`, Lens shows its own guide and does not call the optional method.

### Help, custom screens, and camera banners

Help and `showInfoButton` share one camera control. Choose one tap behavior:

| Goal | Settings / API |
|------|----------------|
| Replay Lens's built-in guide | `showHelpButton = true`, `showDefaultScanningGuide = true` |
| Present a host view controller or sheet | `showHelpButton = true`, `showDefaultScanningGuide = false`, implement `onHelpButtonClicked(_:)` |
| Open a host UIKit view directly over the camera | `showHelpButton = false`, set `showInfoButton` to a `VeryfiInfoView` |
| Show an immediate top-of-camera banner | Set `cameraInfoView`; independent of the shared Help/Info control |

Do not set both `showHelpButton` and `showInfoButton` expecting two buttons. Help wins the shared control's tap path.

`showInfoButton` is also not purely cosmetic in the current runtime: a non-nil value makes the camera Files browser PDF-only and selects specialized retry cleanup/navigation. Use the delegate callback for a general-purpose custom help screen unless that specialized flow is intended.

Host-presented custom help:

```swift
settings.showHelpButton = true
settings.showDefaultScanningGuide = false
settings.helpButtonIconName = "questionmark.circle" // SF Symbol first, then host asset

func onHelpButtonClicked(_ presentingViewController: UIViewController) {
    let help = ClientHelpViewController()
    help.modalPresentationStyle = .pageSheet
    presentingViewController.present(help, animated: true)
}
```

The callback receives Lens's camera view controller specifically so the host can present from the currently visible controller.

For a custom view owned inside the camera, subclass `VeryfiInfoView`. Lens pins `showInfoButton` views to all camera edges; call inherited `close()` from a button or gesture:

```swift
final class ClientCameraInfoView: VeryfiInfoView {
    private let closeButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        closeButton.setTitle("Close", for: .normal)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        addSubview(closeButton)
        // Add normal UIKit constraints for the rest of the screen.
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @objc private func closeTapped() {
        close()
    }
}

settings.showHelpButton = false
settings.showInfoButton = ClientCameraInfoView()
```

`cameraInfoView` is a different placement of the same public base class. It appears immediately at the safe-area top with 16-point side insets, without waiting for a tap. Give the banner intrinsic content size or internal top/bottom constraints:

```swift
let banner = ClientCameraBannerView() // subclass of VeryfiInfoView
settings.cameraInfoView = banner
```

Replace the banner while Lens is already open:

```swift
VeryfiLens.shared().utils.updateCameraInfoView(ClientCameraBannerView())
```

Each update fades out the existing banner and installs the new one. A banner can dismiss itself with `close()`. The update API replaces with another view; it does not accept `nil`.

### Custom strings

`customLensStrings` is `[languageCode: [sourceKey: replacement]]`. Lens looks up `Locale.current.languageCode`. The host app must list those languages under Project or Target Info → Localizations, or `CFBundleLocalizations`.

The source key is the English string currently shown in Lens, copied exactly, including punctuation. Customers who do not know the key should use the public list: https://docs.veryfi.com/lens/mobile/settings/customizable_strings/

A few messages have no visible English default. Those use a `_veryfi_…` key from the “Unique keys” section of that page, such as `_veryfi_no_documents_in_image_message`.

Unlisted keys, and languages missing from the dictionary, keep Lens's own localization.

```swift
settings.customLensStrings = [
    "en": [
        "Try again": "Retry",
        "Submit": "Send",
        "_veryfi_no_documents_in_image_message": "No document was found in this photo."
    ],
    "es": [
        "Try again": "Reintentar",
        "Submit": "Enviar",
        "_veryfi_no_documents_in_image_message": "No se encontró un documento en esta foto."
    ],
    "fr": [
        "Try again": "Réessayer",
        "Submit": "Envoyer",
        "_veryfi_no_documents_in_image_message": "Aucun document n’a été trouvé sur cette photo."
    ]
]
```

Format placeholders such as `%d` and `%@` must stay in the replacement.

### Custom camera alert appearance

`alertBackgroundColor`, `alertBackgroundDarkColor`, `alertFontColor`, `alertFontDarkColor`, `alertButtonHeight`, `alertButtonCornerRadius`, `alertContentMargins`, and `alertContentSpacing` style Lens's custom camera alert. On iOS that alert is used for warning and error events: blocked device, denied camera access, denied Photos access, and a Lens configuration that could not be validated.

Those colors and sizes do not restyle the system alerts used for submit, blur, glare, no-document, and similar prompts. `alertSheetStyleIsOn` chooses an action sheet versus a regular system alert for those prompts. `swapAlertActions` reorders their buttons when the style is a regular alert. On iOS 26, system alerts stay regular alerts.

### Undetected-document and blur submit policy

`allowSubmitUndetectedDocsIsOn` predates the separate blur setting, so it remains a legacy umbrella:

- Undetected `true`, blurred `false` or `true`: users can continue from both no-document and blur warnings.
- Undetected `false`, blurred `true`: no detected rectangle is blocked, but a detected blurry document can continue.
- Undetected `false`, blurred `false`: both warnings require a retake.

The blur warning shows “I'm happy with it” when either flag is true. The no-document warning only uses `allowSubmitUndetectedDocsIsOn`.

### JSON shape (common keys)

| Key | Notes |
|-----|--------|
| `status` | `start`, `inprogress`, `update`, `done` (success), `fail`, `exception`, `error`, `removed`, `close`, `autocapture`, `open` |
| `msg` | Machine/human message (`img_original_path`, `invalid_credentials`, `image_is_screenshot`, `device_blocked`, …) |
| `package_id` | Upload/package id |
| `document_type` | Snake case type string |
| `data` | Success: API payload and/or `file_hashes`, `detected_fields`. Fail: not used this way |
| `error` | Present on `status` `fail` instead of `data` |
| `img_original_paths` / `images` | Stitched PDF path updates |
| `queue_count`, `session_scan_count`, `framework-version` | On `close` |
| `blur_detected`, `document_detected` | Quality signals on some updates |
| `scan_session_counter` | If session counter setting is on |

**`veryfiLensUpdate`:** fires many times — thumbnail path, full-size path, upload progress. Do not treat it as finished extraction.

**`veryfiLensSuccess`:** processing finished (`status` is `"done"`). Payload depends on `dataExtractionEngine` (plugin strings `api` / `mobile` / `none`) and `uploadWithoutProcessingIsOn`. `.inApp` only applies to `credit_card`, `code`, `barcode`, which always extract locally. Credit card data is never sent to the backend; the success payload is the on-device extraction. `.none` does not extract: local decoupling returns `local_package_path` when resources are retained; remote decoupling (`uploadWithoutProcessingIsOn = true`) returns `bucket` and `package_path`.

**`veryfiLensError`:** upload/process/config/crash-style failures.

**`veryfiLensClose`:** UI session ended (submit or cancel). Not a substitute for success.

If `sameFileUploadPreventionPolicy == .always`, success `data` may include `file_hashes`. To allow those files again: `VeryfiLens.shared().allowReuploadingFiles(withIdentifiers:)`.

If `autoDeleteLocalResourcesAfterProcessing == true` (SDK default), copy files off disk inside `update`/`success` immediately or set the flag false. See [Local resources](#local-resources-and-who-deletes-them).

## Local resources and who deletes them

**Local resources** (app Documents, not Photos/iCloud backup):

| Kind | Typical callback keys | On-disk (examples) |
|------|----------------------|--------------------|
| Package images | `img_original_path`, `img_paths`, `img_original_paths` | `Documents/veryfi_pckupl/…/imageN.jpg` |
| Retained zip | `data.local_package_path` (when auto-delete is off) | `Documents/veryfi_zips/…zip` |
| Thumbnails | `img_thumbnail_path` / `img_thumbnail_paths` | `Documents/thumbnails/…` |
| Stitched / imported PDF | `img_stitched_pdf_path` | `Documents/veryfi_pdfs/…` |
| Check TIFFs | `img_check_front_tiff_path`, `img_check_back_tiff_path` | `Documents/veryfi_check_tiffs/…` |
| Shared session copies | same original-path keys when auto-delete is on | `Documents/image.jpg`, `original.pdf` |

`VeryfiLens.shared().utils.getImages(from:)`, `getPdfURL(from:)`, and `getZipPath(for:)` only work while those files still exist.

**Why disable (`false`):** several packages in flight at once (batch, queue, parallel submits). Each package must keep its own files. With the default `true`, Lens deletes the package folder after that document finishes and later captures overwrite the shared `Documents/image.jpg` / `original.pdf` copies — a host that only ever processes **one** document sequentially can often ignore this and copy from `update` immediately.

**When `true`:** Lens deletes that package’s local resources after processing. Copy what you need in `update`/`success` before the next capture.

**When `false`:** the host owns deletion. Lens will not free that disk.

Wipe **all** Lens local files (and the upload queue):

```swift
VeryfiLens.shared().utils.clearLensStorage()
```

`discardAllPackages()` / `discardPackage(with:)` only clear the **upload queue**, not retained zips/PDFs/images after a successful process.

Delete **one** file from a callback path (`FileManager`; there is no Lens “delete this path” API):

```swift
func deleteLocalLensFile(at path: String?) {
    guard let path, FileManager.default.fileExists(atPath: path) else { return }
    try? FileManager.default.removeItem(atPath: path)
}

func veryfiLensSuccess(_ json: [String: Any]) {
    let data = json["data"] as? [String: Any]
    deleteLocalLensFile(at: data?["local_package_path"] as? String)
    deleteLocalLensFile(at: data?["img_original_path"] as? String)
    (data?["img_paths"] as? [String])?.forEach { deleteLocalLensFile(at: $0) }
    deleteLocalLensFile(at: data?["img_stitched_pdf_path"] as? String)
}
```

Collect paths from `veryfiLensUpdate` as well (`msg` `img_original_path`, `img_paths`, `img_stitched_pdf_path`, TIFF keys). Delete only after the host has copied or uploaded the file.

## Decoupled capture: customer-owned Process a Document

Both paths use `dataExtractionEngine = .none`. Lens does not call Process a Document. The customer's backend holds the Veryfi API key.

### Local package (`uploadWithoutProcessingIsOn = false`)

```swift
settings.dataExtractionEngine = .none
settings.uploadWithoutProcessingIsOn = false
settings.autoDeleteLocalResourcesAfterProcessing = false
```

```swift
func veryfiLensSuccess(_ json: [String: Any]) {
    guard let packageID = json["package_id"] as? String else { return }
    let data = json["data"] as? [String: Any]
    let callbackURL = (data?["local_package_path"] as? String).map { URL(fileURLWithPath: $0) }
    guard let zipURL = callbackURL
            ?? VeryfiLens.shared().utils.getZipPath(for: packageID) else {
        return
    }
    customerBackend.uploadLensPackage(at: zipURL, idempotencyKey: packageID)
}
```

`local_package_path` is the preferred handoff. `getZipPath(for:)` is a fallback. Copy or upload the file before `clearLensStorage`.

Backend example with `file_data`:

```http
POST https://api.veryfi.com/api/v8/partner/documents
CLIENT-ID: <client-id>
AUTHORIZATION: Bearer <scoped-api-key>
Idempotency-Key: <stable-key-for-this-package>
Content-Type: application/json

{
  "file_name": "lens-package.zip",
  "file_data": "<base64-encoded zip>",
  "document_type": "receipt"
}
```

ZIP must be enabled for the customer's Veryfi account.

### Remote package (`uploadWithoutProcessingIsOn = true`)

Lens uploads the package. Process a Document is not called. The customer processes later using the remote path values in success `data`: `bucket` and `package_path` (also `document_type`, `external_id` if set). Requires configured Lens credentials so the SDK can upload.

```swift
settings.dataExtractionEngine = .none
settings.uploadWithoutProcessingIsOn = true
```

```swift
func veryfiLensSuccess(_ json: [String: Any]) {
    guard let data = json["data"] as? [String: Any],
          let bucket = data["bucket"] as? String,
          let packagePath = data["package_path"] as? String else { return }
    customerBackend.processRemoteLensPackage(
        bucket: bucket,
        packagePath: packagePath,
        documentType: data["document_type"] as? String,
        externalId: data["external_id"] as? String,
        idempotencyKey: json["package_id"] as? String
    )
}
```

Backend example with remote package fields from [Process a Document](https://docs.veryfi.com/api/receipts-invoices/process-a-document/):

```http
POST https://api.veryfi.com/api/v8/partner/documents
CLIENT-ID: <client-id>
AUTHORIZATION: Bearer <scoped-api-key>
Idempotency-Key: <stable-key-for-this-package>
Content-Type: application/json

{
  "bucket": "<bucket from success data>",
  "package_path": "<package_path from success data>",
  "document_type": "receipt"
}
```

Set or omit `document_type` according to the captured type. Use a fresh idempotency key for each package and reuse it only when retrying that package. The endpoint currently documents a 20 MB file limit, 250-byte minimum, 15-page default limit, and 120-second load-balancer timeout; a retry without the same idempotency key can create and bill a duplicate. Prefer a scoped Bearer key; standard `apikey USERNAME:API_KEY` authorization is legacy.

## Package queue and local files

| API | Role |
|-----|------|
| `update(settings:)` | Replace settings + uploader configuration. Does not re-validate credentials. |
| `updateCameraInfoView(_:)` | Camera banner without full reconfigure |
| `packagesInQueue()` | Package ids in queue |
| `retryAllPackages()` / `retryPackage(with:metadata:imageSourceTag:)` | Retry queued uploads |
| `discardAllPackages()` / `discardPackage(with:)` | Upload **queue** only — not retained files after success |
| `clearLensStorage()` | Wipe **all** local Lens resources (packages, zips, PDFs, TIFFs, thumbs, shared originals) plus the queue |
| `getImages(from:)` / `getMetaData(from:)` / `getPdfURL(from:)` / `getZipPath(for:)` | Read artifacts while they still exist |
| `shareOCRFeedback()` on `VeryfiLens` | Share last code-scan logs |

## Notifications (optional)

- `lensIsConfiguredNotification` — configure succeeded
- `lensConfigurationFailedNotification` — validation failed
- `veryfiLensDidClose` — SwiftUI session dismiss
