#!/bin/bash
#
# Copyright (c) Samsung Electronics. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#
# Evaluation test for PackageTargetFallback compatibility filtering.
#
# FixupNuGetReferences matches a package's lib/<name>/ sibling directories against
# PackageTargetFallback by NAME ONLY - it performs no compatibility check of its own.
# An unfiltered cross-product therefore lets a net6.0-tizen8.0 build silently pick up
# net6.0-tizen11.0 (newer platform) or net11.0-tizen8.0 (newer .NET) assets.
#
# This test extracts the real filtering block from the shipped
# Samsung.Tizen.Sdk.NuGet.targets (between the BEGIN/END TIZEN PACKAGE FALLBACK markers)
# and evaluates it, asserting both that compatible entries are present and - the point of
# the exercise - that incompatible ones are ABSENT.
#
# Usage:
#   bash workload/scripts/test-package-fallback.sh
#   make -C workload test-package-fallback
#

set -uo pipefail

WORKLOAD_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TARGETS="$WORKLOAD_DIR/src/Samsung.Tizen.Sdk/targets/Samsung.Tizen.Sdk.NuGet.targets"
DOTNET="${DOTNET:-dotnet}"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

c_reset=$'\033[0m'; c_red=$'\033[31m'; c_green=$'\033[32m'; c_yellow=$'\033[33m'
[[ -t 1 ]] || { c_reset=""; c_red=""; c_green=""; c_yellow=""; }

if ! command -v "$DOTNET" >/dev/null 2>&1; then
    echo "  ${c_yellow}SKIP${c_reset}  '$DOTNET' not found; cannot evaluate MSBuild expressions."
    exit 0
fi

BLOCK="$(sed -n '/BEGIN TIZEN PACKAGE FALLBACK/,/END TIZEN PACKAGE FALLBACK/p' "$TARGETS" \
         | sed -e '1d' -e '$d')"
if [[ -z "$BLOCK" ]]; then
    echo "ERROR: TIZEN PACKAGE FALLBACK markers not found in $TARGETS."
    echo "       Keep the markers intact so this test exercises shipped code."
    exit 2
fi

{
    echo '<Project>'
    echo "$BLOCK"
    echo '  <Target Name="Probe">'
    echo '    <Message Importance="high" Text="RESULT|$(PackageTargetFallback)" />'
    echo '  </Target>'
    echo '</Project>'
} > "$TMPDIR/probe.proj"

pass=0; fail=0

# "<TFV>|<TPV>|<must be present, comma-sep>|<must be ABSENT, comma-sep>"
CASES=(
    # Building for the lowest supported platform: nothing newer may leak in.
    "v6.0|8.0|net6.0-tizen8.0,tizen80|net6.0-tizen9.0,net6.0-tizen10.0,net6.0-tizen11.0,net8.0-tizen8.0,net11.0-tizen11.0,tizen90,tizen10.0"
    # Newer .NET, old platform: platform siblings above 8.0 must stay out.
    "v11.0|8.0|net11.0-tizen8.0,net6.0-tizen8.0,tizen80|net11.0-tizen9.0,net6.0-tizen11.0,net11.0-tizen11.0,tizen90"
    # Old .NET, newest platform: .NET majors above 6.0 must stay out.
    "v6.0|11.0|net6.0-tizen11.0,net6.0-tizen8.0,tizen10.0|net8.0-tizen11.0,net11.0-tizen11.0,net9.0-tizen10.0"
    # The primary target: everything at or below is fair game.
    "v11.0|11.0|net11.0-tizen11.0,net6.0-tizen8.0,net8.0-tizen10.0,tizen40|"
    # Mid-range combination.
    "v9.0|10.0|net9.0-tizen10.0,net8.0-tizen9.0,tizen10.0|net10.0-tizen10.0,net11.0-tizen11.0,net9.0-tizen10.1,net9.0-tizen11.0"
    # 10.1 must not admit 11.0, and 10.1 itself is available at 10.1.
    "v10.0|10.1|net10.0-tizen10.1,net10.0-tizen10.0|net10.0-tizen11.0,net11.0-tizen10.1"
)

for case in "${CASES[@]}"; do
    IFS='|' read -r tfv tpv want_present want_absent <<< "$case"

    out="$("$DOTNET" msbuild "$TMPDIR/probe.proj" -t:Probe -nologo -v:m -nodereuse:false \
            -p:TargetFrameworkVersion="$tfv" -p:TargetPlatformVersion="$tpv" 2>&1 \
            | grep -o 'RESULT|.*' | head -1)"
    list=";${out#RESULT|};"
    list="${list// /}"

    label="net${tfv#v}-tizen${tpv}"
    row_ok=1
    detail=""

    presents=(); absents=()
    [[ -n "$want_present" ]] && IFS=',' read -ra presents <<< "$want_present"
    [[ -n "$want_absent"  ]] && IFS=',' read -ra absents  <<< "$want_absent"

    for e in "${presents[@]+"${presents[@]}"}"; do
        [[ -z "$e" || "$e" == *_SKIP ]] && continue
        if [[ "$list" != *";$e;"* ]]; then row_ok=0; detail="$detail missing:$e"; fi
    done

    for e in "${absents[@]+"${absents[@]}"}"; do
        [[ -z "$e" ]] && continue
        if [[ "$list" == *";$e;"* ]]; then row_ok=0; detail="$detail LEAKED:$e"; fi
    done

    if [[ $row_ok -eq 1 ]]; then
        printf "  %sPASS%s  %-22s\n" "$c_green" "$c_reset" "$label"
        pass=$((pass + 1))
    else
        printf "  %sFAIL%s  %-22s%s\n" "$c_red" "$c_reset" "$label" "$detail"
        printf "        list: %s\n" "${out#RESULT|}"
        fail=$((fail + 1))
    fi
done

# --- selection priority + atomicity ------------------------------------------
#
# PackageTargetFallback is an ORDERED preference list, but FixupNuGetReferences used to add
# every matching directory to an unordered HashSet (populated in FILESYSTEM enumeration
# order) and then take assemblies first-wins across all of them. Two consequences:
#   * the declared priority was ignored whenever it disagreed with directory order, and
#   * assemblies could be MIXED across TFMs within one package.
#
# The cases below are chosen so alphabetical directory order DISAGREES with the declared
# priority - otherwise the old implementation passes by luck.

echo ""
echo "-- selection priority / atomicity --"

TASK_PROJ="$WORKLOAD_DIR/src/Samsung.Tizen.Build.Tasks/Samsung.Tizen.Build.Tasks.csproj"
TASK_DLL="$WORKLOAD_DIR/src/Samsung.Tizen.Build.Tasks/bin/Release/netstandard2.0/Samsung.Tizen.Build.Tasks.dll"

# Always rebuild: a stale DLL would let the suite validate code that is no longer the
# source of truth. MSBuild node reuse is disabled everywhere below for the same reason -
# a persistent node caches the loaded task assembly across invocations.
"$DOTNET" build "$TASK_PROJ" -c Release --nologo -v:q -nodereuse:false >/dev/null 2>&1 || true

# "<label>|<priority list>|<dirs to create>|<expected winner>|<dirs that get Extras.dll>"
#
# 'priority' mirrors what the SDK emits for the project being built (highest first).
# Alphabetically net6.0-tizen8.0 sorts BEFORE net9.0-tizen9.0, so a filesystem-ordered
# implementation picks the wrong one here.
PRIORITY_CASES=(
    "priority beats dir order|net9.0-tizen9.0;net6.0-tizen8.0|net9.0-tizen9.0 net6.0-tizen8.0|net9.0-tizen9.0|net9.0-tizen9.0 net6.0-tizen8.0"
    "no mixing across TFMs|net9.0-tizen9.0;net6.0-tizen8.0|net9.0-tizen9.0 net6.0-tizen8.0|net9.0-tizen9.0|net6.0-tizen8.0"
    "mid-priority wins|net8.0-tizen10.0;net6.0-tizen8.0|net8.0-tizen10.0 net6.0-tizen8.0|net8.0-tizen10.0|net8.0-tizen10.0 net6.0-tizen8.0"
)

if [[ ! -f "$TASK_DLL" ]]; then
    printf "  %sSKIP%s  task assembly unavailable (build failed)\n" "$c_yellow" "$c_reset"
else
    ci=0
    for case in "${PRIORITY_CASES[@]}"; do
        IFS='|' read -r label priority dirs want extras <<< "$case"

        # Directory enumeration order is filesystem-dependent (observed here as reverse
        # creation order). Rather than depend on it, run each case in BOTH creation orders:
        # whichever way the filesystem enumerates, one of the two runs presents a
        # lower-priority directory first. An implementation that follows enumeration order
        # instead of the declared priority must fail at least one of them.
        for order in forward reverse; do
            ci=$((ci + 1))
            pkgroot="$TMPDIR/pkg$ci/lib"
            rm -rf "$pkgroot"; mkdir -p "$pkgroot/netstandard2.0"
            printf 'netstandard2.0' > "$pkgroot/netstandard2.0/Contoso.dll"
            printf 'netstandard2.0' > "$pkgroot/netstandard2.0/Contoso.Extras.dll"

            if [[ "$order" == "forward" ]]; then
                ordered="$dirs"
            else
                ordered="$(echo "$dirs" | tr ' ' '\n' | sed '1!G;h;$!d' | tr '\n' ' ')"
            fi

            for d in $ordered; do
                [[ -z "$d" ]] && continue
                mkdir -p "$pkgroot/$d"
                printf '%s' "$d" > "$pkgroot/$d/Contoso.dll"
                case " $extras " in *" $d "*) printf '%s' "$d" > "$pkgroot/$d/Contoso.Extras.dll" ;; esac
            done

            cat > "$TMPDIR/fixup$ci.proj" <<PROJEOF
<Project>
  <UsingTask TaskName="Samsung.Tizen.Build.Tasks.FixupNuGetReferences" AssemblyFile="$TASK_DLL" />
  <Target Name="Probe">
    <ItemGroup>
      <CopyLocal Include="$pkgroot/netstandard2.0/Contoso.dll" />
      <CopyLocal Include="$pkgroot/netstandard2.0/Contoso.Extras.dll" />
    </ItemGroup>
    <Samsung.Tizen.Build.Tasks.FixupNuGetReferences
        PackageTargetFallback="$priority"
        CopyLocalItems="@(CopyLocal)">
      <Output TaskParameter="AssembliesToAdd" ItemName="Added" />
    </Samsung.Tizen.Build.Tasks.FixupNuGetReferences>
    <Message Importance="high" Text="ADDED|@(Added)" />
  </Target>
</Project>
PROJEOF

            out="$("$DOTNET" msbuild "$TMPDIR/fixup$ci.proj" -t:Probe -nologo -v:m -nodereuse:false 2>&1 | grep -o 'ADDED|.*' | head -1)"
            added="${out#ADDED|}"
            bad=0; seen=""
            [[ -z "$added" ]] && bad=1
            IFS=';' read -ra items <<< "$added"
            for a in "${items[@]+"${items[@]}"}"; do
                [[ -z "$a" ]] && continue
                tfmdir="$(basename "$(dirname "$a")")"
                seen="$seen $tfmdir"
                [[ "$tfmdir" != "$want" ]] && bad=1
            done
            if [[ $bad -eq 0 ]]; then
                printf "  %sPASS%s  %-28s [%-7s] all from %s\n" "$c_green" "$c_reset" "$label" "$order" "$want"
                pass=$((pass + 1))
            else
                printf "  %sFAIL%s  %-28s [%-7s] expected only %s, saw:%s\n" "$c_red" "$c_reset" "$label" "$order" "$want" "${seen:- <none>}"
                fail=$((fail + 1))
            fi
        done
    done
fi

# --- final asset set: no netstandard remnants --------------------------------
#
# Selecting one fallback TFM is not enough. The task must remove the package's ENTIRE
# netstandard asset group, not just the files the fallback happens to share a name with -
# otherwise the leftover netstandard DLLs stay in the reference set and the build mixes
# platform-specific and netstandard assemblies from the SAME package.
#
# Fixture: netstandard2.0 carries A.dll AND B.dll, but the winning TFM carries only A.dll.
# The final set (originals minus removed, plus added) must contain NO netstandard asset.

echo ""
echo "-- final asset set has no netstandard remnants --"

if [[ ! -f "$TASK_DLL" ]]; then
    printf "  %sSKIP%s  task assembly unavailable\n" "$c_yellow" "$c_reset"
else
    for order in forward reverse; do
        pkgroot="$TMPDIR/remnant-$order/lib"
        rm -rf "$pkgroot"; mkdir -p "$pkgroot/netstandard2.0"
        printf 'ns' > "$pkgroot/netstandard2.0/A.dll"
        printf 'ns' > "$pkgroot/netstandard2.0/B.dll"
        if [[ "$order" == "forward" ]]; then dirs="net9.0-tizen9.0 net6.0-tizen8.0"; else dirs="net6.0-tizen8.0 net9.0-tizen9.0"; fi
        for d in $dirs; do mkdir -p "$pkgroot/$d"; done
        # Winner carries ONLY A.dll; B.dll exists solely as a netstandard asset.
        printf 'net9.0-tizen9.0' > "$pkgroot/net9.0-tizen9.0/A.dll"
        printf 'net6.0-tizen8.0' > "$pkgroot/net6.0-tizen8.0/A.dll"
        printf 'net6.0-tizen8.0' > "$pkgroot/net6.0-tizen8.0/B.dll"

        cat > "$TMPDIR/remnant-$order.proj" <<PROJEOF
<Project>
  <UsingTask TaskName="Samsung.Tizen.Build.Tasks.FixupNuGetReferences" AssemblyFile="$TASK_DLL" />
  <Target Name="Probe">
    <ItemGroup>
      <CopyLocal Include="$pkgroot/netstandard2.0/A.dll" />
      <CopyLocal Include="$pkgroot/netstandard2.0/B.dll" />
    </ItemGroup>
    <Samsung.Tizen.Build.Tasks.FixupNuGetReferences
        PackageTargetFallback="net9.0-tizen9.0;net6.0-tizen8.0"
        CopyLocalItems="@(CopyLocal)">
      <Output TaskParameter="AssembliesToAdd" ItemName="Added" />
      <Output TaskParameter="AssembliesToRemove" ItemName="Removed" />
    </Samsung.Tizen.Build.Tasks.FixupNuGetReferences>
    <ItemGroup>
      <Final Include="@(CopyLocal)" Exclude="@(Removed)" />
      <Final Include="@(Added)" />
    </ItemGroup>
    <Message Importance="high" Text="FINAL|@(Final)" />
  </Target>
</Project>
PROJEOF

        out="$("$DOTNET" msbuild "$TMPDIR/remnant-$order.proj" -t:Probe -nologo -v:m -nodereuse:false 2>&1 | grep -o 'FINAL|.*' | head -1)"
        final="${out#FINAL|}"
        if [[ -n "$final" ]] && ! grep -q 'netstandard2\.0' <<< "$final"; then
            printf "  %sPASS%s  [%-7s] final set free of netstandard assets\n" "$c_green" "$c_reset" "$order"
            pass=$((pass + 1))
        else
            printf "  %sFAIL%s  [%-7s] netstandard asset survived: %s\n" "$c_red" "$c_reset" "$order" "${final:-<none>}"
            fail=$((fail + 1))
        fi
    done
fi

echo ""
echo "=========== package-fallback summary ==========="
echo "  passed: $pass"
echo "  failed: $fail"

[[ $fail -eq 0 ]] || exit 1
exit 0
