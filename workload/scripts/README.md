# Scripts

## workload-install

This script installs the Tizen workload manifest files to the dotnet sdk location.
After installation by this script, other workload packs can be installed by following command:
```
dotnet workload install tizen --skip-manifest-update
```

### Usage
On Linux/MacOS:
```
workload-install.sh [-v <Version>] [-d <Dotnet SDK Location>]
```

On Windows:
```
workload-install.ps1 [-v <Version>] [-d <Dotnet SDK Location>]
```

If this script is executed in CI environment, you can use `curl` to download the script and execute it.
```
curl -sSL https://raw.githubusercontent.com/Samsung/Tizen.NET/main/workload/scripts/workload-install.sh | bash
```
or
```
curl -sSL https://raw.githubusercontent.com/Samsung/Tizen.NET/main/workload/scripts/workload-install.sh | bash -s -- -v <version> -d <dotnet sdk location>
```
