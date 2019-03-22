---
title:  "Using Custom Fonts in Tizen .NET apps"
search: true
categories:
  - Tizen .NET
last_modified_at: 2019-02-12
author: Juwon(Julia) Ahn
toc: true
toc_label: Custom Fonts in Tizen .Net Apps
---

## Xamarin.Forms application
[Sample code](https://github.com/Samsung/Tizen-CSharp-Samples/tree/master/Wearable/CustomFonts/src/WorkingWithFonts){: .btn .btn--info}

First of all, you can get general information regarding fonts in Xamarin.Forms from the following websites:
  - [Fonts in Xamarin.Forms][xamarin_fonts]
  - [Custom Fonts in Xamarin.Forms][custom_fonts]

### Install Fonts and Specify the Font Folder
You can add a font file (.ttf or .otf files) you want to use to your `res` directory and specify the global font path.

![][font_dir]

This code shows how to specify the global path of fonts.
   - API Spec: [ElmSharp.Utility.AppendGlobalFontPath][AppendGlobalFontPath]

```c#
    class Program : global::Xamarin.Forms.Platform.Tizen.FormsApplication
    {
        protected override void OnCreate()
        {
            base.OnCreate();
             // To use a custom font, you need to add a global font path.
            ElmSharp.Utility.AppendGlobalFontPath(this.DirectoryInfo.Resource);
            LoadApplication(new App());
        }
    }
```

### Use Custom Fonts
   Now, you can use custom fonts by setting the `FontFamily` attribute.
   The following example shows how to apply a custom font to a label.

```c#
----------
    C#
----------
    label.FontFamily = Device.RuntimePlatform == Device.iOS ? "Lobster-Regular" :
        Device.RuntimePlatform == Device.Tizen ? "Lobster" :
        Device.RuntimePlatform == Device.Android ? "Lobster-Regular.ttf#Lobster-Regular" : "Assets/Fonts/Lobster-Regular.ttf#Lobster",
```

```c#
-----------
   XAML
-----------
    <Label Text="Hello Forms with XAML">
        <Label.FontFamily>
            <OnPlatform x:TypeArguments="x:String">
                    <On Platform="Tizen" Value="Lobster" />
                    <On Platform="iOS" Value="MarkerFelt-Thin" />
                    <On Platform="Android" Value="Lobster-Regular.ttf#Lobster-Regular" />
                    <On Platform="UWP" Value="Assets/Fonts/Lobster-Regular.ttf#Lobster" />
            </OnPlatform>
        </Label.FontFamily>
    </Label>
```

![][xamarin_forms_screenshot]

## NUI application

[Sample code](https://github.com/Samsung/Tizen-CSharp-Samples/tree/master/Wearable/CustomFonts/src/NUIFontTest){: .btn .btn--info}

Since Tizen 5.0, you can use custom fonts for NUI applications.

### Install Fonts and Specify the Font Folder
You can add a font file (.ttf or .otf files) you want to use to your `res` directory and specify the global font path.

![][nui_font_dir]

This code shows how to specify the global path of fonts.
   - API Spec: [FontClient.Instance.AddCustomFontDirectory][AddCustomFontDirectory]

```c#
    FontClient.Instance.AddCustomFontDirectory(this.DirectoryInfo.Resource);
```

### Use Custom Fonts
   Now, you can use custom fonts by setting the `FontFamily` attribute.
   The following example shows how to apply a custom font to a text label.

```c#
    TextLabel text2 = new TextLabel("Apply a custom font to this label!");
    text2.FontFamily = "Lobster";
```
![][nui_screenshot]

[font_dir]: {{site.url}}{{site.baseurl}}/assets/images/posts/custom-fonts/custom_font_directory.png
[nui_font_dir]: {{site.url}}{{site.baseurl}}/assets/images/posts/custom-fonts/custom_font_directory_in_nui_app.png
[xamarin_forms_screenshot]: {{site.url}}{{site.baseurl}}/assets/images/posts/custom-fonts/custom_font_in_xamarin_forms_app.png
[nui_screenshot]: {{site.url}}{{site.baseurl}}/assets/images/posts/custom-fonts/custom_font_in_nui_app.png
[xamarin_fonts]: https://docs.microsoft.com/en-us/xamarin/xamarin-forms/user-interface/text/fonts
[custom_fonts]: https://xamarinhelp.com/custom-fonts-xamarin-forms/
[AppendGlobalFontPath]: https://developer.tizen.org/dev-guide/csapi/api/ElmSharp.Utility.html#ElmSharp_Utility_AppendGlobalFontPath_System_String_
[AddCustomFontDirectory]: https://developer.tizen.org/dev-guide/csapi/api/Tizen.NUI.FontClient.html#Tizen_NUI_FontClient_AddCustomFontDirectory_System_String_
