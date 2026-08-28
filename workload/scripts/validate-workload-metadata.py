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
  workload/src/Samsung.Tizen.Sdk/targets/Samsung.Tizen.Sdk.targets
  workload/src/Samsung.NETCore.App.Runtime/data/RuntimeList.xml
  workload/src/Samsung.Tizen.Templates/tizen/.template.config/template.json

Checks:
  C1  Versions.targets.in sigils all have matching Versions.props property
      AND a matching Replacements entry in Samsung.Tizen.Sdk.proj.
  C2  WorkloadManifest.in.json sigils all have matching property / Replacements
      in Samsung.NET.Sdk.Tizen.proj.
  C3  TizenSdkSupportedTargetPlatformVersion ↔ KnownFrameworkReference
      consistency in Versions.targets.in.
  C4  test-matrix.sh MATRIX uses only supported platforms.
  C5  Every .NET major offered by the template / exercised by test-matrix.sh has a
      matching KnownRuntimePack in Samsung.Tizen.Sdk.targets. Without it the SDK
      cannot resolve Samsung.NETCore.App.Runtime.tizen and the build fails with
      NETSDK1082 ("no runtime pack available").
  C6  RuntimeList.xml is well-formed XML with a single <FileList> root. It is parsed by
      ResolveRuntimePackAssets (e.g. for SelfContained=true), so multiple roots throw a
      raw XmlException. The pack ships no runtime binaries, so the list is empty and
      self-contained publishing is rejected by TIZENSDK001 instead.
  C7  DotNet11SdkVersion exists in Versions.props and no workflow hardcodes a
      different .NET 11 SDK version (the workflows must grep the SSOT).
  C8  The PackageTargetFallback candidate list covers every (.NET major from
      KnownRuntimePack) x (platform from TizenSdkSupportedTargetPlatformVersion)
      combination, and every candidate is emitted with a compatibility Condition.
      A missing entry silently downgrades a package to its netstandard2.x assets;
      an unconditional entry lets an incompatible TFM's assets be substituted.

Run from anywhere — paths derive from this script's location.

Exit codes:
  0 - all checks pass (warnings still allowed)
  1 - one or more failed checks
"""
from __future__ import annotations
import re
import sys
import xml.etree.ElementTree as ET
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
    sdk_targets = read("src/Samsung.Tizen.Sdk/targets/Samsung.Tizen.Sdk.targets")
    runtime_list = read("src/Samsung.NETCore.App.Runtime/data/RuntimeList.xml")
    template_json = read("src/Samsung.Tizen.Templates/tizen/.template.config/template.json")

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

    # --- C5 ---
    # KnownRuntimePack is keyed by the .NET major TFM (net8.0, net10.0, ...).
    # A TFM the template can produce but the SDK has no runtime pack for fails at
    # build time, so both producers of TFMs must be covered.
    krp_tfms = set(
        re.findall(r'<KnownRuntimePack\b[^>]*?\n?[^>]*?TargetFramework="(net[\d.]+)"', sdk_targets)
    )
    if not krp_tfms:
        # Attribute order/newlines vary; fall back to a per-element scan.
        for block in re.findall(r"<KnownRuntimePack\b.*?/>", sdk_targets, re.S):
            m = re.search(r'TargetFramework="(net[\d.]+)"', block)
            if m:
                krp_tfms.add(m.group(1))

    template_netvers = set(re.findall(r'"choice":\s*"(net[\d.]+)"', template_json))
    matrix_netvers = {tfm.split("-tizen", 1)[0] for tfm, _api in matrix_entries}
    required_netvers = template_netvers | matrix_netvers

    missing_krp = sorted(required_netvers - krp_tfms, key=lambda v: float(v[3:]))
    if not krp_tfms:
        err("C5: no KnownRuntimePack entries parsed from Samsung.Tizen.Sdk.targets")
    elif missing_krp:
        err("C5: no KnownRuntimePack for " + str(missing_krp) +
            " (offered by template.json / test-matrix.sh). Add a KnownRuntimePack "
            "entry in Samsung.Tizen.Sdk.targets or the build fails with NETSDK1082.")
    else:
        ok("C5: template/test-matrix .NET majors (" + str(len(required_netvers)) +
           ") all have a KnownRuntimePack")

    # --- C6 ---
    rl_path = WORKLOAD_DIR / "src/Samsung.NETCore.App.Runtime/data/RuntimeList.xml"
    c6_ok = True
    try:
        rl_root = ET.parse(rl_path).getroot()
    except ET.ParseError as exc:
        err("C6: RuntimeList.xml is not well-formed XML (" + str(exc) + "). "
            "ResolveRuntimePackAssets parses this file - e.g. for SelfContained=true - and "
            "multiple roots surface as a raw XmlException.")
        rl_root = None
        c6_ok = False
    if rl_root is not None:
        if rl_root.tag != "FileList":
            err("C6: RuntimeList.xml root is <" + rl_root.tag + ">, expected <FileList>")
            c6_ok = False
        # The pack is a placeholder with no runtime binaries. If files ever appear here,
        # the self-contained rejection below needs revisiting.
        files = rl_root.findall("File")
        sdk_targets_txt = read("src/Samsung.Tizen.Sdk/targets/Samsung.Tizen.Sdk.targets")
        has_guard = "TIZENSDK001" in sdk_targets_txt
        if not files and not has_guard:
            err("C6: RuntimeList.xml lists no runtime files, but Samsung.Tizen.Sdk.targets has "
                "no TIZENSDK001 self-contained guard. A self-contained publish would emit an "
                "app with no runtime.")
            c6_ok = False
        if c6_ok:
            ok("C6: RuntimeList.xml well-formed (single <FileList> root, " + str(len(files)) +
               " file(s)); self-contained guarded by TIZENSDK001")

    # --- C7 ---
    net11_sdk = props.get("DotNet11SdkVersion", "")
    if not net11_sdk:
        err("C7: <DotNet11SdkVersion> missing from Versions.props; CI resolves the .NET 11 "
            "SDK by grepping it")
    else:
        workflow_dir = WORKLOAD_DIR.parent / ".github" / "workflows"
        stray = []
        for wf in sorted(workflow_dir.glob("*.yml")):
            # Strip comments: prose may legitimately mention a band or an example
            # version. Only real values can cause CI to use the wrong SDK.
            lines = []
            for line in wf.read_text(encoding="utf-8").splitlines():
                stripped = line.lstrip()
                if stripped.startswith("#"):
                    continue
                lines.append(line.split(" #", 1)[0])
            text = "\n".join(lines)
            for literal in set(re.findall(r"\b11\.0\.\d{3}-[A-Za-z0-9]+(?:\.[A-Za-z0-9]+)*", text)):
                if literal.rstrip(".") != net11_sdk:
                    stray.append(wf.name + ": " + literal)
        if stray:
            err("C7: workflow(s) hardcode a .NET 11 SDK version differing from "
                "DotNet11SdkVersion (" + net11_sdk + "): " + str(sorted(stray)))
        else:
            ok("C7: DotNet11SdkVersion = " + net11_sdk + "; no conflicting workflow literals")

    # --- C8 ---
    nuget_targets = read("src/Samsung.Tizen.Sdk/targets/Samsung.Tizen.Sdk.NuGet.targets")
    # Each candidate is a conditional _TizenFallbackList append. Capture the appended TFM
    # and whether the line carries a compatibility Condition.
    cand_lines = re.findall(
        r'<_TizenFallbackList(\s+Condition="[^"]*")?>\$\(_TizenFallbackList\);([^<]+)</_TizenFallbackList>',
        nuget_targets)
    if not cand_lines:
        err("C8: no _TizenFallbackList candidates found in Samsung.Tizen.Sdk.NuGet.targets")
    elif not krp_tfms or not supported_set:
        err("C8: cannot evaluate - KnownRuntimePack or supported platform list empty")
    else:
        listed = {tfm.strip() for _cond, tfm in cand_lines}
        unconditional = sorted(tfm.strip() for cond, tfm in cand_lines if not cond)
        expected = {m + "-tizen" + p for m in krp_tfms for p in supported_set}
        missing_ptf = sorted(expected - listed)
        c8_ok = True
        if missing_ptf:
            err("C8: PackageTargetFallback missing " + str(missing_ptf) +
                ". A package shipping lib/<tfm>/ alongside netstandard2.x would silently "
                "resolve to the netstandard assets for those TFMs.")
            c8_ok = False
        if unconditional:
            err("C8: PackageTargetFallback candidate(s) " + str(unconditional) +
                " have no compatibility Condition. FixupNuGetReferences matches by name "
                "only, so an unconditional entry lets an incompatible TFM's assets be "
                "substituted (e.g. net6.0-tizen11.0 into a net6.0-tizen8.0 build).")
            c8_ok = False
        if c8_ok:
            ok("C8: PackageTargetFallback covers all " + str(len(expected)) +
               " supported (.NET major x platform) combinations; all " +
               str(len(cand_lines)) + " candidates are compatibility-gated")

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
