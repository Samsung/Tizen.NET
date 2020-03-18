---
title: "Create a Tizen .NET Application for Wearables"
permalink: /guides/create-wearableapp/
toc: true
toc_sticky: true
gallery:
  - image_path: "/assets/images/guides/launch_elmsharp_wearable.png"
    title: "ElmSharp"
  - image_path: "/assets/images/guides/launch_nui_wearable.png"
    title: "Tizen.NUI"
  - image_path: "/assets/images/guides/launch_xf_wearable.png"
    title: "Xamarin.Forms"
redirect_to: https://developer.samsung.com/tizen/Galaxy-Watch/Quickstarts/Creating-an-application.html
---

This guide describes how to create and run the basic Tizen .NET application. Visit [Create Your First Tizen Wearable .NET Application](https://developer.tizen.org/development/training/.net-application/getting-started/creating-your-first-tizen-wearable-.net-application) for complete instructions.

Follow these step-by-step instructions to familiarize yourself with the Tizen .NET application development process.

1. Before you start developing Tizen applications, set up the [development environment]({{site.url}}{{site.baseurl}}/guides/environment).
2. [Create a project]({{site.url}}{{site.baseurl}}/guides/create-wearableapp#create-a-project) using Visual Studio.
3. [Build the application]({{site.url}}{{site.baseurl}}/guides/create-wearableapp#build-the-application).
4. [Deploying and Running the Application]({{site.url}}{{site.baseurl}}/guides/create-wearableapp#deploying-and-running-the-application).


## Create a project
To create a new Tizen .NET project:
1. Launch Visual Studio.
2. In the Visual Studio menu, select **File > New > Project**.
![]({{site.url}}{{site.baseurl}}/assets/images/guides/creating_project.png)
<br/>A **New Project** window appears.

3. Select **Installed > Other Languages > Visual C# > Tizen 4.0** or **Tizen 5.0**, and select the application template.
![]({{site.url}}{{site.baseurl}}/assets/images/guides/new_project.png)

Three application templates are provided for the basic blank application:
 - **Blank App (ElmSharp-Beta)** is a single-project template for building Tizen applications with [ElmSharp](https://samsung.github.io/TizenFX/API4/api/ElmSharp.html). The [ElmSharp](https://samsung.github.io/TizenFX/API4/api/ElmSharp.html) is a simple C# wrapper of native EFL elementary, which provides all the widgets you need to build a full application.
 - **Blank App (Tizen.NUI)** is a single-project template for building Tizen applications with [Tizen.NUI](https://samsung.github.io/TizenFX/API4/api/Tizen.NUI.html).
 **Blank App (Xamarin.Forms)** is a multiproject template for building applications with [Xamarin.Forms]({{site.url}}{{site.baseurl}}/guides/about#xamarin-forms), sharing code using a .NET Standard library. Use this template to make a cross-platform application.

Select the template you want to create, and enter the **Name**, **Location**, and **Solution name**.

If you selected the **Blank App (Xamarin.Forms)** template, you see the **Tizen Project Wizard**. Select the **Wearable (preview)** profile, and click **OK**.
![]({{site.url}}{{site.baseurl}}/assets/images/guides/project_wizard_wearable.png)

## Build the application
The building process performs a validation check and compiles your files. You must sign the application package with an author certificate when building the application. If you have not yet registered a Tizen certificate in Visual Studio, see [Certificate Manager](https://developer.tizen.org/development/visual-studio-tools-tizen/tools/certificate-manager).

There are two different ways to build the application:

  - In the Visual Studio menu, select **Build > Build Solution**.
  - In the **Solution Explorer view**, right-click the solution name and select **Build**.

Tizen .NET applications are always deployed as installed packages. The package files have the `.tpk` file extension, and the process of generating a package is controlled by the manifest file (`tizen-manifest.xml`).

## Deploy and run the application

To run the application, you must first deploy it to the target: either a device or an emulator. Deploying means transferring the package file (`.tpk`) to the target and invoking the Tizen package manager to install it.

To deploy and run the application on the emulator:

  1. In the Visual Studio menu, select **Tools > Tizen > Tizen Emulator Manager**.
  Alternatively, click **Launch Tizen Emulator** in the Visual Studio toolbar to launch the Tizen Emulator Manager.
  ![]({{site.url}}{{site.baseurl}}/assets/images/guides/launch_emul.png)
  2. In the Emulator Manager, select an emulator from the list and click Launch. If no applicable emulator instance exists, [you can create one](https://developer.tizen.org/development/visual-studio-tools-tizen/tools/emulator-manager#create).
  ![]({{site.url}}{{site.baseurl}}/assets/images/guides/emul_manager_wearable.png)
  3. Once you launch an emulator instance, you can deploy the application by clicking the emulator instance in the Visual Studio toolbar. In the Visual Studio toolbar, you can select the target from the dropdown to change the deployment target.
  ![]({{site.url}}{{site.baseurl}}/assets/images/guides/deploy_wearable.png)
  ![]({{site.url}}{{site.baseurl}}/assets/images/guides/deploy_changetarget_wearable.png)
  4. If the deployment is successful, the application launches on the emulator. The following figure shows the launched application on the wearable emulator:
  {% include gallery %}


## Watch face application
A well-designed [watch face](https://developer.samsung.com/galaxy-watch/design/watch-face) is a distinctive smartwatch feature. Use the Tizen Watchface App template when you create a new project:
![]({{site.url}}{{site.baseurl}}/assets/images/guides/new_project_watchface.png)

The template shows the current time on your watch:
![]({{site.url}}{{site.baseurl}}/assets/images/guides/launch_watchface.png)

Build and run as described in [Build the Application]({{site.url}}{{site.baseurl}}/guides/create-wearableapp#build-the-application) and [Deploy and Run the Application]({{site.url}}{{site.baseurl}}/guides/create-wearableapp#deploy-and-run-the-application).

For more details, you can review the [SimpleTextWatchface sample application](https://github.com/Samsung/Tizen.CircularUI/tree/master/test/SimpleTextWatchface).
