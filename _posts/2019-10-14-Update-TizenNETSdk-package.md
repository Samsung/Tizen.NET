---
title: "Update Tizen.NET.Sdk package in Visual Studio 16.3 or above"
last_modified_at: 2019-10-02
categories:
  - Tizen .NET
author: Jay Cho
toc: true
toc_sticky: true
redirect_to: https://developer.samsung.com/tizen/blog/en-us/2019/10/14/update-tizennetsdk-package-in-visual-studio-163-or-above
---

<b>Visual Studio 2019 version 16.3</b> has been recently released and lots of people would be very happy to update their Visual Studio to the latest.
Check out the [release notes](https://docs.microsoft.com/en-us/visualstudio/releases/2019/release-notes) to see more details.

## Don't panic! Application built on Visual Studio 16.3 or above will crash
However, if you are a Tizen .NET developers, you could be panic after finding out that your application which is built on Visual Studio version 16.3 or above does not run on the Tizen target anymore.
You will face the following exception.

```
System.IO.FileNotFoundException: Could not load file or assembly 'Xamarin.Forms.Platform.Tizen, Version=2.0.0.0, Culture=neutral, PublicKeyToken=null'. The system cannot find the file specified.
```

This is happening because Visual Studio 2019 version 16.3 contains support for the release of .NET Core 3.0 and Tizen .NET Sdk needs corresponding updates.


## Solution
To resolve this issue, please update `Tizen.NET.Sdk` package from `1.0.3` to `1.0.5`.
- Open your `.csproj` file of your Tizen project.
- Modify the version of `Tizen.NET.Sdk` package from `1.0.3` to `1.0.5` which is normally on the first line.

```xml
<Project Sdk="Tizen.NET.Sdk/1.0.5">

  <!-- Property Group for Tizen50 Project -->
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>tizen50</TargetFramework>
  </PropertyGroup>
 ... 

```


## Tizen .NET Templates have been updated
Tizen .NET templates provided on Visual Studio have been updated, so please update your Visual Studio Tools for Tizen if you are facing this issue.
