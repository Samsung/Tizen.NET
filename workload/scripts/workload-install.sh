#!/bin/bash -e
#
# Copyright (c) Samsung Electronics. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

MANIFEST_BASE_NAME="samsung.net.sdk.tizen.manifest"
MANIFEST_VERSION="<latest>"
DOTNET_INSTALL_DIR="<auto>"
DOTNET_TARGET_VERSION_BAND="<auto>"
DOTNET_DEFAULT_PATH_LINUX="/usr/share/dotnet"
DOTNET_DEFAULT_PATH_MACOS="/usr/local/share/dotnet"
UPDATE_ALL_WORKLOADS="false"

# BEGIN AUTO-GENERATED VERSION MAP -- edit version-map.json and rerun Generate-InstallScripts.ps1
LatestVersionMap=(
    "$MANIFEST_BASE_NAME-6.0.100=7.0.101"
    "$MANIFEST_BASE_NAME-6.0.200=7.0.100-preview.13.6"
    "$MANIFEST_BASE_NAME-6.0.300=8.0.133"
    "$MANIFEST_BASE_NAME-6.0.400=9.0.104"
    "$MANIFEST_BASE_NAME-7.0.100-preview.6=7.0.100-preview.6.14"
    "$MANIFEST_BASE_NAME-7.0.100-preview.7=7.0.100-preview.7.20"
    "$MANIFEST_BASE_NAME-7.0.100-rc.1=7.0.100-rc.1.22"
    "$MANIFEST_BASE_NAME-7.0.100-rc.2=7.0.100-rc.2.24"
    "$MANIFEST_BASE_NAME-7.0.100=7.0.103"
    "$MANIFEST_BASE_NAME-7.0.200=7.0.105"
    "$MANIFEST_BASE_NAME-7.0.300=7.0.120"
    "$MANIFEST_BASE_NAME-7.0.400=10.0.119"
    "$MANIFEST_BASE_NAME-8.0.100-alpha.1=7.0.104"
    "$MANIFEST_BASE_NAME-8.0.100-preview.2=7.0.106"
    "$MANIFEST_BASE_NAME-8.0.100-preview.3=7.0.107"
    "$MANIFEST_BASE_NAME-8.0.100-preview.4=7.0.108"
    "$MANIFEST_BASE_NAME-8.0.100-preview.5=7.0.110"
    "$MANIFEST_BASE_NAME-8.0.100-preview.6=7.0.121"
    "$MANIFEST_BASE_NAME-8.0.100-preview.7=7.0.122"
    "$MANIFEST_BASE_NAME-8.0.100-rc.1=7.0.124"
    "$MANIFEST_BASE_NAME-8.0.100-rc.2=7.0.125"
    "$MANIFEST_BASE_NAME-8.0.100-rtm=7.0.127"
    "$MANIFEST_BASE_NAME-8.0.100=8.0.144"
    "$MANIFEST_BASE_NAME-8.0.200=8.0.157"
    "$MANIFEST_BASE_NAME-8.0.300=8.0.156"
    "$MANIFEST_BASE_NAME-8.0.400=10.0.120"
    "$MANIFEST_BASE_NAME-9.0.100-alpha.1=8.0.134"
    "$MANIFEST_BASE_NAME-9.0.100-preview.1=8.0.135"
    "$MANIFEST_BASE_NAME-9.0.100-preview.2=8.0.137"
    "$MANIFEST_BASE_NAME-9.0.100-preview.3=8.0.148"
    "$MANIFEST_BASE_NAME-9.0.100-rc.1=8.0.152"
    "$MANIFEST_BASE_NAME-9.0.100=10.0.104"
    "$MANIFEST_BASE_NAME-9.0.200=10.0.110"
    "$MANIFEST_BASE_NAME-9.0.300=10.0.121"
    "$MANIFEST_BASE_NAME-10.0.100-rc.2=10.0.118"
    "$MANIFEST_BASE_NAME-10.0.100=10.0.123"
    "$MANIFEST_BASE_NAME-10.0.300=10.0.127"
    )
# END AUTO-GENERATED VERSION MAP

while [ $# -ne 0 ]; do
    name=$1
    case "$name" in
        -v|--version)
            shift
            MANIFEST_VERSION=$1
            ;;
        -d|--dotnet-install-dir)
            shift
            DOTNET_INSTALL_DIR="$1"
            ;;
        -t|--dotnet-target-version-band)
            shift
            DOTNET_TARGET_VERSION_BAND=$1
            ;;
        -u|--update-all-workloads)
            shift
            UPDATE_ALL_WORKLOADS="true"
            ;;
        -h|--help)
            script_name="$(basename "$0")"
            echo "Tizen Workload Installer"
            echo "Usage: $script_name [-v|--version <VERSION>] [-d|--dotnet-install-dir <DIR>] [-t|--dotnet-target-version-band <VERSION>]"
            echo "       $script_name -h|-?|--help"
            echo ""
            echo "Options:"
            echo "  -v,--version <VERSION>                     Use specific VERSION, Defaults to \`$MANIFEST_VERSION\`."
            echo "  -d,--dotnet-install-dir <DIR>              Dotnet SDK Location installed, Defaults to \`$DOTNET_INSTALL_DIR\`."
            echo "  -t,--dotnet-target-version-band <VERSION>  Use specific dotnet version band for install location, Defaults to \`$DOTNET_TARGET_VERSION_BAND\`."
            exit 0
            ;;
        *)
            echo "Unknown argument \`$name\`"
            exit 1
            ;;
    esac

    shift
done

function read_dotnet_link() {
    cd -P "$(dirname "$1")" || return 1
    dotnet_file="$PWD/$(basename "$1")"
    while [[ -h "$dotnet_file" ]]; do
        cd -P "$(dirname "$dotnet_file")"
        dotnet_file="$(readlink "$dotnet_file")"
        cd -P "$(dirname "$dotnet_file")"
        dotnet_file="$PWD/$(basename "$dotnet_file")"
    done
    echo $PWD
}

function error_permission_denied() {
    echo "No permission to install manifest. Try again with sudo."
    exit 1
}

function ensure_directory() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1" || error_permission_denied
    fi
    [ ! -w "$1" ] && error_permission_denied
}

# Check dotnet install directory.
if [[ "$DOTNET_INSTALL_DIR" == "<auto>" ]]; then
    if [[ -n "$DOTNET_ROOT" && -d "$DOTNET_ROOT" ]]; then
        DOTNET_INSTALL_DIR="$DOTNET_ROOT"
    elif [[ -d "$DOTNET_DEFAULT_PATH_LINUX" ]]; then
        DOTNET_INSTALL_DIR="$DOTNET_DEFAULT_PATH_LINUX"
    elif [[ -d "$DOTNET_DEFAULT_PATH_MACOS" ]]; then
        DOTNET_INSTALL_DIR="$DOTNET_DEFAULT_PATH_MACOS"
    elif [[ -n "$(which dotnet)" ]]; then
        DOTNET_INSTALL_DIR="$(read_dotnet_link "$(which dotnet)")"
    fi
fi
if [ ! -d "$DOTNET_INSTALL_DIR" ]; then
    echo "No installed dotnet \`$DOTNET_INSTALL_DIR\`."
    exit 1
fi

# Resolve the manifest package to install for a requested manifest id.
#
# Echoes "<packageId>=<version>", or the empty string when nothing is available.
# The package id MUST be returned alongside the version: when the requested band has
# no published manifest we fall back to an EARLIER band's package, and downloading
# that version under the originally requested (non-existent) id 404s. For example
# a request for '...manifest-10.0.400' resolves to '...manifest-10.0.300=10.0.127'
# and the 10.0.300 package is what has to be downloaded.
# BEGIN FALLBACK RESOLVER -- extracted by scripts/test-version-band.sh so the tests
# exercise the SHIPPED resolver. A hand-copied reimplementation in the test cannot
# detect drift from this function, which is the entire point of testing it.
function getLatestVersion () {
    for index in "${LatestVersionMap[@]}"; do
         if [ "${index%%=*}" = "${1}" ]; then
             echo "${1}=${index#*=}"
             return
         fi
    done
    # Return a fallback version, but only from the SAME .NET major.minor family.
    # '<base>-11.0.100-preview.7' -> '<base>-11.0.' so an 11.x request can never
    # resolve to a 10.x manifest. Must match Get-BandFamilyPrefix in workload-install.ps1.
    local manifestId="$1"
    local family="${manifestId#*-}"
    family="$(echo "$family" | sed -E 's/^([0-9]+\.[0-9]+)\..*/\1/')"
    if [[ ! "$family" =~ ^[0-9]+\.[0-9]+$ ]]; then
        echo ""
        return
    fi
    local prefix="${manifestId%%-*}-${family}."
    local requestedBand="${manifestId#*-}"
    local requestedKey; requestedKey="$(band_sort_key "$requestedBand")"

    # Choose the CLOSEST band that is <= the requested one. Taking the last/highest match
    # meant a request for 10.0.200 resolved to 10.0.300 - a NEWER band, whose manifest may
    # not be valid for the requested SDK - while skipping a perfectly good 10.0.200 or
    # 10.0.100. Bands are ordered by a numeric key so map order is irrelevant.
    local fallbackId=""
    local fallbackVersion=""
    local bestKey=""
    for entry in "${LatestVersionMap[@]}"; do
        mapKey="${entry%%=*}"
        mapValue="${entry#*=}"
        case "$mapKey" in
            "$prefix"*) ;;
            *) continue ;;
        esac
        local candidateBand="${mapKey#*-}"
        local candidateKey; candidateKey="$(band_sort_key "$candidateBand")"
        # Skip anything newer than what was asked for.
        [[ "$candidateKey" > "$requestedKey" ]] && continue
        if [[ -z "$bestKey" || "$candidateKey" > "$bestKey" ]]; then
            bestKey="$candidateKey"
            fallbackId="$mapKey"
            fallbackVersion="$mapValue"
        fi
    done
    if [[ -z "$fallbackId" ]]; then
        echo ""
        return
    fi
    echo "$fallbackId=$fallbackVersion"
}
# END FALLBACK RESOLVER

# Check installed dotnet version
DOTNET_COMMAND="$DOTNET_INSTALL_DIR/dotnet"

if [ ! -x "$DOTNET_COMMAND" ]; then
    echo "$DOTNET_COMMAND command not found"
    exit 1
fi

# BEGIN VERSION BAND DETECTION -- covered by scripts/test-version-band.sh
# Map a full .NET SDK version to the SDK feature band used for the workload
# manifest directory / NuGet package suffix.
#   10.0.100                     -> 10.0.100
#   10.0.100-rc.2.25502.107      -> 10.0.100-rc.2
#   11.0.100-preview.7.26381.103 -> 11.0.100-preview.7
#   8.0.100-rtm.23512.16         -> 8.0.100-rtm
#   6.0.419                      -> 6.0.400   (pre-net7 SDKs have no preview bands)
function compute_target_version_band() {
    local dotnet_version="$1"
    local -a array
    IFS='.' read -r -a array <<< "$dotnet_version"
    local current_major="${array[0]}"
    local band="${array[0]}.${array[1]}.${array[2]:0:1}00"

    if [[ "$current_major" -ge "7" ]]; then
        if [[ "$dotnet_version" == *"-preview"* || "$dotnet_version" == *"-rc"* || "$dotnet_version" == *"-alpha"* ]] && [[ ${#array[@]} -ge 4 ]]; then
            echo "$band${array[2]:3}.${array[3]}"
            return
        elif [[ "$dotnet_version" == *"-rtm"* ]] && [[ ${#array[@]} -ge 3 ]]; then
            echo "$band${array[2]:3}"
            return
        fi
    fi
    echo "$band"
}
# Comparable sort key for an SDK feature band, e.g. '10.0.300' or '11.0.100-preview.7'.
# Zero-padded so plain string comparison orders bands correctly, with pre-release bands
# sorting BEFORE the corresponding stable band ('0' < '1').
band_sort_key() {
    local band="$1"
    local core="${band%%-*}"
    local pre=""
    [[ "$band" == *-* ]] && pre="${band#*-}"
    local IFS='.'
    local -a parts
    read -r -a parts <<< "$core"
    local major="${parts[0]:-0}" minor="${parts[1]:-0}" patch="${parts[2]:-0}"
    if [[ -n "$pre" ]]; then
        # Normalise the pre-release so a plain string comparison follows SemVer precedence.
        # Appending it raw made the comparison lexicographic, where "preview.10" sorts
        # BELOW "preview.9" because '1' < '9' - so a request against a preview.10 band
        # silently fell back to preview.9. Numeric identifiers are therefore zero-padded
        # and tagged 0, alphanumeric ones tagged 1 (numeric < alphanumeric in SemVer).
        # '.' sorts below digits and letters, so a shorter identifier list sorts first,
        # which is also what SemVer requires.
        local normalised=""
        local ident
        local oldIFS="$IFS"
        IFS='.'
        for ident in $pre; do
            case "$ident" in
                ''|*[!0-9]*) normalised="$normalised.$(printf '1%s' "$ident")" ;;
                *)           normalised="$normalised.$(printf '0%010d' "$ident")" ;;
            esac
        done
        IFS="$oldIFS"
        printf '%05d%05d%05d0%s\n' "$major" "$minor" "$patch" "$normalised"
    else
        # No pre-release: sorts above every pre-release of the same core version.
        printf '%05d%05d%05d1\n' "$major" "$minor" "$patch"
    fi
}

# END VERSION BAND DETECTION

function install_tizenworkload() {
    DOTNET_VERSION=$1
    IFS='.' read -r -a array <<< "$DOTNET_VERSION"
    DOTNET_VERSION_BAND="${array[0]}.${array[1]}.${array[2]:0:1}00"
    MANIFEST_NAME="$MANIFEST_BASE_NAME-$DOTNET_VERSION_BAND"

    # Reset local variables
    if [[ "$UPDATE_ALL_WORKLOADS" == "true" ]]; then
        DOTNET_TARGET_VERSION_BAND="<auto>"
        MANIFEST_VERSION="<latest>"
    fi

    # Check version band.
    #
    # -t/--dotnet-target-version-band deliberately installs into a DIFFERENT band than the
    # running SDK (documented: verifying a workload against the next band). Remember which
    # case applies so the post-pin equality check below is applied only when the band was
    # derived automatically.
    TARGET_BAND_IS_EXPLICIT="false"
    if [[ "$DOTNET_TARGET_VERSION_BAND" == "<auto>" ]]; then
        DOTNET_TARGET_VERSION_BAND=$(compute_target_version_band "$DOTNET_VERSION")
    else
        TARGET_BAND_IS_EXPLICIT="true"
    fi
    # The manifest package is named after the band it is FOR, so it must always follow the
    # target band - including when that band was requested explicitly. Leaving it derived
    # from the running SDK meant `-t 10.0.200` on a 10.0.100 SDK downloaded
    # samsung.net.sdk.tizen.manifest-10.0.100 and installed it into sdk-manifests/10.0.200:
    # the wrong band's manifest, in the right band's directory, reported as success.
    MANIFEST_NAME="$MANIFEST_BASE_NAME-$DOTNET_TARGET_VERSION_BAND"

    # Check latest version of manifest.
    if [[ "$MANIFEST_VERSION" == "<latest>" ]]; then
        # NOTE: use tr, not the ${var,,} expansion. That expansion is bash 4+, and macOS
        # still ships bash 3.2 - where it raises "bad substitution", leaves
        # MANIFEST_VERSION empty and silently skips the fallback below. macOS is a
        # supported target (see DOTNET_DEFAULT_PATH_MACOS).
        MANIFEST_NAME_LOWER=$(echo "$MANIFEST_NAME" | tr '[:upper:]' '[:lower:]')
        MANIFEST_VERSION=$(curl -s https://api.nuget.org/v3-flatcontainer/$MANIFEST_NAME_LOWER/index.json | grep \" | tail -n 1 | tr -d '\r' | xargs)
        # An empty response (network failure, or the package having never been published)
        # must take the same fallback path as an explicit BlobNotFound.
        if [ -z "$MANIFEST_VERSION" ] || echo "$MANIFEST_VERSION" | grep -q "BlobNotFound"; then
            RESOLVED_MANIFEST=$(getLatestVersion "$MANIFEST_NAME")
            if [[ -n $RESOLVED_MANIFEST ]]; then
                # Download the package that actually exists. The manifest is still
                # installed into the requested band's directory below.
                MANIFEST_NAME="${RESOLVED_MANIFEST%%=*}"
                MANIFEST_VERSION="${RESOLVED_MANIFEST#*=}"
                echo "Return cached latest version: $MANIFEST_NAME/$MANIFEST_VERSION"
            else
                echo "Failed to get the latest version of $MANIFEST_NAME."
                return 1
            fi
        fi
    fi

    if [ -z "$MANIFEST_VERSION" ] || [ -z "$MANIFEST_NAME" ]; then
        echo "Refusing to install: resolved an empty manifest id/version for $DOTNET_VERSION."
        return 1
    fi

    # Pin and validate the SDK BEFORE touching anything on disk.
    #
    # This used to run after the manifest had already been copied, so a pin failure left a
    # replaced manifest behind. All validation now happens before the first mutation.
    if [ -f global.json ]; then
        CACHE_GLOBAL_JSON="true"
        mv global.json global.json.bak
    else
        CACHE_GLOBAL_JSON="false"
    fi

    restore_global_json() {
        rm -f global.json
        if [[ "$CACHE_GLOBAL_JSON" == "true" ]]; then mv global.json.bak global.json; fi
        CACHE_GLOBAL_JSON="false"
    }

    # Everything from here to the end of the install is ONE transaction. A partial install
    # is worse than no install: the SDK would be left with a manifest describing packs that
    # are not present, or - when a download failed - with global.json still pinned and the
    # user's real global.json sitting in global.json.bak, which the next loop iteration
    # would then overwrite and destroy.
    TX_TMPDIR=""
    TX_MANIFEST_DEST=""
    TX_MANIFEST_NEW=""
    TX_MANIFEST_OLD=""
    TX_SWAPPED="false"
    TX_HAD_PREVIOUS="false"

    # Release temporary state. Used on both paths; on the failure path TX_SWAPPED is still
    # true, so the previous manifest is put back first.
    tx_finish() {
        if [[ "$TX_SWAPPED" == "true" ]]; then
            # Put the previous manifest back exactly as it was.
            rm -fr "$TX_MANIFEST_DEST"
            if [[ "$TX_HAD_PREVIOUS" == "true" ]] && [ -d "$TX_MANIFEST_OLD" ]; then
                mv "$TX_MANIFEST_OLD" "$TX_MANIFEST_DEST"
            fi
        fi
        [ -n "$TX_MANIFEST_NEW" ] && rm -fr "$TX_MANIFEST_NEW"
        [ -n "$TX_MANIFEST_OLD" ] && rm -fr "$TX_MANIFEST_OLD"
        [ -n "$TX_TMPDIR" ] && rm -fr "$TX_TMPDIR"
        restore_global_json
    }

    # Roll the SDK back to exactly the state it was in before this function ran.
    tx_rollback() { tx_finish; }

    # This function is invoked under `if !`, which disables errexit for everything it calls,
    # so every command here is checked explicitly.
    if ! "$DOTNET_INSTALL_DIR/dotnet" new globaljson --sdk-version "$DOTNET_VERSION" --force >/dev/null; then
        echo "Failed to pin SDK $DOTNET_VERSION via global.json."
        tx_rollback
        return 1
    fi

    EFFECTIVE_VERSION="$("$DOTNET_INSTALL_DIR/dotnet" --version 2>/dev/null)"
    if [ "$EFFECTIVE_VERSION" != "$DOTNET_VERSION" ]; then
        echo "SDK pin did not take effect: requested $DOTNET_VERSION, active ${EFFECTIVE_VERSION:-<unknown>}."
        tx_rollback
        return 1
    fi

    # The active SDK must match the destination band ONLY when that band was derived from
    # the SDK. An explicit -t is a deliberate cross-band install.
    if [[ "$TARGET_BAND_IS_EXPLICIT" != "true" ]]; then
        EFFECTIVE_BAND="$(compute_target_version_band "$EFFECTIVE_VERSION")"
        if [ "$EFFECTIVE_BAND" != "$DOTNET_TARGET_VERSION_BAND" ]; then
            echo "Band mismatch: manifest targets $DOTNET_TARGET_VERSION_BAND but the active SDK resolves to $EFFECTIVE_BAND."
            tx_rollback
            return 1
        fi
    else
        echo "Installing into explicitly requested band $DOTNET_TARGET_VERSION_BAND (active SDK $EFFECTIVE_VERSION)."
    fi

    # Check workload manifest directory.
    SDK_MANIFESTS_DIR="$DOTNET_INSTALL_DIR/sdk-manifests/$DOTNET_TARGET_VERSION_BAND"
    ensure_directory "$SDK_MANIFESTS_DIR"

    TMPDIR=$(mktemp -d)
    TX_TMPDIR="$TMPDIR"

    echo "Installing $MANIFEST_NAME/$MANIFEST_VERSION to $SDK_MANIFESTS_DIR..."

    # Download and extract the manifest nuget package.
    curl -sfL -o "$TMPDIR/manifest.zip" "https://www.nuget.org/api/v2/package/$MANIFEST_NAME/$MANIFEST_VERSION"
    CURL_STATUS=$?
    if [ $CURL_STATUS -ne 0 ]; then
        echo "Failed to download $MANIFEST_NAME/$MANIFEST_VERSION (curl exit $CURL_STATUS)."
        tx_rollback
        return 1
    fi

    if ! unzip -qq -d "$TMPDIR/unzipped" "$TMPDIR/manifest.zip"; then
        echo "Failed to extract $MANIFEST_NAME/$MANIFEST_VERSION."
        tx_rollback
        return 1
    fi
    if [ ! -d "$TMPDIR/unzipped/data" ]; then
        echo "No such files to install."
        tx_rollback
        return 1
    fi
    chmod 744 "$TMPDIR"/unzipped/data/*

    # Verify the STAGED payload before replacing anything. Checking the destination instead
    # meant a leftover manifest from a previous install could satisfy the check even when
    # this download had produced nothing usable.
    if [ ! -f "$TMPDIR/unzipped/data/WorkloadManifest.json" ]; then
        echo "Downloaded package does not contain WorkloadManifest.json."
        tx_rollback
        return 1
    fi

    # Replace the destination atomically: build the new directory alongside the old one,
    # swap, and roll the previous contents back if any step fails. An interrupted in-place
    # copy previously left a half-replaced manifest directory.
    MANIFEST_DEST="$SDK_MANIFESTS_DIR/samsung.net.sdk.tizen"
    MANIFEST_NEW="$SDK_MANIFESTS_DIR/.samsung.net.sdk.tizen.new.$$"
    MANIFEST_OLD="$SDK_MANIFESTS_DIR/.samsung.net.sdk.tizen.old.$$"
    rm -fr "$MANIFEST_NEW" "$MANIFEST_OLD"
    TX_MANIFEST_DEST="$MANIFEST_DEST"
    TX_MANIFEST_NEW="$MANIFEST_NEW"
    TX_MANIFEST_OLD="$MANIFEST_OLD"

    if ! mkdir -p "$MANIFEST_NEW" || ! cp -f "$TMPDIR"/unzipped/data/* "$MANIFEST_NEW/"; then
        echo "Failed to stage manifest files."
        tx_rollback
        return 1
    fi
    if [ ! -f "$MANIFEST_NEW/WorkloadManifest.json" ]; then
        echo "Staged manifest is incomplete."
        tx_rollback
        return 1
    fi

    HAD_PREVIOUS="false"
    if [ -d "$MANIFEST_DEST" ]; then
        if ! mv "$MANIFEST_DEST" "$MANIFEST_OLD"; then
            echo "Failed to set aside the existing manifest."
            tx_rollback
            return 1
        fi
        HAD_PREVIOUS="true"
        TX_HAD_PREVIOUS="true"
    fi

    if ! mv "$MANIFEST_NEW" "$MANIFEST_DEST"; then
        echo "Failed to install the new manifest; rolling back."
        tx_rollback
        return 1
    fi
    TX_SWAPPED="true"

    # The pack install is part of the transaction. If it fails, the new manifest must not
    # be left behind: it advertises packs that are not on disk, so every subsequent build
    # against that band fails with a missing-pack error that looks unrelated to this run.
    "$DOTNET_INSTALL_DIR/dotnet" workload install tizen --skip-manifest-update
    install_status=$?

    if [ $install_status -ne 0 ]; then
        echo "Failed to install Tizen workload packs for $DOTNET_VERSION (exit $install_status)."
        echo "Rolling back the manifest so the SDK is left as it was."
        tx_rollback
        return $install_status
    fi

    # Committed: keep the new manifest, drop the saved copy and the temporary state.
    TX_SWAPPED="false"
    tx_finish

    echo "Done installing Tizen workload $MANIFEST_VERSION"
    echo ""
}

if [[ "$UPDATE_ALL_WORKLOADS" == "true" ]]; then
    INSTALLED_DOTNET_SDKS=$("$DOTNET_COMMAND" --list-sdks | sed -E -n '/^([6-9]|[1-9][0-9]+)\./p' | sed 's/ \[.*//g')
else
    INSTALLED_DOTNET_SDKS=$("$DOTNET_COMMAND" --version)
fi

FAILED_SDKS=""

if [ -z "$INSTALLED_DOTNET_SDKS" ]; then
    echo ".NET SDK version 6 or later is required to install Tizen Workload."
    exit 1
fi

for DOTNET_SDK in $INSTALLED_DOTNET_SDKS; do
    echo "Check Tizen Workload for sdk $DOTNET_SDK."
    if ! install_tizenworkload $DOTNET_SDK; then
        FAILED_SDKS="$FAILED_SDKS $DOTNET_SDK"
    fi
done

if [ -n "$FAILED_SDKS" ]; then
    echo "FAILED to install Tizen workload for sdk(s):$FAILED_SDKS"
    exit 1
fi

echo "DONE"
