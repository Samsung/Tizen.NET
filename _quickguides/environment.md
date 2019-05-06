---
title: "Environment"
permalink: /guides/environment/
toc: true
toc_sticky: true
---

Prepare to start developing Tizen .NET applications.

Tizen .NET applications can be developed on the both **Windows** and **macOS**. Using `Windows` and the `Visual Studio` is recommended, or you can use another process that works better for you.

## Windows
### Visual Studio
Using the `Visual Studio 2017` on `Windows` is the official and the most popular development environment.<br/>
Visit [Installing Visual Studio Tools for Tizen](https://developer.tizen.org/development/visual-studio-tools-tizen/installing-visual-studio-tools-tizen) for detailed prerequisites and step-by-step instructions. <br/>

#### Prerequisites
- 1.5 GB of available disk space
- Visual Studio 2017
  - Install with the `.NET desktop development` and `.NET Core cross-platform development` toolsets.
- Java Development Kit (JDK) 8
  - JDK 8 is required to use the Tizen Baseline SDK. 
  - Download JDK 8 from the official [Oracle Web site](https://www.oracle.com/technetwork/java/javase/downloads/index.html).
  - **Note**: JDK 9 is not yet supported.
  - OpenJDK 10 is supported from [Tizen Studio 3.1](https://developer.tizen.org/development/tizen-studio/download/release-notes).


### Visual Studio Code
Visit [Installing Visual Studio Code Extension for Tizen](https://developer.tizen.org/development/visual-studio-code-extension-tizen/installing-visual-studio-code-extension-tizen) for the installation guide.<br/>
Check out the [Known issues for the Visual Studio Code]({{site.url}}{{site.baseurl}}/issues/wearable/tools-vscode/).

## Mac
### Visual Studio Code
macOS 10.12 (Sierra) or later is required to install `Visual Studio Code Extension for Tizen`. <br/>
Visit [Installing Visual Studio Code Extension for Tizen](https://developer.tizen.org/development/visual-studio-code-extension-tizen/installing-visual-studio-code-extension-tizen) for the installation guide.<br/>
Check out the [Known issues for the Visual Studio Code]({{site.url}}{{site.baseurl}}/issues/wearable/tools-vscode/).

### Visual Studio for Mac
No official extension is provided for `Visual Studio for Mac`. <br/>
You cannot create a Tizen project and you do not see the Tizen tools on your `Visual Studio for Mac`.<br/>

If you already have your Tizen .NET project on your machine, you can open and build the project to generate the `tpk` file.

If you want to try installing and launching this `tpk` file on the emulator, install [Tizen Studio](https://developer.tizen.org/development/tizen-studio/download) or [Tizen Baseline SDK]({{site.url}}{{site.baseurl}}/guides/environment#tizen-baseline-sdk) on your macOS to use  Tizen tools such as `Package Manager`, `Emulator manager`, and `Certification Manager`.<br/>
Then:
- Install the emulator image on the `package-manager`
- Create and start the emulator on the `emulator-manager`
- Go to `Terminal`, navigate to the project output folder, and enter the following:

    ```sh
    MacBook:~ jay$ sdb install org.tizen.example.Hello.Tizen-1.0.0.tpk
    MacBook:~ jay$ sdb shell 0 execute <APP_ID>
    ```
    > `sdb` tool is located where Tizen Studio is installed, for example `~/tizen-studio/tools/`.
    
    > You can check the `<APP_ID>` in the `tizen-manifest.xml` file.


## Tizen Baseline SDK
The `Tizen baseline SDK` installer appars after you intall either `Visual Studio Tools for Tizen` or `Visual Studio Code Extension for Tizen`.

### Visual Studio Tools for Tizen
You can either install the new Tizen SDK or set the existing Tizen SDK.
<figure>
    <img src="{{site.url}}{{site.baseurl}}/assets/images/guides/install_tizensdk_vs.png">
</figure>


### Visual Studio Code Extension for Tizen
Once the extension has been activated, it asks if you want to use an existing Tizen baseline SDK installation or install a new one.<br/>
<figure>
    <img src="{{site.url}}{{site.baseurl}}/assets/images/guides/install_tizensdk_code.png">
</figure>
Click `NO` to perform a fresh installation.<br/>
Click `YES` to use the existing Tizen SDK.<br/>
Check out [here](https://developer.tizen.org/development/visual-studio-code-extension-tizen/installing-visual-studio-code-extension-tizen#setting-baseline-config) for more information.

You can manually download and install the `Tizen Baseline SDK` [here](http://download.tizen.org/sdk/Installer/Latest).
{: .notice--info}


## Download Links

 + [JDK 1.8](https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)
 + [Tizen Studio](https://developer.tizen.org/development/tizen-studio/download)
 + [Visual Studio 2017](https://visualstudio.microsoft.com/downloads/)   +   [Visual Studio Tools for Tizen](https://developer.tizen.org/development/visual-studio-tools-tizen/installing-visual-studio-tools-tizen#install) 
 + [Visual Studio Code](https://code.visualstudio.com/download)  +   [Visual Studio Code Extension for Tizen](https://developer.tizen.org/development/visual-studio-code-extension-tizen/installing-visual-studio-code-extension-tizen)
