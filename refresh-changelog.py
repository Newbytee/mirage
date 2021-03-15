#!/usr/bin/env python3

from pathlib import Path
import mistune
import re


def make_changelog_dict(title):
    title_parts = title.split(" ")

    return {
        "changes": "",
        "date": title_parts[2][1:-2],
        "version": title_parts[1]
    }


def get_src_path():
    return str(Path(__file__).resolve().parent)


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
    appdata_releases += "<release version=\"" + entry["version"] + "\" date=\"" + entry["date"] + "\">\n"
    appdata_releases += changes_html
    appdata_releases += "</release>\n"

print(appdata_releases)
