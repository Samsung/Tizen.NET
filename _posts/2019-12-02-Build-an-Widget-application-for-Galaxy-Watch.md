---
title:  "Build an widget application for Galaxy Watch"
search: true
categories:
  - Wearables
last_modified_at: 2019-12-02
author: Kangho Hur
toc: true
toc_sticky: true
---

Tizen wearable profile provides three application models, as decribed below, to create a variety of UI applications as needed.

- **Basic UI application**
  - A basic UI application provides a graphical user interface which allows the user to interact with the application.
- **Watch application**
  - A watch application (or watch face) provides a watch face with the current time (updated every second) as its user interface. The watch application is shown on the idle screen of the device, and supports a special ambient mode that reduces power consumption by showing a limited UI and updating the time on the screen only once per minute.
- **Widget application**
  - A widget application (or widget) is a specialized application that provides the user a quick view of specific information from the parent application. In addition, the widget allows the user to access certain features without launching the parent application. Combined with the parent application, your widget can have various features to increase the usability of your application.

This blog post describes how to publish an wiget application for your Galaxy Watch by using Tizen.NET and [Tizen.CircularUI](https://github.com/Samsung/Tizen.CircularUI).

## Widget Application and Widget Instance

As announced in the last Samsung Developers Conference 2019 (SDC19), you can create widget application using [Tizen.CircularUI version 1.4.0](https://www.nuget.org/packages/Tizen.Wearable.CircularUI/1.4.0) or higher.
In order to create an widget application, you need the following.

 - **FormsWidgetApplcation**
   - The `FormsWidgetApplication` represents a widget application to have widget instances.
 - **FormsWidgetBase**
   - The `FormsWidgetBase` represents a widget instance. Every widget instance has its own lifecycle simiar to the basic UI application. However, the widget instance is only an object shown by the widget viewer applications(e.g., `Home` app). 

### Widget Instance Lifecycle

The `FormsWidgetBase` class contains six virtual methods that can be overridden to respond to lifecycle changes.
 - `OnCreate()` : Called after the widget instance is created.
 - `OnDestroy()` : Called before the widget instance is destroyed.
 - `OnResume()` : Called when the widget is visible.
 - `OnPause()` : Called when the widget is invisible.
 - `OnResize()` : Called before the widget size is changed.
 - `OnUpdate()` : Called when an event for updating the widget is received.

The following figure illustrates the widget instance states during the instance life-cycle:
 - When the application is in the Ready state, the instance does not exist.
 - When the instance is created, it is in the `Created` state.
 - When the instance is visible, it is in the `Running` state.
 - When the instance is invisible, it is in the `Paused` state.
 - When the instance is destroyed, it is in the `Destroyed` state.

<img src="https://user-images.githubusercontent.com/1029134/69931572-1fc43f80-150b-11ea-96ec-a0e4532f1e4d.png">

## Getting Started
Now it’s time to create beatiful widget applications on your Galaxy Watch.

### Installing package 
#### Package Manager
```
PM> Install-Package Tizen.Wearable.CircularUI -Version 1.4.0
```
#### .NET CLI
```
dotnet add package Tizen.Wearable.CircularUI --version 1.4.0
```
#### Package Reference
```xml
<PackageReference Include="Tizen.Wearable.CircularUI" Version="1.4.0" />
```

### Quick Start
ℹ️ 
> Unfortunately, since the application template for the .NET widget is not yet available in Visual Studio, you have to create the widget application code yourself as shown below.

#### Step 1. Edit `tizen-manifest.xml`
Declare the application type and privileges in the Tizen manifest file.
```xml
<widget-application appid="org.tizen.example.MyWidget" update-period="0" exec="MyWidget.dll" type="dotnet">
    <label>MyWidget</label>
    <icon>icon.png</icon>
    <metadata key="http://tizen.org/metadata/prefer_dotnet_aot" value="true" />
    <support-size preview="MyWidget.png">2x2</support-size>
    <splash-screens />
</widget-application>

<privileges>
    <privilege>http://tizen.org/privilege/widget.viewer</privilege>
</privileges>
```

#### Step 2. Creating the Widget Base
[WidgetBase](https://samsung.github.io/TizenFX/latest/api/Tizen.Applications.WidgetBase.html) is the abstract class for widget instance. You should define your widget base, which is inherited from the ```FormsWidgetBase``` class as below. 
```cs
class MyWidgetBase : FormsWidgetBase
{
    public override void OnCreate(Bundle content, int w, int h)
    {
        base.OnCreate(content, w, h);
        // Create the Xamarin.Forms.Application to use your widget
        var app = new Application(); 
       // Load the application just like general Xamarin.Forms app.
        LoadApplication(app);
    }
}
```

#### Step 3. Creating the Widget Application
[WidgetApplication](https://samsung.github.io/TizenFX/latest/api/Tizen.Applications.WidgetApplication.html) represents a widget application. You should define your widget application, which is inherited from the ```FormsWidgetApplication``` class as below. 
```cs
class MyWidgetApp: FormsWidgetApplication
{
    public MyWidgetApp(Type type) : base(type) {  }

    static void Main(string[] args)
    {
        //Creates the widget application with widget base
        var app = new MyWidgetApp(typeof(MyWidgetBase));
        Forms.Init(app);
        FormsCircularUI.Init();
        app.Run(args);
    }
}
```

### Sample
If you're a fan of Xamarin.Forms :monkey_face: , you can remember the [PrettyWeather](https://github.com/jamesmontemagno/app-pretty-weather) app that [James](https://github.com/jamesmontemagno/) showed at the last .NET conference.
And, we slightly modified this beautiful application into a widget application that runs on the Galaxy Watch. :smiley:

<img src="https://github.com/rookiejava/sdc2019-tizen-net/raw/master/demo/GalaxyWatch/PrettyWeatherWidget/Screen_SanJose.png" width=180/> <img src="https://github.com/rookiejava/sdc2019-tizen-net/raw/master/demo/GalaxyWatch/PrettyWeatherWidget/Screen_Seoul.png" width=180/> <img src="https://github.com/rookiejava/sdc2019-tizen-net/raw/master/demo/GalaxyWatch/PrettyWeatherWidget/Screen_Boston.png" width=180/> <img src="https://github.com/rookiejava/sdc2019-tizen-net/raw/master/demo/GalaxyWatch/PrettyWeatherWidget/Screen_CityList.png" width=180/>

Check it out right [here](https://github.com/rookiejava/sdc2019-tizen-net/tree/master/demo/GalaxyWatch/PrettyWeatherWidget).
