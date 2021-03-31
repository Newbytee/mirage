#!/usr/bin/env python3

from pathlib import Path
import html
import mistune
import re


def get_src_path():
    return str(Path(__file__).resolve().parent)


def make_changelog_dict(title):
    title_parts = title.split(" ")

    return {
        "changes": "",
        "date": title_parts[2][1:-2],
        "version": title_parts[1]
    }


def make_release_tag(changes_html, version, date):
    return "<release version=\"" + html.escape(version) \
            + "\" date=\"" + html.escape(date) \
            + "\">\n" \
            + changes_html \
            + "</release>\n"


markdown_parser = mistune.Markdown(escape=False)
changelog_title_pattern = re.compile(r"##\ \d\.\d\.\d\ \(\d{4}-\d{2}-\d{2}\)")
changelog_lines = open(get_src_path() + "/docs/CHANGELOG.md", "r").readlines()
changelog_entries = []

for line in changelog_lines:
    if changelog_title_pattern.match(line):
        changelog_entry = make_changelog_dict(line)
        changelog_entries.append(changelog_entry)
    elif len(changelog_entries) != 0:
        changelog_entries[-1]["changes"] += line

appdata_releases = ""

for entry in changelog_entries:
    changes_html = markdown_parser(entry["changes"])
    appdata_releases += \
        make_release_tag(changes_html, entry["version"], entry["date"])

print(appdata_releases)
