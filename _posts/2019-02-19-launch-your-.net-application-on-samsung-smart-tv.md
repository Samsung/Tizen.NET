---
title: "Launch Your Tizen .NET Application on Samsung Smart TV"
categories:
  - Smart TVs
last_modified_at: 2019-02-19
author: Jay Cho
toc: true
toc_sticky: true
---

This post discusses how to run the Tizen .NET application with Xamarin.Forms on the Samsung Smart TV 2018 models. Learn how to run your own applications on Samsung Smart TV.

Xamarin.Forms developers, if you have a Tizen project already added on your Xamarin.Forms application, you are ready to begin. You can also review this blog for more details about adding Tizen projects (https://blog.xamarin.com/add-tizen-projects-xamarin-forms-apps/).

**Note**: The .NET application is only supported on Samsung Smart TV 2018 or later models that use Tizen 4.0 as a platform. For a list of supported models, go [here](https://developer.samsung.com/tv/develop/specifications/tv-model-groups).
{: .notice--info}

If you are new to developing Tizen .NET applications, we suggest that you browse [Quick Guides]({{site.url}}{{site.baseurl}}/guides) and [Installing Visual Studio Tools for Tizen](https://developer.tizen.org/development/visual-studio-tools-tizen/installing-visual-studio-tools-tizen).


## Development environment
### Windows
You must have Visual Studio Tools for Tizen installed. If you do not, [install the extension tool](https://developer.tizen.org/development/visual-studio-tools-tizen/installing-visual-studiotools-tizen) first. Tizen baseline SDK automatically installs after the extension tool is installed.
### Mac
No extension tool for Visual Studio for Mac is provided. You can download and [install the Tizen Baseline SDK]({{site.url}}{{site.baseurl}}/environment/tizen-baseline-sdk/) or install the full Tizen Studio [here](https://developer.tizen.org/development/tizen-studio/download).

---

There are two more extensions in Tizen Package Manager (**Tools > Tizen > Tizen Package Manager**).

- Samsung TV Extension
- Samsung Certificate Extension

The extensions are located on the **Extension SDK** tab. Install them if they are not already installed.

![image]({{site.url}}{{site.baseurl}}/assets/images/posts/launch-your-.net-application-on-samsung-smart-tv/package_manager.png)


## Connect the SDK to the TV
You can connect your SDK to a TV device as a remote device. Before you connect to the TV, confirm that:

- Your computer and TV are on the same network.
- You have prepared a certificate profile.


1. Enable Developer mode on your TV device
    1. Open the **Smart Hub**.
    2. Select the **Apps** panel.

        ![image]({{site.url}}{{site.baseurl}}/assets/images/posts/launch-your-.net-application-on-samsung-smart-tv/apps_panel.png)

    3. In the **Apps** panel, enter **12345** using the remote control or the onscreen number keypad. The following popup appears.

       ![image]({{site.url}}{{site.baseurl}}/assets/images/posts/launch-your-.net-application-on-samsung-smart-tv/dev_mode_popup.png)
    4. Switch **Developer mode** to **On**.
    5. Enter the host PC IP you want to connect to the TV, and click **OK**.
    6. Reboot the TV.

       ![image]({{site.url}}{{site.baseurl}}/assets/images/posts/launch-your-.net-application-on-samsung-smart-tv/reboot_popup.png)

After the TV reboots, open the **APPS** panel. **Developer Mode** is indicated at the top of the screen.

![image]({{site.url}}{{site.baseurl}}/assets/images/posts/launch-your-.net-application-on-samsung-smart-tv/dev_mode.png)


2. Connect the TV to the SDK
    1. In Visual Studio, navigate to **Tools > Tizen > Tizen Device Manager**.
       **Note**: For Mac users, launch Device Manager on Mac.

       ![image]({{site.url}}{{site.baseurl}}/assets/images/posts/launch-your-.net-application-on-samsung-smart-tv/device_manager1.png)

    2. Click **Remote Device Manager** and **+** to add a TV.

       ![image]({{site.url}}{{site.baseurl}}/assets/images/posts/launch-your-.net-application-on-samsung-smart-tv/device_manager2.png)

    3. In the **Add Device** popup, enter the information for the TV you want to connect to and click **Add**.

       ![image]({{site.url}}{{site.baseurl}}/assets/images/posts/launch-your-.net-application-on-samsung-smart-tv/device_manager3.png)

    4. Back to the Device Manager window, select the TV from the list, and switch the Connection to **On**.

      ![image]({{site.url}}{{site.baseurl}}/assets/images/posts/launch-your-.net-application-on-samsung-smart-tv/device_manager4.png)

When the TV is successfully connected, you can see the TV is connected as a device on the Visual Studio toolbar.

![image]({{site.url}}{{site.baseurl}}/assets/images/posts/launch-your-.net-application-on-samsung-smart-tv/vs_toolbar.png)

Now you are ready to launch your applications on the TV.


## Launch an application on the TV
### Visual Studio for Windows
On Windows, you can launch your application directly through Visual Studio using the **Ctrl + F5** shortcut.

### Visual Studio for Mac
After building the Tizen project, go to Terminal, move to the output folder and execute the following commands:

```sh
MacBook:~ jay$ sdb install org.tizen.example.Hello.Tizen-1.0.0.tpk
MacBook:~ jay$ sdb shell 0 execute <APP_ID>
```
- The `sdb` tool is located where the Tizen Studio is installed; for example `~/tizen-studio/tools/`.
- You can check the `<APP_ID>` in the `tizen-manifest.xml` file.

---

The application you installed on the Tizen 4.0 TV is automatically removed when the TV is turned off and on with cold boot.
