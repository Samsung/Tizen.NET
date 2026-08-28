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
download a 404. Add the entry *after* the release, not before — see commit
`chore: add 10.0.300 -> 10.0.127 to version map`.

## test-version-band

`Generate-InstallScripts.ps1 -Check` only compares the generated version-map block, so it cannot
see problems elsewhere in the installers. Several extra guards cover that gap:

* [`test-version-band.sh`](./test-version-band.sh) asserts the SDK-version → feature-band mapping
  (for example `11.0.100-preview.7.26381.103` → `11.0.100-preview.7`). It extracts the bash
  implementation from `workload-install.sh` and the PowerShell one from `workload-install.ps1`,
  in both cases between the `BEGIN/END VERSION BAND DETECTION` markers, and additionally compares
  both against `Config.mk`'s `DOTNET_VERSION_BAND`. Extracting the real code — rather than
  reimplementing it in the test — is what lets the test detect the two installers drifting apart.
  It also pins the manifest fallback band family and `DOTNET_DESTDIR` band isolation.
  **Keep those markers intact.**
* [`test-template-conditions.sh`](./test-template-conditions.sh) extracts the template's platform
  detection `PropertyGroup` (between the `BEGIN/END TIZEN UI PLATFORM DETECTION` markers) and
  pins it across 13 TFMs.
* [`test-install-failure.sh`](./test-install-failure.sh) pins installer exit codes: a failed
  install must exit non-zero rather than printing `DONE` and exiting 0.
* `test-matrix.sh --self-test` pins matrix row selection without needing a dotnet install.
* `Generate-InstallScripts.ps1` additionally verifies both installers contain no NUL bytes and
  end with their expected final statement. Both scripts had previously been committed truncated
  mid-statement and NUL-padded, which the version-map drift check reported as "OK".

Run everything at once with:

```
make -C workload check
```

`pwsh` is required for the drift/integrity checks. Without it `make check` fails with an
actionable message; use `make check SKIP_PWSH_CHECKS=1` to proceed with those unverified.

### Why

Previously, the same ~36 entries were maintained by hand in two different languages
(bash array and PowerShell ordered hashtable). This was a common source of mistakes —
see e.g. commit `f43fb9d Revert updating version map for 7.0.400`, and divergences
between `.sh` and `.ps1` for the same SDK band.
