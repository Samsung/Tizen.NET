---
title: "Introducing Xamarin Essentials for Tizen"
search: true
last_modified_at: 2019-08-01
categories: Tizen.NET
author: Sungsu Kim
toc: true
toc_sticky: true
toc_label: Contents
---

<br/>
In July, there was a `Xamarin Developer Summit` in Houston, Texas.<br/>
The `Xamarin Developer Summit` is the biggest `Xamarin` community event, and the event was filled with lots of exciting news.<br/>
Above all, one of the most important announcement was about `Xamarin Essentials for Tizen`.<br/>

## What is the Xamarin Essentials

`Xamarin Essentials` is a project for common set of cross platform APIs.<br/>
This API library can replace the platform specific API.<br/>

> [Xamarin Essentials project][link_github]

In other words,<br/>
When you create a cross platform mobile application with `Xamarin`, most of them are shared code.<br/>
However, some features require the platform specific API.<br/>
At this time, the `Xamarin Essentials` API reduces the use of platform specific API and replaces it with shared code.<br/>
Now `Xamarin Essentials` can replace the `Android`, `iOS`, `UWP` and `Tizen` platform APIs.<br/>

## Xamarin Essentials APIs

Currently, `Xamarin Essentials` provides many features.<br/>
It is not enought to replace every platform APIs, but it will grow more.<br/>

> [Accelerometer][link_accelerometer] : Retrieve acceleration data of the device in three dimensional space. <br/>
> [ApplicationInformation][link_appinfo] : Find out information about the application. <br/>
> [Barometer][link_barometer] : Monitor the device's barometer sensor, which measures pressure. <br/>
> [Battery][link_battery] : Easily detect battery level, source, and state. <br/>
> [Browser][link_browser] : Quickly and easily open a browser to a specific website. <br/>
> [Clipboard][link_clipboard] : Quickly and easily set or read text on the clipboard. <br/>
> [Compass][link_compass] : Monitor compass for changes. <br/>
> [Connectivity][link_connectivity]: Check connectivity state and detect changes. <br/>
> [DeviceDisplay][link_devicedisplay] : Get the device’s screen metrics and orientation. <br/>
> [DeviceInformation][link_deviceinfo] : Find out about the device with ease. <br/>
> [Email][link_email] : Easily send email messages. <br/>
> [Filesystem][link_filesystem] : Easily save files to app data. <br/>
> [Flashlight][link_flashlight] : A simple way to turn the flashlight on/off. <br/>
> [Geocoding][link_geocoding] : Easily geocode and reverse geocoding. <br/>
> [Geolocation][link_geolocation] : Retrieve the device’s GPS location. <br/>
> [Gyroscope][link_gyroscope] : Retrieve rotation around the device’s three primary axes. <br/>
> [Launcher][link_launcher] : Enables an application to open a URI by the system. <br/>
> [Magnetometer][link_magnetometer] : Detect device’s orientation relative to Earth’s magnetic field. <br/>
> [Maps][link_maps] : Enables an application to open the installed map application to a specific location or placemark. <br/>
> [OrientationSensor][link_orientationsensor] : Monitor the orientation of a device in three dimensional space. <br/>
> [PhoneDialer][link_dialer] : Open the phone dialer. <br/>
> [Preferences][link_preferences] : Quickly and easily add persistent preferences. <br/>
> [SecureStorage][link_securestorage] : Securely store data. <br/>
> [Share][link_share] : Send text and website Uris to other apps. <br/>
> [SMS][link_sms] : Easily send SMS messages. <br/>
> [TextToSpeech][link_texttospeech] : Vocalize text on the device. <br/>
> [Vibrate][link_vibrate] : Make the device vibrate. <br/>

## Xamarin Essentials for Tizen

`Xamarin Essentials for Tizen` will be included on `Xamarin Essentials` version 1.3.0.<br/>

If you want to try using it right now, you can install pre-released nuget package.<br/>

> [Xamarin.Essentials nuget][link_nuget]

You can also test the sample application included in the `Xamarin Essentials` project.<br/>

> [Xamarin Essentials sample][link_sample]

![img_mobile]

![img_watch]

![img_tv]

`Tizen` supports multi-profiles such as Mobile, Wearable, and TV.<br/>
Therefore, `Xamarin Essentials for Tizen` is also available for multi-profile.<br/>
Currently, there are some limitations on `Xamarin Essentials for Tizen`. <br/>

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
| Sms|o|o|o|o|X|HW limitation|
| TextToSpeech|o|o|o|o|o| |
| Vibration|o|o|o|o|X|HW limitation|

## Summary

1. `Xamarin.Essentials for Tizen` is available with `Xamarin Essentials` version 1.3.0.
2. `Xamarin.Essentials for Tizen` works on Tizen 4.0 based devices.
3. Not supported for `Battery`, `Clipboard`, and `DeviceDisplay` on Tizen platform 4.0.
4. Depending on the profiles, there are limitations due to hardware and policy differences.

It will make easier for developer to create Tizen applications more easily and effectively.<br/>

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


