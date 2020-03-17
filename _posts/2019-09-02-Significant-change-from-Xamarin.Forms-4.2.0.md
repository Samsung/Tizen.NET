---
title: "Significant changes on Tizen.NET from Xamarin.Forms 4.2.0"
last_modified_at: 2019-08-28
categories:
  - Tizen .NET
author: Jay Cho
toc: true
toc_sticky: true
redirect_to: https://developer.samsung.com/tizen/blog/en-us/2019/09/02/changes-to-tizennet-from-xamarinforms-420
---

`Xamarin.Forms 4.2.0` has been released, with significant changes on the Tizen platform.

## What has changed?
The namespaces of major classes were changed to what they are in other platforms. For example, `Xamarin.Forms.Platform.Tizen` has been changed to `Xamarin.Forms`.

For more details, check out an actual [Pull Request](https://github.com/xamarin/Xamarin.Forms/pull/7193) on Xamarin.Forms.

- Changed classes
  - Forms
  - ExportRendererAttribute
  - ExportCellAttribute
  - ExportImageSourceHandlerAttribute
  - ExportHandlerAttribute
  - ViewInitialzedEventArgs
  - TizenTitleBarVisibility

## How to apply changes in your application

Forms initialization code is changed as follows.

Previous
```cs
global::Xamarin.Forms.Platform.Tizen.Forms.Init(app);
```
Verson 4.2.0 change
```cs
Forms.Init(app);
```

The way to create a native control in Custom Renderers was changed as follows:

Previous
```cs
new MyButton(Xamarin.Forms.Platform.Tizen.Forms.NativeParent);
```

Verson 4.2.0 change
```cs
new MyButton(Forms.NativeParent);
```

You may also need to change static APIs you have used with older namespaces.
