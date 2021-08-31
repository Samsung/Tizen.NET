#
# Copyright (c) Samsung Electronics. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

#!/bin/bash -e

MANIFEST_NAME=Samsung.NET.Sdk.Tizen.Manifest-6.0.100
MANIFEST_VERSION=6.5.100-rc.1.92

DOTNET_VERSION_BAND=6.0.100
DOTNET_INSTALL_DIR=/usr/share/dotnet

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

SDK_MANIFESTS_DIR=$DOTNET_INSTALL_DIR/sdk-manifests/$DOTNET_VERSION_BAND

echo "Installing $MANIFEST_NAME/$MANIFEST_VERSION to $SDK_MANIFESTS_DIR..."

if [ ! -d $SDK_MANIFESTS_DIR ]; then
    echo "No target directory \`$SDK_MANIFESTS_DIR\`";
    exit 1
fi

if [ ! -w $SDK_MANIFESTS_DIR ]; then
    echo "No permission to install manifest. Try again with sudo."
    exit 1
fi

TMPDIR=$(mktemp -d)

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
