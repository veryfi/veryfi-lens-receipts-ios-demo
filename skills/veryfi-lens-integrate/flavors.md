# Flavors and recipe metadata

Recipe ids match the iOS pack [../veryfi-lens-ios-integrate/recipes.md](../veryfi-lens-ios-integrate/recipes.md). Property assignments and group ids live there for iOS. Android and plugins apply the same id with their own syntax. Do not paste iOS-only types (Swift enums, `UIDevice`, Info.plist) into other platforms.

Client code uses `VeryfiLensSettings`. Subclasses such as `VeryfiLensReceiptsSettings` are not a client contract on iOS. Android and plugin preset subclasses are **Unconfirmed**; do not introduce them from this router.

## Flavor families

The binary must include models for the document types. A receipts binary does not gain check detection from settings.

| Family | Typical document types | Notes |
|--------|------------------------|-------|
| Full / Receipts | `receipt`, `invoice`, `other` | Add `long_receipt` only when that flavor includes it |
| Long receipts | `long_receipt` | Stitch on |
| Checks | `check` | Capture. Bank-check TIFF is not in the Checks-specific flavor (model size). iOS: Remote Models + `retrieveCheckTiffIsOn` |
| Remote Models | The types the host enables | Recommended when size matters. Heavy models download after install. iOS supports bank-check TIFF here |
| CreditCards | `credit_card` | On-device only. Card data is never sent to the backend |
| BusinessCards | `business_card` | |
| OCR / Code | `code` | On-device |
| Barcodes | `barcode` | On-device |
| W2 / W9 / BankStatements | `w2`, `w9`, `bank_statement` | One type per binary unless the flavor is Full or Remote Models |
| Any-Documents | `any_document` + template | Template list is not closed. Contact support for another template |
| Any-Documents shortcuts | Nutrition facts, US passport, driver license, prescription labels | Same solution, narrower binary. Not separate products |
| Field Detection | receipts + field list | Paid. Account entitlement plus Field Detection or Remote Models flavor. The setting does not unlock it |
| Lite / Core | stripped | Do not assume full camera + extract (iOS skill). Android `veryfilens-core` is email and dictation. iOS Lite/Core beyond "stripped" is **Unconfirmed** here. Partner dictate stays off |
| Headless Receipts / Credit Cards | receipts or credit cards | Separate products. See [no-ui-vs-headless.md](no-ui-vs-headless.md) |

Android flavors are Gradle product flavors (Android `AI_CONTEXT.md`): lens full, receipts, long receipts, checks, credit cards, business cards, OCR, barcodes, W2, W9, bank statements, any docs, prescription labels, field detection, remote models, identity verification, lite, and the two Headless modules. Maven coordinates per flavor are **Unconfirmed** in this router. The public Android quick start shows `com.veryfi.lens:veryfi-lens-sdk` for the receipts walkthrough. Do not invent other artifact ids.

Measure installed size on the final app build with the SDK linked and with it removed. XCFramework and AAR files are fat artifacts. https://docs.veryfi.com/lens/mobile/settings/sdk_binary_sizes/

If the flavor is unknown, say so and keep document types to the narrowest match.

## Recipe ids

Apply base hardening from [intake.md](intake.md), then one row.

| Id | Documents | Engine | Flavor | UX |
|----|-----------|--------|--------|----|
| `cgp-expense` | `receipt`, `invoice`, `other` | `api` | Receipts or Full | Review then submit. Optional stitch. Field detection only with entitlement |
| `banking-checks` | `check` | `api` | Checks, or Remote Models when TIFF or size matters | Review then submit. Front and back. Stitch off |
| `any-documents` | `any_document` | `api` | Any-Documents or a shortcut flavor | Camera typical. Set `anyDocumentTemplate`. Do not set deprecated `anyDocumentType` |
| `decoupled-capture` | host types | `none`, `uploadWithoutProcessingIsOn` false | Matching flavor | Local zip. Keep local files so success can return `local_package_path` |
| `decoupled-remote-package` | host types | `none`, `uploadWithoutProcessingIsOn` true | Matching flavor | Lens uploads. Host later processes with success `bucket` and `package_path` |
| `visual-scan-to-pdf` | `receipt` as the detection model | `none`, upload-without-processing false | Receipts or Full | Local PDF. Not the remote-package recipe |
| `cpg-barcode` | `barcode` | `mobile` | Barcodes | Camera, auto shutter |
| `cpg-code` | `code` | `mobile` | OCR / Code | Camera. Regex comes from the customer, not a sample guess |
| `credit-cards` | `credit_card` | `mobile` | CreditCards or Headless credit cards | On device. Never cloud and never `none` |
| `tax-statements` | `w2` or `w9` or `bank_statement` | `api` | Matching flavor | Single type. Stitch off for a single-page form |
| `long-receipts` | `long_receipt` | `api` | Long receipts or Full / Remote Models | Stitch on |

`decoupled-remote-package` is an overlay on `decoupled-capture` in the iOS pack. This router still treats it as its own chosen id so the route card has one engine story.

## Document type strings

iOS accepts these snake_case strings (unknown becomes `other`): `long_receipt`, `receipt`, `invoice`, `check`, `credit_card`, `business_card`, `other`, `dictation`, `code`, `w2`, `w9`, `barcode`, `bank_statement`, `insurance_card`, `passport`, `driver_license`, `nutrition_fact`, `shipping_label`, `any_document`, `bank_letter_and_check`, `prescription_label`.

Android settings use a `DocumentType` enum whose JSON values are the same family. The full Android enum list is **Unconfirmed** in this router. Use the platform skill's enum, not a guessed case name. Public Android samples use `DocumentType.RECEIPT`.

More than one document type needs the camera type picker (`showDocumentTypes` on iOS). One type can hide it.
