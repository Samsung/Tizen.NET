---
title:  "Grabbing Hardware Key Events"
search: true
categories:
  - Tizen.NET
last_modified_at: 2020-01-16
author: Jay Cho
toc: true
toc_sticky: true
---

It's not common to grab a hardware key event in your application, because you can simply use controls such as `Editor` or `Entry` when you need to get input from users. However, if you want to make a more advanced application that handles hardware key inputs in more detail or when you want to modify the Smart TV remote control key event, you want to grab hardware key events.

## How to get hardware key events
### Using EcoreEvent<EcoreEventType> class
There is a class defined in `ElmSharp` called [`EcoreEvent`](https://samsung.github.io/TizenFX/API4/api/ElmSharp.EcoreEvent-1.html). You can use this [`ElmSharp.EcoreEvent<EcoreEventType>`](https://samsung.github.io/TizenFX/API4/api/ElmSharp.EcoreEvent-1.html) class to create the following [ecore event types](https://samsung.github.io/TizenFX/API4/api/ElmSharp.EcoreEventType.html) to be notified.
  - KeyDown
  - KeyUp
  - MouseButtonDown
  - MouseButtonUp
  - MouseButtonCancel
  - MouseMove
  - MouseWheel
  - MouseIn
  - MouseOut

### Implement in an application
#### Mainpage.xaml
This example shows how to prepare the main page of an application to show which key event occurred. One label, `keyDownLabel`, shows which key down event has occurred, and the other label, `keyDownLabel`, shows which key up event has occurred.
```xml
<c:CirclePage xmlns="http://xamarin.com/schemas/2014/forms"
             xmlns:x="http://schemas.microsoft.com/winfx/2009/xaml"
             xmlns:c="clr-namespace:Tizen.Wearable.CircularUI.Forms;assembly=Tizen.Wearable.CircularUI.Forms"
             x:Class="HandleHWKey.MainPage">
  <c:CirclePage.Content>
    <StackLayout VerticalOptions="CenterAndExpand">
      <Label x:Name="keyDownLabel"
          Text="Which key is down?"
          HorizontalOptions="CenterAndExpand" />

      <Label x:Name="keyDownLabel"
          Text="Which key is up?"
          HorizontalOptions="CenterAndExpand" />
        </StackLayout>
  </c:CirclePage.Content>
</c:CirclePage>

```

#### Mainpage.xaml.cs
In the cs file, declare and create `EcoreEvent` with the proper [`EcoreKeyEventType`](https://samsung.github.io/TizenFX/API4/api/ElmSharp.EcoreEvent-1.html), as shown below.
Here I created [`EcoreEventType.KeyDown`](https://samsung.github.io/TizenFX/API4/api/ElmSharp.EcoreEventType.html#ElmSharp_EcoreEventType_KeyDown) and [`EcoreEventType.KeyUp`](https://samsung.github.io/TizenFX/API4/api/ElmSharp.EcoreEventType.html#ElmSharp_EcoreEventType_KeyUp) to grab the hardware key down and up events.
Then I added event handlers using the [`On`](https://samsung.github.io/TizenFX/API4/api/ElmSharp.EcoreEvent-1.html#ElmSharp_EcoreEvent_1_On) event handler. Both event handlers will update the hardware key name and the key code on each label.

[`EcoreKeyEventArgs`](https://samsung.github.io/TizenFX/API4/api/ElmSharp.EcoreKeyEventArgs.html) is an `EventArgs` to record the Ecore event's key name and key code.

```csharp
using Xamarin.Forms;
using Xamarin.Forms.Xaml;
using Tizen.Wearable.CircularUI.Forms;
using ElmSharp;   // declare using statement

namespace HandleHWKey
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class MainPage : CirclePage
    {
        EcoreEvent<EcoreKeyEventArgs> _ecoreKeyDown;
        EcoreEvent<EcoreKeyEventArgs> _ecoreKeyUp;

        public MainPage()
        {
            InitializeComponent();

            _ecoreKeyDown = new EcoreEvent<EcoreKeyEventArgs>(EcoreEventType.KeyDown, EcoreKeyEventArgs.Create);
            _ecoreKeyDown.On += _ecoreKeyDown_On;

            _ecoreKeyUp = new EcoreEvent<EcoreKeyEventArgs>(EcoreEventType.KeyUp, EcoreKeyEventArgs.Create);
            _ecoreKeyUp.On += _ecoreKeyUp_On;
        }

        private void _ecoreKeyDown_On(object sender, EcoreKeyEventArgs e)
        {
            keyDownLabel.Text =  $"{e.KeyName} ({e.KeyCode})";
        }

        private void _ecoreKeyUp_On(object sender, EcoreKeyEventArgs e)
        {
            keyUpLabel.Text = $"{e.KeyName} ({e.KeyCode})";
        }
    }
}
```

### Run the application on an emulator
You can see the pressed hardware key name and a key code on the upper label, and the released hardware key name and a key code on the lower label.

![]({{site.url}}{{site.baseurl}}/assets/images/posts/grabbing-hardware-key-events/emulator.gif)

### For TV developers
If you are developing for Samsung Smart TV and want to handle hardware key events, [Tizen.TV.UIControls](https://github.com/samsung/Tizen.TV.UIControls) is here for you. [Tizen.TV.UIControls](https://github.com/samsung/Tizen.TV.UIControls) not only provides many sets of UI controls, it has Xamarin.Forms extension features, all of which help you create TV applications easily.

The [`InputEvents`](https://samsung.github.io/Tizen.TV.UIControls/guides/InputEvents.html) feature in this library is the wrapper for this `ElmSharp EcoreEvents` so you can grab keys, such as remote control keys, in your application. Check out the [guides](https://samsung.github.io/Tizen.TV.UIControls/guides/InputEvents.html) and the [API reference](https://samsung.github.io/Tizen.TV.UIControls/api/index.html) for `InputEvents`.
