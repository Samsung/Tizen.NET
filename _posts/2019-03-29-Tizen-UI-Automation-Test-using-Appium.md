---
title: "Tizen UI Automation Test using Appium"
last_modified_at: 2019-03-29
categories:
  - Tizen .NET
author: SeungHyun Choi
toc: true
toc_sticky: true
---

## What is Appium?
[Appium](http://appium.io/) is an open-source test automation framework. The Tizen driver is added in Appium, so you can test UI automatically on the Tizen platform.

## Install and start Appium
Samsung recommends installing the Appium framework on a server that has a Tizen emulator or a connected device.

First, install [nodejs](https://nodejs.org/) so you can use the npm package manager and run Appium.
We recommend you install the latest stable version, although Appium supports node.js 6+.

If you have installed node.js, follow these steps:
1. Clone [Appium git](https://github.com/appium/appium.git)
```
   ~$ git clone https://github.com/appium/appium.git
```

2. Go to the Appium folder and `npm install`
```
    ~$ npm install
```

3. Build Appium with `gulp`
```
    ~$ gulp transpile
```

4. Run Appium
```
   ~$ nodejs .
```

If Appium is running well, you see results similar to the following:
![appium](https://user-images.githubusercontent.com/16184582/55209344-6697c200-5225-11e9-92d6-69c422be74bf.png)

## Add Tizen.Appium to Tizen .NET applications
To automate your Tizen .NET applications, add NuGet `Tizen.Appium` to your application project.

1. Install Tizen.Appium for ElmSharp or NUI projects.
1. Install Tizen.Appium.Forms for Xamarin.Forms projects.

![image]({{site.url}}/{{site.baseurl}}/assets/images/posts/tizen-ui-automation-test-using-appium/install_appium.png)

- ElmSharp and NUI applications require [Tizen.NET package](https://tizen.myget.org/feed/dotnet/package/nuget/Tizen.NET) version 6.0 or higher.
- Xamarin.Forms application requires [Tizen.NET 4.0.0](https://www.nuget.org/packages/Tizen.NET/4.0.0).

### Initialize Tizen.Appium

Add the following code to initialize Tizen.Appium.

#### ElmSharp application
```cs
using Tizen.Appium;

class App : CoreUIApplication
{
    protected override void OnCreate()
    {
        base.OnCreate();
        TizenAppium.StartService(AppType.ElmSharp);
        //...
     }
     //...
}
```

#### NUI application
```cs
using Tizen.Appium;

class Program : NUIApplication
{
    protected override void OnCreate()
    {
        base.OnCreate();
        TizenAppium.StartService(AppType.NUI);
        //...
    }
    //...
}
```

#### Xamarin.Forms application

```cs
using Tizen.Appium;

class Program : global::Xamarin.Forms.Platform.Tizen.FormsApplication
{
    protected override void OnCreate()
    {
        base.OnCreate();
        TizenAppium.StartService();
        LoadApplication(new App());
        //...
    }
    //...
}
```

## Set AutomationId in the test application

Tizen.Appium automates the user interface by activating controls on the screen and performing input. To do this, assign a unique identifier to each control. To set the identifier, use the `AutomationId` property, as shown in the following example.

**Note**: An exception is thrown if the `AutomationId` property is set more than once.

### ElmSharp application
```cs
var button = new Button(window)
{
    Text = "button",
    AutomationId = "button"
};
```

### NUI application
```cs
PushButton button = new PushButton
{
    LabelText = "Button",
    AutomationId = "button"
}
```

### Xamarin.Forms application
```cs
Button button = new Button
{
    Text = "Button",
    AutomationId = "button"
}
```

## Write your test script
Visual Studio has a template to help you add a Tizen .NET UI Test project to your application solution, which you can get as follows:

1. Right-click on the solution, and select **File > New Project**.
2. From **Tizen Templates**, select the **UI Test App** template.

### How to create a UI test project manually

1. Create a test project in Visual Studio.
   Select **Visual C# > Test > NUnit Test Project**.

   ![image](https://user-images.githubusercontent.com/16184582/54807302-2cc43a00-4cc0-11e9-82fc-ebdbdff3d7ae.png)

2. Add `Appium.WebDriver` as a package reference to your project (`*.csporj`).
     Tizen driver is supported as of Appium.WebDriver 4.0.0.2-beta. We recommend that you use this version or later.

    <img src="https://github.com/Samsung/Tizen.Appium/wiki/images/appium_webdriver_nuget.png">

3. Add the following code to initialize TizenDriver and set `AppiumOptions`.
```cs
public class UITest
{
    TizenDriver<TizenElement> _driver;

    [SetUp]
    public void Setup()
    {
        AppiumOptions appiumOptions = new AppiumOptions();

        appiumOptions.AddAdditionalCapability("platformName", "Tizen");
        appiumOptions.AddAdditionalCapability("deviceName", "emulator-26101");

        //Xamarin.Forms
        appiumOptions.AddAdditionalCapability("appPackage", "org.tizen.example.FormsApp.Tizen.Mobile");

        //ElmSharp
        //appiumOptions.AddAdditionalCapability("appPackage", "org.tizen.example.ElmSharpApp");

        //NUI
        //appiumOptions.AddAdditionalCapability("appPackage", "org.tizen.example.NUIApp");

        _driver = new TizenDriver<TizenElement>(new Uri("http://127.0.0.1:4723/wd/hub"), appiumOptions);
    }

    [Test]
    public void Test1()
    {
        _driver.FindElementByAccessibilityId("Button").Click();
    }
}
```
      - For more information about writing test scripts, see [Supported Commands](https://github.com/Samsung/Tizen.Appium/wiki/Supported-Commands).

   -  Be sure to set the Appium server IP (for example, 127.0.0.1:4723) and port number. We recommend you use the same port number as the Appium default, which is 4723.
   - To find a device name, use the `sdb devices` command.
4. Install NUnit3 Test Adapter.
   1. Go to **Tools > Extension and Updates**.
   1. Select **Online**. Search and select **NUnit 3 Test Adapter**.<br>
   ![image]({{site.url}}/{{site.baseurl}}/assets/images/posts/tizen-ui-automation-test-using-appium/install_nunit3_test_adapter.png)

5. Open **Test Explorer**.
   1. Go to **Test > Windows > Test Explorer**.
   1. Right-click on your test, and select **Run Selected Test**.
   ![image]({{site.url}}/{{site.baseurl}}/assets/images/posts/tizen-ui-automation-test-using-appium/run_test.png)

## Run a UI automation test
If you run the Appium project, you can control the application according to the created script.

The following image shows an Appium project running.

![appium_test](https://user-images.githubusercontent.com/16184582/55212704-0fe5b480-5234-11e9-8632-340ba84a7ab1.gif)

## You can run a UI automation test with the Tizen.NET application
If you create a Tizen.NET application, you can run it on Tizen devices. You can also use Appium for automatic UI tests and verifying your application on Tizen.

The following automation test example runs the calculator application. You can test simple and complex applications.

![calculator](https://user-images.githubusercontent.com/16184582/55212717-17a55900-5234-11e9-9be1-7fb1c4621800.gif){: .align-center}

## Support
The following platforms support Appium:
- <b>Wearables</b>: 4.0 or later version of wearable devices and emulator.
- <b>Mobile</b>: 4.0 or later version of emulator.
- <b>TV</b>:  Not supported.
