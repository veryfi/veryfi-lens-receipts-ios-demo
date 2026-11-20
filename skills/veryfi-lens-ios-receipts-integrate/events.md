# iOS analytics events and notifications

Use this when the host wants metrics, a funnel, or a log of what people do inside Lens. Subscribe on `NotificationCenter`. Do not invent event names. Remove the observer when the subscription ends.

## Analytics

`Analytics` posts `VeryfiLensAnalyticsEvent` on every event. The payload is `notification.object`, not `userInfo`.

```swift
private var analyticsObserver: NSObjectProtocol?

func startLensAnalytics() {
    let name = Notification.Name("VeryfiLensAnalyticsEvent")
    analyticsObserver = NotificationCenter.default.addObserver(
        forName: name,
        object: nil,
        queue: .main
    ) { note in
        guard let payload = note.object as? [String: Any] else { return }
        let event = payload["event"] as? String ?? ""
        let params = payload["params"] as? [String: Any]
        let time = payload["time"] as? Int
        // event: lens_session_start
        // params: ["source": "camera"]
        // time: unix seconds
    }
}

func stopLensAnalytics() {
    if let analyticsObserver {
        NotificationCenter.default.removeObserver(analyticsObserver)
        self.analyticsObserver = nil
    }
}
```

SwiftUI:

```swift
.onReceive(NotificationCenter.default.publisher(for: Notification.Name("VeryfiLensAnalyticsEvent"))) { note in
    let payload = note.object as? [String: Any]
}
```

Objective-C hosts use the same name with `NSNotificationCenter` and read `notification.object`.

## Other public notifications

| Name | When | Payload |
| --- | --- | --- |
| `Veryfi_LensNotification_Closed` (Swift: `Notification.Name.veryfiLensDidClose`) | A camera, gallery, or Files session ends. Posted on the main queue. The same JSON is passed to `veryfiLensClose` | `userInfo` |
| `com.veryfi.lens.native_model_download_did_update` (Swift: `.veryfiLensNativeModelDownloadDidUpdate`) | A native model download starts or finishes. Main queue. Remote Models flavor | `userInfo` keys `name`, `phase` (`started` or `finished`), and `error` when it failed. Constants: `VeryfiLensUtils.nativeModelNameKey`, `nativeModelPhaseKey`, `nativeModelPhaseStarted`, `nativeModelPhaseFinished`, `nativeModelErrorKey` |

Use `veryfiLensDidClose` to dismiss a SwiftUI cover. If the host already implements `veryfiLensClose`, do not also run the business logic from the notification.

Model downloads can be requested with `retryNativeModelDownloads()` and `forceDownloadNativeModels(_:completion:)`. Both no-op outside the Remote Models flavor.

The host sets the on-camera counter with `updateScanSessionCounter`. Do not observe the internal counter notification.

## Event catalog

Names come from Android `AnalyticsEvent` / `AnalyticsParams` and iOS `Analytics.Events` / `Analytics.Params`. [Events Tracking](https://docs.veryfi.com/lens/mobile/introduction/events_tracking/) is a subset. Where that page disagrees with the SDK, use this catalog.

Analytics is already on. No settings flag enables it. The host only subscribes. These are interaction metrics. Extraction results still arrive on the Lens delegate (`veryfiLensSuccess`, `veryfiLensClose`, `veryfiLensUpdate`, `veryfiLensError`).

Headless binaries emit session, upload, and result events (`lens_session_start`, `lens_headless_upload`, `lens_mobile_async_upload`, `lens_veryfi_lens_success`, `lens_veryfi_lens_error`, `package_upload_status`). Camera, gallery, submit, and settings events come from the UI SDK.

### Payload

No params:

```json
{ "event": "lens_veryfi_lens_success" }
```

With params. Every param value is a string:

```json
{ "event": "lens_session_start", "params": { "source": "camera", "version": "2.7.0.6" } }
```

iOS also sets top-level `time` to unix seconds. The Android broadcast does not. `package_upload_status` includes `username`. Do not forward that param to a third-party vendor unless the host already treats it as their account id.

On an older Android plugin build, `params` can be a one-key object whose key itself starts with `{`. That key is the JSON object string. Parse it. Current plugin builds decode it before delivery.

### Param keys

| Key | Meaning |
| --- | --- |
| `source` | `camera`, `gallery`, `browser`, `email`, `voice`, or a control name such as `capture_button` |
| `version` | SDK version. On Android `lens_session_start` this is the version name. On `package_upload_status` it is `lens-<name>(<code>)` |
| `type` | Screen, for example `submit`, `settings`, `gallery`, `crop` |
| `document_queue` | Queued document count |
| `action` | `try_again`, `continue`, `true`, or `false` |
| `document_type` | Selected type: `receipt`, `long_receipt`, `bill`, `other`, `credit_card`, `business_card`, `check`, `code`, `w2`, `w9`, `barcode`, `bank_statements`, or another `DocumentType` raw value |
| `status` | `detected`, `not_detected`, `true`, `false`, `granted`, `denied`, or an upload status |
| `error` | Error text |
| `index` | Image position |
| `value` | Free-form. Android `lens_veryfi_lens_error` puts the error JSON here |
| `images_count` | Image count |
| `package_id` | Package id |
| `username` | Partner username, on `package_upload_status` |
| `date` | `yyyy-MM-dd`, Pacific, on `package_upload_status` |
| `time` | `HH:mm:ss:SSS`, Pacific, on `package_upload_status`. This is not the iOS top-level unix `time` |
| `duration` | Duration |
| `progress` | iOS progress |
| `total_frames` | iOS stitching |
| `merged_frames` | iOS stitching |
| `selected_item` | iOS menu row |
| `has_value` | iOS upfront field |
| `rotation_numbner` | iOS rotate count. The SDK spells the key this way |
| `category`, `tag`, `customer`, `costcode`, `notes` | iOS upfront fields |

Not every event sends every key. Treat `params` as an optional string map.

### Session

| Event | When | Params |
| --- | --- | --- |
| `lens_session_start` | A Lens surface opened | `source`: `camera`, `gallery`, `browser`, `email`, or `voice`. Android also sends `version` |
| `lens_session_end` | Session ended | |

### Camera and screens

| Event | When | Params |
| --- | --- | --- |
| `lens_screen_show` | A screen opened | `type` |
| `lens_camera_show` | Camera shown | |
| `lens_camera_close` | Camera closed | |
| `lens_camera_close_confirmation` | Cancel-capture alert | |
| `lens_camera_menu_open` | More menu opened | |
| `lens_camera_menu_close` | More menu closed | |
| `lens_camera_document_type_selected` | Document type picked | `document_type` |
| `lens_camera_gallery_open` | Gallery button | `source` |
| `lens_camera_capture` | Shutter | `source` |
| `lens_camera_flash` | Flash button | `source` |
| `lens_camera_autocapture_start` | Auto-capture started | |
| `lens_camera_autocapture_end` | Auto-capture ended | `source` |
| `camera_back_cancel_scan_confirm` | Confirm cancel from the camera | |
| `camera_back_cancel_scan_ignore` | Dismiss cancel from the camera | |

### Voice

Dictate is not a partner feature. If it is on, the SDK can emit `lens_voice_open`, `lens_voice_close`, `lens_voice_start`, `lens_voice_end`, `lens_voice_mic_access_status`, `lens_voice_recognition_access_status`, `lens_voice_retry`, `lens_voice_submit`, and `lens_voice_fail`. Mic and speech status use `status` `granted` or `denied`.

### Stitching, prescription, upfront

`lens_stitching_start` and `lens_stitching_end`. iOS may add `total_frames`, `merged_frames`, `duration`, or `progress`.

`lens_prescription_start` and `lens_prescription_end`.

`lens_upfront_expand`, `lens_upfront_collapse`, `lens_upfront_show`, `lens_upfront_add_category`, `lens_upfront_add_tag`, `lens_upfront_add_customer`, `lens_upfront_add_costcode`, `lens_upfront_add_notes`. iOS may add `category`, `tag`, `customer`, `costcode`, `notes`, or `has_value`.

### Gallery and files

| Event | When | Params |
| --- | --- | --- |
| `lens_gallery_open` | Gallery opened | `type` |
| `lens_gallery_close` | Gallery closed | |
| `lens_gallery_import_image` | An image was imported | |
| `lens_browse_open` | Files browser opened | |
| `lens_browse_close` | Files browser closed | |
| `lens_browse_import_document` | A file was chosen | |

The docs names `lens_browser_open` and `lens_browser_close` are not emitted. The SDK emits `lens_browse_open` and `lens_browse_close`.

### Submit and quality alerts

| Event | When | Params |
| --- | --- | --- |
| `lens_submit_document_close` | Confirm screen closed | `source` |
| `lens_submit_package_submitted` | User confirmed submit | `source` |
| `lens_submit_package_submitted_images` | Images in that package | `images_count` |
| `lens_submit_document_detection_status` | Document found or not | `status`: `detected` or `not_detected` |
| `lens_submit_no_document_alert_show` | No-document alert | `action`: `try_again` or `continue` |
| `lens_submit_no_face_alert_show` | No-face alert | `action` |
| `lens_submit_blur_alert_show` | Blur alert | `action`, sometimes `status` |
| `lens_submit_glare_alert_show` | Glare alert | `action` |
| `lens_submit_lcd_alert_show` | Screen-photo alert | `action` |
| `lens_submit_screenshot_alert_show` | Screenshot alert | `action` |
| `lens_submit_check_side_alert_show` | Check side alert | `action` |
| `lens_submit_check_corners_alert_show` | Check corners alert | `action` |
| `lens_submit_document_corners_alert_show` | Document corners alert. iOS | `action` |
| `lens_submit_invalid_size_alert_show` | Check size alert | `action` |
| `lens_submit_share_logs` | Share logs | |
| `lens_submit_add_document` | Add another page | `document_queue`, `source` |
| `lens_submit_back_check` | Add the check back | |
| `lens_submit_back_any_document` | Add the document back | |
| `lens_submit_back_driver_license` | Add the license back | |
| `lens_submit_back_insurance_card` | Add the insurance-card back | |
| `lens_submit_back_prescription_label` | Add the prescription back | |
| `lens_submit_document_rotate` | Rotated | `index`. iOS may send `rotation_numbner` |
| `lens_submit_document_retake` | Retake | `index` |
| `lens_submit_document_scrolled` | Scrolled | |
| `lens_submit_document_remove` | Remove | `index`, `action` |
| `lens_submit_document_crop` | Crop | `index` |
| `submit_back_cancel_scan_confirm` | Confirm cancel on submit | |
| `submit_back_cancel_scan_ignore` | Dismiss cancel on submit | |

### Settings

`status` is the string `true` or `false` after the toggle.

| Event | Toggle |
| --- | --- |
| `lens_settings_doc_detection_changed` | Auto doc detection and crop |
| `lens_settings_blur_detection_changed` | Blur detection |
| `lens_settings_glare_detection_changed` | Glare detection |
| `lens_settings_autotorch_changed` | Auto torch |
| `lens_settings_autocapture_changed` | Hands-free auto capture |
| `lens_settings_backup_changed` | Backup scans to the photo gallery |
| `lens_settings_icloud_backup_changed` | iCloud backup. iOS |
| `lens_settings_superman_mode_changed` | Superman mode |
| `lens_settings_autoclose_changed` | Close the camera after submit |
| `lens_settings_upfront_category_changed` | Upfront category |
| `lens_settings_upfront_tags_changed` | Upfront tags |
| `lens_settings_upfront_projects_changed` | Upfront projects |
| `lens_settings_upfront_costcodes_changed` | Upfront cost codes |
| `lens_settings_upfront_notes_changed` | Upfront notes |
| `lens_settings_contact_support` | Contact support. Android's enum case is named external id; the emitted string is this one |

The public docs swap the glare, torch, and auto-capture sentences. Use this table.

`lens_menu_option_selected` fires when a More-menu row is chosen. iOS may send `selected_item`.

### Email, crop, results, upload

| Event | When | Params |
| --- | --- | --- |
| `lens_email_open` | Email screen opened | |
| `lens_email_close` | Email screen closed | |
| `lens_email_copy_email` | Address copied | |
| `lens_email_add_contact` | Contact added | |
| `lens_crop_show` | Crop screen | |
| `lens_crop_guide_show` | Crop guide | |
| `lens_crop_alert_show` | Confirm crop | `action`: `true` or `false` |
| `lens_veryfi_lens_success` | Processing succeeded | |
| `lens_veryfi_lens_error` | Processing failed | Android: `value` is the error JSON |
| `lens_notification_internal_error` | Internal error report | message fields |
| `lens_image_metadata` | Image metadata. Android | |
| `package_upload_status` | Upload outcome | `date`, `time`, `version`, `username`, `package_id`, `status` |
| `lens_headless_upload` | Headless upload | |
| `lens_mobile_async_upload` | Async mobile upload | |
| `lens_validation_request` | Validation request. iOS | |
| `lens_validation_response` | Validation response. iOS | |
| `lens_document_fields_detection_started` | Field detection started. iOS | |
| `lens_document_fields_ocr_completed` | Field OCR finished. iOS | |
| `lens_document_fields_extractor_completed` | Field extractor finished. iOS | |

### Do not subscribe to these

These are internal: `com.veryfi.lens_is_configured`, `com.veryfi.lens_configuration_failed`, `com.veryfi.camera_info_view_did_update`, `Veryfi_LensNotification_ScanSessionCounterDidChange`, `com.veryfi.remote_models_affecting_camera_session_ready`, `com.veryfi.remote_model_download_loading`, `com.veryfi.remote_model_did_become_available`.

Session-close data is the delegate. The scan counter the host sets is `updateScanSessionCounter`, not that internal notification.

Android `com.veryfi.lens.VeryfiLensAnalyticsEvent` is the deprecated broadcast. It is not permission-protected, and it keeps only the first param, lowercased, in `value`. Register `com.veryfi.lens.VeryfiLensSecureAnalyticsEvent` instead.
