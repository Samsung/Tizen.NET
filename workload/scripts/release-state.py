#!/usr/bin/env python3
#
# Copyright (c) Samsung Electronics. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#
"""
Report the publication state of a workload version so a release can be resumed.

Why
===
The release publishes several packages and then creates a tag + GitHub release. Those
steps are not atomic. If one fails after the manifest has been pushed, the version V is
*partially* published:

  * `next-workload-version.py` derives the next version from what exists on NuGet, so it
    now answers V+1;
  * the previous logic saw OLD(V) != NEW(V+1), bumped, and moved on;
  * V therefore never receives its remaining packs, its tag, or its release - permanently.

This script makes that state explicit so the workflow can resume V instead of advancing.
NuGet packages are immutable, so "already present" is always safe to skip.

States
------
  unpublished  none of the expected packages exist for V
  partial      some (but not all) expected packages exist for V
  published    every expected package exists for V
               (the caller still has to check the tag/release before treating V as done)

Outputs
-------
Emits `key=value` lines suitable for appending to $GITHUB_OUTPUT:

  state=unpublished|partial|published
  present=<comma-separated package ids that already exist at V>
  missing=<comma-separated package ids that do not>

Exit codes
----------
  0  state determined
  2  the feed could not be reached (caller must NOT advance the version on this)

Testing
-------
`--feed-base` (or TIZEN_NUGET_FEED_BASE) overrides the flatcontainer base URL, so tests can
point at a local directory of `<id>/index.json` files via a file:// URL.
"""
from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.error
import urllib.request

DEFAULT_FEED_BASE = "https://api.nuget.org/v3-flatcontainer"

# Packages that carry the workload version. Ref packs are versioned by their TizenFX
# version instead and are governed by the separate release_reference input.
VERSIONED_PACKAGE_SUFFIXES = [
    "Samsung.Tizen.Sdk",
    "Samsung.NETCore.App.Runtime.tizen",
    "Samsung.Tizen.Templates",
]


def feed_versions(feed_base: str, package_id: str) -> list:
    """Return the published versions of package_id, or [] when it has never been published."""
    url = "{0}/{1}/index.json".format(feed_base.rstrip("/"), package_id.lower())
    try:
        with urllib.request.urlopen(url, timeout=30) as response:
            payload = json.load(response)
    except urllib.error.HTTPError as exc:
        if exc.code == 404:
            # Genuinely never published.
            return []
        raise
    except urllib.error.URLError as exc:
        # A missing file on a file:// feed (used by the tests) is the local equivalent of a
        # 404. Every OTHER URLError is a transport failure and must stay fatal - treating it
        # as "unpublished" would advance the version and strand a partial release.
        if url.startswith("file:") and isinstance(exc.reason, FileNotFoundError):
            return []
        raise

    # Only a 404 means "never published". A 200 carrying something we cannot parse is a
    # malformed response, and must NOT be read as absence: `{}` previously yielded [] via
    # .get("versions", []), so a truncated or error-shaped body made a published package
    # look missing - which downgrades `published` to `partial` and re-publishes, or worse
    # makes a partial release look unpublished and advances past it.
    if not isinstance(payload, dict):
        raise ValueError(
            "malformed index for {0}: expected a JSON object, got {1}".format(
                package_id, type(payload).__name__
            )
        )
    if "versions" not in payload:
        raise ValueError(
            "malformed index for {0}: no 'versions' key. A 200 response that cannot be "
            "parsed is not the same as a package that was never published.".format(package_id)
        )
    versions = payload["versions"]
    if not isinstance(versions, list):
        raise ValueError(
            "malformed index for {0}: 'versions' is {1}, expected a list".format(
                package_id, type(versions).__name__
            )
        )
    return [v for v in versions if v]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--version", required=True, help="workload version to inspect")
    parser.add_argument("--band", required=True, help="SDK feature band, e.g. 11.0.100-preview.7")
    parser.add_argument(
        "--feed-base",
        default=os.environ.get("TIZEN_NUGET_FEED_BASE", DEFAULT_FEED_BASE),
        help="flatcontainer base URL (tests may point this at a local directory)",
    )
    args = parser.parse_args()

    version = args.version.strip()
    if not version:
        print("ERROR: --version must not be empty", file=sys.stderr)
        return 2

    expected = ["Samsung.NET.Sdk.Tizen.Manifest-" + args.band] + VERSIONED_PACKAGE_SUFFIXES

    present, missing = [], []
    for package_id in expected:
        try:
            versions = feed_versions(args.feed_base, package_id)
        except Exception as exc:  # noqa: BLE001 - any transport failure is fatal here
            print("ERROR: could not query {0}: {1}".format(package_id, exc), file=sys.stderr)
            # Never let a transport failure look like "unpublished": that would advance the
            # version and strand a partially published release.
            return 2
        (present if version in versions else missing).append(package_id)

    if not present:
        state = "unpublished"
    elif missing:
        state = "partial"
    else:
        state = "published"

    print("state=" + state)
    print("present=" + ",".join(present))
    print("missing=" + ",".join(missing))

    print(
        "Version {0} (band {1}): {2} - {3}/{4} expected package(s) published".format(
            version, args.band, state, len(present), len(expected)
        ),
        file=sys.stderr,
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
