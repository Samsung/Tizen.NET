---
title: "Environment"
permalink: /guides/environment/
toc: true
toc_sticky: true
---

The guide describes how to set up an environment in which to develop Tizen .NET applications.

Tizen .NET applications can be developed on both **Windows** and **macOS**. We recommend using Visual Studio on Windows.

## Windows
### Visual Studio
Visual Studio 2017 on Windows is the official and the most popular development environment. Visit [Installing Visual Studio Tools for Tizen](https://developer.tizen.org/development/visual-studio-tools-tizen/installing-visual-studio-tools-tizen) for detailed prerequisites and step-by-step instructions.

#### Prerequisites
- 1.5 GB of available disk space
- Visual Studio 2017
  - Install with the .NET desktop development and .NET core cross-platform development toolsets.
- Java Development Kit (JDK) 8
     **Note**: JDK 9 is not yet supported.
  - JDK 8 is required to use the Tizen Baseline SDK.
  - Download JDK 8 from the official [Oracle Web site](https://www.oracle.com/technetwork/java/javase/downloads/index.html).
  - OpenJDK 10 is supported from [Tizen Studio 3.1 or above](https://developer.tizen.org/development/tizen-studio/download/release-notes).


### Visual Studio Code
- Visit [Installing Visual Studio Code Extension for Tizen](https://developer.tizen.org/development/visual-studio-code-extension-tizen/installing-visual-studio-code-extension-tizen) for the installation guide.
- Check [Known issues for the Visual Studio Code]({{site.url}}{{site.baseurl}}/issues/wearable/tools-vscode/).

## Mac
### Visual Studio Code
macOS 10.12 (Sierra) or later is required to install Visual Studio Code Extension for Tizen.
- Visit [Installing Visual Studio Code Extension for Tizen](https://developer.tizen.org/development/visual-studio-code-extension-tizen/installing-visual-studio-code-extension-tizen) for the installation guide.
- Check [Known issues for the Visual Studio Code]({{site.url}}{{site.baseurl}}/issues/wearable/tools-vscode/).

### Visual Studio for Mac
No official extension is provided for Visual Studio for Mac. However, if you already have your Tizen .NET project on your machine, you can open and build the project to generate the `tpk` file.

To launch this `tpk` file on the emulator, install [Tizen Studio](https://developer.tizen.org/development/tizen-studio/download) or [Tizen Baseline SDK]({{site.url}}{{site.baseurl}}/guides/environment#tizen-baseline-sdk) on your macOS to use Tizen tools such as Package Manager, Emulator Manager, and Certification Manager.
Then:
1. Install the emulator image on Package Manager.
1. Create and start the emulator on Emulator Manager.
1. Go to Terminal, navigate to the project output folder, and enter the following:

    ```sh
    MacBook:~ jay$ sdb install org.tizen.example.Hello.Tizen-1.0.0.tpk
    MacBook:~ jay$ sdb shell 0 execute <APP_ID>
    ```
  - The `sdb` tool is located where Tizen Studio is installed; for example `~/tizen-studio/tools/`.
  - You can check the `<APP_ID>` in the `tizen-manifest.xml` file.


## Tizen Baseline SDK
The Tizen Baseline SDK installer appears after you install either Visual Studio Tools for Tizen or Visual Studio Code Extension for Tizen.

### Visual Studio Tools for Tizen
You can install either the new Tizen SDK or set the existing Tizen SDK.
<figure>
    <img src="{{site.url}}{{site.baseurl}}/assets/images/guides/install_tizensdk_vs.png">
</figure>


### Visual Studio Code Extension for Tizen
Once the extension has been activated, it asks if you want to use an existing Tizen baseline SDK installation or install a new one.
<figure><img src="{{site.url}}{{site.baseurl}}/assets/images/guides/install_tizensdk_code.png">
</figure>
- Click **NO** to perform a fresh installation.
- Click **YES** to use the existing Tizen SDK.
Check [here](https://developer.tizen.org/development/visual-studio-code-extension-tizen/installing-visual-studio-code-extension-tizen#setting-baseline-config) for more information.

You can manually download and install the Tizen Baseline SDK [here](http://download.tizen.org/sdk/Installer/Latest).
{: .notice--info}


## Download Links

 + [JDK 1.8](https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)
 + [Tizen Studio](https://developer.tizen.org/development/tizen-studio/download)
 + [Visual Studio 2017](https://visualstudio.microsoft.com/downloads/)   +   [Visual Studio Tools for Tizen](https://developer.tizen.org/development/visual-studio-tools-tizen/installing-visual-studio-tools-tizen#install)
 + [Visual Studio Code](https://code.visualstudio.com/download)  +   [Visual Studio Code Extension for Tizen](https://developer.tizen.org/development/visual-studio-code-extension-tizen/installing-visual-studio-code-extension-tizen)
