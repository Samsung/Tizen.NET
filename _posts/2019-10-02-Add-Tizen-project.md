---
title: "Add Tizen project to Xamarin.Forms Applications"
last_modified_at: 2019-10-02
categories:
  - Tizen .NET
author: Jay Cho
toc: true
toc_sticky: true
---

We see more people start developing Tizen .NET applications and this tip hopefully provides the better start.
Many of cases, you would want to add a Tizen project to the exising Xamarin.Forms cross-platform applications,
or you would want to implement Tizen renderers for Xamarin.Forms 3rd party libraries which also already have included other platforms.

In those cases, you can simply add a Tizen project to the existing solution.


## Add a Tizen Project on Visual Studio
As an example, below is a sample cross-platform app named SimpleText, which shows a simple line of text in the center. The text varies depending on the Platform:

On an Android Emulator, you’ll see the text displayed as “Welcome to Xamarin.Forms.Android!”. <br/>
On an iOS Simulator, the text is replaced with, “Welcome to Xamarin.Forms.iOS!”.

![][emulators]

 
Now, let's add a Tizen project to run on the Tizen platform in Visual Studio:

- Go to <b>File -> Add -> New Project.</b>
- Select the Tizen cross-platform template <b>Tizen XAML App (Xamarin.Forms)</b>
- Give your project the name `SimpleText.Tizen`.

<br/>

On the Tizen project Wizard:
  ![][project-wizard]
- Select “Common” as the Profile. For future projects, the available profiles are Mobile, TV, and Wearable.
- Choose <b>Select Project in Solution.</b>
- Select `SimpleText` as the reference.
- Add code `LoadApplication(new SimpleText.App())` to the `SimpleText.Tizen/SimpleText.Tizen.cs` file

Following is the quick through of the whole process.
![][adding-tizen]

## Run on Tizen platform
Now you are ready to build and run the application on Tizen platform.
I added the text for Tizen on `Label.Text` on the main page of application.

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

Checkout how it looks on the Wearable target emulator.
![][tizen-emulator]


[adding-tizen]: {{site.url}}{{site.baseurl}}/assets/images/posts/add-tizen-project/adding-tizen-project.gif
[project-wizard]: {{site.url}}{{site.baseurl}}/assets/images/posts/add-tizen-project/project-wizard.png
[emulators]: {{site.url}}{{site.baseurl}}/assets/images/posts/add-tizen-project/emulators.png
[tizen-emulator]: {{site.url}}{{site.baseurl}}/assets/images/posts/add-tizen-project/tizen-emulator.png
