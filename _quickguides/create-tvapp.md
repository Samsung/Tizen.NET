---
title: "Creating Tizen .NET Application"
permalink: /guides/create-tvapp/
toc: true
toc_sticky: true
gallery:
  - image_path: "/assets/images/guides/launch_elmsharp_tv.png"
  - image_path: "/assets/images/guides/launch_nui_tv.png"
  - image_path: "/assets/images/guides/launch_xf_tv.png"
---


This guide shows how to create and run the basic Tizen .NET application.<br/>
Visit [Creating Your First Tizen TV .NET Application](https://developer.tizen.org/development/training/.net-application/getting-started/creating-your-first-tizen-tv-.net-application) for the full instruction and more information.<br/>

Follow the step by step instructions and familiarize yourself with the Tizen .NET application development process.

1. Before you get started with developing Tizen applications, set up the [development environment]({{site.url}}{{site.baseurl}}/guides/environment).
2. [Creating a Project]({{site.url}}{{site.baseurl}}/guides/create-tvapp#creating-a-project) using Visual Studio.
3. [Building the Application]({{site.url}}{{site.baseurl}}/guides/create-tvapp#building-the-application).
4. [Deploying and Running the Application]({{site.url}}{{site.baseurl}}/guides/create-tvapp#deploying-and-running-the-application).


## Creating a Project
To create a new Tizen .NET project:
1. Launch Visual Studio.
2. In the Visual Studio menu, select **File > New > Project**.
![]({{site.url}}{{site.baseurl}}/assets/images/guides/creating_project.png)
<br/>A New Project window appears.

3. Select **Installed > Other Languages > Visual C# > Tizen4.0 or Tizen 5.0** and select the application template.
![]({{site.url}}{{site.baseurl}}/assets/images/guides/new_project.png)

Three Application templates are provided for the basic blank application.
  - Blank App (ElmSharp-Beta)
  - Blank App (Tizen.NUI)
  - Blank App (Xamarin.Forms)

  > **Blank App (ElmSharp-Beta)** is a single project template for building Tizen applications with [ElmSharp](https://samsung.github.io/TizenFX/API4/api/ElmSharp.html). The [ElmSharp](https://samsung.github.io/TizenFX/API4/api/ElmSharp.html) is a simple c# wrapper of native EFL Elementary which provides all the widgets you need to build a full application.<br/>
  > **Blank App (Tizen.NUI)** is a single project template for building Tizen applications with [Tizen.NUI](https://samsung.github.io/TizenFX/API4/api/Tizen.NUI.html).<br/>
  > **Blank App (Xamarin.Forms)** is a multiproject template for building applications with [Xamarin.Forms]({{site.url}}{{site.baseurl}}/guides/about#xamarin-forms), sharing code using a .NET Standard library. Use this template to make a cross-platform application.<br/>

Select the template you want to create and enter the **Name**, **Location**, and **Solution name**.

If you selected the **Blank App (Xamarin.Forms)** template, you will see the `Tizen Project Wizard`. Select the **TV** profile and Click **OK**.
![]({{site.url}}{{site.baseurl}}/assets/images/guides/project_wizard_tv.png)

## Building the Application
The building process performs a validation check and compiles your files. You must sign the application package with an author certificate when building the application. If you have not yet registered a Tizen certificate in Visual Studio, see [Certificate Manager](https://developer.tizen.org/development/visual-studio-tools-tizen/tools/certificate-manager).

There are 2 different ways to build the application:

  - In the Visual Studio menu, select **Build > Build Solution**.
  - In the **Solution Explorer view**, right-click the solution name and select **Build**.

Tizen .NET applications are always deployed as installed packages. The package files have the `.tpk` file extension, and the process of generating a package is controlled by the manifest file (`tizen-manifest.xml`).

## Deploying and Running the Application

To run the application, you must first deploy it to the target: either a device or an emulator. Deploying means transferring the package file (`.tpk`) to the target and invoking the Tizen package manager to install it.

To deploy and run the application on the emulator:

  1. In the Visual Studio menu, select **Tools > Tizen > Tizen Emulator Manager**. <br/>
  Alternatively, click **Launch Tizen Emulator** in the Visual Studio toolbar to launch the Tizen Emulator Manager.<br/>
  ![]({{site.url}}{{site.baseurl}}/assets/images/guides/launch_emul.png)
  2. In the Emulator Manager, select an emulator from the list and click Launch.
  If no applicable emulator instance exists, [create one](https://developer.tizen.org/development/visual-studio-tools-tizen/tools/emulator-manager#create).<br/>
  ![]({{site.url}}{{site.baseurl}}/assets/images/guides/emul_manager_tv.png)
  3. Once you launch an emulator instance, you can deploy the application by clicking the emulator instance in the Visual Studio toolbar.<br/>
  In the Visual Studio toolbar, you can select the target from the drop-down list to change the deployment target.
  ![]({{site.url}}{{site.baseurl}}/assets/images/guides/deploy_tv.png)<br/><br/>
  ![]({{site.url}}{{site.baseurl}}/assets/images/guides/deploy_changetarget_tv.png)
  4. If the deployment is successful, the application launches on the emulator. The following figure shows the launched application on the tv emulator:
  ![]({{site.url}}{{site.baseurl}}/assets/images/guides/launch_elmsharp_tv.png)
  ![]({{site.url}}{{site.baseurl}}/assets/images/guides/launch_nui_tv.png)
  ![]({{site.url}}{{site.baseurl}}/assets/images/guides/launch_xf_tv.png)
