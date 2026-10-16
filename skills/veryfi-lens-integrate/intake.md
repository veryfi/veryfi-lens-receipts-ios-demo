# Common intake

Ask only on the **guided** path, and only for rows that are still unknown. The **quick** path fills the same rows with the assumptions below and prints them on the route card.

## Questions

| Topic | Options |
|-------|---------|
| Platform | iOS, Android, React Native, Flutter, Cordova, Capacitor, .NET MAUI, .NET Legacy. See [routing.md](routing.md) |
| Product | UI SDK, Headless receipts, Headless credit cards. See [no-ui-vs-headless.md](no-ui-vs-headless.md) |
| Documents | receipts/invoices, long receipts, checks, cards, IDs, insurance, W2/W9, bank statements, barcodes/codes, any_document, visual-only PDF |
| Industry | CGP/expense, banking, Any-Documents, CPG, visual/scan-to-PDF |
| Extract | Cloud (`api`), on-device (`mobile`: only `credit_card`, `code`, `barcode`), decoupled (`none`) |
| UX | Review then submit, auto-submit, batch until max then review |
| Sources | Camera, gallery, Files, files the host already has |
| Privacy | Photos backup, location, keep local files after process |
| Size | Default flavor vs Remote Models |

Dictate is not an intake choice. Leave `dictateIsOn` false. iOS: obsolete, not partner available. Android still defaults the flag to true and ships a Core dictation module; whether partners should enable it is **Unconfirmed**. Do not turn it on from this router.

## Quick-path assumptions

Use these only for blanks. A user sentence overrides the matching row.

| Blank | Assumption |
|-------|------------|
| Product | UI SDK |
| Presentation | Camera |
| Documents | `receipt` and `invoice` (and `other` only when the flavor includes it) |
| Industry | CGP / expense |
| Extract | Cloud (`api`) |
| UX | Review then submit |
| Sources | Camera and gallery |
| Privacy | No Photos backup, no location, delete local package files after a single sequential scan |
| Size | Remote Models when the user mentioned app size; otherwise the narrowest flavor for the documents |
| Recipe | `cgp-expense` |

State every assumption in the route card. Do not ask a follow-up on the quick path unless platform or product cannot be inferred.

## Guided path

Recommended when the user is choosing a product, flavor, privacy behavior, or decoupling, or when they ask to be walked through.

1. Ask the table once.
2. Map documents to a flavor and one recipe in [flavors.md](flavors.md).
3. Run [conflicts.md](conflicts.md).
4. Hand off. Do not ask the sibling skill's install questions from here.

## Hardening the recipe uses

These flags exist on iOS `VeryfiLensSettings` and Android `VeryfiLensSettings`. Defaults below were read from both. The router value is what a host recipe should set.

| Flag | SDK default | Router value | Why |
|------|-------------|--------------|-----|
| `ignoreRemoteSettings` | `false` | `true` | Dashboard `lens_settings` must not override the recipe unless the host asked |
| `backupDocsToGallery` | `true` | `false` | Default copies every scan into Photos |
| `autoCaptureOtherIsOn` | `true` | `false` | `other` still auto-captures when auto-capture is off |
| `moreMenuIsOn` | `true` | `false` | iOS: an open More menu stores user overrides. Android override behavior is **Unconfirmed**; still start closed |
| `moreSettingsMenuIsOn` | `true` | `false` | Hides More > Settings |
| `showNoDocumentDetectedWarning` | `true` | `false` | Usual choice: skip the no-document alert |
| `dictateIsOn` | `true` | `false` | See intake note |
| `uploadWithoutProcessingIsOn` | `false` | `false` except recipe `decoupled-remote-package` | Only applies with engine `none` |

iOS also sets `backupDocsToiCloud = false`. That property was not found on Android `VeryfiLensSettings`. Treat iCloud backup as iOS-only until the Android skill adds it.

Plugin settings are a dictionary of these names. The plugins skill confirms encoding. Do not invent extra keys.

If the host reads files after callbacks, or keeps several packages in flight, set `autoDeleteLocalResourcesAfterProcessing = false` (default `true` on iOS and Android). The host then owns deletion. A single sequential document may keep `true` and copy during `update`.
