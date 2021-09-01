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
    [Alias('v')][string]$Version="<latest>",
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
        [io.file]::OpenWrite($(Join-Path -Path $TestDir -ChildPath ".test-write-access")).Close()
    } Catch {
        Write-Error "No permission to install. Try run with administrator mode."
    }
    Remove-Item -Path $(Join-Path -Path $TestDir -ChildPath ".test-write-access") -Force
}

function Get-LatestVersion([string]$Id) {
    $Response = Invoke-WebRequest -Uri https://api.nuget.org/v3-flatcontainer/$Id/index.json | ConvertFrom-Json
    return $Response.versions | Select-Object -Last 1
}

function Get-Package([string]$Id, [string]$Version, [string]$Destination, [string]$FileExt = "nupkg") {
    $OutFileName = "$Id.$Version.$FileExt"
    $OutFilePath = Join-Path -Path $Destination -ChildPath $OutFileName
    Invoke-WebRequest -Uri "https://www.nuget.org/api/v2/package/$Id/$Version" -OutFile $OutFilePath
    return $OutFilePath
}

if ($Version -eq "<latest>") {
    $Version = Get-LatestVersion -Id $ManifestName
}

$ManifestDir = Join-Path -Path $DotnetInstallDir -ChildPath "sdk-manifests" | Join-Path -ChildPath $DotnetVersionBand
$TizenManifestDir = Join-Path -Path $ManifestDir -ChildPath "samsung.net.sdk.tizen"
Test-Directory $ManifestDir

Write-Host "Installing $ManifestName/$Version to $ManifestDir..."

$TempDir = $(New-TemporaryDirectory)

# Install workload manifest.
$TempZipFile = $(Get-Package -Id $ManifestName -Version $Version -Destination $TempDir -FileExt "zip")
$TempUnzipDir = Join-Path -Path $TempDir -ChildPath "unzipped"
Expand-Archive -Path $TempZipFile -DestinationPath $TempUnzipDir
New-Item -Path $TizenManifestDir -ItemType "directory" -Force | Out-Null
Copy-Item -Path "$TempUnzipDir\data\*" -Destination $TizenManifestDir

# Download workload packs.
$TizenManifestFile = Join-Path -Path $TizenManifestDir -ChildPath "WorkloadManifest.json"
$ManifestJson = $(Get-Content $TizenManifestFile | ConvertFrom-Json)
$ManifestJson.packs.PSObject.Properties | ForEach-Object {
    $PackageId = $_.Name
    $PackageVersion = $_.Value.version
    Write-Host "Downloading $PackageId/$PackageVersion..."
    Get-Package -Id $PackageId -Version $PackageVersion -Destination $TempDir | Out-Null
}

# Install workload to dotnet sdk
$Env:DOTNET_ROOT = $DotnetInstallDir
$Env:DOTNET_MULTILEVEL_LOOKUP = 0

& $DotnetInstallDir\dotnet workload install tizen --skip-manifest-update --from-cache $TempDir

Remove-Item -Path $TempDir -Force -Recurse
