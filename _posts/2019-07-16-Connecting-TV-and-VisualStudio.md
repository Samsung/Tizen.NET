---
title:  "Connecting TV and Visual Studio"
date:   2019-07-16
categories:
  - Smart TVs
author: Jay Cho
toc: true
toc_sticky: true
---

To deploy and run the application on the Samsung Smart TV, first connect your TV to Visual Studio.

## Prerequisites
- Connect your computer and the TV to the same network.


## Enable `Developer Mode` on the TV
  1. On the TV, open the "Smart Hub".
  2. Select the "Apps" panel.<br>
    ![image]({{site.url}}{{site.baseurl}}/assets/images/posts/connecting-tv-and-visualstudio/menu-apps.png)
  3. In the "Apps" panel, enter "12345" using the remote control or the on-screen number keypad.<br>
  The developer mode configuration popup appears.<br>
    ![image]({{site.url}}{{site.baseurl}}/assets/images/posts/connecting-tv-and-visualstudio/conf-popup.png)
  4. Switch "Developer mode" to "On".
  5. Enter the IP address of the computer that you want to connect to the TV, and click "OK".
  6. Reboot the TV.<br>
    ![image]({{site.url}}{{site.baseurl}}/assets/images/posts/connecting-tv-and-visualstudio/reboot-popup.png)

When you open the "Apps" panel after the reboot, "Develop Mode" is shown at the top of the screen.<br>
![image]({{site.url}}{{site.baseurl}}/assets/images/posts/connecting-tv-and-visualstudio/developer-mode.png)

## Connect TV to the Visual Studio
  1. In the Visual Studio, select "Tools > Tizen > Tizen Device Manager".<br>
     For Mac users, launch `device-manager`.
    ![image]({{site.url}}{{site.baseurl}}/assets/images/posts/connecting-tv-and-visualstudio/device-manager.png)
  2. To add a TV, click "Remote Device Manager" and "+".<br>
    ![image]({{site.url}}{{site.baseurl}}/assets/images/posts/connecting-tv-and-visualstudio/remote-device-manager.png)
  3. In the "Add Device" popup, define the information for the TV you want to connect to, such as the name, IP address, and port number, and click "Add". Normally, you just need to put in the IP address.<br>
    ![image]({{site.url}}{{site.baseurl}}/assets/images/posts/connecting-tv-and-visualstudio/add-device.png)
  4. In the Device Manager or Remote Device Manager window, select the TV from the list, and switch "Connection" to "On".<br>
    ![image]({{site.url}}{{site.baseurl}}/assets/images/posts/connecting-tv-and-visualstudio/connect-device.png)

When the TV is successfully connected, you can see it on the Visual Studio toolbar.<br>
![image]({{site.url}}{{site.baseurl}}/assets/images/posts/connecting-tv-and-visualstudio/connected-tv-on-vs.png)<br>
Now you can launch applications on the TV directly from the Visual Studio.

