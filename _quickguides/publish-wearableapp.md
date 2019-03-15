---
title: "Publish your application"
permalink: /guides/publish-wearableapp
toc: true
toc_sticky: true
---

## Samsung Galaxy Apps Seller Office
[Samsung Galaxy Apps Seller Office](http://seller.samsungapps.com/) is the official site 
for Samsung watch app publication and promotion.

Visit [here](https://developer.samsung.com/galaxy-watch/distribute/learn-about-seller-office) to know more about it 
and check out [Galaxy Watch App Distribution](https://developer.samsung.com/galaxy-watch/distribute) to get the official information.

## Overview
Publishing your application will be one of the most incredibly rewarding moments of developing applications.
This guide will help you to safely register your Tizen .NET application on the `Samsung Galaxy Apps Seller Office`.

Let's find out how you can distribute your applications to Samsung watch users step by step.

### 1. Develope your application
  The first thing to publish your application on the 'Samsung Galaxy Apps Seller Office' is to develop your application.
  
### 2. Build your application with your Samsung Certificate Profile
  To distribute your application, you need to build your application with your Samsung Certificate.
  You can create the Samsung author/distributor Certificates using 'Tizen Studio Certificate Manager' and build your Tizen .NET application with this certificate.
  
  - [developer.tizen.org - Get certificates](https://developer.tizen.org/development/training/.net-application/getting-certificates)
  - [developer.samsung.com - Get certificates](https://developer.samsung.com/galaxy-watch/develop/getting-certificates)
  
  You need to make sure you don't lose your **author certificate file (author.p12)**. Otherwise, it will not be possible to update your application built with that certificate later.
  {: .notice--danger}

### 3. Open Samsung Galaxy Apps Seller Office site and sign in with Samsung Account
  When your application is ready for distribution, you go to ['Samsung Galaxy Apps Seller Office'](http://seller.samsungapps.com/) site.
  
  To use `Samsung Galaxy Apps Seller Office`, **Samsung Account** is required.

### 4. Register your application to Seller Office
   To register your new application, click the <a class="btn btn--danger">Add New Application</a> button in the main page.
   ![][add_new_app]

   And then, choose 'Galaxy Watch' as your application type.
   ![][app_type]

   You can add your application information and register application binary (.tpk file) for submission.

   After adding your application binary, you can see all wearable devices are selected as follows.

   ![][selected_devices]

   Tizen .NET applications are working only on devices with Tizen 4.0 or above. 
   
   - Full list of supported devices
      - Galaxy Watch
      - Gear S3 upgraded with Tizen 4.0 version
      - Gear Sport upgraded with Tizen 4.0 version
{: .notice--info}
   
   In other words, other devices (e.g. Gear S2) should not be selected as recommended devices.

Visit [here](https://developer.samsung.com/galaxy-watch/distribute/how-to-distribute) to learn more about application distribution.


[add_new_app]: {{site.url}}{{site.baseurl}}/assets/images/guides/galaxy_apps_seller_office_register_button.png
[app_type]: {{site.url}}{{site.baseurl}}/assets/images/guides/galaxy_apps_seller_office_watch_app.png
[selected_devices]: {{site.url}}{{site.baseurl}}/assets/images/guides/galaxy_apps_seller_office_devices.png
