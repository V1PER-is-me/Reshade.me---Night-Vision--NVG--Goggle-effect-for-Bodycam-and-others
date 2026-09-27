- Read this in the "README.md" file for original formatting -


<img width="1181" height="599" alt="Screenshot 2026-09-27 163240" src="https://github.com/user-attachments/assets/406e2558-71b3-4455-9708-d7f1e6e2c928" />



**To install Re-Shade:**
1. Go to "https://ReShade.me"
2. Scroll to the bottom and click on "Download ReShade 6.8.0" (or whatever version is most 'up-to-date' at the time you are reading this.)
3. Go to your Downloads folder and double click the installer "ReShade_Setup_6.8.0.exe"
4. When you double click the installer it will come up with a "Select your game" window:
   - Click on: "Bodycam (Bodycam-Win64-Shipping.exe)"
5. Then select "DirectX 10/11/12"
6. After that, it'll ask "Select effects to install"
   - At the top, click: "Uncheck all", then click it again ("Check all")
7. Then Press "Next" and wait for it to download all the different effects (may take up to 5-8 mins if you have very slow WiFi/Ethernet, usually it's done in about 30 secs though)
8. Then press "Finish" after it is all installed


**SEE BOTTOM FOR ANY TROUBLESHOOTING SOLUTIONS YOU MAY NEED**


**!!HUGE DISCLAIMER!!** 


ReShade Requires a greater than 80% or "TKL" keyboard due to the need of the "Home" button to open in game
If you DO NOT have a "Home" button then try configuring one in your keyboards' software like "Logitech G-hub" for Logitech keyboards, or similar.
If you can - You can set it to a key you do not often press, like "[Backslash\]", "[Right ctrl]", or something similar which is out of the way and rarely used


**-After installing Re-Shade-**

**To install the "BodycamNightVision.fx":**
1. Go to "Program Files (x86)"
  2. Then "Steam"
  3. Then "Apps"
  4. Then "Steamapps"
  5. Then "Common"
  6. Then "Bodycam"
  7. Then "Bodycam" [Yes again]
  8. Then "Binaries"
  9. Then "Win64"
  10. Then "reshade-shaders"
  11. Then "Shaders"
    
12. Now that you are there, just drag and drop the "BodycamNightVision.fx" into that folder ("Shaders")
The file does not need to be inside a separate folder within ("Shaders"), just chuck it in there at the bottom of the "Shaders" folder amongst the other loose files


**The Final folder path should look like this: C:\Program Files (x86)\Steam\apps\steamapps\common\Bodycam\Bodycam\Binaries\Win64\reshade-shaders\Shaders**


Recommended: You can just copy paste the full file directory above into the address bar to save you some time navigating, not necessary but it is faster.

**Configuring the NightVision:**
*I use the following settings for my nightvision filter to make everything stand out as much as possible:*

**"Activation:"**
- "Overall Strength": 1.00
- "Low Light Only": 0.00
- "Low Light Threshold": 0.100
- "Adaptation time": 0.50

**"Image:"**
- "Light Amplification": 5.0
- "Auto-Gain (Darker = Brighter)": 2.00
- "Phosphor Colour": R:51 G:255 B:89
- "Keep Original Colours": 0.00
- "Glow": 0.07
- "Glow Radius": 2.0
- "Grain": 0.020
- "Grain Size": 2.8

**"Goggle Mask:"**
- "Goggle Tube Vignette": 1.00
- "Mask Radius": 0.72
- "Mask Softness": 0.29

Screenshot of all the settings <3:
<img width="2559" height="1439" alt="Screenshot 2026-09-27 162705" src="https://github.com/user-attachments/assets/2a2b1d20-dcad-41e4-b56e-0da1928edeeb" />

*This is a setup for a very clear looking NVG filter, if you want it to look more realistic and include more visual artifacts "Fireflies" then increase "Grain": and "Grain Size": according to your tastes and preferences*

*You can also change the "Keep Original Colours" to keep original colour, but also make the dark areas brighter at the same time. (This could be considered unfair competitive advantage, use at your own risk if you make videos or are going to be using this in content creation)*

*Similarly, if you get sore eyes looking at green all the time, you can change the RGB values to display a Blue NVG, Red NVG, Yellow, or any other colour you want to suit colourblindness and personal preference.*


**Go subscribe to my YT if you followed the guide and leave a comment on the video <3 you'd be giving me free money** 

this contains all my socials:
https://guns.lol/ItzPunchy

**If you notice anything wrong with this guide or have Questions then ask me directly on discord!!**


**Troubleshooting:**


You may find that ReShade does not load the effects properly and come up with red coloured errors at the top of the effects list;
  - this is almost always due to a fresh installation, close and open the game again to fix
  - If it is still not fixed, go back to the installer and use it again using the exact same process listed above (steps 3-8) to install it again, fixing any errors that may have occured.
  - If that still wont work, uninstall ReShade, again from the installer and then do a full fresh Re-Install following steps 3-8 above

You may also find your DLSS is not working after this install:
- I'm not entirely sure if this is related to Re-Shade or other modifications i've done to this game, but to fix it, try and reinstall reshade again, or disable all effects and restart the game then re-equip them
- This is not a likely problem to occur, but it happened to me, whether related to Re-Shade or editing the engine.ini files, either way, ignore this 99% of the time I do not believe it will be a big issue.
