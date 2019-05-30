---
title:  "Tizen Baseline SDK"
permalink: /faq/baseline-sdk/
toc: true
toc_sticky: true
---

## JDK version error
Java Development Kit(JDK) `8` is mandatory for `Tizen Baseline SDK`. JDK 9 will be supported soon.

**Note:** `OpenJDK 10` is supported from [Tizen Studio 3.1](https://developer.tizen.org/development/tizen-studio/download/release-notes).

## Cannot Boot Up Tizen Emulator
`Hyper-V` feature should be disabled in Windows 10 or higher to run the `Tizen Emulator`.


## Distributor Certificate for GalaxyWatch Cannot be Updated
Unfortunately, there is no way to add an additional DUID of a GalaxyWatch device to the existing distributor certificate file.

## App Installation Error
### Invalid Certificate
There are two types of certificate profiles. One for the Tizen Platform devices and one for the Samsung Device.
When you use the certificate that is not suitable for your target device at application build time, the following error occurs:

![][invalid_cert]

The certificate file should match the running device as follows:

| Device         | Certificate                 |
| -------------  |:---------------------------:|
| Tizen Emulator | Tizen Certificate Profile   |
| Samsung Device | Samsung Certificate Profile |

------------

### Version Conflict between App's API and Platform
The following error will occur when the API version of the application is higher than the version of the platform to install.

Let's try to install an application using 5.0 API version on the Tizen 4.0 platform device.

You will see the following error.

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

To solve this error, you should modify the `Api Version` written in the `tizen-manifest.xml` from `5` to `4` and reinstall the application.

## 'Permit to install applications' Error
When you create a Samsung Certificate for Samsung wearable devices, the DUID of a device is required.

For devices with a DUID starting with `1.0#`, you have to get permission for app installation through the Tizen Studio Device Manager. (Tizen Studio Device Manager > Remote Device Manager > make connections with a device > execute `Permit to install applications` by right-click)

![][permission_popup]

You can get the detailed information about this from [here][site_permission_for_app_install].

------

If your device has the DUID starting with `2.0#` (e.g. Galaxy Watch), 
the following error message will be shown when you select `Permit to install applications`.

![][permission_to_install_app]
```
 ERROR
   No certificate profile for permit to install was found in workspace.
   
   Please open the Certificate Manager through the link below.
   After creating and activating a samsung certificate profile.
   close the Certificate Manager and click the Retry button.
```
You can ignore this error, if there is no issue when installing an application.

[site_permission_for_app_install]: https://developer.samsung.com/galaxy-watch/develop/getting-certificates/permit
[permission_popup]: {{site.url}}{{site.baseurl}}/assets/images/issues/tools/device_manager_popup_menu.png
[permission_to_install_app]: {{site.url}}{{site.baseurl}}/assets/images/issues/tools/certificate_manager_app_install_permission.png
[invalid_cert]: {{site.url}}{{site.baseurl}}/assets/images/issues/tools/invalid_cert.png
[version_conflict]: {{site.url}}{{site.baseurl}}/assets/images/issues/tools/version_conflict.png
