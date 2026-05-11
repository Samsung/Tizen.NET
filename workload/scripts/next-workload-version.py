#!/usr/bin/env python3
#
# Copyright (c) Samsung Electronics. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#
"""
Compute the next TizenWorkloadVersion by looking at every Samsung.NET.Sdk.Tizen.Manifest
package published on NuGet, finding the largest globally-sequential build counter,
and returning it incremented by 1.

Rationale
=========
TizenWorkloadVersion uses the format `<TizenOSMajor>.<TizenOSMinor>.<buildSeq>` where
`buildSeq` increments by 1 per release REGARDLESS of which .NET SDK band the release
targets. Every active branch (main, net7.0, net8.0, net9.0, net10.0) draws from the
same `buildSeq` pool. NuGet is the source of truth: the next number must be 1 more
than the largest `buildSeq` ever published, irrespective of sdkBand or branch.

Algorithm
=========
1. Query NuGet's search index for all packages whose id starts with
   `samsung.net.sdk.tizen.manifest-`. This returns one entry per sdkBand (one
   package per band, e.g. ...-7.0.400, ...-8.0.100-rtm, etc.).
2. For each package id, fetch the full version list from the flatcontainer endpoint.
3. Parse each version into (major, minor, buildSeq), ignoring pre-release suffixes
   that follow `-`. Build counters are integers regardless of pre-release tag.
4. Determine the global maximum `(major, minor, buildSeq)` triple.
5. Print `<major>.<minor>.<buildSeq+1>` on stdout (single line, no extras).

Usage
=====
    # Print only:
    python3 workload/scripts/next-workload-version.py

    # Update Versions.props in place:
    python3 workload/scripts/next-workload-version.py --apply

    # Show diagnostics on stderr:
    python3 workload/scripts/next-workload-version.py --verbose

Notes
=====
- Reads no local files; relies only on what is published to nuget.org. This is
  intentional: published artifacts are the authoritative shared sequence; uncommitted
  Versions.props bumps cannot influence the answer.
- If the network is unreachable, exit code 2.
- `--apply` writes Versions.props only when the new value is strictly greater than
  what is already there; otherwise it warns and leaves the file alone.
"""
from __future__ import annotations
import argparse
import json
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

SEARCH_URL = (
    "https://azuresearch-usnc.nuget.org/query"
    "?q=packageid:samsung.net.sdk.tizen.manifest"
    "&prerelease=true&semVerLevel=2.0.0&take=200"
)
SEARCH_FALLBACK_URL = (
    "https://azuresearch-usnc.nuget.org/query"
    "?q=samsung.net.sdk.tizen.manifest"
    "&prerelease=true&semVerLevel=2.0.0&take=200"
)
FLATCONTAINER_FMT = "https://api.nuget.org/v3-flatcontainer/{id}/index.json"

VERSION_RE = re.compile(r"^(\d+)\.(\d+)\.(\d+)(?:[-+].*)?$")


def fetch_json(url: str, timeout: int = 15) -> dict:
    try:
        with urllib.request.urlopen(url, timeout=timeout) as r:
            return json.loads(r.read().decode("utf-8"))
    except (urllib.error.URLError, urllib.error.HTTPError) as e:
        raise SystemExit(f"network error fetching {url}: {e}")


def find_manifest_package_ids(verbose: bool = False) -> list[str]:
    """Return lowercase ids of every published samsung.net.sdk.tizen.manifest-* package."""
    out: set[str] = set()
    for url in (SEARCH_URL, SEARCH_FALLBACK_URL):
        try:
            data = fetch_json(url)
        except SystemExit:
            continue
        for entry in data.get("data", []):
            pid = entry.get("id", "").lower()
            # Accept both exact 'samsung.net.sdk.tizen.manifest' (no suffix, unusual)
            # and the typical '-<band>' suffix forms.
            if pid.startswith("samsung.net.sdk.tizen.manifest"):
                out.add(pid)
        if out:
            break
    if verbose:
        print(f"[verbose] discovered {len(out)} manifest package ids", file=sys.stderr)
    return sorted(out)


def fetch_versions(pid: str, verbose: bool = False) -> list[str]:
    url = FLATCONTAINER_FMT.format(id=pid)
    try:
        data = fetch_json(url)
    except SystemExit:
        if verbose:
            print(f"[verbose] failed to fetch versions for {pid}", file=sys.stderr)
        return []
    return data.get("versions", [])


def parse_version(v: str) -> tuple[int, int, int] | None:
    m = VERSION_RE.match(v)
    return (int(m.group(1)), int(m.group(2)), int(m.group(3))) if m else None


def find_max_triple(verbose: bool = False) -> tuple[int, int, int]:
    pkgs = find_manifest_package_ids(verbose=verbose)
    if not pkgs:
        raise SystemExit("no Samsung.NET.Sdk.Tizen.Manifest packages found on NuGet")

    best: tuple[int, int, int] | None = None
    best_pkg = best_ver = ""
    for pid in pkgs:
        for v in fetch_versions(pid, verbose=verbose):
            t = parse_version(v)
            if t is None:
                continue
            if best is None or t > best:
                best, best_pkg, best_ver = t, pid, v

    if best is None:
        raise SystemExit("no parseable versions found across all manifest packages")

    if verbose:
        print(f"[verbose] max = {best} (from {best_pkg} version={best_ver})", file=sys.stderr)
    return best


def update_versions_props(versions_props: Path, new_value: str, verbose: bool = False) -> int:
    text = versions_props.read_text(encoding="utf-8")
    m = re.search(r"<TizenWorkloadVersion>([^<]+)</TizenWorkloadVersion>", text)
    if not m:
        raise SystemExit(f"<TizenWorkloadVersion> not found in {versions_props}")
    current = m.group(1).strip()

    def to_tuple(s: str) -> tuple[int, int, int] | None:
        return parse_version(s)

    cur_t, new_t = to_tuple(current), to_tuple(new_value)
    if cur_t is None:
        raise SystemExit(f"unparseable current version: {current!r}")
    if new_t is None:
        raise SystemExit(f"unparseable new version: {new_value!r}")

    if new_t <= cur_t:
        print(
            f"refusing to write: current TizenWorkloadVersion ({current}) is >= candidate ({new_value}). "
            f"Versions.props left unchanged.",
            file=sys.stderr,
        )
        return 1

    new_text = re.sub(
        r"<TizenWorkloadVersion>[^<]+</TizenWorkloadVersion>",
        f"<TizenWorkloadVersion>{new_value}</TizenWorkloadVersion>",
        text,
        count=1,
    )
    versions_props.write_text(new_text, encoding="utf-8")
    if verbose:
        print(f"[verbose] {versions_props}: {current} -> {new_value}", file=sys.stderr)
    return 0


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__.splitlines()[1] if __doc__ else "")
    p.add_argument("--apply", action="store_true",
                   help="Update workload/build/Versions.props in place (only if strictly greater).")
    p.add_argument("--versions-props", default=None,
                   help="Path to Versions.props (default: workload/build/Versions.props relative to this script).")
    p.add_argument("--verbose", action="store_true", help="Print diagnostics on stderr.")
    args = p.parse_args()

    major, minor, build = find_max_triple(verbose=args.verbose)
    next_value = f"{major}.{minor}.{build + 1}"

    if args.apply:
        if args.versions_props:
            vp = Path(args.versions_props)
        else:
            # script is in workload/scripts/, so Versions.props is sibling-of-parent/build/
            vp = Path(__file__).resolve().parents[1] / "build" / "Versions.props"
        rc = update_versions_props(vp, next_value, verbose=args.verbose)
        # Always echo the computed value so CI/scripts can capture it.
        print(next_value)
        return rc

    print(next_value)
    return 0


if __name__ == "__main__":
    sys.exit(main())
