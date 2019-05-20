---
title:  "How to Make a Video Player for Tizen Wearables"
search: true
categories:
  - Wearables
last_modified_at: 2019-05-20
author: Juwon(Julia) Ahn
toc: true
toc_sticky: true
toc_label: Video Player for Wearables
---

You can play media files stored in Galaxy Watch
or present over the Internet in your application.

In this post, we are going to discuss about how to create a video player for Tizen Wearables.

## [An Introduction to Circular UI MediaView & MediaPlayer APIs](#circular-ui-media-player-api)

In general, [Tizen.Multimedia API][Tizen.Multimedia] in TizenFX API is available to make certain apps such as video player. 

This is recommended for detailed control of media content.

Since [Tizen.CircularUI 1.1 version][Tizen.CircularUI_1.1], MediaView/MediaPlayer APIs are provided in Tizen.CircularUI API to make it easier to use. Please check out the following documents to learn how to use it.

 - API specification

      -- [Tizen.Wearable.CircularUI.Forms.MediaView][MediaView]

      -- [Tizen.Wearable.CircularUI.Forms.MediaPlayer][MediaPlayer]
      
      -- [Tizen.Wearable.CircularUI.Forms.MediaSource][MediaSource]

 - Developer guide

      -- [MediaView and MediaPlayer][MediaViewGuide]

## [The Necessary Privileges](#privilege-for-viedo-player)

Basically the screen should remain on while playing a video content.

Also, your app should be allowed to access the Internet to use online content. Internet connectivity is additionally required.

 - To access the Internet, `http://tizen.org/privilege/internet` should be declared

 - To keep the screen stay on during video play, `http://tizen.org/privilege/display` should be declared

 in `tizen-manifest.xml` file.

 In particular, `http://tizen.org/privilege/internet` privilege is one of the privacy-related privileges. Then, a user's permission should be granted.

### [User Permission for Privacy Privilege](#privacy-related-privilege)
  
  When you use privacy related functionality, an app user's permission should be granted.
  
  You can get more information about how your app can be granted permission to allow privacy related features by an app user.

  Go and check [the posting `Galaxy Watch: working with user privacy related permissions in Tizen .NET Applications`][UsePrivacyPrivilage]
  

  In addition, you can check [the list of the privacy-related privileged APIs][Privacy-related_privileged_API].

## Keep the Screen On During Video Play

Certain apps such as video apps need to keep the screen stay on.

To do this, we can use Power API that allows your application to control the screen state of the watch device.

However, it can have a significant effect on Galaxy Watch's battery life. Thus you should use it only when it is really necessary and you hold display lock for as short a time as possible.

Unfortunately, [Power.RequestLock()][Power_RequestLock] and [Power.ReleaseLock()][Power_ReleaseLock] cannot be used on Tizen 4.0 based Galaxy Watch because it has been provided since Tizen 5.0.

As an alternative, we can use [Tizen Native Power API][Native_Power_API] using [DllImport][DllImport].

### Use DllImport to call Native APIs

The following code shows how to use Tizen Native Power API in Tizen .NET App.

``` c#
  using System.Runtime.InteropServices;

  enum Power_Type {CPU = 0, DISPLAY, DISPLAY_DIM};

  void MakeScreenOn()
  {
      DevicePowerRequestLock(DISPLAY, 0);
  }

  void MakeScreenOff()
  {
      DevicePowerReleaseLock(DISPLAY);
  }

  [DllImport("libcapi-system-device.so.0", EntryPoint = "device_power_request_lock", CallingConvention = CallingConvention.Cdecl)]
  internal static extern int DevicePowerRequestLock(int type, int timeout_ms);

  [DllImport("libcapi-system-device.so.0", EntryPoint = "device_power_release_lock", CallingConvention = CallingConvention.Cdecl)]
  internal static extern int DevicePowerReleaseLock(int type);

```

For Tizen 5.0 and above based devices, using Tizen .NET Power API is recommended instead of using DllImport.
{: .notice--info}

## [Simple Video Player App](#video_player_for_wearables)

You can download [simple sample code][sample_code] and get info about [how to test this app][sample-how-to-test].






[DllImport]: https://docs.microsoft.com/en-us/dotnet/api/system.runtime.interopservices.dllimportattribute?view=netcore-2.0

[Tizen.CircularUI_1.1]: https://github.com/Samsung/Tizen.CircularUI/releases/tag/release-1.1.0
[UsePrivacyPrivilage]: https://program.developer.samsung.com/2019/04/26/galaxy-watch-working-with-user-privacy-related-permissions-in-tizen-net-applications
[Privacy-related_privileged_API]: https://developer.tizen.org/development/training/native-application/understanding-tizen-programming/security-and-api-privileges#native-api-privileges



[Tizen.Multimedia]: https://developer.tizen.org/dev-guide/csapi/api/Tizen.Multimedia.html
[MediaView]: https://samsung.github.io/Tizen.CircularUI/api/Tizen.Wearable.CircularUI.Forms.MediaView.html
[MediaPlayer]: https://samsung.github.io/Tizen.CircularUI/api/Tizen.Wearable.CircularUI.Forms.MediaPlayer.html
[MediaSource]: https://samsung.github.io/Tizen.CircularUI/api/Tizen.Wearable.CircularUI.Forms.MediaSource.html

[MediaViewGuide]: https://samsung.github.io/Tizen.CircularUI/guide/MediaView.html


[unit_tc1]: https://github.com/Samsung/Tizen.CircularUI/blob/master/test/WearableUIGallery/WearableUIGallery/TC/TCMediaViewAbsoluteLayout.xaml

[unit_tc2]: https://github.com/Samsung/Tizen.CircularUI/blob/master/test/WearableUIGallery/WearableUIGallery/TC/TCMediaViewStackLayout.xaml


[Native_Power_API]: https://developer.tizen.org/development/api-references/native-application?redirect=https://developer.tizen.org/dev-guide/4.0.0/org.tizen.native.wearable.apireference/group__CAPI__SYSTEM__DEVICE__POWER__MODULE.html
[Power_RequestLock]: https://developer.tizen.org/dev-guide/csapi/api/Tizen.System.Power.html#Tizen_System_Power_RequestLock_Tizen_System_PowerLock_System_Int32_
[Power_ReleaseLock]: https://developer.tizen.org/dev-guide/csapi/api/Tizen.System.Power.html#Tizen_System_Power_ReleaseLock_Tizen_System_PowerLock_

[sample_code]: https://github.com/Samsung/Tizen-CSharp-Samples/tree/master/Wearable/CircularUIMediaPlayer

[sample-how-to-test]: https://github.com/Samsung/Tizen-CSharp-Samples/blob/master/Wearable/CircularUIMediaPlayer/README.md#how-to-test-it