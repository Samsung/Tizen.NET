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

## workload-uninstall (Windows only)

This script removes the Tizen workload from the installed .NET SDK, including the HKLM registry entry that `workload-install.ps1` writes on MSI-installed SDKs to make `dotnet workload list` show `tizen`.

### When to use it

On Windows, running `dotnet workload install/restore/update` for other workloads while the Tizen workload is installed can fail with an error like:

```
Version X.Y.Z of package samsung.tizen.sdk.msi.x64 is not found in NuGet feeds
```

and cause the entire transaction to roll back, including other workloads installed in the same session. The root cause is that the Tizen workload is currently distributed as raw NuGet packages via an install script rather than signed MSI NuGet packages, but the install script registers a Windows Installer entry so that `dotnet workload list` can see it. The SDK then treats Tizen as an MSI-installed workload and fails when it cannot find the MSI payload.

As a workaround, run `workload-uninstall.ps1` before `dotnet workload` operations for other workloads, then reinstall the Tizen workload with `workload-install.ps1`:

```
# 1) Uninstall Tizen workload (run PowerShell as Administrator)
.\workload-uninstall.ps1

# 2) Run your dotnet workload operations
dotnet workload install maui
# or dotnet workload restore / update, etc.

# 3) Reinstall the Tizen workload
.\workload-install.ps1
```

### Usage

```
workload-uninstall.ps1 [-d <Dotnet SDK Location>] [-t <Dotnet Version Band Target Folder>]
```

Must be run with administrator privileges when the .NET SDK is installed under `%ProgramFiles%\dotnet` (the default for MSI-installed SDKs).
