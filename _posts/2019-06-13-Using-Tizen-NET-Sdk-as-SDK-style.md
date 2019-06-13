---
title:  "Using Tizen.NET.Sdk as SDK-style"
search: true
categories:
  - Tizen.NET
last_modified_at: 2019-06-13
author: Wonyoung Choi
toc: true
toc_sticky: true
toc_label: Using Tizen.NET.Sdk as SDK-style
---

`Tizen.NET.Sdk` is a nuget package that provides the features for creating and signing a .tpk package file. In the past, this package was added to .csproj file as a PackageReference. However, in this post I will introduces a new method.

## Using SDK-style
Since [Tizen.NET.Sdk 1.0.3], It can be used as a custom SDK of `MSBuild`.
```xml
<Project Sdk="Tizen.NET.Sdk/1.0.3">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>tizen40</TargetFramework>
  </PropertyGroup>

</Project>
```
`Tizen.NET.Sdk` resolves the `Tizen` target frameworks and adds a `PackageReference` for `Tizen.NET` implicitly. There is no need to declare any `PackageReference` to use `Tizen.NET` and `Tizen.NET.Sdk`. But `Tizen.NET.Sdk` should be used in the `Sdk` attribute of top-level `Project` element instead of `Microsoft.NET.Sdk`.

![example1](https://user-images.githubusercontent.com/1029205/59406955-c3e5ed00-8dea-11e9-8850-e77ba1432d0c.png)


## Specify Tizen.NET package version
In [Tizen.NET.Sdk 1.0.3], [Tizen.NET 5.0.0.14629] is implicitly added as `PackageReference`. If you want to specify the version of `Tizen.NET`, use `TizenNetPackageVersion` property.
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

## Use in old way
Of course, `Tizen.NET.Sdk` can also be used in the old way.
```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>tizen40</TargetFramework>
    <!- Workaround: Set TargetFrameworkIdentifier to avoid Tizen TFM issue on VS2019 -->
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



[Tizen.NET.Sdk 1.0.3]: https://www.nuget.org/packages/Tizen.NET.Sdk/1.0.3
[Tizen.NET 5.0.0.14629]: https://www.nuget.org/packages/Tizen.NET/5.0.0.14629
