#!/usr/bin/env python3
"""Validate all generated Lens integration packs against checked-out sources."""

from __future__ import annotations

import re
import sys
from pathlib import Path
from urllib.parse import unquote

REPO = Path(__file__).resolve().parents[3]
CURSOR = REPO / ".cursor"
PACKS = [
    CURSOR / "veryfi-lens-integrate",
    CURSOR / "veryfi-lens-ios-integrate",
    CURSOR / "veryfi-lens-android-integrate",
    CURSOR / "veryfi-lens-plugins-integrate",
]
ANDROID = Path.home() / "lens" / "veryfi-lens-android"
PLUGINS = Path.home() / "plugins"
LINK_RE = re.compile(r"\[[^\]]*]\(([^)]+)\)")
FENCE_RE = re.compile(r"```(\w+)?\n(.*?)```", re.DOTALL)


def markdown_files() -> list[Path]:
    return [path for pack in PACKS for path in pack.rglob("*.md")]


def check_links(errors: list[str]) -> None:
    for source in markdown_files():
        for raw in LINK_RE.findall(source.read_text(encoding="utf-8")):
            target = raw.strip().split()[0].strip("<>")
            if target.startswith(("http://", "https://", "mailto:", "#")):
                continue
            path_part = unquote(target.split("#", 1)[0])
            if path_part and not (source.parent / path_part).resolve().exists():
                errors.append(f"{source.relative_to(REPO)}: missing link target {raw}")


def check_ios_settings(errors: list[str]) -> None:
    source = REPO / "Veryfi-Lens" / "Public" / "Model" / "VeryfiLensSettings.swift"
    properties = set(re.findall(r"\bvar\s+(\w+)\s*:", source.read_text(encoding="utf-8")))
    templates = CURSOR / "veryfi-lens-ios-integrate" / "templates"
    for path in templates.glob("*.md"):
        if path.name.startswith("headless-"):
            continue
        for language, block in FENCE_RE.findall(path.read_text(encoding="utf-8")):
            if language != "swift":
                continue
            for name in re.findall(r"\bsettings\.(\w+)\s*=", block):
                if name not in properties:
                    errors.append(f"{path.relative_to(REPO)}: unknown iOS setting {name}")
            forbidden = re.findall(
                r"\bVeryfiLens(?:Receipts|Checks|Code|CreditCardSolution|"
                r"BusinessCards|Barcodes|W2|W9)Settings\s*\(",
                block,
            )
            if forbidden:
                errors.append(
                    f"{path.relative_to(REPO)}: Demo settings constructor in client code"
                )


def check_android(errors: list[str]) -> None:
    if not ANDROID.is_dir():
        print(f"note: Android source absent at {ANDROID}; source checks skipped")
        return
    settings_source = (
        ANDROID
        / "veryfihelpers/src/main/java/com/veryfi/lens/helpers/VeryfiLensSettings.kt"
    ).read_text(encoding="utf-8")
    properties = set(re.findall(r"\bvar\s+(\w+)\s*[:=]", settings_source))
    credential_fields = {"clientId", "username", "apiKey", "url"}
    templates = CURSOR / "veryfi-lens-android-integrate" / "templates"
    for path in templates.glob("*.md"):
        for language, block in FENCE_RE.findall(path.read_text(encoding="utf-8")):
            if language != "kotlin":
                continue
            for name in re.findall(r"^\s{4}(\w+)\s*=", block, re.MULTILINE):
                if name not in properties | credential_fields:
                    errors.append(
                        f"{path.relative_to(REPO)}: unknown Android setting/credential {name}"
                    )

    build = (ANDROID / "veryfilens/build.gradle").read_text(encoding="utf-8")
    artifacts = {
        "veryfi-lens-sdk",
        "veryfi-lens-remote-models-sdk",
        "veryfi-lens-receipts-sdk",
        "veryfi-lens-long-receipts-sdk",
        "veryfi-lens-cheques-sdk",
        "veryfi-lens-credit-cards-sdk",
        "veryfi-lens-business-cards-sdk",
        "veryfi-lens-barcodes-sdk",
        "veryfi-lens-ocr-sdk",
        "veryfi-lens-w2-sdk",
        "veryfi-lens-w9-sdk",
        "veryfi-lens-lite-sdk",
    }
    for artifact in sorted(artifacts):
        if artifact not in build:
            errors.append(f"Android build.gradle does not publish {artifact}")

    required_methods = {
        ANDROID / "veryfilens/src/main/java/com/veryfi/lens/VeryfiLens.kt": [
            "fun configure(",
            "fun showCamera(",
            "fun showGallery(",
            "fun showDocumentBrowser(",
            "fun uploadImages(",
            "fun setDelegate(",
        ],
        ANDROID
        / "veryfilens-headless-receipts/src/main/java/com/veryfi/lens/headless/receipts/VeryfiLensHeadless.kt": [
            "fun configure(",
            "fun processFrame(",
            "fun captureFrame(",
            "fun processGalleryImage(",
        ],
        ANDROID
        / "veryfilens-headless-creditcards/src/main/java/com/veryfi/lens/headless/creditcards/VeryfiLensHeadless.kt": [
            "fun configure(",
            "fun processCreditCard(",
            "fun reset(",
            "fun close(",
        ],
    }
    for source, tokens in required_methods.items():
        text = source.read_text(encoding="utf-8")
        for token in tokens:
            if token not in text:
                errors.append(f"{source}: missing documented method token {token}")


def check_plugins(errors: list[str]) -> None:
    sources = {
        PLUGINS
        / "veryfi-lens-cordova-plugin-androidx/cordova-plugin-veryfi-lens/www/veryfi.js": [
            "init: function",
            "showCamera: function",
            "getFileBase64: function",
        ],
        PLUGINS
        / "veryfi-lens-react-plugin/react-native-veryfi-lens/src/index.tsx": [
            "configureWithCredentials",
            "showGallery",
            "showDocumentBrowser",
            "closeCamera",
            "showHelpScreen",
        ],
        PLUGINS
        / "veryfi-lens-flutter-plugin/flutter-plugin-veryfi-lens/lib/lens.dart": [
            "initLens(",
            "setDelegate(",
            "showCamera(",
        ],
        PLUGINS
        / "veryfi-lens-capacitor-plugin/veryfi-lens-capacitor/src/definitions.ts": [
            "veryfiInitLens(",
            "setLensEventDelegate(",
            "showCamera(",
        ],
        PLUGINS
        / "veryfi-lens-xamarin-plugin/VeryfiLens.Maui/src/VeryfiLens.Sdk/VeryfiLensMaui.cs": [
            "class VeryfiLensBinding",
            "ShowGallery(",
            "ShowDocumentBrowser(",
            "UploadImages(",
        ],
    }
    for source, tokens in sources.items():
        if not source.is_file():
            print(f"note: plugin source absent at {source}; checks skipped")
            continue
        text = source.read_text(encoding="utf-8")
        for token in tokens:
            if token not in text:
                errors.append(f"{source}: missing documented API token {token}")

    recipes = (
        CURSOR / "veryfi-lens-plugins-integrate" / "recipes.md"
    ).read_text(encoding="utf-8")
    engines = set(re.findall(r'"dataExtractionEngine"\s*:\s*"([^"]+)"', recipes))
    if not engines <= {"api", "mobile", "none"}:
        errors.append(f"plugin recipes contain unsupported engine strings: {engines}")


def main() -> int:
    errors: list[str] = []
    for pack in PACKS:
        if not (pack / "SKILL.md").is_file():
            errors.append(f"missing integration skill: {pack}")
    check_links(errors)
    check_ios_settings(errors)
    check_android(errors)
    check_plugins(errors)
    if errors:
        print("FAIL")
        for error in errors:
            print(f"- {error}")
        return 1
    print(f"OK: {len(markdown_files())} Markdown files and checked-out APIs validated")
    return 0


if __name__ == "__main__":
    sys.exit(main())
