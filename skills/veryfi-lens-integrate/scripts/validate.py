#!/usr/bin/env python3
"""Validate the veryfi-lens-integrate router pack.

Stdlib only. Checks files, frontmatter, relative links, and required
routing phrases. Does not call a Lens API or invent SDK surface.
Sibling Android and plugins skills may be absent; that prints a note
and does not fail.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
IOS_SKILL = ROOT.parent / "veryfi-lens-ios-integrate" / "SKILL.md"

REQUIRED = [
    "SKILL.md",
    "routing.md",
    "no-ui-vs-headless.md",
    "intake.md",
    "checklist.md",
    "flavors.md",
    "conflicts.md",
    "troubleshooting.md",
    "clarifications.md",
]

# Phrases that must appear somewhere in the pack (case-sensitive).
REQUIRED_PHRASES = [
    "headlessUpload",
    "uploadImages",
    "Headless product",
    "Unconfirmed",
    "quick",
    "guided",
    "veryfi-lens-ios-integrate",
    "veryfi-lens-android-integrate",
    "veryfi-lens-plugins-integrate",
    "VeryfiLensSettings",
]

LINK_RE = re.compile(r"\[[^\]]+\]\(([^)]+)\)")
FRONTMATTER_RE = re.compile(r"^---\n(.*?)\n---", re.DOTALL)


def fail(errors: list[str], message: str) -> None:
    errors.append(message)


def check_frontmatter(errors: list[str]) -> None:
    text = (ROOT / "SKILL.md").read_text(encoding="utf-8")
    match = FRONTMATTER_RE.match(text)
    if not match:
        fail(errors, "SKILL.md is missing YAML frontmatter")
        return
    body = match.group(1)
    name = re.search(r"^name:\s*(\S+)\s*$", body, re.M)
    desc = re.search(r"^description:\s*>-\s*\n((?:  .+\n)+)", body, re.M)
    if not name or name.group(1) != "veryfi-lens-integrate":
        fail(errors, "SKILL.md name must be veryfi-lens-integrate")
    if not desc:
        fail(errors, "SKILL.md description must use a folded block")
    else:
        description = " ".join(line.strip() for line in desc.group(1).splitlines())
        if not description:
            fail(errors, "SKILL.md description is empty")
        if len(description) > 1024:
            fail(errors, "SKILL.md description exceeds 1024 characters")
    line_count = text.count("\n") + (0 if text.endswith("\n") else 1)
    if line_count > 500:
        fail(errors, f"SKILL.md is {line_count} lines; keep it at or under 500")


def check_links(errors: list[str]) -> None:
    for name in REQUIRED:
        text = (ROOT / name).read_text(encoding="utf-8")
        for raw in LINK_RE.findall(text):
            target = raw.strip()
            if target.startswith(("http://", "https://", "mailto:")):
                continue
            path_part, _, _anchor = target.partition("#")
            if not path_part:
                continue
            resolved = (ROOT / name).parent / path_part
            if not resolved.exists():
                fail(errors, f"{name} links to missing file: {target}")


def check_phrases(errors: list[str]) -> None:
    blob = "\n".join((ROOT / name).read_text(encoding="utf-8") for name in REQUIRED)
    for phrase in REQUIRED_PHRASES:
        if phrase not in blob:
            fail(errors, f"missing required phrase: {phrase}")
    no_ui = (ROOT / "no-ui-vs-headless.md").read_text(encoding="utf-8")
    if "no `headless*" not in no_ui and "No `headless*" not in no_ui:
        fail(
            errors,
            "no-ui-vs-headless.md must state that Android UI facade has no headless* method",
        )


def note_siblings() -> None:
    android = ROOT.parent / "veryfi-lens-android-integrate" / "SKILL.md"
    plugins = ROOT.parent / "veryfi-lens-plugins-integrate" / "SKILL.md"
    if android.exists():
        print(f"note: Android skill present at {android}")
    else:
        print("note: Android skill not present (Unconfirmed). Router must not invent Android APIs.")
    if plugins.exists():
        print(f"note: plugins skill present at {plugins}")
    else:
        print("note: plugins skill not present (Unconfirmed). Router must not invent plugin APIs.")


def main() -> int:
    errors: list[str] = []
    for name in REQUIRED:
        if not (ROOT / name).is_file():
            fail(errors, f"missing {name}")
    if not IOS_SKILL.is_file():
        fail(errors, f"iOS baseline skill missing: {IOS_SKILL}")
    if not errors:
        check_frontmatter(errors)
        check_links(errors)
        check_phrases(errors)
    note_siblings()
    if errors:
        print("FAIL")
        for item in errors:
            print(f"- {item}")
        return 1
    print("OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
