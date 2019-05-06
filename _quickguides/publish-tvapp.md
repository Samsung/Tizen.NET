---
title: "Samsung Seller Office"
permalink: /guides/publish-tvapp/
toc: true
toc_sticky: true
---

## Official Pages
- Visit [here](https://developer.samsung.com/tv/distribute/seller-office) to learn more about `TV Seller Office`.
- Check out [.NET Application Registration](https://developer.samsung.com/tv/distribute/seller-office/applications/net-application-registration) for official information about registering .NET applications.

## Overview
This guide will help you safely register your .NET application on the [Samsung Apps TV Seller Office](http://seller.samsungapps.com/tv/).

[Samsung Apps TV Seller Office](http://seller.samsungapps.com/tv/) is the official system for TV applications certification and management. Sign in with your Samsung account.

> When you first sign up, you are automatically designated a public seller. Public sellers can distribute applications only in the United States. <br/> If you are interested in registering applications outside of the US, visit [here](https://developer.samsung.com/tv/distribute/seller-office/membership/partnership-request/) to request a partnership.

## Register Application
On the Seller Office main page, navigate to `.NET App Registration`.

![image](https://user-images.githubusercontent.com/14328614/44450927-305de880-a62d-11e8-83e5-81fbd29874b6.png)

- Click `App Registration`.
- Enter the application name.
- Perform the following four registration steps o. <br/>

  ### 1) Basic Information
  ![image](https://user-images.githubusercontent.com/14328614/44501291-a6af2900-a6c7-11e8-9e28-f833cb14182a.png)

  Define basic information about application, country, and seller.
  - Default `Country` is `United States of America` if you are a public seller.
  - `App Title` under `Language` should be the same as the `label` in `tizen-manifest.xml`. Otherwise, the next Pre-Test step fails.<br/>
    ![image](https://user-images.githubusercontent.com/14328614/44458053-f3e7b800-a63f-11e8-85a7-ec124183d374.png)
  - Icon images and screenshots are required.

  ### 2) Application Upload
  ![image](https://user-images.githubusercontent.com/14328614/44501323-c5152480-a6c7-11e8-9529-8ac7472b8fbf.png)

  Upload the application package and complete the Pre-Test. <br/>
  ![image](https://user-images.githubusercontent.com/14328614/44505465-76be5080-a6dc-11e8-907b-bb2e773827eb.png)

  If "Fail Error" appears at `2.Pre-Test` step, scroll down to see the error message in `Pre Test Result Details`.<br/>
  The screen-size error message is shown below:
  ![image]({{site.url}}{{site.baseurl}}/assets/images/guides/screensize_error.png)

  Go to `tizen-manifest.xml` and add the screen-size feature as shown below:
  ![image](https://user-images.githubusercontent.com/14328614/44458394-0adada00-a641-11e8-83b4-fbb415dfa4b1.png)

  ### 3) Test Information
  ![image](https://user-images.githubusercontent.com/14328614/44501506-6ac89380-a6c8-11e8-8231-e6aca95a5f93.png)

  Input information necessary for certification and verification. <br/>
  Provide information for the `App Description File`. A template file is provided so you can download and complete the information. The template file includes UI structure, usage scenario, and other information. <br/>
  

  ### 4) Preview & Submit
  ![image](https://user-images.githubusercontent.com/14328614/44501554-af542f00-a6c8-11e8-85c5-160d4bd03aa4.png)

  Preview the application registration information.<br/>
  When you are ready to submit the application, click “Submit”.

  <br/>Visit [here](https://developer.samsung.com/tv/distribute/seller-office/applications/application-registration) to see the detailed guide for the application registration process.
