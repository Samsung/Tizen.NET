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
MATRIX=(
    "net8.0-tizen10.0|10"
    "net8.0-tizen11.0|11"
    "net9.0-tizen10.0|10"
)

# --- helpers ---------------------------------------------------------------

c_reset=$'\033[0m'; c_red=$'\033[31m'; c_green=$'\033[32m'; c_yellow=$'\033[33m'
[[ -t 1 ]] || { c_reset=""; c_red=""; c_green=""; c_yellow=""; }

log()    { printf "%s\n" "$*"; }
pass()   { printf "  %sPASS%s  %s\n" "$c_green" "$c_reset" "$*"; }
fail()   { printf "  %sFAIL%s  %s\n" "$c_red"   "$c_reset" "$*"; }
warn()   { printf "  %sWARN%s  %s\n" "$c_yellow" "$c_reset" "$*"; }

# --- prerequisites ---------------------------------------------------------

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

# --- matrix loop -----------------------------------------------------------

declare -i pass_count=0 fail_count=0
declare -a failed_rows=()

for entry in "${MATRIX[@]}"; do
    tfm="${entry%%|*}"
    apiver="${entry##*|}"

    if [[ -n "$ONLY" && "$ONLY" != "$tfm" ]]; then
        continue
    fi

    netver="${tfm%-tizen*}"      # net6.0 / net8.0 / net9.0
    platver="${tfm##*-tizen}"    # 8.0 / 9.0 / 10.0 / 11.0
    rowdir="$TMPDIR/$tfm"

    log ""
    log "==> [$tfm] api-version=$apiver"

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

# --- summary ---------------------------------------------------------------

log ""
log "================ test-matrix summary ================"
log "  passed:  $pass_count"
log "  failed:  $fail_count"

if [[ $fail_count -gt 0 ]]; then
    log "  failed rows:"
    for r in "${failed_rows[@]}"; do
        log "    - $r"
    done
    exit 1
fi

exit 0
