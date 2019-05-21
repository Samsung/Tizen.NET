---
title: "How to use SkiaSharp in Tizen .NET"
last_modified_at: 2019-03-20
categories:
  - Tizen .NET
author: Rina You
toc: true
toc_sticky: true
---

SkiaSharp is a cross-platform 2D graphics API for .NET platforms powered by the Google Skia Library. SkiaSharp provides a comprehensive API that is used on mobile, TV, watch, and desktop platforms. You can use SkiaSharp to create many different types of graphics, tables, and text in your own application.

For more information about SkiaSharp APIs, see the [SkiaSharp API](https://docs.microsoft.com/en-us/dotnet/api/skiasharp?view=skiasharp-1.60.3) guide.

This post introduces SkiaSharp use in Tizen .NET.


## Create a Tizen .NET application
Create a Tizen .NET UI application. If you are not familiar with the Tizen .NET application, see [Quick Guides]({{site.url}}{{site.baseurl}}/guides) for further information.

In this post, we share example code using ElmSharp. The sample application references the TizenFX package, which contains ElmSharp.

## Change the target framework
Change the `TargetFramework` of the UI application project file (.`csproj`) using SkiaSharp in Tizen .NET.

### As is
~~~html
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>netcoreapp2.0</TargetFramework>
  </PropertyGroup>
~~~

---

### New
```html
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>tizen40</TargetFramework>
  </PropertyGroup>
```

**Note:** This example is based on Tizen 4.0. If your application is based on Tizen 5.0, change `TargetFramework` to `tizen50` instead of `tizen40`.


## Install the NuGet packages for SkiaSharp
1. In **Solution Explorer**, right-click on the project name of your UI application and click **Manage NuGet Packages**.
![][manage_nuget_package]
1. Select the **Browse** tab
1. Choose **nuget.org** as the Package source, and search for **SkiaSharp** and **SkiaSharp.Views**.
1. Select these packages in the list, and click **Install**.
![][install_nuget_package]


## Draw the text
Create the `SKCanvasView` and use SkiaSharp drawing commands to draw simple text such as SkiSharp in Tizen.
1. Add `PaintSurface` Event Handler of `SKCanvasView`.
1. Implement the following example code inside `PaintSurface` event handler to draw text using SKCanvas's `DrawText` method:

```c#
using Tizen.Applications;
using ElmSharp;
using SkiaSharp;
using SkiaSharp.Views.Tizen;

namespace SkiaSharpTizen
{
    class App : CoreUIApplication
    {
        protected override void OnCreate()
        {
            base.OnCreate();

            Window window = new Window("ElmSharpApp")
            {
                AvailableRotations = DisplayRotation.Degree_0 | DisplayRotation.Degree_180
		| DisplayRotation.Degree_270 | DisplayRotation.Degree_90
            };
            window.BackButtonPressed += (s, e) =>
            {
                Exit();
            };
            window.Show();

            var skiaView = new SKCanvasView(window);
            skiaView.PaintSurface += OnPaintSurface;
            skiaView.Show();

            var conformant = new Conformant(window);
            conformant.Show();
            conformant.SetContent(skiaView);
        }

        private void OnPaintSurface(object sender, SKPaintSurfaceEventArgs e)
        {
            var skiaView = sender as SKCanvasView;

            var canvas = e.Surface.Canvas;

            var scale = (float)ScalingInfo.ScalingFactor;
            var scaledSize = new SKSize(e.Info.Width / scale, e.Info.Height / scale);

            canvas.Scale(scale);
            canvas.Clear(SKColors.Yellow);

            var paint = new SKPaint
            {
                Color = SKColors.Black,
                IsAntialias = true,
                Style = SKPaintStyle.Fill,
                TextAlign = SKTextAlign.Center,
                TextSize = 20
            };
            var coord = new SKPoint(scaledSize.Width / 2, (scaledSize.Height + paint.TextSize) / 2);
            canvas.DrawText("SkiaSharp in Tizen", coord, paint);
        }

        static void Main(string[] args)
        {
            Elementary.Initialize();
            Elementary.ThemeOverlay();
            App app = new App();
            app.Run(args);
        }
    }
}
```
3. Build the application project, install, and run this application.

![][app_text]

## Draw the star polygon

To draw a star polygon, add the `SKCanvasView` `PaintSurface` event handler. Then use the following example code to draw a star polygon.

```c#
private void OnDrawSample(SKCanvas canvas, int width, int height)
{
    var size = ((float)height > width ? width : height) * 0.75f;
    var R = 0.45f * size;
    var TAU = 6.2831853f;

    using (var path = new SKPath())
    {
        path.MoveTo(R, 0.0f);
        for (int i = 1; i < 7; ++i)
        {
            var theta = 3f * i * TAU / 7f;
            path.LineTo(R * (float)Math.Cos(theta), R * (float)Math.Sin(theta));
        }
        path.Close();

        using (var paint = new SKPaint())
        {
            paint.IsAntialias = true;
            canvas.Clear(SKColors.LightBlue);
            canvas.Translate(width / 2f, height / 2f);
            canvas.DrawPath(path, paint);
        }
    }
}

private void OnPaintSurface(object sender, SKPaintSurfaceEventArgs e)
{
    OnDrawSample(e.Surface.Canvas, e.Info.Width, e.Info.Height);
}
```

![][app_polygon]

For more information, see the [SkiaSharp2DSample](https://github.com/Samsung/Tizen-CSharp-Samples/tree/master/Wearable/SkiaSharp2DSample) on GitHub.
{: .notice--info}

[manage_nuget_package]: {{site.url}}{{site.baseurl}}/assets/images/posts/how-to-use-skiasharp-in-tizen-net/manage_nuget_packages.png
[install_nuget_package]: {{site.url}}{{site.baseurl}}/assets/images/posts/how-to-use-skiasharp-in-tizen-net/install_nuget_packages.png
[app_text]: {{site.url}}{{site.baseurl}}/assets/images/posts/how-to-use-skiasharp-in-tizen-net/app_text.png
[app_polygon]: {{site.url}}{{site.baseurl}}/assets/images/posts/how-to-use-skiasharp-in-tizen-net/app_polygon.png
