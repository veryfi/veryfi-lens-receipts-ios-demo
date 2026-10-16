# Callbacks

Implement all four required `VeryfiLensDelegate` methods. JSON keys are snake_case.

```swift
func veryfiLensClose(_ json: [String: Any]) {}
func veryfiLensError(_ json: [String: Any]) {}
func veryfiLensSuccess(_ json: [String: Any]) {}
func veryfiLensUpdate(_ json: [String: Any]) {}
// optional: onHelpButtonClicked(_:) when Help presents a host screen
```

## Common keys

| Key | Notes |
|-----|--------|
| `status` | `start`, `inprogress`, `update`, `done` (package success), `fail`, `exception`, `error`, `removed`, `close`, `autocapture`, `open` |
| `msg` | `img_original_path`, `invalid_credentials`, `image_is_screenshot`, `device_blocked`, and other machine messages |
| `package_id` | Upload or package id |
| `document_type` | Snake-case type string |
| `data` | Success: API payload and/or `file_hashes`, `detected_fields`. On `status` `fail`, the error is `error` rather than this success `data` |
| `img_original_paths` / `images` | Stitched PDF path updates |
| `queue_count`, `session_scan_count`, `framework-version` | On close |
| `blur_detected`, `document_detected` | Quality signals on some updates |
| `scan_session_counter` | When the session counter setting is on |

**`veryfiLensUpdate`** fires many times (thumbnail path, full-size path, upload progress). It is not finished extraction.

**`veryfiLensSuccess`** for this recipe is package processing finished. `status` is `"done"`. With `.cloudAPI`, `data` is the Process a Document payload. Field names inside that payload are the API response for this document type. Do not invent box numbers or JSON keys that this pack does not list.

**`veryfiLensError`** is upload, process, config, and crash-style failure. Empty credentials: `msg` `invalid_credentials`.

**`veryfiLensClose`** is the UI session ending, including cancel. It is not a substitute for success.

Cloud success uses `status` `"done"`. `document_type` is the package type (`receipt`, `invoice`, or `other`).

Update events carry thumbnail and original paths. `msg` `img_original_path` is the usual original-image message. Stitch updates can include `img_original_paths`, `images`, and `img_stitched_pdf_path`.

Close without success means the user left the camera, including cancel.

With `.none` and `uploadWithoutProcessingIsOn` false, and auto-delete false, success `data` includes `local_package_path`. With `.none` and `uploadWithoutProcessingIsOn` true, success `data` includes `bucket` and `package_path`. Those keys are the decoupling handoff, not the cloud extract. See [implementation.md](implementation.md#decoupled-capture).


If `sameFileUploadPreventionPolicy` is `.always`, success `data` may include `file_hashes`. Allow those files again with `VeryfiLens.shared().allowReuploadingFiles(withIdentifiers:)`. `.always` requires `.cloudAPI`.

If `autoDeleteLocalResourcesAfterProcessing` stays true, copy files during `update` or `success` before the next capture. Details: [implementation.md](implementation.md#local-resources-and-who-deletes-them).

`webhookIsOn` true means results can arrive asynchronously. This recipe leaves it false. If the host turns it on, do not treat the first callback as the only result.
