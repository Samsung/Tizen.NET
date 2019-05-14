---
title: "How to debug Tizen.NET Application"
last_modified_at: 2019-05-15
categories:
  - Tizen .NET
author: Reni Mathew
toc: true
toc_sticky: true
---

# Debugging

Debugging Tizen .NET application properly works from Tizen 5.0 platform.
{: .notice--info}

Debugging is a process of recognizing and resolving potential errors from your source code and allowing your source code to perform efficiently under stipulated conditions. To resolve potential errors in your source code, you must identify what went wrong, why it went wrong, and where it went wrong. To make this easy, debugger tools are available that navigates you through the code, helps you to view the execution process, and identifies the problems in your source code efficiently. 

Debugging a Tizen .NET application is same as debugging a C# application in Visual Studio. This document explains how to debug a Tizen .NET application. To debug, you must:

1. [Start Launch Tizen Emulator](#start-launch-tizen-emulator)
2. [Set breakpoint](#set-breakpoint)
3. [Start debugger](#start-debugger)
4. [Step around code](#step-around-code)
5. [Inspect code](#inspect-code)

## Start Launch Tizen Emulator
In order to debug, we need to launch emualtor or connect to target device.

* In the toolbar, click **Launch Tizen Emulator**.

    ![Image]({{site.url}}{{site.baseurl}}/assets/images/posts/how-to-debug-TizenNET-application/launch-emulator.png)

## Set breakpoint
Breakpoint is an essential feature of the debugging process. It acts as a stop sign. If you need to inspect workflow issues in your program, you can set breakpoints wherever required. While debugging, breakpoint indicates the debugger to stop the program automatically. This helps you to inspect your code in detail to verify the variables values, the memory allocation, and the execution sequence.

Click to the left of the line number of your code to set a breakpoint. A red dot appears at the left. 

![Image]({{site.url}}{{site.baseurl}}/assets/images/posts/how-to-debug-TizenNET-application/set-br.png)
 
## Start debugger
After you set the breakpoint, start the debugger. You can run the debugger to debug your code in the following ways:

* Press **F5**.

When you start the debugger, the application program enters a debugging mode and the execution is suspended with all the variables and values in the memory.

In the debugging mode, the debugger monitors the execution of your code in detail. You can pause the debugger and examine your code systematically to see what happens when each statement is executed. 

## Step around code
The breakpoint stops the program and you can hover the mouse over a variable in the current scope of execution to check the value of it. You can verify whether the variable stores the exact values that you expect it to store. 

To verify the variable values, you can use the following tool windows: 

* **Locals** tool window shows variables that are currently in scope. 
* **Autos** tool window shows the type and current value of the variable used.

![Image]({{site.url}}{{site.baseurl}}/assets/images/posts/how-to-debug-TizenNET-application/set-around.png)

These windows appear in the bottom left of Visual Studio while debugging. If it does not appear, you can also select **Debug > Windows** to open them.

![Image]({{site.url}}{{site.baseurl}}/assets/images/posts/how-to-debug-TizenNET-application/set-around1.png)

## Inspect code
When you are going through your code line by line, you will see a yellow arrow ![Image]({{site.url}}{{site.baseurl}}/assets/images/posts/how-to-debug-TizenNET-application/inspect-code1.png) that shows the statement on which the debugger is paused. The arrow indicates that this statement will be executed next. 

While debugging you can use the following to examine the code line by line:

* **Step Into** is used when you want to debug a method in the current line of code. To step into the code, press **F11**.
* **Step over** is used when you do not want to step through the code in detail. To step over the code, press **F10**.
                     
![Image]({{site.url}}{{site.baseurl}}/assets/images/posts/how-to-debug-TizenNET-application/inspect-code.png)

For more information, see [Debugging](https://tutorials.visualstudio.com/vs-get-started/debugging) with Visual Studio. You can use the same steps to debug a Tizen .NET application.
If you have any questions during debugging, feel free contact to us to [Issues](https://github.com/Samsung/Tizen.NET/issues).
