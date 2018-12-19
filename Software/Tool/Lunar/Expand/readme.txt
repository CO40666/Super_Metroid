______________________________________________________________________

 Lunar Expand - SNES Expansion up to 64 Mbit
 Version 1.14
 May 22, 2010

 FuSoYa's Niche
 http://fusoya.eludevisibility.org (also http://fusoya.cjb.net)
______________________________________________________________________

 CONTENTS
______________________________________________________________________

 1. Instructions
 2. Updates
 3. Legal Notice
 4. Contact Information

______________________________________________________________________

 1. Instructions
______________________________________________________________________


 Expansion of SNES ROMs to sizes over 32 Mbit has traditionally been
 a bit of a headache for most ROM hackers, partly because you have to
 do it a bit differently, but mostly because emulator support for it
 has been relatively recent.  And since the mirrored areas of the
 memory map are used to hold the extra data, it's not even guaranteed
 that expansion beyond 32 Mbit sizes is going to work in all cases with
 all ROMs.

 So, I've put together a program that provides a couple of options to
 try and deal with expansion of this sort.

 On compatibility with emulators: if your emulator can play ToP, it
 supports the 48 Mbit ExHiROM option.  Both Zsnes and Snes9x have
 supported this one for a while now.  Snes9x 1.39a (or 1.39mk3) or
 higher is required for support of 48 & 64 MBit ExLoROM and 64 Mbit
 ExHiROM expansion (Zsnes doesn't currently support these).

 Keep in mind that if your ROM uses any extra chips (SFX, SFX2, DSP1,
 etc), then you're most likely out of luck with expansion as these
 chips tend to use their own memory maps.  The program also doesn't
 support interleaved ROMs.  It does support ROMs with or without a
 0x200 byte copier head.


 In the program, the left column gives you choices for expansion up
 to 32 Mbit.  These can be used on either HiROM or LoROM games.  The
 right column gives you choices for expansion to 48 or 64 Mbit. 
 If you have a LoROM game, make sure to choose an ExLoROM (Expanded
 LoROM, AKA JumboLoROM) option to expand your game.  And likewise, if
 you have a HiROM game, choose an ExHiROM option.  The program does
 attempt to verify which ROM type it is first, but it's better to
 be safe than sorry.

 The ExHiROM options are also capable of converting a 8 Mbit or
 smaller LoROM game to ExHiROM, though it's unlikely that anyone
 would want to do that.

 Now, all the choices in the right hand column do the basic steps for
 expansion beyond 32 Mbit (expand the ROM, change the byte size in
 the header, and copy a 0x8000 bank of data to a section at the 
 start of the expanded space).  But you'll notice that there are 
 up to 3 different options for each ROM size.

 For ExHiROM, the first option (no note) is just a typical expansion.
 The compatibility option (note 3) copies every second 32K bank into
 the expanded space so that the 00:8000 map accesses the same data it
 would in the game before expansion.  This can take up to half of the
 new space, but it's useful for evil HiROM games that have pointers
 using the 00:8000 map.  Not all the copied banks may be necessary,
 so if you _really_ need more space you can try clearing out some of
 them, but be careful...

 You can access the space above the 32 Mbit mark in the ExHiROM map 
 at 40:0000 - 7D:FFFF.  Note that banks 7E and 7F are RAM, thus the
 last 128K of your 64 Mbit ROM is not accessible from there, though
 you can access the upper 32K of the two banks at 3E:8000 - 3E:FFFF
 and 3F:8000 - 3F:FFFF.  Also, the area from 0000-7FFF of banks 
 $70 - $77 is usually used by SRAM, so the corresponding areas in
 the ROM are not accessible.

 For ExLoROM, the first option (note 1) is for LoROM games that use
 the 00:8000 - 6F:FFFF memory map.  Typically ROMs already <= 28 Mbit
 in size use this map.  In this case, the original ROM will be copied
 into the expanded space at 40:0000.  The second option (note 2) is
 for LoROM games that use the 80:8000 - FF:FFFF memory map.  Typically
 ROMs > 28 Mbit in size use this map.  If you have an evil LoROM game
 that uses both memory maps, you can try using the third compatibility
 option (note 3), but this simply creates a second copy of your ROM in
 the expanded space.  If the ROM was already 32 Mbit before, you won't
 gain much from this... you'd have to figure out manually which banks
 in the first or second half of the ROM can be cleared out.  >_<

 You can access the space above the 32 Mbit mark in the ExLoROM map 
 at 00:8000 - 7D:8000.  Note that banks 7E and 7F are RAM, thus the
 last 64K of your 64 Mbit ROM is not actually accessible in the game.


 Anyway, the program seems to function fairly well in most cases.
 Games like Chrono Trigger and Mario World have been converted
 successfully into 48 Mbit ExHiROM games.  RoboTrek is one that had to
 use the compatibility ExHiROM option.  Always try the other options
 before resorting to the compatibility options.


______________________________________________________________________

 2. Updates
______________________________________________________________________


Version 1.14 May 22, 2010

-made the program more discriminating on detecting the location of the
 internal header, correcting an issue where the program would update
 the header in both the LoROM and HiROM locations.  Thanks goes out
 to BMF for reporting this.
-updated the program to stop always using the Win95 default font and
 make it high-DPI aware.  Should improve readability on LCDs with
 ClearType.


Version 1.13 July 4, 2003

-minor update to the documentation involving the ExHiROM map.  The
 last halves of the last 2 banks are technically accessible from the
 00:8000 map.
-no changes to the program, other than the version number.


Version 1.12 December 25, 2002

-minor change involving ExLoROM expansion of ROMs using the 00:8000
 memory map.
-updated documentation on the ExHiROM map for banks $70-$77.


Version 1.11 November 13, 2002

-Changed the ExHiROM options so that the starting bank isn't recopied
 if the ROM was already > 32 Mbits.  Not exactly a big deal, but it
 was inconsistent with the ExLoROM expansion.


Version 1.10 November 11, 2002

-added 48 & 64 mbit LoROM expansion options, plus 64 mbit HiROM
 expansion options which are now supported by the new version of
 snes9x 1.39a (and 1.39mk3).  Zsnes doesn't yet support them though.
-added a couple more standard expansion sizes.


Version 1.02 August 28, 2002

-tabbing between controls has been fixed.


Version 1.01 August 26, 2002

-the program no longer requires a copy of the Lunar Compress dll.


Version 1.00 August 25, 2002

-First Release.


______________________________________________________________________

 3. Legal Notice
______________________________________________________________________

 The Lunar Expand program (hereafter referred to as the "Software") is
 not official or supported by Nintendo or any other commercial entity.

 The Software is freeware thus it can be distributed freely provided
 the following conditions hold:(1) This document is supplied with the
 Software and both the document and Software are not modified in any
 way (2) The Software is not distributed with or as part of any ROM
 image in any format, and (3) No goods, services, or money can be
 charged for the Software in any form, nor may it be included in
 conjunction with any other offer or monetary exchange.

 The Software is provided AS IS, and its use is at your own risk.
 Anyone mentioned in this document will not be held liable for any
 damages, direct or otherwise, arising from its use or presence.

______________________________________________________________________

 4. Contact Information
______________________________________________________________________


 FuSoYa
   www:   http://fusoya.eludevisibility.org (http://fusoya.cjb.net)
   ???:   06942508

______________________________________________________________________
