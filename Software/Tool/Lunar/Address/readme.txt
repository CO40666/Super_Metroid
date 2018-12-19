______________________________________________________________________

 Lunar Address - SNES Address Conversion up to 64 Mbit
 Version 1.04
 August 5, 2010

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


 Lunar Address is basically a SNES address converter with a layout
 based on the useful Hex to SNES program from J2E, but with some
 additional functionality that I felt would be convenient for my own
 work.

 First off, the text fields are standard edit controls that you can
 copy and paste into using the windows clipboard.  Also, the program
 ignores extra non-hexadecimal characters, so you can input formatted
 addresses straight from an assembly trace if you like.  Thus 8000,
 $00:8000, and 80M00N are all the same as far as the application is
 concerned.

 Conversion is done automatically as you type, and a text field below
 the edit control will describe the address and identify what part of
 the ROM it accesses.  Note that you can convert from RAM to ZSNES
 savestates at any time in one of the ROM modes without having to be
 in the RAM - ZSNES conversion mode, simply by typing in a SNES RAM
 address.

 The program also allows you to convert SNES addresses from outside
 the "standard" range for the ROM type selected.  For example, 00:8000
 is a perfectly valid pointer in a HiROM game, even though it doesn't
 access the same PC location that it would in a LoROM game.

 And Lunar Address includes support for ROM sizes above 32 Mbits up to
 64 Mbits using the ExHiROM and ExLoROM options.

 If you don't know what type of ROM you're working with, you can use
 the Auto-Detect feature to let the program try and figure it out
 for you.  This will detect both the ROM map type and the header.
 It should work for most ROMs, but if the ROM is interleaved or uses
 an extra chip it may not be of much use.

 The program actually has 4 different layouts that you can choose 
 from in the system menu (right-click on the window's title bar).
 "Expanded" is the default mode that the program starts in.  "Large"
 moves the ROM type selection and other options into menus, which
 considerably reduces the size of the window.  "Medium" is much like
 "Large", except without the menu.  And "Small" removes everything
 except for the 2 edit controls... when combined with the "Top Most
 Window" option, this can be extremely useful for keeping the address
 converter present but out of the way while you work.

 You can also use the F1-F4 keys to quickly switch between the
 different layouts available.

 All settings are saved to the registry, so when you run the program
 again it'll be in the same state you left it in.


 So if you do a fair amount of SNES address conversion you may find 
 this program to be slightly easier to work with.  But if not, I'd
 suggest giving J2E's program a try.  Either way, use whatever works
 for you.  ^^

______________________________________________________________________

 2. Updates
______________________________________________________________________


Version 1.04 August 5, 2010

-updated the program to stop always using the Win95 default font and
 make it high-DPI aware.  Should improve readability on LCDs with
 ClearType.


Version 1.03 August 2, 2006

-fixed a problem where closing the program while it was minimized 
 on WinNT based systems would cause the program window to be placed 
 in an inaccessible location beyond the user's desktop area the next
 time it was run.  Thanks goes out to Nightcrawler and RedComet for
 providing the information to figure this one out.


Version 1.02 July 4, 2003

-fixed a mistake in conversion of ExHiROM addresses.  The last halves
 of the last 2 banks are technically accessible from the 00:8000 map.


Version 1.01 December 25, 2002

-fixed a mistake in conversion of ExHiROM addresses.  The area from
 0000-7FFF in banks $70-$77 are used by SRAM.  The corresponding areas
 in the ROM are not accessible.


Version 1.00 November 13, 2002

-First Release.

______________________________________________________________________

 3. Legal Notice
______________________________________________________________________

 The Lunar Address program (hereafter referred to as the "Software") is
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
