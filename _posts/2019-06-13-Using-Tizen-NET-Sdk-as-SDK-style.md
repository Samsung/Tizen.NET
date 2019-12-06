---
title:  "Using Tizen.NET.Sdk as SDK-style"
search: true
categories:
  - Tizen .NET
last_modified_at: 2019-12-06
author: Wonyoung Choi
toc: true
toc_sticky: true
toc_label: Using Tizen.NET.Sdk as SDK-style
---

`Tizen.NET.Sdk` is a NuGet package that provides the features for creating and signing a .tpk package file. Previously, this package was added to the `.csproj` file as a `PackageReference`; in this post I introduce a new method to add this package.

## Using SDK-style
[Tizen.NET.Sdk 1.0.8] can be used as a custom `MSBuild` SDK.
```xml
<Project Sdk="Tizen.NET.Sdk/1.0.8">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>tizen60</TargetFramework>
  </PropertyGroup>

</Project>
```
`Tizen.NET.Sdk` resolves the `Tizen` target frameworks and adds a `PackageReference` for `Tizen.NET` implicitly, so there is no need to declare any `PackageReference` to use `Tizen.NET` and `Tizen.NET.Sdk`. But use `Tizen.NET.Sdk` instead of `Microsoft.NET.Sdk` in the `Sdk` attribute of the top-level `Project` element.

![example1](https://user-images.githubusercontent.com/1029205/70313735-81611280-1859-11ea-8018-fe6f3a3bd847.png)


## Specify the Tizen.NET package version
In [Tizen.NET.Sdk 1.0.8], [Tizen.NET 6.0.0.14995] is implicitly added as `PackageReference`. If you want to specify the version of `Tizen.NET`, use the  `TizenNetPackageVersion` property.
```xml
<Project Sdk="Tizen.NET.Sdk/1.0.8">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>tizen40</TargetFramework>
    <TizenNetPackageVersion>4.0.0</TizenNetPackageVersion>
  </PropertyGroup>

</Project>
```
![example2](https://user-images.githubusercontent.com/1029205/70313915-d1d87000-1859-11ea-9ad6-a98967e23549.png)

## Disable the implict reference of Tizen.NET
Set `DisableImplicitFrameworkReferences` property to `True` if you want to disable the implict reference of `Tizen.NET` package.
In this case, you **MUST** add `PackageReference` of `Tizen.NET` manually.
```xml
<Project Sdk="Tizen.NET.Sdk/1.0.8">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>tizen60</TargetFramework>
    <DisableImplicitFrameworkReferences>True</DisableImplicitFrameworkReferences>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Tizen.NET" Version="6.0.0.14995" />
  </ItemGroup>
  
</Project>
```

## Manual migration
If you are using the `Tizen.NET.Sdk` in a `PackageReference` style, you can migrate your `.csproj` file manually, as shown below:
```diff
- <Project Sdk="Microsoft.NET.Sdk">
+ <Project Sdk="Tizen.NET.Sdk/1.0.8">
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
    <TargetFramework>tizen60</TargetFramework>
    <!- Workaround for dotnet/project-system#4854 -->
    <TargetFrameworkIdentifier>Tizen</TargetFrameworkIdentifier>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Tizen.NET" Version="6.0.0.14995" />
    <PackageReference Include="Tizen.NET.Sdk" Version="1.0.8" />
  </ItemGroup>

</Project>
```


## References
1. [Tizen.NET.Sdk Documents](https://github.com/Samsung/build-task-tizen/blob/master/doc/tizen.net.sdk-intro-tpk.md)
2. [NuGet-based SDK resolver design spec](https://github.com/Microsoft/msbuild/issues/2803)
3. [dotnet/project-system#4854]


[Tizen.NET.Sdk 1.0.8]: https://www.nuget.org/packages/Tizen.NET.Sdk/1.0.8
[Tizen.NET 6.0.0.14995]: https://www.nuget.org/packages/Tizen.NET/6.0.0.14995
[dotnet/project-system#4854]: https://github.com/dotnet/project-system/issues/4854
