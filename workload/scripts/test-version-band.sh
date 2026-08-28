#!/bin/bash
#
# Copyright (c) Samsung Electronics. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#
# Unit test for the SDK feature-band detection used by the install scripts.
#
# The band string decides three things at install time:
#   * the NuGet package id     Samsung.NET.Sdk.Tizen.Manifest-<band>
#   * the manifest directory   <dotnet>/sdk-manifests/<band>/samsung.net.sdk.tizen
#   * the version-map key      $MANIFEST_BASE_NAME-<band>
# Getting it wrong silently installs the workload where the SDK will never look,
# so it is worth a real test — especially for new majors such as .NET 11 preview.
#
# The bash implementation is extracted from workload-install.sh between the
# "BEGIN/END VERSION BAND DETECTION" markers so the test always exercises the
# shipped code rather than a copy.
#
# Usage:
#   bash workload/scripts/test-version-band.sh
#   make -C workload test-version-band
#

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKLOAD_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SH_SCRIPT="$SCRIPT_DIR/workload-install.sh"
PS1_SCRIPT="$SCRIPT_DIR/workload-install.ps1"

c_reset=$'\033[0m'; c_red=$'\033[31m'; c_green=$'\033[32m'
[[ -t 1 ]] || { c_reset=""; c_red=""; c_green=""; }

# --- load the function under test ------------------------------------------

if [[ ! -f "$SH_SCRIPT" ]]; then
    echo "ERROR: $SH_SCRIPT not found."
    exit 2
fi

BAND_FUNC="$(sed -n '/# BEGIN VERSION BAND DETECTION/,/# END VERSION BAND DETECTION/p' "$SH_SCRIPT")"
if [[ -z "$BAND_FUNC" ]]; then
    echo "ERROR: VERSION BAND DETECTION markers not found in $SH_SCRIPT."
    echo "       The install script was edited without keeping the markers intact."
    exit 2
fi
eval "$BAND_FUNC"

# --- cases: "<sdk version>|<expected band>" --------------------------------
CASES=(
    # .NET 6 has no preview bands: always rounded to the feature band.
    "6.0.419|6.0.400"
    "6.0.100|6.0.100"
    # Stable bands.
    "7.0.400|7.0.400"
    "8.0.404|8.0.400"
    "9.0.304|9.0.300"
    "10.0.100|10.0.100"
    "10.0.400|10.0.400"
    # Pre-release bands.
    "7.0.100-preview.6.22352.1|7.0.100-preview.6"
    "8.0.100-rc.2.23502.2|8.0.100-rc.2"
    "8.0.100-rtm.23512.16|8.0.100-rtm"
    "9.0.100-alpha.1.23615.4|9.0.100-alpha.1"
    "10.0.100-rc.2.25502.107|10.0.100-rc.2"
    # .NET 11 — the band this repo now supports.
    "11.0.100-preview.7.26381.103|11.0.100-preview.7"
    "11.0.100-preview.6.26359.118|11.0.100-preview.6"
    "11.0.100-rc.1.26500.1|11.0.100-rc.1"
    "11.0.100|11.0.100"
    "11.0.200|11.0.200"
    # Future majors must keep working without another code change.
    "12.0.100-preview.1.27000.1|12.0.100-preview.1"
)

pass=0; fail=0

for case in "${CASES[@]}"; do
    version="${case%%|*}"
    expected="${case##*|}"
    actual="$(compute_target_version_band "$version")"
    if [[ "$actual" == "$expected" ]]; then
        printf "  %sPASS%s  %-32s -> %s\n" "$c_green" "$c_reset" "$version" "$actual"
        pass=$((pass + 1))
    else
        printf "  %sFAIL%s  %-32s -> %s (expected %s)\n" "$c_red" "$c_reset" "$version" "$actual" "$expected"
        fail=$((fail + 1))
    fi
done

# --- parity check: load the REAL PowerShell implementation -----------------
#
# The PS logic is extracted from workload-install.ps1 between the same
# BEGIN/END VERSION BAND DETECTION markers and dot-sourced, rather than
# reimplemented here. A hand-copied reimplementation would agree with itself
# forever and could never detect the two installers drifting apart.

if command -v pwsh >/dev/null 2>&1 && [[ -f "$PS1_SCRIPT" ]]; then
    echo ""
    echo "-- PowerShell parity (real Get-TargetVersionBand) --"

    ps_results="$(pwsh -NoProfile -Command "
        \$src = Get-Content -Raw '$PS1_SCRIPT'
        \$block = [regex]::Match(\$src, '(?s)# BEGIN VERSION BAND DETECTION.*?# END VERSION BAND DETECTION').Value
        if (-not \$block) { Write-Output 'EXTRACT_FAILED'; exit 1 }
        Invoke-Expression \$block
        foreach (\$v in @($(printf "'%s'," "${CASES[@]%%|*}" | sed 's/,$//'))) {
            Write-Output (\$v + '=' + (Get-TargetVersionBand -DotnetVersion \$v))
        }" 2>/dev/null | tr -d '\r')"

    if [[ "$ps_results" == *EXTRACT_FAILED* || -z "$ps_results" ]]; then
        printf "  %sFAIL%s  could not extract Get-TargetVersionBand from workload-install.ps1\n" "$c_red" "$c_reset"
        fail=$((fail + 1))
    else
        for case in "${CASES[@]}"; do
            version="${case%%|*}"
            expected="${case##*|}"
            actual="$(grep -F "$version=" <<< "$ps_results" | head -1 | cut -d'=' -f2-)"
            if [[ "$actual" == "$expected" ]]; then
                printf "  %sPASS%s  %-32s -> %s\n" "$c_green" "$c_reset" "$version" "$actual"
                pass=$((pass + 1))
            else
                printf "  %sFAIL%s  %-32s -> %s (expected %s)\n" "$c_red" "$c_reset" "$version" "${actual:-<none>}" "$expected"
                fail=$((fail + 1))
            fi
        done
    fi
else
    echo ""
    echo "  (pwsh not available - skipping workload-install.ps1 parity check)"
fi

# --- fallback family: an 11.x request must never resolve to a 10.x manifest ----
#
# The PowerShell fallback used a fixed-length prefix, so '...Manifest-11.0.100-preview.7'
# was truncated to '...Manifest-1' and matched the 10.x entries, installing a .NET 10
# manifest into an 11.x band. Both installers must now stay inside one major.minor family.

echo ""
echo "-- fallback band family --"

# The SHIPPED resolver is extracted and invoked directly. The previous version of this
# block re-implemented the family-prefix rule with its own sed, so it agreed with itself
# no matter what workload-install.sh actually did - it could never detect drift.
RESOLVER="$(sed -n '/^MANIFEST_BASE_NAME=/p;/# BEGIN AUTO-GENERATED VERSION MAP/,/# END AUTO-GENERATED VERSION MAP/p;/# BEGIN VERSION BAND DETECTION/,/# END VERSION BAND DETECTION/p;/# BEGIN FALLBACK RESOLVER/,/# END FALLBACK RESOLVER/p' "$SH_SCRIPT")"
eval "$RESOLVER"

if ! declare -f getLatestVersion >/dev/null; then
    printf "  %sFAIL%s  %s\n" "$c_red" "$c_reset" "could not extract getLatestVersion from workload-install.sh"
    fail=$((fail + 1))
else
    printf "  %sPASS%s  %s\n" "$c_green" "$c_reset" "the shipped resolver is the one under test"
    pass=$((pass + 1))
fi

M="samsung.net.sdk.tizen.manifest"

# id|expected resolver output ('' means must fail closed)
RESOLVER_CASES=(
    # exact hits come straight from the map
    "$M-10.0.100|$M-10.0.100=10.0.123"
    "$M-6.0.400|$M-6.0.400=9.0.104"
    # closest band AT OR BELOW the request - never a newer one
    "$M-10.0.200|$M-10.0.100=10.0.123"
    "$M-10.0.400|$M-10.0.300=10.0.127"
    "$M-9.0.400|$M-9.0.300=10.0.121"
    # must never cross the major.minor family
    "$M-11.0.100-preview.7|"
    "$M-11.0.100|"
    # nothing older exists in the family
    "$M-6.0.050|"
    # unparseable family fails closed rather than guessing
    "$M-bogus|"
)

for case in "${RESOLVER_CASES[@]}"; do
    id="${case%%|*}"
    want="${case##*|}"
    got="$(getLatestVersion "$id")"
    if [[ "$got" == "$want" ]]; then
        printf "  %sPASS%s  %-48s -> %s\n" "$c_green" "$c_reset" "$id" "${got:-<none>}"
        pass=$((pass + 1))
    else
        printf "  %sFAIL%s  %-48s -> %s (expected %s)\n" "$c_red" "$c_reset" "$id" "${got:-<none>}" "${want:-<none>}"
        fail=$((fail + 1))
    fi
done

# --- SemVer ordering of pre-release bands -------------------------------------
#
# band_sort_key appended the pre-release raw and the comparison is a string compare, so
# "preview.10" sorted BELOW "preview.9" ('1' < '9'). A request against a preview.10 band
# would then fall back to preview.9. Ordering is asserted on the real function.

echo ""
echo "-- SemVer band ordering --"

ORDERED=(
    "8.0.100-alpha.1"
    "11.0.100-preview.7"
    "11.0.100-preview.9"
    "11.0.100-preview.10"
    "11.0.100-rc.1"
    "11.0.100-rtm"
    "11.0.100"
)
prev=""
prev_band=""
for band in "${ORDERED[@]}"; do
    key="$(band_sort_key "$band")"
    if [[ -z "$prev" || "$key" > "$prev" ]]; then
        printf "  %sPASS%s  %-24s sorts above %s\n" "$c_green" "$c_reset" "$band" "${prev_band:-<start>}"
        pass=$((pass + 1))
    else
        printf "  %sFAIL%s  %-24s does NOT sort above %s\n" "$c_red" "$c_reset" "$band" "$prev_band"
        fail=$((fail + 1))
    fi
    prev="$key"; prev_band="$band"
done

# sh/ps1 parity on the real functions, not on a description of them.
if command -v pwsh >/dev/null 2>&1; then
    PS_KEYFUNC="$(sed -n '/function Get-BandSortKey/,/^}/p' "$PS1_SCRIPT")"
    for band in "${ORDERED[@]}"; do
        sh_key="$(band_sort_key "$band")"
        ps_key="$(pwsh -NoProfile -Command "$PS_KEYFUNC; Get-BandSortKey -Band '$band'" 2>/dev/null | tr -d '\r')"
        if [[ "$sh_key" == "$ps_key" ]]; then
            printf "  %sPASS%s  %-24s sh/ps1 key parity\n" "$c_green" "$c_reset" "$band"
            pass=$((pass + 1))
        else
            printf "  %sFAIL%s  %-24s sh=%s ps1=%s\n" "$c_red" "$c_reset" "$band" "$sh_key" "$ps_key"
            fail=$((fail + 1))
        fi
    done
fi

# --- producer/consumer parity: Config.mk must agree with the installers -------
#
# Config.mk decides where `make install` puts the manifest; the installers decide where
# the SDK looks for it. If they disagree the workload installs into a directory nothing
# reads. Config.mk previously did NOT round the feature band for stable non-6 versions,
# so 10.0.404 produced band '10.0.404' while the installers looked for '10.0.400'.

echo ""
echo "-- Config.mk producer parity --"

if command -v make >/dev/null 2>&1; then
    for case in "${CASES[@]}"; do
        version="${case%%|*}"
        expected="${case##*|}"
        # Config.mk only handles versions it can split; skip the ones make can't model.
        actual="$(make -s -C "$WORKLOAD_DIR" print-version-band DOTNET_VERSION="$version" 2>/dev/null | tail -1)"
        if [[ "$actual" == "$expected" ]]; then
            printf "  %sPASS%s  %-32s -> %s\n" "$c_green" "$c_reset" "$version" "$actual"
            pass=$((pass + 1))
        else
            printf "  %sFAIL%s  %-32s -> %s (installers say %s)\n" "$c_red" "$c_reset" "$version" "${actual:-<none>}" "$expected"
            fail=$((fail + 1))
        fi
    done
else
    echo "  (make not available - skipping Config.mk parity check)"
fi

# --- band isolation: one tree must not reuse another band's SDK ---------------
#
# DOTNET_DESTDIR and the install stamp were previously unscoped, so
# `make install DOTNET_VERSION=11...` in a tree that had already built .NET 10 reused the
# old SDK and silently tested the wrong band.

echo ""
echo "-- band isolation --"

if command -v make >/dev/null 2>&1; then
    for var in print-dotnet-destdir print-install-stamp; do
        a="$(DOTNET_VERSION=10.0.100 make -s -C "$WORKLOAD_DIR" $var 2>/dev/null | tail -1)"
        b="$(DOTNET_VERSION=11.0.100-preview.7.26381.103 make -s -C "$WORKLOAD_DIR" $var 2>/dev/null | tail -1)"
        if [[ -n "$a" && -n "$b" && "$a" != "$b" ]]; then
            printf "  %sPASS%s  %-24s differs across bands\n" "$c_green" "$c_reset" "$var"
            pass=$((pass + 1))
        else
            printf "  %sFAIL%s  %-24s same for both bands (%s)\n" "$c_red" "$c_reset" "$var" "$a"
            fail=$((fail + 1))
        fi
    done

    # Isolation must also hold WITHIN a band. 10.0.100 and 10.0.101 share a feature band,
    # so a band-keyed cache handed the second one the first one's SDK - the build then
    # silently tested an SDK it was never asked for. The SDK directory and stamp are keyed
    # by the FULL version; only the manifest path stays band-based.
    for pair in "10.0.100|10.0.101" "11.0.100-preview.7.26381.103|11.0.100-preview.7.26999.1"; do
        v1="${pair%%|*}"; v2="${pair##*|}"
        for var in print-dotnet-destdir print-install-stamp; do
            a="$(DOTNET_VERSION=$v1 make -s -C "$WORKLOAD_DIR" $var 2>/dev/null | tail -1)"
            b="$(DOTNET_VERSION=$v2 make -s -C "$WORKLOAD_DIR" $var 2>/dev/null | tail -1)"
            if [[ -n "$a" && -n "$b" && "$a" != "$b" ]]; then
                printf "  %sPASS%s  %-24s differs for %s vs %s\n" "$c_green" "$c_reset" "$var" "$v1" "$v2"
                pass=$((pass + 1))
            else
                printf "  %sFAIL%s  %-24s identical for %s and %s (%s)\n" "$c_red" "$c_reset" "$var" "$v1" "$v2" "$a"
                fail=$((fail + 1))
            fi
        done
        # ...while the manifest band deliberately stays shared.
        ba="$(DOTNET_VERSION=$v1 make -s -C "$WORKLOAD_DIR" print-version-band 2>/dev/null | tail -1)"
        bb="$(DOTNET_VERSION=$v2 make -s -C "$WORKLOAD_DIR" print-version-band 2>/dev/null | tail -1)"
        if [[ -n "$ba" && "$ba" == "$bb" ]]; then
            printf "  %sPASS%s  %-24s shared by %s and %s (%s)\n" "$c_green" "$c_reset" "manifest band" "$v1" "$v2" "$ba"
            pass=$((pass + 1))
        else
            printf "  %sFAIL%s  %-24s %s=%s but %s=%s\n" "$c_red" "$c_reset" "manifest band" "$v1" "$ba" "$v2" "$bb"
            fail=$((fail + 1))
        fi
    done
else
    echo "  (make not available - skipping band isolation check)"
fi

echo ""
echo "================ version-band summary ================"
echo "  passed: $pass"
echo "  failed: $fail"

[[ $fail -eq 0 ]] || exit 1
exit 0
