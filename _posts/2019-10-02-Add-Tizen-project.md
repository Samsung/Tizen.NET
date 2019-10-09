---
title: "Add Tizen project to Xamarin.Forms Applications"
last_modified_at: 2019-10-02
categories:
  - Tizen .NET
author: Jay Cho
toc: true
toc_sticky: true
---

This article provide helpful information for new Tizen .NET application developers to get started.

In many cases, you'll want to add a Tizen project to existing Xamarin.Forms cross-platform applications or implement Tizen renderers for Xamarin.Forms third-party libraries, which  already include other platforms. In these cases, you can simply add a Tizen project to the existing solution.

## Add a Tizen Project to Visual Studio
The following example shows a cross-platform app named SimpleText, which shows a line of text in the center. The text varies depending on the platform:

- On an Android Emulator, the text appears as “Welcome to Xamarin.Forms.Android!” <br/>
- On an iOS Simulator, the text appears as “Welcome to Xamarin.Forms.iOS!”

![][emulators]

Now, let's add a Tizen project to run on the Tizen platform in Visual Studio:

- Go to **File > Add > New Project**.
- Select the Tizen cross-platform template **Tizen XAML App (Xamarin.Forms)**
- Give your project the name `SimpleText.Tizen`.

<br/>

On the Tizen project wizard:
  ![][project-wizard]
1. Select “Common” as the profile. Other available profiles are Mobile, TV, and Wearable.
1. Choose **Select Project in Solution**.
1. Select `SimpleText` as the reference.
1. Add code `LoadApplication(new SimpleText.App())` to the `SimpleText.Tizen/SimpleText.Tizen.cs` file.

The following shows a quick runthrough of the process:
![][adding-tizen-project]

## Run on the Tizen platform
Now you are ready to build and run the application on Tizen platform.
I added the text for Tizen on `Label.Text` on the main page of the application.

```c#
<?xml version="1.0" encoding="utf-8" ?>
<ContentPage xmlns="http://xamarin.com/schemas/2014/forms"
             xmlns:x="http://schemas.microsoft.com/winfx/2009/xaml"
             xmlns:d="http://xamarin.com/schemas/2014/forms/design"
             xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
             mc:Ignorable="d"
             x:Class="SimpleText.MainPage">

    <StackLayout>
        <!-- Place new controls here -->
        <Label Text="{OnPlatform Android='Welcome to Xamarin.Forms.Android!',
            iOS='Welcome to Xamarin.Forms.iOS!',
            Tizen='Welcome to Xamarin.Forms.Tizen!'}}"
           HorizontalOptions="Center"
           VerticalOptions="CenterAndExpand" />
    </StackLayout>

</ContentPage>
```

You can check out how it looks on the Wearable target emulator.
![][tizen-emulator]


[adding-tizen]: {{site.url}}{{site.baseurl}}/assets/images/posts/add-tizen-project/adding-tizen-project.gif
[project-wizard]: {{site.url}}{{site.baseurl}}/assets/images/posts/add-tizen-project/project-wizard.png
[emulators]: {{site.url}}{{site.baseurl}}/assets/images/posts/add-tizen-project/emulators.png
[tizen-emulator]: {{site.url}}{{site.baseurl}}/assets/images/posts/add-tizen-project/tizen-emulator.png
