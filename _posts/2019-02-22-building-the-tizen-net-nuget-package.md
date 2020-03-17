---
title: "Build the Tizen .NET NuGet package"
last_modified_at: 2019-02-22
categories:
  - Tizen .NET
author: Kangho Hur
redirect_to: https://developer.samsung.com/tizen/blog/en-us/2019/02/22/build-the-tizen-net-nuget-package
---

TizenFX APIs allow you to access Tizen-specific platform features not covered by the generic .NET standard and Xamarin APIs, such as system information and status, battery status, sensor date, and account and connectivity services.

The best way to understand the TizenFX APIs and modify them to make your own customizations to Tizen.NET is to build and publish your own NuGet package. In this post, we discuss how you can build it locally.


## Prerequisites

To build Tizen .NET NuGet, you must have .NET Core SDK 2.0 or higher installed on your machine. See [here](https://www.microsoft.com/net/download/) for instructions on how to download and install the .NET Core SDK.


## Download the source code

Download the latest TizenFX source code. You can clone the TizenFX repository, as shown below.

```sh
# git clone git@github.com:Samsung/TizenFX.git
```

TizenFX has several release branches for API level management. For instance, the API4 branch is the release branch for Tizen .NET API Level 4, and the API5 branch is the release branch for Tizen .NET API Level 5. No new public API changes (additions, deletions and modifications) are allowed in these branches, because all public APIs have already been committed. However, you can freely add or modify APIs in the master branch, which is the working branch.

## Build the solution

After you download and modify the source code, you can build the source code. TizenFX provides a very simple script, `build.sh`, to build the solution.

To build a specific module, use:

```sh
# build.sh build [module]
```

To build the entire solution, use:

```sh
# build.sh full
```

## Package NuGet

If the build was successful, you can package Tizen .NET NuGet. Packaging NuGet is done using `build.sh`.

The following command creates your own Tizen.NET NuGet package, which will be located in your root directory.
```sh
# build.sh pack
```

If you want to create a NuGet package with a specific package version, specify the version as follows:
```sh
# build.sh pack [version]
```

## Publish the NuGet package
The generated Tizen .NET NuGet package can be uploaded to your private package repository (for example, MyGet) or your local repository for distribution.

Now you’re ready to build with Tizen.NET and distribute within your own organization. Enjoy!
