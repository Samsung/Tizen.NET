---
title:  "How to Package UI and Service Applications Together and Use Them"
search: true
toc: true
toc_sticky: true
categories:
  - Tizen .NET
last_modified_at: 2019-01-04
author: Juwon(Julia) Ahn
---


## Create a new Tizen project for Xamarin.Forms application
1. You can create a new project by navigating to `File` -> `New` -> `Project...`.
1. Select any `Tizen App` template except `Service App` under the Visual C# selector (Tizen).
1. Name of your project and specify its location, then click `OK`.

![][create_project]

## Add a new project for a Service Application
1. In `Solution Explorer`, right-click the solution node and click `Add` -> `New Project...`
1. Select the `Service App` template (Tizen) under the Visual C# selector.
1. Enter the name of your service application, and click `OK`.

![][add_project_for_service_app]

## Add a reference to a service application in Xamarin.Forms
1. In `Solution Explorer`, right-click on the project name of your UI application, and click `Add` -> `Reference`. 

![][right-click-on-ui-app]

2. In the Reference Manager dialog box, select the name of project you want to reference, and click `OK`.

![][service_reference_for_ui_app]

## Build the entire solution

You may see the following error message when you try to build the solution.

![][build_error_for_ui_and_service_apps]

To fix the error, edit the project file (.csproj) of your service application to change the target framework.

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
    <TargetFramework>tizen50</TargetFramework>
  </PropertyGroup>
```

**Note:** This solution is based on Tizen 5.0. If your application is based on Tizen 4.0, `TargetFramework` should be `tizen40` instead of `tizen50`.

After modification, navigate to `Build` -> `Rebuild Solution`.

## Launch the applications
The UI (that is, Xamarin.Forms) application explicitly invokes your service application, because it does not launch automatically.

Define the mandatory privilege for application launch in the `tizen-manifest.xml` file as follows:

![][app_launch_priv]

The UI application can then launch the service application (for example, application id: org.tizen.example.ServiceApp) by executing the following code:

```c#
AppControl appcontrol = new AppControl
            {
                ApplicationId = "org.tizen.example.ServiceApp",
                Operation = AppControlOperations.Default,
            };

            AppControl.SendLaunchRequest(appcontrol, (launchRequest, replyRequest, result) =>
            {
                switch (result)
                {
                    case AppControlReplyResult.Succeeded:
                        label.Text = "Service application is successfully launched.";
                        Console.WriteLine("Service application is successfully launched.");
                        break;
                    case AppControlReplyResult.Failed:
                        label.Text = "Service application is not launched.";
                        Console.WriteLine("Service application is not launched.");
                        break;
                    case AppControlReplyResult.AppStarted:
                        label.Text = "Service application is just started.";
                        Console.WriteLine("Service application is just started.");
                        break;
                    case AppControlReplyResult.Canceled:
                        label.Text = "Service application is canceled.";
                        Console.WriteLine("Service application is canceled.");
                        break;
                }
            });

```

Alternatively, a service application can respond to the launch request as follows:

```c#
        protected override void OnAppControlReceived(AppControlReceivedEventArgs e)
        {
            base.OnAppControlReceived(e);
            // Reply to a launch request
            ReceivedAppControl receivedAppControl = e.ReceivedAppControl;
            if (receivedAppControl.IsReplyRequest)
            {
                AppControl replyRequest = new AppControl();
                receivedAppControl.ReplyToLaunchRequest(replyRequest, AppControlReplyResult.Succeeded);
            }
        }
```


You can get the sample code from [XamarinFormsAndServiceApps][sample_code] and view the following message when you execute the code on a Tizen wearable emulator or a device.

![][screenshot]


[create_project]: {{site.url}}{{site.baseurl}}/assets/images/posts/how-to-package-ui-and-service-apps/new_project_for_ui_n_service_apps.png
[add_project_for_service_app]: {{site.url}}{{site.baseurl}}/assets/images/posts/how-to-package-ui-and-service-apps/new_project_for_service_app.png
[right-click-on-ui-app]: {{site.url}}{{site.baseurl}}/assets/images/posts/how-to-package-ui-and-service-apps/right-click-on-ui-app.png
[service_reference_for_ui_app]: {{site.url}}{{site.baseurl}}/assets/images/posts/how-to-package-ui-and-service-apps/service_reference_for_ui_app.png
[build_error_for_ui_and_service_apps]: {{site.url}}{{site.baseurl}}/assets/images/posts/how-to-package-ui-and-service-apps/build_error_for_ui_and_service_apps.png
[app_launch_priv]: {{site.url}}{{site.baseurl}}/assets/images/posts/how-to-package-ui-and-service-apps/privilege_of_ui_app.png
[screenshot]: {{site.url}}{{site.baseurl}}/assets/images/posts/how-to-package-ui-and-service-apps/screenshot-on-wearable.png
[sample_code]: https://github.com/Samsung/Tizen-CSharp-Samples/tree/master/Wearable/XamarinFormsAndServiceApps
