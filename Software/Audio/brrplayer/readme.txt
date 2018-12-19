 ____  _____  _____    _____  _                       
|  _ \|  __ \|  __ \  |  __ \| |                      
| |_) | |__) | |__) | | |__) | | __ _ _   _  ___ _ __ 
|  _ <|  _  /|  _  /  |  ___/| |/ _` | | | |/ _ \ '__|
| |_) | | \ \| | \ \  | |    | | (_| | |_| |  __/ |   
|____/|_|  \_\_|  \_\ |_|    |_|\__,_|\__, |\___|_|   
                                       __/ |          
    By Vitor Vilela        Ver. 1.0   |___/           

BRR Player lets you listen BRR samples and "play" with them. You can change the volume,
adsr, gain, pitch, making it work like a piano keyboard or simply use to tune them.
Plus it has functions for loading them with pre-configured configuration, making easier
to you listen, check and share with people. Check out BRR pattern loader for details.

As a bonus, it lets you calculate and find volume. Check tools section for more
information.

Features:
	- Looped and non-looped BRR support.
	- Real time S-DSP changer with automatic key on/off support.
	- Capable of storing parameters (patterns) on BRR files, allowing to you
	  load with preconfigured ADSR and pitch with Regex support.
	- Noise support.
	- Support for exporting BRR to WAV with loop point conversion (requires snesbrr)
	- Real time pitch <-> note converter.
	- Real time dsp volume <-> smw/amk volume converter.
	- Works like a virtual keyboard.
	- Friendly ADSR/GAIN support.

Key shortcuts: You have some shortcuts available to make changing notes easier:
	- Normal notes: keys z, x, c, v, b, n, m (which plays c, d, e, f, g, a and b)
	- Sharp notes: keys s, d, g, h, j (which plays c+, d+, f+, g+ and a+)
	- Key off/on: space bar.
	
Real time DSP changer:
	- You can change ADSR, GAIN, Left/Right Volume and Pitch at real time while playing the sample.
	- If the sample doesn't loop, go to Options and set "Auto Key Off/On", this will make the sample
	  restart when you move any of the sliders. This also applies if you want to change and see the
	  behavior of ADSR.
	- To select GAIN or ADSR mode, go to the combo box and change the option desired. First one is
	  "ADSR" (and obviously sets ADSR mode), while the next four are "direct", "increase (linear)",
	  "increase (bent line)", "decrease (linear)" and "decrease (exponential)". All of them are
	  GAIN and to the decrease mode, the envelope must be already be on a high value, as they are
	  supposed to continue after direct/increase mode.
	- If you change the pitch, the notes gets automatically changed to current or closest pitch.
	  Note that the pitch multiplier and submultiplier doesn't get changed, so this function can be
	  useful if you want to tune a sample.

BRR pattern loader:
	- I don't really have words to describle this function. Basically you have a 'pattern' file where
	you can specify the initial volume, adsr, gain, note and more. As for a bonus, it has regex support
	so you can multiples files have the same setting or even make the setting load from the file name.
	- It's per folder, so when you load a BRR file, BRR Player tries to find a "!patterns.txt" file in
	the parent folder.
	- If you want to know more, there is a sample !patterns.txt file with more detailed explanation and
	there is a few brr files as example that interacts with !patterns.txt.

Additional Options and Notes:
	- You can set staccato timer, which is basically the time to wait between a key off and on.
	  By default BRR Player sets to 16 ms.
	- If you're having issues with keyboard conflicting with other buttons or with the text boxes,
	  click on key off+on button or on menu.
	- Some playback options are available, such as bits per sample, sampling rate, one or two channels
	  plus the interpolation.
	- Clicking on the "+" button, a menu will appear where you can set noise clock, export the current
	  configuration to AMK format and export current configuration to a pattern file format. Note that
	  tuning doesn't get exported when saving the pattern so if you really want to use the exact pitch,
	  change the (raw) note to $00 and set multiplier/sub multiplier to the pitch you want to play.

Tools:
	- There are two tools available related to volume.
	- One of them lets you calculate the volume based on N-SPC commands. It will give you a S-DSP
	  volume.
	- The second one lets you find the volume based on S-DSP volume and it will give you some N-SPC
	  commands equilavent to the volume. Note that the global volume, wXXX command is fixed, since
	  obviously you won't want to change it mid-song, so simply input the global volume that you're
	  using in your MML.
	
Libraries Used:
 - Alpha-II for SNESAPU.DLL (http://www.alpha-ii.com/)
 - NAudio (http://naudio.codeplex.com/)
 
Credits:
 - Also I would like to thank:
	- CrispyYoshi (suggestions and base idea).
	- Harumi (suggestions and testing).

Contact:
 - If you find any bug, please PM me, VitorVilela (userid: 8251) on SMW Central.