---
title: "Significant changes on Tizen.NET from Xamarin.Forms 4.2.0"
last_modified_at: 2019-08-28
categories:
  - Tizen .NET
author: Jay Cho
toc: true
toc_sticky: true
---

`Xamarin.Forms 4.2.0` stable version has been released, and there are some significant changes on Tizen platform from this version.

## What are changed?
The namespaces of major classes are changed to what they are like in other platforms.<br/>
<b>`Xamarin.Forms.Platform.Tizen` is changed to `Xamarin.Forms`.</b><br/>
Check out an actual [Pull Request](https://github.com/xamarin/Xamarin.Forms/pull/7193) on Xamarin.Forms to see more details.

- Changed Classes
  - Forms
  - ExportRendererAttribute
  - ExportCellAttribute
  - ExportImageSourceHandlerAttribute
  - ExportHandlerAttribute
  - ViewInitialzedEventArgs
  - TizenTitleBarVisibility

## How to apply in your application

Forms initilaization code is changed like below.

[As-is]
```cs
global::Xamarin.Forms.Platform.Tizen.Forms.Init(app);
```
[To be]
```cs
Forms.Init(app);
```
<br/>
The way to create a native control in Custom Renderers is changed like below.

[As-is]
```cs
new MyButton(Xamarin.Forms.Platform.Tizen.Forms.NativeParent);
```

[To-be]
```cs
new MyButton(Forms.NativeParent);
```

You may also need to change static APIs you have used with older namespaces.<br/>
