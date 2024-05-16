; ##############################
; # Programm: 00_Intro.asm.asm #
; # Autor:    Christian Gerbig #
; # Datum:    12.04.2024       #
; # Version:  1.0              #
; # CPU:      68020+           #
; # FASTMEM:  -                #
; # Chipset:  AGA              #
; # OS:       3.0+             #
; ##############################

  XDEF start_00_intro
  XDEF mouse_handler
  XDEF sine_table

  XREF COLOR00BITS
  XREF nop_first_copperlist
  XREF nop_second_copperlist

  SECTION code_and_variables,CODE

  MC68040


; ** Library-Includes V.3.x nachladen **
; --------------------------------------
  ;INCDIR  "OMA:include/"
  INCDIR "Daten:include3.5/"

  INCLUDE "dos/dos.i"
  INCLUDE "dos/dosextens.i"
  INCLUDE "libraries/dos_lib.i"

  INCLUDE "exec/exec.i"
  INCLUDE "exec/exec_lib.i"

  INCLUDE "graphics/GFXBase.i"
  INCLUDE "graphics/videocontrol.i"
  INCLUDE "graphics/graphics_lib.i"

  INCLUDE "intuition/intuition.i"
  INCLUDE "intuition/intuition_lib.i"

  INCLUDE "resources/cia_lib.i"

  INCLUDE "hardware/adkbits.i"
  INCLUDE "hardware/blit.i"
  INCLUDE "hardware/cia.i"
  INCLUDE "hardware/custom.i"
  INCLUDE "hardware/dmabits.i"
  INCLUDE "hardware/intbits.i"

  INCDIR "Daten:Asm-Sources.AGA/normsource-includes/"


; ** Konstanten **
; ----------------

  INCLUDE "equals.i"

requires_68030                 EQU FALSE
requires_68040                 EQU FALSE
requires_68060                 EQU FALSE
requires_fast_memory           EQU FALSE
requires_multiscan_monitor     EQU FALSE

workbench_start                EQU FALSE
workbench_fade                 EQU FALSE
text_output                    EQU FALSE

sys_taken_over
pass_global_references
pass_return_code

DMABITS                        EQU DMAF_SPRITE+DMAF_BLITTER+DMAF_COPPER+DMAF_RASTER+DMAF_SETCLR

INTENABITS                     EQU INTF_SETCLR

CIAAICRBITS                    EQU CIAICRF_SETCLR
CIABICRBITS                    EQU CIAICRF_SETCLR

COPCONBITS                     EQU TRUE

pf1_x_size1                    EQU 192
pf1_y_size1                    EQU 192
pf1_depth1                     EQU 3
pf1_x_size2                    EQU 192
pf1_y_size2                    EQU 192
pf1_depth2                     EQU 3
pf1_x_size3                    EQU 192
pf1_y_size3                    EQU 192
pf1_depth3                     EQU 3
pf1_colors_number              EQU 0 ;8

pf2_x_size1                    EQU 0
pf2_y_size1                    EQU 0
pf2_depth1                     EQU 0
pf2_x_size2                    EQU 0
pf2_y_size2                    EQU 0
pf2_depth2                     EQU 0
pf2_x_size3                    EQU 0
pf2_y_size3                    EQU 0
pf2_depth3                     EQU 0
pf2_colors_number              EQU 0
pf_colors_number               EQU pf1_colors_number+pf2_colors_number
pf_depth                       EQU pf1_depth3+pf2_depth3

extra_pf_number                EQU 0

spr_number                     EQU 8
spr_x_size1                    EQU 0
spr_x_size2                    EQU 64
spr_depth                      EQU 2
spr_colors_number              EQU 0 ;16
spr_odd_color_table_select     EQU 1
spr_even_color_table_select    EQU 1
spr_used_number                EQU 3

audio_memory_size              EQU 0

disk_memory_size               EQU 0

extra_memory_size              EQU 0

chip_memory_size               EQU 0

AGA_OS_Version                 EQU 39

CIAA_TA_value                  EQU 0
CIAA_TB_value                  EQU 0
CIAB_TA_value                  EQU 0
CIAB_TB_value                  EQU 0
CIAA_TA_continuous             EQU FALSE
CIAA_TB_continuous             EQU FALSE
CIAB_TA_continuous             EQU FALSE
CIAB_TB_continuous             EQU FALSE

beam_position                  EQU $136

pixel_per_line                 EQU 192
visible_pixels_number          EQU 192
visible_lines_number           EQU 192
MINROW                         EQU VSTOP_OVERSCAN_PAL

pf_pixel_per_datafetch         EQU 64 ;4x
DDFSTRTBITS                    EQU DDFSTART_192_pixel_4x
DDFSTOPBITS                    EQU DDFSTOP_192_pixel_4x
spr_pixel_per_datafetch        EQU 64 ;4x

display_window_HSTART          EQU HSTART_192_pixel
display_window_VSTART          EQU MINROW
DIWSTRTBITS                    EQU ((display_window_VSTART&$ff)*DIWSTRTF_V0)+(display_window_HSTART&$ff)
display_window_HSTOP           EQU HSTOP_192_pixel
display_window_VSTOP           EQU VSTOP_256_lines
DIWSTOPBITS                    EQU ((display_window_VSTOP&$ff)*DIWSTOPF_V0)+(display_window_HSTOP&$ff)

pf1_plane_width                EQU pf1_x_size3/8
data_fetch_width               EQU pixel_per_line/8
pf1_plane_moduli               EQU (pf1_plane_width*(pf1_depth3-1))+pf1_plane_width-data_fetch_width

BPLCON0BITS                    EQU BPLCON0F_ECSENA+((pf_depth>>3)*BPLCON0F_BPU3)+(BPLCON0F_COLOR)+((pf_depth&$07)*BPLCON0F_BPU0) ;lores
BPLCON1BITS                    EQU TRUE
BPLCON2BITS                    EQU TRUE
BPLCON3BITS1                   EQU BPLCON3F_SPRES0
BPLCON3BITS2                   EQU BPLCON3BITS1+BPLCON3F_LOCT
BPLCON4BITS                    EQU (BPLCON4F_OSPRM4*spr_odd_color_table_select)+(BPLCON4F_ESPRM4*spr_even_color_table_select)
DIWHIGHBITS                    EQU (((display_window_HSTOP&$100)>>8)*DIWHIGHF_HSTOP8)+(((display_window_VSTOP&$700)>>8)*DIWHIGHF_VSTOP8)+(((display_window_HSTART&$100)>>8)*DIWHIGHF_HSTART8)+((display_window_VSTART&$700)>>8)
FMODEBITS                      EQU FMODEF_SPR32+FMODEF_SPAGEM+FMODEF_BPL32+FMODEF_BPAGEM

cl1_display_y_size1            EQU 39
cl1_display_y_size2            EQU 56
cl2_display_x_size1            EQU 192
cl2_display_width1             EQU cl2_display_x_size1/8
cl2_display_x_size2            EQU 192
cl2_display_width2             EQU cl2_display_x_size2/8
cl1_HSTART1                    EQU display_window_HSTART-(4*CMOVE_slot_period)-4
cl1_VSTART1                    EQU VSTART_192_lines
cl1_HSTART2                    EQU display_window_HSTART-(4*CMOVE_slot_period)-4
cl1_VSTART2                    EQU VSTART_192_lines+110
cl1_HSTART3                    EQU $00
cl1_VSTART3                    EQU beam_position&$ff

sine_table_length              EQU 512

; **** Title ****
title_image_x_position         EQU display_window_HSTART
title_image_y_position         EQU VSTART_192_lines
title_image_x_size             EQU 192
title_image_width              EQU title_image_x_size/8
title_image_y_size             EQU 39

; **** Logo ****
logo_image_x_position1         EQU display_window_HSTART+28
logo_image_y_position1         EQU VSTART_192_lines+110
logo_image_x_position2         EQU display_window_HSTART+88
logo_image_y_position2         EQU VSTART_192_lines+150
logo_image_x_position3         EQU display_window_HSTART+148
logo_image_y_position3         EQU VSTART_192_lines+110
logo_image_x_size              EQU 192
logo_image_width               EQU logo_image_x_size/8
logo_image_y_size              EQU 16

; **** Glenz-Vectors ****
gv_rotation_d                  EQU 512
gv_rotation_xy_center          EQU visible_lines_number/2
gv_rotation_y_angle_speed      EQU 4

gv_object_edge_points_number   EQU 26
gv_object_edge_points_per_face EQU 3
gv_object_faces_number         EQU 48

gv_object_face1_color          EQU 2
gv_object_face1_lines_number   EQU 3
gv_object_face2_color          EQU 4
gv_object_face2_lines_number   EQU 3
gv_object_face3_color          EQU 2
gv_object_face3_lines_number   EQU 3
gv_object_face4_color          EQU 4
gv_object_face4_lines_number   EQU 3
gv_object_face5_color          EQU 2
gv_object_face5_lines_number   EQU 3
gv_object_face6_color          EQU 4
gv_object_face6_lines_number   EQU 3
gv_object_face7_color          EQU 2
gv_object_face7_lines_number   EQU 3
gv_object_face8_color          EQU 4
gv_object_face8_lines_number   EQU 3

gv_object_face9_color          EQU 4
gv_object_face9_lines_number   EQU 3
gv_object_face10_color         EQU 2
gv_object_face10_lines_number  EQU 3
gv_object_face11_color         EQU 4
gv_object_face11_lines_number  EQU 3
gv_object_face12_color         EQU 2
gv_object_face12_lines_number  EQU 3

gv_object_face13_color         EQU 2
gv_object_face13_lines_number  EQU 3
gv_object_face14_color         EQU 4
gv_object_face14_lines_number  EQU 3
gv_object_face15_color         EQU 2
gv_object_face15_lines_number  EQU 3
gv_object_face16_color         EQU 4
gv_object_face16_lines_number  EQU 3

gv_object_face17_color         EQU 4
gv_object_face17_lines_number  EQU 3
gv_object_face18_color         EQU 2
gv_object_face18_lines_number  EQU 3
gv_object_face19_color         EQU 4
gv_object_face19_lines_number  EQU 3
gv_object_face20_color         EQU 2
gv_object_face20_lines_number  EQU 3

gv_object_face21_color         EQU 2
gv_object_face21_lines_number  EQU 3
gv_object_face22_color         EQU 4
gv_object_face22_lines_number  EQU 3
gv_object_face23_color         EQU 2
gv_object_face23_lines_number  EQU 3
gv_object_face24_color         EQU 4
gv_object_face24_lines_number  EQU 3

gv_object_face25_color         EQU 4
gv_object_face25_lines_number  EQU 3
gv_object_face26_color         EQU 2
gv_object_face26_lines_number  EQU 3
gv_object_face27_color         EQU 4
gv_object_face27_lines_number  EQU 3
gv_object_face28_color         EQU 2
gv_object_face28_lines_number  EQU 3

gv_object_face29_color         EQU 2
gv_object_face29_lines_number  EQU 3
gv_object_face30_color         EQU 4
gv_object_face30_lines_number  EQU 3
gv_object_face31_color         EQU 2
gv_object_face31_lines_number  EQU 3
gv_object_face32_color         EQU 4
gv_object_face32_lines_number  EQU 3

gv_object_face33_color         EQU 4
gv_object_face33_lines_number  EQU 3
gv_object_face34_color         EQU 2
gv_object_face34_lines_number  EQU 3
gv_object_face35_color         EQU 4
gv_object_face35_lines_number  EQU 3
gv_object_face36_color         EQU 2
gv_object_face36_lines_number  EQU 3

gv_object_face37_color         EQU 2
gv_object_face37_lines_number  EQU 3
gv_object_face38_color         EQU 4
gv_object_face38_lines_number  EQU 3
gv_object_face39_color         EQU 2
gv_object_face39_lines_number  EQU 3
gv_object_face40_color         EQU 4
gv_object_face40_lines_number  EQU 3

gv_object_face41_color         EQU 2
gv_object_face41_lines_number  EQU 3
gv_object_face42_color         EQU 4
gv_object_face42_lines_number  EQU 3
gv_object_face43_color         EQU 2
gv_object_face43_lines_number  EQU 3
gv_object_face44_color         EQU 4
gv_object_face44_lines_number  EQU 3
gv_object_face45_color         EQU 2
gv_object_face45_lines_number  EQU 3
gv_object_face46_color         EQU 4
gv_object_face46_lines_number  EQU 3
gv_object_face47_color         EQU 2
gv_object_face47_lines_number  EQU 3
gv_object_face48_color         EQU 4
gv_object_face48_lines_number  EQU 3

; **** Fill-Blit ****
gv_fill_blit_x_size            EQU visible_pixels_number
gv_fill_blit_y_size            EQU visible_lines_number
gv_fill_blit_depth             EQU pf1_depth3

; **** Scroll-Playfield-Bottom ****
spb_min_VSTART                 EQU VSTART_192_lines
spb_max_VSTOP                  EQU VSTOP_OVERSCAN_PAL
spb_max_visible_lines_number   EQU 283
spb_y_radius                   EQU visible_lines_number+(spb_max_visible_lines_number-visible_lines_number)
spb_y_centre                   EQU visible_lines_number+(spb_max_visible_lines_number-visible_lines_number)

; **** Scroll-Playfield-Bottom-In ****
spbi_y_angle_speed             EQU 3

; **** Scroll-Playfield-Bottom-Out ****
spbo_y_angle_speed             EQU 2

; **** Horiz-Fader ****
hf_colors_per_colorbank        EQU 16
hf_colorbanks_number           EQU 240/hf_colors_per_colorbank

; **** Effects-Handler ****
eh_trigger_number_max          EQU 5


; ## Makrobefehle ##
; ------------------

  INCLUDE "macros.i"


; ** Struktur, die alle Exception-Vektoren-Offsets enthält **
; -----------------------------------------------------------

  INCLUDE "except-vectors-offsets.i"


; ** Struktur, die alle Eigenschaften des Extra-Playfields enthält **
; -------------------------------------------------------------------

  INCLUDE "extra-pf-attributes-structure.i"


; ** Struktur, die alle Eigenschaften der Sprites enthält **
; ----------------------------------------------------------

  INCLUDE "sprite-attributes-structure.i"


; ** Struktur, die alle Registeroffsets der ersten Copperliste enthält **
; -----------------------------------------------------------------------
  RSRESET

cl1_subextension1      RS.B 0
cl1_subext1_WAIT       RS.L 1
cl1_subext1_COP1LCH    RS.L 1
cl1_subext1_COP1LCL    RS.L 1
cl1_subext1_COPJMP2    RS.L 1
cl1_subextension1_SIZE RS.B 0

  RSRESET

cl1_extension1               RS.B 0
cl1_ext1_COP2LCH             RS.L 1
cl1_ext1_COP2LCL             RS.L 1
cl1_ext1_subextension1_entry RS.B cl1_subextension1_SIZE*cl1_display_y_size1
cl1_extension1_SIZE          RS.B 0

  RSRESET

cl1_extension2               RS.B 0
cl1_ext2_COP2LCH             RS.L 1
cl1_ext2_COP2LCL             RS.L 1
cl1_ext2_subextension1_entry RS.B cl1_subextension1_SIZE*cl1_display_y_size2
cl1_extension2_SIZE          RS.B 0

  RSRESET

cl1_begin            RS.B 0

  INCLUDE "copperlist1-offsets.i"

cl1_extension1_entry RS.B cl1_extension1_SIZE
cl1_extension2_entry RS.B cl1_extension2_SIZE
cl1_COP1LCH          RS.L 1
cl1_COP1LCL          RS.L 1
cl1_WAIT             RS.L 1
cl1_INTENA           RS.L 1

cl1_end              RS.L 1

copperlist1_SIZE     RS.B 0

; ** Struktur, die alle Registeroffsets der zweiten Copperliste enthält **
; ------------------------------------------------------------------------

  RSRESET

cl2_extension1      RS.B 0

cl2_ext1_BPLCON4_1  RS.L 1
cl2_ext1_BPLCON4_2  RS.L 1
cl2_ext1_BPLCON4_3  RS.L 1
cl2_ext1_BPLCON4_4  RS.L 1
cl2_ext1_BPLCON4_5  RS.L 1
cl2_ext1_BPLCON4_6  RS.L 1
cl2_ext1_BPLCON4_7  RS.L 1
cl2_ext1_BPLCON4_8  RS.L 1
cl2_ext1_BPLCON4_9  RS.L 1
cl2_ext1_BPLCON4_10 RS.L 1
cl2_ext1_BPLCON4_11 RS.L 1
cl2_ext1_BPLCON4_12 RS.L 1
cl2_ext1_BPLCON4_13 RS.L 1
cl2_ext1_BPLCON4_14 RS.L 1
cl2_ext1_BPLCON4_15 RS.L 1
cl2_ext1_BPLCON4_16 RS.L 1
cl2_ext1_BPLCON4_17 RS.L 1
cl2_ext1_BPLCON4_18 RS.L 1
cl2_ext1_BPLCON4_19 RS.L 1
cl2_ext1_BPLCON4_20 RS.L 1
cl2_ext1_BPLCON4_21 RS.L 1
cl2_ext1_BPLCON4_22 RS.L 1
cl2_ext1_BPLCON4_23 RS.L 1
cl2_ext1_BPLCON4_24 RS.L 1
cl2_ext1_COPJMP1    RS.L 1

cl2_extension1_SIZE RS.B 0

  RSRESET

cl2_extension2      RS.B 0

cl2_ext2_BPLCON4_1  RS.L 1
cl2_ext2_BPLCON4_2  RS.L 1
cl2_ext2_BPLCON4_3  RS.L 1
cl2_ext2_BPLCON4_4  RS.L 1
cl2_ext2_BPLCON4_5  RS.L 1
cl2_ext2_BPLCON4_6  RS.L 1
cl2_ext2_BPLCON4_7  RS.L 1
cl2_ext2_BPLCON4_8  RS.L 1
cl2_ext2_BPLCON4_9  RS.L 1
cl2_ext2_BPLCON4_10 RS.L 1
cl2_ext2_BPLCON4_11 RS.L 1
cl2_ext2_BPLCON4_12 RS.L 1
cl2_ext2_BPLCON4_13 RS.L 1
cl2_ext2_BPLCON4_14 RS.L 1
cl2_ext2_BPLCON4_15 RS.L 1
cl2_ext2_BPLCON4_16 RS.L 1
cl2_ext2_BPLCON4_17 RS.L 1
cl2_ext2_BPLCON4_18 RS.L 1
cl2_ext2_BPLCON4_19 RS.L 1
cl2_ext2_BPLCON4_20 RS.L 1
cl2_ext2_BPLCON4_21 RS.L 1
cl2_ext2_BPLCON4_22 RS.L 1
cl2_ext2_BPLCON4_23 RS.L 1
cl2_ext2_BPLCON4_24 RS.L 1
cl2_ext2_COPJMP1    RS.L 1

cl2_extension2_SIZE RS.B 0

  RSRESET

cl2_begin            RS.B 0

cl2_extension1_entry RS.B cl2_extension1_SIZE
cl2_extension2_entry RS.B cl2_extension2_SIZE

copperlist2_SIZE     RS.B 0


; ** Konstanten für die größe der Copperlisten **
; -----------------------------------------------
cl1_size1          EQU 0
cl1_size2          EQU 0
cl1_size3          EQU copperlist1_SIZE
cl2_size1          EQU 0
cl2_size2          EQU 0
cl2_size3          EQU copperlist2_SIZE


; ** Sprite0-Zusatzstruktur **
; ----------------------------
  RSRESET

spr0_extension1       RS.B 0

spr0_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr0_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*title_image_y_size

spr0_extension1_SIZE  RS.B 0

  RSRESET

spr0_extension2       RS.B 0

spr0_ext2_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr0_ext2_planedata   RS.L (spr_pixel_per_datafetch/16)*logo_image_y_size

spr0_extension2_SIZE  RS.B 0

; ** Sprite0-Hauptstruktur **
; ---------------------------
  RSRESET

spr0_begin            RS.B 0

spr0_extension1_entry RS.B spr0_extension1_SIZE
spr0_extension2_entry RS.B spr0_extension2_SIZE

spr0_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite0_SIZE          RS.B 0

; ** Sprite1-Zusatzstruktur **
; ----------------------------
  RSRESET

spr1_extension1       RS.B 0

spr1_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr1_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*title_image_y_size

spr1_extension1_SIZE  RS.B 0

  RSRESET

spr1_extension2       RS.B 0

spr1_ext2_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr1_ext2_planedata   RS.L (spr_pixel_per_datafetch/16)*logo_image_y_size

spr1_extension2_SIZE  RS.B 0

; ** Sprite1-Hauptstruktur **
; ---------------------------
  RSRESET

spr1_begin            RS.B 0

spr1_extension1_entry RS.B spr1_extension1_SIZE
spr1_extension2_entry RS.B spr1_extension2_SIZE

spr1_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite1_SIZE          RS.B 0

; ** Sprite2-Zusatzstruktur **
; ----------------------------
  RSRESET

spr2_extension1       RS.B 0

spr2_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr2_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*title_image_y_size

spr2_extension1_SIZE  RS.B 0

  RSRESET

spr2_extension2       RS.B 0

spr2_ext2_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr2_ext2_planedata   RS.L (spr_pixel_per_datafetch/16)*logo_image_y_size

spr2_extension2_SIZE  RS.B 0

; ** Sprite2-Hauptstruktur **
; ---------------------------
  RSRESET

spr2_begin            RS.B 0

spr2_extension1_entry RS.B spr2_extension1_SIZE
spr2_extension2_entry RS.B spr2_extension2_SIZE

spr2_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite2_SIZE          RS.B 0

; ** Sprite3-Hauptstruktur **
; ---------------------------
  RSRESET

spr3_begin            RS.B 0

spr3_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite3_SIZE          RS.B 0

; ** Sprite4-Hauptstruktur **
; ---------------------------
  RSRESET

spr4_begin            RS.B 0

spr4_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite4_SIZE          RS.B 0

; ** Sprite5-Hauptstruktur **
; ---------------------------
  RSRESET

spr5_begin            RS.B 0

spr5_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite5_SIZE          RS.B 0

; ** Sprite6-Hauptstruktur **
; ---------------------------
  RSRESET

spr6_begin            RS.B 0

spr6_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite6_SIZE          RS.B 0

; ** Sprite7-Hauptstruktur **
; ---------------------------
  RSRESET

spr7_begin            RS.B 0

spr7_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite7_SIZE          RS.B 0

; ** Konstanten für die Größe der Spritestrukturen **
; ---------------------------------------------------
spr0_x_size1     EQU spr_x_size1
spr0_y_size1     EQU 0
spr1_x_size1     EQU spr_x_size1
spr1_y_size1     EQU 0
spr2_x_size1     EQU spr_x_size1
spr2_y_size1     EQU 0
spr3_x_size1     EQU spr_x_size1
spr3_y_size1     EQU 0
spr4_x_size1     EQU spr_x_size1
spr4_y_size1     EQU 0
spr5_x_size1     EQU spr_x_size1
spr5_y_size1     EQU 0
spr6_x_size1     EQU spr_x_size1
spr6_y_size1     EQU 0
spr7_x_size1     EQU spr_x_size1
spr7_y_size1     EQU 0

spr0_x_size2     EQU spr_x_size2
spr0_y_size2     EQU sprite0_SIZE/(spr_x_size2/8)
spr1_x_size2     EQU spr_x_size2
spr1_y_size2     EQU sprite1_SIZE/(spr_x_size2/8)
spr2_x_size2     EQU spr_x_size2
spr2_y_size2     EQU sprite2_SIZE/(spr_x_size2/8)
spr3_x_size2     EQU spr_x_size2
spr3_y_size2     EQU sprite3_SIZE/(spr_x_size2/8)
spr4_x_size2     EQU spr_x_size2
spr4_y_size2     EQU sprite4_SIZE/(spr_x_size2/8)
spr5_x_size2     EQU spr_x_size2
spr5_y_size2     EQU sprite5_SIZE/(spr_x_size2/8)
spr6_x_size2     EQU spr_x_size2
spr6_y_size2     EQU sprite6_SIZE/(spr_x_size2/8)
spr7_x_size2     EQU spr_x_size2
spr7_y_size2     EQU sprite7_SIZE/(spr_x_size2/8)


; ** Struktur, die alle Variablenoffsets enthält **
; -------------------------------------------------

  INCLUDE "variables-offsets.i"

save_a7                RS.L 1

; **** Glenz-Vectors ****
gv_rotation_x_angle    RS.W 1
gv_rotation_y_angle    RS.W 1
gv_rotation_z_angle    RS.W 1

; **** Scroll-Playfield-Bottom-In ****
spbi_state             RS.W 1
spbi_y_angle           RS.W 1

; **** Scroll-Playfield-Bottom-Out ****
spbo_state             RS.W 1
spbo_y_angle           RS.W 1

; **** Horiz-Fader ****
hf1_switch_table_start RS.W 1
hf2_switch_table_start RS.W 1

; **** Horiz-Fader-In ****
hfi1_state             RS.W 1
hfi2_state             RS.W 1

; **** Horiz-Fader-Out ****
hfo1_state             RS.W 1
hfo2_state             RS.W 1

; **** Effects-Handler ****
eh_trigger_number      RS.W 1

; **** Main ****
fx_state               RS.W 1

variables_SIZE         RS.B 0


; **** Glenz-Vectors ****
; ** Objekt-Info-Struktur **
; --------------------------
  RSRESET

gv_object_info              RS.B 0

gv_object_info_edge_table   RS.L 1
gv_object_info_face_color   RS.W 1
gv_object_info_lines_number RS.W 1

gv_object_info_SIZE         RS.B 0


; ## Beginn des Initialisierungsprogramms ##
; ------------------------------------------
start_00_intro
  INCLUDE "sys-init.i"

; ** Eigene Variablen initialisieren **
; -------------------------------------
  CNOP 0,4
init_own_variables

; **** Glenz-Vectors ****
  moveq   #TRUE,d0
  move.w  d0,gv_rotation_x_angle(a3)
  move.w  d0,gv_rotation_y_angle(a3)
  move.w  d0,gv_rotation_z_angle(a3)

; **** Scroll-Playfield-Bottom-In ****
  moveq   #FALSE,d1
  move.w  d1,spbi_state(a3)
  move.w  d0,spbi_y_angle(a3) ;0 Grad

; **** Scroll-Playfield-Bottom-Out ****
  move.w  d1,spbo_state(a3)
  move.w  #sine_table_length/4,spbo_y_angle(a3) ;90 Grad

; **** Horiz-Fader ****
  move.w  d0,hf1_switch_table_start(a3)
  move.w  d0,hf2_switch_table_start(a3)

; **** Horiz-Fader-In ****
  move.w  d1,hfi1_state(a3)
  move.w  d1,hfi2_state(a3)

; **** Horiz-Fader-Out ****
  move.w  d1,hfo1_state(a3)
  move.w  d1,hfo2_state(a3)

; **** Effects-Handler ****
  move.w  d0,eh_trigger_number(a3)

; **** Main ****
  move.w  d1,fx_state(a3)
  rts

; ** Alle Initialisierungsroutinen ausführen **
; ---------------------------------------------
  CNOP 0,4
init_all
  bsr.s   init_sprites
  bsr     gv_init_object_info_table
  bsr     gv_init_color_table
  bsr     hf_dim_colors
  bsr     init_color_registers
  bsr     init_first_copperlist
  bra     init_second_copperlist

; ** Sprites initialisieren **
; ----------------------------
  CNOP 0,4
init_sprites
  bsr.s   spr_init_pointers_table
  bra.s   init_sprites_cluster

; ** Tabelle mit Zeigern auf Sprites initialisieren **
; ----------------------------------------------------
  INIT_SPRITE_POINTERS_TABLE

; **** Logo ****
  CNOP 0,4
init_sprites_cluster
  move.l  a4,-(a7)
  MOVEF.W (title_image_x_position+(spr_x_size2*0))*4,d0 ;X
  moveq   #title_image_y_position,d1 ;Y
  MOVEF.W title_image_y_size,d2 ;Höhe
  moveq   #((title_image_x_size-spr_x_size2)/8)+title_image_width,d3
  lea     spr_pointers_display(pc),a1 ;Zeiger auf Sprites
  move.l  (a1)+,a0           ;SPR0-Struktur
  lea     title_image_data+((spr_x_size2/8)*0),a2 ;Bitplane 1
  lea     title_image_width(a2),a4 ;Bitplane 2
  MOVEF.W title_image_y_size-1,d7 ;Höhe des Einzelsprites
  bsr     copy_sprite_bitplanes

  MOVEF.W (title_image_x_position+(spr_x_size2*1))*4,d0 ;X
  moveq   #title_image_y_position,d1 ;Y
  MOVEF.W title_image_y_size,d2 ;Höhe
  move.l  (a1)+,a0           ;SPR1-Struktur
  lea     title_image_data+((spr_x_size2/8)*1),a2 ;Bitplane 1
  lea     title_image_width(a2),a4 ;Bitplane 2
  MOVEF.W title_image_y_size-1,d7 ;Höhe des Einzelsprites
  bsr.s   copy_sprite_bitplanes

  MOVEF.W (title_image_x_position+(spr_x_size2*2))*4,d0 ;X
  moveq   #title_image_y_position,d1 ;Y
  MOVEF.W title_image_y_size,d2 ;Höhe
  move.l  (a1),a0            ;SPR2-Struktur
  lea     title_image_data+((spr_x_size2/8)*2),a2 ;Bitplane 1
  lea     title_image_width(a2),a4 ;Bitplane 2
  MOVEF.W title_image_y_size-1,d7 ;Höhe des Einzelsprites
  bsr.s   copy_sprite_bitplanes


  MOVEF.W logo_image_x_position1*4,d0 ;X
  MOVEF.W logo_image_y_position1,d1 ;Y
  MOVEF.W logo_image_y_size,d2 ;Höhe
  moveq   #((logo_image_x_size-spr_x_size2)/8)+logo_image_width,d3
  lea     spr_pointers_display(pc),a1 ;Zeiger auf Sprites
  move.l  (a1)+,a0           ;SPR0-Struktur
  ADDF.W  spr0_extension2_entry,a0
  lea     logo_image_data+((spr_x_size2/8)*0),a2 ;Bitplane 1
  lea     logo_image_width(a2),a4 ;Bitplane 2
  MOVEF.W logo_image_y_size-1,d7 ;Höhe des Einzelsprites
  bsr.s   copy_sprite_bitplanes

  MOVEF.W logo_image_x_position2*4,d0 ;X
  MOVEF.W logo_image_y_position2,d1 ;Y
  MOVEF.W logo_image_y_size,d2 ;Höhe
  move.l  (a1)+,a0           ;SPR1-Struktur
  ADDF.W  spr1_extension2_entry,a0
  lea     logo_image_data+((spr_x_size2/8)*1),a2 ;Bitplane 1
  lea     logo_image_width(a2),a4 ;Bitplane 2
  MOVEF.W logo_image_y_size-1,d7 ;Höhe des Einzelsprites
  bsr.s   copy_sprite_bitplanes

  MOVEF.W logo_image_x_position3*4,d0 ;X
  MOVEF.W logo_image_y_position3,d1 ;Y
  MOVEF.W logo_image_y_size,d2 ;Höhe
  move.l  (a1),a0            ;SPR2-Struktur
  ADDF.W  spr2_extension2_entry,a0
  lea     logo_image_data+((spr_x_size2/8)*2),a2 ;Bitplane 1
  lea     logo_image_width(a2),a4 ;Bitplane 2
  MOVEF.W logo_image_y_size-1,d7 ;Höhe des Einzelsprites
  bsr.s   copy_sprite_bitplanes
  move.l  (a7)+,a4
  rts

  CNOP 0,4
copy_sprite_bitplanes
  add.w   d1,d2              ;VSTOP
  SET_SPRITE_POSITION d0,d1,d2
  move.w  d1,(a0)            ;SPRxPOS
  move.w  d2,spr_pixel_per_datafetch/8(a0) ;SPRxCTL
  ADDF.W  (spr_pixel_per_datafetch/4),a0 ;Sprite-Header überspringen
copy_sprite_bitplanes_loop
  move.l  (a2)+,(a0)+        ;Plane 1 64 Pixel
  move.l  (a2)+,(a0)+
  add.l   d3,a2
  move.l  (a4)+,(a0)+        ;Plane 2 64 Pixel
  move.l  (a4)+,(a0)+
  add.l   d3,a4
  dbf     d7,copy_sprite_bitplanes_loop
  rts

; **** Glenz-Vectors ****
; ** Object-Info-Tabelle initialisieren **
; ----------------------------------------
  CNOP 0,4
gv_init_object_info_table
  lea     gv_object_info_table+gv_object_info_edge_table(pc),a0 ;Zeiger auf Object-Info-Tabelle
  lea     gv_object_edge_table(pc),a1 ;Zeiger auf Tebelle mit Eckpunkten
  move.w  #gv_object_info_SIZE,a2
  moveq   #gv_object_faces_number-1,d7 ;Anzahl der Flächen
gv_init_object_info_table_loop
  move.w  gv_object_info_lines_number(a0),d0 
  addq.w  #2,d0              ;Anzahl der Linien + 1 = Anzahl der Eckpunkte
  move.l  a1,(a0)            ;Zeiger auf Tabelle mit Eckpunkten eintragen
  lea     (a1,d0.w*2),a1     ;Zeiger auf Eckpunkte-Tabelle erhöhen
  add.l   a2,a0              ;Object-Info-Struktur der nächsten Fläche
  dbf     d7,gv_init_object_info_table_loop
  rts

; ** Farbtablelle initialisieren **
; ---------------------------------
  CNOP 0,4
gv_init_color_table
  lea     pf1_color_table(pc),a0 ;Zeiger auf Farbtableelle
  lea     gv_glenz_color_table(pc),a1 ;Farben der einzelnen Glenz-Objekte
  move.l  (a1)+,2*LONGWORDSIZE(a0) ;COLOR02
  move.l  (a1)+,3*LONGWORDSIZE(a0) ;COLOR03
  move.l  (a1)+,4*LONGWORDSIZE(a0) ;COLOR04
  move.l  (a1),5*LONGWORDSIZE(a0) ;COLOR05
  rts

; **** Horiz-Fader ****
; ** Helligkeit der Farben verringern **
; --------------------------------------
  CNOP 0,4
hf_dim_colors
  moveq   #1,d3              ;minimale Helligkeit
  moveq   #hf_colorbanks_number,d4 ;maximale Helligkeit
  lea     spr_color_table+(hf_colors_per_colorbank*LONGWORDSIZE)+(1*LONGWORDSIZE)(pc),a0
  MOVEF.W (hf_colorbanks_number-1)-1,d7 ;Anzahl der Colour-Banks
hf_dim_colors_loop1
  moveq   #hf_colorbanks_number,d5
  sub.b   d3,d5              ;Helligkeit umkehren
  move.l  #COLOR00BITS,d0
  swap    d0                 ;Rr
  mulu.w  d5,d0              ;Rotwert dimmen
  divu.w  d4,d0
  move.l  #COLOR00BITS,d1
  lsr.w   #8,d1              ;Gg
  mulu.w  d5,d1              ;Grünwert dimmen
  divu.w  d4,d1
  move.l  #COLOR00BITS,d2
  and.l   #$0000ff,d2
  mulu.w  d5,d2              ;Blauwert dimmen
  divu.w  d4,d2
  swap    d0                 ;Rr0000
  lsl.w   #8,d1
  move.w  d1,d0              ;RrGg00
  move.b  d2,d0              ;RrGgBb
  move.l  d0,d5              ;RGB8-Hintergrundfarbe
  MOVEF.W (hf_colors_per_colorbank-1)-1,d6 ;Anzahl der Farben pro Colour-Bank
hf_dim_colors_loop2
  move.l  (a0),d0            ;RGB8-Farbwert
  moveq   #TRUE,d2
  move.b  d0,d2              ;Bb
  lsr.w   #8,d0
  moveq   #TRUE,d1
  move.b  d0,d1              ;Gg
  swap    d0                 ;Rr
  mulu.w  d3,d0              ;Rotanteil dimmen
  divu.w  d4,d0
  mulu.w  d3,d1              ;Grünanteil dimmen
  divu.w  d4,d1
  mulu.w  d3,d2              ;Blauanteil dimmen
  divu.w  d4,d2
  swap    d0                 ;Rr0000
  lsl.w   #8,d1
  move.w  d1,d0              ;RrGg00
  move.b  d2,d0              ;RrGgBb
  or.l    d5,d0              ;Hintergrundfarbe
  move.l  d0,(a0)+           ;gedimmter RGB8-Farbwert
  dbf     d6,hf_dim_colors_loop2
  addq.w  #4,a0              ;Hintergrundfarbe überspringen
  addq.w  #1,d3              ;Helligkeit verringern
  dbf     d7,hf_dim_colors_loop1
  rts

; ** Farbregister initialisieren **
; ---------------------------------
  CNOP 0,4
init_color_registers
  CPU_SELECT_COLORHI_BANK 0
  CPU_INIT_COLORHI COLOR00,8,pf1_color_table
  CPU_INIT_COLORHI COLOR16,16,spr_color_table
  CPU_SELECT_COLORHI_BANK 1
  CPU_INIT_COLORHI COLOR00,32
  CPU_SELECT_COLORHI_BANK 2
  CPU_INIT_COLORHI COLOR00,32
  CPU_SELECT_COLORHI_BANK 3
  CPU_INIT_COLORHI COLOR00,32
  CPU_SELECT_COLORHI_BANK 4
  CPU_INIT_COLORHI COLOR00,32
  CPU_SELECT_COLORHI_BANK 5
  CPU_INIT_COLORHI COLOR00,32
  CPU_SELECT_COLORHI_BANK 6
  CPU_INIT_COLORHI COLOR00,32
  CPU_SELECT_COLORHI_BANK 7
  CPU_INIT_COLORHI COLOR00,32

  CPU_SELECT_COLORLO_BANK 0
  CPU_INIT_COLORLO COLOR00,8,pf1_color_table
  CPU_INIT_COLORLO COLOR16,16,spr_color_table
  CPU_SELECT_COLORLO_BANK 1
  CPU_INIT_COLORLO COLOR00,32
  CPU_SELECT_COLORLO_BANK 2
  CPU_INIT_COLORLO COLOR00,32
  CPU_SELECT_COLORLO_BANK 3
  CPU_INIT_COLORLO COLOR00,32
  CPU_SELECT_COLORLO_BANK 4
  CPU_INIT_COLORLO COLOR00,32
  CPU_SELECT_COLORLO_BANK 5
  CPU_INIT_COLORLO COLOR00,32
  CPU_SELECT_COLORLO_BANK 6
  CPU_INIT_COLORLO COLOR00,32
  CPU_SELECT_COLORLO_BANK 7
  CPU_INIT_COLORLO COLOR00,32
  rts


; ** 1. Copperliste initialisieren **
; -----------------------------------
  CNOP 0,4
init_first_copperlist
  move.l  cl1_display(a3),a0
  bsr.s   cl1_init_playfield_registers
  bsr     cl1_init_sprite_pointers
  bsr     cl1_init_bitplane_pointers
  bsr     cl1_init_branches_pointers1
  bsr     cl1_init_branches_pointers2
  bsr     cl1_reset_pointer
  bsr     cl1_init_copint
  COPLISTEND
  bra     cl1_set_sprite_pointers

  COP_INIT_PLAYFIELD_REGISTERS cl1

  COP_INIT_SPRITE_POINTERS cl1

  COP_INIT_BITPLANE_POINTERS cl1

  CNOP 0,4
cl1_init_branches_pointers1
  move.l  #(((cl1_VSTART1<<24)+(((cl1_HSTART1/4)*2)<<16))|$10000)|$fffe,d0 ;WAIT-Befehl
  move.l  cl1_display(a3),d1
  add.l   #cl1_extension1_entry+cl1_ext1_subextension1_entry+cl1_subextension1_SIZE,d1
  moveq   #1,d2
  ror.l   #8,d2              ;$01000000 = Additionswert
  move.l  cl2_display(a3),d4
  swap    d4                 ;High-Wert
  move.w  #COP2LCH,(a0)+
  moveq   #cl1_subextension1_SIZE,d3
  move.w  d4,(a0)+
  swap    d4                 ;Low-Wert
  move.w  #COP2LCL,(a0)+
  move.w  d4,(a0)+
  MOVEF.W cl1_display_y_size1-1,d7 ;Anzahl der Zeilen
cl1_init_branches_pointers1_loop
  move.l  d0,(a0)+           ;WAIT x,y
  swap    d1                 ;High-Wert
  move.w  #COP1LCH,(a0)+
  add.l   d2,d0              ;nächste Zeile
  move.w  d1,(a0)+
  swap    d1                 ;Low-Wert
  move.w  #COP1LCL,(a0)+
  move.w  d1,(a0)+
  add.l   d3,d1              ;Einsprungadresse CL1 erhöhen
  COPMOVEQ TRUE,COPJMP2
  dbf     d7,cl1_init_branches_pointers1_loop
  rts

  CNOP 0,4
cl1_init_branches_pointers2
  move.l  #(((cl1_VSTART2<<24)+(((cl1_HSTART2/4)*2)<<16))|$10000)|$fffe,d0 ;WAIT-Befehl
  move.l  cl1_display(a3),d1
  add.l   #cl1_extension2_entry+cl1_ext2_subextension1_entry+cl1_subextension1_SIZE,d1
  moveq   #1,d2
  ror.l   #8,d2              ;$01000000 = Additionswert
  move.l  cl2_display(a3),d4
  add.l   #cl2_extension2_entry,d4
  swap    d4                 ;High-Wert
  move.w  #COP2LCH,(a0)+
  moveq   #cl1_subextension1_SIZE,d3
  move.w  d4,(a0)+
  swap    d4                 ;Low-Wert
  move.w  #COP2LCL,(a0)+
  move.w  d4,(a0)+
  MOVEF.W cl1_display_y_size2-1,d7 ;Anzahl der Zeilen
cl1_init_branches_pointers2_loop
  move.l  d0,(a0)+           ;WAIT x,y
  swap    d1                 ;High-Wert
  move.w  #COP1LCH,(a0)+
  add.l   d2,d0              ;nächste Zeile
  move.w  d1,(a0)+
  swap    d1                 ;Low-Wert
  move.w  #COP1LCL,(a0)+
  move.w  d1,(a0)+
  add.l   d3,d1              ;Einsprungadresse CL1 erhöhen
  COPMOVEQ TRUE,COPJMP2
  dbf     d7,cl1_init_branches_pointers2_loop
  rts

  CNOP 0,4
cl1_reset_pointer
  move.l  cl1_display(a3),d0
  swap    d0                 ;High-Wert
  move.w  #COP1LCH,(a0)+
  move.w  d0,(a0)+
  swap    d0                 ;Low-Wert
  move.w  #COP1LCL,(a0)+
  move.w  d0,(a0)+
  rts

  COP_INIT_COPINT cl1,cl1_HSTART3,cl1_VSTART3,YWRAP

  COP_SET_SPRITE_POINTERS cl1,display,spr_number

; ** 2. Copperliste initialisieren **
; -----------------------------------
  CNOP 0,4
init_second_copperlist
  move.l  cl2_display(a3),a0
  bsr.s   cl2_init_BPLCON4_registers1
  bra.s   cl2_init_BPLCON4_registers2

  CNOP 0,4
cl2_init_BPLCON4_registers1
  move.l  #(BPLCON4<<16)+BPLCON4BITS,d0
  moveq  #cl2_display_width1-1,d7 ;Anzahl der Spalten
cl2_init_BPLCON4_registers1_loop
  move.l  d0,(a0)+           ;BPLCON4
  dbf     d7,cl2_init_BPLCON4_registers1_loop
  COPMOVEQ TRUE,COPJMP1
  rts

  CNOP 0,4
cl2_init_BPLCON4_registers2
  move.l  #(BPLCON4<<16)+BPLCON4BITS,d0
  moveq  #cl2_display_width2-1,d7 ;Anzahl der Spalten
cl2_init_BPLCON4_registers2_loop
  move.l  d0,(a0)+           ;BPLCON4
  dbf     d7,cl2_init_BPLCON4_registers2_loop
  COPMOVEQ TRUE,COPJMP1
  rts


; ** CIA-Timer starten **
; -----------------------

  INCLUDE "continuous-timers-start.i"


; ## Hauptprogramm ##
; -------------------
; a3 ... Basisadresse aller Variablen
; a4 ... CIA-A-Base
; a5 ... CIA-B-Base
; a6 ... DMACONR
  CNOP 0,4
main_routine
  bsr.s   no_sync_routines
  bra.s   beam_routines


; ## Routinen, die nicht mit der Bildwiederholfrequenz gekoppelt sind ##
; ----------------------------------------------------------------------
  CNOP 0,4
no_sync_routines
  rts


; ## Rasterstahl-Routinen ##
; --------------------------
  CNOP 0,4
beam_routines
  bsr     wait_copint
  bsr.s   swap_playfield1
  bsr     effects_handler
  bsr     horiz_fader_in1
  bsr     horiz_fader_in2
  bsr     horiz_fader_out1
  bsr     horiz_fader_out2
  bsr     gv_clear_playfield1
  bsr     gv_draw_lines
  bsr     gv_fill_playfield1
  bsr     gv_rotation
  bsr     scroll_playfield_bottom_in
  bsr     scroll_playfield_bottom_out
  bsr     mouse_handler
  tst.l   d0                 ;Abbruch ?
  bne.s   fast_exit          ;Ja -> verzweige
  tst.w   fx_state(a3)       ;Effekte beendet ?
  bne.s   beam_routines      ;Nein -> verzweige
fast_exit
  move.l  nop_second_copperlist,COP2LC-DMACONR(a6) ;2. Copperliste deaktivieren
  move.w  d0,COPJMP2-DMACONR(a6)
  move.l  nop_first_copperlist,COP1LC-DMACONR(a6) ;2. Copperliste deaktivieren
  move.w  d0,COPJMP1-DMACONR(a6)
  move.w  custom_error_code(a3),d1
  rts


; ** Playfields vertauschen **
; ------------------------
  SWAP_PLAYFIELD pf1,3,pf1_depth3


; ** Playfield löschen **
; ------------------
  CNOP 0,4
gv_clear_playfield1
  movem.l a3-a6,-(a7)
  move.l  a7,save_a7(a3)     ;Stackpointer retten
  moveq   #TRUE,d0
  moveq   #TRUE,d1
  moveq   #TRUE,d2
  moveq   #TRUE,d3
  moveq   #TRUE,d4
  moveq   #TRUE,d5
  moveq   #TRUE,d6
  move.l  d0,a0
  move.l  d0,a1
  move.l  d0,a2
  move.l  d0,a4
  move.l  d0,a5
  move.l  d0,a6
  move.l  pf1_construction1(a3),a7 ;Zeiger erste Plane
  move.l  (a7),a7
  ADDF.L  pf1_plane_width*pf1_y_size3*pf1_depth3,a7 ;Ende des Playfieldes
  move.l  d0,a3
  moveq   #4-1,d7            ;Anzahl der Durchläufe
gv_clear_playfield1_loop
  REPT ((pf1_plane_width*pf1_y_size3*pf1_depth3)/56)/4
    movem.l d0-d6/a0-a6,-(a7)  ;56 Bytes löschen
  ENDR
  dbf     d7,gv_clear_playfield1_loop
; Rest 160
  movem.l d0-d6/a0-a6,-(a7)
  movem.l d0-d6/a0-a6,-(a7)
  movem.l d0-d6/a0-a4,-(a7)
  move.l  variables+save_a7(pc),a7 ;Alter Stackpointer
  movem.l (a7)+,a3-a6
  rts

; ** 3D-Rotation **
; -----------------
  CNOP 0,4
gv_rotation
  movem.l a4-a5,-(a7)
  move.w  gv_rotation_y_angle(a3),d1 ;Y-Winkel
  move.w  d1,d0              ;retten
  lea     sine_table(pc),a2  ;Sinus-Tabelle
  move.w  (a2,d0.w*2),d5     ;sin(b)
  IFEQ sine_table_length-512
    MOVEF.W sine_table_length-1,d3
  ELSE
    MOVEF.W sine_table_length,d3
  ENDC
  add.w   #sine_table_length/4,d0 ;+ 90 Grad
  swap    d5                 ;Bits 16-31 = sin(b)
  IFEQ sine_table_length-512
    and.w   d3,d0            ;Übertrag entfernen
  ELSE
    cmp.w   d3,d0            ;360 Grad erreicht ?
    blt.s   gv_rotation_no_y_angle_restart1
    sub.w   d3,d0            ;Neustart
gv_rotation_no_y_angle_restart1
  ENDC
  move.w  (a2,d0.w*2),d5     ;Bits  0-15 = cos(b)
  addq.w  #gv_rotation_y_angle_speed,d1 ;nächster Y-Winkel
  IFEQ sine_table_length-512
    and.w   d3,d1            ;Übertrag entfernen
  ELSE
    cmp.w   d3,d1            ;360 Grad erreicht ?
    blt.s   gv_rotation_no_y_angle_restart2
    sub.w   d3,d1            ;Neustart
gv_rotation_no_y_angle_restart2
  ENDC
  move.w  d1,gv_rotation_y_angle(a3) ;Y-Winkel retten
  lea     gv_object_coordinates(pc),a0 ;Koordinaten der Linien
  lea     gv_rotation_xy_coordinates(pc),a1 ;Koord.-Tab.
  move.w  #gv_rotation_d*8,a4 ;d
  move.w  #gv_rotation_xy_center,a5 ;X+Y-Mittelpunkt
  moveq   #gv_object_edge_points_number-1,d7 ;Anzahl der Punkte
gv_rotation_loop
  move.w  (a0)+,d0           ;X-Koord.
  move.l  d7,a2              ;Schleifenzähler retten
  move.w  (a0)+,d1           ;Y-Koord.
  move.w  (a0)+,d2           ;Z-Koord.
  ROTATE_Y_AXIS
; ** Zentralprojektion und Translation **
  MULSF.W gv_rotation_d,d0,d3 ;x*d  X-Projektion
  add.w   a4,d2              ;z+d
  divs.w  d2,d0              ;x' = (x*d)/(z+d)
  MULSF.W gv_rotation_d,d1,d3 ;y*d  Y-Projektion
  add.w   a5,d0              ;x' + X-Mittelpunkt
  move.w  d0,(a1)+           ;X-Pos.
  divs.w  d2,d1              ;y' = (y*d)/(z+d)
  move.l  a2,d7              ;Schleifenzähler holen
  add.w   a5,d1              ;y' + Y-Mittelpunkt
  move.w  d1,(a1)+           ;Y-Pos.
  dbf     d7,gv_rotation_loop
  movem.l (a7)+,a4-a5
  rts

; ** Linien ziehen **
; -------------------
  CNOP 0,4
gv_draw_lines
  movem.l a3-a5,-(a7)
  bsr     gv_draw_lines_init
  lea     gv_object_info_table(pc),a0 ;Zeiger auf Info-Daten zum Objekt
  lea     gv_rotation_xy_coordinates(pc),a1   ;Zeiger auf XY-Koordinaten
  move.l  pf1_construction2(a3),a2
  move.l  (a2),a2
  move.l  #((BC0F_SRCA+BC0F_SRCC+BC0F_DEST+NANBC+NABC+ABNC)<<16)+(BLTCON1F_LINE+BLTCON1F_SING),a3
  move.w  #pf1_plane_width,a4
  moveq   #gv_object_faces_number-1,d7 ;Anzahl der Flächen
gv_draw_lines_loop1
; ** Z-Koordinate des Vektors N durch das Kreuzprodukt u x v berechnen **
  move.l  (a0)+,a5           ;Zeiger auf Startwerte der Punkte
  swap    d7                 ;Flächenzähler retten
  move.w  (a5),d4            ;P1-Startwert
  move.w  2(a5),d5           ;P2-Startwert
  move.w  4(a5),d6           ;P3-Startwert
  movem.w (a1,d5.w*2),d0-d1  ;P2(x,y)
  movem.w (a1,d6.w*2),d2-d3  ;P3(x,y)
  sub.w   d0,d2              ;xv = xp3-xp2
  sub.w   (a1,d4.w*2),d0     ;xu = xp2-xp1
  sub.w   d1,d3              ;yv = yp3-yp2
  sub.w   2(a1,d4.w*2),d1    ;yu = yp2-yp1
  muls.w  d3,d0              ;xu*yv
  move.w  (a0)+,d7           ;Farbe der Fläche
  muls.w  d2,d1              ;yu*xv
  move.w  (a0)+,d6           ;Anzahl der Linien
  sub.l   d0,d1              ;zn = (yu*xv)-(xu*yv)
  bmi.s   gv_draw_lines_loop2 ;Wenn zn negativ -> verzweige
  lsr.w   #2,d7              ;COLOR02/04 -> COLOR00/01
  beq     gv_draw_lines_no_face ;Wenn COLOR00 -> verzweige
gv_draw_lines_loop2
  move.w  (a5)+,d0           ;Startwerte der Punkte P1,P2
  move.w  (a5),d2
  movem.w (a1,d0.w*2),d0-d1  ;P1(x,y)
  movem.w (a1,d2.w*2),d2-d3  ;P2(x,y)
  GET_LINE_PARAMETERS gv,AREAFILL
  add.l   a3,d0              ;restliche BLTCON0 & BLTCON1-Bits setzen
  add.l   a2,d1              ;+ Playfieldadresse
  cmp.w   #1,d7              ;Plane 1 ?
  beq.s   gv_draw_lines_single_line ;Ja -> verzweige
  add.l   a4,d1              ;nächste Plane
  cmp.w   #2,d7              ;Plane 2 ?
  beq.s   gv_draw_lines_single_line ;Ja -> verzweige
  add.l   a4,d1              ;nächste Plane
gv_draw_lines_single_line
  WAITBLITTER
  move.l  d0,BLTCON0-DMACONR(a6) ;Bits 31-15: BLTCON0, Bits 16-0: BLTCON1
  move.l  d1,BLTCPT-DMACONR(a6) ;Playfield lesen
  move.w  d3,BLTAPTL-DMACONR(a6) ;(4*dy)-(2*dx)
  move.l  d1,BLTDPT-DMACONR(a6) ;Playfield schreiben
  move.l  d4,BLTBMOD-DMACONR(a6) ;Bits 31-16: 4*dy, Bits 15-0: 4*(dy-dx)
  move.w  d2,BLTSIZE-DMACONR(a6) ;Blitter starten
gv_draw_lines_no_line
  dbf     d6,gv_draw_lines_loop2
gv_draw_lines_no_face
  swap    d7                 ;Flächenzähler holen
  dbf     d7,gv_draw_lines_loop1
  movem.l (a7)+,a3-a5
  rts
  CNOP 0,4
gv_draw_lines_init
  move.w  #DMAF_BLITHOG+DMAF_SETCLR,DMACON-DMACONR(a6) ;BLTPRI an
  WAITBLITTER
  move.l  #$ffff8000,BLTBDAT-DMACONR(a6) ;Bits 31-16: Linientextur, Bits 0-15: Linientextur mit MSB beginnen
  moveq   #FALSE,d0
  move.l  d0,BLTAFWM-DMACONR(a6) ;Keine Ausmaskierung
  moveq   #pf1_plane_width*pf1_depth3,d0 ;Moduli für Interleaved-Bitmaps
  move.w  d0,BLTCMOD-DMACONR(a6)
  move.w  d0,BLTDMOD-DMACONR(a6)
  rts

; ** Playfield füllen **
; -----------------
  CNOP 0,4
gv_fill_playfield1
  move.l  pf1_construction2(a3),a0 ;Playfield
  WAITBLITTER
  move.w  #DMAF_BLITHOG,DMACON-DMACONR(a6) ;BLTPRI aus
  move.l  (a0),a0
  ADDF.L  (pf1_plane_width*pf1_y_size3*pf1_depth3)-2,a0 ;Ende des Playfieldes
  move.l  #((BC0F_SRCA+BC0F_DEST+ANBNC+ANBC+ABNC+ABC)<<16)+(BLTCON1F_DESC+BLTCON1F_EFE),BLTCON0-DMACONR(a6) ;Minterm D=A, Füll-Modus, Rückwärts
  move.l  a0,BLTAPT-DMACONR(a6) ;Quelle
  move.l  a0,BLTDPT-DMACONR(a6) ;Ziel
  moveq   #TRUE,d0
  move.l  d0,BLTAMOD-DMACONR(a6) ;A+D-Mod
  move.w  #(gv_fill_blit_y_size*gv_fill_blit_depth*64)+(gv_fill_blit_x_size/16),BLTSIZE-DMACONR(a6)
  rts


; ** Playfield von unten einscrollen **
; -------------------------------------
  CNOP 0,4
scroll_playfield_bottom_in
  tst.w   spbi_state(a3)     ;Scroll-Playfield-Bottom-In an ?
  bne.s   no_scroll_playfield_bottom_in ;Nein -> verzweige
  move.w  spbi_y_angle(a3),d2 ;Y-Winkel holen
  cmp.w   #sine_table_length/4,d2 ;90 Grad ?
  bgt.s   spbi_finished      ;Ja -> verzweige
  lea     sine_table(pc),a0  
  move.w  (a0,d2.w*2),d0     ;sin(w)
  muls.w  #spb_y_radius*2,d0 ;y'=(sin(w)*yr)/2^15
  swap    d0
  add.w   #spb_y_centre,d0 ;y' + Y-Mittelpunkt
  addq.w  #spbi_y_angle_speed,d2 ;nächster Y-Winkel
  move.w  d2,spbi_y_angle(a3) ;Y-Winkel retten
  MOVEF.W spb_max_VSTOP,d3
  bsr.s   spb_set_display_window
no_scroll_playfield_bottom_in
  rts
  CNOP 0,4
spbi_finished
  moveq   #FALSE,d0
  move.w  d0,spbi_state(a3)  ;Scroll-Playfield-Bottom-In aus
  rts

; ** Playfield nach unten ausscrollen **
; --------------------------------------
  CNOP 0,4
scroll_playfield_bottom_out
  tst.w   spbo_state(a3)     ;Scroll-Playfild-Bottom-Out an ?
  bne.s   no_scroll_playfield_bottom_out ;Nein -> verzweige
  move.w  spbo_y_angle(a3),d2 ;Y-Winkel holen
  cmp.w   #sine_table_length/2,d2 ;180 Grad ?
  bgt.s   spbo_finished      ;Ja -> verzweige
  lea     sine_table(pc),a0  
  move.w  (a0,d2.w*2),d0     ;cos(w)
  muls.w  #spb_y_radius*2,d0 ;y'=(cos(w)*yr)/2^15
  swap    d0
  add.w   #spb_y_centre,d0 ;y' + Y-Mittelpunkt
  addq.w  #spbo_y_angle_speed,d2 ;nächster Y-Winkel
  move.w  d2,spbo_y_angle(a3) ;Y-Winkel retten
  MOVEF.W spb_max_VSTOP,d3
  bsr.s   spb_set_display_window
no_scroll_playfield_bottom_out
  rts
  CNOP 0,4
spbo_finished
  clr.w   fx_state(a3)       ;Effekte beendet
  moveq   #FALSE,d0
  move.w  d0,spbo_state(a3)  ;Scroll-Playfield-Bottom-Out aus
  rts

  CNOP 0,4
spb_set_display_window
  move.l  cl1_display(a3),a1
  moveq   #spb_min_VSTART,d1
  add.w   d0,d1              ;+ Y-Offset
  cmp.w   d3,d1              ;VSTOP-Maximum erreicht ?
  ble.s   spb_no_max_VSTOP1  ;Nein -> verzweige
  move.w  d3,d1              ;VSTOP korrigieren
spb_no_max_VSTOP1
  move.b  d1,cl1_DIWSTRT+2(a1) ;VSTART V7-V0
  move.w  d1,d2
  add.w   #visible_lines_number,d2 ;VSTOP
  cmp.w   d3,d2              ;VSTOP-Maximum erreicht ?
  ble.s   spb_no_max_VSTOP2 ;Nein -> verzweige
  move.w  d3,d2              ;VSTOP korrigieren
spb_no_max_VSTOP2
  move.b  d2,cl1_DIWSTOP+2(a1) ;VSTOP V7-V0
  lsr.w   #8,d1              ;VSTART V8-Bit in richtige Position bringen
  move.b  d1,d2              ;VSTART V8 + VSTOP V8
  or.w    #DIWHIGHBITS&(~(DIWHIGHF_VSTART8+DIWHIGHF_VSTOP8)),d2 ;restliche Bits
  move.w  d2,cl1_DIWHIGH+2(a1)
  rts

; ** Grafik horizontal einfaden **
; --------------------------------
  CNOP 0,4
horiz_fader_in1
  tst.w   hfi1_state(a3)     ;Horiz-Fader-In1 an ?
  bne.s   no_horiz_fader_in1 ;Nein -> vertweige
  move.w  hf1_switch_table_start(a3),d2 ;Startwert in Switchwert-Tabelle
  move.w  d2,d0
  cmp.w   #cl2_display_width1+hf_colorbanks_number-1,d0 ;Tabellenende ?
  bge.s   hfi1_finished      ;Ja -> verzweige
  addq.w  #1,d2              ;nächster Eintrag
  move.w  d2,hf1_switch_table_start(a3)
  lea     hf_switch_table(pc),a0 ;Zeiger auf Switchwert-Tabelle
  lea     (a0,d0.w),a0       ;Offset bestimmen
  move.l  cl2_display(a3),a1
  ADDF.W  cl2_extension1_entry+cl2_ext1_BPLCON4_24+3,a1
  MOVEF.W cl2_display_width1-1,d7
horiz_fader_in1_loop
  move.b  (a0)+,d0
  move.b  d0,d1              ;Switchwert für gerade und ungerade Sprites
  lsr.b   #4,d1
  or.b    d1,d0
  move.b  d0,(a1)            ;Switchwert kopieren
  subq.w  #4,a1              ;nächste Spalte in CL
  dbf     d7,horiz_fader_in1_loop
no_horiz_fader_in1
  rts
  CNOP 0,4
hfi1_finished
  moveq   #FALSE,d0
  move.w  d0,hfi1_state(a3)  ;Horiz-Fader-In1 aus
  rts

; ** Playfield horizontal einfaden **
; -----------------------------------
  CNOP 0,4
horiz_fader_in2
  tst.w   hfi2_state(a3)     ;Horiz-Fader-In1 an ?
  bne.s   no_horiz_fader_in2 ;Nein -> verzweige
  move.w  hf2_switch_table_start(a3),d2 ;Startwert in Switchwert-Tabelle
  move.w  d2,d0
  cmp.w   #cl2_display_width2+hf_colorbanks_number-1,d0 ;Tabellenende ?
  bge.s   hfi2_finished      ;Ja -> verzweige
  addq.w  #1,d2              ;nächster Eintrag
  move.w  d2,hf2_switch_table_start(a3)
  lea     hf_switch_table(pc),a0 ;Zeiger auf Switchwert-Tabelle
  lea     (a0,d0.w),a0       ;Offset bestimmen
  move.l  cl2_display(a3),a1
  ADDF.W  cl2_extension2_entry+cl2_ext2_BPLCON4_24+3,a1
  MOVEF.W cl2_display_width2-1,d7
horiz_fader_in2_loop
  move.b  (a0)+,d0
  move.b  d0,d1              ;Switchwert für gerade und ungerade Sprites
  lsr.b   #4,d1
  or.b    d1,d0
  move.b  d0,(a1)            ;Switchwert kopieren
  subq.w  #4,a1              ;nächste Spalte in CL
  dbf     d7,horiz_fader_in2_loop
no_horiz_fader_in2
  rts
  CNOP 0,4
hfi2_finished
  moveq   #FALSE,d0
  move.w  d0,hfi2_state(a3)  ;Horiz-Fader-In2 aus
  rts

; ** Grafik horizontal ausfaden **
; --------------------------------
  CNOP 0,4
horiz_fader_out1
  tst.w   hfo1_state(a3)     ;Horiz-Fader-Out1 an ?
  bne.s   no_horiz_fader_out1 ;Nein ->verzweige
  move.w  hf1_switch_table_start(a3),d2 ;Startwert in Switchwert-Tabelle
  move.w  d2,d0
  bmi.s   hfo1_finished      ;Wenn Tabellenanfang -> verzweige
  subq.w  #1,d2              ;vorheriger Eintrag
  move.w  d2,hf1_switch_table_start(a3)
  lea     hf_switch_table(pc),a0 ;Zeiger auf Switchwert-Tabelle
  lea     (a0,d0.w),a0       ;Offset bestimmen
  move.l  cl2_display(a3),a1
  ADDF.W  cl2_extension1_entry+3,a1
  MOVEF.W cl2_display_width1-1,d7
horiz_fader_out1_loop
  move.b  (a0)+,d0
  move.b  d0,d1              ;Switchwert für gerade und ungerade Sprites
  lsr.b   #4,d1
  or.b    d1,d0
  move.b  d0,(a1)            ;Switchwert kopieren
  addq.w  #4,a1              ;nächste Spalte in CL
  dbf     d7,horiz_fader_out1_loop
no_horiz_fader_out1
  rts
  CNOP 0,4
hfo1_finished
  moveq   #FALSE,d0
  move.w  d0,hfo1_state(a3)  ;Horiz-Fader-Out1 aus
  rts

; ** Playfield horizontal ausfaden **
; -----------------------------------
  CNOP 0,4
horiz_fader_out2
  tst.w   hfo2_state(a3)     ;Horiz-Fader-Out2 an ?
  bne.s   no_horiz_fader_out2 ;Nein ->verzweige
  move.w  hf2_switch_table_start(a3),d2 ;Startwert in Switchwert-Tabelle
  move.w  d2,d0
  bmi.s   hfo2_finished      ;Wenn Tabellenanfang -> verzweige
  subq.w  #1,d2              ;vorheriger Eintrag
  move.w  d2,hf2_switch_table_start(a3)
  lea     hf_switch_table(pc),a0 ;Zeiger auf Switchwert-Tabelle
  lea     (a0,d0.w),a0       ;Offset bestimmen
  move.l  cl2_display(a3),a1
  ADDF.W  cl2_extension2_entry+3,a1
  MOVEF.W cl2_display_width2-1,d7
horiz_fader_out2_loop
  move.b  (a0)+,d0
  move.b  d0,d1              ;Switchwert für gerade und ungerade Sprites
  lsr.b   #4,d1
  or.b    d1,d0
  move.b  d0,(a1)            ;Switchwert kopieren
  addq.w  #4,a1              ;nächste Spalte in CL
  dbf     d7,horiz_fader_out2_loop
no_horiz_fader_out2
  rts
  CNOP 0,4
hfo2_finished
  moveq   #FALSE,d0
  move.w  d0,hfo2_state(a3)  ;Horiz-Fader-Out2 aus
  rts


; ** SOFTINT-Interrupts abfragen **
; ---------------------------------
  CNOP 0,4
effects_handler
  moveq   #INTF_SOFTINT,d1
  and.w   INTREQR-DMACONR(a6),d1   ;Wurde der SOFTINT-Interrupt gesetzt ?
  beq.s   no_check_effects_trigger ;Nein -> verzweige
  addq.w  #1,eh_trigger_number(a3) ;FX-Trigger-Zähler hochsetzen
  move.w  eh_trigger_number(a3),d0 ;FX-Trigger-Zähler holen
  cmp.w   #eh_trigger_number_max,d0 ;Maximalwert bereits erreicht ?
  bgt.s   no_check_effects_trigger ;Ja -> verzweige
  move.w  d1,INTREQ-DMACONR(a6) ;SOFTINT-Interrupt löschen
  subq.w  #1,d0
  beq.s   eh_start_scroll_playfield_bottom_in
  subq.w  #1,d0
  beq.s   eh_start_horiz_fader_in1
  subq.w  #1,d0
  beq.s   eh_start_horiz_fader_in2
  subq.w  #1,d0
  beq.s   eh_start_horiz_fader_out
  subq.w  #1,d0
  beq.s   eh_start_scroll_playfield_bottom_out
no_check_effects_trigger
  rts
  CNOP 0,4
eh_start_scroll_playfield_bottom_in
  clr.w   spbi_state(a3)     :Scroll-Playfield-Bottom-In an
  rts
  CNOP 0,4
eh_start_horiz_fader_in1
  clr.w   hfi1_state(a3)      ;Horiz-Fader-In1 an
  rts
  CNOP 0,4
eh_start_horiz_fader_in2
  clr.w   hfi2_state(a3)      ;Horiz-Fader-In2 an
  rts
  CNOP 0,4
eh_start_horiz_fader_out
  moveq   #TRUE,d0
  move.w  d0,hfo1_state(a3)  ;Horiz-Fader-Out1 an
  move.w  d0,hfo2_state(a3)  ;Horiz-Fader-Out2 an
  rts
  CNOP 0,4
eh_start_scroll_playfield_bottom_out
  clr.w   spbo_state(a3)     :Scroll-Playfield-Bottom-Out an
  rts

; ** Mouse-Handler **
; -------------------
  CNOP 0,4
mouse_handler
  btst    #CIAB_GAMEPORT0,CIAPRA(a4) ;Linke Maustaste gedrückt ?
  beq.s   mh_quit            ;Ja -> verzweige
  moveq   #RETURN_OK,d0
  rts
  CNOP 0,4
mh_quit
  moveq   #RETURN_WARN,d0    ;Abbruch
  rts


; ## Interrupt-Routinen ##
; ------------------------

  INCLUDE "int-autovectors-handlers.i"

; ** Level-7-Interrupt-Server **
; ------------------------------
  CNOP 0,4
NMI_int_server
  rts


; ** Timer stoppen **
; -------------------

  INCLUDE "continuous-timers-stop.i"


; ## System wieder in Ausganszustand zurücksetzen ##
; --------------------------------------------------

  INCLUDE "sys-return.i"


; ## Hilfsroutinen ##
; -------------------

  INCLUDE "help-routines.i"


; ## Speicherstellen für Tabellen und Strukturen ##
; -------------------------------------------------

  INCLUDE "sys-structures.i"

; ** Farben des ersten Playfields **
; ----------------------------------
  CNOP 0,4
pf1_color_table
  REPT 8 ;pf1_colors_number
    DC.L COLOR00BITS
  ENDR

; ** Farben der Sprites **
; ------------------------
spr_color_table
  REPT hf_colors_per_colorbank
    DC.L COLOR00BITS
  ENDR
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/192x39x4-Superglenz.ct"
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/192x39x4-Superglenz.ct"
  REPT 8
    DC.L COLOR00BITS
  ENDR
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/192x39x4-Superglenz.ct"
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/192x39x4-Superglenz.ct"
  REPT 8
    DC.L COLOR00BITS
  ENDR
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/192x39x4-Superglenz.ct"
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/192x39x4-Superglenz.ct"
  REPT 8
    DC.L COLOR00BITS
  ENDR
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/192x39x4-Superglenz.ct"
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/192x39x4-Superglenz.ct"
  REPT 8
    DC.L COLOR00BITS
  ENDR
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/192x39x4-Superglenz.ct"
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/192x39x4-Superglenz.ct"
  REPT 8
    DC.L COLOR00BITS
  ENDR
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/192x39x4-Superglenz.ct"
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/192x39x4-Superglenz.ct"
  REPT 8
    DC.L COLOR00BITS
  ENDR
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/192x39x4-Superglenz.ct"
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/192x39x4-Superglenz.ct"
  REPT 8
    DC.L COLOR00BITS
  ENDR
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/192x39x4-Superglenz.ct"
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/192x39x4-Superglenz.ct"
  REPT 8
    DC.L COLOR00BITS
  ENDR
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/192x39x4-Superglenz.ct"
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/192x39x4-Superglenz.ct"
  REPT 8
    DC.L COLOR00BITS
  ENDR
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/192x39x4-Superglenz.ct"
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/192x39x4-Superglenz.ct"
  REPT 8
    DC.L COLOR00BITS
  ENDR
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/192x39x4-Superglenz.ct"
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/192x39x4-Superglenz.ct"
  REPT 8
    DC.L COLOR00BITS
  ENDR
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/192x39x4-Superglenz.ct"
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/192x39x4-Superglenz.ct"
  REPT 8
    DC.L COLOR00BITS
  ENDR
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/192x39x4-Superglenz.ct"
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/192x39x4-Superglenz.ct"
  REPT 8
    DC.L COLOR00BITS
  ENDR
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/192x39x4-Superglenz.ct"
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/192x39x4-Superglenz.ct"
  REPT 8
    DC.L COLOR00BITS
  ENDR

; ** Adressen der Sprites **
; --------------------------
spr_pointers_display
  DS.L spr_number

; ** Sinus / Cosinustabelle **
; ----------------------------
  CNOP 0,2
sine_table
  IFEQ sine_table_length-512
    INCLUDE "sine-table-512x16.i"
  ELSE
    INCLUDE "sine-table-360x16.i"
  ENDC

; **** Morph-Glenz-Vectors ****
; ** Farben der Glenz-Objekte **
  CNOP 0,4
gv_glenz_color_table
  INCLUDE "Blitter.AGA:Grafik/1xGlenz-Colorgradient5.ct"

; ** Objektdaten **
; -----------------
  CNOP 0,2
gv_object_coordinates
; ** Diamant
  DC.W 0,-(36*8),0             ;P0
  DC.W -(19*8),-(36*8),-(48*8) ;P1
  DC.W 19*8,-(36*8),-(48*8)    ;P2
  DC.W 48*8,-(36*8),-(19*8)    ;P3
  DC.W 48*8,-(36*8),19*8       ;P4
  DC.W 19*8,-(36*8),48*8       ;P5
  DC.W -(19*8),-(36*8),48*8    ;P6
  DC.W -(48*8),-(36*8),19*8    ;P7
  DC.W -(48*8),-(36*8),-(19*8) ;P8
  DC.W 0,-(24*8),-(58*8)       ;P9
  DC.W 40*8,-(24*8),-(40*8)    ;P10
  DC.W 58*8,-(24*8),0          ;P11
  DC.W 40*8,-(24*8),40*8       ;P12
  DC.W 0,-(24*8),58*8          ;P13
  DC.W -(40*8),-(24*8),40*8    ;P14
  DC.W -(58*8),-(24*8),0       ;P15
  DC.W -(40*8),-(24*8),-(40*8) ;P16
  DC.W -(27*8),-(12*8),-(68*8) ;P17
  DC.W 27*8,-(12*8),-(68*8)    ;P18
  DC.W 68*8,-(12*8),-(27*8)    ;P19
  DC.W 68*8,-(12*8),27*8       ;P20
  DC.W 27*8,-(12*8),68*8       ;P21
  DC.W -(27*8),-(12*8),68*8    ;P22
  DC.W -(68*8),-(12*8),27*8    ;P23
  DC.W -(68*8),-(12*8),-(27*8) ;P24
  DC.W 0,48*8,0                ;P25

; ** Information über Objekt **
; -----------------------------
  CNOP 0,4
gv_object_info_table
; ** 1. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face1_color ;Farbe der Fläche
  DC.W gv_object_face1_lines_number-1 ;Anzahl der Linien
; ** 2. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face2_color ;Farbe der Fläche
  DC.W gv_object_face2_lines_number-1 ;Anzahl der Linien
; ** 3. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face3_color ;Farbe der Fläche
  DC.W gv_object_face3_lines_number-1 ;Anzahl der Linien
; ** 4. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face4_color ;Farbe der Fläche
  DC.W gv_object_face4_lines_number-1 ;Anzahl der Linien
; ** 5. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face5_color ;Farbe der Fläche
  DC.W gv_object_face5_lines_number-1 ;Anzahl der Linien
; ** 6. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face6_color ;Farbe der Fläche
  DC.W gv_object_face6_lines_number-1 ;Anzahl der Linien
; ** 7. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face7_color ;Farbe der Fläche
  DC.W gv_object_face7_lines_number-1 ;Anzahl der Linien
; ** 8. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face8_color ;Farbe der Fläche
  DC.W gv_object_face8_lines_number-1 ;Anzahl der Linien

; ** 9. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face9_color ;Farbe der Fläche
  DC.W gv_object_face9_lines_number-1 ;Anzahl der Linien
; ** 10. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face10_color ;Farbe der Fläche
  DC.W gv_object_face10_lines_number-1 ;Anzahl der Linien
; ** 11. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face11_color ;Farbe der Fläche
  DC.W gv_object_face11_lines_number-1 ;Anzahl der Linien
; ** 12. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face12_color ;Farbe der Fläche
  DC.W gv_object_face12_lines_number-1 ;Anzahl der Linien

; ** 13. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face13_color ;Farbe der Fläche
  DC.W gv_object_face13_lines_number-1 ;Anzahl der Linien
; ** 14. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face14_color ;Farbe der Fläche
  DC.W gv_object_face14_lines_number-1 ;Anzahl der Linien
; ** 15. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face15_color ;Farbe der Fläche
  DC.W gv_object_face15_lines_number-1 ;Anzahl der Linien
; ** 16. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face16_color ;Farbe der Fläche
  DC.W gv_object_face16_lines_number-1 ;Anzahl der Linien

; ** 17. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face17_color ;Farbe der Fläche
  DC.W gv_object_face17_lines_number-1 ;Anzahl der Linien
; ** 18. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face18_color ;Farbe der Fläche
  DC.W gv_object_face18_lines_number-1 ;Anzahl der Linien
; ** 19. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face19_color ;Farbe der Fläche
  DC.W gv_object_face19_lines_number-1 ;Anzahl der Linien
; ** 20. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face20_color ;Farbe der Fläche
  DC.W gv_object_face20_lines_number-1 ;Anzahl der Linien

; ** 21. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face21_color ;Farbe der Fläche
  DC.W gv_object_face21_lines_number-1 ;Anzahl der Linien
; ** 22. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face22_color ;Farbe der Fläche
  DC.W gv_object_face22_lines_number-1 ;Anzahl der Linien
; ** 23. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face23_color ;Farbe der Fläche
  DC.W gv_object_face23_lines_number-1 ;Anzahl der Linien
; ** 24. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face24_color ;Farbe der Fläche
  DC.W gv_object_face24_lines_number-1 ;Anzahl der Linien

; ** 25. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face25_color ;Farbe der Fläche
  DC.W gv_object_face25_lines_number-1 ;Anzahl der Linien
; ** 26. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face26_color ;Farbe der Fläche
  DC.W gv_object_face26_lines_number-1 ;Anzahl der Linien
; ** 27. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face27_color ;Farbe der Fläche
  DC.W gv_object_face27_lines_number-1 ;Anzahl der Linien
; ** 28. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face28_color ;Farbe der Fläche
  DC.W gv_object_face28_lines_number-1 ;Anzahl der Linien

; ** 29. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face29_color ;Farbe der Fläche
  DC.W gv_object_face29_lines_number-1 ;Anzahl der Linien
; ** 30. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face30_color ;Farbe der Fläche
  DC.W gv_object_face30_lines_number-1 ;Anzahl der Linien
; ** 31. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face31_color ;Farbe der Fläche
  DC.W gv_object_face31_lines_number-1 ;Anzahl der Linien
; ** 32. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face32_color ;Farbe der Fläche
  DC.W gv_object_face32_lines_number-1 ;Anzahl der Linien

; ** 33. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face33_color ;Farbe der Fläche
  DC.W gv_object_face33_lines_number-1 ;Anzahl der Linien
; ** 34. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face34_color ;Farbe der Fläche
  DC.W gv_object_face34_lines_number-1 ;Anzahl der Linien
; ** 35. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face35_color ;Farbe der Fläche
  DC.W gv_object_face35_lines_number-1 ;Anzahl der Linien
; ** 36. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face36_color ;Farbe der Fläche
  DC.W gv_object_face36_lines_number-1 ;Anzahl der Linien

; ** 37. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face37_color ;Farbe der Fläche
  DC.W gv_object_face37_lines_number-1 ;Anzahl der Linien
; ** 38. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face38_color ;Farbe der Fläche
  DC.W gv_object_face38_lines_number-1 ;Anzahl der Linien
; ** 39. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face39_color ;Farbe der Fläche
  DC.W gv_object_face39_lines_number-1 ;Anzahl der Linien
; ** 40. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face40_color ;Farbe der Fläche
  DC.W gv_object_face40_lines_number-1 ;Anzahl der Linien

; ** 41. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face41_color ;Farbe der Fläche
  DC.W gv_object_face41_lines_number-1 ;Anzahl der Linien
; ** 42. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face42_color ;Farbe der Fläche
  DC.W gv_object_face42_lines_number-1 ;Anzahl der Linien
; ** 43. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face43_color ;Farbe der Fläche
  DC.W gv_object_face43_lines_number-1 ;Anzahl der Linien
; ** 44. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face44_color ;Farbe der Fläche
  DC.W gv_object_face44_lines_number-1 ;Anzahl der Linien
; ** 45. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face45_color ;Farbe der Fläche
  DC.W gv_object_face45_lines_number-1 ;Anzahl der Linien
; ** 46. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face46_color ;Farbe der Fläche
  DC.W gv_object_face46_lines_number-1 ;Anzahl der Linien
; ** 47. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face47_color ;Farbe der Fläche
  DC.W gv_object_face47_lines_number-1 ;Anzahl der Linien
; ** 48. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W gv_object_face48_color ;Farbe der Fläche
  DC.W gv_object_face48_lines_number-1 ;Anzahl der Linien

  
; ** Eckpunkte der Flächen **
; ---------------------------
  CNOP 0,2
gv_object_edge_table
  DC.W 0*2,6*2,5*2,0*2       ;Fläche 5 oben, Dreieck 12 Uhr
  DC.W 0*2,5*2,4*2,0*2       ;Fläche 4 oben, Dreieck 1,5 Uhr
  DC.W 3*2,0*2,4*2,3*2       ;Fläche 3 oben, Dreieck 3 Uhr
  DC.W 0*2,3*2,2*2,0*2       ;Fläche 2 oben, Dreieck 4,5 Uhr
  DC.W 1*2,0*2,2*2,1*2       ;Fläche 1 oben, Dreieck 6 Uhr
  DC.W 1*2,8*2,0*2,1*2       ;Fläche 8 oben, Dreieck 7,5 Uhr
  DC.W 8*2,7*2,0*2,8*2       ;Fläche 7 oben, Dreieck 9 Uhr
  DC.W 0*2,7*2,6*2,0*2       ;Fläche 6 oben, Dreieck 10,5 Uhr

  DC.W 2*2,9*2,1*2,2*2       ;Fläche 9 vorne, Dreieck 12 Uhr
  DC.W 2*2,18*2,9*2,2*2      ;Fläche 12 vorne, Dreieck 3 Uhr
  DC.W 9*2,18*2,17*2,9*2     ;Fläche 11 vorne, Dreieck 6 Uhr
  DC.W 1*2,9*2,17*2,1*2      ;Fläche 10 vorne, Dreieck 9 Uhr

  DC.W 3*2,10*2,2*2,3*2      ;Fläche 13 vorne rechts, Dreieck 12 Uhr
  DC.W 19*2,10*2,3*2,19*2    ;Fläche 16 vorne rechts, Dreieck 3 Uhr
  DC.W 10*2,19*2,18*2,10*2   ;Fläche 15 vorne rechts, Dreieck 6 Uhr
  DC.W 2*2,10*2,18*2,2*2     ;Fläche 14 vorne rechts, Dreieck 9 Uhr

  DC.W 4*2,11*2,3*2,4*2      ;Fläche 17 rechts, Dreieck 12 Uhr
  DC.W 4*2,20*2,11*2,4*2     ;Fläche 20 rechts, Dreieck 3 Uhr
  DC.W 11*2,20*2,19*2,11*2   ;Fläche 19 rechts, Dreieck 6 Uhr
  DC.W 3*2,11*2,19*2,3*2     ;Fläche 18 rechts, Dreieck 9 Uhr

  DC.W 5*2,12*2,4*2,5*2      ;Fläche 21 hinten rechts, Dreieck 12 Uhr
  DC.W 5*2,21*2,12*2,5*2     ;Fläche 24 hinten rechts, Dreieck 3 Uhr
  DC.W 12*2,21*2,20*2,12*2   ;Fläche 23 hinten rechts, Dreieck 6 Uhr
  DC.W 12*2,20*2,4*2,12*2    ;Fläche 22 hinten rechts, Dreieck 9 Uhr

  DC.W 6*2,13*2,5*2,6*2      ;Fläche 25 hinten, Dreieck 12 Uhr
  DC.W 6*2,22*2,13*2,6*2     ;Fläche 28 hinten, Dreieck 3 Uhr
  DC.W 13*2,22*2,21*2,13*2   ;Fläche 27 hinten, Dreieck 6 Uhr
  DC.W 5*2,13*2,21*2,5*2     ;Fläche 26 hinten, Dreieck 9 Uhr

  DC.W 7*2,14*2,6*2,7*2      ;Fläche 29 hinten links, Dreieck 12 Uhr
  DC.W 7*2,23*2,14*2,7*2     ;Fläche 32 hinten links, Dreieck 3 Uhr
  DC.W 14*2,23*2,22*2,14*2   ;Fläche 31 hinten links, Dreieck 6 Uhr
  DC.W 6*2,14*2,22*2,6*2     ;Fläche 30 hinten links, Dreieck 9 Uhr

  DC.W 8*2,15*2,7*2,8*2      ;Fläche 33 links, Dreieck 12 Uhr
  DC.W 8*2,24*2,15*2,8*2     ;Fläche 36 links, Dreieck 3 Uhr
  DC.W 15*2,24*2,23*2,15*2   ;Fläche 35 links, Dreieck 6 Uhr
  DC.W 7*2,15*2,23*2,7*2     ;Fläche 34 links, Dreieck 9 Uhr

  DC.W 1*2,16*2,8*2,1*2      ;Fläche 37 vorne links, Dreieck 12 Uhr
  DC.W 1*2,17*2,16*2,1*2     ;Fläche 40 vorne links, Dreieck 3 Uhr
  DC.W 16*2,17*2,24*2,16*2   ;Fläche 39 vorne links, Dreieck 6 Uhr
  DC.W 8*2,16*2,24*2,8*2     ;Fläche 38 vorne links, Dreieck 9 Uhr

  DC.W 25*2,21*2,22*2,25*2   ;Fläche 45 unten, Dreieck 12 Uhr
  DC.W 25*2,20*2,21*2,25*2   ;Fläche 44 unten, Dreieck 1,5 Uhr
  DC.W 19*2,20*2,25*2,19*2   ;Fläche 43 unten, Dreieck 3 Uhr
  DC.W 18*2,19*2,25*2,18*2   ;Fläche 42 unten, Dreieck 4,5 Uhr
  DC.W 17*2,18*2,25*2,17*2   ;Fläche 41 unten, Dreieck 6 Uhr
  DC.W 17*2,25*2,24*2,17*2   ;Fläche 48 unten, Dreieck 7,5 Uhr
  DC.W 24*2,25*2,23*2,24*2   ;Fläche 47 unten, Dreieck 9 Uhr
  DC.W 25*2,22*2,23*2,25*2   ;Fläche 46 unten, Dreieck 10,5 Uhr

; ** Koordinaten der Linien **
; ----------------------------
gv_rotation_xy_coordinates
  DS.W gv_object_edge_points_number*2

; **** Horiz-Fader ****
; ** Von dunkel nach hell **
hf_switch_table
  REPT cl2_display_width1
    DC.B 256-(hf_colors_per_colorbank*15)
  ENDR
  DC.B 256-(hf_colors_per_colorbank*14)
  DC.B 256-(hf_colors_per_colorbank*13)
  DC.B 256-(hf_colors_per_colorbank*12)
  DC.B 256-(hf_colors_per_colorbank*11)
  DC.B 256-(hf_colors_per_colorbank*10)
  DC.B 256-(hf_colors_per_colorbank*9)
  DC.B 256-(hf_colors_per_colorbank*8)
  DC.B 256-(hf_colors_per_colorbank*7)
  DC.B 256-(hf_colors_per_colorbank*6)
  DC.B 256-(hf_colors_per_colorbank*5)
  DC.B 256-(hf_colors_per_colorbank*4)
  DC.B 256-(hf_colors_per_colorbank*3)
  DC.B 256-(hf_colors_per_colorbank*2)
  REPT cl2_display_width1
    DC.B 256-(hf_colors_per_colorbank*1)
  ENDR


; ## Speicherstellen allgemein ##
; -------------------------------

  INCLUDE "sys-variables.i"


; ## Speicherstellen für Namen ##
; -------------------------------

  INCLUDE "sys-names.i"


; ## Speicherstellen für Texte ##
; -------------------------------

  INCLUDE "error-texts.i"

; ** Programmversion für Version-Befehl **
; ----------------------------------------
prg_version DC.B "$VER: 00_Intro 1.0 (12.4.24)",TRUE
  EVEN


; ## Grafikdaten nachladen ##
; ---------------------------

; **** Title ****
title_image_data SECTION title_gfx,DATA
  INCBIN "Daten:Asm-Sources.AGA/Superglenz/graphics/192x39x4-Superglenz.rawblit"

; **** Logo ****
logo_image_data SECTION logo_gfx,DATA
  INCBIN "Daten:Asm-Sources.AGA/Superglenz/graphics/3x64x16x4-RSE.rawblit"

  END
