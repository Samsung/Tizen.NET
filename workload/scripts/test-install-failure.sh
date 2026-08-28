#!/bin/bash
#
# Copyright (c) Samsung Electronics. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#
# Exit-code regression test for the install scripts.
#
# Both installers used to swallow every per-SDK failure: install_tizenworkload returned
# early on error, the caller ignored the result, and the script printed "DONE" and exited 0.
# A CI job that pipes the script to bash therefore reported success even when nothing was
# installed. These tests pin the corrected behaviour.
#
# Usage:
#   bash workload/scripts/test-install-failure.sh
#   make -C workload test-install-failure
#

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SH_SCRIPT="$SCRIPT_DIR/workload-install.sh"
PS1_SCRIPT="$SCRIPT_DIR/workload-install.ps1"
TMPROOT="$(mktemp -d)"
trap 'rm -rf "$TMPROOT"' EXIT

c_reset=$'\033[0m'; c_red=$'\033[31m'; c_green=$'\033[32m'; c_yellow=$'\033[33m'
[[ -t 1 ]] || { c_reset=""; c_red=""; c_green=""; c_yellow=""; }

pass=0; fail=0

check() {
    local name="$1" expected="$2" actual="$3" output="$4"
    if [[ "$actual" == "$expected" ]]; then
        printf "  %sPASS%s  %-52s exit=%s\n" "$c_green" "$c_reset" "$name" "$actual"
        pass=$((pass + 1))
    else
        printf "  %sFAIL%s  %-52s exit=%s (expected %s)\n" "$c_red" "$c_reset" "$name" "$actual" "$expected"
        echo "$output" | tail -6 | sed 's/^/        | /'
        fail=$((fail + 1))
    fi
}

# --- 1. missing dotnet install dir must fail ------------------------------------

out="$(bash "$SH_SCRIPT" -d "$TMPROOT/does-not-exist" 2>&1)"; rc=$?
check "sh: nonexistent --dotnet-install-dir" 1 "$rc" "$out"

# --- 2. dotnet present but no manifest for the band must fail -------------------
#
# A stub dotnet reports an implausible SDK version. The band lookup finds nothing on
# NuGet and nothing in the fallback version map, so install_tizenworkload must fail and
# the script must exit non-zero instead of printing DONE.

FAKE="$TMPROOT/fakedotnet"
mkdir -p "$FAKE"
cat > "$FAKE/dotnet" <<'STUB'
#!/bin/bash
case "$1" in
    --version)    echo "99.0.100" ;;
    --list-sdks)  echo "99.0.100 [$(dirname "$0")/sdk]" ;;
    *)            exit 0 ;;
esac
STUB
chmod +x "$FAKE/dotnet"

if curl -sSf -m 20 -o /dev/null https://api.nuget.org/v3/index.json 2>/dev/null; then
    out="$(cd "$TMPROOT" && bash "$SH_SCRIPT" -d "$FAKE" 2>&1)"; rc=$?
    check "sh: unknown SDK band fails instead of printing DONE" 1 "$rc" "$out"

    if grep -q "^DONE$" <<< "$out"; then
        printf "  %sFAIL%s  %-52s\n" "$c_red" "$c_reset" "sh: must not print DONE on failure"
        fail=$((fail + 1))
    else
        printf "  %sPASS%s  %-52s\n" "$c_green" "$c_reset" "sh: must not print DONE on failure"
        pass=$((pass + 1))
    fi
else
    printf "  %sSKIP%s  %-52s (no network)\n" "$c_yellow" "$c_reset" "sh: unknown SDK band"
fi

# --- 3. PowerShell parity ------------------------------------------------------

if command -v pwsh >/dev/null 2>&1 && [[ -f "$PS1_SCRIPT" ]]; then
    out="$(pwsh -NoProfile -File "$PS1_SCRIPT" -d "$TMPROOT/does-not-exist" 2>&1)"; rc=$?
    check "ps1: nonexistent -DotnetInstallDir" 1 "$rc" "$out"
else
    printf "  %sSKIP%s  %-52s (pwsh unavailable)\n" "$c_yellow" "$c_reset" "ps1 parity"
fi

# --- 4. fallback must resolve the package ID, not just the version -------------
#
# getLatestVersion previously returned only a version. The caller then downloaded that
# version under the ORIGINAL, unpublished manifest id - e.g. a request for
# '...manifest-10.0.400' resolved to version 10.0.127 (which belongs to
# '...manifest-10.0.300') and then 404'd trying to fetch 10.0.400/10.0.127.
# The function must return "<packageId>=<version>".

echo ""
echo "-- fallback resolves package id --"

# Load the shipped map + function without executing the installer body.
fallback_probe() {
    bash -c '
        eval "$(sed -n "/^MANIFEST_BASE_NAME=/p" '"$SH_SCRIPT"')"
        eval "$(sed -n "/# BEGIN AUTO-GENERATED VERSION MAP/,/# END AUTO-GENERATED VERSION MAP/p" '"$SH_SCRIPT"' | grep -v "^#")"
        eval "$(sed -n "/^function getLatestVersion/,/^}/p" '"$SH_SCRIPT"')"
        getLatestVersion "$1"
    ' _ "$1"
}

# "<requested band>|<expected id band>|<expected version>"  ('' = must resolve to nothing)
FALLBACK_CASES=(
    "10.0.400|10.0.300|10.0.127"
    "10.0.300|10.0.300|10.0.127"
    "9.0.400|9.0.300|10.0.121"
    "11.0.100-preview.7||"
    "12.0.100||"
)

for case in "${FALLBACK_CASES[@]}"; do
    IFS='|' read -r req want_band want_ver <<< "$case"
    base="samsung.net.sdk.tizen.manifest"
    got="$(fallback_probe "$base-$req")"
    if [[ -z "$want_band" ]]; then
        if [[ -z "$got" ]]; then
            printf "  %sPASS%s  %-24s -> resolves to nothing (fails closed)\n" "$c_green" "$c_reset" "$req"
            pass=$((pass + 1))
        else
            printf "  %sFAIL%s  %-24s -> %s (expected nothing)\n" "$c_red" "$c_reset" "$req" "$got"
            fail=$((fail + 1))
        fi
        continue
    fi
    want="$base-$want_band=$want_ver"
    if [[ "$got" == "$want" ]]; then
        printf "  %sPASS%s  %-24s -> %s\n" "$c_green" "$c_reset" "$req" "${got#$base-}"
        pass=$((pass + 1))
    else
        printf "  %sFAIL%s  %-24s -> %s (expected %s)\n" "$c_red" "$c_reset" "$req" "${got:-<none>}" "$want"
        fail=$((fail + 1))
    fi
done

# --- 5. PowerShell parity, incl. no cross-SDK fallback leakage -----------------
#
# The PS installer kept the resolved fallback id in a script-level $global:FallbackId that
# was never cleared, so an -UpdateAllWorkloads run could carry one SDK's fallback package
# into the NEXT SDK's install. The resolved id must be per-call.

if command -v pwsh >/dev/null 2>&1 && [[ -f "$PS1_SCRIPT" ]]; then
    echo ""
    echo "-- PowerShell fallback parity / no global leakage --"

    if grep -q 'global:FallbackId' "$PS1_SCRIPT"; then
        printf "  %sFAIL%s  workload-install.ps1 still uses \$global:FallbackId\n" "$c_red" "$c_reset"
        fail=$((fail + 1))
    else
        printf "  %sPASS%s  workload-install.ps1 has no \$global:FallbackId\n" "$c_green" "$c_reset"
        pass=$((pass + 1))
    fi

    cat > "$TMPROOT/ps-probe.ps1" <<'PSEOF'
param([string]$ScriptPath)
$src = Get-Content -Raw $ScriptPath
$ManifestBaseName = 'Samsung.NET.Sdk.Tizen.Manifest'
Invoke-Expression ([regex]::Match($src,'(?s)# BEGIN AUTO-GENERATED VERSION MAP.*?# END AUTO-GENERATED VERSION MAP').Value -replace '(?m)^#.*$','')
Invoke-Expression ([regex]::Match($src,'(?s)# BEGIN VERSION BAND DETECTION.*?# END VERSION BAND DETECTION').Value)
function Resolve-Offline([string]$Id) {
    if ($LatestVersionMap.Contains($Id)) { return "$Id=$($LatestVersionMap.$Id)" }
    $p = Get-BandFamilyPrefix -ManifestId $Id
    if ($p) {
        $ids = @(); $vs = @()
        foreach ($k in $LatestVersionMap.Keys) {
            if ($k -like "$p*") { $ids += $k; $vs += $LatestVersionMap[$k] }
        }
        if ($vs) { return "$($ids[-1])=$($vs[-1])" }
    }
    return ''
}
# Mixed-band sequence: a 10.x fallback must not bleed into the 11.x iteration.
foreach ($b in @('10.0.400','11.0.100-preview.7','9.0.400')) {
    Write-Output "$b=>$(Resolve-Offline "$ManifestBaseName-$b")"
}
PSEOF
    ps_out="$(pwsh -NoProfile -File "$TMPROOT/ps-probe.ps1" -ScriptPath "$PS1_SCRIPT" 2>/dev/null | tr -d '\r')"

    check_ps() {
        local label="$1" expect="$2"
        if grep -Fqx "$expect" <<< "$ps_out"; then
            printf "  %sPASS%s  %-24s -> %s\n" "$c_green" "$c_reset" "$label" "${expect#*=>}"
            pass=$((pass + 1))
        else
            printf "  %sFAIL%s  %-24s (got: %s)\n" "$c_red" "$c_reset" "$label" "$(grep -F "$label=>" <<< "$ps_out")"
            fail=$((fail + 1))
        fi
    }
    B=Samsung.NET.Sdk.Tizen.Manifest
    check_ps "10.0.400" "10.0.400=>$B-10.0.300=10.0.127"
    check_ps "11.0.100-preview.7" "11.0.100-preview.7=>"
    check_ps "9.0.400" "9.0.400=>$B-9.0.300=10.0.121"
else
    echo ""
    echo "  (pwsh unavailable - skipping PowerShell fallback parity)"
fi

# --- 6. bash 3.2 compatibility -------------------------------------------------
#
# macOS ships bash 3.2 and is a supported target (DOTNET_DEFAULT_PATH_MACOS). The
# ${var,,} lowercase expansion is bash 4+ and raises "bad substitution" there, which left
# the version empty and silently skipped the fallback path entirely.

echo ""
echo "-- bash 3.2 compatibility --"

if grep -nE '\$\{[A-Za-z_][A-Za-z0-9_]*(,,|\^\^)\}' "$SH_SCRIPT" | grep -qv '^\s*[0-9]*:\s*#'; then
    printf "  %sFAIL%s  workload-install.sh uses a bash 4+ case-conversion expansion\n" "$c_red" "$c_reset"
    grep -nE '\$\{[A-Za-z_][A-Za-z0-9_]*(,,|\^\^)\}' "$SH_SCRIPT" | sed 's/^/        /'
    fail=$((fail + 1))
else
    printf "  %sPASS%s  no bash 4+ case-conversion expansions\n" "$c_green" "$c_reset"
    pass=$((pass + 1))
fi

for bad in 'declare -A' 'readarray' 'mapfile'; do
    if grep -q -- "$bad" "$SH_SCRIPT"; then
        printf "  %sFAIL%s  workload-install.sh uses bash 4+ feature: %s\n" "$c_red" "$c_reset" "$bad"
        fail=$((fail + 1))
    else
        printf "  %sPASS%s  no bash 4+ feature: %-12s\n" "$c_green" "$c_reset" "$bad"
        pass=$((pass + 1))
    fi
done

printf "  %sINFO%s  running under bash %s\n" "$c_yellow" "$c_reset" "${BASH_VERSION}"

# --- 7. install path containing spaces ------------------------------------------
#
# Unquoted $DOTNET_INSTALL_DIR / $TMPDIR expansions word-split on a path with spaces.

echo ""
echo "-- space-containing install path --"

SPACEDIR="$TMPROOT/dir with spaces/dotnet sdk"
mkdir -p "$SPACEDIR"
cat > "$SPACEDIR/dotnet" <<'STUB'
#!/bin/bash
case "$1" in
    --version)   echo "10.0.100" ;;
    --list-sdks) echo "10.0.100 [$(dirname "$0")/sdk]" ;;
    workload)    exit 0 ;;
    new)         exit 0 ;;
    *)           exit 0 ;;
esac
STUB
chmod +x "$SPACEDIR/dotnet"

if curl -sSf -m 20 -o /dev/null https://api.nuget.org/v3/index.json 2>/dev/null; then
    space_out="$(cd "$TMPROOT" && bash "$SH_SCRIPT" -d "$SPACEDIR" 2>&1)"; space_rc=$?
    if [[ $space_rc -eq 0 ]] && [[ -f "$SPACEDIR/sdk-manifests/10.0.100/samsung.net.sdk.tizen/WorkloadManifest.json" ]]; then
        printf "  %sPASS%s  installs into a path containing spaces\n" "$c_green" "$c_reset"
        pass=$((pass + 1))
    else
        printf "  %sFAIL%s  install into space-containing path failed (exit %s)\n" "$c_red" "$c_reset" "$space_rc"
        echo "$space_out" | tail -6 | sed 's/^/        | /'
        fail=$((fail + 1))
    fi
else
    printf "  %sSKIP%s  space-path install (no network)\n" "$c_yellow" "$c_reset"
fi

# --- 8. transport failure must fail closed --------------------------------------
#
# A failed/empty version query must take the fallback path and, when that yields
# nothing, fail - never proceed with an empty version.

echo ""
echo "-- transport failure fails closed --"

FAKEHOME="$TMPROOT/nonet"
mkdir -p "$FAKEHOME"
cat > "$FAKEHOME/dotnet" <<'STUB'
#!/bin/bash
case "$1" in
    --version)   echo "99.0.100" ;;
    --list-sdks) echo "99.0.100 [$(dirname "$0")/sdk]" ;;
    *)           exit 0 ;;
esac
STUB
chmod +x "$FAKEHOME/dotnet"
# Force every curl to fail by pointing at an unroutable proxy.
nonet_out="$(cd "$TMPROOT" && ALL_PROXY="http://127.0.0.1:9" HTTPS_PROXY="http://127.0.0.1:9" \
             bash "$SH_SCRIPT" -d "$FAKEHOME" 2>&1)"; nonet_rc=$?
if [[ $nonet_rc -ne 0 ]] && ! grep -q "^DONE$" <<< "$nonet_out"; then
    printf "  %sPASS%s  unreachable feed -> non-zero exit, no DONE\n" "$c_green" "$c_reset"
    pass=$((pass + 1))
else
    printf "  %sFAIL%s  unreachable feed -> exit %s (must fail closed)\n" "$c_red" "$c_reset" "$nonet_rc"
    echo "$nonet_out" | tail -6 | sed 's/^/        | /'
    fail=$((fail + 1))
fi

# --- 9. SDK pin must be verified before installing -----------------------------
#
# install_tizenworkload is invoked under `if !`, which disables errexit for everything it
# calls. An unchecked `dotnet new globaljson` therefore let the install proceed against
# whatever SDK the PATH happened to resolve. The pin is now checked, and the EFFECTIVE
# version/band re-verified, before any pack is installed.

echo ""
echo "-- SDK pin verified before install --"

PINDIR="$TMPROOT/pinbad"
mkdir -p "$PINDIR"
cat > "$PINDIR/dotnet" <<'STUB'
#!/bin/bash
if [ "$1" = "--version" ]; then
    # Model a pin that silently does not take effect.
    if [ -f "$PWD/global.json" ]; then echo "9.0.100"; else echo "10.0.100"; fi
    exit 0
fi
if [ "$1" = "new" ] && [ "$2" = "globaljson" ]; then
    printf '{"sdk":{"version":"x"}}' > "$PWD/global.json"; exit 0
fi
case "$1" in
    --list-sdks) echo "10.0.100 [$(dirname "$0")/sdk]" ;;
    workload)    echo "REACHED_INSTALL"; exit 0 ;;
    *)           exit 0 ;;
esac
STUB
chmod +x "$PINDIR/dotnet"

if curl -sSf -m 20 -o /dev/null https://api.nuget.org/v3/index.json 2>/dev/null; then
    pin_out="$(cd "$TMPROOT" && bash "$SH_SCRIPT" -d "$PINDIR" 2>&1)"; pin_rc=$?
    if [[ $pin_rc -ne 0 ]] && grep -q "pin did not take effect" <<< "$pin_out" && ! grep -q "REACHED_INSTALL" <<< "$pin_out"; then
        printf "  %sPASS%s  ineffective SDK pin aborts before install\n" "$c_green" "$c_reset"
        pass=$((pass + 1))
    else
        printf "  %sFAIL%s  ineffective SDK pin did not abort (exit %s)\n" "$c_red" "$c_reset" "$pin_rc"
        echo "$pin_out" | tail -5 | sed 's/^/        | /'
        fail=$((fail + 1))
    fi

    # A pin that DOES take effect must install normally.
    PINOK="$TMPROOT/pinok"
    mkdir -p "$PINOK"
    cat > "$PINOK/dotnet" <<'STUB'
#!/bin/bash
case "$1" in
    --version)   echo "10.0.100" ;;
    --list-sdks) echo "10.0.100 [$(dirname "$0")/sdk]" ;;
    new)         exit 0 ;;
    workload)    exit 0 ;;
    *)           exit 0 ;;
esac
STUB
    chmod +x "$PINOK/dotnet"
    ok_out="$(cd "$TMPROOT" && bash "$SH_SCRIPT" -d "$PINOK" 2>&1)"; ok_rc=$?
    if [[ $ok_rc -eq 0 ]] && grep -q "^DONE$" <<< "$ok_out"; then
        printf "  %sPASS%s  effective SDK pin installs normally\n" "$c_green" "$c_reset"
        pass=$((pass + 1))
    else
        printf "  %sFAIL%s  effective SDK pin failed (exit %s)\n" "$c_red" "$c_reset" "$ok_rc"
        echo "$ok_out" | tail -5 | sed 's/^/        | /'
        fail=$((fail + 1))
    fi
else
    printf "  %sSKIP%s  SDK pin verification (no network)\n" "$c_yellow" "$c_reset"
fi

# --- 10. empty feed response must not install "latest" -------------------------
#
# The NuGet v2 package endpoint serves the LATEST version when the URL carries no version
# segment, so an empty resolved version must never reach the download step.

echo ""
echo "-- empty version never reaches the download URL --"

if grep -q 'Refusing to install: resolved an empty manifest id/version' "$SH_SCRIPT"; then
    printf "  %sPASS%s  workload-install.sh guards against an empty resolved version\n" "$c_green" "$c_reset"
    pass=$((pass + 1))
else
    printf "  %sFAIL%s  workload-install.sh has no empty-version guard\n" "$c_red" "$c_reset"
    fail=$((fail + 1))
fi

if command -v pwsh >/dev/null 2>&1; then
    # An empty versions[] must NOT yield a truthy "<id>=" result.
    cat > "$TMPROOT/empty-versions.ps1" <<'PSEOF'
param([string]$ScriptPath)
$src = Get-Content -Raw $ScriptPath
if ($src -match 'Where-Object \{ \$_ -and \$_\.Trim\(\) \} \| Select-Object -Last 1') {
    Write-Output 'GUARDED'
} else {
    Write-Output 'UNGUARDED'
}
if ($src -match 'IsNullOrWhiteSpace\(\$ResolvedVersion\)') {
    Write-Output 'CALLER_GUARDED'
} else {
    Write-Output 'CALLER_UNGUARDED'
}
PSEOF
    ev="$(pwsh -NoProfile -File "$TMPROOT/empty-versions.ps1" -ScriptPath "$PS1_SCRIPT" 2>/dev/null | tr -d '\r')"
    for want in GUARDED CALLER_GUARDED; do
        if grep -Fqx "$want" <<< "$ev"; then
            printf "  %sPASS%s  ps1 %s\n" "$c_green" "$c_reset" "$want"
            pass=$((pass + 1))
        else
            printf "  %sFAIL%s  ps1 missing %s\n" "$c_red" "$c_reset" "$want"
            fail=$((fail + 1))
        fi
    done
fi

# --- 11. explicit -Version "" must have no side effects ------------------------
#
# An explicit empty/whitespace -Version does NOT equal "<latest>", so it bypassed the
# resolution-and-validation block entirely, reached the manifest REMOVAL, and produced a
# versionless NuGet URL - and the v2 package endpoint serves the LATEST package for such a
# URL. The gate is now unconditional, before any removal, URL construction or download.

if command -v pwsh >/dev/null 2>&1 && [[ -f "$PS1_SCRIPT" ]]; then
    echo ""
    echo "-- explicit empty -Version has no side effects --"

    EVDIR="$TMPROOT/emptyver"
    mkdir -p "$EVDIR"
    cat > "$EVDIR/dotnet" <<'STUB'
#!/bin/bash
case "$1" in
    --version)   echo "10.0.100" ;;
    --list-sdks) echo "10.0.100 [$(dirname "$0")/sdk]" ;;
    *)           echo "SIDE_EFFECT: dotnet $*" ;;
esac
STUB
    chmod +x "$EVDIR/dotnet"

    for arg in "" "   "; do
        # Pre-seed an installed manifest so its removal would be detectable.
        seeded="$EVDIR/sdk-manifests/10.0.100/samsung.net.sdk.tizen"
        rm -rf "$EVDIR/sdk-manifests"; mkdir -p "$seeded"
        echo '{"version":"SENTINEL","packs":{}}' > "$seeded/WorkloadManifest.json"

        ev_out="$(pwsh -NoProfile -File "$PS1_SCRIPT" -d "$EVDIR" -Version "$arg" 2>&1)"; ev_rc=$?
        label="$([[ -z "$arg" ]] && echo 'empty' || echo 'whitespace')"

        if [[ $ev_rc -ne 0 ]] \
           && grep -q "manifest version is required" <<< "$ev_out" \
           && ! grep -q "SIDE_EFFECT" <<< "$ev_out" \
           && grep -q "SENTINEL" "$seeded/WorkloadManifest.json"; then
            printf "  %sPASS%s  -Version %-12s rejected; no download, no removal\n" "$c_green" "$c_reset" "'$arg'"
            pass=$((pass + 1))
        else
            printf "  %sFAIL%s  -Version %-12s exit=%s (expected rejection with no side effects)\n" "$c_red" "$c_reset" "'$arg'" "$ev_rc"
            grep -q "SENTINEL" "$seeded/WorkloadManifest.json" 2>/dev/null || echo "        | installed manifest was REMOVED"
            grep -q "SIDE_EFFECT" <<< "$ev_out" && echo "        | dotnet was invoked"
            echo "$ev_out" | tail -3 | sed 's/^/        | /'
            fail=$((fail + 1))
        fi
    done
fi

echo ""
echo "============= install-failure summary ============="
echo "  passed: $pass"
echo "  failed: $fail"

[[ $fail -eq 0 ]] || exit 1
exit 0
