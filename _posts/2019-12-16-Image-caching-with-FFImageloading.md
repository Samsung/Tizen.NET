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

인터넷에 있는 이미지를 앱에 표시할때는 때때로 네트워크 문제로 이미지 로딩에 실패하거나 매우 느리게 표시되는 경우가 발생합니다. 이때는 이미지가 표시 되기 전까지 임시 이미지를 표시하고, 로딩에 실패한 경우 다시 로딩을 시도하며, 이미 다운 받은 적이 있는 데이터의 경우 이를 또 사용하여 빠르게 이미지를 화면에 표시하는 방법으로 구현해야 합니다.

FFImageLoading은 이를 모든 기능이 구현된 라이브러리로 이미지를 빠르고 쉽게 로드할 수 있게 도와줍니다.

## What is FFImageLoading - Fast & Furious Image Loading 
Library to load images quickly & easily on Xamarin.iOS, Xamarin.Android, Xamarin.Forms, Xamarin.Mac / Xamarin.Tizen and Windows (UWP, WinRT).

### Features (support on Tizen)
- Configurable disk and memory caching
- Multiple image views using the same image source (url, path, resource) will use only one bitmap which is cached in memory (less memory usage)
- Deduplication of similar download/load requests. *(If 100 similar requests arrive at same time then one real loading will be performed while 99 others will wait).*
- Error and loading placeholders support
- Images can be automatically downsampled to specified size (less memory usage)
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
 If you want to handling events from CachedImage object on your app code, need to set `ExecuteCallbacksOnUIThread` property to `true`
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
 `CachedImage` provide a main functionality of FFImageLoading including cached image loading. a usage is very simmilar with original `Image` class of Xamarin.Forms.

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
 |ErrorPlaceholder|If set, if error occurs while loading image, an error placeholder is shown. It supports UriImageSource, FileImageSource and StreamImageSource.|
 |RetryCount (int, default: 3)|If image download failed, or something wrong happened, it can be automatically retried. Defines retries count.|
 |RetryDelay (int, default: 250)|If image download failed, or something wrong happened, it can be automatically retried. Defines retry delay.|
 |CacheDuration (Timespan, default: `TimeSpan.FromDays(90)`)|Defines how long file cache of downloaded image is valid.|

## Clear cache on the memory and disk
 If not enough memory on device, need to suppression memory usage in your app, FFImageLoading provide way to clear a cache on the memory

``` c#
// Provided in `CoreApplication`, it is the best place to clear memory cache
protected override void OnLowMemory(LowMemoryEventArgs e)
{
    FFImageLoading.ImageService.Instance.InvalidateMemoryCache();
}
```

 You can also clear a cache on the disk
``` c#
FFImageLoading.ImageService.Instance.InvalidateDiskCacheAsync();
```

## The Best usage of CachedImage
 `CachedImage` work best when used in `CollectionView`, because `CollectionView` is unload a view that out of sight and reload when come back to the sight. Once loaded image source is really quickly shown
![][img1]


## Privileges 
 If image from internet does not shown, check your app's privilege, it need internet privilege.

 In the `tizen-manifest.xml` file:
 - To access the Internet, declare `http://tizen.org/privilege/internet`


## Links
* [Project site](https://github.com/luberda-molinet/FFImageLoading)
* [API Reference](https://github.com/luberda-molinet/FFImageLoading/wiki/Xamarin.Forms-API)
* [Tizen Sample](https://github.com/luberda-molinet/FFImageLoading/tree/master/samples/Simple.TizenForms.Sample)

[img1]: {{site.url}}{{site.baseurl}}/assets/images/posts/image-caching/ffimage.gif