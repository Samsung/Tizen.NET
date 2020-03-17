---
title: "How to set image borders for making it resizable"
last_modified_at: 2019-09-16
categories:
  - Tizen .NET
author: Sunghyun Min
toc: true
toc_sticky: true
toc_label: How to set image borders
redirect_to: https://developer.samsung.com/tizen/blog/en-us/2019/09/16/how-to-set-an-images-borders-to-make-it-resizable
---

Sometimes app developers want to set a resizable image as background to better fit the contents. However, if you resize the image as it is, you may not get the shape you want.<br/>

Tizen provides an API to set `border`, a region of the image to be resized by scale to keep the correct aspect ratio. The following figures provide a visual explanation.

![][img1]
![][img2]


## How to set image borders

To create image borders, use the `ElmSharp.Image.SetBorder()` method after image loading.<br/>

For information about using native controls in Xamarin.Forms, see [Xamarin.Forms Custom Renderers](https://docs.microsoft.com/en-us/xamarin/xamarin-forms/app-fundamentals/custom-renderer/)<br/>

### Create custom renderer

```c#
public class CustomImage : Image
{
    public static readonly BindableProperty BorderLeftProperty = BindableProperty.Create("BorderLeft", typeof(int), typeof(CustomImage), default(int));
    public static readonly BindableProperty BorderRightProperty = BindableProperty.Create("BorderRight", typeof(int), typeof(CustomImage), default(int));
    public static readonly BindableProperty BorderTopProperty = BindableProperty.Create("BorderTop", typeof(int), typeof(CustomImage), default(int));
    public static readonly BindableProperty BorderBottomProperty = BindableProperty.Create("BorderBottom", typeof(int), typeof(CustomImage), default(int));

    public CustomImage()
    {
    }

    public int BorderLeft
    {
        get { return (int)GetValue(BorderLeftProperty); }
        set { SetValue(BorderLeftProperty, value); }
    }

    public int BorderRight
    {
        get { return (int)GetValue(BorderRightProperty); }
        set { SetValue(BorderRightProperty, value); }
    }

    public int BorderTop
    {
        get { return (int)GetValue(BorderTopProperty); }
        set { SetValue(BorderTopProperty, value); }
    }

    public int BorderBottom
    {
        get { return (int)GetValue(BorderBottomProperty); }
        set { SetValue(BorderBottomProperty, value); }
    }
}
```

```c#
[assembly: ExportRenderer(typeof(CustomImage), typeof(CustomImageRenderer))]
class CustomImageRenderer : ImageRenderer
{
    protected override void OnElementChanged(ElementChangedEventArgs<Xamarin.Forms.Image> e)
    {
        base.OnElementChanged(e);
        UpdateBorder();
    }

    protected override void OnElementPropertyChanged(object sender, PropertyChangedEventArgs e)
    {
        if ((e.PropertyName == CustomImage.BorderBottomProperty.PropertyName)
            || (e.PropertyName == CustomImage.BorderLeftProperty.PropertyName)
            || (e.PropertyName == CustomImage.BorderRightProperty.PropertyName)
            || (e.PropertyName == CustomImage.BorderTopProperty.PropertyName))
        {
            UpdateBorder();
        }
        base.OnElementPropertyChanged(sender, e);
    }

    void UpdateBorder()
    {
        var img = Element as CustomImage;
        Control.SetBorder(img.BorderLeft, img.BorderRight, img.BorderTop, img.BorderBottom);
    }

    protected override void UpdateAfterLoading()
    {
        base.UpdateAfterLoading();
        UpdateBorder(); // SetBorder should be called after image loading
    }
}
```
<strong>Note</strong>: Because `ElmSharp.Image` allows you to use the override `UpdateAfterLoading()` method for post processing, you can call the `SetBorder()` method after image loading.

### Example

```c#
public class App : Application
{
    public App()
    {
        // The root page of your application
        MainPage = new ContentPage
        {
            BackgroundColor = Color.White,
            Content = new StackLayout
            {
                VerticalOptions = LayoutOptions.Center,
                Children = {
                    new CustomImage
                    {
                        Source = FileImageSource.FromFile("sample.png"),
                        HorizontalOptions = LayoutOptions.Center,
                        VerticalOptions = LayoutOptions.Center,
                        WidthRequest = 300,
                        HeightRequest = 100,
                        Aspect = Aspect.Fill,
                        BorderLeft = 50,
                        BorderRight = 50,
                        BorderTop = 50,
                        BorderBottom = 50
                    }
                }

            }
        };
    }
}
```

![][img3]<br/>
The sample application with original image (100x100).<br/><br/>
![][img5]<br/>
The sample application with resized image (300x100).<br/>
You can check the image is resized, keeping the borders.<br/>

[img1]: {{site.url}}{{site.baseurl}}/assets/images/posts/how-to-set-image-borders/image-borders.png
[img2]: {{site.url}}{{site.baseurl}}/assets/images/posts/how-to-set-image-borders/border-effect.png
[img3]: {{site.url}}{{site.baseurl}}/assets/images/posts/how-to-set-image-borders/sample-origin.png
[img4]: {{site.url}}{{site.baseurl}}/assets/images/posts/how-to-set-image-borders/sample-before.png
[img5]: {{site.url}}{{site.baseurl}}/assets/images/posts/how-to-set-image-borders/sample-after.png
