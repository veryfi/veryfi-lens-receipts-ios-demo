---
name: veryfi-lens-integrate
description: >-
  Routes a Veryfi Lens host integration to the iOS, Android, or plugins skill.
  Infers the platform from the project, separates UI SDK uploadImages and iOS
  headlessUpload from Headless products, and runs a quick or guided intake
  (flavor, recipe, conflicts, troubleshooting) before handoff. Use when adding
  Veryfi Lens, choosing a flavor or recipe, or when the platform is not yet known.
---

# Veryfi Lens integration router

Pick the host platform, the product, and one recipe. Then hand off. Do not invent SDK APIs. When a fact is missing from the iOS baseline or the sibling skill, mark it **Unconfirmed** and leave it out of host code.

The settings baseline is the iOS pack: [../veryfi-lens-ios-integrate/SKILL.md](../veryfi-lens-ios-integrate/SKILL.md). This router does not replace it.

**Guided** is the recommended path for a new integration. **Quick** is for a first scan when the platform is already obvious.

## Checklist

Copy and track:

```
Lens route:
- [ ] Infer platform
- [ ] UI SDK vs Headless product
- [ ] Intake (quick assumptions or guided answers)
- [ ] Flavor vs document types
- [ ] One recipe
- [ ] Core conflict check
- [ ] Hand off to the sibling skill
```

Read one level deep:

- [routing.md](routing.md) — source inference and where to hand off
- [no-ui-vs-headless.md](no-ui-vs-headless.md) — UI SDK file upload vs Headless products
- [intake.md](intake.md) — shared questions and the quick-path assumptions
- [flavors.md](flavors.md) — flavor families and recipe ids
- [conflicts.md](conflicts.md) — core conflicts
- [troubleshooting.md](troubleshooting.md) — ticket symptoms
- [clarifications.md](clarifications.md) — open items
- [checklist.md](checklist.md) — what each box means

## 1. Infer the platform

Follow [routing.md](routing.md). User wording wins. Plugin markers win over a nested `ios/` or `android/` folder. If the platform is still ambiguous, ask once. That is the only required question on the quick path.

## 2. Choose the product

Follow [no-ui-vs-headless.md](no-ui-vs-headless.md).

- **UI SDK** — Lens camera, gallery, or files UI, or a no-UI call on that same SDK (`uploadImages`; on iOS also `headlessUpload`).
- **Headless product** — separate receipts or credit-cards binary. The host owns the camera.

## 3. Intake

**Quick.** Do not interview. Apply the assumptions in [intake.md](intake.md) for anything the user left out. Write those assumptions in the route card.

**Guided (recommended).** Ask the intake table once. Skip any row the project or the user already answered.

## 4. Flavor and recipe

Pick the narrowest flavor whose models match the documents. When install size matters, recommend **Remote Models**. Apply **one** recipe id from [flavors.md](flavors.md). The sibling skill writes the property assignments.

Public settings stay on `VeryfiLensSettings`. The iOS baseline forbids `VeryfiLensReceiptsSettings`, `VeryfiLensChecksSettings`, and other `VeryfiLens*Settings` subclasses in client code. Do not copy those subclasses out of the public quick start.

## 5. Conflicts

Run [conflicts.md](conflicts.md) after the recipe. Prefer dropping an extra flag over adding one. Then skim [troubleshooting.md](troubleshooting.md) for the symptom the host is already hitting.

## 6. Hand off

Stop this router. Open the sibling skill and follow it for install, configure, presentation, and callbacks.

| Platform | Skill |
|----------|--------|
| iOS | [../veryfi-lens-ios-integrate/SKILL.md](../veryfi-lens-ios-integrate/SKILL.md) |
| Android | [../veryfi-lens-android-integrate/SKILL.md](../veryfi-lens-android-integrate/SKILL.md) |
| Plugins | [../veryfi-lens-plugins-integrate/SKILL.md](../veryfi-lens-plugins-integrate/SKILL.md) |

If that skill file is missing, say so. Do not synthesize install code or method names from this router.

## Route card

Produce this, then follow the sibling skill:

```
Lens route:
- Path: quick | guided
- Platform:
- Product: UI SDK | Headless receipts | Headless credit cards
- Presentation:
- Documents:
- Recipe:
- Assumptions:
- Conflicts:
- Next skill:
```

## Do not

- Change SDK source from this skill
- Treat `uploadImages` or iOS `headlessUpload` as a Headless product
- Claim Android has `headlessUpload` (the UI facade method found in source is `uploadImages`)
- Invent plugin method names when the plugins skill is absent
- Quote an XCFramework or AAR file size as the size added to the installed app
- Enable `dictateIsOn` from this router
- Leave `ignoreRemoteSettings` false unless the host wants dashboard `lens_settings` to override the recipe
- Set in-app extraction except for `credit_card`, `code`, or `barcode`
- Send credit card data to the backend
