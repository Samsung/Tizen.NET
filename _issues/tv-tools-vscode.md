---
title:  "Visual Studio Code"
permalink: /issues/tv/tools-vscode/
toc: true
toc_sticky: true
---

Using `Visual Studio 2017` on Windows is definitely the number one choice for developing Tizen .NET applications. However, if you are a Mac user, `Visual Studio Code` can be one of the options to develop Tizen .NET applications.

Check out [Installing Visual Studio Code Extension for Tizen](https://developer.tizen.org/development/visual-studio-code-extension-tizen/installing-visual-studio-code-extension-tizen) to know more about Tizen .NET extension.
{: .notice--info}

The following known issues are based on the `1.1.0` version of the `Visual Studio Code Extension for Tizen` which is the latest at this moment. Check out the [Change Log](https://marketplace.visualstudio.com/items/tizen.vscode-tizen-csharp/changelog) to see the history.

## Version 1.1.0 (2019-01-08)
### Creating a Tizen .NET Project
  - command: `Tizen .NET: Create a Tizen .NET project`
    - Incomplete Xamarin.Forms Template (`Tizen.NET.Template.Cross.NETStandard`) is generated.<br/>
    You have to manually add a code line `LoadApplication(new App());` in the file `[Name].[profile]/[Name].[profile].cs` to show your application contents on the device screen.
    ```c#
    protected override void OnCreate()
    {
        base.OnCreate();
        // Following line needs to be added manually.
        LoadApplication(new App());
    }
    ```

### Debugging an Application in the Emulator
  - Run Debug mode may be not stable enough.

## Version 1.0.0 (2017-12-13)
### Creating a Tizen .NET Project
  - command: `Tizen .NET: Create a Tizen .NET project`
    - Templates including Xamarin Forms are Missing
    - Provides only followings at the moment
      - Tizen.NET.Template.ElmSharp
      - Tizen.NET.Template.NSClassLib
      - Tizen.NUI.Template.Single

### Running an Application 
  - command: `Tizen .NET: Run a Tizen .NET application on the Tizen device`
    - FAILS to install on Tizen 4.0 TV emulator

  - command: `Tizen .NET: Run debug mode`
    - 'Run debug mode' is not working properly.
    - FAILS with the message
      - "Failed to install the Tizen debug package, (Make sure the path info of the LLDB package is correct.)"

### Debugging an Application in the Emulator
  - Debug at the Debug Tab on VS Code Activity Bar
    - FAILS with the folowing error occurs
        - Popup: "Cannot read property 'message' of null"
        - Log: "No path info specified for LLDB packages in the settings." 
