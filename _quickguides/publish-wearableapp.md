---
title: "Publish Your Wearable Application"
permalink: /guides/publish-wearableapp/
toc: true
toc_sticky: true
---

## Samsung Galaxy Apps Seller Office
[Samsung Galaxy Apps Seller Office](http://seller.samsungapps.com/) is the official site for Samsung watch app publication and promotion.

- Visit [here](https://developer.samsung.com/galaxy-watch/distribute/learn-about-seller-office) to learn more.
- Check [Galaxy Watch Distribute](https://developer.samsung.com/galaxy-watch/distribute) for further distribution information.

## Overview
This guide describes how to register your Tizen .NET application on Samsung Galaxy Apps Seller Office and provides step-by-step instructions to distribute your applications to Samsung watch users.

### 1. Develop your application
  Develop your application.

### 2. Build your application with your Samsung Certificate profile
  To distribute your application, you must build your application with your Samsung certificate. Create Samsung author or distributor certificates using **Tizen Studio Certificate Manager**, and build the Tizen .NET application you built with these certificates.

  - [developer.tizen.org - Getting the certificates](https://developer.tizen.org/development/training/.net-application/getting-certificates)
  - [developer.samsung.com - Getting the certificates](https://developer.samsung.com/galaxy-watch/develop/getting-certificates)

**Caution**: Do not lose your author certificate file (author.p12). If you do, it will not be possible to update the application you built with that certificate.
  {: .notice--danger}

### 3. Open Samsung Galaxy Apps Seller Office site and sign in with Samsung Account
  When your application is ready for distribution, go to the [Samsung Galaxy Apps Seller Office](http://seller.samsungapps.com/) site and sign in with your **Samsung Account**.

### 4. Register your application to Seller Office
1. To register your new application, click the <a class="btn btn--danger">Add New Application</a> button in the main page.
   ![][add_new_app]

1. Choose **Galaxy Watch** as your application type.
   ![][app_type]

   Add your application information and register application binary (.`tpk` file) for submission.

   After adding your application binary, you can see that all wearable devices are selected:

   ![][selected_devices]

   Tizen .NET applications work only on devices with Tizen 4.0 or above. We do not recommend using Tizen .NET with older devices, such as Gear S2.

   - Supported devices:
      - Galaxy Watch
      - Galaxy Watch Active
      - Gear S3 upgraded with Tizen 4.0 version
      - Gear Sport upgraded with Tizen 4.0 version
{: .notice--info}

Go [here](https://developer.samsung.com/galaxy-watch/distribute/how-to-distribute) to learn more about application distribution.

[add_new_app]: {{site.url}}{{site.baseurl}}/assets/images/guides/galaxy_apps_seller_office_register_button.png
[app_type]: {{site.url}}{{site.baseurl}}/assets/images/guides/galaxy_apps_seller_office_watch_app.png
[selected_devices]: {{site.url}}{{site.baseurl}}/assets/images/guides/galaxy_apps_seller_office_devices.png
