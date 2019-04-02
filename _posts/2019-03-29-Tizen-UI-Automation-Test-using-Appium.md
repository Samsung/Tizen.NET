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
[Appium](http://appium.io/) is an open source test automation framework.<br>
I added the Tizen driver in Appium, so you can test UI automatically on the Tizen platform.

## Installing and Starting Appium
I recommand installing the Appium on the server that has a Tizen emulator or a connected device.

First, you have to install [nodejs](https://nodejs.org/), so that you can use npm and run Appium.
I recommend you to install the latest stable version, though Appium supports nodejs 6+.

If you have installed the nodejs, follow the steps below.
1. Clone [Appium git](https://github.com/appium/appium.git)
```
   ~$ git clone https://github.com/appium/appium.git
```

2. Go to appium folder and `npm install`
```
    ~$ npm install
```

3. Build Appium - Appium builds with `gulp`
```
    ~$ gulp transpile
```

4. Run appium
```
   ~$ nodejs .
```

If Appium is running well, you can see the result like below.
![appium](https://user-images.githubusercontent.com/16184582/55209344-6697c200-5225-11e9-92d6-69c422be74bf.png)

## Adding Tizen.Appium to Tizen .NET Applications
To automate your Tizen .NET applications, add Nuget `Tizen.Appium` to your application project.

>Install `Tizen.Appium` for `ElmSharp` or `NUI` project.<br>
>Install `Tizen.Appium.Forms` for `Xamarin.Forms` project.

![image](https://user-images.githubusercontent.com/16184582/55209484-36045800-5226-11e9-8ca6-991873ccb072.png)

> ElmSharp and NUI applications require a [Tizen.NET package](https://tizen.myget.org/feed/dotnet/package/nuget/Tizen.NET) version 6.0 or higher.

> Xamarin.Forms application requires a [Tizen.NET 4.0.0](https://www.nuget.org/packages/Tizen.NET/4.0.0).

### Initializing the Tizen.Appium

Add the following code to initialize `Tizen.Appium`. 

#### ElmSharp Application
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

#### NUI Application
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

#### Xamarin.Forms Application

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

## Setting AutomationId in the Test Application

`Tizen.Appium` automates the user interface by activating controls on the screen and performing input. To do this, you should assign a  unique identifier to each controls.<br>
The recommended way to set this identifier is to use an `AutomationId` property as shown below.
> Note that an exception will be thrown, if the `AutomationId` property is set more than once.

### ElmSharp Application
```cs
var button = new Button(window)
{
    Text = "button",
    AutomationId = "button"
};
```

### NUI Application
```cs
PushButton button = new PushButton
{
    LabelText = "Button",
    AutomationId = "button"
}
```

### Xamarin.Forms Application
```cs
Button button = new Button
{
    Text = "Button",
    AutomationId = "button"
}
```

## Writing Your Test Script
Visual Studio has a template to help add a Tizen .NET UI Test project to your application solution:
> Upcoming [Visual Studio Tools for Tizen](https://marketplace.visualstudio.com/items?itemName=tizen.VisualStudioToolsforTizen) will provide this template. Until then, you can manually create and use the UI test project.

1. Right click on the solution, and select `File` > `New Project`.

2. From the Tizen Templates, select the `UI Test App` template.

### How to Manually Create a UI Test Project

1. Create a test project in Visual Studio.<br>
   Select `Visual C#` -> `Test` -> `Nunit Test Project`
   > If you know how to use other test projects, you can use it.
   
   ![image](https://user-images.githubusercontent.com/16184582/54807302-2cc43a00-4cc0-11e9-82fc-ebdbdff3d7ae.png)

2. Add `Appium.WebDriver` as a package reference to your project (*.csporj).
>Tizen driver is supported from `Appium.WebDriver 4.0.0.2-beta`. Therefore, we recommend you to use this version or later.

    <img src="https://github.com/Samsung/Tizen.Appium/wiki/images/appium_webdriver_nuget.png">

3. Add the following code to initialize the `TizenDriver` and set the `AppiumOptions`.
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
> Refer [Supported Commands](https://github.com/Samsung/Tizen.Appium/wiki/Supported-Commands) to write test scripts.

    Make sure you set the appium server ip(ex:127.0.0.1:4723) and port number. You should set the same server port number. (appium default port number is '4723')
> If you want to find a device name, use 'sdb devices' command. You can find a device list and their name.

4. Install `Nunit3 Test Adapter`.<br>
   Go to `Tools` -> `Extesion and Updates` -> Select `Online` -> Search `Nunit 3 Test Adapter`<br>
   ![image](https://user-images.githubusercontent.com/16184582/54807753-94c75000-4cc1-11e9-9f3d-20f6f41b3d73.png)
   
5. Open `Test Explorer`.<br>
   Go to `Test` -> `Windows` -> `Test Explorer` -> Right-click on your test, and select `Run Test`.<br>
   ![image](https://user-images.githubusercontent.com/16184582/55212507-5686df00-5233-11e9-94af-dc4858b2d01a.png)

## Running UIAutomation Test
If you run the Appium project, you can control the application according to the created script.<br>
Below is an image of Appium Project running.

![appium_test](https://user-images.githubusercontent.com/16184582/55212704-0fe5b480-5234-11e9-8632-340ba84a7ab1.gif){: .align-center}

## You can run UI Automation Test with Tizen.NET Application
If you create a Tizen.NET application, you can run it on the Tizen devices.
In addition, you can also use Appium for automatic UI test and verifying your application, of course on Tizen.
The setting process can be a bit cumbersome, but this will change your coding life way better.

Below is another sample automation test example which runs the calculator application.
You can test not only the simple application, but also the complex application.

<b>Start it now.</b>

![calculator](https://user-images.githubusercontent.com/16184582/55212717-17a55900-5234-11e9-9be1-7fb1c4621800.gif){: .align-center}
