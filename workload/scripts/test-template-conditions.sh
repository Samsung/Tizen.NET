#!/bin/bash
#
# Copyright (c) Samsung Electronics. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#
# Evaluation regression tests for Tizen MSBuild conditions. Two independent suites run here,
# both against real shipped files (extracted, never duplicated, so they cannot drift), and
# both without the Tizen workload — so they run in the metadata CI job.
#
# Suite 1 — template platform-version detection:
#   The template conditions its Tizen.UI.Components.Material PackageReference on the Tizen
#   platform band. PackageReference items are evaluated with the project body, which runs
#   BEFORE the .NET SDK infers $(TargetPlatformVersion) from the TFM — so the detection must
#   parse $(TargetFramework) itself. Reading $(TargetPlatformVersion) in the body silently
#   yields an empty string and falls back to the default, which wrongly pulls Material into
#   e.g. net11.0-tizen9.0 and suppresses TIZENTMPL001. Extracted from the shipped template
#   csproj between the BEGIN/END TIZEN UI PLATFORM DETECTION markers.
#
# Suite 2 — the _TizenErrorOnSelfContained (TIZENSDK001) self-contained guard:
#   Samsung.NETCore.App.Runtime.tizen is a placeholder runtime pack with no runtime binaries,
#   so a self-contained Tizen publish cannot work and the guard errors with TIZENSDK001. The
#   guard must fire ONLY when self-contained was *explicitly* requested. The trap: the .NET SDK
#   still infers SelfContained=true from a present RuntimeIdentifier on pre-8.0 TFMs
#   (Microsoft.NET.RuntimeIdentifierInference.targets), and the Tizen SDK supplies an implicit
#   RID for MAUI apps — so an ordinary framework-dependent net6.0-tizen / net7.0-tizen build
#   has SelfContained inferred to 'true'. Gating on the SDK's own _SelfContainedWasSpecified
#   (set only for an explicit request) instead of the inferred $(SelfContained) is what keeps
#   those builds working. This suite extracts the real guard <Target> from the shipped
#   Samsung.Tizen.Sdk.targets, embeds it in an SDK-style probe (so the SDK parses the -tizen TFM
#   to TargetPlatformIdentifier=tizen and runs the identical RID/SelfContained inference), and
#   invokes the guard target directly to assert TIZENSDK001 fires exactly when it should.
#
# Usage:
#   bash workload/scripts/test-template-conditions.sh
#   make -C workload test-template-conditions
#
# Environment overrides:
#   DOTNET   path to the dotnet command (default: dotnet from PATH)
#

set -uo pipefail

WORKLOAD_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CSPROJ="$WORKLOAD_DIR/src/Samsung.Tizen.Templates/tizen/TizenApp1.csproj"
SDK_TARGETS="$WORKLOAD_DIR/src/Samsung.Tizen.Sdk/targets/Samsung.Tizen.Sdk.targets"
DOTNET="${DOTNET:-dotnet}"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

c_reset=$'\033[0m'; c_red=$'\033[31m'; c_green=$'\033[32m'; c_yellow=$'\033[33m'
[[ -t 1 ]] || { c_reset=""; c_red=""; c_green=""; c_yellow=""; }

if ! command -v "$DOTNET" >/dev/null 2>&1; then
    echo "  ${c_yellow}SKIP${c_reset}  '$DOTNET' not found; cannot evaluate MSBuild expressions."
    exit 0
fi

if [[ ! -f "$CSPROJ" ]]; then
    echo "ERROR: template csproj not found at $CSPROJ"
    exit 2
fi

DETECTION="$(sed -n '/BEGIN TIZEN UI PLATFORM DETECTION/,/END TIZEN UI PLATFORM DETECTION/p' "$CSPROJ" \
             | sed -n '/<PropertyGroup>/,/<\/PropertyGroup>/p')"

if [[ -z "$DETECTION" ]]; then
    echo "ERROR: TIZEN UI PLATFORM DETECTION markers (or the PropertyGroup between them)"
    echo "       not found in $CSPROJ. Keep the markers intact so this test stays honest."
    exit 2
fi

# Build a probe project containing the extracted PropertyGroup verbatim.
{
    echo '<Project>'
    echo "$DETECTION"
    echo '  <Target Name="Probe">'
    echo '    <Message Importance="high" Text="RESULT|$(_TizenUIPlatformVersion)|$(_TizenUIMaterialSupported)" />'
    echo '  </Target>'
    echo '</Project>'
} > "$TMPDIR/probe.proj"

# Cases: "<TargetFramework>|<expected platform version>|<expected material supported>"
CASES=(
    # Below the Material floor: must NOT reference Material.
    "net11.0-tizen8.0|8.0|False"
    "net11.0-tizen9.0|9.0|False"
    "net10.0-tizen8.0|8.0|False"
    "net8.0-tizen9.0|9.0|False"
    # At or above the floor: Material is referenced.
    "net11.0-tizen10.0|10.0|True"
    "net11.0-tizen10.1|10.1|True"
    "net11.0-tizen11.0|11.0|True"
    "net10.0-tizen10.0|10.0|True"
    "net8.0-tizen11.0|11.0|True"
    # Unversioned / outer multi-targeting build: assume the SDK default (10.0).
    "net11.0-tizen|10.0|True"
    "net10.0-tizen|10.0|True"
    "|10.0|True"
    # A non-Tizen TFM must not be misparsed.
    "net10.0|10.0|True"
)

pass=0; fail=0

for case in "${CASES[@]}"; do
    IFS='|' read -r tfm want_ver want_mat <<< "$case"

    out="$("$DOTNET" msbuild "$TMPDIR/probe.proj" -t:Probe -nologo -v:m \
            -p:TargetFramework="$tfm" 2>&1 | grep -o 'RESULT|[^|]*|[^ ]*' | head -1)"
    got_ver="$(echo "$out" | cut -d'|' -f2)"
    got_mat="$(echo "$out" | cut -d'|' -f3)"

    label="${tfm:-<empty>}"
    if [[ "$got_ver" == "$want_ver" && "$got_mat" == "$want_mat" ]]; then
        printf "  %sPASS%s  %-22s -> platform=%-5s material=%s\n" \
            "$c_green" "$c_reset" "$label" "$got_ver" "$got_mat"
        pass=$((pass + 1))
    else
        printf "  %sFAIL%s  %-22s -> platform=%-5s material=%-5s (expected %s / %s)\n" \
            "$c_red" "$c_reset" "$label" "${got_ver:-?}" "${got_mat:-?}" "$want_ver" "$want_mat"
        fail=$((fail + 1))
    fi
done

# --------------------------------------------------------------------------------------------
# Suite 2 — self-contained guard (_TizenErrorOnSelfContained / TIZENSDK001).
#
# Extract the real guard <Target> from the shipped SDK targets (never duplicate it, so the test
# tracks whatever ships) and embed it in an SDK-style probe. Because the probe uses
# Sdk="Microsoft.NET.Sdk" and a -tizen TFM, the .NET SDK parses TargetPlatformIdentifier=tizen
# and runs the exact same RuntimeIdentifier -> SelfContained inference as a production build,
# with no Tizen workload required. Invoking the guard target directly evaluates its Condition
# against those SDK-inferred property values and emits TIZENSDK001 iff the guard would fire.
# --------------------------------------------------------------------------------------------

if [[ ! -f "$SDK_TARGETS" ]]; then
    echo "ERROR: SDK targets not found at $SDK_TARGETS"
    exit 2
fi

GUARD="$(sed -n '/<Target Name="_TizenErrorOnSelfContained"/,/<\/Target>/p' "$SDK_TARGETS")"

if [[ -z "$GUARD" ]]; then
    echo "ERROR: _TizenErrorOnSelfContained target not found in $SDK_TARGETS."
    echo "       Keep the target intact so this self-contained regression test stays honest."
    exit 2
fi

# EnableDefaultCompileItems=false keeps the probe from needing any source; OutputType=Exe makes
# HasRuntimeOutput true, which is the gate the SDK requires before it will infer SelfContained.
{
    echo '<Project Sdk="Microsoft.NET.Sdk">'
    echo '  <PropertyGroup>'
    echo '    <OutputType>Exe</OutputType>'
    echo '    <EnableDefaultCompileItems>false</EnableDefaultCompileItems>'
    echo '  </PropertyGroup>'
    echo "$GUARD"
    echo '</Project>'
} > "$TMPDIR/guard.csproj"

# Cases: "<label>|<expected: error|ok>|<extra -p args>"
#
# An implicit RID (tizen-x86, as the Tizen SDK sets for MAUI) is passed on the framework-
# dependent rows precisely to reproduce the SDK's SelfContained inference. net6.0/net7.0 infer
# SelfContained=true from that RID; the guard must still stay silent because self-contained was
# not explicitly requested (_SelfContainedWasSpecified is empty). An explicit request must error;
# the skip property must bypass; and PublishSelfContained during publish must still error (the
# SDK copies it onto SelfContained before computing _SelfContainedWasSpecified).
GUARD_CASES=(
    # Framework-dependent builds with the implicit RID present: must NOT error.
    "net6.0-tizen fwdep|ok|-p:TargetFramework=net6.0-tizen -p:RuntimeIdentifier=tizen-x86"
    "net7.0-tizen fwdep|ok|-p:TargetFramework=net7.0-tizen -p:RuntimeIdentifier=tizen-x86"
    "net8.0-tizen fwdep|ok|-p:TargetFramework=net8.0-tizen -p:RuntimeIdentifier=tizen-x86"
    "net11.0-tizen11.0 fwdep|ok|-p:TargetFramework=net11.0-tizen11.0 -p:RuntimeIdentifier=tizen-x86"
    # Explicitly requested self-contained: MUST error with TIZENSDK001.
    "net6.0-tizen SelfContained=true|error|-p:TargetFramework=net6.0-tizen -p:RuntimeIdentifier=tizen-x86 -p:SelfContained=true"
    "net11.0-tizen11.0 SelfContained=true|error|-p:TargetFramework=net11.0-tizen11.0 -p:RuntimeIdentifier=tizen-x86 -p:SelfContained=true"
    "net6.0-tizen publish --self-contained|error|-p:TargetFramework=net6.0-tizen -p:RuntimeIdentifier=tizen-x86 -p:PublishSelfContained=true -p:_IsPublishing=true"
    # Explicit self-contained but bypassed via the skip property: must NOT error.
    "net6.0-tizen SelfContained=true + Skip|ok|-p:TargetFramework=net6.0-tizen -p:RuntimeIdentifier=tizen-x86 -p:SelfContained=true -p:SkipTizenSelfContainedCheck=true"
    # Explicit SelfContained=false must never error even where a RID is present.
    "net6.0-tizen SelfContained=false|ok|-p:TargetFramework=net6.0-tizen -p:RuntimeIdentifier=tizen-x86 -p:SelfContained=false"
)

for case in "${GUARD_CASES[@]}"; do
    IFS='|' read -r label want args <<< "$case"

    # -nodereuse:false: MSBuild node reuse caches loaded task assemblies and project state across
    # invocations and has previously caused tests in this repo to silently validate stale state.
    out="$("$DOTNET" msbuild "$TMPDIR/guard.csproj" -t:_TizenErrorOnSelfContained \
            -nologo -v:m -nodereuse:false $args 2>&1)"
    if echo "$out" | grep -q 'TIZENSDK001'; then got="error"; else got="ok"; fi

    if [[ "$got" == "$want" ]]; then
        printf "  %sPASS%s  %-38s -> %s\n" "$c_green" "$c_reset" "$label" "$got"
        pass=$((pass + 1))
    else
        printf "  %sFAIL%s  %-38s -> %s (expected %s)\n" "$c_red" "$c_reset" "$label" "$got" "$want"
        echo "$out" | grep -iE 'error|TIZENSDK' | head -3 | sed 's/^/        | /'
        fail=$((fail + 1))
    fi
done

echo ""
echo "============ template-conditions summary ============"
echo "  passed: $pass"
echo "  failed: $fail"

[[ $fail -eq 0 ]] || exit 1
exit 0
