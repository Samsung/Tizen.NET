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
    [Alias('t')][string]$DotnetTargetVersionBand="<auto>",
    [Alias('u')][switch]$UpdateAllWorkloads
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$ManifestBaseName = "Samsung.NET.Sdk.Tizen.Manifest"

# BEGIN AUTO-GENERATED VERSION MAP -- edit version-map.json and rerun Generate-InstallScripts.ps1
$LatestVersionMap = [ordered]@{
    "$ManifestBaseName-6.0.100"           = "7.0.101";
    "$ManifestBaseName-6.0.200"           = "7.0.100-preview.13.6";
    "$ManifestBaseName-6.0.300"           = "8.0.133";
    "$ManifestBaseName-6.0.400"           = "9.0.104";
    "$ManifestBaseName-7.0.100-preview.6" = "7.0.100-preview.6.14";
    "$ManifestBaseName-7.0.100-preview.7" = "7.0.100-preview.7.20";
    "$ManifestBaseName-7.0.100-rc.1"      = "7.0.100-rc.1.22";
    "$ManifestBaseName-7.0.100-rc.2"      = "7.0.100-rc.2.24";
    "$ManifestBaseName-7.0.100"           = "7.0.103";
    "$ManifestBaseName-7.0.200"           = "7.0.105";
    "$ManifestBaseName-7.0.300"           = "7.0.120";
    "$ManifestBaseName-7.0.400"           = "10.0.119";
    "$ManifestBaseName-8.0.100-alpha.1"   = "7.0.104";
    "$ManifestBaseName-8.0.100-preview.2" = "7.0.106";
    "$ManifestBaseName-8.0.100-preview.3" = "7.0.107";
    "$ManifestBaseName-8.0.100-preview.4" = "7.0.108";
    "$ManifestBaseName-8.0.100-preview.5" = "7.0.110";
    "$ManifestBaseName-8.0.100-preview.6" = "7.0.121";
    "$ManifestBaseName-8.0.100-preview.7" = "7.0.122";
    "$ManifestBaseName-8.0.100-rc.1"      = "7.0.124";
    "$ManifestBaseName-8.0.100-rc.2"      = "7.0.125";
    "$ManifestBaseName-8.0.100-rtm"       = "7.0.127";
    "$ManifestBaseName-8.0.100"           = "8.0.144";
    "$ManifestBaseName-8.0.200"           = "8.0.157";
    "$ManifestBaseName-8.0.300"           = "8.0.156";
    "$ManifestBaseName-8.0.400"           = "10.0.120";
    "$ManifestBaseName-9.0.100-alpha.1"   = "8.0.134";
    "$ManifestBaseName-9.0.100-preview.1" = "8.0.135";
    "$ManifestBaseName-9.0.100-preview.2" = "8.0.137";
    "$ManifestBaseName-9.0.100-preview.3" = "8.0.148";
    "$ManifestBaseName-9.0.100-rc.1"      = "8.0.152";
    "$ManifestBaseName-9.0.100"           = "10.0.104";
    "$ManifestBaseName-9.0.200"           = "10.0.110";
    "$ManifestBaseName-9.0.300"           = "10.0.121";
    "$ManifestBaseName-10.0.100-rc.2"     = "10.0.118";
    "$ManifestBaseName-10.0.100"          = "10.0.123";
    "$ManifestBaseName-10.0.300"          = "10.0.127"
}
# END AUTO-GENERATED VERSION MAP

function New-TemporaryDirectory {
    $parent = [System.IO.Path]::GetTempPath()
    $name = [System.IO.Path]::GetRandomFileName()
    New-Item -ItemType Directory -Path (Join-Path $parent $name)
}

function Ensure-Directory([string]$TestDir) {
    Try {
        New-Item -ItemType Directory -Path $TestDir -Force -ErrorAction stop | Out-Null
        [io.file]::OpenWrite($(Join-Path -Path $TestDir -ChildPath ".test-write-access")).Close()
        Remove-Item -Path $(Join-Path -Path $TestDir -ChildPath ".test-write-access") -Force
    }
    Catch [System.UnauthorizedAccessException] {
        Write-Error "No permission to install. Try run with administrator mode."
    }
}

function Get-LatestVersion([string]$Id) {
    $attempts=3
    $sleepInSeconds=3
    do
    {
        try
        {
            $Response = Invoke-WebRequest -Uri https://api.nuget.org/v3-flatcontainer/$($Id.ToLowerInvariant())/index.json -UseBasicParsing | ConvertFrom-Json
            $Selected = $Response.versions | Where-Object { $_ -and $_.Trim() } | Select-Object -Last 1
            if ($Selected) {
                return "$Id=$($Selected.Trim())"
            }
            # An empty or all-blank versions[] is NOT a usable answer. Returning "$Id="
            # here would be truthy, and the NuGet v2 package endpoint serves the LATEST
            # version when given a versionless URL - silently installing an arbitrary
            # package. Fall through to the retry/version-map path instead.
            Write-Host "Id: $Id"
            Write-Host "The feed returned no usable versions."
        }
        catch {
            Write-Host "Id: $Id"
            Write-Host "An exception was caught: $($_.Exception.Message)"
        }

        $attempts--
        if ($attempts -gt 0) { Start-Sleep $sleepInSeconds }
    } while ($attempts -gt 0)

    if ($LatestVersionMap.Contains($Id))
    {
        Write-Host "Return cached latest version."
        return "$Id=$($LatestVersionMap.$Id)"
    }
    else
    {
        # Only fall back within the SAME .NET major.minor family.
        #
        # This used to take a fixed-length prefix ($ManifestBaseName.Length + 2), which for
        # '...Manifest-11.0.100-preview.7' yields '...Manifest-1' and therefore matches the
        # 10.x entries too - silently installing a .NET 10 manifest into an 11.x band.
        $BandPrefix = Get-BandFamilyPrefix -ManifestId $Id
        if ($BandPrefix)
        {
            # Choose the CLOSEST band <= the requested one. Taking the last/highest match
            # meant a request for 10.0.200 resolved to 10.0.300 - a NEWER band, whose
            # manifest may not be valid for the requested SDK - while skipping a perfectly
            # good 10.0.200 or 10.0.100. Must match getLatestVersion in workload-install.sh.
            $RequestedBand = $Id.Substring($Id.IndexOf("-") + 1)
            $RequestedKey  = Get-BandSortKey -Band $RequestedBand
            $FallbackId = ""
            $FallbackVersion = ""
            $BestKey = ""
            foreach ($key in $LatestVersionMap.Keys) {
                if ($key -notlike "$BandPrefix*") { continue }
                $CandidateBand = $key.Substring($key.IndexOf("-") + 1)
                $CandidateKey  = Get-BandSortKey -Band $CandidateBand
                if ([string]::Compare($CandidateKey, $RequestedKey, $false) -gt 0) { continue }
                if ($BestKey -eq "" -or [string]::Compare($CandidateKey, $BestKey, $false) -gt 0) {
                    $BestKey = $CandidateKey
                    $FallbackId = $key
                    $FallbackVersion = $LatestVersionMap[$key]
                }
            }
            if ($FallbackId)
            {
                Write-Host "Return fallback version: $FallbackVersion (from $FallbackId)"
                return "$FallbackId=$FallbackVersion"
            }
        }
    }

    Write-Error "Wrong Id: $Id"
}

function Get-Package([string]$Id, [string]$Version, [string]$Destination, [string]$FileExt = "nupkg") {
    $OutFileName = "$Id.$Version.$FileExt"
    $OutFilePath = Join-Path -Path $Destination -ChildPath $OutFileName

    if ($Id -match ".net[0-9]+$") {
        $Id = $Id -replace (".net[0-9]+", "")
    }

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
            if ( ($kind -eq "sdk") -and ($Id -match ".net[0-9]+$")) {
                $Id = $Id -replace (".net[0-9]+", "")
            }
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

# BEGIN VERSION BAND DETECTION -- covered by scripts/test-version-band.sh
# Map a full .NET SDK version to the SDK feature band used for the workload manifest
# directory / NuGet package suffix. Must stay behaviourally identical to
# compute_target_version_band() in workload-install.sh.
function Get-TargetVersionBand([string]$DotnetVersion)
{
    $VersionSplitSymbol = '.'
    $SplitVersion = $DotnetVersion.Split($VersionSplitSymbol)
    $CurrentDotnetVersion = [Version]"$($SplitVersion[0]).$($SplitVersion[1])"
    # Feature bands round the patch component down to the nearest hundred: 10.0.404 -> 10.0.400.
    $DotnetVersionBand = $SplitVersion[0] + $VersionSplitSymbol + $SplitVersion[1] + $VersionSplitSymbol + $SplitVersion[2][0] + "00"

    if ($CurrentDotnetVersion -ge [Version]"7.0")
    {
        $IsPreviewVersion = $DotnetVersion.Contains("-preview") -or $DotnetVersion.Contains("-rc") -or $DotnetVersion.Contains("-alpha")
        if ($IsPreviewVersion -and ($SplitVersion.Count -ge 4)) {
            return $DotnetVersionBand + $SplitVersion[2].SubString(3) + $VersionSplitSymbol + $($SplitVersion[3])
        }
        elseif ($DotnetVersion.Contains("-rtm") -and ($SplitVersion.Count -ge 3)) {
            return $DotnetVersionBand + $SplitVersion[2].SubString(3)
        }
    }
    return $DotnetVersionBand
}

# '<base>-11.0.100-preview.7' -> '<base>-11.0.' so fallback stays inside one .NET major.minor.
function Get-BandFamilyPrefix([string]$ManifestId)
{
    $Match = [regex]::Match($ManifestId, '-(\d+\.\d+)\.')
    if (-not $Match.Success) { return "" }
    return $ManifestId.Substring(0, $ManifestId.IndexOf("-") + 1) + $Match.Groups[1].Value + "."
}
# Comparable sort key for an SDK feature band, e.g. '10.0.300' or '11.0.100-preview.7'.
# Zero-padded so ordinal string comparison orders bands correctly, with pre-release bands
# sorting BEFORE the corresponding stable band ('0' < '1').
function Get-BandSortKey([string]$Band)
{
    $Core = $Band.Split('-')[0]
    $Pre  = if ($Band.Contains('-')) { $Band.Substring($Band.IndexOf('-') + 1) } else { "" }
    $Parts = $Core.Split('.')
    $Major = [int]($Parts[0]); $Minor = [int]($Parts[1]); $Patch = [int]($Parts[2])
    if ($Pre) {
        # Normalise the pre-release so a plain string comparison follows SemVer precedence.
        # Appending it raw made the comparison lexicographic, where "preview.10" sorts
        # BELOW "preview.9" because '1' < '9'. Numeric identifiers are zero-padded and
        # tagged 0, alphanumeric ones tagged 1 (numeric < alphanumeric in SemVer).
        # Must stay byte-identical to band_sort_key() in workload-install.sh.
        $Normalised = ""
        foreach ($Ident in $Pre.Split('.')) {
            if ($Ident -match '^[0-9]+$') {
                $Normalised += '.' + ('0{0:D10}' -f [int]$Ident)
            } else {
                $Normalised += '.1' + $Ident
            }
        }
        return ('{0:D5}{1:D5}{2:D5}0{3}' -f $Major, $Minor, $Patch, $Normalised)
    }
    # No pre-release: sorts above every pre-release of the same core version.
    return ('{0:D5}{1:D5}{2:D5}1' -f $Major, $Minor, $Patch)
}

# END VERSION BAND DETECTION

function Install-TizenWorkload([string]$DotnetVersion)
{
    $VersionSplitSymbol = '.'
    $SplitVersion = $DotnetVersion.Split($VersionSplitSymbol)

    $CurrentDotnetVersion = [Version]"$($SplitVersion[0]).$($SplitVersion[1])"
    $DotnetVersionBand = $SplitVersion[0] + $VersionSplitSymbol + $SplitVersion[1] + $VersionSplitSymbol + $SplitVersion[2][0] + "00"
    $ManifestName = "$ManifestBaseName-$DotnetVersionBand"

    if ($DotnetTargetVersionBand -eq "<auto>" -or $UpdateAllWorkloads.IsPresent) {
        $DotnetTargetVersionBand = Get-TargetVersionBand -DotnetVersion $DotnetVersion
    }
    # The manifest package is named after the band it is FOR, so it must always follow the
    # target band - including an explicitly requested one. Deriving it from the running SDK
    # meant `-Tizen 10.0.200` on a 10.0.100 SDK downloaded the 10.0.100 manifest and
    # installed it into sdk-manifests\10.0.200. Matches workload-install.sh.
    $ManifestName = "$ManifestBaseName-$DotnetTargetVersionBand"

    # Check latest version of manifest.
    #
    # Get-LatestVersion returns "<packageId>=<version>". The id matters: when the
    # requested band has no published manifest we fall back to an earlier band's
    # package, and that version does not exist under the requested id. Both values are
    # kept function-local so an -UpdateAllWorkloads run cannot carry one SDK's fallback
    # package into the next SDK's install.
    if ($Version -eq "<latest>" -or $UpdateAllWorkloads.IsPresent) {
        $Resolved = Get-LatestVersion -Id $ManifestName
        if (-not $Resolved -or -not $Resolved.Contains("=")) {
            throw "Failed to resolve a manifest package for $ManifestName."
        }
        $ResolvedId      = $Resolved.Substring(0, $Resolved.LastIndexOf("="))
        $ResolvedVersion = $Resolved.Substring($Resolved.LastIndexOf("=") + 1)
        # Defence in depth: never proceed with an empty version. The NuGet v2 package
        # endpoint serves the LATEST version when the URL has no version segment, so an
        # empty value would silently install an arbitrary package.
        if ([string]::IsNullOrWhiteSpace($ResolvedId) -or [string]::IsNullOrWhiteSpace($ResolvedVersion)) {
            throw "Resolved an invalid manifest package '$Resolved' for $ManifestName."
        }
        $ManifestName = $ResolvedId
        $Version      = $ResolvedVersion
    }

    # Unconditional gate, regardless of which branch above set $Version.
    #
    # An explicit -Version "" (or whitespace) does not equal "<latest>", so it skips the
    # resolution block entirely and would otherwise reach the manifest REMOVAL below and a
    # versionless NuGet URL - and the v2 package endpoint serves the LATEST package when the
    # URL carries no version segment. Reject before any removal, URL construction or download.
    if ([string]::IsNullOrWhiteSpace($Version)) {
        throw "A manifest version is required. Pass -Version <VERSION>, or '<latest>' to resolve it automatically."
    }
    if ([string]::IsNullOrWhiteSpace($ManifestName)) {
        throw "Could not determine the manifest package id for $DotnetVersion."
    }

    # Check workload manifest directory.
    $ManifestDir = Join-Path -Path $DotnetInstallDir -ChildPath "sdk-manifests" | Join-Path -ChildPath $DotnetTargetVersionBand
    $TizenManifestDir = Join-Path -Path $ManifestDir -ChildPath "samsung.net.sdk.tizen"
    $TizenManifestFile = Join-Path -Path $TizenManifestDir -ChildPath "WorkloadManifest.json"

    # Check and remove already installed old version.
    if (Test-Path $TizenManifestFile) {
        $ManifestJson = $(Get-Content $TizenManifestFile | ConvertFrom-Json)
        $OldVersion = $ManifestJson.version
        if ($OldVersion -eq $Version) {
            $DotnetWorkloadList = Invoke-Expression "& '$DotnetCommand' workload list | Select-String -Pattern '^tizen'"
            if ($DotnetWorkloadList)
            {
                Write-Host "Tizen Workload $Version version is already installed."
                Continue
            }
        }

        Ensure-Directory $ManifestDir
        Write-Host "Removing $ManifestName/$OldVersion from $ManifestDir..."
        Remove-Pack -Id $ManifestName -Version $OldVersion -Kind "manifest"
        $ManifestJson.packs.PSObject.Properties | ForEach-Object {
            Write-Host "Removing $($_.Name)/$($_.Value.version)..."
            Remove-Pack -Id $_.Name -Version $_.Value.version -Kind $_.Value.kind
        }
    }

    Ensure-Directory $ManifestDir
    $TempDir = $(New-TemporaryDirectory)

    # The remove-then-install sequence below is destructive: the previous manifest and its
    # packs are deleted BEFORE the new ones are fetched, so any failure in between used to
    # leave the SDK with no Tizen workload at all - a worse state than before the run. The
    # whole sequence is therefore one transaction, and the previous manifest is restored on
    # any failure. Matches the tx_rollback handling in workload-install.sh.
    $TxBackupDir = $null
    if (Test-Path $TizenManifestDir) {
        $TxBackupDir = Join-Path -Path $TempDir -ChildPath "manifest-backup"
        Copy-Item -Path $TizenManifestDir -Destination $TxBackupDir -Recurse -Force
    }
    $TxCommitted = $false

    try {
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
        # Featured version band for metadata does NOT include any preview specifier.
        # https://github.com/dotnet/sdk/blob/main/documentation/general/workloads/user-local-workloads.md
        New-Item -Path $(Join-Path -Path $DotnetInstallDir -ChildPath "metadata\workloads\$DotnetVersionBand\InstalledWorkloads\tizen") -Force | Out-Null
        if (Test-Path $(Join-Path -Path $DotnetInstallDir -ChildPath "metadata\workloads\$DotnetVersionBand\InstallerType\msi")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\dotnet\InstalledWorkloads\Standalone\x64\$DotnetTargetVersionBand\tizen" -Force | Out-Null
        }
        $TxCommitted = $true
    }
    finally {
        if (-not $TxCommitted) {
            Write-Host "Install failed; rolling back the Tizen manifest."
            if (Test-Path $TizenManifestDir) {
                Remove-Item -Path $TizenManifestDir -Recurse -Force -ErrorAction SilentlyContinue
            }
            if ($TxBackupDir -and (Test-Path $TxBackupDir)) {
                Ensure-Directory $ManifestDir
                Copy-Item -Path $TxBackupDir -Destination $TizenManifestDir -Recurse -Force
            }
        }
        # Clean up
        if (Test-Path $TempDir) { Remove-Item -Path $TempDir -Force -Recurse }
    }

    Write-Host "Done installing Tizen workload $Version"
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
    Write-Host "No installed dotnet '$DotnetInstallDir'."
    exit 1
}

# Check installed dotnet version
$DotnetCommand = "$DotnetInstallDir\dotnet"
if (Get-Command $DotnetCommand -ErrorAction SilentlyContinue)
{
    if ($UpdateAllWorkloads.IsPresent)
    {
        $InstalledDotnetSdks = Invoke-Expression "& '$DotnetCommand' --list-sdks | Select-String -Pattern '^([6-9]|[1-9][0-9]+)\.'" | ForEach-Object {$_ -replace (" \[.*","")}
    }
    else
    {
        $InstalledDotnetSdks = Invoke-Expression "& '$DotnetCommand' --version"
    }
}
else
{
    Write-Host "'$DotnetCommand' occurs an error."
    exit 1
}

if (-Not $InstalledDotnetSdks)
{
    Write-Host "`n.NET SDK version 6 or later is required to install Tizen Workload."
    exit 1
}

# Track per-SDK failures. -UpdateAllWorkloads keeps going across the remaining SDKs,
# but the overall run must still report failure to the caller.
$FailedSdks = @()

foreach ($DotnetSdk in $InstalledDotnetSdks)
{
    try {
        Write-Host "`nCheck Tizen Workload for sdk $DotnetSdk"
        Install-TizenWorkload -DotnetVersion $DotnetSdk
    }
    catch {
        Write-Host "Failed to install Tizen Workload for sdk $DotnetSdk"
        Write-Host "$_"
        $FailedSdks += $DotnetSdk
        Continue
    }
}

if ($FailedSdks.Count -gt 0)
{
    Write-Host "`nFAILED to install Tizen workload for sdk(s): $($FailedSdks -join ', ')"
    exit 1
}

Write-Host "`nDone"
