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

When you want to use an internet image in your application, you may be concerned about slow image loading or load failure caused by network issues. In this scenario, it is a good idea to show the default temporal image until the actual image is successfully loaded and ready to be displayed. Reusing the image data that has been downloaded can also make an image appear more quickly.

The `FFImageLoading` library includes these features to help you to load images quickly and easily.

## FFImageLoading - Fast and furious image loading
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
Let's use `FFImageLoading` in your application.

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
 To use `FFImageLoading`, initialize the library for the Tizen platform and configure various options:
```cs
var app = new Program();
Forms.Init(app);
// Initialize FFImageLoading with FormsApplication object
FFImageLoading.Forms.Platform.CachedImageRenderer.Init(app);
```

### Set up options at startup
 If you want to handle events from `CachedImage` object on your app code, you need to set the `ExecuteCallbacksOnUIThread` property to `true`.
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
 `CachedImage` is a main function of `FFImageLoading`. It is very similar to the  Xamarin.Forms `Image` class.

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
|`LoadingPlaceholder`|If set, a loading placeholder appears. It supports `UriImageSource`, `FileImageSource`, and `StreamImageSource`.|
 |`ErrorPlaceholder`|If set, an error placeholder appears if an error occurs while loading an image. It supports `UriImageSource`, `FileImageSource`, and `StreamImageSource`.|
 |`RetryCount` (integer, default: 3)|Defines the retry count. If an image download or other failure occurs, it can be retried automatically.|
 |`RetryDelay` (integer, default: 250)|Defines the retry delay. If an image download or other failure occurs, it can automatically be retried.|
 |CacheDuration (Timespan, default: `TimeSpan.FromDays(90)`)|Defines the length of time the file cache of the downloaded image is valid.|

## Clear cache on the memory and disk
 If a device does not have enough memory, you must suppress memory usage in your app. `FFImageLoading` provides a way to clear the memory cache.

 ``` c#
  FFImageLoading.ImageService.Instance.InvalidateDiskCacheAsync();
  ```

 You can also clear the cache on the disk:
``` c#
FFImageLoading.ImageService.Instance.InvalidateDiskCacheAsync();
```

## Best use of CachedImage
 `CachedImage` works best when used in `CollectionView`, because `CollectionView` unloads a view that is out of sight, and reloads the view when it returns. Once the image source is loaded, it appears quickly.
![][img1]


## Privileges
 If an internet image is not shown, check your app for the `internet` privilege. In the `tizen-manifest.xml` file, declare `http://tizen.org/privilege/internet`


## Links
* [Project site](https://github.com/luberda-molinet/FFImageLoading)
* [API Reference](https://github.com/luberda-molinet/FFImageLoading/wiki/Xamarin.Forms-API)
* [Tizen Sample](https://github.com/luberda-molinet/FFImageLoading/tree/master/samples/Simple.TizenForms.Sample)

[img1]: {{site.url}}{{site.baseurl}}/assets/images/posts/image-caching/ffimage.gif
