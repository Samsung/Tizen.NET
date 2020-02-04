---
title:  "Using a Custom Font To Your Xamarin.Forms Tizen Application"
search: true
categories:
  - Tizen .NET
last_modified_at: 2020-02-03
author: Kangho Hur
toc: true
toc_sticky: true
---

Previously, in order to use custom fonts in existing Xamarin.Forms applications, you had to add the font asset in each platform project and use the `FontFamily` property to apply the fonts. This was very cumbersome, because each platform required a different syntax for referencing a font file. 

It was the same on Tizen. As we introduced in [previous blog post](https://samsung.github.io/Tizen.NET/tizen%20.net/custom-fonts), using custom fonts in your Tizen .NET applications wasn't very simple.

Xamarin.Forms 4.5.0 introduced a [new uniform way](https://github.com/xamarin/Xamarin.Forms/pull/6013) to specify the custom font across platforms. You can no longer define custom fonts on each platform and use them in the same way by including them as `Application Resources`, which was a feature available from [Xamarin.Forms 4.5.0 Pre Release 1](https://www.nuget.org/packages/Xamarin.Forms/4.5.0.142-pre1). Unfortunately, this version of Xamarin.Forms didn't include support for Tizen. So, we added the Tizen support, and now you don't need to write code to use the fonts. You you can choose from thousands of fonts to use in your Xamarin.Forms Tizen application. 

> **NOTE**: This change is effective as of [Xamarin.Forms 4.5.0 Pre Release 2](https://www.nuget.org/packages/Xamarin.Forms/4.5.0.187-pre2) and higher.

This blog explains how to use custom embedded fonts in Xamarin.Forms Tizen applications. 

## Add the font file to your project in Visual Studio

To add fonts as resources, perform the following steps in Visual Studio:

### Create a folder to store the font files

To create a folder for storing the font files, right-click the project folder and select **Add > New Folder**. 

<img src="https://d3unf4s5rp9dfh.cloudfront.net/Tizen_blog/customfont-create-folder.png" />

Let's call it **Resource**.

<img src ="https://d3unf4s5rp9dfh.cloudfront.net/Tizen_blog/customfont-create-folder 2.png" />

### Add a font file to your project

To add a font file to your project, right-click the **Resource** folder that you created in the previous step and go to **Add > Existing item...**, or drag the file from **File Explore** (on Windows) / **Finder** (on Mac) and drop it into the **Resource** folder. You can add TrueType font (`.ttf`) and OpenType font (`.otf`) files. For a folder of example fonts, go [here](https://github.com/xamarin/Xamarin.Forms/tree/master/Xamarin.Forms.Controls/Fonts).

<img src="https://d3unf4s5rp9dfh.cloudfront.net/Tizen_blog/customfont-add-fonts.png" />

**Note** Be sure to add the font file with **Build Action: Resources**. Otherwise, the font file will not be distributed as part of your app.

<img src="https://d3unf4s5rp9dfh.cloudfront.net/Tizen_blog/customfont-add-fonts2.png" />

After you add the font file to your project as a `Resource`, you can begin assigning the font any `VisualElement` that has a `FontFamily` property, such as `Label`, `Entry`, and so on. The font name can be specified in XAML or in C# code. As mentioned, you no longer need to know platform-specific rules for specifying `FontFamily` attributes. Whether you use the full path and font name separated by a hash (`#`) as the font name (as with Android), or you use just the font name (as with iOS), it works well.

**Note**: The font file name and font name may be different. To discover the font name in Windows, right-click the `.ttf` file and select **Preview**. You can then determine the font name from the preview window.

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
