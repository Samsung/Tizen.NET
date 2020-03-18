---
title: "Samsung Apps TV Seller Office"
permalink: /guides/publish-tvapp/
toc: true
toc_sticky: true
redirect_to: https://developer.samsung.com/tizen/Smart-TV/Quickstarts/Publishing-an-application.html
---

## Official Pages
- Visit [here](https://developer.samsung.com/tv/distribute/seller-office) to learn more about TV Seller Office.
- See [.NET Application Registration](https://developer.samsung.com/tv/distribute/seller-office/applications/net-application-registration) for official information about registering .NET applications.

## Overview
This guide helps you register your .NET application on the [Samsung Apps TV Seller Office](http://seller.samsungapps.com/tv/).

[Samsung Apps TV Seller Office](http://seller.samsungapps.com/tv/) is the official system for TV application certification and management. Sign in with your Samsung account.

When you first sign up, you are automatically designated a public seller. Public sellers can distribute applications only in the United States. If you are interested in registering applications outside of the US, visit [here](https://developer.samsung.com/tv/distribute/seller-office/membership/partnership-request/) to request a partnership.

## Register the application
1. On the Seller Office main page, navigate to **.NET App Registration**.
![image]({{site.url}}{{site.baseurl}}/assets/images/guides/tv_app_registration.png)
1. Click **App Registration**.
1. Enter the application name.
1. Complete the following four registration steps:

### 1. Basic information
  ![image](https://user-images.githubusercontent.com/14328614/44501291-a6af2900-a6c7-11e8-9e28-f833cb14182a.png)

  Define basic information about the application, country, and seller.
  - For public sellers: The default `Country` is United States of America.
  - The App Title under Language should be the same as the `Label` in the `tizen-manifest.xml`. Otherwise, the **2. Pre-Test** step (shown below) fails.
    ![image](https://user-images.githubusercontent.com/14328614/44458053-f3e7b800-a63f-11e8-85a7-ec124183d374.png)

  - Icon images and screenshots are required.

### 2. Application upload
  ![image](https://user-images.githubusercontent.com/14328614/44501323-c5152480-a6c7-11e8-9529-8ac7472b8fbf.png)

  Upload the application package, and complete **2. Pre-Test**.
  ![image](https://user-images.githubusercontent.com/14328614/44505465-76be5080-a6dc-11e8-907b-bb2e773827eb.png)

  - If "Fail Error" appears at the **2. Pre-Test** step, scroll down to see the error message in the `Pre-Test Result Details`. The **screen-size** error message is shown like below:
  ![image]({{site.url}}{{site.baseurl}}/assets/images/guides/screensize_error.png)

  - Navigate to the `tizen-manifest.xml` and add the screen-size feature:
  ![image](https://user-images.githubusercontent.com/14328614/44458394-0adada00-a641-11e8-83b4-fbb415dfa4b1.png)

### 3. Test information
  ![image](https://user-images.githubusercontent.com/14328614/44501506-6ac89380-a6c8-11e8-8231-e6aca95a5f93.png)

  Next, input information necessary for certification and verification.
  - Provide information for the App Description file. A template file with UI structure, usage scenario, and other information is provided for you to download.

### 4. Preview and submit
  ![image](https://user-images.githubusercontent.com/14328614/44501554-af542f00-a6c8-11e8-85c5-160d4bd03aa4.png)

  Preview the application registration information, and click **Submit**.

Visit [here](https://developer.samsung.com/tv/distribute/seller-office/applications/application-registration) to see the detailed application registration process guide.
