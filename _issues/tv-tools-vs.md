---
title:  "Visual Studio 2019"
permalink: /issues/tv/tools-vs/
toc: true
toc_sticky: true
---

This issue was shared on March 23, 2019.
{: .notice--info}

## Issue on Visual Studio 2019
After updating Visual Studio 2019 to version 16.1.0, the following build error for your Tizen project appears:

> The TargetFramework value 'tizen40' was not recognized. It may be misspelled. If not, then the TargetFrameworkIdentifier and/or TargetFrameworkVersion properties must be specified explicitly.

### This issue will be fixed soon
- [This issue](https://github.com/dotnet/project-system/issues/4854) has been [fixed](https://github.com/dotnet/project-system/pull/4859).
- A fixed version of Visual Studio will be released soon.
- The Tizen.NET SDK will be fixed and released soon.

### Workaround
To avoid this problem, add following two lines in .`csproj` to define the `TargetFramework` `FullName`.
```
<PropertyGroup>
    <TargetFrameworkIdentifier>Tizen</TargetFrameworkIdentifier>
    <TargetFrameworkVersion>v4.0</TargetFrameworkVersion>
</PropertyGroup>
```
