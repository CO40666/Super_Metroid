;------------------
.model tiny
.code
.286
locals
org 100h
jmp start
;------------------
; Centronics Side          MAD-1 Chip Side                MAD-1
; DATA CNTR.2..8  -------- IN0..6 (Pin15..9)            ___  ___
; /ERR CNTR.32    -------- OUT0 (Pin16)  /ROM.CS1 OUT1 |1  \/ 16| OUT0 /ROM.CS0
; SLCT CNTR.13    -------- OUT1 (Pin1)   /SRAM.CS OUT2 |2     15| IN0  ADDR0
; PE   CNTR.12    -------- OUT2 (Pin2)    /AUX.CS OUT3 |3     14| IN1  ADDR1
; /ACK CNTR.10    -------- OUT3 (Pin3)    /ROM.CS OUT4 |4     13| IN2  ADDR2
; BUSY CNTR.11    -------- OUT4 (Pin4)            Vout |5     12| IN3  ADDR3
; N/A  N/A             --- Vout (Pin5)             VCC |6     11| IN4  /CART
; VCC  +5VDC      -------- VCC  (Pin6)            Vbat |7     10| IN5  MODE
; GND  CNTR.19-30 -------- VBat (Pin7)             GND |8______9| IN6  /RESET
; GND  CNTR.19-30 -------- GND  (Pin8)
;------------------
;  1  OUT1 /ROM.CS1 ;(to upper ROM) (NC if single ROM)
;  2  OUT2 /SRAM.CS ;(to SRAM)
;  3  OUT3 /AUX.CS  ;(to expansion I/O or so) (usually NC)
;  4  OUT4 /ROM.CS  ;(to single ROM) (NC if two ROMs)
;  5  Vout          ;(supply to SRAM)
;  6  VCC           ;(supply from SNES)
;  7  Vbat          ;(supply from Battery via resistor)
;  8  GND           ;(supply Ground)
;  9  IN6 /RESET    ;(from cart.26)
;  10 IN5 MODE      ;HiROM: VCC                  | LoROM: GND
;  11 IN4 /ROMSEL   ;(from cart.49)
;  12 IN3 Addr3     ;HiROM: A22 (400000h) or A15 | LoROM: A22 (400000h) or VCC
;  13 IN2 Addr2     ;HiROM: A21 (200000h)        | LoROM: A21 (200000h)
;  14 IN1 Addr1     ;HiROM: A14 (4000h)          | LoROM: A20 (100000h)
;  15 IN0 Addr0     ;HiROM: A13 (2000h)          | LoROM: A15 (8000h)
;  16 OUT0 /ROM.CS0 ;(to lower ROM) (NC if single ROM)
;------------------
ioport   dw 0378h   ;ports 378h,278h,3bch = LPT1,2,3 (base+0=data, base+1=stat)
out_val  db 0
in_val   db 0
expected db 0
;------------------
txt_headline:
 IFDEF act_as_mad_r
   db 'MAD-R Tester',0dh,0ah
   db '------------',0dh,0ah
 ENDIF
 db '   IN0   IN1   IN2   IN3   IN4   IN5   IN6   -->  OUT0  OUT1  OUT2  OUT3  OUT4',0dh,0ah
 db '   Addr0 Addr1 Addr2 Addr3 /ROM  MODE  /RES  -->  /ROM0 /ROM1 /SRAM  /AUX /ROM',0dh,0ah
 db 0
txt_ok  db 'ok',0
txt_bad db 'bad',0
;------------------
wrchr:
 pusha
 mov  ah,6
 mov  dl,al
 int  21h
 popa
 ret
;------------------
wrcrlf:
 push ax
 mov  al,0dh
 call wrchr
 mov  al,0ah
 call wrchr
 pop  ax
 ret
;------------------
wrspc:
 push ax
 mov  al,' '
 call wrchr
 pop  ax
 ret
;------------------
wrhexal:
 ror  al,4
 call wrdigital
 ror  al,4
;- - - - ----------
wrdigital:
 push ax
 and  al,0fh
 cmp  al,0ah
 jb   short @@this
 add  al,07h
@@this:
 add  al,30h
 call wrchr
 pop  ax
 ret
;------------------
wrstr:
@@lop:
 lodsb
 cmp  al,00h
 je   short @@fin
 call wrchr
 jmp  short @@lop
@@fin:
 ret
;------------------
show_al:
 call wrhexal
 call wrspc  ;-space
 call wrspc  ;-space
@@xlop:
 pusha
 and  al,01h ;\
 add  al,30h ; digit
 call wrchr  ;/
 call wrspc  ;-space
 call wrspc  ;-space
 call wrspc  ;-space
 call wrspc  ;-space
 call wrspc  ;-space
 popa
 shr  al,1
 loop short @@xlop
 ret
;------------------
calc_expected:
 mov  byte ptr ds:[expected],1fh        ;-default all high
 test byte ptr ds:[out_val],40h         ;\/RESET=LOW
 jz   short @@this                      ;/
 test byte ptr ds:[out_val],20h         ;\MODE=LOW=LoROM
 jz   short @@mode_lorom                ;/
 jmp  short @@mode_hirom                ;-MODE=HIGH=HiROM
@@this:
 test byte ptr ds:[expected],10h        ;\
 jnz  short @@no_rom                    ;
 test byte ptr ds:[out_val],04h ;Addr2  ;  ;200000h
 mov  al,not 01h                        ; if /ROM output is low,
 jz   short @@this_rom                  ; reflect it to /ROM0 or /ROM1
 mov  al,not 02h                        ; depending on "Ahi" bit
@@this_rom:                             ;
 and  byte ptr ds:[expected],al         ;
@@no_rom:                               ;/
 IFDEF act_as_mad_r                     ;\
   test byte ptr ds:[out_val],40h       ;
   jz   short @@keep_res_high           ; on MAD-R, replace "/ROM" by "RESET"
   and  byte ptr ds:[expected],not 10h  ; (inverted /RESET signal)
  @@keep_res_high:                      ;
 ENDIF                                  ;/
 ret
;---
@@mode_lorom:
 test byte ptr ds:[out_val],10h ;/ROMSEL;\
 jnz  short @@lorom_rom_and_sram_off    ;/
 IFDEF act_as_mad_r                     ;\
  test byte ptr ds:[out_val],08h ;Addr3 ;  ;400000h ;\
  jnz  short @@lorom_rom_off            ;           ;/
 ELSE                                   ;
  test byte ptr ds:[out_val],01h ;Addr0 ;  ;8000h   ;\region 8000h-FFFFh
  jz   short @@lorom_rom_off            ;           ;/in ALL banks 0-7Dh,80h-FFh
 ENDIF                                  ;
 and  byte ptr ds:[expected],not 10h    ;
@@lorom_rom_off:                        ;/
 test byte ptr ds:[out_val],01h ;Addr0  ;\ ;8000h   ;\region 0000h-7FFFh
 jnz  short @@lorom_sram_off            ;           ;/
 test byte ptr ds:[out_val],04h ;Addr2  ;  ;200000h ;\
 jz  short @@lorom_sram_off             ;           ; bank 60h-7Dh or E0h-FFh
 test byte ptr ds:[out_val],08h ;Addr3  ;  ;400000h ;
 jz  short @@lorom_sram_off             ;           ;/
 test byte ptr ds:[out_val],02h ;\      ;           ;\
 mov  al,not 08h  ;/AUX         ;       ;           ;
 jz   short @@lorom_sram_this   ; Addr1 ;  ;100000h ; split 60h-6Fh or E0h-EFh
 mov  al,not 04h  ;/SRAM        ;       ;           ; and   70h-7Dh or F0h-FFh
 ;XXX if Vbat>=VCC --> @@lorom_sram_off ;           ;
@@lorom_sram_this:              ;       ;           ;
 and  byte ptr ds:[expected],al ;/      ;           ;/
@@lorom_sram_off:                       ;
 IFDEF act_as_mad_r                     ;           ;\
  or   byte ptr ds:[expected],8         ;           ;
  test byte ptr ds:[out_val],04h ;Addr2 ;  ;200000h ; on MAD-R,
  jnz  short @@lorom_madr_aux_off       ;           ; compute AUX differently
  test byte ptr ds:[out_val],08h ;Addr3 ;  ;400000h ;
  jz   short @@lorom_madr_aux_off       ;           ;
  and  byte ptr ds:[expected],not 8     ;           ;
 @@lorom_madr_aux_off:                  ;           ;
 ENDIF                                  ;/          ;/
@@lorom_rom_and_sram_off:
 jmp  short @@this
;---
@@mode_hirom:
 test byte ptr ds:[out_val],10h ;/ROMSEL;\
 jnz  short @@hirom_rom_off             ;
 and  byte ptr ds:[expected],not 10h    ;
@@hirom_rom_off:                        ;/
 test byte ptr ds:[out_val],10h ;/ROMSEL;\ ;/ROMSEL ;\
 jz   short @@hirom_sram_off            ;           ; bank 00h-3Fh and 80h-BFh
 test byte ptr ds:[out_val],08h ;Addr3  ;  ;400000h ; at 0000h-7FFFh
 jnz  short @@hirom_sram_off            ;           ;/
 test byte ptr ds:[out_val],01h ;Addr0  ;  ;2000h   ;\
 jz   short @@hirom_sram_off            ;           ; region 6000h-7FFFh
 test byte ptr ds:[out_val],02h ;Addr1  ;  ;4000h   ;
 jz   short @@hirom_sram_off            ;           ;/
 test byte ptr ds:[out_val],04h ;\      ;           ;\
 mov  al,not 08h  ;/AUX         ;       ;           ;
 jz   short @@hirom_sram_this   ; Addr2 ;  ;200000h ; split 00h-1Fh and 80h-9Fh
 mov  al,not 04h  ;/SRAM        ;       ;           ; and   20h-3Fh and A0h-BFh
 ;XXX if Vbat>=VCC --> @@hirom_sram_off ;           ;
@@hirom_sram_this:              ;       ;           ;
 and  byte ptr ds:[expected],al ;/      ;           ;/
@@hirom_sram_off:                       ;/
 jmp  @@this
;------------------
start:
 mov  si,offset txt_headline
 call wrstr
 mov  byte ptr ds:[out_val],00h
@@y_out_lop:
 mov  dx,word ptr ds:[ioport]           ;\
 mov  al,byte ptr ds:[out_val]          ; output
 out  dx,al                             ;/
 REPT 10                                ;\
   in   al,dx                           ; delay
 ENDM                                   ;/
 mov  dx,word ptr ds:[ioport]           ;\
 inc  dx                                ;
 in   al,dx                             ; input
 xor  al,80h  ;undo BUSY-inversion      ;
 shr  al,3    ;5bit to LSBs             ;
 mov  byte ptr ds:[in_val],al           ;/
 mov  al,byte ptr ds:[out_val]          ;\
 mov  cx,7                              ; show 7bit output
 call show_al                           ;/
;call wrspc                             ;\
;mov  al,'-'                            ; spacing
;call wrchr                             ;
 call wrspc                             ;/
 mov  al,byte ptr ds:[in_val]           ;\
 mov  cx,5                              ; show 5bit input
 call show_al                           ;/
 call calc_expected                     ;-calc expected
 mov  al,byte ptr ds:[expected]         ;\
 cmp  al,byte ptr ds:[in_val]           ;
 mov  si,offset txt_ok                  ;
 je   short @@ok                        ; show ok/bad
 mov  si,offset txt_bad                 ;
@@ok:                                   ;
 call wrstr                             ;/
 call wrcrlf
 inc  byte ptr ds:[out_val]             ;\lop next
 jns  short @@y_out_lop                 ;/
 ret
;------------------
end cs:100h
;------------------
;:----------------- MAD-1 (and MAD-1 A) Logged Outputs
;------------------
   IN0   IN1   IN2   IN3   IN4   IN5   IN6  --> OUT0  OUT1  OUT2  OUT3  OUT4
   Addr0 Addr1 Addr2 Addr3 /ROM  MODE  /RES --> /ROM0 /ROM1 /SRAM  /AUX /ROM
00  0     0     0     0     0     0     0    1F  1     1     1     1     1   ok
01  1     0     0     0     0     0     0    1F  1     1     1     1     1   ok
02  0     1     0     0     0     0     0    1F  1     1     1     1     1   ok
03  1     1     0     0     0     0     0    1F  1     1     1     1     1   ok
04  0     0     1     0     0     0     0    1F  1     1     1     1     1   ok
05  1     0     1     0     0     0     0    1F  1     1     1     1     1   ok
06  0     1     1     0     0     0     0    1F  1     1     1     1     1   ok
07  1     1     1     0     0     0     0    1F  1     1     1     1     1   ok
08  0     0     0     1     0     0     0    1F  1     1     1     1     1   ok
09  1     0     0     1     0     0     0    1F  1     1     1     1     1   ok
0A  0     1     0     1     0     0     0    1F  1     1     1     1     1   ok
0B  1     1     0     1     0     0     0    1F  1     1     1     1     1   ok
0C  0     0     1     1     0     0     0    1F  1     1     1     1     1   ok
0D  1     0     1     1     0     0     0    1F  1     1     1     1     1   ok
0E  0     1     1     1     0     0     0    1F  1     1     1     1     1   ok
0F  1     1     1     1     0     0     0    1F  1     1     1     1     1   ok
10  0     0     0     0     1     0     0    1F  1     1     1     1     1   ok
11  1     0     0     0     1     0     0    1F  1     1     1     1     1   ok
12  0     1     0     0     1     0     0    1F  1     1     1     1     1   ok
13  1     1     0     0     1     0     0    1F  1     1     1     1     1   ok
14  0     0     1     0     1     0     0    1F  1     1     1     1     1   ok
15  1     0     1     0     1     0     0    1F  1     1     1     1     1   ok
16  0     1     1     0     1     0     0    1F  1     1     1     1     1   ok
17  1     1     1     0     1     0     0    1F  1     1     1     1     1   ok
18  0     0     0     1     1     0     0    1F  1     1     1     1     1   ok
19  1     0     0     1     1     0     0    1F  1     1     1     1     1   ok
1A  0     1     0     1     1     0     0    1F  1     1     1     1     1   ok
1B  1     1     0     1     1     0     0    1F  1     1     1     1     1   ok
1C  0     0     1     1     1     0     0    1F  1     1     1     1     1   ok
1D  1     0     1     1     1     0     0    1F  1     1     1     1     1   ok
1E  0     1     1     1     1     0     0    1F  1     1     1     1     1   ok
1F  1     1     1     1     1     0     0    1F  1     1     1     1     1   ok
20  0     0     0     0     0     1     0    1F  1     1     1     1     1   ok
21  1     0     0     0     0     1     0    1F  1     1     1     1     1   ok
22  0     1     0     0     0     1     0    1F  1     1     1     1     1   ok
23  1     1     0     0     0     1     0    1F  1     1     1     1     1   ok
24  0     0     1     0     0     1     0    1F  1     1     1     1     1   ok
25  1     0     1     0     0     1     0    1F  1     1     1     1     1   ok
26  0     1     1     0     0     1     0    1F  1     1     1     1     1   ok
27  1     1     1     0     0     1     0    1F  1     1     1     1     1   ok
28  0     0     0     1     0     1     0    1F  1     1     1     1     1   ok
29  1     0     0     1     0     1     0    1F  1     1     1     1     1   ok
2A  0     1     0     1     0     1     0    1F  1     1     1     1     1   ok
2B  1     1     0     1     0     1     0    1F  1     1     1     1     1   ok
2C  0     0     1     1     0     1     0    1F  1     1     1     1     1   ok
2D  1     0     1     1     0     1     0    1F  1     1     1     1     1   ok
2E  0     1     1     1     0     1     0    1F  1     1     1     1     1   ok
2F  1     1     1     1     0     1     0    1F  1     1     1     1     1   ok
30  0     0     0     0     1     1     0    1F  1     1     1     1     1   ok
31  1     0     0     0     1     1     0    1F  1     1     1     1     1   ok
32  0     1     0     0     1     1     0    1F  1     1     1     1     1   ok
33  1     1     0     0     1     1     0    1F  1     1     1     1     1   ok
34  0     0     1     0     1     1     0    1F  1     1     1     1     1   ok
35  1     0     1     0     1     1     0    1F  1     1     1     1     1   ok
36  0     1     1     0     1     1     0    1F  1     1     1     1     1   ok
37  1     1     1     0     1     1     0    1F  1     1     1     1     1   ok
38  0     0     0     1     1     1     0    1F  1     1     1     1     1   ok
39  1     0     0     1     1     1     0    1F  1     1     1     1     1   ok
3A  0     1     0     1     1     1     0    1F  1     1     1     1     1   ok
3B  1     1     0     1     1     1     0    1F  1     1     1     1     1   ok
3C  0     0     1     1     1     1     0    1F  1     1     1     1     1   ok
3D  1     0     1     1     1     1     0    1F  1     1     1     1     1   ok
3E  0     1     1     1     1     1     0    1F  1     1     1     1     1   ok
3F  1     1     1     1     1     1     0    1F  1     1     1     1     1   ok
40  0     0     0     0     0     0     1    1F  1     1     1     1     1   ok
41  1     0     0     0     0     0     1    0E  0     1     1     1     0   ok
42  0     1     0     0     0     0     1    1F  1     1     1     1     1   ok
43  1     1     0     0     0     0     1    0E  0     1     1     1     0   ok
44  0     0     1     0     0     0     1    1F  1     1     1     1     1   ok
45  1     0     1     0     0     0     1    0D  1     0     1     1     0   ok
46  0     1     1     0     0     0     1    1F  1     1     1     1     1   ok
47  1     1     1     0     0     0     1    0D  1     0     1     1     0   ok
48  0     0     0     1     0     0     1    1F  1     1     1     1     1   ok
49  1     0     0     1     0     0     1    0E  0     1     1     1     0   ok
4A  0     1     0     1     0     0     1    1F  1     1     1     1     1   ok
4B  1     1     0     1     0     0     1    0E  0     1     1     1     0   ok
4C  0     0     1     1     0     0     1    17  1     1     1     0     1   ok
4D  1     0     1     1     0     0     1    0D  1     0     1     1     0   ok
4E  0     1     1     1     0     0     1    1B  1     1     0     1     1   ok
4F  1     1     1     1     0     0     1    0D  1     0     1     1     0   ok
50  0     0     0     0     1     0     1    1F  1     1     1     1     1   ok
51  1     0     0     0     1     0     1    1F  1     1     1     1     1   ok
52  0     1     0     0     1     0     1    1F  1     1     1     1     1   ok
53  1     1     0     0     1     0     1    1F  1     1     1     1     1   ok
54  0     0     1     0     1     0     1    1F  1     1     1     1     1   ok
55  1     0     1     0     1     0     1    1F  1     1     1     1     1   ok
56  0     1     1     0     1     0     1    1F  1     1     1     1     1   ok
57  1     1     1     0     1     0     1    1F  1     1     1     1     1   ok
58  0     0     0     1     1     0     1    1F  1     1     1     1     1   ok
59  1     0     0     1     1     0     1    1F  1     1     1     1     1   ok
5A  0     1     0     1     1     0     1    1F  1     1     1     1     1   ok
5B  1     1     0     1     1     0     1    1F  1     1     1     1     1   ok
5C  0     0     1     1     1     0     1    1F  1     1     1     1     1   ok
5D  1     0     1     1     1     0     1    1F  1     1     1     1     1   ok
5E  0     1     1     1     1     0     1    1F  1     1     1     1     1   ok
5F  1     1     1     1     1     0     1    1F  1     1     1     1     1   ok
60  0     0     0     0     0     1     1    0E  0     1     1     1     0   ok
61  1     0     0     0     0     1     1    0E  0     1     1     1     0   ok
62  0     1     0     0     0     1     1    0E  0     1     1     1     0   ok
63  1     1     0     0     0     1     1    0E  0     1     1     1     0   ok
64  0     0     1     0     0     1     1    0D  1     0     1     1     0   ok
65  1     0     1     0     0     1     1    0D  1     0     1     1     0   ok
66  0     1     1     0     0     1     1    0D  1     0     1     1     0   ok
67  1     1     1     0     0     1     1    0D  1     0     1     1     0   ok
68  0     0     0     1     0     1     1    0E  0     1     1     1     0   ok
69  1     0     0     1     0     1     1    0E  0     1     1     1     0   ok
6A  0     1     0     1     0     1     1    0E  0     1     1     1     0   ok
6B  1     1     0     1     0     1     1    0E  0     1     1     1     0   ok
6C  0     0     1     1     0     1     1    0D  1     0     1     1     0   ok
6D  1     0     1     1     0     1     1    0D  1     0     1     1     0   ok
6E  0     1     1     1     0     1     1    0D  1     0     1     1     0   ok
6F  1     1     1     1     0     1     1    0D  1     0     1     1     0   ok
70  0     0     0     0     1     1     1    1F  1     1     1     1     1   ok
71  1     0     0     0     1     1     1    1F  1     1     1     1     1   ok
72  0     1     0     0     1     1     1    1F  1     1     1     1     1   ok
73  1     1     0     0     1     1     1    17  1     1     1     0     1   ok
74  0     0     1     0     1     1     1    1F  1     1     1     1     1   ok
75  1     0     1     0     1     1     1    1F  1     1     1     1     1   ok
76  0     1     1     0     1     1     1    1F  1     1     1     1     1   ok
77  1     1     1     0     1     1     1    1B  1     1     0     1     1   ok
78  0     0     0     1     1     1     1    1F  1     1     1     1     1   ok
79  1     0     0     1     1     1     1    1F  1     1     1     1     1   ok
7A  0     1     0     1     1     1     1    1F  1     1     1     1     1   ok
7B  1     1     0     1     1     1     1    1F  1     1     1     1     1   ok
7C  0     0     1     1     1     1     1    1F  1     1     1     1     1   ok
7D  1     0     1     1     1     1     1    1F  1     1     1     1     1   ok
7E  0     1     1     1     1     1     1    1F  1     1     1     1     1   ok
7F  1     1     1     1     1     1     1    1F  1     1     1     1     1   ok
;------------------
;:----------------- MAD-1 (and MAD-1 A) Formulas / Logic Table
;------------------
;if /RES=HIGH and MODE=LOW                                      ;\
;  if /ROMSEL=LOW and ADDR0=HIGH             --> /ROM.CS=LOW    ;
;  if /ROMSEL=LOW ADDR0=HIGH and ADDR2=LOW   --> /ROM.CS0=LOW   ;
;  if /ROMSEL=LOW ADDR0=HIGH and ADDR2=HIGH  --> /ROM.CS1=LOW   ; LoROM
;  if /ROMSEL=LOW ADDR0=LOW and ADDR2=HIGH and ADDR3=HIGH       ;
;    if ADDR1=LOW                            --> /AUX.CS=LOW    ;
;    if ADDR1=HIGH and Vbat<VCC              --> /SRAM.CS=LOW   ;/
;---
;if /RES=HIGH and MODE=HIGH                                     ;\
;  if /ROMSEL=LOW                            --> /ROM.CS=LOW    ;
;  if /ROMSEL=LOW and ADDR2=LOW              --> /ROM.CS0=LOW   ;
;  if /ROMSEL=LOW and ADDR2=HIGH             --> /ROM.CS1=LOW   ; HiROM
;  if /ROMSEL=HIGH and ADDR0=HIGH and ADDR1=HIGH and ADDR3=LOW  ;
;    if ADDR2=LOW                            --> /AUX.CS=LOW    ;
;    if ADDR2=HIGH and Vbat<VCC              --> /SRAM.CS=LOW   ;/
;------------------
  IN0   IN1   IN2   IN3   IN4   IN5   IN6   VCC vs   --> Output being
  Addr0 Addr1 Addr2 Addr3 /ROM  MODE  /RES  Vbat         dragged LOW
  --------------------------------------------------------------------
  HIGH  x     x     x     LOW   LOW   HIGH  x        --> /ROM.CS=LOW   ;\
  HIGH  x     LOW   x     LOW   LOW   HIGH  x        --> /ROM.CS0=LOW  ;
  HIGH  x     HIGH  x     LOW   LOW   HIGH  x        --> /ROM.CS1=LOW  ; LoROM
  LOW   LOW   HIGH  HIGH  LOW   LOW   HIGH  x        --> /AUX.CS=LOW   ;
  LOW   HIGH  HIGH  HIGH  LOW   LOW   HIGH  VCC>Vbat --> /SRAM.CS=LOW  ;/
  x     x     x     x     LOW   HIGH  HIGH  x        --> /ROM.CS=LOW   ;\
  x     x     LOW   x     LOW   HIGH  HIGH  x        --> /ROM.CS0=LOW  ;
  x     x     HIGH  x     LOW   HIGH  HIGH  x        --> /ROM.CS1=LOW  ; HiROM
  HIGH  HIGH  LOW   LOW   HIGH  HIGH  HIGH  x        --> /AUX.CS=LOW   ;
  HIGH  HIGH  HIGH  LOW   HIGH  HIGH  HIGH  VCC>Vbat --> /SRAM.CS=LOW  ;/
;------------------
;:----------------- MAD-R Formulas / Logic Table
;------------------
;if /RES=HIGH                                --> RES=LOW        ;-inverted /RES
;---
;if /RES=HIGH and MODE=LOW                                      ;\
;  if /ROMSEL=LOW ADDR3=LOW and ADDR2=LOW    --> /ROM.CS0=LOW   ;        ! A3=LO instead A0=HI on MAD-1
;  if /ROMSEL=LOW ADDR3=LOW and ADDR2=HIGH   --> /ROM.CS1=LOW   ; LoROM  ! A3=LO instead A0=HI on MAD-1
;  if /ROMSEL=LOW ADDR2=LOW and ADDR3=HIGH   --> /AUX.CS=LOW    ;        ! A0..A2 other as MAD-1
;  if /ROMSEL=LOW ADDR0=LOW and ADDR2=HIGH and ADDR3=HIGH       ;        same as MAD-1
;    if ADDR1=HIGH and Vbat<VCC              --> /SRAM.CS=LOW   ;/       same as MAD-1
;---
;if /RES=HIGH and MODE=HIGH                                     ;\
;  if /ROMSEL=LOW and ADDR2=LOW              --> /ROM.CS0=LOW   ;        same as MAD-1
;  if /ROMSEL=LOW and ADDR2=HIGH             --> /ROM.CS1=LOW   ; HiROM  same as MAD-1
;  if /ROMSEL=HIGH and ADDR0=HIGH and ADDR1=HIGH and ADDR3=LOW  ;        same as MAD-1
;    if ADDR2=LOW                            --> /AUX.CS=LOW    ;        same as MAD-1
;    if ADDR2=HIGH and Vbat<VCC              --> /SRAM.CS=LOW   ;/       same as MAD-1
;------------------
  IN0   IN1   IN2   IN3   IN4   IN5   IN6   VCC vs   --> Output being
  Addr0 Addr1 Addr2 Addr3 /ROM  MODE  /RES  Vbat         dragged LOW
  --------------------------------------------------------------------
  x     x     x     x     x     x     HIGH  ?        --> RESET=LOW    * ;-Reset
  x     x     LOW   LOW   LOW   LOW   HIGH  x        --> /ROM.CS0=LOW * ;\
  x     x     HIGH  LOW   LOW   LOW   HIGH  x        --> /ROM.CS1=LOW * ; LoROM
  x     x     LOW   HIGH  LOW   LOW   HIGH  x        --> /AUX.CS=LOW  * ;
  LOW   HIGH  HIGH  HIGH  LOW   LOW   HIGH  VCC>Vbat --> /SRAM.CS=LOW   ;/
  x     x     LOW   x     LOW   HIGH  HIGH  x        --> /ROM.CS0=LOW   ;\
  x     x     HIGH  x     LOW   HIGH  HIGH  x        --> /ROM.CS1=LOW   ; HiROM
  HIGH  HIGH  LOW   LOW   HIGH  HIGH  HIGH  x        --> /AUX.CS=LOW    ;
  HIGH  HIGH  HIGH  LOW   HIGH  HIGH  HIGH  VCC>Vbat --> /SRAM.CS=LOW   ;/
The four "*" marked lines are different as MAD-1.
;------------------
;:----------------- End of File
;------------------
