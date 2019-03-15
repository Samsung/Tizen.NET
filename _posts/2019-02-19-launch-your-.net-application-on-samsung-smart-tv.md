---
title: "Launch Your .NET Application on Samsung Smart TV"
categories:
  - Smart TVs
last_modified_at: 2019-02-19
author: Jay Cho
toc: true
toc_sticky: true
---

I am very excited to share how to run the Tizen .NET application including the Xamarin.Forms application on the actual Samsung Smart TV 2018 models.
Try out and feel the remarkable moment to run your applications on the Samsung Smart TV!

To `Xamarin.Forms` developers, if you have a Tizen project already added on your `Xamarin.Forms` application, you are ready to go.
Or the [generous blog](https://blog.xamarin.com/add-tizen-projects-xamarin-forms-apps/) is right here to help you with adding the Tizen project.

> .NET application is only supported on Samsung Smart TV 2018 or later models which use Tizen 4.0 as a platform. <br/> See [here](https://developer.samsung.com/tv/develop/specifications/tv-model-groups) to see what models are supported.
{: .notice--info}

> If you are totally new to develop a Tizen .NET application, start by browsing the [`Quick Guides`]({{site.url}}{{site.baseurl}}/guides) and installing [Visual Studio Tools for Tizen](https://developer.tizen.org/development/visual-studio-tools-tizen/installing-visual-studio-tools-tizen).

<br/>

## Development Environment
### Windows
If you have the `Visual Studio Tools for Tizen` installed, you are almost done for the development environment.
If you don't, [install the extension tool](https://developer.tizen.org/development/visual-studio-tools-tizen/installing-visual-studio-tools-tizen) first. Installing Tizen baseline SDK automatically follows after.
### Mac
No extension tool for Visual Studio for Mac is provided. You should either simply download and [install the Tizen Baseline SDK]({{site.url}}{{site.baseurl}}/environment/tizen-baseline-sdk/) which is enough, or install the full `Tizen Studio` [here](https://developer.tizen.org/development/tizen-studio/download).


---

Now, check out two more extensions in `Tizen Package Manager` (Tools > Tizen > Tizen Package Manager)
> For Mac users, launch the `package-manager` on Mac.

- Samsung TV Extension
- Samsung Certificate Extension

You can find the extensions on "Extension SDK" tab, and install those if they are not installed.

![image]({{site.url}}{{site.baseurl}}/assets/images/posts/launch-your-.net-application-on-samsung-smart-tv/package_manager.png)

<br/>

## Connect the SDK to TV
You can connect your SDK to a TV device as a remote device.
Before you connect to the TV, make sure
- your computer and the TV are on the same network.
- you have prepared a certificate profile.

<br/>

1. Enable Developer Mode on your TV device
    1.  Open the "Smart Hub".
    2.  Select the "Apps" panel.

        ![image]({{site.url}}{{site.baseurl}}/assets/images/posts/launch-your-.net-application-on-samsung-smart-tv/apps_panel.png)

    3. In the "Apps" panel, enter "12345" using the remote control or the on-screen number keypad.
       You will then see the secret popup appears.

       ![image]({{site.url}}{{site.baseurl}}/assets/images/posts/launch-your-.net-application-on-samsung-smart-tv/dev_mode_popup.png)
    4. Switch "Developer mode" to "On".
    5. Enter the host PC IP which you want to connect to the TV, and click "OK".
    6. Reboot the TV.

       ![image]({{site.url}}{{site.baseurl}}/assets/images/posts/launch-your-.net-application-on-samsung-smart-tv/reboot_popup.png)

After the reboot, open the "Apps" panel and check out the "Developer Mode" is marked at the top of the screen.

![image]({{site.url}}{{site.baseurl}}/assets/images/posts/launch-your-.net-application-on-samsung-smart-tv/dev_mode.png)

<br/>

2. Connect the TV to SDK
    1. In your Visual Studio, go to "Tools > Tizen > Tizen Device Manager".
       > For Mac users, launch `device-manager` on Mac.

       ![image]({{site.url}}{{site.baseurl}}/assets/images/posts/launch-your-.net-application-on-samsung-smart-tv/device_manager1.png)

    2. Click "Remote Device Manager" and "+" to add a TV.

       ![image]({{site.url}}{{site.baseurl}}/assets/images/posts/launch-your-.net-application-on-samsung-smart-tv/device_manager2.png)

    3. In the "Add Device" popup, enter the information for the TV you want to connect to and click Add.

       ![image]({{site.url}}{{site.baseurl}}/assets/images/posts/launch-your-.net-application-on-samsung-smart-tv/device_manager3.png)

    4. Back to the Device Manager window, select the TV from the list, and switch the "Connection" to "On".

      ![image]({{site.url}}{{site.baseurl}}/assets/images/posts/launch-your-.net-application-on-samsung-smart-tv/device_manager4.png)

When the TV is successfully connected, you can see the TV is connected as a device on the Visual Studio toolbar.

![image]({{site.url}}{{site.baseurl}}/assets/images/posts/launch-your-.net-application-on-samsung-smart-tv/vs_toolbar.png)

Now you are ready to launch your applications on the TV. What a moment!

<br />

## Launch an Application
### Visual Studio (Windows)
On Windows, you have everything prepared by connecting the TV as a device. You can launch your application right through the Visual Studio. I normally use the shortcut, `Ctrl + F5`, to quickly start the application.

> Debug mode will be available in the future

### Visual Studio for Mac
You can use Terminal to install and launch the application, because no Tizen extension tool is provided for Visual Studio for Mac.
After building the Tizen project, go to Terminal, move to the output folder and execute the commands like following.

```sh
MacBook:~ jay$ sdb install org.tizen.example.Hello.Tizen-1.0.0.tpk
MacBook:~ jay$ sdb shell 0 execute <APP_ID>
```
> `sdb` tool is located where the Tizen Studio is installed, for example `~/tizen-studio/tools/`.

> You can check the `<APP_ID>` in the `tizen-manifest.xml` file.

---

The application you installed on the Tizen 4.0 TV will be automatically removed when the TV is turned off and on with cold boot.


## Start Now
The most tricky part will be to find a TV around you or maybe to get a new one, but you will find it worth to try launching your .NET applications on the Samsung Smart TV. If you are a Xamarin.Forms developer, you are also a TV application developer from now on. <br/>
