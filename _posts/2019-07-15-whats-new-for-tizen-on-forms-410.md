---
title:  "What's new for Tizen on Xamarin.Forms 4.1.0"
search: true
categories:
  - Tizen .NET
last_modified_at: 2019-07-15
author: Sunghyun Min
toc: true
toc_sticky: true
---


`Xamarin.Forms 4.1.0` has been recently released on Nuget, and I'd like to introduce what's new for Tizen on `Xamarin.Forms 4.1.0`. <br/>
As you already know, many cool new features are added on `Xamarin.Forms 4.0`, and you may be wondered if those features are available on Tizen platform.


I am pleased to tell the major new UI features including Shell, CollectionView and Material Visual are supported on Tizen platform.<br/>
`Xamarin.Forms 4.1.0` includes Tizen support for the new UI features, and I'd like to show each features running on Tizen platform.


## 1.Shell
Shell is the main feature of new Xamarin.Forms. It seeks to reduce the complexity of building mobile apps by providing fundamental app architecture features.

For more details on Shell, you can check out [Shell navigation documentation](https://docs.microsoft.com/en-us/xamarin/xamarin-forms/app-fundamentals/shell/introduction)


Shell provides 3 types of common mobile navigation UI:
 - Flyout
 - Bottom Tabs
 - Top Tabs <br/>

![][shell]
 
## 2. CollectionView
CollectionView is a view for presenting lists of data using different layout specifications. It aims to provide a more flexible, and performant alternative to ListView.

For more details on CollectionView, you can check out [CollectionView documentation](https://docs.microsoft.com/en-us/xamarin/xamarin-forms/user-interface/collectionview/)<br/>

![][collectionview1]
![][collectionview2]
![][collectionview3]

## 3. Material Visual

Material Design is an opinionated design system created by Google, that prescribes the size, color, spacing, and other aspects of how views and layouts should look and behave.

Xamarin.Forms provides the way to apply material design across the platforms to controls in Xamarin.Forms apps.
This is achieved with material renderers, that apply the Material Design rules.

For more details on CollectionView, you can check out [Material Visual documentation](https://docs.microsoft.com/en-us/xamarin/xamarin-forms/user-interface/visual/material-visual)


Since `Xamarin.forms 4.1.0` includes material renderers for Tizen, you can implement a Material look-and-feel in your Tizen .NET app without any custom renderers.

The supported controls in Tizen are:
 - ActivityIndicaotr
 - Button
 - Frame
 - Entry
 - ProgressBar
 - Slider
 - CheckBox <br/>

![][visual]
 
Other controls will also be added soon.


[shell]: {{site.url}}{{site.baseurl}}/assets/images/posts/whats-new-for-tizen-on-forms-410/shell.gif
[collectionview1]: {{site.url}}{{site.baseurl}}/assets/images/posts/whats-new-for-tizen-on-forms-410/collectionView.gif
[collectionview2]: {{site.url}}{{site.baseurl}}/assets/images/posts/whats-new-for-tizen-on-forms-410/collectionView2.gif
[collectionview3]: {{site.url}}{{site.baseurl}}/assets/images/posts/whats-new-for-tizen-on-forms-410/collectionView3.gif
[visual]: {{site.url}}{{site.baseurl}}/assets/images/posts/whats-new-for-tizen-on-forms-410/visual.gif
