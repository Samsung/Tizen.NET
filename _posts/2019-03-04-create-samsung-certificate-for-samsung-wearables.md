---
title: "Samsung Certificate Profile for Samsung Wearables"
last_modified_at: 2019-02-27
categories:
  - Wearables
author: Juwon(Julia) Ahn
toc: true
toc_sticky: true
---

You often face the following error while developing Tizen .NET applications:

```sh
   processing result : Check certificate error [-12] failed
```

This error occurs when you install the default certificate signed .NET app on Samsung Wearables or install the Samsung certificate-signed app on a Tizen emulator.

<a id="top"></a>
You can get its solution [here](#certificate_error_-12){: .btn .btn--success}.

## Samsung Certificate Profile

### Install Samsung Certificate Extension

 To create Samsung certificate profile, [Samsung Certificate Extension][samsung_cert_extension] is required. You can install it through `Tizen Studio Package Manager`.

 ![][install_samsung_cert_extension]

### Create Samsung Certificate Profile
 
- Launch `Tizen Certificate Manager` and click **+** button to create a new certificate profile.

 ![][tizen-certificate-manager_first_page]

- Select **Samsung** to create a certificate profile to develop and test your application for Samsung Wearables and publish it to **Samsung Seller Office**.

 ![][select_samsung_cert]

- In Step 1, select **Mobile / Wearable** as the device type and click **Next>**.

 ![][mobile_wearable_type]

- Select **Create a new certificate profile** and put the file name to create a new one.

 ![][create_new_cert]

- Select **Create a new author certificate** and click **Next>**, and then, put Author name and password.

 ![][create_new_author_cert]

 ![][author_name_pw]

- At the Next step, to sign in Samsung Account, registration window pops up. After a few seconds from signing-in you can get the author certificate.

 ![][samsung_account_popup]
 
 ![][author_cert_done]

  > You should keep author certificate for future updates of your applications.
  >
  > If you lose your author certificate, you will not be able to modify your apps registered in Samsung Seller Office.

- The next step is creating the distributor certificate.

 ![][create_new_distributor_cert]

- If your device or wearable emulator is connected, DUID value is automatically added.

 ![][duid_of_device]

- Now, you can get the distributor certificate.

 ![][distributor_cert_done]

<a id="certificate_error_-12"></a>
### Handle Error `'certificate error [-12]'`
        
[Top](#top){: .btn .btn--success}

To install your Tizen .NET application on Samsung Wearables such as Galaxy Watch, Samsung Gear S3, etc, and publish it on Samsung Seller Office, you need to create Samsung certificate profile and sign your application with it.

You have to ensure that .NET application is signed with the desired Samsung certificate profile, not the Tizen default certificate.

First of all, make sure you make Samsung Certificate Profile.

If so, check whether your Samsung Certificate Profile is used or not by checking the following option

Visual Studio > Tools > Option > Tizen > Certification >
- Select the **Sign the .TPK file using the following option** `check box`.
- Select your Samsung certificate profile from **Profile** `drop-down menu`

 ![][app_samsung_cert]

## Tizen Certificate Profile

If you want to use Tizen default certificate profile, uncheck the  **Sign the .TPK file using the following option** `check box` as follows:

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