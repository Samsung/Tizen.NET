---
title: "How to use SkiaSharp in Tizen .NET"
last_modified_at: 2019-03-20
categories:
  - Tizen .NET
author: Rina You
toc: true
toc_sticky: true
---

SkiaSharp is a cross-platform 2D graphics API for .NET platforms powered by the Skia Library of Google. 
It provides a comprehensive API that is used on mobile, TV, watch and desktop. 
So, you can easily make your own application with multifarious graphics such as texts, graphs and images using SkiaSharp. 
For more information about the SkiaSharp APIs, see the official [SkiaSharp API](https://docs.microsoft.com/en-us/dotnet/api/skiasharp?view=skiasharp-1.60.3) document. 

This post is made for introducing how to use SkiaSharp in Tizen .NET. 


## Create Tizen .NET application
At first, create Tizen .NET UI application. 
If you are not familiar with Tizen .NET application, several posts on [Quick Guides]({{site.url}}{{site.baseurl}}/guides) help you to understand how to create Tizen .NET application.
This post will share an example code using ElmSharp. The sample application references the TizenFX package which contains ElmSharp.

## Change the target framework
Change the target framework on project file of UI application(.csproj) for using `SkiaSharp` in Tizen .NET.

### AS-IS
~~~html
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>netcoreapp2.0</TargetFramework>
  </PropertyGroup>
~~~

---

### TO-BE
```html
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>tizen40</TargetFramework>
  </PropertyGroup>
``` 

**Note:** It's based on Tizen 4.0. If your application is based on Tizen 5.0, `TargetFramework` should be `tizen50` instead of `tizen40`.


## Install the nuget packages for SkiaSharp
In the `Solution Explorer`, right-click on the project name of your UI application and click `Manage Nuget Packages`. 

![][manage_nuget_package]


Select the `Browse` tab, Choose `nuget.org` as the Package source and search for **SkiaSharp** and **SkiaSharp.Views**.
And then, select these packages in the list, and click `Install` button.

![][install_nuget_package]


## Draw the Text
Create the `SKCanvasView` to draw the simple text such as `SkiSharp in Tizen`. 
The `SKCanvasView` is a View that can be drawn on using SkiaSharp drawing commands. 
Add `PaintSurface` Event Handler of `SKCanvasView`, and then implement some code inside `PaintSurface` Event Handler to draw the text using SKCanvas's `DrawText` method.
Reference the following example code. 

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
Build the application project, install and run this application.

![][app_text]

## Draw the star polygon

Add PaintSurface Event Handler of SKCanvasView to draw the star polygon, just like the above example does for drawing the simple text. 
Below is an example to draw star polygon.

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

Please also checkout the [SkiaSharp2DSample](https://github.com/Samsung/Tizen-CSharp-Samples/tree/master/Wearable/SkiaSharp2DSample) on the github.
{: .notice--info}

[manage_nuget_package]: {{site.url}}{{site.baseurl}}/assets/images/posts/how-to-use-skiasharp-in-tizen-net/manage_nuget_packages.png
[install_nuget_package]: {{site.url}}{{site.baseurl}}/assets/images/posts/how-to-use-skiasharp-in-tizen-net/install_nuget_packages.png
[app_text]: {{site.url}}{{site.baseurl}}/assets/images/posts/how-to-use-skiasharp-in-tizen-net/app_text.png
[app_polygon]: {{site.url}}{{site.baseurl}}/assets/images/posts/how-to-use-skiasharp-in-tizen-net/app_polygon.png