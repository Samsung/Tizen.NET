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

Previously, in order to use custom fonts in existing Xamarin.Forms applications, you had to add the font asset in each platform project and use the `FontFamily` property to apply the fonts. This was very cumbersome, because each platform required a different syntax for referencing a font file. 

As we introduced in a [previous blog post](https://samsung.github.io/Tizen.NET/tizen%20.net/custom-fonts), using custom fonts in your Tizen .NET applications was not so simple, either.

Xamarin.Forms 4.5.0 introduced a [new uniform way](https://github.com/xamarin/Xamarin.Forms/pull/6013) to specify custom fonts across platforms. You could define custom fonts on each platform and use them in the same way by including them as `Application Resources`, which was a feature available from [Xamarin.Forms 4.5.0 Pre Release 1](https://www.nuget.org/packages/Xamarin.Forms/4.5.0.142-pre1). We've added Tizen support to this feature, so you don't need to write code to use custom fonts. 

> **NOTE**: This change is effective as of [Xamarin.Forms 4.5.0 Pre Release 2](https://www.nuget.org/packages/Xamarin.Forms/4.5.0.187-pre2) and higher.

This blog explains how to use custom embedded fonts in Xamarin.Forms Tizen applications. 

## Add the font file to your project in Visual Studio

To add fonts as resources, perform the following steps in the Visual Studio.

### 1. Create a folder to store the font files

To create a folder for storing the font files, right-click the project folder and select **Add > New Folder**. 

<img src="https://d3unf4s5rp9dfh.cloudfront.net/Tizen_blog/customfont-create-folder.png" />

Let's call it **Resource**.

<img src ="https://d3unf4s5rp9dfh.cloudfront.net/Tizen_blog/customfont-create-folder 2.png" />

### 2. Add a font file to your project
To add a font file to your project, right-click the **Resource** folder you just created and go to **Add > Existing item...**, or drag the file from **File Explore** (on Windows) or **Finder** (on Mac) and drop it into **Resource** folder. You can add TrueType font (`.ttf`) and OpenType font (`.otf`) files. To obtain sample font files, go [here](https://github.com/xamarin/Xamarin.Forms/tree/master/Xamarin.Forms.Controls/Fonts).

<img src="https://d3unf4s5rp9dfh.cloudfront.net/Tizen_blog/customfont-add-fonts.png" />

**Note**: Be sure to add the font file with **`Build Action: Resources`**. Otherwise, the font file will not be distributed as part of your app.

<img src="https://d3unf4s5rp9dfh.cloudfront.net/Tizen_blog/customfont-add-fonts2.png" />

After you add the font file to your project as a `Resource`, you can begin assigning the font to `VisualElement` items that have the `FontFamily` property, such as `Label`, `Entry`, and so on. Font name can be specified in XAML or in C# code. As mentioned, you no longer need to know platform-specific rules for specifying `FontFamily` attributes. Whether it's using the full path and font name separated by a hash (#) as the font name (as in Android) or it's just using the font name (as in iOS), it works well.

**Note**: that the font file name and font name may be different. To discover the font name on Windows, right-click the `.ttf` file and select **Preview**. The font name can then be determined from the preview window.

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

Now that you've reviewed the simple steps in this blog, check out the sample font files, see the many TrueType and OpenType fonts that are out there, and try custom fonts in your own Xamarin.Forms Tizen applications. For any questions or issues you may have, don't hesitate to contact us.
