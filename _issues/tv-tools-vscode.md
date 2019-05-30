---
title:  "Visual Studio Code"
permalink: /issues/tv/tools-vscode/
toc: true
toc_sticky: true
---

Visual Studio 2017 on Windows is the number one choice for developing Tizen .NET applications. However, if you are a Mac user, you have the option of using Visual Studio Code to develop Tizen .NET applications.

See [Installing Visual Studio Code Extension for Tizen](https://developer.tizen.org/development/visual-studio-code-extension-tizen/installing-visual-studio-code-extension-tizen) for information about the Tizen .NET extension.
{: .notice--info}

The following known issues are based on Visual Studio Code Extension for Tizen version 1.1.0. For issue histories, see [Change Log](https://marketplace.visualstudio.com/items/tizen.vscode-tizen-csharp/changelog).

## Version 1.1.0 (2019-01-08)
### Creating a Tizen .NET project
  - command: `Tizen .NET: Create a Tizen .NET project`
    - An incomplete Xamarin.Forms template (`Tizen.NET.Template.Cross.NETStandard`) is generated. You must manually add the line `LoadApplication(new App());` in the file `[Name].[profile]/[Name].[profile].cs` to show your application contents on the device screen.
    ```c#
    protected override void OnCreate()
    {
        base.OnCreate();
        // Following line needs to be added manually.
        LoadApplication(new App());
    }
    ```

### Debug an application in the emulator
- Run debug mode may be not stable enough to use.

## Version 1.0.0 (2017-12-13)
### Create a Tizen .NET project
  - command: `Tizen .NET: Create a Tizen .NET project`
    - Templates, including Xamarin.Forms, are missing.
    - Only the following templates are provided:
      - Tizen.NET.Template.ElmSharp
      - Tizen.NET.Template.NSClassLib
      - Tizen.NUI.Template.Single

### Run an application
  - command: `Tizen .NET: Run a Tizen .NET application on the Tizen device`
    - Fails to install on the Tizen 4.0 TV emulator.

  - command: `Tizen .NET: Run debug mode`
    - Run debug mode is not working properly.
    - Fails with the message: </br>
      `Failed to install the Tizen debug package (make sure the path info of the LLDB package is correct).`

### Debug an application in the emulator
  - **Debug** tab on VS Code Activity Bar
    - Fails with the following messages:
        - Popup: `Cannot read property 'message' of null`
        - Log: `No path info specified for LLDB packages in the settings.`
