# Checklist

Copy and track. A box is done only when the note under it is true.

```
Lens integrate:
- [ ] Artifact
- [ ] Plist
- [ ] Recipe
- [ ] Conflicts
- [ ] Configure and delegate
- [ ] One presentation
- [ ] Callbacks
- [ ] Unconfirmed items left unmarked as facts
```

## Artifact

[install.md](install.md) pod `VeryfiLens-Receipts`, import `VeryfiLens`, and XCFramework `VeryfiLens.xcframework`. Dedicated SPM repo `veryfi-lens-spm-receipts` only. Do not add `veryfi-lens-spm`.

## Plist

Camera usage string when the camera opens. Photo library string only if gallery import is on. Photo add string only if gallery backup is on. Location string only if `locationServicesIsOn` is on. Contacts and Calendar strings stay out.

## Recipe

[settings.md](settings.md) on a fresh `VeryfiLensSettings()`. Backups false. `dictateIsOn` false. `ignoreRemoteSettings` true. `moreMenuIsOn` false. No Demo subclass.

## Conflicts

[troubleshooting.md](troubleshooting.md#conflicts) was applied. Residual risk is one line, or “none”.

## Configure and delegate

Delegate is retained and set before `configure`. UI or `uploadImages` runs only inside `completion(true)`.

## Presentation

One of camera, gallery, standalone Files, embed `lensVC()`, or `uploadImages`. SwiftUI and `showCamera` are not both active. Files entry points match the table in [implementation.md](implementation.md#files-gallery-and-browser-entry-points).

## Callbacks

All four required methods exist. Success versus update versus close is handled as in [callbacks.md](callbacks.md). File copies respect auto-delete.

## Size

If the host asked about size, Remote Models was recommended and the measurement is the final app with and without the dependency. The XCFramework file size was not quoted as the install delta. [SDK binary sizes](https://docs.veryfi.com/lens/mobile/settings/sdk_binary_sizes/).

## Unconfirmed

Nothing in [clarifications.md](clarifications.md) was promised as settled.

## Output

Host sample includes the plist keys actually needed, `configure` plus delegate, one presentation path, the recipe mutations, and a one-line conflict note when residual risk remains.
