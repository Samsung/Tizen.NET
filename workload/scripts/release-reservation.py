#!/usr/bin/env python3
#
# Copyright (c) Samsung Electronics. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#
"""
Encode and verify the payload of a release reservation.

Why a payload at all
--------------------
A reservation used to be nothing but a ref pointing at a commit. That is enough to answer
"is this version taken", but not "is this run allowed to continue it". Two failures follow
from a bare ref:

  * A re-run of a dispatch checks out the SHA of the ORIGINAL event, so `Versions.props` on
    disk still holds the pre-bump version. Deciding what to resume from that value makes a
    re-run look at a version it already finished, conclude there is nothing to resume, and
    then abort against its own reservation.
  * Nothing tied the reservation to the inputs it was made for. Re-dispatching with a
    different `net_sdk_version` would happily resume a reservation created for another SDK
    band and publish a manifest built for the wrong one.

So the reservation records the complete set of release inputs, and a run that wants to
continue it must match them exactly.

Format
------
The reservation ref (`refs/tizen-release/v<version>`) points at an annotated tag object
whose message contains one line of JSON:

  {"version", "sha", "sdk", "band", "manifest_id", "packages", "branch"}

`sha` is the reserved release commit: the single commit every artifact for this version
must be built from, on the first attempt and on every retry.

Commands
--------
  encode   build the payload from explicit inputs (prints one line of JSON)
  verify   check a payload against the inputs of the run that wants to use it

Exit codes
----------
  0  ok
  2  usage/parse error
  3  the reservation does not match the run's inputs (do NOT resume it)
"""
from __future__ import annotations

import argparse
import json
import sys

FIELDS = ("version", "sha", "sdk", "band", "manifest_id", "packages", "branch")


def encode(args: argparse.Namespace) -> int:
    packages = [p.strip() for p in args.packages.split(",") if p.strip()]
    if not packages:
        print("ERROR: --packages must list at least one package id", file=sys.stderr)
        return 2
    if len(args.sha) != 40 or not all(c in "0123456789abcdef" for c in args.sha.lower()):
        print(f"ERROR: --sha must be a full 40-character commit id, got {args.sha!r}",
              file=sys.stderr)
        return 2
    payload = {
        "version": args.version.strip(),
        "sha": args.sha.strip().lower(),
        "sdk": args.sdk.strip(),
        "band": args.band.strip(),
        "manifest_id": args.manifest_id.strip(),
        "packages": sorted(packages),
        "branch": args.branch.strip(),
    }
    for key in FIELDS:
        if not payload[key]:
            print(f"ERROR: {key} must not be empty", file=sys.stderr)
            return 2
    # separators= keeps it on a single line so `git cat-file -p` output can be grepped.
    print(json.dumps(payload, sort_keys=True, separators=(",", ":")))
    return 0


def load_payload(path: str) -> dict:
    with open(path, "r", encoding="utf-8") as handle:
        text = handle.read()
    # Tolerate the surrounding tag-object headers: take the first line that looks like the
    # payload object.
    for line in text.splitlines():
        line = line.strip()
        if line.startswith("{"):
            return json.loads(line)
    raise ValueError("no JSON payload found")


def verify(args: argparse.Namespace) -> int:
    try:
        payload = load_payload(args.payload_file)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"ERROR: unreadable reservation payload: {exc}", file=sys.stderr)
        return 2

    if not isinstance(payload, dict):
        print("ERROR: reservation payload is not an object", file=sys.stderr)
        return 2
    missing = [f for f in FIELDS if f not in payload]
    if missing:
        # An older, bare reservation cannot be validated, so it cannot be resumed.
        print(
            "ERROR: reservation is missing required field(s): "
            + ", ".join(missing)
            + ". Refusing to resume a reservation whose release inputs are unknown.",
            file=sys.stderr,
        )
        return 3

    problems = []
    checks = [
        ("version", args.expect_version),
        ("sdk", args.expect_sdk),
        ("band", args.expect_band),
        ("branch", args.expect_branch),
        ("manifest_id", args.expect_manifest_id),
        ("sha", args.expect_sha),
    ]
    for key, expected in checks:
        if expected is None:
            continue
        actual = payload.get(key)
        if isinstance(actual, str) and isinstance(expected, str):
            same = actual.strip() == expected.strip()
        else:
            same = actual == expected
        if not same:
            problems.append(f"{key}: reserved {actual!r} but this run has {expected!r}")

    if args.expect_packages is not None:
        expected_pkgs = sorted(p.strip() for p in args.expect_packages.split(",") if p.strip())
        actual_pkgs = payload.get("packages")
        if not isinstance(actual_pkgs, list):
            problems.append("packages: reservation payload has a non-list 'packages'")
        elif sorted(actual_pkgs) != expected_pkgs:
            problems.append(
                f"packages: reserved {sorted(actual_pkgs)} but this run expects {expected_pkgs}"
            )

    if problems:
        print(
            "ERROR: reservation v{0} does not match this run:".format(payload.get("version")),
            file=sys.stderr,
        )
        for problem in problems:
            print("  - " + problem, file=sys.stderr)
        print(
            "Refusing to resume it. A reservation may only be continued by a run with the "
            "same release inputs.",
            file=sys.stderr,
        )
        return 3

    if args.print_field:
        value = payload.get(args.print_field)
        print(",".join(value) if isinstance(value, list) else value)
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)

    enc = sub.add_parser("encode", help="build a reservation payload")
    for flag in ("version", "sha", "sdk", "band", "manifest-id", "packages", "branch"):
        enc.add_argument("--" + flag, required=True)
    enc.set_defaults(func=encode)

    ver = sub.add_parser("verify", help="check a reservation against this run's inputs")
    ver.add_argument("--payload-file", required=True)
    for flag in ("version", "sha", "sdk", "band", "branch", "manifest-id", "packages"):
        ver.add_argument("--expect-" + flag, default=None)
    ver.add_argument("--print-field", default=None,
                     help="on success, print this field from the payload")
    ver.set_defaults(func=verify)

    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
