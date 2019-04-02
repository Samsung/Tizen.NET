---
title:  "Tizen Baseline SDK"
permalink: /issues/wearable/tizen-baseline-sdk
search: true
toc: true
toc_sticky: true
toc_label: Known Issues & Workarounds
---


## Connection Issue Between a Watch and Device Manager

Please refer to [Testing Your App on Gear][testing_app_on_watch] to learn about developing your application and testing it on your watch.

Even though you have followed every steps correctly, you could face the following error:

![][device_mgr_connection]

```sh
 ERROR: failed to connect to remote target '192.168.0.X'

 You may get this message for following reasons:
  - This remote device is already connected by another one.
  - This remote device is running on a non-standard port.
  - There is no IP address, please check the physical connection.
```

### Workaround
 - Check if both devices are connected to the same Wi-Fi network.
 - Try rebooting your PC and the Watch and connecting to the network.


[device_mgr_connection]: {{site.url}}{{site.baseurl}}/assets/images/issues/tools/device-manager-connection-issue.png
[testing_app_on_watch]: https://developer.samsung.com/galaxy-watch/develop/testing-your-app-on-gear
