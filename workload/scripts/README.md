# Scripts

## workload-install

This script installs the Tizen workload manifest files and packs to the installed dotnet sdk.

### Usage
On Linux / macOS:
```
workload-install.sh [-v <Version>] [-d <Dotnet SDK Location>] [-t <Dotnet Version Band Target Folder>]
```

On Windows:
```
workload-install.ps1 [-v <Version>] [-d <Dotnet SDK Location>] [-t <Dotnet Version Band Target Folder>]
```

> The `-t` option for an install script is only for testing and verifying a next dotnet version band. <br />
> For example, a developer can install a workload(`7.0.100-preview.6.19`) of dotnet 6.0.2xx version band to 6.0.3xx destination version band folder.<br />
> workload-install.ps1 -v 7.0.100-preview.6.19 -t 6.0.300

If this script is executed in CI environment, you can use `curl` to download the script and execute it.
```
curl -sSL https://raw.githubusercontent.com/Samsung/Tizen.NET/main/workload/scripts/workload-install.sh | bash
```
or
```
curl -sSL https://raw.githubusercontent.com/Samsung/Tizen.NET/main/workload/scripts/workload-install.sh | bash -s -- -v <version> -d <dotnet sdk location>
```

## Editing the version map

The `LatestVersionMap` table used inside `workload-install.sh` and `workload-install.ps1`
is **generated** from a single source of truth: [`version-map.json`](./version-map.json).

To add or update an entry:

1. Edit `workload/scripts/version-map.json`. Only add the new `(sdkBand, workloadVersion)` pair.
2. Regenerate the install scripts:
   ```
   pwsh ./workload/scripts/Generate-InstallScripts.ps1
   ```
3. Commit all three files together (`version-map.json`, `workload-install.sh`, `workload-install.ps1`).

**Do not hand-edit the blocks delimited by**
```
# BEGIN AUTO-GENERATED VERSION MAP
...
# END AUTO-GENERATED VERSION MAP
```
The CI workflow `validate-version-map.yml` runs `Generate-InstallScripts.ps1 -Check`
on every PR and fails if the two scripts have drifted from `version-map.json`.

### When *not* to add an entry

`LatestVersionMap` is a **fallback cache of already-published manifest versions**. It is only
consulted when the live NuGet lookup fails. Adding an entry for an SDK band whose
`Samsung.NET.Sdk.Tizen.Manifest-<band>` package has never been released makes the installer
download a 404. Add the entry *after* the release, not before.

## test-install-failure

`Generate-InstallScripts.ps1 -Check` only compares the generated version-map block, so it cannot
see problems elsewhere in the installers. Two extra guards cover that gap and run from
`validate-version-map.yml` as well:

* [`test-install-failure.sh`](./test-install-failure.sh) drives both installers against stub
  `dotnet` executables and pins their behaviour: a failed install exits non-zero instead of
  printing `DONE`, the version-map fallback resolves to the closest band of the same .NET
  major.minor, the SDK pin disables roll-forward, an upgrade over an existing manifest never
  exposes a second manifest directory, a permission failure leaves the caller's `global.json`
  untouched, and `-u` skips SDK bands that have no Tizen manifest yet. The PowerShell cases run
  when `pwsh` is available and are skipped otherwise.
* `Generate-InstallScripts.ps1` additionally verifies both installers contain no NUL bytes and
  end with their expected final statement, so a truncated script cannot pass the drift check.

Run them locally with:

```
pwsh ./workload/scripts/Generate-InstallScripts.ps1 -Check
bash ./workload/scripts/test-install-failure.sh
```

### Why

Previously, the same ~36 entries were maintained by hand in two different languages
(bash array and PowerShell ordered hashtable). This was a common source of mistakes —
see e.g. commit `f43fb9d Revert updating version map for 7.0.400`, and divergences
between `.sh` and `.ps1` for the same SDK band.
