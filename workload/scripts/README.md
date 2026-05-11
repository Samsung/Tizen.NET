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

### Why

Previously, the same ~36 entries were maintained by hand in two different languages
(bash array and PowerShell ordered hashtable). This was a common source of mistakes —
see e.g. commit `f43fb9d Revert updating version map for 7.0.400`, and divergences
between `.sh` and `.ps1` for the same SDK band.
