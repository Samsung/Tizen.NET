---
title: "Writing Tizen .NET Applications in F#"
last_modified_at: 2019-07-23
categories:
  - Tizen .NET
author: Swift Kim
toc: true
---

Although C# is the only language officially supported by Tizen .NET, you can write applications in other languages such as F# and VB.NET. Ideally, applications written in interoperable .NET languages are compiled into common _IL (intermediate language)_ code, which can be executed by any CLI-compliant runtime.

**Note**: Any examples in this article are for tech demo purposes only. Further tests and investigation on limitations are required to ensure operability in general cases.

## F# (VB.NET) Templates

Find the projects in the following repository and compare them with the original template projects shipped with [Visual Studio Tools for Tizen](https://developer.tizen.org/development/visual-studio-tools-tizen/installing-visual-studio-tools-tizen).

- [CrossTemplate.FSharp](https://github.com/swift-kim/FSharpSamples/tree/master/CrossTemplate.FSharp)
- [CrossTemplate.VB](https://github.com/swift-kim/FSharpSamples/tree/master/CrossTemplate.VB)
- [CrossXamlTemplate.FSharp](https://github.com/swift-kim/FSharpSamples/tree/master/CrossXamlTemplate.FSharp)
- [NUITemplate.FSharp](https://github.com/swift-kim/FSharpSamples/tree/master/NUITemplate.FSharp)

The first three applications target _Xamarin.Forms_ UI frameworks, and the fourth is built on the _Tizen.NUI_ framework. You can copy the `.fsproj` or `.vbproj` project files, the ` tizen-manifest.xml` , and other resources directly from the original projects.

I converted C# code into F# manually, line by line. F# comes with wide support for imperative programming features out of its functional features, so C# code can be readily switched into F#.

When it comes to XAML-based applications, however, it becomes a bit complicated, because the XAML code generator of Xamarin.Forms only supports generating code (`.g.cs`) in C#. I had to manually load XAML pages at runtime using [`LoadFromXaml()`](https://docs.microsoft.com/en-us/dotnet/api/xamarin.forms.xaml.extensions.loadfromxaml) instead of `InitializeComponent()`, as follows.

<small>**C# (MainPage.xaml.cs in TizenXamlApp)**</small>
```csharp
public partial class MainPage : ContentPage
{
    public MainPage()
    {
        InitializeComponent();
    }
}
```

<small>**F# (MainPage.xaml.fs in CrossXamlTemplate)**</small>
```fsharp
type MainPage() as this = inherit ContentPage()

    do this.LoadFromXaml(typeof<MainPage>) |> ignore
```

<small>**Screenshots**</small>

| CrossTemplate (F#) | CrossTemplate (VB) | CrossXamlTemplate (F#) | NUITemplate (F#) |
|-|-|-|-|
| ![CrossTemplate.FSharp]({{site.url}}{{site.baseurl}}/assets/images/posts/writing-tizen-net-applications-in-fsharp/crosstemplate_fsharp.jpg) | ![CrossTemplate.VB]({{site.url}}{{site.baseurl}}/assets/images/posts/writing-tizen-net-applications-in-fsharp/crosstemplate_vb.jpg) | ![CrossXamlTemplate.FSharp]({{site.url}}{{site.baseurl}}/assets/images/posts/writing-tizen-net-applications-in-fsharp/crossxamltemplate_fsharp.jpg) | ![NUITemplate.FSharp]({{site.url}}{{site.baseurl}}/assets/images/posts/writing-tizen-net-applications-in-fsharp/nuitemplate_fsharp.jpg) |

It becomes complicated when you have any reference in your program code to XAML elements. Such a case is investigated in the XStopWatch F# example.

## XStopWatch (F#)

XStopWatch is one of my favorite applications for testing .NET on Tizen. It's a good example for demonstrating the compatibility of Xamarin.Forms features with F#.

- [XStopWatch (C# version)](https://github.com/Samsung/Tizen-CSharp-Samples/tree/master/Wearable/XStopWatch)
- [XStopWatch (F# version)](https://github.com/swift-kim/FSharpSamples/tree/master/XStopWatch.FSharp)

**Note**: Only the comments in  F# code were removed from the original C# code. Otherwise, the two projects have the same logic and resources.

How XStopWatch is different from the previous helloworld examples:

- [Use of P/Invoke](https://github.com/swift-kim/FSharpSamples/blob/master/XStopWatch.FSharp/XStopWatch/WindowExtension.fs) to access native platform functions
- Access to XAML elements from application code
- Data binding with _BindableProperty_
- Events

For the P/Invoke usage in F# code, see the instructions [here](https://docs.microsoft.com/en-us/dotnet/fsharp/language-reference/functions/external-functions).

To reference XAML elements in the program logic, we must first inflate the layout of the XAML code. In C#, `InitializeComponent()` did it for us, so we didn't even need something like `findViewById()` in Android.

<small>**StopWatch.xaml.cs**</small>
```csharp
public StopWatch()
{
    _mainStopWatch = new NStopWatch();
    _subStopWatch = new NStopWatch();

    InitializeComponent();

    Stop();
}
```

In F#, we have to manually instantiate every single element.

<small>**StopWatch.xaml.fs**</small>
```fsharp
type StopWatch() as this = inherit CirclePage()

    let _mainStopWatch = NStopWatch()
    let _subStopWatch = NStopWatch()

    do
        this.LoadFromXaml(typeof<StopWatch>) |> ignore
        Self <- this.FindByName<CirclePage>("Self")
        Timebar <- this.FindByName<CircleProgressBarSurfaceItem>("Timebar")
        RootView <- this.FindByName<AbsoluteLayout>("RootView")
        RedBar <- this.FindByName<Image>("RedBar")
        BlueBar <- this.FindByName<Image>("BlueBar")
        StateLabel <- this.FindByName<Label>("StateLabel")
        ResetOrLapLabel <- this.FindByName<Label>("ResetOrLapLabel")
        CueBtn <- this.FindByName<Image>("CueBtn")

        this.Stop()
```

No problem so far. However, what if we have to use _data binding_ for dynamic interaction with XAML elements? Don't worry. We can use _BindableProperty_ to create any data binding, as we did in C#.

<small>**StopWatch.xaml.cs**</small>
```csharp
public partial class StopWatch : CirclePage
{
    public static BindableProperty StateProperty = BindableProperty.Create(nameof(State), typeof(State), typeof(StopWatch), State.Stopped);
    public static BindableProperty AllTimeProperty = BindableProperty.Create(nameof(AllTime), typeof(TimeSpan), typeof(StopWatch), TimeSpan.Zero);

    public State State { get => (State)GetValue(StateProperty); set => SetValue(StateProperty, value); }
    public TimeSpan AllTime { get => (TimeSpan)GetValue(AllTimeProperty); set => SetValue(AllTimeProperty, value); }

    ...
}
```

<small>**StopWatch.xaml.fs**</small>
```fsharp
type StopWatch() as this = inherit CirclePage()

    static let stateProperty = BindableProperty.Create("State", typeof<State>, typeof<StopWatch>, State.Stopped)
    static let allTimeProperty = BindableProperty.Create("AllTime", typeof<TimeSpan>, typeof<StopWatch>, TimeSpan.Zero)

    static member StateProperty = stateProperty
    static member AllTimeProperty = allTimeProperty

    member this.State
        with get() : State = this.GetValue(stateProperty) :?> State
        and set(value : State) = this.SetValue(stateProperty, value)

    member this.AllTime
        with get() : TimeSpan = this.GetValue(allTimeProperty) :?> TimeSpan
        and set(value : TimeSpan) = this.SetValue(allTimeProperty, value)

    ...
```

However, I didn't manage to make the following element parse properly  with the XAML compiler. The compiler was unable to locate a property (`Time`) in another page (`LapsPage`). (It could be a bug, or I was doing something wrong.)

<small>**StopWatchApplication.xaml**</small>
```xml
<CarouselPage x:Name="RootPage">
    ...
    <local:LapsPage x:Name="Laps" Time="{Binding AllTime, Source={x:Reference StopWatch}}"/>
</CarouselPage>
```

Instead, I had to manually create a binding in the program.

<small>**StopWatchApplication.xaml.fs**</small>
```fsharp
type StopWatchApplication() as this = inherit Application()

    do
        Laps.SetBinding(LapsPage.TimeProperty, "AllTime")
        Laps.BindingContext <- StopWatch
```

Finally, we can also use _Events_ in F#. To create a custom event handler and invoke it, follow the instructions in [this guide](https://docs.microsoft.com/ko-kr/dotnet/fsharp/language-reference/members/events) or refer to the following code.

<small>**C# (StopWatch.xaml.cs)**</small>
```csharp
// Define an EventHandler.
public event EventHandler StopPressed;

void Stop()
{
    // Invoke it.
    StopPressed?.Invoke(this, EventArgs.Empty);
}
```

<small>**F# (StopWatch.xaml.fs)**</small>
```fsharp
let stopPressed = Event<_>()

// Define a CLIEvent.
[<CLIEvent>]
member this.StopPressed = stopPressed.Publish

member this.Stop() =
    // Invoke it.
    stopPressed.Trigger(EventArgs.Empty)
```

Now, let's install the application on a device. It works just like the original C# application.

| XStopWatch (C#) | XStopWatch (F#) |
|-|-|
| ![XStopWatch (F#)]({{site.url}}{{site.baseurl}}/assets/images/posts/writing-tizen-net-applications-in-fsharp/xstopwatch_csharp.jpg) | ![XStopWatch.FSharp]({{site.url}}{{site.baseurl}}/assets/images/posts/writing-tizen-net-applications-in-fsharp/xstopwatch_fsharp.jpg) |

## Advantages and Disadvantages

I went over a simple benchmark of the above XStopWatch application on my _TW2_ (_Gear S3_) device. Every assembly was fully compiled into a native image. The result is as follows:

| Application | Mean startup time |
| - | -:|
| **XStopWatch (C#)** | **1120** ms |
| **XStopWatch (F#)** | **1896** ms |

The F# version of XStopWatch had a significant overhead when launching (_169%_ of the original application). Unfortunately, I have no real evidence about the root cause. There also was a large memory regression (up to _5 Mbytes_), although it's not mentioned in the above table. Therefore, I believe that F# in Tizen development has the following pros and cons:

<small>**Pros**</small>
- More development options (opportunity for F# developers)

<small>**Cons**</small>
- Performance
- Limited support and learning materials
- Potential unknown bugs

## Conclusion

Although it's possible to use F# in Tizen application development, I don't recommend that you do so unless you are expert in F# use and are not familiar with C#.

If you need help, please don't hesitate to contact me.

## Links

- [Using F# With Xamarin](https://docs.microsoft.com/ko-kr/xamarin/cross-platform/platform/fsharp/)
- [Xamarin.Forms using Visual Basic.NET](https://docs.microsoft.com/ko-kr/xamarin/cross-platform/platform/visual-basic/xamarin-forms)
- [Xamarin.Forms Visual Basic sample](https://github.com/xamarin/mobile-samples/tree/master/VisualBasic)