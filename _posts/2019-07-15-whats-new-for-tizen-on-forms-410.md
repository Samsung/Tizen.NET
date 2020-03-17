---
title:  "What's new for Tizen on Xamarin.Forms 4.1.0"
search: true
categories:
  - Tizen .NET
last_modified_at: 2019-07-15
author: Sunghyun Min
toc: true
toc_sticky: true
redirect_to: https://developer.samsung.com/tizen/blog/en-us/2019/07/15/whats-new-for-tizen-on-xamarinforms-410
---

Many new UI features were added on `Xamarin.Forms 4.0`, including Shell, CollectionView and Material Visual.<br/>
Tizen support for these features was added on `Xamarin.Forms 4.1.0` which has been released on NuGet.
This post introduces each of new features.

## 1. Shell
The `Xamarin.Forms` Shell feature reduces the complexity of building mobile apps by providing fundamental app architecture features.

For more details on Shell, see [Shell navigation documentation](https://docs.microsoft.com/en-us/xamarin/xamarin-forms/app-fundamentals/shell/introduction)

Shell provides three types of common mobile navigation:
 - Flyout
 - Bottom Tabs
 - Top Tabs

![][shell]
 
## 2. CollectionView
CollectionView is used to present lists of data using different layout specifications. It provides a more flexible and performant alternative to ListView.

For more details on CollectionView, see [CollectionView documentation](https://docs.microsoft.com/en-us/xamarin/xamarin-forms/user-interface/collectionview/)<br/>

![][collectionview1]
![][collectionview2]
![][collectionview3]

## 3. Material Visual

Material Design is an opinionated design system created by Google, which prescribes the size, color, spacing, and other aspects of how views and layouts should look and behave.

Xamarin.Forms provides the way to apply material design across the platforms to controls in Xamarin.Forms apps. This is achieved with material renderers that apply the Material Design rules.

For more details on CollectionView, see [Material Visual documentation](https://docs.microsoft.com/en-us/xamarin/xamarin-forms/user-interface/visual/material-visual)

Because `Xamarin.forms 4.1.0` includes material renderers for Tizen, you can implement a Material look and feel in your Tizen .NET app without any custom renderers.

Supported controls in Tizen are:
 - ActivityIndicator
 - Button
 - Frame
 - Entry
 - ProgressBar
 - Slider
 - CheckBox <br/>

![][visual]
 
[shell]: {{site.url}}{{site.baseurl}}/assets/images/posts/whats-new-for-tizen-on-forms-410/shell.gif
[collectionview1]: {{site.url}}{{site.baseurl}}/assets/images/posts/whats-new-for-tizen-on-forms-410/collectionView.gif
[collectionview2]: {{site.url}}{{site.baseurl}}/assets/images/posts/whats-new-for-tizen-on-forms-410/collectionView2.gif
[collectionview3]: {{site.url}}{{site.baseurl}}/assets/images/posts/whats-new-for-tizen-on-forms-410/collectionView3.gif
[visual]: {{site.url}}{{site.baseurl}}/assets/images/posts/whats-new-for-tizen-on-forms-410/visual.gif
