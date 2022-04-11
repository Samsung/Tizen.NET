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
