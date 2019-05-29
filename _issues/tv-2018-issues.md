---
title:  "Known issues on 2018 Smart TV"
permalink: /issues/tv/2018SmartTV/
search: true
toc: true
toc_sticky: true
toc_label: Known Issues & Workarounds
---

This section lists problems you might encounter while working with a Tizen TV emulator or a Samsung Smart TV.

## Common issues
 - `sdb shell` is not available
 - Cannot check the log messages
 - Cannot use debug mode

## Issues on the Smart TV device
 - Any applications loading third-party libraries (including .`so` files) are not allowed, because of Samsung Smart TV's security policy.
 - Interoperability is not allowed on Samsung Smart TV, because of security risks.
 - Test automation (such as with Appium) for the application is not available, because `sdb shell` is not available.
 - The application installed through your SDK will not be shown and is deleted when the TV device is rebooted.

***

## Issues on the TV emulator
The following TizenFX TV APIs are not supported on the TV emulator:
- [Tizen.TV.Accessory](https://developer.samsung.com/tv/tizen-net-tv/api-references/tizenfx-tv-api-references/Tizen.TV.Accessory)
- [Tizen.TV.Service.Billing](https://developer.samsung.com/tv/tizen-net-tv/api-references/tizenfx-tv-api-references/Tizen.TV.Service.Billing)
- [Tizen.TV.Service.Sso](https://developer.samsung.com/tv/tizen-net-tv/api-references/tizenfx-tv-api-references/Tizen.TV.Service.Sso/Sso-Class)

No workaround is available. We will keep you posted on further updates.

For details about the TV Extension 5.0 emulator, go [here](https://developer.samsung.com/tv/develop/tools/tv-extension/download).
