---
title:  "Watch Face"
permalink: /issues/wearable/watchface
toc: true
toc_sticky: true
---


### App Template's Build Error

When you create a Tizen Watchface application with the *Tizen Watchface App template* in Visual Studio 2017, you may face an error during the build process.

It is because there is an error in `tizen-manifest.xml` file of the watchface app template.
(There is an issue in watchface app template distributed in `Visual Studio Tools for Tizen 2.3.1 version`.)

It will be fixed in the next release. Until then, please modify the `tizen-manifest.xml` file as follows:

<blockquote>
<b>[AS-IS]</b>

<p><watch-application appid="org.tizen.example.TizenWatchfaceApp1" exec="TizenWatchfaceApp1.dll" type="dotnet" ambient-support="false" <span style="color:red">>></span></p>

<b>[TO-BE]</b>

<p><watch-application appid="org.tizen.example.TizenWatchfaceApp1" exec="TizenWatchfaceApp1.dll" type="dotnet" ambient-support="false" <span style="color:red">></span></p>

</blockquote>
{: .notice--info}

### App execution with debugger

There is an issue when you execute a watchface application in debug mode (by pressing `F5` key). Changing the watchface may fail on Samsung Wearables in Tizen 4.0.

It will be fixed soon. Until then, you can execute the watchface application without debugger (by pressing `ctrl + F5` key) or change the watchface after running your application in debug mode and rebooting your Samsung smartwatch.
