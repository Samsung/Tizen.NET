#!/usr/bin/env python3
#
# Copyright (c) Samsung Electronics. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#
"""
Cross-file consistency check for Tizen workload metadata.

Validates that the following stay in sync:

  workload/build/Versions.props                 (the SSOT for version values)
  workload/build/Samsung.Tizen.Sdk.proj         (ReplaceFileContents driver)
  workload/build/Samsung.NET.Sdk.Tizen.proj     (ReplaceFileContents driver)
  workload/src/Samsung.Tizen.Sdk/targets/Samsung.Tizen.Sdk.Versions.targets.in
  workload/src/Samsung.NET.Sdk.Tizen/WorkloadManifest.in.json
  workload/scripts/test-matrix.sh

Checks:
  C1  Versions.targets.in sigils all have matching Versions.props property
      AND a matching Replacements entry in Samsung.Tizen.Sdk.proj.
  C2  WorkloadManifest.in.json sigils all have matching property / Replacements
      in Samsung.NET.Sdk.Tizen.proj.
  C3  TizenSdkSupportedTargetPlatformVersion ↔ KnownFrameworkReference
      consistency in Versions.targets.in.
  C4  test-matrix.sh MATRIX uses only supported platforms.

Run from anywhere — paths derive from this script's location.

Exit codes:
  0 - all checks pass (warnings still allowed)
  1 - one or more failed checks
"""
from __future__ import annotations
import re
import sys
from pathlib import Path

WORKLOAD_DIR = Path(__file__).resolve().parents[1]


def read(rel: str) -> str:
    return (WORKLOAD_DIR / rel).read_text(encoding="utf-8")


def parse_props(text: str) -> dict:
    return dict(re.findall(r"<(\w+)>([^<]+)</\1>", text))


def parse_replacements(text: str) -> dict:
    m = re.search(r'Replacements="([^"]+)"', text)
    if not m:
        return {}
    out = {}
    for kvp in m.group(1).split(";"):
        kvp = kvp.strip()
        if not kvp or "=" not in kvp:
            continue
        k, v = kvp.split("=", 1)
        out[k] = v
    return out


def sigils(text: str) -> list:
    return sorted(set(re.findall(r"@(\w+)@", text)))


def main() -> int:
    errors = []
    notes = []

    def err(msg):
        errors.append(msg)
        print("[FAIL] " + msg)

    def ok(msg):
        print("[ OK ] " + msg)

    def warn(msg):
        notes.append(msg)
        print("[WARN] " + msg)

    props = parse_props(read("build/Versions.props"))
    sdk_proj = read("build/Samsung.Tizen.Sdk.proj")
    manifest_proj = read("build/Samsung.NET.Sdk.Tizen.proj")
    versions_in = read("src/Samsung.Tizen.Sdk/targets/Samsung.Tizen.Sdk.Versions.targets.in")
    workload_in = read("src/Samsung.NET.Sdk.Tizen/WorkloadManifest.in.json")
    matrix_sh = read("scripts/test-matrix.sh")

    sdk_repl = parse_replacements(sdk_proj)
    manifest_repl = parse_replacements(manifest_proj)

    # --- C1 ---
    vt_sigils = sigils(versions_in)
    c1_ok = True
    for s in vt_sigils:
        key = "@" + s + "@"
        if s not in props:
            err("C1: Versions.targets.in " + key + " has no property in Versions.props")
            c1_ok = False
        if key not in sdk_repl:
            err("C1: Samsung.Tizen.Sdk.proj missing Replacements entry for " + key)
            c1_ok = False
        elif sdk_repl[key] != "$(" + s + ")":
            err("C1: Samsung.Tizen.Sdk.proj Replacements[" + key + "] = " + repr(sdk_repl[key]) + ", expected '$(" + s + ")'")
            c1_ok = False
    if c1_ok:
        ok("C1: Versions.targets.in sigils (" + str(len(vt_sigils)) + ") all resolved")

    # --- C2 ---
    wm_sigils = sigils(workload_in)
    # @TIZEN_WORKLOAD_VERSION@ is special: injected via TizenPackVersion at pack time,
    # see Samsung.NET.Sdk.Tizen.proj and the Makefile.
    special = {"TIZEN_WORKLOAD_VERSION"}
    c2_ok = True
    for s in wm_sigils:
        if s in special:
            if "TizenWorkloadVersion" not in props:
                err("C2: WorkloadManifest.in.json uses @TIZEN_WORKLOAD_VERSION@ but Versions.props has no <TizenWorkloadVersion>")
                c2_ok = False
            continue
        key = "@" + s + "@"
        if s not in props:
            err("C2: WorkloadManifest.in.json " + key + " has no property in Versions.props")
            c2_ok = False
        if key not in manifest_repl:
            err("C2: Samsung.NET.Sdk.Tizen.proj missing Replacements entry for " + key)
            c2_ok = False
    if c2_ok:
        ok("C2: WorkloadManifest.in.json sigils (" + str(len(wm_sigils)) + ") all resolved")

    # --- C3 ---
    supported = re.findall(r'<TizenSdkSupportedTargetPlatformVersion Include="([^"]+)"', versions_in)
    fr_conditions = re.findall(r"TargetPlatformVersion\)'\s*==\s*'([^']+)'", versions_in)
    supported_set = set(supported)
    fr_set = set(fr_conditions)
    missing_fr = supported_set - fr_set
    extra_fr = fr_set - supported_set
    if extra_fr:
        # KFR pointing at a platform the SDK doesn't claim to support is a clear bug.
        err("C3: KnownFrameworkReference exists for " + str(sorted(extra_fr)) +
            " but not in TizenSdkSupportedTargetPlatformVersion")
    if missing_fr:
        # Reverse direction is ambiguous: the platform might be supported via external
        # OSS NuGet refs (no KFR needed in the SDK itself). Warn, don't fail.
        warn("C3: TizenSdkSupportedTargetPlatformVersion declares " + str(sorted(missing_fr)) +
             " but no KnownFrameworkReference — confirm intent (platform-only?) " +
             "or add a KnownFrameworkReference.")
    if not missing_fr and not extra_fr:
        ok("C3: SupportedTargetPlatformVersion (" + str(len(supported_set)) + ") ↔ KnownFrameworkReference: 1:1")

    # --- C4 ---
    matrix_entries = re.findall(r'"(net\d+(?:\.\d+)?-tizen[\d.]+)\|(\d+(?:\.\d+)?)"', matrix_sh)
    unknown_plats = set()
    for tfm, _api in matrix_entries:
        plat = tfm.split("-tizen", 1)[1]
        if plat not in supported_set:
            unknown_plats.add(plat)
    if not matrix_entries:
        warn("C4: test-matrix.sh MATRIX appears empty or unparseable")
    elif unknown_plats:
        err("C4: test-matrix.sh uses unsupported platform(s): " + str(sorted(unknown_plats)))
    else:
        ok("C4: test-matrix.sh (" + str(len(matrix_entries)) + " rows) all platforms supported")

    print()
    if errors:
        print("==== " + str(len(errors)) + " ERROR(S) ====")
        for e in errors:
            print("  - " + e)
        return 1
    print("==== all metadata consistency checks passed ====")
    if notes:
        print("(" + str(len(notes)) + " warning(s))")
    return 0


if __name__ == "__main__":
    sys.exit(main())
