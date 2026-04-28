# Tizen TFM ↔ Workload ↔ API Level matrix

**Last reviewed:** 2026-04-24

Quick lookup for matching a project's target framework moniker (TFM) with the
right .NET SDK band, Tizen Workload version, Tizen platform version, and the
`Tizen.NET.APInn` package it implicitly depends on.

Use this to diagnose `NETSDK1139` (target platform not recognized) and
`NETSDK1147` (workload missing) errors, and to tell whether a machine's
current install can build a given project.

## TFM naming convention

Tizen TFMs have the form:

```
net<dotnet-version>-tizen<tizen-platform-version>
```

The platform suffix is **required** for formal projects — `net8.0-tizen` without
a version suffix resolves to a generic moniker that does not pin a Tizen.NET.API
version and should be avoided in shipping code. The formal, versioned forms are:

| TFM                 | .NET SDK band | Tizen Workload band | Tizen platform | API Level | Implicit `Tizen.NET.API*` package |
|---------------------|---------------|---------------------|----------------|-----------|-----------------------------------|
| `net6.0-tizen8.0`   | .NET 6 SDK    | `6.0.*`             | 8.0            | 11        | `Tizen.NET.API11`                 |
| `net6.0-tizen9.0`   | .NET 6 SDK    | `6.0.*`             | 9.0            | 12        | `Tizen.NET.API12`                 |
| `net8.0-tizen10.0`  | .NET 8 SDK    | `8.0.*`             | 10.0           | 13        | `Tizen.NET.API13`                 |
| `net8.0-tizen11.0`  | .NET 8 SDK    | `8.0.*`             | 11.0           | 14        | `Tizen.NET.API14`                 |

Unversioned fallbacks that still resolve (via `Tizen.NET.nuspec` dependency groups)
but are not recommended for new project files:

| TFM           | Resolves to |
|---------------|-------------|
| `net6.0-tizen` | latest `net6.0-tizen*` group — currently `Tizen.NET.API12` |
| `net8.0-tizen` | latest `net8.0-tizen*` group — currently `Tizen.NET.API14` |
| `net6.0`       | `Tizen.NET.API12` |
| `net8.0`       | `Tizen.NET.API14` |

(Derived from the `<group targetFramework="…">` entries in `pkg/Tizen.NET/Tizen.NET.nuspec`.)

The Workload version tracks the .NET SDK band — picking `net8.0-tizen11.0` means
the Tizen Workload for the .NET 8 SDK band must be installed; the `tizen11.0`
suffix is a **platform binding**, not a workload selector.

### Reading `dotnet workload list` output correctly

The Tizen workload's `Manifest Version` column looks like `10.0.123/10.0.100`.
The leading `10.0.x` is the **.NET SDK feature band the workload manifest ships
with**, not a new TFM. A `tizen 10.0.*` workload on a machine with only a
.NET 10 SDK does **not** automatically mean `net10.0-tizenX.0` TFMs exist — the
manifest may still only expose the TFMs listed in the matrix above.

To confirm which TFMs a given workload actually exposes, inspect the
`WorkloadManifest.json` on disk. On Windows it lives at:

```
%ProgramFiles%\dotnet\sdk-manifests\<sdk-band>\samsung.net.sdk.tizen\WorkloadManifest.json
```

On Linux / macOS the typical path is:

```
/usr/share/dotnet/sdk-manifests/<sdk-band>/samsung.net.sdk.tizen/WorkloadManifest.json
```

### What the manifest tells you

Inside `WorkloadManifest.json`, the authoritative list is the
`workloads.tizen.packs` array and the `packs` dictionary. Look for entries
of the form `Samsung.Tizen.Ref.API<N>` — each one corresponds to a specific
Tizen platform version:

| Ref pack                  | Matching TFM          | API Level |
|---------------------------|-----------------------|-----------|
| `Samsung.Tizen.Ref.API11` | `net6.0-tizen8.0`     | 11        |
| `Samsung.Tizen.Ref.API12` | `net6.0-tizen9.0`     | 12        |
| `Samsung.Tizen.Ref.API13` | `net8.0-tizen10.0`    | 13        |
| `Samsung.Tizen.Ref.API14` | `net8.0-tizen11.0`    | 14        |

**If an API Ref pack is missing from the installed workload, the matching
TFM will fail to build on that machine — even if the `tizen` workload row
appears in `dotnet workload list`.** Workload manifests lag nuspec updates,
so a freshly-published TFM in `Tizen.NET.nuspec` may not yet have a
corresponding Ref pack in every SDK band's manifest.

The `collect-env.sh` / `collect-env.ps1` scripts that ship with this skill
automatically locate and parse every `samsung.net.sdk.tizen` manifest on
disk and print the Ref pack list under `tizen_workload_manifests:`. Use
that output as the authoritative answer for "can this machine build TFM X?".

### Observed as of 2026-04-24

- `.NET 10` SDK band (`samsung.net.sdk.tizen` manifest version `10.0.123`)
  ships Ref packs for **API11, API12, API13** only — **API14 is not yet
  included**. Projects targeting `net8.0-tizen11.0` therefore cannot be
  built with a .NET 10-only install and the .NET 10 band Tizen workload;
  the user must install the .NET 8 SDK and its matching Tizen workload.

## Installing / updating the Workload

> ⚠️ **The Tizen Workload is NOT on the public dotnet workload feed.**
> The standard commands (`dotnet workload install tizen`,
> `dotnet workload update`) do **not** install or update the Tizen workload.
> You must use the install scripts shipped from the `Samsung/Tizen.NET` repo:

**Linux / macOS / WSL:**

```bash
curl -sSL https://raw.githubusercontent.com/Samsung/Tizen.NET/main/workload/scripts/workload-install.sh | sudo bash
```

**Windows (PowerShell):**

```powershell
Invoke-WebRequest 'https://raw.githubusercontent.com/Samsung/Tizen.NET/main/workload/scripts/workload-install.ps1' -OutFile 'workload-install.ps1'
./workload-install.ps1
```

**Updating** is the same script re-run — there is no separate update command.

After install, verify with the standard commands (these *do* work for inspection):

```bash
dotnet workload list
dotnet --info        # confirms which .NET SDK band the workload was installed against
```

If the project targets `net8.0-tizen11.0` and the machine has both .NET 6 and
.NET 8 SDKs, the workload must be installed for **the .NET 8 SDK**. The Samsung
install script resolves against the currently active `dotnet` (the one
`dotnet --version` prints) — check `dotnet --info` to confirm which SDK will
be patched before running the script.

## Common mismatches and their signatures

| Symptom                                                                                                      | Likely cause                                                                                                       |
|--------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------|
| `NETSDK1139 The target platform identifier tizen was not recognized`                                         | Workload for the active SDK band is not installed.                                                                 |
| `NETSDK1147 To build this project, the following workloads must be installed: tizen`                         | Same as above; .NET 7+ gives a more explicit message.                                                              |
| Build succeeds locally but CI fails with `Tizen.NET.Sdk not found`                                           | CI image is on a different SDK band than local; install the matching workload in the pipeline.                    |
| `Package Tizen.NET.API13 is not compatible with net6.0-tizen9.0`                                             | API Level package version is tied to the TFM's platform suffix — API13 is for `net8.0-tizen10.0`, not `net6.0-*`.  |
| `dotnet workload list` shows `tizen` but `dotnet build` still errors with NETSDK1139                         | `dotnet` on PATH resolves to a *different* SDK than the one the workload was installed against.                    |
| `net8.0-tizen` resolves to the wrong API package                                                             | Unversioned TFM — pin to `net8.0-tizen10.0` or `net8.0-tizen11.0` instead.                                         |
| Machine has `tizen 10.0.*` workload but no .NET 6 / .NET 8 SDK, `net8.0-tizen11.0` build still fails         | `.NET 10` band manifest (`10.0.123` as of 2026-04) ships Ref packs only up to `Samsung.Tizen.Ref.API13` — no `API14`. Install `.NET 8 SDK` and its tizen workload. |
| Workload listed but a specific TFM (e.g. `net8.0-tizen11.0`) refuses to resolve                              | Missing `Samsung.Tizen.Ref.API<N>` pack in that workload's manifest — inspect `WorkloadManifest.json` directly, don't trust `dotnet workload list` alone. |

## Cross-references

- Agent workflow that uses this table: [`../SKILL.md`](../SKILL.md)
- Upstream Workload release notes: <https://github.com/dotnet/sdk/releases>
- TizenFX API Level contract & Tizen.NET.nuspec: <https://github.com/Samsung/TizenFX/blob/main/pkg/Tizen.NET/Tizen.NET.nuspec>

## Maintenance

This reference goes stale whenever a new Tizen Workload or platform version
ships. When updating:

1. Bump the **Last reviewed** date at the top.
2. Cross-check against `pkg/Tizen.NET/Tizen.NET.nuspec` in TizenFX — each
   `<group targetFramework="…">` entry there is the source of truth for the
   TFM ↔ API package mapping.
3. Add a new row to the TFM matrix when a new `net<N>.0-tizen<M>.0` pair is
   published.
4. Capture any newly-observed error signatures in the "Common mismatches" table.
