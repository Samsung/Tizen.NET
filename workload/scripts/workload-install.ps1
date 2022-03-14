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
    [Alias('d')][string]$DotnetInstallDir="<auto>",
    [Alias('t')][string]$DotnetTargetVersionBand="<auto>"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$ManifestBaseName = "Samsung.NET.Sdk.Tizen.Manifest"
$SupportedDotnetVersion = "6"

function New-TemporaryDirectory {
    $parent = [System.IO.Path]::GetTempPath()
    $name = [System.IO.Path]::GetRandomFileName()
    New-Item -ItemType Directory -Path (Join-Path $parent $name)
}

function Ensure-Directory([string]$TestDir) {
    Try {
        New-Item -ItemType Directory -Path $TestDir -Force -ErrorAction stop
        [io.file]::OpenWrite($(Join-Path -Path $TestDir -ChildPath ".test-write-access")).Close()
        Remove-Item -Path $(Join-Path -Path $TestDir -ChildPath ".test-write-access") -Force
    }
    Catch [System.UnauthorizedAccessException] [
        Write-Error "No permission to install. Try run with administrator mode."
    }
}

function Get-LatestVersion([string]$Id) {
    try {
        $Response = Invoke-WebRequest -Uri https://api.nuget.org/v3-flatcontainer/$Id/index.json | ConvertFrom-Json
    } catch {
        Write-Error "Wrong Id: $Id"
    }
    return $Response.versions | Select-Object -Last 1
}

function Get-Package([string]$Id, [string]$Version, [string]$Destination, [string]$FileExt = "nupkg") {
    $OutFileName = "$Id.$Version.$FileExt"
    $OutFilePath = Join-Path -Path $Destination -ChildPath $OutFileName
    Invoke-WebRequest -Uri "https://www.nuget.org/api/v2/package/$Id/$Version" -OutFile $OutFilePath
    return $OutFilePath
}

function Install-Pack([string]$Id, [string]$Version, [string]$Kind) {
    $TempZipFile = $(Get-Package -Id $Id -Version $Version -Destination $TempDir -FileExt "zip")
    $TempUnzipDir = Join-Path -Path $TempDir -ChildPath "unzipped\$Id"

    switch ($Kind) {
        "manifest" {
            Expand-Archive -Path $TempZipFile -DestinationPath $TempUnzipDir
            New-Item -Path $TizenManifestDir -ItemType "directory" -Force | Out-Null
            Copy-Item -Path "$TempUnzipDir\data\*" -Destination $TizenManifestDir -Force
        }
        {($_ -eq "sdk") -or ($_ -eq "framework")} {
            Expand-Archive -Path $TempZipFile -DestinationPath $TempUnzipDir
            $TargetDirectory = $(Join-Path -Path $DotnetInstallDir -ChildPath "packs\$Id\$Version")
            New-Item -Path $TargetDirectory -ItemType "directory" -Force | Out-Null
            Copy-Item -Path "$TempUnzipDir/*" -Destination $TargetDirectory -Recurse -Force
        }
        "template" {
            $TargetFileName = "$Id.$Version.nupkg".ToLower()
            $TargetDirectory = $(Join-Path -Path $DotnetInstallDir -ChildPath "template-packs")
            New-Item -Path $TargetDirectory -ItemType "directory" -Force | Out-Null
            Copy-Item $TempZipFile -Destination $(Join-Path -Path $TargetDirectory -ChildPath "$TargetFileName") -Force
        }
    }
}

function Remove-Pack([string]$Id, [string]$Version, [string]$Kind) {
    switch ($Kind) {
        "manifest" {
            Remove-Item -Path $TizenManifestDir -Recurse -Force
        }
        {($_ -eq "sdk") -or ($_ -eq "framework")} {
            $TargetDirectory = $(Join-Path -Path $DotnetInstallDir -ChildPath "packs\$Id\$Version")
            Remove-Item -Path $TargetDirectory -Recurse -Force
        }
        "template" {
            $TargetFileName = "$Id.$Version.nupkg".ToLower();
            Remove-Item -Path $(Join-Path -Path $DotnetInstallDir -ChildPath "template-packs\$TargetFileName") -Force
        }
    }
}

# Check dotnet install directory.
if ($DotnetInstallDir -eq "<auto>") {
    if ($Env:DOTNET_ROOT -And $(Test-Path "$Env:DOTNET_ROOT")) {
        $DotnetInstallDir = $Env:DOTNET_ROOT
    } else {
        $DotnetInstallDir = Join-Path -Path $Env:Programfiles -ChildPath "dotnet"
    }
}
if (-Not $(Test-Path "$DotnetInstallDir")) {
    Write-Error "No installed dotnet '$DotnetInstallDir'."
}

# Check installed dotnet version
$DotnetCommand = "$DotnetInstallDir\dotnet"
if (Get-Command $DotnetCommand -ErrorAction SilentlyContinue)
{
    $DotnetVersion = Invoke-Expression "& '$DotnetCommand' --version"
    $VersionSplitSymbol = '.'
    $SplitVersion = $DotnetVersion.Split($VersionSplitSymbol);
    if ($SplitVersion[0] -ne $SupportedDotnetVersion)
    {
        Write-Host "Current .NET version is $DotnetVersion. .NET 6.0 SDK is required."
        Exit 0
    }
    $DotnetVersionBand = $SplitVersion[0] + $VersionSplitSymbol + $SplitVersion[1] + $VersionSplitSymbol + $SplitVersion[2][0] + "00"
    $ManifestName = "$ManifestBaseName-$DotnetVersionBand"
}
else
{
    Write-Error "'$DotnetCommand' occurs an error."
}

if ($DotnetTargetVersionBand -eq "<auto>") {
    $DotnetTargetVersionBand = $DotnetVersionBand
}

# Check latest version of manifest.
if ($Version -eq "<latest>") {
    $Version = Get-LatestVersion -Id $ManifestName
}

# Check workload manifest directory.
$ManifestDir = Join-Path -Path $DotnetInstallDir -ChildPath "sdk-manifests" | Join-Path -ChildPath $DotnetTargetVersionBand
$TizenManifestDir = Join-Path -Path $ManifestDir -ChildPath "samsung.net.sdk.tizen"
$TizenManifestFile = Join-Path -Path $TizenManifestDir -ChildPath "WorkloadManifest.json"
Ensur-Directory $ManifestDir

# Check and remove already installed old version.
if (Test-Path $TizenManifestFile) {
    $ManifestJson = $(Get-Content $TizenManifestFile | ConvertFrom-Json)
    $OldVersion = $ManifestJson.version
    if ($OldVersion -ne $Version) {
        Write-Host "Removing $ManifestName/$OldVersion from $ManifestDir..."
        Remove-Pack -Id $ManifestName -Version $OldVersion -Kind "manifest"
        $ManifestJson.packs.PSObject.Properties | ForEach-Object {
            Write-Host "Removing $($_.Name)/$($_.Value.version)..."
            Remove-Pack -Id $_.Name -Version $_.Value.version -Kind $_.Value.kind
        }
    } else {
        Write-Host "$Version version is already installed."
        Exit 0
    }
}

$TempDir = $(New-TemporaryDirectory)

# Install workload manifest.
Write-Host "Installing $ManifestName/$Version to $ManifestDir..."
Install-Pack -Id $ManifestName -Version $Version -Kind "manifest"

# Download and install workload packs.
$NewManifestJson = $(Get-Content $TizenManifestFile | ConvertFrom-Json)
$NewManifestJson.packs.PSObject.Properties | ForEach-Object {
    Write-Host "Installing $($_.Name)/$($_.Value.version)..."
    Install-Pack -Id $_.Name -Version $_.Value.version -Kind $_.Value.kind
}

# Add tizen to the installed workload metadata.
New-Item -Path $(Join-Path -Path $DotnetInstallDir -ChildPath "metadata\workloads\$DotnetTargetVersionBand\InstalledWorkloads\tizen") -Force | Out-Null
if (Test-Path $(Join-Path -Path $DotnetInstallDir -ChildPath "metadata\workloads\$DotnetTargetVersionBand\InstallerType\msi")) {
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\dotnet\InstalledWorkloads\Standalone\x64\$DotnetTargetVersionBand\tizen" -Force | Out-Null
}

# Clean up
Remove-Item -Path $TempDir -Force -Recurse
