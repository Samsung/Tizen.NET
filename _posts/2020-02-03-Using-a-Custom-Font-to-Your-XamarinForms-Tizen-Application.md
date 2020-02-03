---
title:  "Using a Custom Font In Your Xamarin.Forms Tizen Applications"
search: true
categories:
  - Tizen .NET
last_modified_at: 2020-02-03
author: Kangho Hur
toc: true
toc_sticky: true
---

To use custom fonts in existing Xamarin.Forms applications, you have to add the font asset to each platform project and use the `FontFamily` property to apply the fonts. This is very cumbersome, because each platform requires a different syntax for referencing a font file. This is no different on Tizen. As introduced in [previous blog post](https://samsung.github.io/Tizen.NET/tizen%20.net/custom-fonts), using custom fonts in your Tizen .NET application is not that simple.

Thanks to the Xamarin.Forms community, `Xamarin.Forms 4.5.0` introduces a [new uniform way](https://github.com/xamarin/Xamarin.Forms/pull/6013) to specify the custom font across platforms. You can no longer define custom fonts on each platform and use them in the same way by including them as `Application Resources`, which was available from [Xamarin.Forms 4.5.0 Pre Release 1](https://www.nuget.org/packages/Xamarin.Forms/4.5.0.142-pre1). However, this version didn't include support for Tizen. 

We added Tizen support, and now there is no need to write code to use the fonts. You can also choose from any of thousands of available fonts and use them in your Xamarin.Forms Tizen application. 

> **NOTE**: This change will be effective as of [Xamarin.Forms 4.5.0 Pre Release 2](https://www.nuget.org/packages/Xamarin.Forms/4.5.0.187-pre2) or higher.

In this blog, we will describe how to use custom embedded fonts in Xamarin.Forms Tizen applications. 

## Add the font file to your project in Visual Studio

To add fonts as resources, perform the following steps in the Visual Studio:

### 1. Create a folder to store the font files
To create a folder for storing the font files, right click the project folder and select `Add > New Folder`. 

<img src="https://d3unf4s5rp9dfh.cloudfront.net/Tizen_blog/customfont-create-folder.png" />

Let's call it `Resources`.

<img src ="https://d3unf4s5rp9dfh.cloudfront.net/Tizen_blog/customfont-create-folder 2.png" />

### 2. Add a font file to your project
To add a font file to your project, right click the `Resources` folder (that would have been created in previous step) and go to `Add > Existing item...`, or drag the file from `File Explore` (on Windows) / `Finder` (on Mac) and drop it into `Resources` folder. You can add True Type Font (`.ttf`) and Open Type Font (`.otf`) files. The example font file you can obtain from [here](https://github.com/xamarin/Xamarin.Forms/tree/master/Xamarin.Forms.Controls/Fonts).

<img src="https://d3unf4s5rp9dfh.cloudfront.net/Tizen_blog/customfont-add-fonts.png" />

Also, make sure that adding the font file with **`Build Action: Resources`**. Otherwise, the font file will not be distributed as part of your app.

<img src="https://d3unf4s5rp9dfh.cloudfront.net/Tizen_blog/customfont-add-fonts2.png" />

After you add the font file to your project as a `Resource`, you can begin assigning the font to `VisualElement` having `FontFamily` property like `Label`, `Entry` and so on. Font name can be specified in XAML or specified in C# code. As I mentioned above, you no longer need to know platform specific rules for specifying `FontFamily` attributes. Whether it's using the full path and font name separated by a hash(`#`) as the font name (just like existing Android way) or it's just using the font name (just like existing iOS way),  it works well. :smiley:

> Note that the font file name and font name may be different. To discover the font name on Windows, right-click the `.ttf` file and select `Preview`. The font name can then be determined from the preview window.

## Use your custom font in XAML


```xml
<Label Text="Custom Font 한글" FontFamily ="CuteFont-Regular" />
<Label Text="Custom Font 한글" FontFamily ="Dokdo" />
<Label Text="Custom Font 한글" FontFamily ="PTM55FT#PTMono-Regular" /> 
<Label Text="Custom Font 한글" FontFamily ="fa-regular-400.ttf#FontAwesome5Free-Regular" />
```

## Use your custom font in C#

```cs
new Label 
{
    Text = "Custom Font 한글",
    FontFamily = "CuteFont-Regular"
};

new Label 
{
    Text = "Custom Font 한글",
    FontFamily = "Dokdo"
};

new Label 
{
    Text = "Custom Font 한글",
    FontFamily = "PTM55FT#PTMono-Regular"
};

new Label 
{
    Text = "Custom Font 한글",
    FontFamily = "fa-regular-400.ttf#FontAwesome5Free-Regular"
};
```

## Screenshot
<img src="https://d3unf4s5rp9dfh.cloudfront.net/Tizen_blog/customfont-screenshot.png" width="300" />
