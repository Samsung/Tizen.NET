#
# Copyright (c) Samsung Electronics. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

#!/bin/bash -e

MANIFEST_BASE_NAME="samsung.net.sdk.tizen.manifest"
SUPPORTED_DOTNET_VERSION="6"
MANIFEST_VERSION="<latest>"
DOTNET_INSTALL_DIR="<auto>"
DOTNET_TARGET_VERSION_BAND="<auto>"
DOTNET_DEFAULT_PATH_LINUX="/usr/share/dotnet"
DOTNET_DEFAULT_PATH_MACOS="/usr/local/share/dotnet"

while [ $# -ne 0 ]; do
    name=$1
    case "$name" in
        -v|--version)
            shift
            MANIFEST_VERSION=$1
            ;;
        -d|--dotnet-install-dir)
            shift
            DOTNET_INSTALL_DIR=$1
            ;;
        -t|--dotnet-target-version-band)
            shift
            DOTNET_TARGET_VERSION_BAND=$1
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
    cd -P "$(dirname "$1")"
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
    if [ ! -d $1 ]; then
        mkdir -p $1 || error_permission_denied
    fi
    [ ! -w $1 ] && error_permission_denied
}

# Check dotnet install directory.
if [[ "$DOTNET_INSTALL_DIR" == "<auto>" ]]; then
    if [[ -n "$DOTNET_ROOT" && -d "$DOTNET_ROOT" ]]; then
        DOTNET_INSTALL_DIR=$DOTNET_ROOT
    elif [[ -d "$DOTNET_DEFAULT_PATH_LINUX" ]]; then
        DOTNET_INSTALL_DIR=$DOTNET_DEFAULT_PATH_LINUX
    elif [[ -d "$DOTNET_DEFAULT_PATH_MACOS" ]]; then
        DOTNET_INSTALL_DIR=$DOTNET_DEFAULT_PATH_MACOS
    elif [[ -n "$(which dotnet)" ]]; then
        DOTNET_INSTALL_DIR=$(read_dotnet_link $(which dotnet))
    fi
fi
if [ ! -d $DOTNET_INSTALL_DIR ]; then
    echo "No installed dotnet \`$DOTNET_INSTALL_DIR\`."
    exit 1
fi

# Check installed dotnet version
DOTNET_COMMAND="$DOTNET_INSTALL_DIR/dotnet"

if [ ! -x "$DOTNET_COMMAND" ]; then
    echo "$DOTNET_COMMAND command not found"
    exit 1
fi

DOTNET_VERSION=$($DOTNET_COMMAND --version)
IFS='.' read -r -a array <<< "$DOTNET_VERSION"

CURRENT_DOTNET_VERSION=${array[0]}
if [[ $CURRENT_DOTNET_VERSION -lt $SUPPORTED_DOTNET_VERSION ]]; then
    echo "Current .NET version is $CURRENT_DOTNET_VERSION. .NET SDK version $SUPPORTED_DOTNET_VERSION or later is required."
    exit 0
fi

DOTNET_VERSION_BAND="${array[0]}.${array[1]}.${array[2]:0:1}00"
MANIFEST_NAME="$MANIFEST_BASE_NAME-$DOTNET_VERSION_BAND"

if [[ "$DOTNET_TARGET_VERSION_BAND" == "<auto>" ]]; then
    if [[ "$CURRENT_DOTNET_VERSION" -ge "7" ]]; then
        if [[ "$DOTNET_VERSION" == *"-preview"* || $DOTNET_VERSION == *"-rc"* || $DOTNET_VERSION == *"-alpha"* ]] && [[ ${#array[@]} -ge 4 ]]; then
            DOTNET_TARGET_VERSION_BAND="$DOTNET_VERSION_BAND${array[2]:3}.${array[3]}"
        else
            DOTNET_TARGET_VERSION_BAND=$DOTNET_VERSION_BAND
        fi
    else
        DOTNET_TARGET_VERSION_BAND=$DOTNET_VERSION_BAND
    fi
fi

LatestVersionMap=(
    "$MANIFEST_BASE_NAME-6.0.100=6.5.100-rc.1.120"
    "$MANIFEST_BASE_NAME-6.0.200=7.0.100-preview.13.6"
    "$MANIFEST_BASE_NAME-6.0.300=7.0.303"
    )

function getLatestVersion () {
    for index in "${LatestVersionMap[@]}"; do
         if [ "${index%%=*}" = "${1}" ]; then
             echo "${index#*=}"
         fi
    done
    echo ""
}

# Check latest version of manifest.
if [[ "$MANIFEST_VERSION" == "<latest>" ]]; then
    MANIFEST_VERSION=$(curl -s https://api.nuget.org/v3-flatcontainer/$MANIFEST_NAME/index.json | grep \" | tail -n 1 | tr -d '\r' | xargs)
    if [ ! "$MANIFEST_VERSION" ]; then
        MANIFEST_VERSION=$(getLatestVersion "$MANIFEST_NAME")
        if [[ -n $MANIFEST_VERSION ]]; then
            echo "Return cached latest version: $MANIFEST_VERSION"
        else
            echo "Failed to get the latest version of $MANIFEST_NAME."
            exit 1
        fi
    fi
fi

# Check workload manifest directory.
SDK_MANIFESTS_DIR=$DOTNET_INSTALL_DIR/sdk-manifests/$DOTNET_TARGET_VERSION_BAND

ensure_directory $SDK_MANIFESTS_DIR

TMPDIR=$(mktemp -d)

echo "Installing $MANIFEST_NAME/$MANIFEST_VERSION to $SDK_MANIFESTS_DIR..."

# Download and extract the manifest nuget package.
curl -s -o $TMPDIR/manifest.zip -L https://www.nuget.org/api/v2/package/$MANIFEST_NAME/$MANIFEST_VERSION
unzip -qq -d $TMPDIR/unzipped $TMPDIR/manifest.zip
if [ ! -d $TMPDIR/unzipped/data ]; then
    echo "No such files to install."
    exit 1
fi
chmod 744 $TMPDIR/unzipped/data/*

# Copy manifest files to dotnet sdk.
mkdir -p $SDK_MANIFESTS_DIR/samsung.net.sdk.tizen
cp -f $TMPDIR/unzipped/data/* $SDK_MANIFESTS_DIR/samsung.net.sdk.tizen/

if [ ! -f $SDK_MANIFESTS_DIR/samsung.net.sdk.tizen/WorkloadManifest.json ]; then
    echo "Installation is failed."
    exit 1
fi

# Install workload packs.
$DOTNET_INSTALL_DIR/dotnet workload install tizen --skip-manifest-update

# Clean-up
rm -fr $TMPDIR
