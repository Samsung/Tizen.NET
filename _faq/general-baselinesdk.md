---
title:  "Tizen Baseline SDK"
permalink: /faq/baseline-sdk/
toc: true
toc_sticky: true
redirect_to: https://developer.samsung.com/tizen/Galaxy-Watch/FAQ/FAQ.html
---

## JDK version error
You must have Java Development Kit (JDK) version 8 to use Tizen Baseline SDK.

**Note:** [Tizen Studio 3.1](https://developer.tizen.org/development/tizen-studio/download/release-notes) supports OpenJDK 10.

## Cannot run the Tizen emulator
To run the Tizen emulator in Windows 10 or higher, you must disable the Hyper-V feature.

## The distributor certificate for Galaxy Watch cannot be updated
You cannot add another Galaxy Watch device unique identifier (DUID) to the existing distributor certificate file.

## App installation error
### Invalid certificate
There are two types of certificate profiles: one for Tizen platform devices and one for Samsung devices.
When you build the application using the incorrect certificate for your target device, the following error occurs:

![][invalid_cert]

The certificate file must match the running device:

| Device         | Certificate                 |
| -------------  |:---------------------------:|
| Tizen Emulator | Tizen Certificate Profile   |
| Samsung Device | Samsung Certificate Profile |

------------

### Version conflict between the application API and platform
This error occurs when the API version of the application is higher than the version of the platform to install. For example, when you try to install an application using 5.0 API version on the Tizen 4.0 platform device, the following error occurs:

![][version_conflict]

```sh
# Visual Studio Output Window

Operation not allowed [-4] failed
```

```sh
# log message

Package's API version (5) is higher than platform version (4.0.0)
Error during processing
Failure occurs in step: CheckTizenVersion
```

To resolve this error, change the API version in the `tizen-manifest.xml` from `5` to `4`, and reinstall the application.

## 'Permit to install applications' error
When you create a Samsung certificate for Samsung wearable devices, the device DUID is required.

For devices with DUIDs that start with `1.0#`, get permission for app installation through the Tizen Studio Device Manager:

**Tizen Studio Device Manager > Remote Device Manager > make connections with a device** > Right-click **Permit to install applications**.

![][permission_popup]

For more details, go [here][site_permission_for_app_install].

------

For devices with DUIDs that start with  `2.0#` (for example, Galaxy Watch), the following error message appears when you select **Permit to install applications**.

![][permission_to_install_app]

 If no issues occur when installing an application, you can ignore this error.

[site_permission_for_app_install]: https://developer.samsung.com/galaxy-watch/develop/getting-certificates/permit
[permission_popup]: {{site.url}}{{site.baseurl}}/assets/images/issues/tools/device_manager_popup_menu.png
[permission_to_install_app]: {{site.url}}{{site.baseurl}}/assets/images/issues/tools/certificate_manager_app_install_permission.png
[invalid_cert]: {{site.url}}{{site.baseurl}}/assets/images/issues/tools/invalid_cert.png
[version_conflict]: {{site.url}}{{site.baseurl}}/assets/images/issues/tools/version_conflict.png
