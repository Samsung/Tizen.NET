---
title:  "About Tizen .NET"
permalink: /guides/about/
toc: true
toc_sticky: true
---

## What is Tizen .NET?
**Tizen .NET** is an exciting new way to develop applications for the Tizen operating system, which runs on 50 million Samsung devices, including TVs and wearables, worldwide.

Existing Tizen frameworks are either C-based with no advantages of a managed runtime, or HTML5-based with fewer features and lower performance than the C-based solution. With Tizen .NET, you can use the C# programming language, the Common Language Infrastructure standards, and benefits from a managed runtime for faster application development and code execution that is efficient and secure.

<figure>
    <img src="{{site.url}}{{site.baseurl}}/assets/images/guides/cs_overview.png">
</figure>

You can develop and run Tizen .NET applications on both wearable devices and TVs: <br/>
  - Wearables: Galaxy Watch, Galaxy Watch Active, Gear S3, Gear Sport
  - TV: [2018 Smart TV models](https://developer.samsung.com/tv/develop/specifications/tv-model-groups) or higher.
  {: .notice--info}



## Programming Environment

### .NET Standard API
One of the major components of .NET Core is the .NET Standard. The .NET APIs provided by Tizen .NET follow .NET Standard 2.0. The column titled **2.0** in the [official list](https://docs.microsoft.com/en-us/dotnet/standard/net-standard) of the supported CoreFX APIs lists all available .NET APIs.

There are limitations of .NET Standard API on Tizen. For more information, see [Limitations of .NET Standard API on Tizen](https://developer.tizen.org/development/api-reference/.net-application/limitations-.net-standard-api-on-tizen).

### TizenFX
[TizenFX](https://github.com/Samsung/TizenFX) contains a variety of features that allow your applications to access platform-specific functionalities. This API enables [Xamarin.Forms](https://docs.microsoft.com/en-us/xamarin/xamarin-forms/get-started/) applications to perform functions that a native application can perform.

The brief explanation for each namespace of TizenFX is provided on the bottom of [this linked page](https://developer.tizen.org/development/api-reference/.net-application). <br/>
- [TizenFX 4.0 API Reference](https://samsung.github.io/TizenFX/API4/) for the `Galaxy Watch` and [`Samsung Smart TV 2018 TV models`](https://developer.samsung.com/tv/develop/specifications/tv-model-groups).

### Xamarin Forms
[Xamarin.Forms](https://docs.microsoft.com/en-us/xamarin/xamarin-forms/get-started/) provides cross-platform APIs, which allow you to create user interfaces that can be shared across platforms. The Tizen.NET Visual Studio extension enables Tizen support for Xamarin.Forms.

You can efficiently build your Tizen .NET application UI and its supporting logic using the Xamarin.Forms APIs. Extended details for these APIs are available on the [Xamarin Web site](https://docs.microsoft.com/en-us/dotnet/api/Xamarin.Forms?view=xamarin-forms).

Here are some helpful Xamarin Forms extensions: 
 - [Tizen Circular UI]({{site.url}}{{site.baseurl}}/resources/SamsungWearables#tizen-circular-ui-apis) helps you easily and efficiently create Tizen wearable-specific user interfaces.
 - [Tizen TV UIControl]({{site.url}}{{site.baseurl}}/resources/SamsungSmartTV#tizen-tv-uicontrols) provides many UI controls that you can use when developing TV applications.
