# Workload for Tizen .NET

This is a build of Tizen workload for an early preview of Tizen in .NET 6.
Please refer [.NET 6.0.0 Mobile Samples](https://github.com/dotnet/net6-mobile-samples#net-600-mobile-samples) for installing .NET 6 preview SDK and other workloads of different plattforms.

## Installing Tizen Workload
You would first need to install .NET 6 Preview SDK. Download and install `SDK 6.0.100-preview.4` [here](https://dotnet.microsoft.com/download/dotnet/6.0).
### Linux
Use following commands to build and install Tizen workload.
```shell
make install DESTDIR=<.net 6 preview sdk path>
```
or
```shell
make install DESTDIR=<.net 6 preview sdk path> DESTVER=<.net 6 preview sdk version>
```

### Windows
* Windows: [Samsung.NET.Workload.Tizen.6.5.100-preview.4.45.msi](https://workload-bin.s3.ap-northeast-2.amazonaws.com/windows/Samsung.NET.Workload.Tizen.6.5.100-preview.4.45.msi)
     
## Using IDEs
Refer [here](https://github.com/dotnet/net6-mobile-samples#using-ides) to see the supporting status of an each IDE and how to manually enable workload.
