---
title: "Building the Tizen .NET NuGet package"
last_modified_at: 2019-02-22
categories:
  - Tizen .NET
author: Kangho Hur
---

TizenFX APIs allow you to access Tizen-specific platform features not covered by the generic .NET standard and Xamarin API such as system information and status, battery status, sensor date, and account and connectivity services.

The best way to understand the TizenFX APIs and modify it as you want is to make your own customizations to Tizen.NET to build and publish your own NuGet package.
In this post, let's talk about how you can build that locally.


## Prerequisites

In order to build Tizen .NET Nuget, .NET Core SDK 2.0 or higher version must be installed on your machine. Since .NET Core SDK supports Windows, Linux and MacOS, you don't have to worry about whatever you're using. Please see [here](https://www.microsoft.com/net/download/) for instructions on how to download and install the .NET Core SDK.


## Download the source code


Now all you need to do is to download the latest TizenFX source code. You can clone the TizenFX repository as shown below.

```sh
# git clone git@github.com:Samsung/TizenFX.git
```

TizenFX has several release branches for API level management. For instance, the API4 branch is the release branch for Tizen .NET API Level 4 and the API5 branch is the release branch for Tizen .NET API Level 5. No new public API changes (additions, deletions and modifications) are allowed in these branches because all public APIs have already been committed. On the other hand, you can freely add or modify APIs in the master branch, which is the working branch.

## Build the Solution

Once you've downloaded and modified the source code, perhaps you want to build the source code.
TizenFX provides a useful script (build.sh) for building the solution. The usage of this script is very simple.

If you want to build a specific module, you can use:

```sh
# build.sh build [module] 
```

And if you want to build the entire solution, you can do it as follows.

```sh
# build.sh full
```

## Package the NuGet


If the build has been successful, now is the time to package the Tizen .NET NuGet. Just like the build step, packaging the NuGet is done via build.sh.
The following command will create your own Tizen.NET NuGet. The NuGet package will be in your root directory when it’s complete. 
```sh
# build.sh pack
```

If you want to create a nuget package with a specific package version, specify the version as follows.
```sh
# build.sh pack [version]
```

## Publish the NuGet
This generated Tizen .NET NuGet package can be uploaded to your private package repository (e.g. MyGet) or simply uploaded to your local repository for distribution.

Now you’re all set to build Tizen.NET and distribute within your own organization!

Enjoy Tizen .NET!

