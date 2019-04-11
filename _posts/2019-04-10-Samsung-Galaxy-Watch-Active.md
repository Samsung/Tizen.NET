---
title: "Samsung Galaxy Watch Active & Wearable Emulator Without the Rotating Bezel"
last_modified_at: 2019-04-10
categories:
  - Wearables
author: Juwon(Julia) Ahn
search: true
classes: wide
---

The new `Samsung Galaxy Watch Active` is now available.<br><br>
<a href="https://www.samsung.com/global/galaxy/galaxy-watch-active/" target="_blank">![galaxy_watch_active]({{site.url}}{{site.baseurl}}/assets/images/posts/samsung-galaxy-watch-active/samsung_galaxy_watch_active.gif)</a>

Samsung's new `Galaxy Watch Active` is a sportier Galaxy Watch.<br>
Unlike the previous models, it's a sleeker and slimmer.<br>

One of the biggest changes from the developer's point of view is **the disappearance of the rotating bezel**.<br>

From a developer's point of view, a touch-based gesture(e.g. touching or swiping) can be used instead of bezel interaction to explore the screen.

The default Tizen wearable emulator has the rotating bezel. If you want a wearable emulator without the rotating bezel, you can get it through the procedure below.

- Open Tizen Emulator Manager
- Press the `+ Create` button and select one of wearable images.
- Go to the `3. Properties` step by pressing the `Next` button twice.
- In `3. Properties` step, change the skin as follows:<br>

    ![][how_to_create_bezel_less_emulator]

    ![][wearable_emulators]

[galaxy_watch_active]: {{site.url}}{{site.baseurl}}/assets/images/posts/samsung-galaxy-watch-active/samsung_galaxy_watch_active.gif
[how_to_create_bezel_less_emulator]: {{site.url}}{{site.baseurl}}/assets/images/posts/samsung-galaxy-watch-active/emulator_without_the_rotating_bezel.png
[wearable_emulators]: {{site.url}}{{site.baseurl}}/assets/images/posts/samsung-galaxy-watch-active/wearable_emulators.png

