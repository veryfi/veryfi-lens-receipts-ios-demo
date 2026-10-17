# Checklist

Track the block in [SKILL.md](SKILL.md). Each box is done only when the note below is true.

## Infer platform

[routing.md](routing.md) names one platform. Plugin shells are not classified as native iOS or Android. The next skill path is either a resolved file or an explicit "skill file missing".

## UI SDK vs Headless product

[no-ui-vs-headless.md](no-ui-vs-headless.md) picks one product. A no-UI call on the UI SDK stays on the UI SDK row.

## Intake

Guided: every unknown row in [intake.md](intake.md) was asked once. Quick: assumptions are written on the route card and nothing else was asked, except platform or product when inference failed.

## Flavor vs document types

The flavor family in [flavors.md](flavors.md) contains models for the document types. Settings cannot add models the binary omitted. Size-sensitive hosts are pointed at Remote Models. Bank-check TIFF is Remote Models, not the Checks-specific flavor (iOS baseline). Android artifact coordinates for each flavor are **Unconfirmed** here.

## One recipe

Exactly one recipe id. Overlays from the iOS pack (`BatchToMaxThenReview`, `AutoSubmit`, `FilesFirst`, and the rest) are optional and applied by the platform skill. This router does not stack two industry recipes.

## Core conflict check

[conflicts.md](conflicts.md) was applied to the chosen recipe. Residual risk is one line on the route card, or "none".

## Hand off

The sibling skill is open. Install, configure, presentation, and delegates come from that skill. This router does not emit a second copy of that code.

## Done when

The route card is filled and the platform skill's own checklist has started. Troubleshooting in [troubleshooting.md](troubleshooting.md) is only required when the user already has a failing integration.
