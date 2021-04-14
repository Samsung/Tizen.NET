#!/bin/bash

# DOTNET6_PATH=<set path for dotnet 6>

if [ -z "$DOTNET6_PATH" ]; then
	echo "Please set DOTNET6_PATH for the location of dotnet-sdk 6.0"
	exit 1
fi

SCRIPT_DIR=$(dirname $(readlink -f $0))

TASK_DLL=$SCRIPT_DIR/Tizen.NET.Build.Tasks/bin/Debug/netstandard2.0/Tizen.NET.Build.Tasks.dll
if [ -f $TASK_DLL ]; then
	cp -f $TASK_DLL $SCRIPT_DIR/Samsung.Tizen.Sdk/*/tools/
fi

rm -fr $DOTNET6_PATH/sdk-manifests/*/Microsoft.NET.Workload.Tizen
cp -fr $SCRIPT_DIR/Microsoft.NET.Workload.Tizen $DOTNET6_PATH/sdk-manifests/*/

rm -fr $DOTNET6_PATH/packs/Samsung.Tizen.Sdk
cp -fr $SCRIPT_DIR/Samsung.Tizen.Sdk $DOTNET6_PATH/packs/

rm -fr $DOTNET6_PATH/packs/Tizen.NET.Ref
cp -fr $SCRIPT_DIR/Tizen.NET.Ref $DOTNET6_PATH/packs/

SENTINEL=$DOTNET6_PATH/sdk/*/EnableWorkloadResolver.sentinel
[ -f $SENTINEL ] || touch $SENTINEL

