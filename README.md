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

**- .NET 6 Preview SDK**
  * Windows: [dotnet-sdk-6.0.100-preview.3.21202.5-win-x64.exe](https://download.visualstudio.microsoft.com/download/pr/f650c921-3ee9-4352-b743-a052e45d9ce7/99c5e001a48d243d27765d84c74f1e37/dotnet-sdk-6.0.100-preview.3.21202.5-win-x64.exe)
  * macOS: [dotnet-sdk-6.0.100-preview.3.21202.5-osx-x64.pkg](https://download.visualstudio.microsoft.com/download/pr/fc5fdd1f-fb4c-4b88-a507-158204030320/98497ef248883404ff5b0604dda944fb/dotnet-sdk-6.0.100-preview.3.21202.5-osx-x64.pkg)

**- .NET MAUI Tizen workloads, packs and templates (Preview)**
  * Windows: [Samsung.NET.Workload.Tizen.6.5.100-preview.3.34.msi](https://workload-bin.s3.ap-northeast-2.amazonaws.com/windows/Samsung.NET.Workload.Tizen.6.5.100-preview.3.34.msi)
  * macOS and Linux: Refer to the instructions [here](https://github.com/Samsung/Tizen.NET/tree/main/workload).

### Time to Go!

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
