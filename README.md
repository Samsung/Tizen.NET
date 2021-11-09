# Tizen .NET
![image](https://user-images.githubusercontent.com/14328614/115324121-49473f00-a1c4-11eb-844c-86970c5e0764.png)

[<b>Tizen .NET</b>](https://developer.samsung.com/tizen/About-Tizen.NET/Tizen.NET.html) is an advanced way to develop applications with .NET technology for Tizen OS.

Tizen .NET is :
- Support [TizenFX](https://github.com/Samsung/TizenFX)
- Support .NET [MAUI](https://github.com/dotnet/maui)
- Support .NET 6


## Getting Started
> This is an early preview of Tizen in .NET 6 not for production use. Expect breaking changes as this is still in development for .NET 6.

### Prerequisites
> [.NET MAUI Check Tool](https://github.com/Redth/dotnet-maui-check) doesn't support Tizen environment yet, but hopes to be supported soon.

**- Tizen SDK**
  * [Tizen Extensions for Visual Studio Family](https://developer.tizen.org/development/tizen-extensions-visual-studio-family) or 
  * [Tizen Studio](https://developer.tizen.org/development/tizen-studio)

**- .NET 6 SDK**
  * Linux / Windows / macOS : https://dotnet.microsoft.com/download/dotnet/6.0
  
**- Visual Studio 2022**
  * To create Tizen .NET with .NET6, you need the latest version of [Visual Studio 2022](https://visualstudio.microsoft.com/)

### Installing Tizen workload for .NET 6.0 (Preview)
  You can install Tizen workload for .NET 6.0 by using the installer script.
  * On Linux/MacOS:
  ```sh
  curl -sSL https://raw.githubusercontent.com/Samsung/Tizen.NET/main/workload/scripts/workload-install.sh | sudo bash
  ```
  if you want to install a specific version of Tizen.NET workload or install to a specific directory, use the following command:
  ```sh
  curl -sSL https://raw.githubusercontent.com/Samsung/Tizen.NET/main/workload/scripts/workload-install.sh | bash /dev/stdin -v <version> -d <directory>
  ```
  * On Windows:
  ```powershell
  Invoke-WebRequest 'https://raw.githubusercontent.com/Samsung/Tizen.NET/main/workload/scripts/workload-install.ps1' -Proxy $env:HTTP_PROXY -ProxyUseDefaultCredentials -OutFile 'workload-install.ps1';
  ./workload-install.ps1 [-v <version>] [-d <directory>]
  ```
  
  For an instance:
  ```powershell
  PS D:\workspace> Invoke-WebRequest 'https://raw.githubusercontent.com/Samsung/Tizen.NET/main/workload/scripts/workload-install.ps1' -OutFile 'workload-install.ps1';
  
  PS D:\workspace> .\workload-install.ps1
Installing Samsung.NET.Sdk.Tizen.Manifest-6.0.100/6.5.100-rc.1.114 to C:\Program Files\dotnet\sdk-manifests\6.0.100...
Installing Samsung.Tizen.Sdk/6.5.100-rc.1.114...
Installing Samsung.Tizen.Ref/6.5.100-rc.1.114...
Installing Samsung.Tizen.Templates/6.5.100-rc.1.114...
Installing Samsung.NETCore.App.Runtime.tizen/6.5.100-rc.1.114... 
```
  You can see the Tizen workload as follows if it is properly installed.
  ```powershell
PS D:\workspace> dotnet workload list

This command lists only workloads that were installed via `dotnet workload install` in this version of the SDK and not those that were installed via Visual Studio.

Installed Workload Ids
----------------------
maui
tizen

Use `dotnet workload search` to find additional workloads to install.

Updates are avaliable for the following workload(s): maui tizen. Run `dotnet workload update` to get the latest  
  ```

### Time to Go! (using Visual Studio 2022)
See [here](https://github.com/Samsung/Tizen.NET/wiki/Build-your-first-(.NET6)-Tizen-App-using-Visual-Studio-2022) for more details.

![](https://github.com/Samsung/Tizen.NET/blob/a710d7095ca9ba0a759705dc59461140dec13ae4/assets/hello-tizen-net6-vs2022.gif)

### Time to Go! (using CLI)

#### 1. Check the Tizen templates before creating a new Tizen Project
You can see the Tizen template as follows if it is properly installed.
```sh
dotnet new --list
Template Name                                 Short Name      Language    Tags                  
--------------------------------------------  --------------  ----------  ----------------------
Console Application                           console         [C#],F#,VB  Common/Console        
Class Library                                 classlib        [C#],F#,VB  Common/Library        
Worker Service                                worker          [C#],F#     Common/Worker/Web     
MSTest Test Project                           mstest          [C#],F#,VB  Test/MSTest           
NUnit 3 Test Item                             nunit-test      [C#],F#,VB  Test/NUnit            
NUnit 3 Test Project                          nunit           [C#],F#,VB  Test/NUnit            
xUnit Test Project                            xunit           [C#],F#,VB  Test/xUnit            
*Tizen .NET Application**                    *tizen*          *[C#]*      *Tizen*
Razor Component                               razorcomponent  [C#]        Web/ASP.NET           
Razor Page                                    page            [C#]        Web/ASP.NET           
...

```  

#### 2. Creates a New Project
```sh
dotnet new tizen -n HelloTizenNet6
```
When the project is successfully created, the following files are created.
```sh
└── HelloTizenNet6
    ├── HelloTizenNet6.csproj
    ├── Main.cs
    ├── shared
    └── tizen-manifest.xml
```

> This is a Tizen .NET app, not a .NET MAUI app. A .NET MAUI app that supports Tizen is currently under development and will be released as soon as possible.


#### 3. Build the application
```sh
dotnet build 
```
When the project builds successfully, tizen app package (.tpk) is created as follows.
```sh
Microsoft (R) Build Engine version 16.10.0-preview-21181-07+073022eb4 for .NET
Copyright (C) Microsoft Corporation. All rights reserved.

  Determining projects to restore...
  Restored /home/rookiejava/workspace/HelloTizenNet6/HelloTizenNet6.csproj (in 165 ms).
  You are using a preview version of .NET. See: https://aka.ms/dotnet-core-preview
  HelloTizenNet6 -> /home/rookiejava/workspace/HelloTizenNet6/bin/Debug/net6.0-tizen/HelloTizenNet6.dll
  TizenTpkFiles : shared/res/HelloTizenNet6.png
  TizenTpkFiles : tizen-manifest.xml
  HelloTizenNet6 is signed with Default Certificates!
  HelloTizenNet6 -> /home/rookiejava/workspace/HelloTizenNet6/bin/Debug/net6.0-tizen/com.companyname.HelloTizenNet6-1.0.0.tpk

Build succeeded.
    0 Warning(s)
    0 Error(s)

Time Elapsed 00:00:04.83
```

#### 4. Run the application 
Unfortunately `dotnet run` is not yet integrated. So for now you need to use `sdb` to install the app.
```sh
sdb install bin/Debug/net6.0-tizen/com.companyname.HelloTizenNet6-1.0.0.tpk
```

> Tizen emulators and devices that support .NET6 have not yet been officially released, and we will announce a binary for testing soon.
