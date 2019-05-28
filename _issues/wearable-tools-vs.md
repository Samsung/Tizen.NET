---
title:  "Visual Studio 2019"
permalink: /issues/wearable/tools-vs/
toc: true
toc_sticky: true
---

This issue has been shared on 23, March, 2019.
{: .notice--info}

### Issue on Visual Studio 2019
After updating your Visual Studio 2019 to `16.1.0` version, you will face the build error for your Tizen project.

TargetFramework error will occur like below.
> The TargetFramework value 'tizen40' was not recognized. It may be misspelled. If not, then the TargetFrameworkIdentifier and/or TargetFrameworkVersion properties must be specified explicitly.

### Issue will be fixed soon
- Fixed version of Visual Studio will be released soon.
[Ths issue](https://github.com/dotnet/project-system/issues/4854) has been quickly shared and it is [already fixed](https://github.com/dotnet/project-system/pull/4859).
- `Tizen.NET.Sdk` will be fixed and released soon.

### Workaround
To avoid this problem, you have to add following two lines in .csproj to define TargetFramework FullName.
```
<PropertyGroup>
    <TargetFrameworkIdentifier>Tizen</TargetFrameworkIdentifier>
    <TargetFrameworkVersion>v4.0</TargetFrameworkVersion>
</PropertyGroup>
```