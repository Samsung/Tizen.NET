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

# Load the shipped map + resolver without executing the installer body. The resolver
# depends on band_sort_key from the VERSION BAND DETECTION block; loading getLatestVersion
# alone left that undefined, every key came back empty, and the resolver silently degraded
# to "last map entry wins" - which happened to match the expected answers below, so the
# closest-band logic was never actually tested. stderr is captured into the result so any
# such "command not found" fails the case instead of being swallowed.
fallback_probe() {
    bash -c '
        eval "$(sed -n "/^MANIFEST_BASE_NAME=/p" '"$SH_SCRIPT"')"
        eval "$(sed -n "/# BEGIN AUTO-GENERATED VERSION MAP/,/# END AUTO-GENERATED VERSION MAP/p" '"$SH_SCRIPT"' | grep -v "^#")"
        eval "$(sed -n "/# BEGIN VERSION BAND DETECTION/,/# END VERSION BAND DETECTION/p" '"$SH_SCRIPT"')"
        eval "$(sed -n "/# BEGIN FALLBACK RESOLVER/,/# END FALLBACK RESOLVER/p" '"$SH_SCRIPT"')"
        getLatestVersion "$1"
    ' _ "$1" 2>&1
}

# "<requested band>|<expected id band>|<expected version>"  ('' = must resolve to nothing)
# 10.0.200 is the case that separates "closest band <= requested" from "last entry wins":
# the map has 10.0.100 and 10.0.300, and only the former is valid for a 10.0.200 SDK.
FALLBACK_CASES=(
    "10.0.400|10.0.300|10.0.127"
    "10.0.300|10.0.300|10.0.127"
    "10.0.200|10.0.100|10.0.123"
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

    # Probe the SHIPPED Get-LatestVersion, not a re-implementation: a hand-written stand-in
    # cannot detect drift in the real function (it used to be one that returned the last
    # map entry - the very algorithm the closest-band fix replaced). The feed is stubbed
    # out so the map fallback is exercised offline and without the retry sleeps.
    cat > "$TMPROOT/ps-probe.ps1" <<'PSEOF'
param([string]$ScriptPath)
Set-StrictMode -Version Latest
$src = Get-Content -Raw $ScriptPath
$ManifestBaseName = 'Samsung.NET.Sdk.Tizen.Manifest'
Invoke-Expression ([regex]::Match($src,'(?s)# BEGIN AUTO-GENERATED VERSION MAP.*?# END AUTO-GENERATED VERSION MAP').Value -replace '(?m)^#.*$','')
Invoke-Expression ([regex]::Match($src,'(?s)# BEGIN VERSION BAND DETECTION.*?# END VERSION BAND DETECTION').Value)
Invoke-Expression ([regex]::Match($src,'(?ms)^function Get-LatestVersion\(.*?^\}').Value)
function Invoke-WebRequest { throw "offline" }
function Start-Sleep {}
# Mixed-band sequence: a 10.x fallback must not bleed into the 11.x iteration, and
# 10.0.200 must resolve to the closest LOWER band (10.0.100), not the newest (10.0.300).
foreach ($b in @('10.0.400','10.0.200','11.0.100-preview.7','9.0.400')) {
    $r = Get-LatestVersion -Id "$ManifestBaseName-$b" 6>$null
    Write-Output "$b=>$r"
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
    check_ps "10.0.200" "10.0.200=>$B-10.0.100=10.0.123"
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

# --- 12. upgrading an existing install must not expose a second manifest --------
#
# The transaction parked the previous manifest at sdk-manifests/<band>/.samsung...old.<pid>
# while `dotnet workload install` ran. The SDK loads EVERY subdirectory of the band
# directory as a manifest, so it saw the 'tizen' workload defined twice and failed with a
# manifest-composition error - on every upgrade. The stub below models that resolver rule.

echo ""
echo "-- upgrade over an existing manifest --"

UPDIR="$TMPROOT/upgrade"
UPBAND="$UPDIR/sdk-manifests/10.0.100"
mkdir -p "$UPBAND/samsung.net.sdk.tizen"
echo '{"version":"SENTINEL","packs":{}}' > "$UPBAND/samsung.net.sdk.tizen/WorkloadManifest.json"
cat > "$UPDIR/dotnet" <<'STUB'
#!/bin/bash
case "$1" in
    --version)   echo "10.0.100" ;;
    --list-sdks) echo "10.0.100 [$(dirname "$0")/sdk]" ;;
    workload)
        # SdkDirectoryWorkloadManifestProvider: every subdirectory of the band directory,
        # dot-prefixed or not, is a manifest. Two copies of the tizen manifest conflict.
        band="$(dirname "$0")/sdk-manifests/10.0.100"
        n=0
        for d in "$band"/*/ "$band"/.*/; do
            [ -d "$d" ] || continue
            case "$(basename "$d")" in .|..) continue ;; esac
            n=$((n + 1))
        done
        if [ "$n" -ne 1 ]; then
            echo "Workload definition 'tizen' conflicts: $n manifest directories in $band"
            exit 1
        fi
        exit 0 ;;
    *)           exit 0 ;;
esac
STUB
chmod +x "$UPDIR/dotnet"

if curl -sSf -m 20 -o /dev/null https://api.nuget.org/v3/index.json 2>/dev/null; then
    mkdir -p "$TMPROOT/upgrade-cwd"
    up_out="$(cd "$TMPROOT/upgrade-cwd" && bash "$SH_SCRIPT" -d "$UPDIR" 2>&1)"; up_rc=$?
    leftovers="$(cd "$UPBAND" && ls -A | grep -v '^samsung.net.sdk.tizen$')"
    if [[ $up_rc -eq 0 ]] && grep -q "^DONE$" <<< "$up_out" \
       && ! grep -q SENTINEL "$UPBAND/samsung.net.sdk.tizen/WorkloadManifest.json" \
       && [[ -z "$leftovers" ]]; then
        printf "  %sPASS%s  upgrade replaces the manifest with no second manifest dir\n" "$c_green" "$c_reset"
        pass=$((pass + 1))
    else
        printf "  %sFAIL%s  upgrade over existing manifest (exit %s)\n" "$c_red" "$c_reset" "$up_rc"
        [[ -n "$leftovers" ]] && echo "        | extra entries in band dir: $leftovers"
        grep -q SENTINEL "$UPBAND/samsung.net.sdk.tizen/WorkloadManifest.json" 2>/dev/null && echo "        | manifest was NOT replaced"
        echo "$up_out" | tail -6 | sed 's/^/        | /'
        fail=$((fail + 1))
    fi
else
    printf "  %sSKIP%s  upgrade over existing manifest (no network)\n" "$c_yellow" "$c_reset"
fi

# --- 13. SDK pin must disable roll-forward ---------------------------------------
#
# A global.json without rollForward uses latestPatch: with 10.0.100 and 10.0.105 both
# installed, pinning 10.0.100 activates 10.0.105 and the exact-version check failed on
# every such machine. The stub models that resolver rule.

echo ""
echo "-- SDK pin disables roll-forward --"

RFDIR="$TMPROOT/rollfwd"
mkdir -p "$RFDIR"
cat > "$RFDIR/dotnet" <<'STUB'
#!/bin/bash
case "$1" in
    --version)
        if [ -f "$PWD/global.json" ] && ! grep -q '"rollForward": *"disable"' "$PWD/global.json"; then
            echo "10.0.105"
        else
            echo "10.0.100"
        fi ;;
    --list-sdks) printf '10.0.100 [x]\n10.0.105 [x]\n' ;;
    new)
        # `dotnet new globaljson --sdk-version X` writes NO rollForward, exactly as the
        # real template does; the installer must not rely on it.
        printf '{"sdk":{"version":"%s"}}' "$4" > "$PWD/global.json" ;;
    *)           exit 0 ;;
esac
STUB
chmod +x "$RFDIR/dotnet"

if curl -sSf -m 20 -o /dev/null https://api.nuget.org/v3/index.json 2>/dev/null; then
    mkdir -p "$TMPROOT/rollfwd-cwd"
    rf_out="$(cd "$TMPROOT/rollfwd-cwd" && bash "$SH_SCRIPT" -d "$RFDIR" 2>&1)"; rf_rc=$?
    if [[ $rf_rc -eq 0 ]] && grep -q "^DONE$" <<< "$rf_out"; then
        printf "  %sPASS%s  pin holds when a newer patch of the band is installed\n" "$c_green" "$c_reset"
        pass=$((pass + 1))
    else
        printf "  %sFAIL%s  pin lost to roll-forward (exit %s)\n" "$c_red" "$c_reset" "$rf_rc"
        echo "$rf_out" | tail -5 | sed 's/^/        | /'
        fail=$((fail + 1))
    fi
else
    printf "  %sSKIP%s  SDK pin roll-forward (no network)\n" "$c_yellow" "$c_reset"
fi

# --- 14. permission failure must leave the caller's global.json untouched ---------
#
# ensure_directory exits the script outright on a permission error. It ran after the
# caller's global.json had been moved to global.json.bak and replaced by the pin, and that
# exit path never restores it. Fails closed only when the check runs before the pin.

echo ""
echo "-- permission failure leaves global.json untouched --"

if [[ $EUID -eq 0 ]]; then
    printf "  %sSKIP%s  permission failure (running as root)\n" "$c_yellow" "$c_reset"
else
    PERMDIR="$TMPROOT/perm"
    mkdir -p "$PERMDIR/sdk-manifests/10.0.100"
    cat > "$PERMDIR/dotnet" <<'STUB'
#!/bin/bash
case "$1" in
    --version)   echo "10.0.100" ;;
    --list-sdks) echo "10.0.100 [$(dirname "$0")/sdk]" ;;
    *)           exit 0 ;;
esac
STUB
    chmod +x "$PERMDIR/dotnet"
    chmod 555 "$PERMDIR/sdk-manifests/10.0.100"
    PERMCWD="$TMPROOT/perm-cwd"
    mkdir -p "$PERMCWD"
    echo '{"sdk":{"version":"SENTINEL"}}' > "$PERMCWD/global.json"

    perm_out="$(cd "$PERMCWD" && bash "$SH_SCRIPT" -d "$PERMDIR" 2>&1)"; perm_rc=$?
    chmod 755 "$PERMDIR/sdk-manifests/10.0.100"
    if [[ $perm_rc -ne 0 ]] && grep -q SENTINEL "$PERMCWD/global.json" && [[ ! -e "$PERMCWD/global.json.bak" ]]; then
        printf "  %sPASS%s  unwritable band dir -> exit %s, global.json untouched\n" "$c_green" "$c_reset" "$perm_rc"
        pass=$((pass + 1))
    else
        printf "  %sFAIL%s  unwritable band dir (exit %s)\n" "$c_red" "$c_reset" "$perm_rc"
        grep -q SENTINEL "$PERMCWD/global.json" 2>/dev/null || echo "        | caller's global.json is missing or replaced"
        [[ -e "$PERMCWD/global.json.bak" ]] && echo "        | global.json.bak left behind"
        echo "$perm_out" | tail -4 | sed 's/^/        | /'
        fail=$((fail + 1))
    fi
fi

# --- 15. ps1: a failed download must restore the previous manifest ---------------
#
# The PowerShell "transaction" took its backup AFTER the previous manifest and packs had
# been removed, so on an upgrade there was nothing to restore and a failed download left
# the SDK with no Tizen workload at all. A 404 on the manifest package models the failure.

if command -v pwsh >/dev/null 2>&1 && [[ -f "$PS1_SCRIPT" ]]; then
    echo ""
    echo "-- ps1: failed download restores the previous manifest --"

    if curl -sSf -m 20 -o /dev/null https://api.nuget.org/v3/index.json 2>/dev/null; then
        RBDIR="$TMPROOT/ps-rollback"
        RBSEED="$RBDIR/sdk-manifests/10.0.100/samsung.net.sdk.tizen"
        mkdir -p "$RBSEED"
        echo '{"version":"SENTINEL","packs":{}}' > "$RBSEED/WorkloadManifest.json"
        cat > "$RBDIR/dotnet" <<'STUB'
#!/bin/bash
case "$1" in
    --version)   echo "10.0.100" ;;
    --list-sdks) echo "10.0.100 [$(dirname "$0")/sdk]" ;;
    *)           exit 0 ;;
esac
STUB
        chmod +x "$RBDIR/dotnet"

        rb_out="$(pwsh -NoProfile -File "$PS1_SCRIPT" -d "$RBDIR" -Version "0.0.0-does-not-exist" 2>&1)"; rb_rc=$?
        if [[ $rb_rc -ne 0 ]] && grep -q SENTINEL "$RBSEED/WorkloadManifest.json" 2>/dev/null; then
            printf "  %sPASS%s  404 on the manifest -> exit %s, previous manifest restored\n" "$c_green" "$c_reset" "$rb_rc"
            pass=$((pass + 1))
        else
            printf "  %sFAIL%s  404 on the manifest (exit %s)\n" "$c_red" "$c_reset" "$rb_rc"
            grep -q SENTINEL "$RBSEED/WorkloadManifest.json" 2>/dev/null || echo "        | previous manifest was NOT restored"
            echo "$rb_out" | tail -5 | sed 's/^/        | /'
            fail=$((fail + 1))
        fi
    else
        printf "  %sSKIP%s  ps1 rollback (no network)\n" "$c_yellow" "$c_reset"
    fi
fi

# --- 16. -u must skip, not fail, an SDK band that has no Tizen manifest ------------
#
# --update-all-workloads walks every installed SDK. A band with no published manifest
# (a preview SDK, or one newer than the last release) is not an install failure; failing
# the whole run for it made -u unusable the day a preview SDK was installed. A single-SDK
# run for such a band still fails (case 2 above).

echo ""
echo "-- -u skips SDK bands with no manifest --"

SKDIR="$TMPROOT/skipband"
mkdir -p "$SKDIR"
cat > "$SKDIR/dotnet" <<'STUB'
#!/bin/bash
case "$1" in
    --version)   echo "99.0.100" ;;
    --list-sdks) echo "99.0.100 [$(dirname "$0")/sdk]" ;;
    *)           exit 0 ;;
esac
STUB
chmod +x "$SKDIR/dotnet"

mkdir -p "$TMPROOT/skipband-cwd"
sk_out="$(cd "$TMPROOT/skipband-cwd" && bash "$SH_SCRIPT" -d "$SKDIR" -u 2>&1)"; sk_rc=$?
if [[ $sk_rc -eq 0 ]] && grep -q "^DONE$" <<< "$sk_out" && grep -q "SKIPPED" <<< "$sk_out"; then
    printf "  %sPASS%s  sh: -u with an unpublished band -> exit 0, reported as skipped\n" "$c_green" "$c_reset"
    pass=$((pass + 1))
else
    printf "  %sFAIL%s  sh: -u with an unpublished band (exit %s)\n" "$c_red" "$c_reset" "$sk_rc"
    echo "$sk_out" | tail -4 | sed 's/^/        | /'
    fail=$((fail + 1))
fi

if command -v pwsh >/dev/null 2>&1 && [[ -f "$PS1_SCRIPT" ]]; then
    psk_out="$(pwsh -NoProfile -File "$PS1_SCRIPT" -d "$SKDIR" -UpdateAllWorkloads 2>&1)"; psk_rc=$?
    if [[ $psk_rc -eq 0 ]] && grep -q "SKIPPED" <<< "$psk_out"; then
        printf "  %sPASS%s  ps1: -UpdateAllWorkloads with an unpublished band -> exit 0, skipped\n" "$c_green" "$c_reset"
        pass=$((pass + 1))
    else
        printf "  %sFAIL%s  ps1: -UpdateAllWorkloads with an unpublished band (exit %s)\n" "$c_red" "$c_reset" "$psk_rc"
        echo "$psk_out" | tail -4 | sed 's/^/        | /'
        fail=$((fail + 1))
    fi
fi

echo ""
echo "============= install-failure summary ============="
echo "  passed: $pass"
echo "  failed: $fail"

[[ $fail -eq 0 ]] || exit 1
exit 0
