#!/usr/bin/env nix-shell
#! nix-shell -i python -p "python3.withPackages (ps: with ps; [ absl-py node-semver ])" nix-prefetch-scripts git

# TODO: factor update scripts

import json
import os
import re
import subprocess

from typing import Optional

from absl import app
from absl import flags
from absl import logging

import semver

REPO = "https://github.com/epics-modules/asyn.git"
# See: https://github.com/npm/node-semver#versions
VERSION_REQ = ">=4"

FLAGS = flags.FLAGS

flags.DEFINE_string("out", "", "Output path for versions.json.")


def find_versions_json() -> str:
    if FLAGS.out:
        return FLAGS.out
    try_paths = ["pkgs/support/asyn/versions.json", "versions.json"]
    for path in try_paths:
        if os.path.exists(path):
            return path
    raise Exception(
        "Couldn't figure out where to write versions.json; try specifying --out"
    )


def sanitize_tag(tag: str) -> Optional[str]:
    # Only official releases
    if not tag.startswith("R"):
        return None

    # Remove the "R", and make a semver compatible version
    cleaned_tag = tag[1:]

    # No prereleases, beta, or release candidates
    if re.search("[a-zA-Z]", cleaned_tag):
        return None

    parts = cleaned_tag.split("-")

    if len(parts) < 3:
        parts.append("0")

    return ".".join(parts)



def list_remote_tags() -> str:
    cmd = ["git", "ls-remote", "--tags", REPO]
    logging.info("Running %s", cmd)
    out = subprocess.check_output(cmd)
    out = out.decode("utf-8")

    tags = set()

    for line in out.splitlines():
        end = line.rfind("^")
        if end == -1:
            tag = line[line.rfind("/") + 1 :]
        else:
            tag = line[line.rfind("/") + 1 : end]

        # Remove the "R", and make a semver compatible version
        cleaned_tag = sanitize_tag(tag)

        if not cleaned_tag:
            continue

        if semver.satisfies(cleaned_tag, VERSION_REQ):
            tags.add(tag[1:])

    return tags


def prefetch(tag: str) -> str:
    cmd = ["nix-prefetch-git", "--url", REPO, "--rev", tag, "--fetch-submodules"]
    logging.info("Running %s", cmd)
    out = subprocess.check_output(cmd)
    return json.loads(out.decode("utf-8"))["sha256"]


def main(argv):
    out_file = find_versions_json()
    logging.info("Outputting to '%s'", out_file)

    tags = list_remote_tags()

    logging.info("Fetching for tags: %s", tags)

    output = {}

    for tag in tags:
        output[tag] = {"sha256": prefetch(tag)}

    logging.info("Output: %s", output)
    with open(out_file, "w") as file:
        json.dump(output, file, sort_keys=True, indent=2)


if __name__ == "__main__":
    app.run(main)