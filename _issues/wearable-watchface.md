---
title:  "Watch Face"
permalink: /issues/wearable/watchface/
toc: true
toc_sticky: true
---


## App template build error

The following issue was fixed in Visual Studio Tools for Tizen, version 2.4 (released in March 2019).
{: .notice--danger}

### Error in Visual Studio Tools for Tizen, version 2.3.1
When you create a Tizen watch face application with the Tizen watch face app template, you may face an error during the build process because of an error in the `tizen-manifest.xml` file of the watch face app template.

To fix this error, modify the `tizen-manifest.xml` file as follows:

<blockquote>
<b>As is</b>

<p><watch-application appid="org.tizen.example.TizenWatchfaceApp1" exec="TizenWatchfaceApp1.dll" type="dotnet" ambient-support="false" <span style="color:red">>></span></p>

<b>To be</b>

<p><watch-application appid="org.tizen.example.TizenWatchfaceApp1" exec="TizenWatchfaceApp1.dll" type="dotnet" ambient-support="false" <span style="color:red">></span></p>

</blockquote>

### Watch face app execution with debugger on Samsung wearables

The following issue does not occur on the Tizen wearable emulator. An update will be globally released in May 2019.
{: .notice--danger}

An issue occurs when you execute a watch face application in debug mode by pressing the F5 key. Changing the watch face may fail on Samsung wearables that are based on Tizen 4.0.

This error will be fixed soon. Until then, use one the following workarounds:
- Press **ctrl + F5** to execute the watch face application without debugger.
- Change the watch face after running your application in debug mode and rebooting your Samsung smart watch.
