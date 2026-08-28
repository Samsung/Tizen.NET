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
---------
TizenWorkloadVersion uses the format `<TizenOSMajor>.<TizenOSMinor>.<buildSeq>` where
`buildSeq` increments by 1 per release REGARDLESS of which .NET SDK band the release
targets. Every active branch (main, net7.0, net8.0, net9.0, net10.0) draws from the
same `buildSeq` pool. NuGet is the source of truth: the next number must be 1 more
than the largest `buildSeq` ever published, irrespective of sdkBand or branch.

Algorithm
---------
1. Query NuGet's search index for all packages whose id starts with
   `samsung.net.sdk.tizen.manifest-`. This returns one entry per sdkBand (one
   package per band, e.g. ...-7.0.400, ...-8.0.100-rtm, etc.).
2. For each package id, fetch the full version list from the flatcontainer endpoint.
3. Parse each version into (major, minor, buildSeq), ignoring pre-release suffixes
   that follow `-`. Build counters are integers regardless of pre-release tag.
4. Determine the global maximum `(major, minor, buildSeq)` triple.
5. Print `<major>.<minor>.<buildSeq+1>` on stdout (single line, no extras).

Usage
-----
    # Print only:
    python3 workload/scripts/next-workload-version.py

    # Update Versions.props in place:
    python3 workload/scripts/next-workload-version.py --apply

    # Show diagnostics on stderr:
    python3 workload/scripts/next-workload-version.py --verbose

Notes
-----
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
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

# Overridable so the tests can point the queries at a local stub feed. Defaults are the
# production endpoints; nothing in CI or a real release sets these.
SEARCH_BASE = os.environ.get("TIZEN_NUGET_SEARCH_BASE", "https://azuresearch-usnc.nuget.org/query")
FLATCONTAINER_BASE = os.environ.get(
    "TIZEN_NUGET_FEED_BASE", "https://api.nuget.org/v3-flatcontainer"
)

SEARCH_URL = (
    SEARCH_BASE + "?q=packageid:samsung.net.sdk.tizen.manifest"
    "&prerelease=true&semVerLevel=2.0.0"
)
SEARCH_FALLBACK_URL = (
    SEARCH_BASE + "?q=samsung.net.sdk.tizen.manifest"
    "&prerelease=true&semVerLevel=2.0.0"
)
PAGE_SIZE = 200

FLATCONTAINER_FMT = FLATCONTAINER_BASE.rstrip("/") + "/{id}/index.json"

VERSION_RE = re.compile(r"^(\d+)\.(\d+)\.(\d+)(?:[-+].*)?$")


def fetch_json(url: str, timeout: int = 15) -> dict:
    try:
        with urllib.request.urlopen(url, timeout=timeout) as r:
            return json.loads(r.read().decode("utf-8"))
    except (urllib.error.URLError, urllib.error.HTTPError) as e:
        raise SystemExit(f"network error fetching {url}: {e}")


def search_page(url_base: str, skip: int, take: int) -> tuple[int, list]:
    """One page of a NuGet search query, with the response strictly validated.

    Returns (totalHits, entries). Every structural surprise raises: a search response we
    cannot fully understand must never be reduced to "fewer packages exist".
    """
    url = "{0}&skip={1}&take={2}".format(url_base, skip, take)
    data = fetch_json(url)
    if not isinstance(data, dict):
        raise SystemExit(f"unexpected search response for {url}: not a JSON object")
    if "totalHits" not in data:
        raise SystemExit(f"search response for {url} has no 'totalHits'; refusing to guess")
    total = data["totalHits"]
    if not isinstance(total, int) or isinstance(total, bool) or total < 0:
        raise SystemExit(f"search response for {url} has a bad 'totalHits': {total!r}")
    entries = data.get("data")
    if not isinstance(entries, list):
        raise SystemExit(
            f"search response for {url} has a non-list 'data': {type(entries).__name__}"
        )
    return total, entries


def collect_ids(url_base: str, verbose: bool = False) -> set[str]:
    """Every matching package id from url_base, paginating until totalHits is satisfied.

    The search endpoint caps `take`, so a single request silently returned only the first
    page. Reading one page and treating it as the whole world meant a band whose entry fell
    on page 2 was invisible - and if that band held the highest build counter, the derived
    "next" version collided with one already published. Pagination continues until the
    number of entries seen matches totalHits; anything less is a hard error.
    """
    out: set[str] = set()
    skip = 0
    seen = 0
    total: int | None = None
    while True:
        page_total, entries = search_page(url_base, skip, PAGE_SIZE)
        if total is None:
            total = page_total
        elif page_total != total:
            raise SystemExit(
                f"totalHits changed mid-pagination ({total} -> {page_total}); the feed is "
                f"not stable enough to derive a version from."
            )
        for entry in entries:
            if not isinstance(entry, dict):
                raise SystemExit(f"unexpected search entry: {type(entry).__name__}")
            pid = entry.get("id", "")
            if not isinstance(pid, str):
                raise SystemExit(f"unexpected package id: {pid!r}")
            pid = pid.lower()
            # Accept both exact 'samsung.net.sdk.tizen.manifest' (no suffix, unusual)
            # and the typical '-<band>' suffix forms.
            if pid.startswith("samsung.net.sdk.tizen.manifest"):
                out.add(pid)
        seen += len(entries)
        if seen >= total:
            break
        if not entries:
            # More were promised than delivered: stop rather than spin, and fail closed.
            raise SystemExit(
                f"search returned {seen} of {total} promised entries for {url_base}; "
                f"refusing to derive a version from an incomplete package list."
            )
        skip += len(entries)
    if verbose:
        print(
            f"[verbose] {url_base}: {seen}/{total} entries, {len(out)} manifest ids",
            file=sys.stderr,
        )
    return out


def find_manifest_package_ids(verbose: bool = False) -> list[str]:
    """Return lowercase ids of every published samsung.net.sdk.tizen.manifest-* package."""
    problems: list[str] = []
    for url in (SEARCH_URL, SEARCH_FALLBACK_URL):
        try:
            out = collect_ids(url, verbose=verbose)
        except SystemExit as exc:
            # Remember it: if every query form fails we must abort rather than proceed
            # with no data, which would look exactly like "nothing is published yet".
            problems.append(f"{url}: {exc}")
            continue
        if out:
            if verbose:
                print(f"[verbose] discovered {len(out)} manifest package ids", file=sys.stderr)
            return sorted(out)
    if problems:
        raise SystemExit(
            "could not enumerate the manifest packages: "
            + "; ".join(problems)
            + ". Refusing to derive a version from incomplete feed data."
        )
    return []


def fetch_versions(pid: str, verbose: bool = False) -> list[str]:
    """Versions of an authoritative package.

    Any transport, status or parse failure ABORTS. Returning an empty list on failure
    silently lowered the global maximum: if the query that failed happened to be the
    package holding the highest build counter, the next version would collide with one
    that is already published. Being unable to see the whole picture is never the same
    as seeing an empty one.
    """
    url = FLATCONTAINER_FMT.format(id=pid)
    try:
        data = fetch_json(url)
    except SystemExit as exc:
        raise SystemExit(
            f"failed to fetch versions for {pid}: {exc}. Refusing to derive a version "
            f"from incomplete feed data."
        )
    if not isinstance(data, dict) or "versions" not in data:
        raise SystemExit(
            f"unexpected response for {pid} (no 'versions' array). Refusing to derive a "
            f"version from unparseable feed data."
        )
    versions = data.get("versions")
    if not isinstance(versions, list):
        raise SystemExit(f"unexpected 'versions' payload for {pid}: {type(versions).__name__}")
    return versions


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


def update_versions_props(
    versions_props: Path, new_value: str, verbose: bool = False, allow_noop: bool = False
) -> int:
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

    if allow_noop and new_t == cur_t:
        print(
            f"TizenWorkloadVersion is already {new_value}; nothing to write.",
            file=sys.stderr,
        )
        return 0

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
    p.add_argument("--set-version", default=None,
                   help="Write this exact version instead of re-deriving it. Use with --apply "
                        "so a caller that already computed a candidate cannot have a "
                        "concurrent release change the value between compute and apply.")
    args = p.parse_args()

    if args.set_version:
        if not args.apply:
            raise SystemExit("--set-version requires --apply")
        next_value = args.set_version.strip()
        if not VERSION_RE.match(next_value):
            raise SystemExit(f"--set-version {next_value!r} is not a valid workload version")
    else:
        major, minor, build = find_max_triple(verbose=args.verbose)
        next_value = f"{major}.{minor}.{build + 1}"

    if args.apply:
        if args.versions_props:
            vp = Path(args.versions_props)
        else:
            # script is in workload/scripts/, so Versions.props is sibling-of-parent/build/
            vp = Path(__file__).resolve().parents[1] / "build" / "Versions.props"
        # An explicit --set-version that equals what is already on disk is the resume
        # case: a previous run bumped the file but never got as far as reserving it.
        # That is a no-op, not a failure - the caller reserves the current commit.
        rc = update_versions_props(
            vp, next_value, verbose=args.verbose, allow_noop=bool(args.set_version)
        )
        # Always echo the computed value so CI/scripts can capture it.
        print(next_value)
        return rc

    print(next_value)
    return 0


if __name__ == "__main__":
    sys.exit(main())
