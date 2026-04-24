#
# Copyright (c) Samsung Electronics. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

<#
.SYNOPSIS
Uninstalls Tizen workload.
.DESCRIPTION
Removes the Tizen WorkloadManifest, workload packs, the file-based workload
marker, and (on MSI-installed .NET SDKs) the HKLM registry entry that
workload-install.ps1 creates so that 'dotnet workload list' shows 'tizen'.

Use this script before running 'dotnet workload install/restore/update' for
other workloads to avoid the MSI lookup failure that causes those operations
to roll back. After you are done, reinstall the Tizen workload with
workload-install.ps1.

Must be run with administrator privileges when the .NET SDK was installed
via the Windows MSI (the default location under %ProgramFiles%\dotnet).
.PARAMETER DotnetInstallDir
Dotnet SDK location (default: $env:DOTNET_ROOT, or %ProgramFiles%\dotnet).
.PARAMETER DotnetTargetVersionBand
Explicit SDK version band to uninstall from (e.g. '8.0.400'). If omitted,
the script iterates over every installed .NET 6+ SDK and removes the Tizen
workload from each matching band.
#>

[cmdletbinding()]
param(
    [Alias('d')][string]$DotnetInstallDir="<auto>",
    [Alias('t')][string]$DotnetTargetVersionBand="<auto>"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$ManifestBaseName = "Samsung.NET.Sdk.Tizen.Manifest"

function Ensure-Writable([string]$TestDir) {
    if (-Not (Test-Path $TestDir)) { return }
    Try {
        [io.file]::OpenWrite($(Join-Path -Path $TestDir -ChildPath ".test-write-access")).Close()
        Remove-Item -Path $(Join-Path -Path $TestDir -ChildPath ".test-write-access") -Force
    }
    Catch [System.UnauthorizedAccessException] {
        Write-Error "No permission to uninstall from '$TestDir'. Try run with administrator mode."
    }
}

function Remove-Pack([string]$Id, [string]$Version, [string]$Kind) {
    switch ($Kind) {
        "manifest" {
            if (Test-Path $TizenManifestDir) {
                Write-Host "Removing manifest $Id/$Version..."
                Remove-Item -Path $TizenManifestDir -Recurse -Force
            }
        }
        {($_ -eq "sdk") -or ($_ -eq "framework")} {
            if ( ($Kind -eq "sdk") -and ($Id -match ".net[0-9]+$")) {
                $Id = $Id -replace (".net[0-9]+", "")
            }
            $TargetDirectory = $(Join-Path -Path $DotnetInstallDir -ChildPath "packs\$Id\$Version")
            if (Test-Path $TargetDirectory) {
                Write-Host "Removing pack $Id/$Version..."
                Remove-Item -Path $TargetDirectory -Recurse -Force
                # Remove the pack's parent folder if it becomes empty.
                $ParentDir = Split-Path -Parent $TargetDirectory
                if ((Test-Path $ParentDir) -and ((Get-ChildItem -Path $ParentDir -Force | Measure-Object).Count -eq 0)) {
                    Remove-Item -Path $ParentDir -Force
                }
            }
        }
        "template" {
            $TargetFileName = "$Id.$Version.nupkg".ToLower()
            $TargetFile = $(Join-Path -Path $DotnetInstallDir -ChildPath "template-packs\$TargetFileName")
            if (Test-Path $TargetFile) {
                Write-Host "Removing template $Id/$Version..."
                Remove-Item -Path $TargetFile -Force
            }
        }
    }
}

function Uninstall-TizenWorkload([string]$DotnetVersion)
{
    $VersionSplitSymbol = '.'
    $SplitVersion = $DotnetVersion.Split($VersionSplitSymbol)

    $CurrentDotnetVersion = [Version]"$($SplitVersion[0]).$($SplitVersion[1])"
    $DotnetVersionBand = $SplitVersion[0] + $VersionSplitSymbol + $SplitVersion[1] + $VersionSplitSymbol + $SplitVersion[2][0] + "00"
    $ManifestName = "$ManifestBaseName-$DotnetVersionBand"

    # Resolve target band. A locally-scoped copy of the script-level parameter.
    $TargetBand = $DotnetTargetVersionBand
    if ($TargetBand -eq "<auto>") {
        if ($CurrentDotnetVersion -ge "7.0")
        {
            $IsPreviewVersion = $DotnetVersion.Contains("-preview") -or $DotnetVersion.Contains("-rc") -or $DotnetVersion.Contains("-alpha")
            if ($IsPreviewVersion -and ($SplitVersion.Count -ge 4)) {
                $TargetBand = $DotnetVersionBand + $SplitVersion[2].SubString(3) + $VersionSplitSymbol + $($SplitVersion[3])
                $ManifestName = "$ManifestBaseName-$TargetBand"
            }
            elseif ($DotnetVersion.Contains("-rtm") -and ($SplitVersion.Count -ge 3)) {
                $TargetBand = $DotnetVersionBand + $SplitVersion[2].SubString(3)
                $ManifestName = "$ManifestBaseName-$TargetBand"
            }
            else {
                $TargetBand = $DotnetVersionBand
            }
        }
        else {
            $TargetBand = $DotnetVersionBand
        }
    }

    # Locate Tizen workload manifest.
    $ManifestDir = Join-Path -Path $DotnetInstallDir -ChildPath "sdk-manifests" | Join-Path -ChildPath $TargetBand
    $TizenManifestDir = Join-Path -Path $ManifestDir -ChildPath "samsung.net.sdk.tizen"
    $TizenManifestFile = Join-Path -Path $TizenManifestDir -ChildPath "WorkloadManifest.json"

    $Found = $false

    # Remove packs declared by the manifest, then the manifest itself.
    if (Test-Path $TizenManifestFile) {
        $Found = $true
        Ensure-Writable $ManifestDir
        Try {
            $ManifestJson = $(Get-Content $TizenManifestFile | ConvertFrom-Json)
            $InstalledVersion = $ManifestJson.version
            $ManifestJson.packs.PSObject.Properties | ForEach-Object {
                Remove-Pack -Id $_.Name -Version $_.Value.version -Kind $_.Value.kind
            }
            Remove-Pack -Id $ManifestName -Version $InstalledVersion -Kind "manifest"
        }
        Catch {
            Write-Host "Could not parse manifest at $TizenManifestFile, falling back to directory removal."
            Write-Host "$_"
            Remove-Item -Path $TizenManifestDir -Recurse -Force
        }
    }
    elseif (Test-Path $TizenManifestDir) {
        # Manifest folder exists but WorkloadManifest.json is missing (partial install).
        $Found = $true
        Write-Host "Manifest file missing; removing partial manifest directory $TizenManifestDir..."
        Remove-Item -Path $TizenManifestDir -Recurse -Force
    }

    # Remove the file-based workload marker (independent of manifest band,
    # this marker is always under the non-preview band path).
    $FileBasedMarker = Join-Path -Path $DotnetInstallDir -ChildPath "metadata\workloads\$DotnetVersionBand\InstalledWorkloads\tizen"
    if (Test-Path $FileBasedMarker) {
        $Found = $true
        Write-Host "Removing file-based workload marker..."
        Remove-Item -Path $FileBasedMarker -Force
    }

    # Remove HKLM registry entry written by workload-install.ps1 on MSI-installed SDKs.
    $RegPath = "HKLM:\SOFTWARE\Microsoft\dotnet\InstalledWorkloads\Standalone\x64\$TargetBand\tizen"
    if (Test-Path $RegPath) {
        $Found = $true
        Write-Host "Removing registry entry $RegPath..."
        Try {
            Remove-Item -Path $RegPath -Force
        }
        Catch [System.UnauthorizedAccessException] {
            Write-Error "No permission to remove registry entry. Try run with administrator mode."
        }
    }

    if (-Not $Found) {
        Write-Host "Tizen workload not found for band $TargetBand. Nothing to remove."
    }
    else {
        Write-Host "Done uninstalling Tizen workload for band $TargetBand"
    }
}

# Resolve dotnet install directory.
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

# Enumerate installed SDKs and uninstall Tizen workload from each.
$DotnetCommand = "$DotnetInstallDir\dotnet"
if (Get-Command $DotnetCommand -ErrorAction SilentlyContinue)
{
    $InstalledDotnetSdks = Invoke-Expression "& '$DotnetCommand' --list-sdks | Select-String -Pattern '^6|^7|^8|^9|^10'" | ForEach-Object {$_ -replace (" \[.*","")}
}
else
{
    Write-Error "'$DotnetCommand' occurs an error."
}

if (-Not $InstalledDotnetSdks)
{
    Write-Host "`nNo .NET SDK (6+) found. Nothing to uninstall."
}
else
{
    foreach ($DotnetSdk in $InstalledDotnetSdks)
    {
        try {
            Write-Host "`nCheck Tizen Workload for sdk $DotnetSdk"
            Uninstall-TizenWorkload -DotnetVersion $DotnetSdk
        }
        catch {
            Write-Host "Failed to uninstall Tizen Workload for sdk $DotnetSdk"
            Write-Host "$_"
            Continue
        }
    }
}

Write-Host "`nDone"
