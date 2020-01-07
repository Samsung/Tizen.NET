---
title:  "Image caching using FFImageLoading"
search: true
categories:
  - Tizen.NET
last_modified_at: 2019-12-16
author: Seungkeun Lee
toc: true
toc_sticky: true
---

When you want to use an internet image in your application, you worry about the slow image loading or load failure caused by network issues. In this scenario, it is a good idea to show the default temporal image until the actual image is successfully loaded and ready to be displayed. Reusing the image data that has been downloaded can also make an image appear quickly.

The `FFImageLoading` library includes all these features to help you to load images quickly and easily.

## What is FFImageLoading - Fast and furious image loading 
The `FFImageLoading` library allows you to load images quickly and easily on Xamarin.iOS, Xamarin.Android, Xamarin.Forms, Xamarin.Mac,  Xamarin.Tizen, and Windows (UWP, WinRT).

### Features supported on Tizen
- Configurable disk and memory caching
- Multiple image views using the same image source (such as URL, path, resource) use only one bitmap, which is cached in memory (less memory usage)
- No duplication of similar download/load requests. That is, if 100 similar requests arrive simultaneously, one will load while the other 99 wait
- Support for error and loading placeholders
- Images can be automatically downsampled to a specified size (less memory usage)
- SVG support
- Image loading Fade-In animations support
- Can retry image downloads (RetryCount, RetryDelay)

## Getting started
  Let's use Fast & Furious Image on your Application

### Install the FFImageloading package
#### nuget.exe
```
nuget.exe install Xamarin.FFImageLoading.Forms
```
#### .NET CLI
```
dotnet add package Xamarin.FFImageLoading.Forms
```
#### Package reference
```xml
<PackageReference Include="Xamarin.FFImageLoading.Forms" Version="2.4.11.982" />
```

### Initialize FFImageLoading
 To use FFImageLoading, initialize library for tizen platform and setup various options
```cs
var app = new Program();
Forms.Init(app);
// Initialize FFImageLoading with FormsApplication object
FFImageLoading.Forms.Platform.CachedImageRenderer.Init(app);
```

### Setup options on startup time
 If you want to handle events from CachedImage object on your app code, you need to set `ExecuteCallbacksOnUIThread` property to `true`
```cs
protected override void OnCreate()
{
    base.OnCreate();
    var config = new FFImageLoading.Config.Configuration
    {
        ExecuteCallbacksOnUIThread = true,
    };
    FFImageLoading.ImageService.Instance.Initialize(config);
    LoadApplication(new App());
}
```

## CachedImage
 `CachedImage` provides a main functionality of FFImageLoading including cached image loading. A usage is very simmilar with the original `Image` class of Xamarin.Forms.

```xml
<?xml version="1.0" encoding="utf-8" ?>
<ContentPage xmlns="http://xamarin.com/schemas/2014/forms"
             xmlns:x="http://schemas.microsoft.com/winfx/2009/xaml"
             xmlns:ff="clr-namespace:FFImageLoading.Forms;assembly=FFImageLoading.Forms"
             x:Class="CachedImageSample.MainPage">
    <ContentPage.Content>
        <StackLayout>
            <ff:CachedImage LoadingPlaceholder="loading.jpg"
             Source="http://i.imgur.com/gkVgpL1.jpg"/>
        </StackLayout>
    </ContentPage.Content>
</ContentPage> 
```

```c#
var image = new CachedImage
{
    LoadingPlaceholder = "loading.jpg",
    Source = "http://i.imgur.com/gkVgpL1.jpg"
};
```
### Useful properties

| Property | Description |
|-|-|
|LoadingPlaceholder|If set, a loading placeholder is shown while loading. It supports UriImageSource, FileImageSource and StreamImageSource.|
 |ErrorPlaceholder|If set, an error placeholder is shown when error occurs while loading image. It supports UriImageSource, FileImageSource and StreamImageSource.|
 |RetryCount (int, default: 3)|If image download failed, or something wrong happened, it can be automatically retried. Defines retries count.|
 |RetryDelay (int, default: 250)|If image download failed, or something wrong happened, it can be automatically retried. Defines retry delay.|
 |CacheDuration (Timespan, default: `TimeSpan.FromDays(90)`)|Defines how long file cache of downloaded image is valid.|

## Clear cache on the memory and disk
 If there is not enough memory on a device, you need to suppress memory usage in your app, FFImageLoading provides a way to clear cache on the memory.

``` c#
// Provided in `CoreApplication`, it is the best place to clear memory cache
protected override void OnLowMemory(LowMemoryEventArgs e)
{
    FFImageLoading.ImageService.Instance.InvalidateMemoryCache();
}
```

 You can also clear cache on the disk.
``` c#
FFImageLoading.ImageService.Instance.InvalidateDiskCacheAsync();
```

## The Best usage of CachedImage
 `CachedImage` works best when it is used in `CollectionView`, because `CollectionView` unloads a view that is out of sight and reloads when it comes back to the sight. Once image source is loaded, it shows really quick.
![][img1]


## Privileges 
 If image from internet is not shown, check your app's privilege, it needs internet privilege.

 In the `tizen-manifest.xml` file:
 - To access the Internet, declare `http://tizen.org/privilege/internet`


## Links
* [Project site](https://github.com/luberda-molinet/FFImageLoading)
* [API Reference](https://github.com/luberda-molinet/FFImageLoading/wiki/Xamarin.Forms-API)
* [Tizen Sample](https://github.com/luberda-molinet/FFImageLoading/tree/master/samples/Simple.TizenForms.Sample)

[img1]: {{site.url}}{{site.baseurl}}/assets/images/posts/image-caching/ffimage.gif
