---
title: "Try the Latest in Tizen .NET with Nightly Builds"
last_modified_at: 2019-05-02
categories:
  - Tizen .NET
author: Sunghyun Min
toc: true
toc_sticky: true
toc_label: Try the Latest in Tizen .NET with Nightly Builds
---

TizenFX is a part of [Tizen Project](https://www.tizen.org/), which allows you to access platform-specific features not covered by the generic .NET and Xamarin.Forms. There are several versions of TizenFX, according to Tizen platform release. They have been published as Tizen.NET packages in [nuget.org](https://www.nuget.org/).

The API Level 5 for the Tizen 5.0 platform is the latest official release. For more details, go [here](https://github.com/Samsung/TizenFX).

This post introduces how to use the latest Tizen .NET package, which includes nightly builds.

## How to access nightly builds
The Tizen .NET package is published whenever there are any changes. The nightly builds are distributed through a custom NuGet feed. You can review the changes and new features that will appear in the next prerelease.

The feed is located here:

https://tizen.myget.org/F/dotnet/api/v3/index.json

1. In the NuGet Package Manager, open the settings panel and configure a new package source: </br>
**Tools > Options > NuGet Package Manager > Package Sources**<br/>
    ![][ref1]

2. Right-click on the project, and then click on **Manage NuGet Packages...**<br/>
    ![][ref2]

3. Select the new package source you added.<br/>
    ![][ref3]

4. Check the **Include prerelease** option.<br/>
    ![][ref4]

5. Update Latest Tizen .NET package. Now Available: Tizen.NET 6.0.0.14763
    ![][ref5]

6. Check that the Tizen .NET package is updated.<br/>
    ![][ref7]


## Launch your application on the latest Tizen emulator

If you're finished updating your application, you can create the Tizen emulator that fits on your nightly build for testing.

1. Download latest Tizen platform image file. You can get the file at: </br>
http://download.tizen.org/snapshots/tizen/unified/latest/

2. Extract the *.`tar.gz` file. After extracting, you can find the following files:
  - `emulator-rootfs`
  - `emulator-sysdata`
  - `gui.property`

3. Open Tizen Emulator Manager:<br/>
**Tools > Tizen > Tizen Emulator Manager**
    ![][emul1]

4. Click the **+ Create** button.
    ![][emul2]

5. Click **Wearable**, and then click the **+** icon button.
    ![][emul3]

6. Check **raw** Image Format.
    ![][emul4]

7. Click the **...** icon button, and select the directory in which downloaded files are located.
    ![][emul5]

8. If you see the "Following disk image files are detected", click **OK**.
    ![][emul6]

9. Click **Next** until the **Finish** button appears. Click **Finish**.
    ![][emul9]

10. You can see That a new emulator is created. Click **Launch**.
    ![][emul10]

11. Launch the application on the new emulator.
    ![][emul13]

**Note**: You might encounter an issue on the emulator with raw-format image when you install a large application.</i>

[emul1]: {{site.url}}{{site.baseurl}}/assets/images/posts/try-latest-in-tizen-net/emul1.png
[emul2]: {{site.url}}{{site.baseurl}}/assets/images/posts/try-latest-in-tizen-net/emul2.png
[emul3]: {{site.url}}{{site.baseurl}}/assets/images/posts/try-latest-in-tizen-net/emul3.png
[emul4]: {{site.url}}{{site.baseurl}}/assets/images/posts/try-latest-in-tizen-net/emul4.png
[emul5]: {{site.url}}{{site.baseurl}}/assets/images/posts/try-latest-in-tizen-net/emul5.png
[emul6]: {{site.url}}{{site.baseurl}}/assets/images/posts/try-latest-in-tizen-net/emul6.png
[emul7]: {{site.url}}{{site.baseurl}}/assets/images/posts/try-latest-in-tizen-net/emul7.png
[emul8]: {{site.url}}{{site.baseurl}}/assets/images/posts/try-latest-in-tizen-net/emul8.png
[emul9]: {{site.url}}{{site.baseurl}}/assets/images/posts/try-latest-in-tizen-net/emul9.png
[emul10]: {{site.url}}{{site.baseurl}}/assets/images/posts/try-latest-in-tizen-net/emul10.png
[emul13]: {{site.url}}{{site.baseurl}}/assets/images/posts/try-latest-in-tizen-net/emul13.png
[ref1]: {{site.url}}{{site.baseurl}}/assets/images/posts/try-latest-in-tizen-net/ref1.png
[ref2]: {{site.url}}{{site.baseurl}}/assets/images/posts/try-latest-in-tizen-net/ref2.png
[ref3]: {{site.url}}{{site.baseurl}}/assets/images/posts/try-latest-in-tizen-net/ref3.png
[ref4]: {{site.url}}{{site.baseurl}}/assets/images/posts/try-latest-in-tizen-net/ref4.png
[ref5]: {{site.url}}{{site.baseurl}}/assets/images/posts/try-latest-in-tizen-net/ref5.png
[ref7]: {{site.url}}{{site.baseurl}}/assets/images/posts/try-latest-in-tizen-net/ref7.png
