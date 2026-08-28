#!/bin/bash
#
# Copyright (c) Samsung Electronics. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#
# Build the 'tizen' template across all officially supported (TFM, api-version) combinations
# and assert each build succeeds.
#
# Run after `make install` (workload installed into $(DOTNET_DESTDIR)).
# Can be invoked directly:
#   $ bash workload/scripts/test-matrix.sh
# Or via the workload Makefile:
#   $ make -C workload test-matrix
#
# Environment overrides:
#   DOTNET            path to the dotnet command (default: dotnet from PATH)
#   TEST_MATRIX_TMP   scratch directory (default: <workload>/.tmp/matrix)
#   TEST_MATRIX_ONLY  limit to a single TFM, e.g. "net8.0-tizen11.0"
#

set -euo pipefail

WORKLOAD_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DOTNET="${DOTNET:-dotnet}"
TMPDIR="${TEST_MATRIX_TMP:-$WORKLOAD_DIR/.tmp/matrix}"
ONLY="${TEST_MATRIX_ONLY:-}"
SELF_TEST=""

for arg in "$@"; do
    case "$arg" in
        --self-test) SELF_TEST="1" ;;
        *) echo "Unknown argument '$arg'"; exit 2 ;;
    esac
done

# Matrix rows: "<TargetFramework>|<api-version>"
#
# Keep in sync with TizenSdkSupportedTargetPlatformVersion / KnownFrameworkReference
# in workload/src/Samsung.Tizen.Sdk/targets/Samsung.Tizen.Sdk.Versions.targets.
#
# NOTE on net6.0-tizen{8,9}.0:
#   These TFMs are still officially supported by the workload, but the current
#   `dotnet new tizen` template targets the Tizen.UI era (Tizen.UI.Components.Material)
#   while net6.0-tizen8.0/9.0 belong to the older NUI-based template family.
#   A single shared fixture can't build both eras, so they are excluded here.
#   Add coverage in a follow-up by introducing a separate legacy fixture
#   (e.g. workload/scripts/fixtures/legacy/) keyed off the row's TFM.
#
# NOTE on net11.0-*:
#   .NET 11 is a preview SDK band. A row is SKIPPED (not failed) when the dotnet
#   under test cannot build that .NET major, so the default `make test-matrix`
#   run against the .NET 10 band stays green. To exercise these rows:
#       make test-matrix DOTNET_VERSION=11.0.100-preview.7.26381.103
MATRIX=(
    # net8.0: oldest .NET major still exercised, across every current platform band.
    "net8.0-tizen10.0|10"
    "net8.0-tizen10.1|10.1"
    "net8.0-tizen11.0|11"
    # net9.0
    "net9.0-tizen10.0|10"
    # net10.0: the current shipping band. Covered explicitly rather than implied by the
    # SDK version used to run the matrix.
    "net10.0-tizen10.0|10"
    "net10.0-tizen10.1|10.1"
    "net10.0-tizen11.0|11"
    # net11.0: the band this branch adds.
    "net11.0-tizen10.0|10"
    "net11.0-tizen11.0|11"
)

# --- helpers ---------------------------------------------------------------

c_reset=$'\033[0m'; c_red=$'\033[31m'; c_green=$'\033[32m'; c_yellow=$'\033[33m'
[[ -t 1 ]] || { c_reset=""; c_red=""; c_green=""; c_yellow=""; }

log()    { printf "%s\n" "$*"; }
pass()   { printf "  %sPASS%s  %s\n" "$c_green" "$c_reset" "$*"; }
fail()   { printf "  %sFAIL%s  %s\n" "$c_red"   "$c_reset" "$*"; }
warn()   { printf "  %sWARN%s  %s\n" "$c_yellow" "$c_reset" "$*"; }
skip()   { printf "  %sSKIP%s  %s\n" "$c_yellow" "$c_reset" "$*"; }

# Newest .NET SDK major visible to $DOTNET, e.g. "11".
# Populated once, after the $DOTNET prerequisite check below.
LATEST_SDK_MAJOR=""

# sdk_can_target <netver>   e.g. sdk_can_target net11.0
# An SDK can build any TFM up to and including its own major (the .NET 10 SDK builds
# net8.0/net9.0/net10.0 fine), so a row is only unbuildable when its .NET major is
# NEWER than the newest installed SDK. Returns non-zero in that case so the row is
# skipped rather than reported as a failure.
sdk_can_target() {
    local netver="$1"
    local want="${netver#net}"; want="${want%%.*}"
    [[ -n "$LATEST_SDK_MAJOR" ]] || return 0
    [[ "$want" -le "$LATEST_SDK_MAJOR" ]]
}

# --- prerequisites ---------------------------------------------------------

# --self-test exercises the row-selection logic without any dotnet install, so CI can
# pin it in the cheap metadata job. A regression here is expensive but silent: an
# over-strict check makes every row "skip", and the matrix reports success having
# built nothing.
if [[ -n "$SELF_TEST" ]]; then
    st_pass=0; st_fail=0
    # "<newest installed SDK major>|<row TFM>|<expected: run|skip>"
    #
    # An SDK builds its own major and every earlier one, so only rows NEWER than the
    # installed SDK may be skipped.
    for c in \
        "10|net8.0-tizen10.0|run"  "10|net9.0-tizen10.0|run"  "10|net10.0-tizen11.0|run" \
        "10|net11.0-tizen11.0|skip" "10|net12.0-tizen11.0|skip" \
        "11|net8.0-tizen10.0|run"  "11|net9.0-tizen10.0|run"  "11|net11.0-tizen11.0|run" \
        "11|net12.0-tizen11.0|skip" \
        "9|net8.0-tizen10.0|run"   "9|net10.0-tizen10.0|skip"
    do
        IFS='|' read -r major tfm want <<< "$c"
        LATEST_SDK_MAJOR="$major"
        netver="${tfm%-tizen*}"
        if sdk_can_target "$netver"; then got="run"; else got="skip"; fi
        if [[ "$got" == "$want" ]]; then
            printf "  %sPASS%s  sdk=%-3s %-22s -> %s\n" "$c_green" "$c_reset" "$major.x" "$tfm" "$got"
            st_pass=$((st_pass + 1))
        else
            printf "  %sFAIL%s  sdk=%-3s %-22s -> %s (expected %s)\n" "$c_red" "$c_reset" "$major.x" "$tfm" "$got" "$want"
            st_fail=$((st_fail + 1))
        fi
    done
    echo ""
    echo "============ test-matrix self-test summary ============"
    echo "  passed: $st_pass"
    echo "  failed: $st_fail"
    [[ $st_fail -eq 0 ]] || exit 1
    exit 0
fi

if ! command -v "$DOTNET" >/dev/null 2>&1; then
    log "ERROR: '$DOTNET' command not found."
    log "  Run 'make install' first to bootstrap dotnet under workload/out/dotnet,"
    log "  then re-invoke as: DOTNET=workload/out/dotnet/dotnet bash workload/scripts/test-matrix.sh"
    exit 2
fi

# Verify the 'tizen' workload manifest is reachable to this dotnet.
if ! "$DOTNET" workload list 2>/dev/null | grep -qi '^tizen'; then
    warn "'tizen' workload not detected via '$DOTNET workload list'."
    warn "Run 'make install' first; this script does not install the workload itself."
fi

mkdir -p "$TMPDIR"

# Discover the newest .NET major this dotnet can build for.
LATEST_SDK_MAJOR="$("$DOTNET" --list-sdks 2>/dev/null | sed -E 's/^([0-9]+)\..*/\1/' | sort -un | tail -1)"
log "Newest .NET SDK major: ${LATEST_SDK_MAJOR:-<none detected>}"

# --- matrix loop -----------------------------------------------------------

declare -i pass_count=0 fail_count=0 skip_count=0
declare -a failed_rows=()
declare -a skipped_rows=()

for entry in "${MATRIX[@]}"; do
    tfm="${entry%%|*}"
    apiver="${entry##*|}"

    if [[ -n "$ONLY" && "$ONLY" != "$tfm" ]]; then
        continue
    fi

    netver="${tfm%-tizen*}"      # net6.0 / net8.0 / net9.0 / net11.0
    platver="${tfm##*-tizen}"    # 8.0 / 9.0 / 10.0 / 10.1 / 11.0
    rowdir="$TMPDIR/$tfm"

    log ""
    log "==> [$tfm] api-version=$apiver"

    if ! sdk_can_target "$netver"; then
        skip "$tfm  (needs a ${netver#net}+ SDK; newest installed is ${LATEST_SDK_MAJOR}.x)"
        skip_count+=1
        skipped_rows+=("$tfm")
        continue
    fi

    rm -rf "$rowdir"
    mkdir -p "$rowdir"

    # 1. Generate template project with chosen .NET version.
    #    template.json's 'framework' parameter replaces the literal 'net10.0' in csproj.
    #    --name TizenApp1 keeps the sourceName fixed; otherwise the output directory
    #    name (e.g. 'net6.0-tizen8.0') would replace it, producing an invalid C#
    #    identifier and a renamed .csproj.
    if ! "$DOTNET" new tizen --framework "$netver" --name TizenApp1 --output "$rowdir" \
            > "$rowdir/dotnet-new.log" 2>&1; then
        fail "$tfm  (dotnet new failed)"
        tail -20 "$rowdir/dotnet-new.log" | sed 's/^/      | /'
        fail_count+=1
        failed_rows+=("$tfm:new")
        continue
    fi

    # 2. Rewrite csproj '-tizen10.0' (template default) to '-tizen<platver>'.
    #    The template only parameterises the .NET version, not the Tizen platform version.
    csproj="$rowdir/TizenApp1.csproj"
    sed -i.bak -E "s|-tizen10\\.0|-tizen${platver}|g" "$csproj" && rm -f "$csproj.bak"

    # 3. Rewrite tizen-manifest.xml api-version to match the platform.
    manifest="$rowdir/tizen-manifest.xml"
    sed -i.bak -E "s|api-version=\"10\"|api-version=\"${apiver}\"|g" "$manifest" \
        && rm -f "$manifest.bak"

    # Sanity: confirm rewrites landed.
    if ! grep -q "<TargetFramework>${tfm}</TargetFramework>" "$csproj"; then
        fail "$tfm  (csproj TargetFramework rewrite failed)"
        grep TargetFramework "$csproj" | sed 's/^/      | /'
        fail_count+=1
        failed_rows+=("$tfm:csproj-rewrite")
        continue
    fi
    if ! grep -q "api-version=\"${apiver}\"" "$manifest"; then
        fail "$tfm  (tizen-manifest.xml api-version rewrite failed)"
        fail_count+=1
        failed_rows+=("$tfm:manifest-rewrite")
        continue
    fi

    # 4. Build.
    if "$DOTNET" build "$rowdir" --nologo > "$rowdir/build.log" 2>&1; then
        # Optional sanity: produced assembly exists somewhere under bin/.
        # Use find (not bash globstar — requires shopt that we don't set).
        if [[ -n "$(find "$rowdir/bin" -name TizenApp1.dll -print -quit 2>/dev/null)" ]]; then
            pass "$tfm"
        else
            warn "$tfm  (build succeeded but TizenApp1.dll not found under bin/)"
        fi
        pass_count+=1
    else
        fail "$tfm  (build failed - see $rowdir/build.log)"
        tail -25 "$rowdir/build.log" | sed 's/^/      | /'
        fail_count+=1
        failed_rows+=("$tfm:build")
    fi
done

# --- self-contained disposition --------------------------------------------
#
# Samsung.NETCore.App.Runtime.tizen is a placeholder pack with no runtime binaries, so a
# self-contained Tizen publish cannot work. It must fail with the actionable TIZENSDK001
# rather than a raw XmlException from ResolveRuntimePackAssets parsing RuntimeList.xml,
# or an opaque NETSDK1083.
if [[ -z "$ONLY" && $pass_count -gt 0 ]]; then
    sc_dir="$TMPDIR/selfcontained"
    log ""
    log "==> [self-contained disposition]"
    rm -rf "$sc_dir" && mkdir -p "$sc_dir"
    # Reuse whichever row built successfully; any Tizen project will do.
    src_row="$(find "$TMPDIR" -maxdepth 1 -name 'net*-tizen*' -type d | head -1)"
    if [[ -z "$src_row" ]]; then
        fail "self-contained disposition could not run (no built row to reuse)"
        fail_count+=1
        failed_rows+=("selfcontained:no-fixture")
    else
        cp "$src_row/TizenApp1.csproj" "$src_row/tizen-manifest.xml" "$sc_dir/" 2>/dev/null
        cp -r "$src_row"/*.cs "$sc_dir/" 2>/dev/null
        sc_log="$sc_dir/selfcontained.log"
        if "$DOTNET" build "$sc_dir" --nologo -p:SelfContained=true > "$sc_log" 2>&1; then
            fail "self-contained build unexpectedly SUCCEEDED (no runtime is shipped)"
            fail_count+=1
            failed_rows+=("selfcontained:unexpected-success")
        elif grep -q "TIZENSDK001" "$sc_log"; then
            pass "self-contained rejected with TIZENSDK001"
            pass_count+=1
        elif grep -qiE "XmlException|multiple root" "$sc_log"; then
            fail "self-contained produced a raw XML parse error - RuntimeList.xml is malformed"
            grep -iE "XmlException|multiple root" "$sc_log" | head -2 | sed 's/^/      | /'
            fail_count+=1
            failed_rows+=("selfcontained:xmlexception")
        else
            # Any other diagnostic is a FAILURE, not a warning. Self-contained has exactly one
            # supported outcome; NETSDK1083 or anything else means the guard did not fire and
            # the user gets an unactionable error.
            fail "self-contained produced an unexpected diagnostic (expected TIZENSDK001)"
            grep -m3 "error" "$sc_log" | sed 's/^/      | /'
            fail_count+=1
            failed_rows+=("selfcontained:unexpected-diagnostic")
        fi
    fi
fi

# --- summary ---------------------------------------------------------------

log ""
log "================ test-matrix summary ================"
log "  passed:  $pass_count"
log "  failed:  $fail_count"
log "  skipped: $skip_count"

if [[ $skip_count -gt 0 ]]; then
    log "  skipped rows:"
    for r in "${skipped_rows[@]}"; do
        log "    - $r"
    done
fi

if [[ $fail_count -gt 0 ]]; then
    log "  failed rows:"
    for r in "${failed_rows[@]}"; do
        log "    - $r"
    done
    exit 1
fi

exit 0
