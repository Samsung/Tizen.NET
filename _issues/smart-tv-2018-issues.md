---
title:  "Known issues on 2018 Smart TV"
permalink: /issues/tv/2018SmartTV/
search: true
toc: true
toc_sticky: true
toc_label: Known Issues & Workarounds
---

This section lists up the problems that you might encounter while working with a Tizen TV emulator or a Samsung Smart TV.

### Common Known Issues
 >- `sdb shell` is not available
 >- Cannot check the log messages
 >- Cannot use the debug mode

### Issues on the Smart TV Device
 >- Any applications loading third-party libraries (including .so files) are not allowed, due to security policy of Samsung Smart TV.
 >- Interoperability is not allowed on Samsung Smart TV, due to the security risk.
 >- Test automation (like with the use of Appium) for the application is not available, because `sdb shell` is not available.
 >- The application installed through your SDK will not be shown and be deleted when the TV device is rebooted.
 
***

### Issues on the TV Emulator
  >- The following TizenFX TV APIs are not supported on the TV emulator.
 >> - [Tizen.TV.Accessory](https://developer.samsung.com/tv/tizen-net-tv/api-references/tizenfx-tv-api-references/Tizen.TV.Accessory)
 >> - [Tizen.TV.Service.Billing](https://developer.samsung.com/tv/tizen-net-tv/api-references/tizenfx-tv-api-references/Tizen.TV.Service.Billing)
 >> - [Tizen.TV.Service.Sso](https://developer.samsung.com/tv/tizen-net-tv/api-references/tizenfx-tv-api-references/Tizen.TV.Service.Sso/Sso-Class)

You can get detailed information about a TV Extension 5.0 emulator [here](https://developer.samsung.com/tv/develop/tools/tv-extension/download).

Unfortunately, there is no workaround at the moment.

We will keep you posted on any further update.
