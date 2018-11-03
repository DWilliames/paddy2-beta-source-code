# Paddy 2 beta – Source code

This is the source code for my Sketch Plugin, ['Paddy 2 beta.'](https://github.com/DWilliames/paddy2-beta)


## ⚠️ Warning
This code is really gross, and in a state where I was experiementing — it is not clean, well-organised code. Explore at your own risk 😅. I'm a little embarrassed for others to see it; however, I feel it may be helpful and perhaps spark some inspiration for others.

---


## Overview

Paddy 2 is written in Objective C within a Cocoa Framework. A lot of the code is injected into Sketch Private APIs via Swizzling (use this method at your own risk).

It does not work properly on Sketch 53 and above.

All of Sketch's internal APIs were dumped into a folder called 'Sketch headers', by using [Class-dump.](http://stevenygard.com/projects/class-dump/)



## Running

Download this repository and open the 'PaddyFramework' Xcode project.

To run it, click 'play' in the top left-hand corner within Xcode. This will bundle up the 'Plugin' and 'Resource' files from the Xcode project into a Sketch plugin called, 'Paddy2.sketchplugin', and copy it to the Sketch plugins folder. It will then open Sketch in a debugging mode; allowing you to log direcly into Xcode's console.

The details of this 'build script' can be seen under `'PaddyFramework project' > 'Build phases' > 'Build script'`, within Xcode.



## Questions

If you have trouble running this project, or any questions about how Paddy 2 works under the hood — I can't guarantee I will respond, but if you create an 'issue' under this repo, I'll see what I can do.

I have tried to cut my ties with supporting Paddy now, so I can't promise I will respond, but I will try to help out where I can.



## Support

If you'd like to support me for all the effort I've put into Paddy, and for providing this source code; all I ask is for you to follow me on Twiiter [@davidwilliames](https://twitter.com/davidwilliames) 🙌

[![Twitter Follow](https://img.shields.io/twitter/follow/davidwilliames.svg?style=social&label=Follow)]()
