---
title: "Samsung Certificate Profile for Samsung Wearables"
last_modified_at: 2019-02-27
categories:
  - Wearables
author: Juwon (Julia) Ahn
toc: true
toc_sticky: true
---

You may face the following error when you develop Tizen .NET applications:

```sh
   processing result : Check certificate error [-12] failed
```

This error occurs when you install the default certificate signed .NET app on Samsung wearables or install the Samsung certificate-signed app on a Tizen emulator.

<a id="top"></a>
You can get its solution [here](#certificate_error_-12) {: .btn .btn--success}.

## Samsung certificate profile

### Install Samsung Certificate Extension

 To create a Samsung certificate profile, you must have [Samsung Certificate Extension][samsung_cert_extension] installed. You can install it through Tizen Studio Package Manager.

 ![][install_samsung_cert_extension]

### Create a Samsung certificate profile

1. Launch Tizen Certificate Manager, and click the **+** button to create a new certificate profile.
 ![][tizen-certificate-manager_first_page]
1. Select **Samsung** to create a certificate profile to develop and test your application for Samsung Wearables.
 ![][select_samsung_cert]
1. In Step 1, select **Mobile/Wearable** as the device type and click **Next**.
 ![][mobile_wearable_type]
1. Select **Create a new certificate profile** and enter the file name.
 ![][create_new_cert]
1. Select **Create a new author certificate** and click **Next**. Enter author name and password.
 ![][create_new_author_cert]

 ![][author_name_pw]
1. Sign into Samsung Account. After a few seconds, you get a link to the author certificate.

 ![][samsung_account_popup]

 ![][author_cert_done]

  **Important**: Keep the author certificate in a safe location for future updates of your applications. If you lose your author certificate, you will not be able to modify your apps registered in Samsung Seller Office.

Next, create the distributor certificate.

 ![][create_new_distributor_cert]

If your device or wearable emulator is connected, the DUID value is automatically added.

 ![][duid_of_device]

You can now get your distributor certificate.

 ![][distributor_cert_done]

<a id="certificate_error_-12"></a>
### Handle Error `'certificate error [-12]'`

[Top](#top){: .btn .btn--success}

To install your Tizen .NET application on Samsung wearables such as Galaxy Watch, you need to create a Samsung certificate profile and sign your application with it.

You must ensure that the .NET application is signed with your Samsung certificate profile, not the Tizen default certificate. To use your Samsung certificate profile:

1. Navigate to **Visual Studio > Tools > Option > Tizen > Certification**.
1. Select the **Sign the .TPK file using the following option** checkbox.
1. Select your Samsung certificate profile from the **Profile** dropdown.

 ![][app_samsung_cert]

## Tizen certificate profile

To use the Tizen default certificate profile, uncheck the  **Sign the .TPK file using the following option** checkbox:

 ![][apply_default_cert]




[samsung_cert_extension]: https://developer.samsung.com/galaxy-watch/develop/getting-certificates/install
[install_samsung_cert_extension]: {{site.url}}{{site.baseurl}}/assets/images/posts/samsung-certificates-for-wearables/install_samsung_cert_extension_through_package_manager.png
[tizen-certificate-manager_first_page]: {{site.url}}{{site.baseurl}}/assets/images/posts/samsung-certificates-for-wearables/tizen_certificate_manager.png
[select_samsung_cert]: {{site.url}}{{site.baseurl}}/assets/images/posts/samsung-certificates-for-wearables/samsung_cert.png
[mobile_wearable_type]: {{site.url}}{{site.baseurl}}/assets/images/posts/samsung-certificates-for-wearables/wearable_device_type.png
[create_new_cert]: {{site.url}}{{site.baseurl}}/assets/images/posts/samsung-certificates-for-wearables/create_new_cert.png
[create_new_author_cert]: {{site.url}}{{site.baseurl}}/assets/images/posts/samsung-certificates-for-wearables/create_new_author_cert.png
[author_name_pw]: {{site.url}}{{site.baseurl}}/assets/images/posts/samsung-certificates-for-wearables/author_name_pw.png
[apply_default_cert]: {{site.url}}{{site.baseurl}}/assets/images/posts/samsung-certificates-for-wearables/default_cert_is_to_be_applied.png
[app_samsung_cert]: {{site.url}}{{site.baseurl}}/assets/images/posts/samsung-certificates-for-wearables/samsung_cert_is_to_be_applied.png
[samsung_account_popup]: {{site.url}}{{site.baseurl}}/assets/images/posts/samsung-certificates-for-wearables/samsung_account_popup.png
[author_cert_done]: {{site.url}}{{site.baseurl}}/assets/images/posts/samsung-certificates-for-wearables/author_cert_done.png
[create_new_distributor_cert]: {{site.url}}{{site.baseurl}}/assets/images/posts/samsung-certificates-for-wearables/create_new_distributor_cert.png
[duid_of_device]: {{site.url}}{{site.baseurl}}/assets/images/posts/samsung-certificates-for-wearables/duid_of_devic.png
[distributor_cert_done]: {{site.url}}{{site.baseurl}}/assets/images/posts/samsung-certificates-for-wearables/distributor_cert_done.png
