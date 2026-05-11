<#
.SYNOPSIS
    Regenerates the LatestVersionMap sections of workload-install.sh / workload-install.ps1
    from the single source of truth (version-map.json).

.DESCRIPTION
    The pair of install scripts used to duplicate a 36+ entry version map manually.
    This script owns that duplication: edit version-map.json, run this script, commit.
    CI uses `-Check` mode to fail the build if the scripts drift from the JSON.

.PARAMETER Check
    Do not modify files. Exits with code 1 if either script differs from what would
    be generated, printing a unified diff. Used by validate-version-map.yml.

.EXAMPLE
    # Regenerate (developer workflow):
    pwsh ./workload/scripts/Generate-InstallScripts.ps1

    # CI drift detection:
    pwsh ./workload/scripts/Generate-InstallScripts.ps1 -Check

.NOTES
    Compatible with PowerShell 7.2+ (pwsh) on Linux/macOS/Windows.
#>
[CmdletBinding()]
param(
    [switch]$Check
)

$ErrorActionPreference = 'Stop'

$ScriptDir  = Split-Path -Parent $PSCommandPath
$MapPath    = Join-Path $ScriptDir 'version-map.json'
$ShPath     = Join-Path $ScriptDir 'workload-install.sh'
$Ps1Path    = Join-Path $ScriptDir 'workload-install.ps1'

$BeginMarker = '# BEGIN AUTO-GENERATED VERSION MAP -- edit version-map.json and rerun Generate-InstallScripts.ps1'
$EndMarker   = '# END AUTO-GENERATED VERSION MAP'

function Read-Map {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        throw "version-map.json not found at $Path"
    }
    $raw = Get-Content -Raw -LiteralPath $Path
    $obj = $raw | ConvertFrom-Json
    if (-not $obj.manifestBaseName) { throw "manifestBaseName missing in $Path" }
    if (-not $obj.entries)          { throw "entries[] missing in $Path" }

    # Sanity: no duplicate sdkBand
    $bands = $obj.entries | ForEach-Object { $_.sdkBand }
    $dupes = $bands | Group-Object | Where-Object Count -gt 1
    if ($dupes) {
        throw "Duplicate sdkBand entries: $($dupes.Name -join ', ')"
    }

    return $obj
}

function Get-PaddedColumn {
    param([object[]]$Entries, [string]$Property)
    $max = 0
    foreach ($e in $Entries) {
        $len = $e.$Property.Length
        if ($len -gt $max) { $max = $len }
    }
    return $max
}

function Build-ShBlock {
    # IMPORTANT: no column padding here. bash array entries are plain strings and
    # the runtime lookup uses `${index%%=*}`, so any trailing whitespace between
    # the key and `=` would end up inside the key and break matching.
    param($Map)
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add($BeginMarker) | Out-Null
    $lines.Add('LatestVersionMap=(') | Out-Null
    foreach ($e in $Map.entries) {
        $lines.Add(('    "$MANIFEST_BASE_NAME-{0}={1}"' -f $e.sdkBand, $e.workloadVersion)) | Out-Null
    }
    $lines.Add('    )') | Out-Null
    $lines.Add($EndMarker) | Out-Null
    return ($lines -join "`n")
}

function Build-Ps1Block {
    param($Map)
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add($BeginMarker) | Out-Null
    $lines.Add('$LatestVersionMap = [ordered]@{') | Out-Null
    $padBand = Get-PaddedColumn -Entries $Map.entries -Property sdkBand
    $max = $Map.entries.Count
    for ($i = 0; $i -lt $max; $i++) {
        $e = $Map.entries[$i]
        $left = '"$ManifestBaseName-{0}"' -f $e.sdkBand
        $pad  = ' ' * ($padBand - $e.sdkBand.Length)
        $sep  = if ($i -lt $max - 1) { ';' } else { '' }
        $lines.Add(('    {0}{1} = "{2}"{3}' -f $left, $pad, $e.workloadVersion, $sep)) | Out-Null
    }
    $lines.Add('}') | Out-Null
    $lines.Add($EndMarker) | Out-Null
    return ($lines -join "`n")
}

function Replace-Block {
    param(
        [string]$FilePath,
        [string]$NewBlock,
        [string]$LineEnding  # "LF" or "CRLF"
    )
    if (-not (Test-Path $FilePath)) {
        throw "Target script not found: $FilePath"
    }
    $raw = Get-Content -Raw -LiteralPath $FilePath

    $escBegin = [regex]::Escape($BeginMarker)
    $escEnd   = [regex]::Escape($EndMarker)
    # Match begin marker up to and including end marker, spanning lines.
    $pattern  = "(?s)$escBegin.*?$escEnd"

    if (-not ($raw -match $pattern)) {
        throw @"
Markers not found in $FilePath.
Expected a block delimited by:
  $BeginMarker
  ...
  $EndMarker
Please add these markers around the existing LatestVersionMap block, then rerun.
"@
    }

    $ending = if ($LineEnding -eq 'CRLF') { "`r`n" } else { "`n" }
    $normalized = $NewBlock -replace "`r`n", "`n" -replace "`n", $ending

    # Preserve original file's trailing newline behavior.
    $replaced = [regex]::Replace($raw, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $normalized }, 1)
    return $replaced
}

function Detect-LineEnding {
    param([string]$Path)
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    for ($i = 0; $i -lt [Math]::Min($bytes.Length, 8192); $i++) {
        if ($bytes[$i] -eq 0x0D) { return 'CRLF' }
        if ($bytes[$i] -eq 0x0A) { return 'LF' }
    }
    return 'LF'
}

function Write-Or-Check {
    param(
        [string]$Path,
        [string]$NewContent,
        [switch]$CheckOnly
    )
    $current = Get-Content -Raw -LiteralPath $Path
    if ($current -eq $NewContent) {
        Write-Host "  OK: $Path is up-to-date." -ForegroundColor Green
        return $true
    }
    if ($CheckOnly) {
        Write-Host "  DRIFT: $Path is out of sync with version-map.json" -ForegroundColor Red
        # Print a minimal diff hint: show only the changed region lines
        $curLines = $current -split "`r?`n"
        $newLines = $NewContent -split "`r?`n"
        $curStart = ($curLines | Select-String -Pattern ([regex]::Escape($BeginMarker)) | Select-Object -First 1).LineNumber
        $newStart = ($newLines | Select-String -Pattern ([regex]::Escape($BeginMarker)) | Select-Object -First 1).LineNumber
        if ($curStart -and $newStart) {
            Write-Host "    Expected block around line $newStart (generated) vs actual around line $curStart."
        }
        return $false
    }
    # Preserve the file's line ending when writing
    $ending = Detect-LineEnding -Path $Path
    $nl = if ($ending -eq 'CRLF') { "`r`n" } else { "`n" }
    $toWrite = $NewContent -replace "`r`n", "`n" -replace "`n", $nl
    [System.IO.File]::WriteAllText($Path, $toWrite, [System.Text.UTF8Encoding]::new($false))
    Write-Host "  UPDATED: $Path" -ForegroundColor Yellow
    return $true
}

# -----------------------------------------------------------------------------

Write-Host "Loading version-map from: $MapPath"
$map = Read-Map -Path $MapPath
Write-Host ("Loaded {0} entries." -f $map.entries.Count)

$shEnding  = Detect-LineEnding -Path $ShPath
$ps1Ending = Detect-LineEnding -Path $Ps1Path

$shBlock   = Build-ShBlock  -Map $map
$ps1Block  = Build-Ps1Block -Map $map

$shNew     = Replace-Block -FilePath $ShPath  -NewBlock $shBlock  -LineEnding $shEnding
$ps1New    = Replace-Block -FilePath $Ps1Path -NewBlock $ps1Block -LineEnding $ps1Ending

$okSh  = Write-Or-Check -Path $ShPath  -NewContent $shNew  -CheckOnly:$Check
$okPs1 = Write-Or-Check -Path $Ps1Path -NewContent $ps1New -CheckOnly:$Check

if ($Check -and (-not $okSh -or -not $okPs1)) {
    Write-Host ""
    Write-Host "version-map.json and the install scripts are out of sync." -ForegroundColor Red
    Write-Host "Run locally to fix:"
    Write-Host "    pwsh ./workload/scripts/Generate-InstallScripts.ps1"
    exit 1
}

exit 0
