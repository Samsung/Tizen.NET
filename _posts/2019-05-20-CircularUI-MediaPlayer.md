---
title:  "How to Make a Video Player for Tizen Wearables"
search: true
categories:
  - Wearables
last_modified_at: 2019-05-20
author: Juwon (Julia) Ahn
toc: true
toc_sticky: true
toc_label: Video Player for Wearables
---

You can play media files stored in Galaxy Watch, or present over the Internet in your application. In this post, we discuss how to create a video player for Tizen wearables.

## [An Introduction to Circular UI MediaView and MediaPlayer APIs](#circular-ui-media-player-api)

[Tizen.Multimedia API][Tizen.Multimedia] in TizenFX API is available to make certain apps, such as video players. We recommend using this API for detailed control of media content.

Since [Tizen.CircularUI version 1.1.0][Tizen.CircularUI_1.1], MediaView and MediaPlayer APIs are provided in the Tizen.CircularUI API to make it easier to use. The following documents provide further information on how to use:

 - API specifications

      -- [Tizen.Wearable.CircularUI.Forms.MediaView][MediaView]

      -- [Tizen.Wearable.CircularUI.Forms.MediaPlayer][MediaPlayer]

      -- [Tizen.Wearable.CircularUI.Forms.MediaSource][MediaSource]

 - Developer guide

      -- [MediaView and MediaPlayer][MediaViewGuide]

## [Necessary privileges](#privilege-for-video-player)

The screen must remain on while playing video content.

 Internet connectivity is required. Your app must be allowed to access the Internet to use online content.

In the `tizen-manifest.xml` file:

 - To access the Internet, declare `http://tizen.org/privilege/internet`.

 - To keep the screen on while playing a video, declare `http://tizen.org/privilege/display`.

 The `http://tizen.org/privilege/internet` privilege is a privacy-related privileges. A user's permission must be granted.

### [User permission for privacy privileges](#privacy-related-privilege)

An app user's permission must granted to use privacy-related functionality. For more information about how your app can be granted permission to allow use of  privacy-related features, see [`Galaxy Watch: working with user privacy related permissions in Tizen .NET Applications`][UsePrivacyPrivilage]

In addition, check [the list of the privacy-related privileged APIs][Privacy-related_privileged_API].

## Keep the screen on during video play

Video apps need to have the screen on while playing. To do this, use Power class APIs, which allow your application to control the screen state of the watch device.

These APIs have a significant effect on a Galaxy watch's battery life. We recommend you use them only when really necessary and hold the display lock for as short a time as possible.

[Power.RequestLock()][Power_RequestLock] and [Power.ReleaseLock()][Power_ReleaseLock] have been provided since Tizen 5.0 and therefore are unavailable for use on Tizen 4.0-based Galaxy watches. As an alternative, use [Tizen Native Power API][Native_Power_API] using [DllImport][DllImport].

### Use DllImport to call native APIs

The following code shows how to use Tizen native Power APIs in Tizen .NET apps.

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

For devices based on Tizen 5.0 and above, use Tizen .NET Power API instead of DllImport.
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
