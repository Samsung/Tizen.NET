# .NET 11 support

This branch builds the `tizen` workload for the .NET 11 SDK band in addition to .NET 10.

At the time of writing .NET 11 is in **preview**: the newest SDK is
`11.0.100-preview.7.26381.103` (released 2026-08-11). Everything below therefore describes a
band that is real and buildable, but whose manifest package has **not been published to
nuget.org yet**.

## TFM and API mapping

The primary target framework is **`net11.0-tizen11.0`**.

| Tizen platform version | TizenFX API level | Targeting (ref) pack | Pack version |
|---|---|---|---|
| `tizen8.0`  | 11 | `Samsung.Tizen.Ref.API11` | `$(TizenFXAPI11Version)` |
| `tizen9.0`  | 12 | `Samsung.Tizen.Ref.API12` | `$(TizenFXAPI12Version)` |
| `tizen10.0` | 13 | `Samsung.Tizen.Ref.API13` | `$(TizenFXAPI13Version)` |
| `tizen10.1` | 14 | `Samsung.Tizen.Ref.API14` | `$(TizenFXAPI14Version)` |
| **`tizen11.0`** | **15** | **`Samsung.Tizen.Ref.API15`** | `$(TizenFXAPI15Version)` |

The .NET version axis and the Tizen platform axis are independent, so `net11.0` combines with
every platform version above — `net11.0-tizen8.0` … `net11.0-tizen11.0` are all valid. The
`tizen-manifest.xml` `api-version` attribute must match the platform version
(`tizen11.0` → `api-version="11"`, `tizen10.1` → `10.1`, `tizen10.0` → `10`).

**No new reference pack is required for .NET 11.** Ref packs ship reference assemblies under
`ref/net8.0/` and are resolved by explicit `<File Path="…"/>` entries in `data/FrameworkList.xml`,
so they are independent of the consuming project's .NET version. `Samsung.Tizen.Ref.API16` does
not exist and is not needed.

Use versioned TFMs. The unversioned `net11.0-tizen` form is still accepted as project input but
resolves to `_DefaultTargetPlatformVersion` (`10.0`), which is rarely what a caller wants.

## Building the .NET 11 band

`DOTNET_VERSION` selects the SDK band; it defaults to
`MicrosoftDotnetSdkInternalPackageVersion` in `build/Versions.props` (currently the .NET 10 band).

```sh
# Produce the packs, including Samsung.NET.Sdk.Tizen.Manifest-11.0.100-preview.7
make packs DOTNET_VERSION=11.0.100-preview.7.26381.103

# Install into the locally bootstrapped SDK and run the full TFM matrix
make test-matrix DOTNET_VERSION=11.0.100-preview.7.26381.103
```

The exact SDK version CI uses lives in `build/Versions.props` as `<DotNet11SdkVersion>`.
That property is the single source of truth: the workflows grep it, so bumping the preview
there is enough. `validate-workload-metadata.py` check C7 fails if a workflow hardcodes a
different `11.0.1xx-*` version.

The band string is derived generically from `DOTNET_VERSION`, so `11.0.100-rc.1.*` and the
eventual `11.0.100` GA need no further code change. This is asserted by
[`scripts/test-version-band.sh`](../scripts/test-version-band.sh).

## CI behaviour

| Branch / PR target | .NET 10 matrix leg | .NET 11 matrix leg | `Build Workload` SDK |
|---|---|---|---|
| `main`, `net10.0` | blocking | advisory (`continue-on-error`) | Versions.props default (.NET 10) |
| `net11.0` | blocking | **blocking** | **`$(DotNet11SdkVersion)`** |

.NET 11 is advisory only while the branch ships a different band. On a `net11.0` branch
.NET 11 *is* the product, so both the matrix leg and the workload build switch to it.

## Local checks

`make check` runs everything that needs no dotnet install or Tizen workload:

| Target | What it pins |
|---|---|
| `validate-metadata` | C1–C8 cross-file consistency |
| `test-matrix-self-test` | matrix row selection (an over-strict check silently builds nothing) |
| `test-version-band` | SDK version → feature band across **both installers and Config.mk**, fallback band family, band isolation |
| `test-template-conditions` | template platform detection across TFMs |
| `test-package-fallback` | fallback filtering, plus selection priority / atomicity in both directory-creation orders |
| `test-release-workflow` | release ordering, retryability, partial-publication resume, failure injection |
| `test-install-failure` | installer exit codes, fallback package **id**, SDK-pin verification, empty/transport responses |
| `Generate-InstallScripts.ps1 -Check` | version-map drift **and** install-script integrity |

`make check` requires `pwsh` for the last row. If it is unavailable the target fails with an
actionable message; `make check SKIP_PWSH_CHECKS=1` proceeds with those checks unverified.

## Band isolation and feature-band rounding

`DOTNET_VERSION` is resolved immediately in `Config.mk`, and `DOTNET_DESTDIR` plus the install
stamp are scoped by band (`out/dotnet-<band>`, `.stamp-install-workload-<band>`). Two
consequences worth knowing:

- Building a different band in an existing tree bootstraps a separate SDK instead of reusing
  the previous one. Previously `DOTNET_VERSION` was cached in `.tmp/dotnet-version.config`
  whose only prerequisite was `Versions.props`; because the cache was newer, make never
  regenerated it and a newly-passed `DOTNET_VERSION` was **ignored**, silently building and
  testing the previous band.
- Feature bands round the patch component down: `10.0.404` → `10.0.400`, `9.0.304` → `9.0.300`.
  `Config.mk` previously did not round for stable non-6 versions, so it produced band
  `10.0.404` while the installers looked for `10.0.400` — the manifest was installed where the
  SDK would never look. `test-version-band.sh` now asserts producer/consumer agreement.

Pass `DOTNET_VERSION` via the environment or omit it. An explicit empty command-line override
(`make DOTNET_VERSION=`) beats the resolved value and yields an empty band.

## Manifest fallback safety

When a band's manifest is not published, the installers fall back to the cached version map.
Two properties are load-bearing:

- **The resolved package ID travels with the version.** `getLatestVersion` /
  `Get-LatestVersion` return `"<packageId>=<version>"`. Returning only a version made the
  caller download that version under the *originally requested* — and unpublished — id: a
  request for `...manifest-10.0.400` resolves to version `10.0.127`, which exists only under
  `...manifest-10.0.300`, so the download 404'd. The manifest is still installed into the
  **requested** band's directory; only the package fetched differs.
- **The fallback is constrained to the same .NET major.minor family**, and the resolved id is
  function-local. The PowerShell installer previously took a fixed-length prefix
  (`$ManifestBaseName.Length + 2`), so `...Manifest-11.0.100-preview.7` was truncated to
  `...Manifest-1`, matched the 10.x entries and installed a **.NET 10 manifest into an 11.x
  band**. It also cached the resolved id in a script-level `$global:FallbackId` that was never
  cleared, so an `-UpdateAllWorkloads` run could carry one SDK's fallback package into the
  next SDK's install. Both are fixed and pinned by `scripts/test-install-failure.sh`.

An 11.x request with no 11.x map entry fails closed.

A manifest version is required unconditionally, whichever branch produced it. An explicit
`-Version ""` (or whitespace) does not equal `"<latest>"`, so it used to bypass resolution and
validation entirely, remove the installed manifest, and construct a **versionless** NuGet URL —
and the v2 package endpoint serves the **latest** package for such a URL. The gate now runs
before any removal, URL construction or download.

The resolved version is validated before use. An empty or all-blank `versions[]` from the feed
is rejected rather than returned as a truthy `"<id>="`: the NuGet v2 package endpoint serves the
**latest** version when given a versionless URL, so an empty version would silently install an
arbitrary package. Both installers fall through to the version map and then fail closed.

The SDK pin is verified before anything is installed. `install_tizenworkload` is invoked under
`if !`, which disables `errexit` for everything it calls, so an unchecked
`dotnet new globaljson` previously let the install proceed against whatever SDK `PATH` resolved.
The pin now uses the dotnet under test, its exit status is checked, and the **effective**
`dotnet --version` and feature band are re-verified against the requested ones before any pack
is installed.

Note the installer must run under **bash 3.2** (macOS ships it and is a supported target, see
`DOTNET_DEFAULT_PATH_MACOS`). The `${var,,}` lowercase expansion is bash 4+ and raised
`bad substitution` there, leaving the version empty and silently skipping the fallback
entirely; a portable `tr` is used instead, and an empty lookup response now takes the same
fallback path as an explicit `BlobNotFound`.

## Package asset resolution

`PackageTargetFallback` in `Samsung.Tizen.Sdk.NuGet.targets` lists the package `lib/<tfm>/`
folder names that `FixupNuGetReferences` prefers over a package's `netstandard2.x` assets.

The task matches those directories **by name only** and performs no compatibility check of its
own, so the list must be filtered to what the project can actually consume. An unfiltered
cross-product lets a `net6.0-tizen8.0` build pick up `net6.0-tizen11.0` (newer platform) or
`net11.0-tizen8.0` (newer .NET) assets. A candidate is emitted only when its .NET version and
its Tizen platform version are both `<=` the project's, and candidates are appended
highest-first so the best compatible match wins the task's first-wins selection.

The filter is built from conditional **properties**, not filtered items: MSBuild evaluates all
top-level properties before any items, so a property referencing `@(item)` at that level
silently expands to nothing.

`PackageTargetFallback` is an **ordered preference list**, and `FixupNuGetReferences` honours
that order: it ranks candidates by their position in the list and selects exactly **one**
fallback TFM per package, taking every substituted assembly from that single directory. It
previously collected all matching directories into an unordered `HashSet` populated in
filesystem-enumeration order and then took assemblies first-wins across them, which could both
ignore the declared priority and mix assemblies from different TFMs within one package.
`scripts/test-package-fallback.sh` builds the candidate directories in **both** creation orders
so the assertion does not depend on how a particular filesystem enumerates.

Check C8 verifies the candidate list covers the full (.NET major × platform) cross-product
*and* that every candidate carries a compatibility condition;
`scripts/test-package-fallback.sh` pins the filtering itself with negative
cross-platform/cross-version assertions.

## What changed in this repository

| File | Change |
|---|---|
| `build/Versions.props` | `MicrosoftDotNetBuildTasksFeedPackageVersion` = `11.0.0-beta.26426.103` when building an `11.0` band |
| `NuGet.config` | added the `dotnet11` package source |
| `src/Samsung.Tizen.Sdk/targets/Samsung.Tizen.Sdk.targets` | added the `net11.0` `KnownRuntimePack` |
| `src/Samsung.NETCore.App.Runtime/data/RuntimeList.xml` | added the `.NET Runtime 11` `FileList` row |
| `src/Samsung.Tizen.Templates/.../template.json` | added the `net11.0` framework choice (default stays `net10.0`) |
| `src/Samsung.Tizen.Templates/tizen/TizenApp1.csproj` | Material referenced conditionally; platform version parsed from the TFM, not `$(TargetPlatformVersion)` (see below) |
| `scripts/test-matrix.sh` | added `net11.0-*` rows; rows are skipped only when newer than the installed SDK; `--self-test` mode |
| `scripts/validate-workload-metadata.py` | new checks C5/C6/C7 |
| `scripts/test-version-band.sh` | new — asserts SDK-version → feature-band mapping for both installers |
| `scripts/test-template-conditions.sh` | new — pins template platform detection across TFMs |
| `scripts/test-install-failure.sh` | new — pins installer exit codes |
| `scripts/test-package-fallback.sh` | new — pins `PackageTargetFallback` compatibility filtering |
| `.github/workflows/build-matrix.yml` | .NET 11 leg, advisory off a `net11.0` branch and blocking on one |
| `.github/workflows/build-workload.yml` | builds against `$(DotNet11SdkVersion)` on a `net11.0` branch |
| `.github/workflows/release-workload.yml` | notes reuse the staging step's verified band / manifest id |

### Template platform detection

`PackageReference` items are evaluated with the project body, which runs **before** the .NET
SDK infers `$(TargetPlatformVersion)` from the TFM. Reading that property in the body yields an
empty string, so a naive implementation falls back to the default and pulls an incompatible
`Tizen.UI.Components.Material` into e.g. `net11.0-tizen9.0` while never raising `TIZENTMPL001`.
The template therefore parses the platform version out of `$(TargetFramework)` directly, and
re-checks the authoritative `$(TargetPlatformVersion)` inside a target where it is available.
`scripts/test-template-conditions.sh` extracts the shipped `PropertyGroup` and pins the
behaviour across 13 TFMs.

`version-map.json` is deliberately **not** updated. That table is a fallback cache of *already
published* manifest versions, consulted only when the NuGet lookup fails. Adding an entry for a
band that has never been released would make `workload-install.sh` download a 404. The
`11.0.100-preview.7` entry should be added in a follow-up commit *after* the first release, the
same way `10.0.300` was.

## External blockers

These artifacts are owned by other repositories. Nothing in Samsung/Tizen.NET can fix them, and
they are not faked here.

### 1. `Samsung.NET.Sdk.Tizen.Manifest-11.0.100-preview.7` is unpublished

- **Owner:** Samsung/Tizen.NET maintainers (this repo's `Release Workload` workflow).
- **Action:** run `Release Workload` with `net_sdk_version = 11.0.100-preview.7.26381.103`.
- **Until then:** `workload-install.sh` on an 11.x SDK finds no manifest. Local development works
  via `make install DOTNET_VERSION=11.0.100-preview.7.26381.103`, which installs into the
  bootstrapped SDK under `workload/out/dotnet`.

### 2. `Tizen.UIExtensions.NUI` has no modern assets

- **Owner:** [Samsung/Tizen.UIExtensions](https://github.com/Samsung/Tizen.UIExtensions).
- **Published state:** `0.9.2` ships `lib/net6.0-tizen7.0/` and `lib/tizen10.0/`. Source on `main`
  targets `<TargetFrameworks>tizen10.0;net6.0-tizen</TargetFrameworks>` against
  `Tizen.NET 10.0.0.17508` (API level 10).
- **Note:** NuGet TFM compatibility is *not* the problem — `net6.0-tizen7.0` is consumable from
  `net11.0-tizen11.0`. The blocker is the dependency group, which pins
  `Microsoft.Maui.Graphics` / `Microsoft.Maui.Graphics.Skia` `6.0.300-rc.3.1336` and
  `SkiaSharp.Views 2.88.6`, dragging .NET 6-era MAUI Graphics into any modern MAUI build.
- **Expected artifact:** a `Tizen.UIExtensions.NUI` release with a `lib/net11.0-tizen11.0/` folder
  built against `Samsung.Tizen.Ref.API15` and a refreshed `Microsoft.Maui.Graphics*` dependency.
- **API risk, measured:** all types .NET MAUI's Tizen backend needs are present in API 15. Between
  API 11 and API 15, `Tizen.NUI.ScrollView`, `Tizen.NUI.ItemView` (and the `Item*`/`Ruler*`
  families), `Tizen.NUI.Components.Title`, `Tizen.NUI.Adaptor`, `Tizen.NUI.AutofillContainer`,
  `Tizen.NUI.Accessibility.AccessibilityManager`, the `CubeTransition*` effects and the entire
  `Tizen.NUI.Wearable` namespace were removed. Ports should use
  `Tizen.NUI.Components.ScrollableBase`, which is retained.

### 3. `Tizen.UI.Components.Material` is platform-gated

- **Owner:** TizenAPI / Samsung (package `Tizen.UI.Components.Material`).
- **Published state:** `1.0.0-rc.8` ships **only** `lib/net8.0-tizen10.0/`; never went GA.
- **Effect:** consumable from `-tizen10.0`, `-tizen10.1` and `-tizen11.0`, but not from
  `-tizen8.0` / `-tizen9.0`. The `dotnet new tizen` template now references it conditionally and
  raises `TIZENTMPL001` with an actionable message instead of an opaque restore failure when the
  target platform is below `tizen10.0`.
- **Expected artifact:** a release with `lib/` assets for the lower platform bands, or a separate
  non-Material template family for them.

## Notes for release notes
Observations from porting a real consumer (`Samsung/Tizen.UIExtensions`) onto this band:

- **`net6.0-tizen7.0` is no longer reproducible.** `Samsung.Tizen.Sdk` dropped `7.0` from
  `TizenSdkSupportedTargetPlatformVersion` (now `8.0`/`9.0`/`10.0`/`10.1`/`11.0`), so packages
  that historically shipped a `net6.0-tizen7.0` asset cannot rebuild one.
- **Unversioned `net6.0-tizen` now resolves to platform 10.0** (`_DefaultTargetPlatformVersion`),
  i.e. TizenFX API 13, where all of ElmSharp and `Tizen.NUI.Window.Instance` are `[Obsolete]`.
  Consumers building that TFM with `TreatWarningsAsErrors` will break. Use a versioned TFM.
- **`tizen.myget.org` returns HTTP 401 to anonymous clients.** The feed is still referenced as a
  push target in `build-workload.yml`'s deploy job. Any documentation or template still pointing
  consumers at it for *restore* is dead; worth confirming whether the push target is still wanted.

## `RuntimeList.xml` and self-contained publishing

`src/Samsung.NETCore.App.Runtime/data/RuntimeList.xml` previously contained one
`<FileList .../>` element per supported .NET version, i.e. **multiple root elements**, which
is not well-formed XML.

**This file is parsed.** `Microsoft.NET.Build.Tasks` contains the literal `RuntimeList.xml`
alongside the runtime-pack manifest fields it reads (`Managed`, `Native`, `PgoData`,
`Resources`, `AssemblyVersion`, `FileVersion`, `PublicKeyToken`), i.e.
`ResolveRuntimePackAssets` reads it whenever runtime pack assets are resolved — notably for
`SelfContained=true`. An earlier note in this file claimed it was never parsed; that claim was
based on a framework-dependent RID build, which does not reach that task. **It was wrong and is
retracted.**

Both remediations are applied:

1. **The file is now well-formed** — a single `<FileList>` root. The pack is a placeholder that
   ships no runtime binaries (its only payload is `lib/net6.0-tizen/_._`), so the list is
   legitimately empty.
2. **Explicitly requested self-contained Tizen publishing is rejected up front** with
   `TIZENSDK001`, explaining that Tizen applications run against the platform-provided runtime.
   Without it, the build failed with the opaque `NETSDK1083: The specified RuntimeIdentifier
   'tizen' is not recognized`.

The guard (`_TizenErrorOnSelfContained` in `Samsung.Tizen.Sdk.targets`) gates on the SDK's
`_SelfContainedWasSpecified`, **not** on the final `$(SelfContained)` value, and this distinction
is load-bearing. The .NET SDK (`Microsoft.NET.RuntimeIdentifierInference.targets`) still *infers*
`SelfContained=true` from a present `RuntimeIdentifier` on pre-8.0 TFMs, and the Tizen SDK
supplies an implicit RID (`tizen-x86`) for MAUI apps. Gating on the inferred `$(SelfContained)`
therefore mis-classified an ordinary **framework-dependent** `net6.0-tizen` / `net7.0-tizen` build
— exactly what every existing .NET MAUI Tizen consumer does — as self-contained and broke it.
`_SelfContainedWasSpecified` is set by the SDK only when self-contained was *explicitly* requested
(`-p:SelfContained=true`, or `PublishSelfContained=true` during publish, which the SDK copies onto
`SelfContained` before computing `_SelfContainedWasSpecified`), so the guard now fires on explicit
requests only.

Verified empirically on `11.0.100-preview.7.26381.103` (`dotnet msbuild -nodereuse:false`,
`OutputType=Exe`, implicit RID `tizen-x86`):

| Build | inferred `SelfContained` | `_SelfContainedWasSpecified` | TIZENSDK001 |
| --- | --- | --- | --- |
| `net6.0-tizen`, framework-dependent | `true` | *(empty)* | **no** (was wrongly yes) |
| `net7.0-tizen`, framework-dependent | `true` | *(empty)* | **no** (was wrongly yes) |
| `net8.0`–`net11.0-tizen*`, framework-dependent | `false` | *(empty)* | no |
| any `-tizen*` with `-p:SelfContained=true` | `true` | `true` | **yes** |
| any `-tizen*` publish `-p:PublishSelfContained=true` | `true` | `true` | **yes** |

`SkipTizenSelfContainedCheck=true` bypasses the guard for anyone supplying a runtime by other
means. These behaviours are locked down by `test-template-conditions.sh`, which extracts the real
guard `<Target>` from the shipped targets and asserts each row above without needing the Tizen
workload.

**Scope note, stated precisely:** with the guard bypassed *and* the old malformed file restored,
this configuration failed at `NETSDK1083` (RID resolution) *before* reaching
`ResolveRuntimePackAssets`, so a raw `XmlException` could not be reproduced on this SDK. The
malformed file was nevertheless a latent hazard on any path that does reach that task, and both
fixes are correct regardless of which error surfaces first.

Check C6 now parses the file with a real XML parser and asserts the `TIZENSDK001` guard exists;
`test-matrix.sh` additionally asserts the runtime disposition end to end.

## Release retryability

The release workflow **reserves first, then builds**:

1. resolve the version (no mutation yet) and pin it as one immutable candidate,
2. create the release commit and **reserve** it globally,
3. check out the reserved SHA explicitly and build from *that* commit only,
4. verify every staged package carries the reserved SHA,
5. push packages from the verified staging directory,
6. create the tag, targeting the reserved SHA.

> **This deliberately reverses the earlier "commit only after a verified build" ordering.**
> That ordering was adopted to keep a failed release retryable, but it cannot hold once a
> resume has to rebuild: the Makefile embeds the current Git SHA in every package, so an
> initial run and its retry produced packages built from *different* commits, and
> skip-duplicate happily preserved that mixed set under a tag pointing at only one of them.
> Retryability now comes from the **reservation**, not from deferring the commit — the
> reserved SHA is the single source of truth that both the first attempt and every retry
> build from, so provenance is identical by construction.

`OLD == NEW` is not an error. `next-workload-version.py` derives the next version from what is
published on NuGet, so when the branch already carries the intended still-unpublished version
the run resumes it; there is simply nothing to commit, and the current HEAD *is* the release
commit, so it is reserved as-is. Re-creating an existing tag is a no-op.

### What a reservation records

A reservation used to be nothing but a ref pointing at a commit. That answers *"is this
version taken"* but not *"is this run allowed to continue it"*, and both gaps were real:

* **Re-runs could never resume their own release.** `Re-run jobs` checks out the SHA of the
  *original* event — the commit *before* the version bump — so the version read from
  `Versions.props` was the previous, already-released one. The re-run concluded there was
  nothing to resume, recomputed the same candidate, found its own reservation ref and
  aborted as though a stranger held it. An interrupted release was permanently unfinishable.
* **Nothing tied a reservation to the inputs it was made for**, so re-dispatching with a
  different `net_sdk_version` would adopt a reservation created for another band.

`refs/tizen-release/v<V>` is therefore an *annotated tag object* whose message carries the
complete release input set — version, reserved SHA, SDK, band, manifest id, package set and
branch (`scripts/release-reservation.py`). Resume is decided by **enumerating** those refs
and matching them against the current run's inputs; the checked-out SHA is no longer used
for that decision at all. A reservation that does not match every input is skipped, and one
that predates the payload format cannot be validated and so is refused rather than trusted.
Two unfinished reservations matching the same inputs is an error, not a guess.

An existing tag is only accepted as "already done" when it resolves to the reserved commit.
Treating mere existence as done would bless a release whose tag targets a different tree
than the packages that were published.

### Reservation and concurrency

Two branches or bands releasing at once could previously select the same next version, both
push, and let skip-duplicate silently accept one owner's packs while the other's were dropped.
Ownership is now explicit:

* the job takes a repository-wide `concurrency` group (`cancel-in-progress: false`),
* it claims `refs/tizen-release/v<version>` with an atomic create — losing the race aborts,
* a retry must **prove** it owns the reservation (the ref must point at its release SHA);
  a foreign reservation aborts rather than publishing over someone else's version.

Because `workflow_dispatch` re-runs check out the *original* event SHA rather than the pushed
bump commit, every downstream step checks out the reserved SHA explicitly and rejects source
drift instead of silently building the wrong tree.

A reference-only run (`release_manifest=false`) publishes no manifest and is completely
non-mutating: no bump, no commit, no tag.

### Resuming a partially published release

Publication is not atomic: the companion packs, the manifest, the tag and the GitHub release
are separate steps. If one fails partway, version V is *partially* published — and because
`next-workload-version.py` derives the next version from what exists on NuGet, it then answers
V+1. Advancing at that point strands V permanently with no tag, no release and a missing pack
set.

`scripts/release-state.py` makes that state explicit (`unpublished` / `partial` / `published`),
and the workflow resumes V unless it is provably complete:

| State of the branch's version | Action |
|---|---|
| `partial` | **always resume V** — never advance |
| `published` but no tag/release | resume V to finish the tag/release |
| `unpublished` and branch already carries it | resume V |
| `published` **and** released | safe to compute V+1 |

Two supporting properties:

* **The manifest is published last.** It is what `next-workload-version.py` keys off, so
  publishing it only after its companion packs means an interruption cannot leave a version
  that looks advanceable while its packs are missing.
* **Every push is idempotent** (`--skip-duplicate`). NuGet packages are immutable, so an
  id+version that already exists *is* the intended artifact and is skipped; only missing
  artifacts are published. Completeness is re-verified (with retries for feed lag) before the
  tag is created, and re-creating an existing tag is a no-op.

A feed transport failure exits non-zero rather than being read as `unpublished` — otherwise a
network blip would advance the version and strand the release it was meant to protect.

`scripts/test-release-workflow.sh` pins all of the above, including failure injection at each
publication step.


## Installer band selection

`workload-install.sh` and `workload-install.ps1` must behave identically; `test-version-band.sh`
extracts the real logic from both (never a hand-copy) and compares them case by case.

**Closest band at or below the request.** When a manifest for the active band is unavailable the
installer falls back — but it must fall back *downwards*. Selecting `10.0.300` for a `10.0.200`
request skips the published `10.0.200` manifest entirely and installs a newer feature band's
metadata. Both installers now order candidates with a numeric band sort key and choose the
closest compatible band `<= ` the request, and the fallback returns the resolved **package ID
and version together** — resolving only a version left the download using the original,
unavailable manifest ID.

**Explicit vs. derived target band.** `-t` / `-Tizen` is documented as supporting cross-band
installation, so the "target band must equal the active SDK band" rule applies **only** to an
auto-derived band. An explicitly requested band is honoured, and all inputs are validated
*before* anything is written.

**SDK pinning is validated before any mutation.** `install_tizenworkload` is invoked under `if !`,
which suppresses `errexit` for everything it calls, so an unchecked `dotnet new globaljson` could
fail and let the install proceed against the wrong SDK. Every pin command is now checked
explicitly and the effective `dotnet --version` is re-read and compared before download.

**Atomic manifest replacement.** The payload is staged and verified in a temporary directory
alongside the destination, then swapped in atomically, with rollback of the previous manifest on
any failure. Previously a partial copy could destroy a working manifest, and the leftover
directory made a subsequent existence check pass.

**SDK bootstrap is keyed by full SDK version.** `DOTNET_DESTDIR` and the install stamp include
the exact SDK version (`10.0.100` vs `10.0.101` vs a preview build), so `make install` no longer
reuses a stale SDK that merely shares a feature band. Manifest paths remain band-based.

Shell tests run under stock macOS Bash 3.2 (no `${var,,}`), and cover spaced paths, empty and
transport-failed version queries, and mixed-band `UpdateAllWorkloads`.


## Deriving the next version from the feed

`next-workload-version.py` picks the next global build counter from what is published, so
every question it asks the feed has to fail closed:

* **The search index is paginated.** The endpoint caps results per request, so a single
  query saw only the first page. If the band holding the highest counter fell on a later
  page it was invisible and the derived "next" version collided with one already published.
  Pagination now continues until the number of entries seen matches `totalHits`, and a
  response that delivers fewer than it promised, omits `totalHits`, or returns a
  non-integer `totalHits` or non-list `data` aborts the run.
* **A 200 that cannot be parsed is not an empty package.** `release-state.py` read
  `payload.get("versions", [])`, so `{}` — a truncated or error-shaped body — made a
  published package look missing. That downgrades `published` to `partial`, or makes a
  partial release look unpublished and advances past it. Only a genuine 404 (or a missing
  file on the `file://` feed used by the tests) means "never published".

`--set-version` equal to the value already on disk is an **idempotent no-op, not a failure**.
It is called outside a condition under `set -e`, so returning non-zero killed the step and
made the documented "reserve the current commit" recovery below it unreachable. Writing a
*lower* version is still refused.

## Installer band selection, continued

**The manifest package always follows the target band.** The manifest is named after the
band it is *for*, but the id was derived from the running SDK and only corrected on the
auto-derived path. `-t 10.0.200` on a 10.0.100 SDK therefore downloaded
`samsung.net.sdk.tizen.manifest-10.0.100` and installed it into `sdk-manifests/10.0.200` —
the wrong band's manifest in the right band's directory, reported as success.

**Pre-release bands are ordered by SemVer precedence.** The sort key appended the
pre-release verbatim and the comparison is a string compare, so `preview.10` sorted *below*
`preview.9` (`'1' < '9'`) and a request against a `preview.10` band silently fell back to
`preview.9`. Numeric identifiers are now zero-padded and tagged, alphanumeric ones tagged
separately (numeric sorts below alphanumeric, as SemVer requires). The shell and PowerShell
keys are asserted byte-identical.

**Installing is one transaction.** A partial install is worse than none: the shell installer
left `global.json` pinned when a download failed — so the next iteration of an
`--update-all-workloads` run overwrote the user's real `global.json.bak` and destroyed it —
and a failed pack install left a new manifest advertising packs that were not on disk, so
every later build against that band failed with an unrelated-looking error. The PowerShell
installer was worse still: it *removed* the old manifest and packs before fetching the new
ones, so a mid-way failure left no workload at all. Both now roll the SDK back to exactly
its previous state on any failure, including restoring `global.json` verbatim.

## Testing the shipped code

The fallback tests used to re-implement the family-prefix rule with their own `sed`, so they
agreed with themselves no matter what the installer did and could never detect drift. The
resolver is now delimited by `# BEGIN/END FALLBACK RESOLVER` markers, extracted, and invoked
directly — as `compute_target_version_band` and `band_sort_key` already were. Regressing
`band_sort_key` to its previous form makes the suite fail, which is the property that
matters.

The package set lives in three places — the workflow's push loop, `release-state.py`, and
the reservation payload — and is now checked in **both** directions. The old check only
verified that everything pushed was tracked; a package tracked but never pushed could never
become present, so the completeness gate would retry until it gave up and the version could
never be tagged.

SDK bootstrap directories and install stamps are keyed by the **full** SDK version, so
`10.0.100` and `10.0.101` do not share a tree, while the manifest path stays band-based.
