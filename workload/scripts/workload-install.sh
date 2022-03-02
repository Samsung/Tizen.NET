#
# Copyright (c) Samsung Electronics. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

#!/bin/bash -e

MANIFEST_BASE_NAME="samsung.net.sdk.tizen.manifest"
SupportedDotnetVersion="6"
MANIFEST_VERSION="<latest>"
DOTNET_INSTALL_DIR="<auto>"
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
        -h|--help)
            script_name="$(basename "$0")"
            echo "Tizen Workload Installer"
            echo "Usage: $script_name [-v|--version <VERSION>] [-d|--dotnet-install-dir <DIR>]"
            echo "       $script_name -h|-?|--help"
            echo ""
            echo "Options:"
            echo "  -v,--version <VERSION>         Use specific VERSION, Defaults to \`$MANIFEST_VERSION\`."
            echo "  -d,--dotnet-install-dir <DIR>  Dotnet SDK Location installed, Defaults to \`$DOTNET_INSTALL_DIR\`."
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

# Check dotnet install directory.
if [[ "$DOTNET_INSTALL_DIR" == "<auto>" ]]; then
    if [[ -n "$DOTNET_ROOT" && -d "$DOTNET_ROOT" ]]; then
        DOTNET_INSTALL_DIR=$DOTNET_ROOT
    elif [[ -d "$DOTNET_DEFAULT_PATH_LINUX" ]]; then
        DOTNET_INSTALL_DIR=$DOTNET_DEFAULT_PATH_LINUX
    elif [[ -d "$DOTNET_DEFAULT_PATH_MACOS" ]]; then
        DOTNET_INSTALL_DIR=$DOTNET_DEFAULT_PATH_MACOS
    else
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
if [[ ${array[0]} != $SupportedDotnetVersion ]]; then
    echo "Current .NET version is ${DOTNET_VERSION}. .NET 6.0 SDK is required."
    exit 0
fi

DOTNET_VERSION_BAND="${array[0]}.${array[1]}.${array[2]:0:1}00"
MANIFEST_NAME="$MANIFEST_BASE_NAME-$DOTNET_VERSION_BAND"

# Check latest version of manifest.
if [[ "$MANIFEST_VERSION" == "<latest>" ]]; then
    MANIFEST_VERSION=$(curl -s https://api.nuget.org/v3-flatcontainer/$MANIFEST_NAME/index.json | grep \" | tail -n 1 | tr -d '\r' | xargs)
    if [ ! "$MANIFEST_VERSION" ]; then
        echo "Failed to get the latest version of $MANIFEST_NAME."
        exit 1
    fi
fi

# Check workload manifest directory.
SDK_MANIFESTS_DIR=$DOTNET_INSTALL_DIR/sdk-manifests/$DOTNET_VERSION_BAND
if [ ! -d $SDK_MANIFESTS_DIR ]; then
    echo "No target directory \`$SDK_MANIFESTS_DIR\`.";
    exit 1
fi

if [ ! -w $SDK_MANIFESTS_DIR ]; then
    echo "No permission to install manifest. Try again with sudo."
    exit 1
fi

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
