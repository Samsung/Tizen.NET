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

It's my pleasure to tell you how to try the latest in Tizen .NET with our nightly builds.

Before starting, I'd like to talk about TizenFX briefly.

TizenFX is a part of [Tizen Project](https://www.tizen.org/), which allows you to access platform-specific features not covered by the generic `.NET` and `Xamarin.Forms`. 

There are several versions of TizenFX according to Tizen platform release, They have been published as Tizen.NET pacakges in [nuget.org](https://www.nuget.org/).

The API Level 5 which is for Tizen 5.0 platform is the latest official release, and the next API version for Tizen vNext(5.5) platform is under development.

You can get more details [here](https://github.com/Samsung/TizenFX).

In this post, I'm going to introduce how to use the latest Tizen .NET package with nightly builds.



## How to Access Nightly Builds
The Tizen .NET package is published every day when there are any changes.

The nightly builds are distributed via a custom NuGet feed like how `Xamarin.Forms` does.

It allows you to review the changes and the new features that will appear in the next pre-release.

You can find the feed at

> https://tizen.myget.org/F/dotnet/api/v3/index.json

Now, Let's try this!

1. Open the settings panel and configure a new package source in the `NuGet Package Manager`.<br/>
`Tools` - `Options` - `NuGet Package Manager` - `Package Sources`<br/>
    ![][ref1]

2. Right click on the project, and then click on `Manage NuGet Packages...`<br/>
    ![][ref2]

3. Select the new package source you added.<br/>
    ![][ref3]
	
4. Check the `include prerelease` option.<br/>
    ![][ref4]

5. Update Latest Tizen .NET package.<br/>
Now Available: Tizen.NET 6.0.0.14763
    ![][ref5]

6. You can check the Tizen .NET package is updated.<br/>
    ![][ref7]


## Launch Your Application on Latest Tizen Emulator

If you've done updating your application, you might need the Tizen emulator that fits on your nightly build for testing.

1. Download latest Tizen Platform Image File.<br/>
You can get the file at 
> http://download.tizen.org/snapshots/tizen/unified/latest/

2. Extract the *.tar.gz file. <br/>
You can find the following files after extracting.
  - emulator-rootfs
  - emulator-sysdata
  - gui.property


3. Open Tizen Emulator Manager.<br/>
`Tools` - `Tizen` - `Tizen Emulator Manager`
    ![][emul1]

4. Click `+ Create` button.
    ![][emul2]

5. Click `Wearable` and then Click "`+`" icon button.
    ![][emul3]

6. Check `raw` Image format.
    ![][emul4]

7. Click "`...`" icon button, and then select the directory in which downloaded files are located.
    ![][emul5]

8. If you see a message "Image files are detected", click `OK` button.
    ![][emul6]

9. Click `OK` button until the `Finish` button is appeared.
    ![][emul7]
    ![][emul8]	
    ![][emul9]
	
10. You can see a new emulator is created. Click `Launch` button.
    ![][emul10]
	
11. Launch the application on the new emulator.
    ![][emul13]


<i>* There might be an issue on emulator with raw format image when you install big size application. </i>

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


