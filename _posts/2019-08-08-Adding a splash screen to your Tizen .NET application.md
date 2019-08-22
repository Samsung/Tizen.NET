---
title:  "Add a splash screen to your Tizen .NET application"
search: true
categories:
  - Tizen.NET
author: Kangho Hur
last_modified_at: 2019-08-08
toc: true
toc_sticky: true
toc_label: Adding a splash screen to your Tizen .NET application
---

A splash screen appears instantly while your app launches and is quickly replaced with the app's first screen. Tizen provides an option for users to include splash screens in their applications. Splash screens can be customized based on orientation and resolution.
In this post, we take a look at how to add splash screens to your Tizen .NET applications. 

We'll use the StopWatch sample application for testing. The source code can be downloaded [here](https://github.com/Samsung/Tizen-CSharp-Samples/tree/master/Wearable/XStopWatch).

## Quick Guide 

- **Step 1.** Edit the `tizen-manifest.xml` file (we recommend you use the XML editor).
  - The following code adds `<splash-screens>` into the `<ui-application>` element. The image file is located in `shared/res`.

  <img src="https://user-images.githubusercontent.com/1029134/62266973-6f173800-b465-11e9-9fbc-5338b5032f06.png">
  
  - For further information, refer to the [Attribute Description](#Attribute Description).
  
- **Step 2.** Build, package, and install the application.

- **Step 3.** Launch the application.

| **No splash image** | **With splash image** |
|-|-|
|<img src="https://user-images.githubusercontent.com/1029134/62266998-88b87f80-b465-11e9-8d81-d317c6e2e365.gif" width="320"/> | <img src="https://user-images.githubusercontent.com/1029134/62267001-8a824300-b465-11e9-85bf-5feed6181b1f.gif" width="320"/>|

> The splash screen image is shown only when you launch the application by choosing from an application list (not when launching directly from Visual Studio).<br><br>
> Also, it is shown only when the app is launched for the first time. Make sure that the splash image is not shown if the app is running in the background and re-activates (resumes).

## Attribute Description

### `ui-application` Element
- `splash-screen-display` Attribute (Optional)
  - Value : `true` or `false`
  - Description : Specify whether splash screen is displayed or not. The default value is `true`.

### `splash-screen` Element 
- `src` Attribute (Mandatory)
  - Value : the file name of splash image (`*.png`, `*.jpg` or `*.edj`)
  - Description : Specify the resource file for splash screen.
- `type` Attribute (Mandatory)
  - Value : `img` or `edj`
  - Description : Specify the resource type.
- `orientation` Attribute (Mandatory)
  - Value : `portrait` or `landscape`
  - Description : Specify the orientation of splash image.
- `dpi` Attribute (Optional)
  - Value : `ldpi`, `mdpi`, `hdpi`, `xhdpi`, or `xxhdpi`
  - Description : Specify the resource resolution.
- `indicator-display` Attribute (Optional)
  - Value : `true` or `false`
  - Description : Specify whether indicator is displayed or not while splash image is showing (mobile only). The default value is `true`.
- `app-control-operation` Attribute (Optional)
  - Value : (string)
  - Description : Specify the specific `app-control` operation. Refer to [here](https://developer.tizen.org/development/guides/.net-application/application-management/application-controls?langredirect=1), if you want to get more information about `app-control` operations.
 
 > `<splash-screens>` element can be have multiple `<splash-screen>` element.
 
  
