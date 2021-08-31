#
# Copyright (c) Samsung Electronics. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

<#
.SYNOPSIS
Installs Tizen workload manifest.
.DESCRIPTION
Installs the WorkloadManifest.json and WorkloadManifest.targets files for Tizen to the dotnet sdk.
.PARAMETER Version
Use specific VERSION
.PARAMETER DotnetInstallDir
Dotnet SDK Location installed
#>

[cmdletbinding()]
param(
    [Alias('v')][string]$Version="6.5.100-rc.1.92",
    [Alias('d')][string]$DotnetInstallDir="$env:Programfiles\dotnet"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$ManifestName = "Samsung.NET.Sdk.Tizen.Manifest-6.0.100"
$DotnetVersionBand = "6.0.100"

function New-TemporaryDirectory {
    $parent = [System.IO.Path]::GetTempPath()
    $name = [System.IO.Path]::GetRandomFileName()
    New-Item -ItemType Directory -Path (Join-Path $parent $name)
}

function Test-Directory([string]$TestDir) {
    if (-Not $(Test-Path $TestDir)) {
        Write-Error "No target directory '$TestDir'."
    }
    Try {
        [io.file]::OpenWrite($(Join-Path -Path $TestDir -ChildPath ".tmp")).Close()
    } Catch {
        Write-Error "No permission to install. Try run with administrator mode."
    }
}

$ManifestDir = Join-Path -Path $DotnetInstallDir -ChildPath "sdk-manifests" | Join-Path -ChildPath $DotnetVersionBand
$TizenManifestDir = Join-Path -Path $ManifestDir -ChildPath "samsung.net.sdk.tizen"
Test-Directory $ManifestDir

Write-Host "Installing $ManifestName/$Version to $ManifestDir..."

$TempDir = $(New-TemporaryDirectory)
$TempZipFile = Join-Path -Path $TempDir -ChildPath "manifest.zip"
$TempUnzipDir = Join-Path -Path $TempDir -ChildPath "unzipped"
Invoke-WebRequest -Uri "https://www.nuget.org/api/v2/package/$ManifestName/$Version" -OutFile $TempZipFile
Expand-Archive -Path $TempZipFile -DestinationPath $TempUnzipDir
Copy-Item -Path "$TempUnzipDir\data\*" -Destination $TizenManifestDir
Remove-Item -Path $TempDir -Force -Recurse

Write-Host "Tizen manifest is installed to $TizenManifestDir."
Write-Host ""
Write-Host "Run 'dotnet workload install tizen' to install tizen workload packs."
