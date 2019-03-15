---
title: "Samsung Seller Office"
permalink: /guides/publish-tvapp
toc: true
toc_sticky: true
---

## Official Pages
Visit [here](https://developer.samsung.com/tv/distribute/seller-office) to know more about the `TV Seller Office` and check out [.NET Application Registration](https://developer.samsung.com/tv/distribute/seller-office/applications/net-application-registration) for the official information about registering .NET application.

## Overview
Publishing your application will be the most rewarding moment of developing an application.
This guide will help you to safely register your .NET application on the [Samsung Apps TV Seller Office](http://seller.samsungapps.com/tv/).

[Samsung Apps TV Seller Office](http://seller.samsungapps.com/tv/) is the official system for TV applications certification and management. Sign in with your Samsung account or sign up now to start.

> When you first sign up, you are a Public Seller automatically. The public seller can distribute applications only in the United States. <br/> If you are more interested in registering applications outside of the US, visit [here](https://developer.samsung.com/tv/distribute/seller-office/membership/partnership-request/) to see how to request the partnership.

## Register Application
On the main page of the seller office, you can easily find `.NET App Registration`.

![image](https://user-images.githubusercontent.com/14328614/44450927-305de880-a62d-11e8-83e5-81fbd29874b6.png)

- Start with clicking `App Registration`.
- Enter the application name to be used for management.
- Go through the following 4 steps of registration. <br/>
  It is basically filling up the forms, but here are tips for some items that may be tricky to fill out. <br/>

  ### 1) Basic Information
  ![image](https://user-images.githubusercontent.com/14328614/44501291-a6af2900-a6c7-11e8-9e28-f833cb14182a.png)

  Define the basic information about application, country, and seller.
  - `Country` would be `United States of America` as default, if you are a public seller.
  - `App Title` under `Language` should be the same as the `label` in `tizen-manifest.xml`. Otherwise the next Pre-Test step will fail.<br/>
    ![image](https://user-images.githubusercontent.com/14328614/44458053-f3e7b800-a63f-11e8-85a7-ec124183d374.png)
  - Icon images and screenshots are required.

  ### 2) Application Upload
  ![image](https://user-images.githubusercontent.com/14328614/44501323-c5152480-a6c7-11e8-9529-8ac7472b8fbf.png)

  Upload the application package and complete the Pre-Test. <br/>
  ![image](https://user-images.githubusercontent.com/14328614/44505465-76be5080-a6dc-11e8-907b-bb2e773827eb.png)


  If you face the "Fail Error" at `2.Pre-Test` step, scroll down and see the error message in `Pre Test Result Details`.<br/>
  About the screen size error which shows the message below:
  ![image]({{site.url}}{{site.baseurl}}/assets/images/guides/screensize_error.png)

  Go to `tizen-manifest.xml` and add the screen size feature like the image below.
  ![image](https://user-images.githubusercontent.com/14328614/44458394-0adada00-a641-11e8-83b4-fbb415dfa4b1.png)

  ### 3) Test Information
  ![image](https://user-images.githubusercontent.com/14328614/44501506-6ac89380-a6c8-11e8-8231-e6aca95a5f93.png)

  This step is where you input information necessary for certification and verification. <br/>
  Providing an `App Description File` may be the toughest job in the whole process. The template file is provided so that you can download and fill out the information. The template file includes the UI structure, usage scenario, and etc. <br/>
  

  ### 4) Preview & Submit
  ![image](https://user-images.githubusercontent.com/14328614/44501554-af542f00-a6c8-11e8-85c5-160d4bd03aa4.png)

  Preview the application registration information.<br/>
  When you are ready to submit the application, click “Submit”.

  <br/>Visit [here](https://developer.samsung.com/tv/distribute/seller-office/applications/application-registration) to see the detailed guide for application registration process.
