---
title: "Introducing Xamarin Essentials for Tizen"
search: true
last_modified_at: 2019-08-01
categories: Tizen.NET
author: Sungsu Kim
toc: true
toc_sticky: true
toc_label: Contents
redirect_to: https://developer.samsung.com/tizen/blog/en-us/2019/08/01/introducing-xamarin-essentials-for-tizen
---

<br/>
In July 2019, the Xamarin Developer Summit was held in Houston, Texas.

The Xamarin Developer Summit, which is the biggest Xamarin community event, was filled with lots of exciting news. One of the most important announcements was about Xamarin Essentials for Tizen, available on the Tizen 4.0 release.

## What is Xamarin Essentials

The Xamarin Essentials project is a common set of cross-platform APIs, which can replace platform-specific APIs.

> [Xamarin Essentials project][link_github]

When you create cross-platform mobile applications with Xamarin, most of the code is shared. However, some features require platform-specific APIs. Xamarin Essentials reduces the use of platform-specific APIs and replaces them with shared code. Xamarin Essentials can replace Android, iOS, UWP, and Tizen platform APIs.

## Xamarin Essentials APIs

The Xamarin Essentials API set does not replace every platform API, but it does provide many features:

> [Accelerometer][link_accelerometer]: Retrieves the devices' acceleration data in three-dimensional space. <br/>
> [ApplicationInformation][link_appinfo]: Finds information about the application. <br/>
> [Barometer][link_barometer]: Monitors the device's barometer sensor, which measures pressure. <br/>
> [Battery][link_battery]: Easily detects battery level, source, and state. <br/>
> [Browser][link_browser]: Quickly and easily opens a browser to a specific website.<br/>
> [Clipboard][link_clipboard]: Quickly and easily places or reads text on the clipboard.<br/>
> [Compass][link_compass]: Monitors compass for changes. <br/>
> [Connectivity][link_connectivity]: Checks connectivity state and detect changes. <br/>
> [DeviceDisplay][link_devicedisplay]: Gets the device’s screen metrics and orientation. <br/>
> [DeviceInformation][link_deviceinfo]: Easily finds information about the device. <br/>
> [Email][link_email]: Easily sends email messages. <br/>
> [Filesystem][link_filesystem]: Easily saves files to app data. <br/>
> [Flashlight][link_flashlight]: A simple way to turn the flashlight on/off. <br/>
> [Geocoding][link_geocoding]: Easily geocodes and reverses geocoding. <br/>
> [Geolocation][link_geolocation]: Retrieves the device’s GPS location. <br/>
> [Gyroscope][link_gyroscope]: Retrieves rotation around the device’s three primary axes. <br/>
> [Launcher][link_launcher]: Enables an application to open a URI by the system. <br/>
> [Magnetometer][link_magnetometer]: Detects device’s orientation relative to Earth’s magnetic field. <br/>
> [Maps][link_maps]: Enables an application to open the installed map application to a specific location or placemark. <br/>
> [OrientationSensor][link_orientationsensor]: Monitors the device's orientation in three-dimensional space. <br/>
> [PhoneDialer][link_dialer]: Opens the phone dialer. <br/>
> [Preferences][link_preferences]: Quickly and easily adds persistent preferences. <br/>
> [SecureStorage][link_securestorage]: Securely stores data. <br/>
> [Share][link_share]: Sends text and website URIs to other apps. <br/>
> [SMS][link_sms]: Easily sends SMS messages. <br/>
> [TextToSpeech][link_texttospeech]: Vocalizes text on the device. <br/>
> [Vibrate][link_vibrate]: Makes the device vibrate. <br/>

## Xamarin Essentials for Tizen

Xamarin Essentials for Tizen will be included on Xamarin Essentials version 1.3.0. To try using it now, install the prereleased NuGet package.

> [Xamarin.Essentials nuget][link_nuget]

You can also test the sample application included in the Xamarin Essentials project.

> [Xamarin Essentials sample][link_sample]

![img_mobile]

![img_watch]

![img_tv]

Tizen supports multi-profiles, such as Mobile, Wearables, and TV. Xamarin Essentials for Tizen is also available for multi-profile.

Xamarin Essentials for Tizen has the following limitations: <br>

| |Mobile Device|Mobile Emulator|Wearable Device|Wearable Emulator|TV Emulator|
|:-----------------:|:-----------------:|:-----------------:|:-----------------:|:-----------------:|:-----------------:|
| Support   |21|24|15|18|8|
| Limitation|8|3|12|9|19|

| |Mobile Device|Mobile Emulator|Wearable Device|Wearable Emulator|TV Emulator|Limitation|
|:-----------------:|:-----------------:|:-----------------:|:-----------------:|:-----------------:|:-----------------:|:-----------------:|
| Accelerometer|o|o|o|o|X|HW limitation|
| AppInfo|o|o|o|o|o| |
| Barometer|X|o|o|o|X|HW limitation|
| Battery|X|X|X|X|X|Platform limitation|
| Browser|o|o|X|X|X|Policy limitation|
| Clipboard|X|X|X|X|X|Platform limitation|
| Compass|X|o|X|o|X|HW limitation|
| Connectivity|o|o|o|o|o| |
| DeviceDisplay|X|X|X|X|X|Platform limitation|
| DeviceInfo|o|o|o|o|o| |
| Email|o|o|X|X|X|HW limitation|
| FileSystem|o|o|o|o|o| |
| Flashlight|o|o|X|X|X|HW limitation|
| Geocoding|o|o|o|o|o| |
| Geolocation|o|o|o|o|X|HW limitation|
| Gyroscope|X|o|o|o|X|HW limitation|
| Launcher|o|o|X|X|X|Policy limitation|
| Magnetometer|X|o|X|o|X|HW limitation|
| Map|o|o|X|X|X|Policy limitation|
| OrientationSensor|X|o|X|o|X|HW limitation|
| PhoneDialer|o|o|o|o|X|HW limitation|
| Preferences|o|o|o|o|o| |
| SecureStorage|o|o|o|o|o| |
| Share|o|o|X|X|X|Policy limitation|
| SMS|o|o|o|o|X|HW limitation|
| TextToSpeech|o|o|o|o|o| |
| Vibration|o|o|o|o|X|HW limitation|

## Summary

1. Xamarin.Essentials for Tizen is available with Xamarin Essentials version 1.3.0.
2. Xamarin.Essentials for Tizen works on Tizen 4.0-based devices.
3. Not supported for Battery, Clipboard, and DeviceDisplay features on Tizen platform 4.0.
4. Depending on the profiles, there are limitations due to hardware and policy differences.

[link_accelerometer]: https://docs.microsoft.com/en-us/xamarin/essentials/accelerometer
[link_appinfo]: https://docs.microsoft.com/en-us/xamarin/essentials/app-information
[link_barometer]: https://docs.microsoft.com/en-us/xamarin/essentials/barometer
[link_battery]: https://docs.microsoft.com/en-us/xamarin/essentials/battery
[link_browser]: https://docs.microsoft.com/en-us/xamarin/essentials/open-browser
[link_clipboard]: https://docs.microsoft.com/en-us/xamarin/essentials/clipboard
[link_compass]: https://docs.microsoft.com/en-us/xamarin/essentials/compass
[link_connectivity]: https://docs.microsoft.com/en-us/xamarin/essentials/connectivity
[link_devicedisplay]: https://docs.microsoft.com/en-us/xamarin/essentials/device-display
[link_deviceinfo]: https://docs.microsoft.com/en-us/xamarin/essentials/device-information
[link_email]: https://docs.microsoft.com/en-us/xamarin/essentials/email
[link_filesystem]: https://docs.microsoft.com/en-us/xamarin/essentials/file-system-helpers
[link_flashlight]: https://docs.microsoft.com/en-us/xamarin/essentials/flashlight
[link_geocoding]: https://docs.microsoft.com/en-us/xamarin/essentials/geocoding
[link_geolocation]: https://docs.microsoft.com/en-us/xamarin/essentials/geolocation
[link_gyroscope]: https://docs.microsoft.com/en-us/xamarin/essentials/gyroscope
[link_launcher]: https://docs.microsoft.com/en-us/xamarin/essentials/launcher
[link_magnetometer]: https://docs.microsoft.com/en-us/xamarin/essentials/magnetometer
[link_maps]: https://docs.microsoft.com/en-us/xamarin/essentials/maps
[link_orientationsensor]: https://docs.microsoft.com/en-us/xamarin/essentials/orientation-sensor
[link_dialer]: https://docs.microsoft.com/en-us/xamarin/essentials/phone-dialer
[link_preferences]: https://docs.microsoft.com/en-us/xamarin/essentials/preferences
[link_securestorage]: https://docs.microsoft.com/en-us/xamarin/essentials/secure-storage
[link_share]: https://docs.microsoft.com/en-us/xamarin/essentials/share
[link_sms]: https://docs.microsoft.com/en-us/xamarin/essentials/sms
[link_texttospeech]: https://docs.microsoft.com/en-us/xamarin/essentials/text-to-speech
[link_vibrate]: https://docs.microsoft.com/en-us/xamarin/essentials/vibrate
[link_github]: https://github.com/xamarin/Essentials
[link_nuget]: https://www.nuget.org/packages/Xamarin.Essentials/1.3.0-pre
[link_sample]: https://github.com/xamarin/Essentials/tree/dev/1.3.0/Samples
[img_mobile]: {{site.url}}{{site.baseurl}}/assets/images/posts/essentials/mobile.gif
[img_watch]: {{site.url}}{{site.baseurl}}/assets/images/posts/essentials/watch.gif
[img_tv]: {{site.url}}{{site.baseurl}}/assets/images/posts/essentials/tv.gif


