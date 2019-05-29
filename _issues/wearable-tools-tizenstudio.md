---
title:  "Tizen Baseline SDK"
permalink: /issues/wearable/tizen-baseline-sdk/
search: true
toc: true
toc_sticky: true
toc_label: Known Issues and Workarounds
---


## Connection issue between a watch and Device Manager

Refer to [Testing Your App on Galaxy Watch][testing_app_on_watch] for information about developing your application and testing it on your watch.

Even if you follow every step correctly, you may face the following error:

```
 ERROR: failed to connect to remote target '192.168.0.X'

 You may get this message for one of the following reasons:
  - This remote device is already connected to another target.
  - This remote device is running on a nonstandard port.
  - There is no IP address. Please check the physical connection.
```

### Workaround
 - Check if both devices are connected to the same Wi-Fi network.
 - Reboot your PC and the watch, and connect to the network.


[testing_app_on_watch]: https://developer.samsung.com/galaxy-watch/develop/testing-your-app-on-gear
