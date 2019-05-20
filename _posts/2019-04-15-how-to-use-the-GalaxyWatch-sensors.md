---
title: "How to Use Sensors on Galaxy Watch"
search: true
last_modified_at: 2019-04-15
categories: Wearables
author: Sungsu Kim
toc: true
toc_sticky: true
toc_label: Contents
---

Many developers have asked how to use sensor features on Galaxy Watch. This post introduces sensors that are supported for Galaxy Watch and how developers can use them.

## Environment

### Target devices
The following Samsung wearables can be used with the Tizen.NET NuGet package:

- [Galaxy Watch][link_watch]<br/>
- [Galaxy Watch Active][link_watch_active]
- [Gear S3][link_gear_s3] (4.0 or later)<br/>
- [Gear Sport][link_gear_sport] (4.0 or later)<br/>

According to the device specification, the Accelerometer, Barometer, Gyro, HR, and Light sensors are supported.

### Tizen .NET NuGet package

To use sensor features on Galaxy Watch and other wearable applications, refer to the [Tizen.NET][link_tizenfx] NuGet package. The `Tizen.Wearable.CircularUI` provides the Xamarin.Forms extension controls, which are used for wearables.

```cs
<PackageReference Include="Tizen.Wearable.CircularUI" Version="1.1.0" />
```

![NuGet][img_nuget]

### APIs

The Tizen.NET NuGet package contains the `Tizen.Sensor` namespace, which provides the sensor API.

In the following table, find the API class that matches the sensor you want to use:

|  Sensor name  |    Class name    |
|:-------------:|:----------------:|
| Accelerometer |   [Accelerometer][link_accelerometer]  |
|   Barometer   |  [PressureSensor][link_barometer]  |
|      Gyro     |     [Gyroscope][link_gyro]    |
|       HR      | [HeartRateMonitor][link_hr] |
|     Light     |    [LightSensor][link_light]   |

## Usage

1. Declare namespace
```cs
using Tizen.Sensor;
```
2. Create instance
```cs
new Accelerometer();
```
3. Use sensor
```cs
Accelerometer.IsSupported; //properties
Accelerometer.Count;
Accelerometer.Start(); //method
Accelerometer.Stop();
Accelerometer.DataUpdated += (s, e) => { }; //event
```

### Example

The following example shows how to use the accelerometer on the application.

```cs
using Tizen.Sensor;
using Tizen.Wearable.CircularUI.Forms;

public class AccelerometerPage : CirclePage
{
	public Accelerometer Accelerometer { get; private set; }

	public AccelerometerPage()
	{
		if (Accelerometer.IsSupported && Accelerometer.Count)
		{
			Accelerometer = new Accelerometer();
			Accelerometer.DataUpdated += (s, e) =>
			{
				// use event argument
			};
		}
	}

	protected override void OnAppearing()
	{
		base.OnAppearing();
		Accelerometer?.Start();
	}

	protected override void OnDisappearing()
	{
		base.OnDisappearing();
		Accelerometer?.Stop();
	}
}
```

### Checking permission for HR sensor

For HR sensors, the developer needs to declare privilege and check permission. Refer to [Privacy-related Permissions][link_ppm] and the following sample code.

- Declaring privilege: http://tizen.org/privilege/healthinfo

![manifest][img_manifest]

- Checking permission in your app code.

```cs
using Tizen.Security;
using Tizen.Sensor;
using Tizen.Wearable.CircularUI.Forms;

public partial class HRMPage : CirclePage
{
	private const string hrmPrivilege = "http://tizen.org/privilege/healthinfo";

	public HRMPage()
	{
		CheckResult result = PrivacyPrivilegeManager.CheckPermission(hrmPrivilege);
		switch (result)
		{
			case CheckResult.Allow:
				CreateHRM();
				break;

			case CheckResult.Deny:
				break;

			case CheckResult.Ask:
				PrivacyPrivilegeManager.RequestPermission(hrmPrivilege);
				break;
		}
	}
}
```

## Demo

![accelerometer][img_accelerometer]
![gyro][img_gyro]
![hr][img_hr]
![light][img_light]
![barometer][img_barometer]

We provide several sample applications for wearables [here][link_samples], including the [Sensor sample][link_sensors] used in this post.

[link_gear_s3]: https://www.samsung.com/global/galaxy/gear-s3/
[link_gear_sport]: https://www.samsung.com/global/galaxy/gear-sport/specs/
[link_watch]: https://www.samsung.com/global/galaxy/galaxy-watch/specs/
[link_watch_active]: https://www.samsung.com/global/galaxy/galaxy-watch-active/specs/
[link_tizenfx]: https://samsung.github.io/Tizen.NET/guides/about#tizenfx
[link_circlular]: https://samsung.github.io/Tizen.NET/resources/SamsungWearables#tizen-circular-ui-apis
[link_accelerometer]: https://developer.tizen.org/dev-guide/csapi/api/Tizen.Sensor.Accelerometer.html
[link_barometer]: https://developer.tizen.org/dev-guide/csapi/api/Tizen.Sensor.PressureSensor.html
[link_gyro]: https://developer.tizen.org/dev-guide/csapi/api/Tizen.Sensor.Gyroscope.html
[link_hr]: https://developer.tizen.org/dev-guide/csapi/api/Tizen.Sensor.HeartRateMonitor.html
[link_light]: https://developer.tizen.org/dev-guide/csapi/api/Tizen.Sensor.LightSensor.html
[link_gravity]: https://developer.tizen.org/dev-guide/csapi/api/Tizen.Sensor.GravitySensor.html
[link_humidity]: https://developer.tizen.org/dev-guide/csapi/api/Tizen.Sensor.HumiditySensor.html
[link_magnetometer]: https://developer.tizen.org/dev-guide/csapi/api/Tizen.Sensor.Magnetometer.html
[link_orientation]: https://developer.tizen.org/dev-guide/csapi/api/Tizen.Sensor.OrientationSensor.html
[link_proximity]: https://developer.tizen.org/dev-guide/csapi/api/Tizen.Sensor.ProximitySensor.html
[link_rotation]: https://developer.tizen.org/dev-guide/csapi/api/Tizen.Sensor.RotationVectorSensor.html
[link_temperature]: https://developer.tizen.org/dev-guide/csapi/api/Tizen.Sensor.TemperatureSensor.html
[link_ultraviolet]: https://developer.tizen.org/dev-guide/csapi/api/Tizen.Sensor.UltravioletSensor.html
[link_ppm]: https://developer.tizen.org/development/guides/.net-application/security/privacy-related-permissions
[link_samples]: https://github.com/Samsung/Tizen-CSharp-Samples/
[link_sensors]: https://github.com/Samsung/Tizen-CSharp-Samples/tree/master/Wearable/Sensors
[img_nuget]: {{site.url}}{{site.baseurl}}/assets/images/posts/how-to-use-the-GalaxyWatch-sensors/1nuget.png
[img_accelerometer]: {{site.url}}{{site.baseurl}}/assets/images/posts/how-to-use-the-GalaxyWatch-sensors/2accelerometer.gif
[img_gyro]: {{site.url}}{{site.baseurl}}/assets/images/posts/how-to-use-the-GalaxyWatch-sensors/3gyroscope.gif
[img_hr]: {{site.url}}{{site.baseurl}}/assets/images/posts/how-to-use-the-GalaxyWatch-sensors/4heartrate.gif
[img_light]: {{site.url}}{{site.baseurl}}/assets/images/posts/how-to-use-the-GalaxyWatch-sensors/5light.gif
[img_barometer]: {{site.url}}{{site.baseurl}}/assets/images/posts/how-to-use-the-GalaxyWatch-sensors/6barometer.gif
[img_manifest]: {{site.url}}{{site.baseurl}}/assets/images/posts/how-to-use-the-GalaxyWatch-sensors/7manifest.png
