---
title:  "Bring beautiful Lottie animation to your Galaxy Watch apps"
search: true
categories:
  - Wearables
last_modified_at: 2019-05-22
author: Kangho Hur
toc: true
toc_sticky: true
toc_label: Lottie for Tizen .NET
---

[Lottie](https://github.com/airbnb/lottie) is a library for various platforms. It parses [Adobe After Effects](http://www.adobe.com/products/aftereffects.html) animations exported as JSON with [Bodymovin](https://github.com/bodymovin/bodymovin) and renders them natively on mobile and on the web.
You can use Lottie on Android, iOS, Windows, web, and Xamarin apps.

<img src="https://github.com/airbnb/lottie/raw/master/images/Introduction_00_sm.gif">
<img src="https://github.com/airbnb/lottie/raw/master/images/Introduction_01_sm.gif">

In this post, I'll introduce how to use the Lottie animation to create beautiful animations for your Galaxy Watch using Tizen .NET.

## What is ElottieSharp?

[ElottieSharp](https://github.com/TizenAPI/ElottieSharp) is a library for Tizen .NET that parses and renders Lottie animation natively on Galaxy Watch.
ElottieSharp is distributed through NuGet. To use Lottie animation in your apps, simply add the [ElottieSharp package](https://www.nuget.org/packages/ElottieSharp) to your projects.

**Note**: Because the [Galaxy Watch](https://www.samsung.com/global/galaxy/galaxy-watch/) and [Gear S-series](https://www.samsung.com/global/galaxy/gear-s3/) platform has been upgraded to version 4.0.0.4, [ElottieSharp 0.9.0-preview](https://www.nuget.org/packages/ElottieSharp/0.9.0-preview) is now cow compatible with [Galaxy Watch Active](https://www.samsung.com/global/galaxy/galaxy-watch-active/), [Galaxy Watch](https://www.samsung.com/global/galaxy/galaxy-watch/), and [Gear S series](https://www.samsung.com/global/galaxy/gear-s3/). Other products, including previous Gear S series and Samsung Smart TV, are not compatible.

<img src="https://user-images.githubusercontent.com/1029134/58157778-061c8280-7cb4-11e9-93ff-06a879949a06.gif">

## Getting Started
Let's add Lottie animations to Tizen .NET applications on your Galaxy Watch.

### Install the package
#### nuget.exe
```
nuget.exe install ElottieSharp -Version 0.9.0-preview
```
#### .csproj
```xml
<PackageReference Include="ElottieSharp" Version="0.9.0-preview" />
```

### Quick Start
ElottieSharp supports Tizen 4.0 (tizen40) and above.
The simplest way to use it is with LottieAnimationView:
```cs
// Create the LottieAnimationView
var animation = new new LottieAnimationView(window)
{
    AlignmentX = -1,
    AlignmentY = -1,
    WeightX = 1,
    WeightY = 1,
    AutoPlay = true,
};
animation.Show();

// Loading the animation file from a file path
animation.SetAnimation(Path.Combine(DirectoryInfo.Resource, "lottie.json"));

// Play the animation
animation.Play();
```

### LottieAnimationView
`LottieAnimationView` is an `EvasObject (TizenFX)` subclass that displays animation content.

#### Create animation views
```cs
var animation = new LottieAnimationView(window)
{
    AutoPlay = true,
    AutoRepeat = false,
    Speed = 1.0,
    MinumumProgress = 0,
    MaximumProgress = 1.0
};
```
Animation views can be allocated with or without animation data. There are a handful of convenience initializers for initializing with animations.

**Properties**
- **AutoPlay**: Indicates whether this animation plays automatially or not.  The default value is `false`.
- **AutoRepeat**: The loop behavior of the animation. The default value is `false`.
- **Speed**: The speed of the animation playback. Higher speed equals faster time. The default value is `1.0`.
- **MinumumProgress**: The start progress of the animation (0 ~ 1.0). The default value is `0`.
- **MaximumProgress**: The end progress of the animation (0 ~ 1.0). The default value is `1.0`.

#### Load from a file path
```cs
animation.SetAnimation(Path.Combine(DirectoryInfo.Resource, "lottie.json"));
```
Loads an animation model from a file path. After loading an animation successfully, you can get the duration time and total frame count by using `TotalFrame` and `DurationTime` properties.

**Parameters**

: **filepath**: The absolute filepath of the animation to load.


#### Play the animation
```cs
animation.Play();
```
Plays the animation from its current state to the end of its timeline. A `Started` event occurs when the animation is started, and a `Finished` event occurs when the animation is finished.

#### Stop the animation
```cs
animation.Stop();
```
Stops the animation. A `Stopped` event occurs when the animation is stopped.

#### Pause the animation
```cs
animation.Pause();
```
Pauses the animation. A `Paused` event occurs when the animation is paused.

#### Is animation playing
```cs
bool isPlaying = anumation.IsPlaying;
```
Returns `true` if the animation is currently playing, `false` if it is not.

#### Current frame
```cs
int currentFrame = anumation.CurrentFrame;
```
Returns the current animation frame count.

**Note**: It returns -1 if animation is not playing.

#### Total frame
```cs
int totalFrame = anumation.TotalFrame;
```
Returns the total animation frame count.

**Note**: Load the animation file before you use it.

#### Duration time
```cs
double duration = anumation.DurationTime;
```
Returns the duration time of animation.<br/>
**Note**: Load the animation file before you use it.

Feel free to reach out to us directly at GitHub with your thoughts, feedback, and issues.
