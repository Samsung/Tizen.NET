# Workload for Tizen .NET

This is a build of Tizen workload for an early preview of Tizen in .NET 6.
Please refer [.NET 6.0.0 Mobile Samples](https://github.com/dotnet/net6-mobile-samples#net-600-mobile-samples) for installing .NET 6 preview SDK and other workloads of different plattforms.

## Installing Tizen Workload
You would first need to install .NET 6 Preview SDK. Download and install `SDK 6.0.100-preview.3` [here](https://dotnet.microsoft.com/download/dotnet/6.0).
### Linux
Use following commands to build and install Tizen workload.
```shell
make && make install DESTDIR=<.net 6 preview sdk path>
make && make install DESTDIR=<.net 6 preview sdk path> DESTVER=<.net 6 preview sdk version>
```

> If you want to use Tizen workload on Windows
>   - Build Tizen workload in Linux
>   - Copy the build artifacts manually to Windows environment 
>     - dotnet/packs/Samsung.Tizen.Ref
>     - dotnet/packs/Samsung.Tizen.Sdk
>     - dotnet/sdk-manifests/6.0.100/Samsung.NET.Workload.Tizen
>     - dotnet/template-packs/Samsung.Tizen.Templates.6.5.100-ci.main.27.nupkg
     
## Using IDEs
Refer [here](https://github.com/dotnet/net6-mobile-samples#using-ides) to see the supporting status of an each IDE and how to manually enable workload.
