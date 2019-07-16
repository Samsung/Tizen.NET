---
title:  "Using Tizen.NET.Sdk as SDK-style"
search: true
categories:
  - Tizen .NET
last_modified_at: 2019-06-20
author: Wonyoung Choi
toc: true
toc_sticky: true
toc_label: Using Tizen.NET.Sdk as SDK-style
---

`Tizen.NET.Sdk` is a NuGet package that provides the features for creating and signing a .tpk package file. Previously, this package was added to the `.csproj` file as a `PackageReference`. However, in this post I introduce a new method.

## Using SDK-style
[Tizen.NET.Sdk 1.0.3] can be used as a custom `MSBuild` SDK.
```xml
<Project Sdk="Tizen.NET.Sdk/1.0.3">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>tizen40</TargetFramework>
  </PropertyGroup>

</Project>
```
`Tizen.NET.Sdk` resolves the `Tizen` target frameworks and adds a `PackageReference` for `Tizen.NET` implicitly, so there is no need to declare any `PackageReference` to use `Tizen.NET` and `Tizen.NET.Sdk`. But use `Tizen.NET.Sdk` instead of `Microsoft.NET.Sdk` in the `Sdk` attribute of the top-level `Project` element.

![example1](https://user-images.githubusercontent.com/1029205/59406955-c3e5ed00-8dea-11e9-8850-e77ba1432d0c.png)


## Specify the Tizen.NET package version
In [Tizen.NET.Sdk 1.0.3], [Tizen.NET 5.0.0.14629] is implicitly added as `PackageReference`. If you want to specify the version of `Tizen.NET`, use the  `TizenNetPackageVersion` property.
```xml
<Project Sdk="Tizen.NET.Sdk/1.0.3">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>tizen40</TargetFramework>
    <TizenNetPackageVersion>4.0.0</TizenNetPackageVersion>
  </PropertyGroup>

</Project>
```
![example2](https://user-images.githubusercontent.com/1029205/59406973-d2cc9f80-8dea-11e9-9b1c-655347fb3806.png)


## Manual migration
If you are using the `Tizen.NET.Sdk` in a `PackageReference` style, you can migrate your `.csproj` file manually, as shown below:
```diff
- <Project Sdk="Microsoft.NET.Sdk">
+ <Project Sdk="Tizen.NET.Sdk/1.0.3">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>tizen40</TargetFramework>
  </PropertyGroup>

-  <ItemGroup>
-    <PackageReference Include="Tizen.NET" Version="5.0.0.14629" />
-    <PackageReference Include="Tizen.NET.Sdk" Version="1.0.1" />
-  </ItemGroup>

</Project>
```


## Use as in previous versions
Of course, you can use `Tizen.NET.Sdk` as you did prior to version 1.0.3. However, there is problem in VS2019; see [dotnet/project-system#4854]. To avoid this problem, add the `TargetFrameworkIdentifier` property explicitly.
```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>tizen40</TargetFramework>
    <!- Workaround for dotnet/project-system#4854 -->
    <TargetFrameworkIdentifier>Tizen</TargetFrameworkIdentifier>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Tizen.NET" Version="5.0.0.14629" />
    <PackageReference Include="Tizen.NET.Sdk" Version="1.0.3" />
  </ItemGroup>

</Project>
```


## References
1. [Tizen.NET.Sdk Documents](https://github.com/Samsung/build-task-tizen/blob/master/doc/tizen.net.sdk-intro-tpk.md)
2. [NuGet-based SDK resolver design spec](https://github.com/Microsoft/msbuild/issues/2803)
3. [dotnet/project-system#4854]


[Tizen.NET.Sdk 1.0.3]: https://www.nuget.org/packages/Tizen.NET.Sdk/1.0.3
[Tizen.NET 5.0.0.14629]: https://www.nuget.org/packages/Tizen.NET/5.0.0.14629
[dotnet/project-system#4854]: https://github.com/dotnet/project-system/issues/4854
