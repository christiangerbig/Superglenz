; #########################################
; # Programm: 014_Morph-Glenz-Vectors.asm #
; # Autor:    Christian Gerbig            #
; # Datum:    05.06.2024                  #
; # Version:  1.0                         #
; # CPU:      68020+                      #
; # FASTMEM:  -                           #
; # Chipset:  AGA                         #
; # OS:       3.0+                        #
; #########################################

; Morphendes 1x128-Flächen-Glenz auf einem 160x160-Screen.
; Der Copper wartet auf den Blitter. 
; Beam-Position-Timing wegen flexibler Ausführungszeit der Copperliste.
; Das Playfield ist auf 64 kB aligned damit Blitter-High-Pointer der
; Linien-Blits nur 1x initialisiert werden müssen.

  XDEF start_014_morph_glenz_vectors

  XREF v_BPLCON0BITS
  XREF v_BPLCON3BITS1
  XREF v_BPLCON3BITS2
  XREF v_BPLCON4BITS
  XREF v_FMODEBITS
  XREF COLOR00BITS
  XREF nop_second_copperlist
  XREF mouse_handler
  XREF sine_table

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

requires_68030                    EQU FALSE
requires_68040                    EQU FALSE
requires_68060                    EQU FALSE
requires_fast_memory              EQU FALSE
requires_multiscan_monitor        EQU FALSE

workbench_start                   EQU FALSE
workbench_fade                    EQU FALSE
text_output                       EQU FALSE

sys_taken_over
pass_global_references
pass_return_code

mgv_count_lines                   EQU FALSE
mgv_premorph_start_shape          EQU TRUE
mgv_morph_loop                    EQU FALSE

DMABITS                           EQU DMAF_BLITTER+DMAF_RASTER+DMAF_BLITHOG+DMAF_SETCLR

INTENABITS                        EQU INTF_SETCLR

CIAAICRBITS                       EQU CIAICRF_SETCLR
CIABICRBITS                       EQU CIAICRF_SETCLR

COPCONBITS                        EQU COPCONF_CDANG

pf1_x_size1                       EQU 192
pf1_y_size1                       EQU 160+911
pf1_depth1                        EQU 3
pf1_x_size2                       EQU 192
pf1_y_size2                       EQU 160+911
pf1_depth2                        EQU 3
pf1_x_size3                       EQU 192
pf1_y_size3                       EQU 160+911
pf1_depth3                        EQU 3
pf1_colors_number                 EQU 8

pf2_x_size1                       EQU 0
pf2_y_size1                       EQU 0
pf2_depth1                        EQU 0
pf2_x_size2                       EQU 0
pf2_y_size2                       EQU 0
pf2_depth2                        EQU 0
pf2_x_size3                       EQU 0
pf2_y_size3                       EQU 0
pf2_depth3                        EQU 0
pf2_colors_number                 EQU 0
pf_colors_number                  EQU pf1_colors_number+pf2_colors_number
pf_depth                          EQU pf1_depth3+pf2_depth3

extra_pf_number                   EQU 0

spr_number                        EQU 0
spr_x_size1                       EQU 0
spr_x_size2                       EQU 0
spr_depth                         EQU 0
spr_colors_number                 EQU 0

audio_memory_size                 EQU 0

disk_memory_size                  EQU 0

extra_memory_size                 EQU 0

chip_memory_size                  EQU 0

AGA_OS_Version                    EQU 39

CIAA_TA_value                     EQU 0
CIAA_TB_value                     EQU 0
CIAB_TA_value                     EQU 0
CIAB_TB_value                     EQU 0
CIAA_TA_continuous                EQU FALSE
CIAA_TB_continuous                EQU FALSE
CIAB_TA_continuous                EQU FALSE
CIAB_TB_continuous                EQU FALSE

beam_position                     EQU $135

pixel_per_line                    EQU 192
visible_pixels_number             EQU 160
visible_lines_number              EQU 160
MINROW                            EQU VSTOP_OVERSCAN_PAL

pf_pixel_per_datafetch            EQU 64 ;4x
DDFSTRTBITS                       EQU DDFSTART_192_pixel_4x
DDFSTOPBITS                       EQU DDFSTOP_192_pixel_4x

display_window_HSTART             EQU HSTART_160_pixel
display_window_VSTART             EQU MINROW
DIWSTRTBITS                       EQU ((display_window_VSTART&$ff)*DIWSTRTF_V0)+(display_window_HSTART&$ff)
display_window_HSTOP              EQU HSTOP_160_pixel
display_window_VSTOP              EQU VSTOP_OVERSCAN_PAL
DIWSTOPBITS                       EQU ((display_window_VSTOP&$ff)*DIWSTOPF_V0)+(display_window_HSTOP&$ff)

pf1_plane_width                   EQU pf1_x_size3/8
data_fetch_width                  EQU pixel_per_line/8
pf1_plane_moduli                  EQU (pf1_plane_width*(pf1_depth3-1))+pf1_plane_width-data_fetch_width

BPLCON0BITS                       EQU BPLCON0F_ECSENA+((pf_depth>>3)*BPLCON0F_BPU3)+(BPLCON0F_COLOR)+((pf_depth&$07)*BPLCON0F_BPU0) ;lores
BPLCON1BITS                       EQU $4400
BPLCON2BITS                       EQU TRUE
BPLCON3BITS1                      EQU TRUE
BPLCON3BITS2                      EQU BPLCON3BITS1+BPLCON3F_LOCT
BPLCON4BITS                       EQU TRUE
DIWHIGHBITS                       EQU (((display_window_HSTOP&$100)>>8)*DIWHIGHF_HSTOP8)+(((display_window_VSTOP&$700)>>8)*DIWHIGHF_VSTOP8)+(((display_window_HSTART&$100)>>8)*DIWHIGHF_HSTART8)+((display_window_VSTART&$700)>>8)
FMODEBITS                         EQU FMODEF_BPL32+FMODEF_BPAGEM

cl2_HSTART                        EQU $00
cl2_VSTART                        EQU beam_position&$ff

sine_table_length                 EQU 512

; **** Morph-Glenz-Vectors ****
mgv_rotation_d                    EQU 512
mgv_rotation_xy_center            EQU visible_lines_number/2

mgv_rotation_x_angle_speed_radius EQU 2
mgv_rotation_x_angle_speed_center EQU 3
mgv_rotation_x_angle_speed_speed  EQU 2

mgv_rotation_y_angle_speed_radius EQU 1
mgv_rotation_y_angle_speed_center EQU 2
mgv_rotation_y_angle_speed_speed  EQU 1

mgv_rotation_z_angle_speed_radius EQU 1
mgv_rotation_z_angle_speed_center EQU 2
mgv_rotation_z_angle_speed_speed  EQU 1

mgv_object_edge_points_number     EQU 66
mgv_object_edge_points_per_face   EQU 3
mgv_object_faces_number           EQU 128

mgv_object_face1_color            EQU 2
mgv_object_face1_lines_number     EQU 3
mgv_object_face2_color            EQU 4
mgv_object_face2_lines_number     EQU 3
mgv_object_face3_color            EQU 2
mgv_object_face3_lines_number     EQU 3
mgv_object_face4_color            EQU 4
mgv_object_face4_lines_number     EQU 3
mgv_object_face5_color            EQU 2
mgv_object_face5_lines_number     EQU 3
mgv_object_face6_color            EQU 4
mgv_object_face6_lines_number     EQU 3
mgv_object_face7_color            EQU 2
mgv_object_face7_lines_number     EQU 3
mgv_object_face8_color            EQU 4
mgv_object_face8_lines_number     EQU 3
mgv_object_face9_color            EQU 2
mgv_object_face9_lines_number     EQU 3
mgv_object_face10_color           EQU 4
mgv_object_face10_lines_number    EQU 3
mgv_object_face11_color           EQU 2
mgv_object_face11_lines_number    EQU 3
mgv_object_face12_color           EQU 4
mgv_object_face12_lines_number    EQU 3
mgv_object_face13_color           EQU 2
mgv_object_face13_lines_number    EQU 3
mgv_object_face14_color           EQU 4
mgv_object_face14_lines_number    EQU 3
mgv_object_face15_color           EQU 2
mgv_object_face15_lines_number    EQU 3
mgv_object_face16_color           EQU 4
mgv_object_face16_lines_number    EQU 3

mgv_object_face17_color           EQU 2
mgv_object_face17_lines_number    EQU 3
mgv_object_face18_color           EQU 4
mgv_object_face18_lines_number    EQU 3
mgv_object_face19_color           EQU 2
mgv_object_face19_lines_number    EQU 3

mgv_object_face20_color           EQU 4
mgv_object_face20_lines_number    EQU 3
mgv_object_face21_color           EQU 2
mgv_object_face21_lines_number    EQU 3
mgv_object_face22_color           EQU 4
mgv_object_face22_lines_number    EQU 3

mgv_object_face23_color           EQU 2
mgv_object_face23_lines_number    EQU 3
mgv_object_face24_color           EQU 4
mgv_object_face24_lines_number    EQU 3
mgv_object_face25_color           EQU 2
mgv_object_face25_lines_number    EQU 3

mgv_object_face26_color           EQU 4
mgv_object_face26_lines_number    EQU 3
mgv_object_face27_color           EQU 2
mgv_object_face27_lines_number    EQU 3
mgv_object_face28_color           EQU 4
mgv_object_face28_lines_number    EQU 3

mgv_object_face29_color           EQU 2
mgv_object_face29_lines_number    EQU 3
mgv_object_face30_color           EQU 4
mgv_object_face30_lines_number    EQU 3
mgv_object_face31_color           EQU 2
mgv_object_face31_lines_number    EQU 3

mgv_object_face32_color           EQU 4
mgv_object_face32_lines_number    EQU 3
mgv_object_face33_color           EQU 2
mgv_object_face33_lines_number    EQU 3
mgv_object_face34_color           EQU 4
mgv_object_face34_lines_number    EQU 3

mgv_object_face35_color           EQU 2
mgv_object_face35_lines_number    EQU 3
mgv_object_face36_color           EQU 4
mgv_object_face36_lines_number    EQU 3
mgv_object_face37_color           EQU 2
mgv_object_face37_lines_number    EQU 3

mgv_object_face38_color           EQU 4
mgv_object_face38_lines_number    EQU 3
mgv_object_face39_color           EQU 2
mgv_object_face39_lines_number    EQU 3
mgv_object_face40_color           EQU 4
mgv_object_face40_lines_number    EQU 3

mgv_object_face41_color           EQU 2
mgv_object_face41_lines_number    EQU 3
mgv_object_face42_color           EQU 4
mgv_object_face42_lines_number    EQU 3
mgv_object_face43_color           EQU 2
mgv_object_face43_lines_number    EQU 3

mgv_object_face44_color           EQU 4
mgv_object_face44_lines_number    EQU 3
mgv_object_face45_color           EQU 2
mgv_object_face45_lines_number    EQU 3
mgv_object_face46_color           EQU 4
mgv_object_face46_lines_number    EQU 3

mgv_object_face47_color           EQU 2
mgv_object_face47_lines_number    EQU 3
mgv_object_face48_color           EQU 4
mgv_object_face48_lines_number    EQU 3
mgv_object_face49_color           EQU 2
mgv_object_face49_lines_number    EQU 3

mgv_object_face50_color           EQU 4
mgv_object_face50_lines_number    EQU 3
mgv_object_face51_color           EQU 2
mgv_object_face51_lines_number    EQU 3
mgv_object_face52_color           EQU 4
mgv_object_face52_lines_number    EQU 3

mgv_object_face53_color           EQU 2
mgv_object_face53_lines_number    EQU 3
mgv_object_face54_color           EQU 4
mgv_object_face54_lines_number    EQU 3
mgv_object_face55_color           EQU 2
mgv_object_face55_lines_number    EQU 3

mgv_object_face56_color           EQU 4
mgv_object_face56_lines_number    EQU 3
mgv_object_face57_color           EQU 2
mgv_object_face57_lines_number    EQU 3
mgv_object_face58_color           EQU 4
mgv_object_face58_lines_number    EQU 3

mgv_object_face59_color           EQU 2
mgv_object_face59_lines_number    EQU 3
mgv_object_face60_color           EQU 4
mgv_object_face60_lines_number    EQU 3
mgv_object_face61_color           EQU 2
mgv_object_face61_lines_number    EQU 3

mgv_object_face62_color           EQU 4
mgv_object_face62_lines_number    EQU 3
mgv_object_face63_color           EQU 2
mgv_object_face63_lines_number    EQU 3
mgv_object_face64_color           EQU 4
mgv_object_face64_lines_number    EQU 3


mgv_object_face65_color           EQU 4
mgv_object_face65_lines_number    EQU 3
mgv_object_face66_color           EQU 2
mgv_object_face66_lines_number    EQU 3
mgv_object_face67_color           EQU 4
mgv_object_face67_lines_number    EQU 3

mgv_object_face68_color           EQU 2
mgv_object_face68_lines_number    EQU 3
mgv_object_face69_color           EQU 4
mgv_object_face69_lines_number    EQU 3
mgv_object_face70_color           EQU 2
mgv_object_face70_lines_number    EQU 3

mgv_object_face71_color           EQU 4
mgv_object_face71_lines_number    EQU 3
mgv_object_face72_color           EQU 2
mgv_object_face72_lines_number    EQU 3
mgv_object_face73_color           EQU 4
mgv_object_face73_lines_number    EQU 3

mgv_object_face74_color           EQU 2
mgv_object_face74_lines_number    EQU 3
mgv_object_face75_color           EQU 4
mgv_object_face75_lines_number    EQU 3
mgv_object_face76_color           EQU 2
mgv_object_face76_lines_number    EQU 3

mgv_object_face77_color           EQU 4
mgv_object_face77_lines_number    EQU 3
mgv_object_face78_color           EQU 2
mgv_object_face78_lines_number    EQU 3
mgv_object_face79_color           EQU 4
mgv_object_face79_lines_number    EQU 3

mgv_object_face80_color           EQU 2
mgv_object_face80_lines_number    EQU 3
mgv_object_face81_color           EQU 4
mgv_object_face81_lines_number    EQU 3
mgv_object_face82_color           EQU 2
mgv_object_face82_lines_number    EQU 3

mgv_object_face83_color           EQU 4
mgv_object_face83_lines_number    EQU 3
mgv_object_face84_color           EQU 2
mgv_object_face84_lines_number    EQU 3
mgv_object_face85_color           EQU 4
mgv_object_face85_lines_number    EQU 3

mgv_object_face86_color           EQU 2
mgv_object_face86_lines_number    EQU 3
mgv_object_face87_color           EQU 4
mgv_object_face87_lines_number    EQU 3
mgv_object_face88_color           EQU 2
mgv_object_face88_lines_number    EQU 3

mgv_object_face89_color           EQU 4
mgv_object_face89_lines_number    EQU 3
mgv_object_face90_color           EQU 2
mgv_object_face90_lines_number    EQU 3
mgv_object_face91_color           EQU 4
mgv_object_face91_lines_number    EQU 3

mgv_object_face92_color           EQU 2
mgv_object_face92_lines_number    EQU 3
mgv_object_face93_color           EQU 4
mgv_object_face93_lines_number    EQU 3
mgv_object_face94_color           EQU 2
mgv_object_face94_lines_number    EQU 3

mgv_object_face95_color           EQU 4
mgv_object_face95_lines_number    EQU 3
mgv_object_face96_color           EQU 2
mgv_object_face96_lines_number    EQU 3
mgv_object_face97_color           EQU 4
mgv_object_face97_lines_number    EQU 3

mgv_object_face98_color           EQU 2
mgv_object_face98_lines_number    EQU 3
mgv_object_face99_color           EQU 4
mgv_object_face99_lines_number    EQU 3
mgv_object_face100_color          EQU 2
mgv_object_face100_lines_number   EQU 3

mgv_object_face101_color          EQU 4
mgv_object_face101_lines_number   EQU 3
mgv_object_face102_color          EQU 2
mgv_object_face102_lines_number   EQU 3
mgv_object_face103_color          EQU 4
mgv_object_face103_lines_number   EQU 3

mgv_object_face104_color          EQU 2
mgv_object_face104_lines_number   EQU 3
mgv_object_face105_color          EQU 4
mgv_object_face105_lines_number   EQU 3
mgv_object_face106_color          EQU 2
mgv_object_face106_lines_number   EQU 3

mgv_object_face107_color          EQU 4
mgv_object_face107_lines_number   EQU 3
mgv_object_face108_color          EQU 2
mgv_object_face108_lines_number   EQU 3
mgv_object_face109_color          EQU 4
mgv_object_face109_lines_number   EQU 3

mgv_object_face110_color          EQU 2
mgv_object_face110_lines_number   EQU 3
mgv_object_face111_color          EQU 4
mgv_object_face111_lines_number   EQU 3
mgv_object_face112_color          EQU 2
mgv_object_face112_lines_number   EQU 3


mgv_object_face113_color          EQU 4
mgv_object_face113_lines_number   EQU 3

mgv_object_face114_color          EQU 2
mgv_object_face114_lines_number   EQU 3

mgv_object_face115_color          EQU 4
mgv_object_face115_lines_number   EQU 3

mgv_object_face116_color          EQU 2
mgv_object_face116_lines_number   EQU 3

mgv_object_face117_color          EQU 4
mgv_object_face117_lines_number   EQU 3

mgv_object_face118_color          EQU 2
mgv_object_face118_lines_number   EQU 3

mgv_object_face119_color          EQU 4
mgv_object_face119_lines_number   EQU 3

mgv_object_face120_color          EQU 2
mgv_object_face120_lines_number   EQU 3

mgv_object_face121_color          EQU 4
mgv_object_face121_lines_number   EQU 3

mgv_object_face122_color          EQU 2
mgv_object_face122_lines_number   EQU 3

mgv_object_face123_color          EQU 4
mgv_object_face123_lines_number   EQU 3

mgv_object_face124_color          EQU 2
mgv_object_face124_lines_number   EQU 3

mgv_object_face125_color          EQU 4
mgv_object_face125_lines_number   EQU 3

mgv_object_face126_color          EQU 2
mgv_object_face126_lines_number   EQU 3

mgv_object_face127_color          EQU 4
mgv_object_face127_lines_number   EQU 3

mgv_object_face128_color          EQU 2
mgv_object_face128_lines_number   EQU 3

mgv_lines_number_max              EQU 288
mgv_glenz_colors_number           EQU 4

  IFEQ mgv_morph_loop
mgv_morph_shapes_number           EQU 3
  ELSE
mgv_morph_shapes_number           EQU 4
  ENDC
mgv_morph_speed                   EQU 8
mgv_morph_delay                   EQU 8*PALFPS

; **** Fill-Blit ****
mgv_fill_blit_x_size              EQU visible_pixels_number
mgv_fill_blit_y_size              EQU visible_lines_number
mgv_fill_blit_depth               EQU pf1_depth3

; **** Scroll-Playfield-Bottom ****
spb_min_VSTART                    EQU VSTART_160_lines
spb_max_VSTOP                     EQU VSTOP_OVERSCAN_PAL
spb_max_visible_lines_number      EQU 283
spb_y_radius                      EQU visible_lines_number+(spb_max_visible_lines_number-visible_lines_number)
spb_y_centre                      EQU visible_lines_number+(spb_max_visible_lines_number-visible_lines_number)

; **** Scroll-Playfield-Bottom-In ****
spbi_y_angle_speed                EQU 4

; **** Scroll-Playfield-Bottom-Out ****
spbo_y_angle_speed                EQU 5


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


; ** Struktur, die alle Registeroffsets der zweiten Copperliste enthält **
; ------------------------------------------------------------------------
  RSRESET

cl2_extension1      RS.B 0

cl2_ext1_WAITBLIT   RS.L 1
cl2_ext1_BLTAFWM    RS.L 1
cl2_ext1_BLTALWM    RS.L 1
cl2_ext1_BLTCPTH    RS.L 1
cl2_ext1_BLTDPTH    RS.L 1
cl2_ext1_BLTCMOD    RS.L 1
cl2_ext1_BLTDMOD    RS.L 1
cl2_ext1_BLTBDAT    RS.L 1
cl2_ext1_BLTADAT    RS.L 1
cl2_ext1_COP2LCH    RS.L 1
cl2_ext1_COP2LCL    RS.L 1
cl2_ext1_COPJMP2    RS.L 1

cl2_extension1_SIZE RS.B 0


  RSRESET

cl2_extension2      RS.B 0

cl2_ext2_BLTCON0    RS.L 1
cl2_ext2_BLTCON1    RS.L 1
cl2_ext2_BLTCPTL    RS.L 1
cl2_ext2_BLTAPTL    RS.L 1
cl2_ext2_BLTDPTL    RS.L 1
cl2_ext2_BLTBMOD    RS.L 1
cl2_ext2_BLTAMOD    RS.L 1
cl2_ext2_BLTSIZE    RS.L 1
cl2_ext2_WAITBLIT   RS.L 1

cl2_extension2_SIZE RS.B 0

  RSRESET

cl2_extension3      RS.B 0

cl2_ext3_BLTCON0    RS.L 1
cl2_ext3_BLTCON1    RS.L 1
cl2_ext3_BLTAPTH    RS.L 1
cl2_ext3_BLTAPTL    RS.L 1
cl2_ext3_BLTDPTH    RS.L 1
cl2_ext3_BLTDPTL    RS.L 1
cl2_ext3_BLTAMOD    RS.L 1
cl2_ext3_BLTDMOD    RS.L 1
cl2_ext3_BLTSIZE    RS.L 1

cl2_extension3_SIZE RS.B 0

  RSRESET

cl2_begin            RS.B 0

  INCLUDE "copperlist2-offsets.i"

cl2_extension1_entry RS.B cl2_extension1_SIZE
cl2_extension2_entry RS.B cl2_extension2_SIZE*mgv_lines_number_max
cl2_extension3_entry RS.B cl2_extension3_SIZE

cl2_end              RS.L 1

copperlist2_SIZE     RS.B 0


; ** Konstanten für die größe der Copperlisten **
; -----------------------------------------------
cl1_size1               EQU 0
cl1_size2               EQU 0
cl1_size3               EQU 0
cl2_size1               EQU 0
cl2_size2               EQU copperlist2_SIZE
cl2_size3               EQU copperlist2_SIZE

; ** Konstanten für die Größe der Spritestrukturen **
; ---------------------------------------------------
spr0_x_size1            EQU spr_x_size1
spr0_y_size1            EQU 0
spr1_x_size1            EQU spr_x_size1
spr1_y_size1            EQU 0
spr2_x_size1            EQU spr_x_size1
spr2_y_size1            EQU 0
spr3_x_size1            EQU spr_x_size1
spr3_y_size1            EQU 0
spr4_x_size1            EQU spr_x_size1
spr4_y_size1            EQU 0
spr5_x_size1            EQU spr_x_size1
spr5_y_size1            EQU 0
spr6_x_size1            EQU spr_x_size1
spr6_y_size1            EQU 0
spr7_x_size1            EQU spr_x_size1
spr7_y_size1            EQU 0

spr0_x_size2            EQU spr_x_size2
spr0_y_size2            EQU 0
spr1_x_size2            EQU spr_x_size2
spr1_y_size2            EQU 0
spr2_x_size2            EQU spr_x_size2
spr2_y_size2            EQU 0
spr3_x_size2            EQU spr_x_size2
spr3_y_size2            EQU 0
spr4_x_size2            EQU spr_x_size2
spr4_y_size2            EQU 0
spr5_x_size2            EQU spr_x_size2
spr5_y_size2            EQU 0
spr6_x_size2            EQU spr_x_size2
spr6_y_size2            EQU 0
spr7_x_size2            EQU spr_x_size2
spr7_y_size2            EQU 0

; ** Struktur, die alle Variablenoffsets enthält **
; -------------------------------------------------

  INCLUDE "variables-offsets.i"

save_a7                          RS.L 1

; **** Morph-Glenz-Vectors ****
mgv_rotation_x_angle             RS.W 1
mgv_rotation_y_angle             RS.W 1
mgv_rotation_z_angle             RS.W 1

mgv_rotation_variable_x_speed    RS.W 1
mgv_rotation_x_angle_speed_angle RS.W 1
mgv_rotation_variable_y_speed    RS.W 1
mgv_rotation_y_angle_speed_angle RS.W 1
mgv_rotation_variable_z_speed    RS.W 1
mgv_rotation_z_angle_speed_angle RS.W 1

mgv_lines_counter                RS.W 1

mgv_morph_state                  RS.W 1
mgv_morph_shapes_table_start     RS.W 1
mgv_morph_delay_counter          RS.W 1

; **** Scroll-Playfield-Bottom-In ****
spbi_state                       RS.W 1
spbi_y_angle                     RS.W 1

; **** Scroll-Playfield-Bottom-Out ****
spbo_state                       RS.W 1
spbo_y_angle                     RS.W 1

; **** Main ****
fx_state                         RS.W 1

variables_SIZE                   RS.B 0


; **** Morph-Glenz-Vectors ****
; ** Objekt-Info-Struktur **
; --------------------------
  RSRESET

mgv_object_info              RS.B 0

mgv_object_info_edge_table   RS.L 1
mgv_object_info_face_color   RS.W 1
mgv_object_info_lines_number RS.W 1

mgv_object_info_SIZE         RS.B 0

; ** Morph-Shape-Struktur **
; --------------------------
  RSRESET

mgv_morph_shape                   RS.B 0

mgv_morph_shape_object_edge_table RS.L 1

mgv_morph_shape_SIZE              RS.B 0


; ## Beginn des Initialisierungsprogramms ##
; ------------------------------------------
start_014_morph_glenz_vectors
  INCLUDE "sys-init.i"

; ** Eigene Variablen initialisieren **
; -------------------------------------
  CNOP 0,4
init_own_variables

; **** Morphing-Glenz-Vectors ****
  moveq   #TRUE,d0
  move.w  d0,mgv_rotation_x_angle(a3)
  move.w  d0,mgv_rotation_y_angle(a3)
  move.w  d0,mgv_rotation_z_angle(a3)

  move.w  d0,mgv_rotation_variable_x_speed(a3)
  move.w  d0,mgv_rotation_x_angle_speed_angle(a3)
  move.w  d0,mgv_rotation_variable_y_speed(a3)
  move.w  d0,mgv_rotation_y_angle_speed_angle(a3)
  move.w  d0,mgv_rotation_variable_z_speed(a3)
  move.w  d0,mgv_rotation_z_angle_speed_angle(a3)

  move.w  d0,mgv_lines_counter(a3)

  IFEQ mgv_premorph_start_shape
    move.w  d0,mgv_morph_state(a3)
  ELSE
    move.w  dq,mgv_morph_state(a3)
  ENDC
  move.w  d0,mgv_morph_shapes_table_start(a3)
  IFEQ mgv_premorph_start_shape
    move.w  d1,mgv_morph_delay_counter(a3) ;Delay-Counter aktivieren
  ELSE
    moveq   #1,d2
    move.w  d2,mgv_morph_delay_counter(a3) ;Delay-Counter aktivieren
  ENDC

; **** Scroll-Playfield-Bottom-In ****
  move.w  d0,spbi_state(a3)
  move.w  d0,spbi_y_angle(a3) ;0 Grad

; **** Scroll-Playfield-Bottom-Out ****
  moveq   #FALSE,d1
  move.w  d1,spbo_state(a3)
  move.w  #sine_table_length/4,spbo_y_angle(a3) ;90 Grad

; **** Main ****
  move.w  d1,fx_state(a3)
  rts

; ** Alle Initialisierungsroutinen ausführen **
; ---------------------------------------------
  CNOP 0,4
init_all
  bsr.s   mgv_init_object_info_table
  bsr.s   mgv_init_morph_shapes_table
  IFEQ mgv_premorph_start_shape
    bsr.s   mgv_init_start_shape
  ENDC
  bsr.s   mgv_init_color_table
  bra     init_second_copperlist

; **** Morph-Glenz-Vectors ****
; ** Object-Info-Tabelle initialisieren **
; ----------------------------------------
  CNOP 0,4
mgv_init_object_info_table
  lea     mgv_object_info_table+mgv_object_info_edge_table(pc),a0 ;Zeiger auf Object-Info-Tabelle
  lea     mgv_object_edge_table(pc),a1 ;Zeiger auf Tebelle mit Eckpunkten
  move.w  #mgv_object_info_SIZE,a2
  MOVEF.W mgv_object_faces_number-1,d7 ;Anzahl der Flächen
mgv_init_object1_info_table_loop
  move.w  mgv_object_info_lines_number(a0),d0 
  addq.w  #2,d0              ;Anzahl der Linien + 2 = Anzahl der Eckpunkte
  move.l  a1,(a0)            ;Zeiger auf Tabelle mit Eckpunkten eintragen
  lea     (a1,d0.w*2),a1     ;Zeiger auf Eckpunkte-Tabelle erhöhen
  add.l   a2,a0              ;Object-Info-Struktur der nächsten Fläche
  dbf     d7,mgv_init_object1_info_table_loop
  rts

; ** Object-Tabelle initialisieren **
; -----------------------------------
  CNOP 0,4
mgv_init_morph_shapes_table
; ** Form 1 **
  lea     mgv_object_shape1_coordinates(pc),a0 ;Zeiger auf 1. Form
  lea     mgv_morph_shapes_table(pc),a1 ;Tabelle mit Zeigern auf Objektdaten
  move.l  a0,(a1)+           ;Zeiger auf Form-Tabelle
; ** Form 2 **
  lea     mgv_object_shape2_coordinates(pc),a0 ;Zeiger auf 2. Form
  move.l  a0,(a1)+           ;Zeiger auf Form-Tabelle
; ** Form 3 **
  lea     mgv_object_shape3_coordinates(pc),a0 ;Zeiger auf 3. Form
  IFEQ mgv_morph_loop
    move.l  a0,(a1)          ;Zeiger auf Form-Tabelle
  ELSE
    move.l  a0,(a1)+         ;Zeiger auf Form-Tabelle
; ** Form 4 **
    lea     mgv_object_shape4_coordinates(pc),a0 ;Zeiger auf 4. Form
    move.l  a0,(a1)          ;Zeiger auf Form-Tabelle
  ENDC
  rts

  IFEQ mgv_premorph_start_shape
    CNOP 0,4
mgv_init_start_shape
    bsr     mgv_morph_object
    tst.w   mgv_morph_state(a3) ;Morphing beendet?
    beq.s   mgv_init_start_shape ;Nein -> verzweige
    rts
  ENDC

; ** Farbtabelle initialisieren **
; --------------------------------
  CNOP 0,4
mgv_init_color_table
  lea     pf1_color_table(pc),a0 ;Zeiger auf Farbtableelle
  lea     mgv_glenz_color_table4(pc),a1 ;Farben des Glenz-Objekts
  move.l  (a1)+,2*LONGWORDSIZE(a0) ;COLOR02
  move.l  (a1)+,3*LONGWORDSIZE(a0) ;COLOR03
  move.l  (a1)+,4*LONGWORDSIZE(a0) ;COLOR04
  move.l  (a1),5*LONGWORDSIZE(a0) ;COLOR05
  rts


; ** 2. Copperliste initialisieren **
; -----------------------------------
  CNOP 0,4
init_second_copperlist
  move.l  cl2_construction2(a3),a0
  bsr.s   cl2_init_playfield_registers
  bsr     cl2_init_color_registers
  bsr     cl2_init_bitplane_pointers
  bsr     cl2_init_line_blits_steady_registers
  bsr     cl2_init_line_blits
  bsr     cl2_init_fill_blit
  COPLISTEND
  bsr     get_wrapper_view_values
  bsr     cl2_set_bitplane_pointers
  bsr     copy_second_copperlist
  bsr     swap_second_copperlist
  bsr     swap_playfield1
  bsr     mgv_fill_playfield1
  bsr     mgv_draw_lines
  bsr     mgv_set_second_copperlist_jump
  bsr     swap_second_copperlist
  bsr     swap_playfield1
  bsr     mgv_fill_playfield1
  bsr     mgv_draw_lines
  bra     mgv_set_second_copperlist_jump

  COP_INIT_PLAYFIELD_REGISTERS cl2

  CNOP 0,4
cl2_init_color_registers
  COP_INIT_COLORHI COLOR00,8,pf1_color_table

  COP_SELECT_COLORLO_BANK 0,v_BPLCON3BITS2
  COP_INIT_COLORLO COLOR00,8,pf1_color_table
  rts

  COP_INIT_BITPLANE_POINTERS cl2

  CNOP 0,4
cl2_init_line_blits_steady_registers
  COPWAITBLIT
  COPMOVEQ FALSEW,BLTAFWM    ;Keine Ausmaskierung
  COPMOVEQ FALSEW,BLTALWM
  COPMOVEQ TRUE,BLTCPTH
  COPMOVEQ TRUE,BLTDPTH
  COPMOVEQ pf1_plane_width*pf1_depth3,BLTCMOD ;Moduli für interleaved Bitmaps
  COPMOVEQ pf1_plane_width*pf1_depth3,BLTDMOD
  COPMOVEQ FALSEW,BLTBDAT    ;Linientextur
  COPMOVEQ $8000,BLTADAT     ;Linientextur beginnt ab MSB
  COPMOVEQ TRUE,COP2LCH
  COPMOVEQ TRUE,COP2LCL
  COPMOVEQ TRUE,COPJMP2
  rts

  CNOP 0,4
cl2_init_line_blits
  MOVEF.W  mgv_lines_number_max-1,d7
cl1_init_line_blits_loop
  COPMOVEQ TRUE,BLTCON0
  COPMOVEQ TRUE,BLTCON1
  COPMOVEQ TRUE,BLTCPTL
  COPMOVEQ TRUE,BLTAPTL
  COPMOVEQ TRUE,BLTDPTL
  COPMOVEQ TRUE,BLTBMOD
  COPMOVEQ TRUE,BLTAMOD
  COPMOVEQ TRUE,BLTSIZE
  COPWAITBLIT
  dbf     d7,cl1_init_line_blits_loop
  rts

  CNOP 0,4
cl2_init_fill_blit
  COPMOVEQ BC0F_SRCA+BC0F_DEST+ANBNC+ANBC+ABNC+ABC,BLTCON0 ;Minterm D=A
  COPMOVEQ BLTCON1F_DESC+BLTCON1F_EFE,BLTCON1 ;Füll-Modus, Rückwärts
  COPMOVEQ TRUE,BLTAPTH
  COPMOVEQ TRUE,BLTAPTL
  COPMOVEQ TRUE,BLTDPTH
  COPMOVEQ TRUE,BLTDPTL
  COPMOVEQ pf1_plane_width-(visible_pixels_number/8),BLTAMOD
  COPMOVEQ pf1_plane_width-(visible_pixels_number/8),BLTDMOD
  COPMOVEQ (mgv_fill_blit_y_size*mgv_fill_blit_depth*64)+(mgv_fill_blit_x_size/16),BLTSIZE
  rts

  CNOP 0,4
get_wrapper_view_values
  move.l  cl2_construction2(a3),a0
  or.w    #v_BPLCON0BITS,cl2_BPLCON0+2(a0)
  or.w    #v_BPLCON3BITS1,cl2_BPLCON3_1+2(a0)
  or.w    #v_BPLCON4BITS,cl2_BPLCON4+2(a0)
  or.w    #v_FMODEBITS,cl2_FMODE+2(a0)
  rts

  COP_SET_BITPLANE_POINTERS cl2,construction2,pf1_depth3

  COPY_COPPERLIST cl2,2


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

; ## Rasterstahl-Routinen ##
; --------------------------
beam_routines
  bsr     wait_beam_position
  bsr.s   swap_second_copperlist
  bsr.s   swap_playfield1
  bsr     mgv_clear_playfield1
  bsr     mgv_calculate_rotation_xyz_speed
  bsr     mgv_rotation
  bsr     mgv_morph_object
  bsr     mgv_draw_lines
  bsr     mgv_fill_playfield1
  bsr     mgv_set_second_copperlist_jump
  bsr     scroll_playfield_bottom_in
  bsr     scroll_playfield_bottom_out
  bsr     mgv_control_counters
  bsr     mouse_handler
  tst.l   d0                 ;Abbruch ?
  bne.s   fast_exit          ;Ja -> verzweige
  tst.w   fx_state(a3)       ;Effekte beendet ?
  bne.s   beam_routines      ;Nein -> verzweige
fast_exit
  move.l  nop_second_copperlist,COP2LC-DMACONR(a6) ;2. Copperliaste deaktivieren
  move.w  d0,COPJMP2-DMACONR(a6)
  move.w  custom_error_code(a3),d1
  rts


; ** Copperlisten vertauschen **
; ------------------------------
  SWAP_COPPERLIST cl2,2

; ** Playfields vertauschen **
; ----------------------------
  CNOP 0,4
swap_playfield1
  move.l  pf1_construction1(a3),a0
  move.l  pf1_construction2(a3),a1
  move.l  pf1_display(a3),pf1_construction1(a3)
  move.l  a0,pf1_construction2(a3)
  move.l  a1,pf1_display(a3)
  move.l  #ALIGN64KB,d1
  moveq   #TRUE,d2
  moveq   #pf1_plane_width,d3
  move.l  cl2_display(a3),a0
  ADDF.W  cl2_BPL1PTH+2,a0   
  moveq   #pf1_depth3-1,d7   ;Anzahl der Planes
swap_playfield1_loop
  move.l  (a1)+,d0
  add.l   d1,d0              ;64 kByte-Alignment
  clr.w   d0
  add.l   d2,d0              ;Offset für Bitplane
  move.w  d0,4(a0)           ;BPLxPTL
  swap    d0                 ;High
  move.w  d0,(a0)            ;BPLxPTH
  add.l   d3,d2              ;Offset nächste Bitplane
  addq.w  #8,a0
  dbf     d7,swap_playfield1_loop
  rts


; ** Playfield löschen **
; -----------------------
  CNOP 0,4
mgv_clear_playfield1
  movem.l a3-a6,-(a7)
  move.l  a7,save_a7(a3)     ;Alten Stackpointer retten
  moveq   #TRUE,d1
  moveq   #TRUE,d2
  moveq   #TRUE,d3
  moveq   #TRUE,d4
  moveq   #TRUE,d5
  moveq   #TRUE,d6
  move.l  d1,a0
  move.l  d1,a1
  move.l  d1,a2
  move.l  d1,a4
  move.l  d1,a5
  move.l  d1,a6
  move.l  pf1_construction1(a3),a7 ;Zeiger erste Plane
  move.l  (a7),d0
  add.l   #ALIGN64KB,d0
  clr.w   d0
  move.l  d0,a7
  ADDF.L  pf1_plane_width*visible_lines_number*pf1_depth3,a7 ;Ende des Playfieldes
  moveq   #TRUE,d0
  move.l  d0,a3
  moveq   #4-1,d7
mgv_clear_playfield1_loop
  REPT ((pf1_plane_width*visible_lines_number*pf1_depth3)/56)/4
  movem.l d0-d6/a0-a6,-(a7)  ;56 Bytes löschen
  ENDR
  dbf     d7,mgv_clear_playfield1_loop
; Rest 96 Bytes
  movem.l d0-d6/a0-a6,-(a7) 
  movem.l d0-d6/a0-a2,-(a7)
  move.l  variables+save_a7(pc),a7 ;Alter Stackpointer
  movem.l (a7)+,a3-a6
  rts

; ** Rotationsgeschwindigkeit um XYZ-Achse berechnen **
; -----------------------------------------------------
  CNOP 0,4
mgv_calculate_rotation_xyz_speed
  move.w  mgv_rotation_x_angle_speed_angle(a3),d2
  lea     sine_table(pc),a0
  move.w  (a0,d2.w*2),d0     ;sin(w)
  MULSF.W mgv_rotation_x_angle_speed_radius*2,d0,d1 ;x_speed = (r*sin(w))/2^15
  swap    d0
  MOVEF.W sine_table_length-1,d3
  add.w   #mgv_rotation_x_angle_speed_center,d0
  move.w  d0,mgv_rotation_variable_x_speed(a3)
  add.w   #mgv_rotation_x_angle_speed_speed,d2 ;nächster X-Winkel
  and.w   d3,d2              ;Überlauf entfwernen
  move.w  d2,mgv_rotation_x_angle_speed_angle(a3)

  move.w  mgv_rotation_y_angle_speed_angle(a3),d2
  move.w  (a0,d2.w*2),d0     ;sin(w)
  MULSF.W mgv_rotation_y_angle_speed_radius*2,d0,d1 ;y_speed = (r*sin(w))/2^15
  swap    d0
  add.w   #mgv_rotation_y_angle_speed_center,d0
  move.w  d0,mgv_rotation_variable_y_speed(a3)
  add.w   #mgv_rotation_y_angle_speed_speed,d2 ;nächster Y-Winkel
  and.w   d3,d2              ;Überlauf entfwernen
  move.w  d2,mgv_rotation_y_angle_speed_angle(a3)

  move.w  mgv_rotation_z_angle_speed_angle(a3),d2
  move.w  (a0,d2.w*2),d0     ;sin(w)
  MULSF.W mgv_rotation_z_angle_speed_radius*2,d0,d1 ;z_speed = (r*sin(w))/2^15
  swap    d0
  add.w   #mgv_rotation_z_angle_speed_center,d0
  move.w  d0,mgv_rotation_variable_z_speed(a3)
  add.w   #mgv_rotation_z_angle_speed_speed,d2 ;nächster YZ-Winkel
  and.w   d3,d2              ;Überlauf entfernen
  move.w  d2,mgv_rotation_z_angle_speed_angle(a3)
  rts

; ** 3D-Rotation **
; -----------------
  CNOP 0,4
mgv_rotation
  movem.l a4-a5,-(a7)
  move.w  mgv_rotation_x_angle(a3),d1 ;X-Winkel
  move.w  d1,d0              ;X-Winkel -> d7
  lea     sine_table(pc),a2  ;Sinus-Tabelle
  move.w  (a2,d0.w*2),d4     ;sin(a)
  move.w  #sine_table_length/4,a4
  MOVEF.W sine_table_length-1,d3
  add.w   a4,d0              ;+ 90 Grad
  swap    d4                 ;Bits 16-31 = sin(a)
  and.w   d3,d0              ;Übertrag entfernen
  move.w  (a2,d0.w*2),d4     ;Bits  0-15 = cos(a)
  add.w   mgv_rotation_variable_x_speed(a3),d1 ;nächster X-Winkel
  and.w   d3,d1              ;Übertrag entfernen
  move.w  d1,mgv_rotation_x_angle(a3) ;X-Winkel retten
  move.w  mgv_rotation_y_angle(a3),d1 ;Y-Winkel
  move.w  d1,d0              
  move.w  (a2,d0.w*2),d5     ;sin(b)
  add.w   a4,d0              ;+ 90 Grad
  swap    d5                 ;Bits 16-31 = sin(b)
  and.w   d3,d0              ;Übertrag entfernen
  move.w  (a2,d0.w*2),d5     ;Bits  0-15 = cos(b)
  add.w   mgv_rotation_variable_y_speed(a3),d1 ;nächster Y-Winkel
  and.w   d3,d1              ;Übertrag entfernen
  move.w  d1,mgv_rotation_y_angle(a3) ;Y-Winkel retten
  move.w  mgv_rotation_z_angle(a3),d1 ;Z-Winkel
  move.w  d1,d0              
  move.w  (a2,d0.w*2),d6     ;sin(c)
  add.w   a4,d0              ;+ 90 Grad
  swap    d6                 ;Bits 16-31 = sin(c)
  and.w   d3,d0              ;Übertrag entfernen
  move.w  (a2,d0.w*2),d6     ;Bits  0-15 = cos(c)
  add.w   mgv_rotation_variable_z_speed(a3),d1 ;nächster Z-Winkel
  and.w   d3,d1              ;Übertrag entfernen
  move.w  d1,mgv_rotation_z_angle(a3) ;Z-Winkel retten
  lea     mgv_object_coordinates(pc),a0 ;Koordinaten der Linien
  lea     mgv_rotation_xy_coordinates(pc),a1 ;Koord.-Tab.
  move.w  #mgv_rotation_d*8,a4 ;d
  move.w  #mgv_rotation_xy_center,a5 ;X+Y-Mittelpunkt
  moveq   #mgv_object_edge_points_number-1,d7 ;Anzahl der Punkte
mgv_rotate_loop
  move.w  (a0)+,d0           ;X-Koord.
  move.l  d7,a2              ;Schleifenzähler retten
  move.w  (a0)+,d1           ;Y-Koord.
  move.w  (a0)+,d2           ;Z-Koord.
  ROTATE_X_AXIS
  ROTATE_Y_AXIS
  ROTATE_Z_AXIS
; ** Zentralprojektion und Translation **
  MULSF.W mgv_rotation_d,d0,d3 ;x*d  X-Projektion
  add.w   a4,d2              ;z+d
  divs.w  d2,d0              ;x' = (x*d)/(z+d)
  MULSF.W mgv_rotation_d,d1,d3 ;y*d  Y-Projektion
  add.w   a5,d0              ;x' + X-Mittelpunkt
  move.w  d0,(a1)+           ;X-Pos.
  divs.w  d2,d1              ;y'= (y*d)/(z+d)
  move.l  a2,d7              ;Schleifenzähler holen
  add.w   a5,d1              ;y' + Y-Mittelpunkt
  move.w  d1,(a1)+           ;Y-Pos.
  dbf     d7,mgv_rotate_loop
  movem.l (a7)+,a4-a5
  rts

; ** Form des Objekts ändern **
; -----------------------------
  CNOP 0,4
mgv_morph_object
  tst.w   mgv_morph_state(a3) ;Morphing an ?
  bne.s   mgv_no_morph_object ;Nein -> verzweige
  move.w  mgv_morph_shapes_table_start(a3),d1 ;Startwert
  moveq   #TRUE,d2           ;Koordinatenzähler
  lea     mgv_object_coordinates(pc),a0 ;Aktuelle Objektdaten
  lea     mgv_morph_shapes_table(pc),a1 ;Tabelle mit Adressen der Formen-Tabellen
  move.l  (a1,d1.w*4),a1     ;Zeiger auf Tabelle holen
  MOVEF.W mgv_object_edge_points_number*3-1,d7 ;Anzahl der Koordinaten
mgv_morph_object_loop
  move.w  (a0),d0            ;aktuelle Koordinate lesen
  cmp.w   (a1)+,d0           ;mit Ziel-Koordinate vergleichen
  beq.s   mgv_morph_object_next_coordinate ;Wenn aktuelle Koordinate = Ziel-Koordinate, dann verzweige
  bgt.s   mgv_morph_object_zoom_size ;Wenn aktuelle Koordinate < Ziel-Koordinate, dann Koordinate erhöhen
mgv_morph_object_reduce_size
  addq.w  #mgv_morph_speed,d0 ;aktuelle Koordinate erhöhen
  bra.s   mgv_morph_object_save_coordinate
  CNOP 0,4
mgv_morph_object_zoom_size
  subq.w  #mgv_morph_speed,d0 ;aktuelle Koordinate verringern
mgv_morph_object_save_coordinate
  move.w  d0,(a0)            ;und retten
  addq.w  #1,d2              ;Koordinatenzähler erhöhen
mgv_morph_object_next_coordinate
  addq.w  #2,a0              ;Nächste Koordinate
  dbf     d7,mgv_morph_object_loop

  tst.w   d2                 ;Morphing beendet?
  bne.s   mgv_no_morph_object ;Nein -> verzweige
  addq.w  #1,d1              ;nächster Eintrag in Objekttablelle
  cmp.w   #mgv_morph_shapes_number,d1 ;Ende der Tabelle ?
  IFEQ mgv_morph_loop
    bne.s   mgv_save_morph_shapes_table_start ;Nein -> verzweige
    moveq   #TRUE,d1         ;Neustart
mgv_save_morph_shapes_table_start
  ELSE
    beq.s   mgv_morph_object_disable ;Ja -> verzweige
  ENDC
  move.w  d1,mgv_morph_shapes_table_start(a3) 
  move.w  #mgv_morph_delay,mgv_morph_delay_counter(a3) ;Zähler zurücksetzen
mgv_morph_object_disable
  moveq   #FALSE,d0
  move.w  d0,mgv_morph_state(a3) ;Morhing aus
mgv_no_morph_object
  rts

; ** Linien ziehen **
; -------------------
  CNOP 0,4
mgv_draw_lines
  movem.l a3-a6,-(a7)
  bsr     mgv_draw_lines_init
  lea     mgv_object_info_table(pc),a0 ;Zeiger auf Info-Daten zum Objekt
  lea     mgv_rotation_xy_coordinates(pc),a1 ;Zeiger auf XY-Koordinaten
  move.l  pf1_construction1(a3),a2 ;Plane0
  move.l  (a2),d0
  add.l   #ALIGN64KB,d0
  clr.w   d0
  move.l  d0,a2
  sub.l   a4,a4              ;Linienzähler zurücksetzen
  move.l  cl2_construction2(a3),a6 
  ADDF.W  cl2_extension3_entry-cl2_extension2_SIZE+cl2_ext2_BLTCON0+2,a6
  move.l  #((BC0F_SRCA+BC0F_SRCC+BC0F_DEST+NANBC+NABC+ABNC)<<16)+(BLTCON1F_LINE+BLTCON1F_SING),a3
  MOVEF.W mgv_object_faces_number-1,d7 ;Anzahl der Flächen
mgv_draw_lines_loop1

; ** Z-Koordinate des Vektors N durch das Kreuzprodukt u x v berechnen **
; -----------------------------------------------------------------------
  move.l  (a0)+,a5           ;Zeiger auf Startwerte der Punkte
  move.w  (a5),d4            ;P1-Startwert
  move.w  2(a5),d5           ;P2-Startwert
  move.w  4(a5),d6           ;P3-Startwert
  swap    d7                 ;Flächenzähler retten
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
  bmi.s   mgv_draw_lines_loop2 ;Wenn zn negativ -> verzweige
  lsr.w   #2,d7              ;COLOR02/04 -> COLOR00/01
  beq     mgv_draw_lines_no_face ;Wenn COLOR00 -> verzweige
  cmp.w   #1,d7              ;Hintere Fläche von Object1 ?
  beq.s   mgv_draw_lines_loop2 ;Ja -> verzweige
  lsr.w   #2,d7              ;COLOR08/16 -> COLOR00/01
  beq     mgv_draw_lines_no_face ;Wenn COLOR00 -> verzweige
mgv_draw_lines_loop2
  move.w  (a5)+,d0           ;Startwerte der Punkte P1,P2
  move.w  (a5),d2
  movem.w (a1,d0.w*2),d0-d1  ;xp1,xp2-Koords
  movem.w (a1,d2.w*2),d2-d3  ;yp1,yp2-Koords
  GET_LINE_PARAMETERS mgv,AREAFILL,COPPERUSE
  add.l   a3,d0              ;restliche BLTCON0 & BLTCON1-Bits setzen
  add.l   a2,d1              ;+ Playfieldadresse
  cmp.w   #1,d7              ;Plane 1 ?
  beq.s   mgv_draw_lines_single_line ;Ja -> verzweige
  moveq   #pf1_plane_width,d5
  add.l   d5,d1              ;nächste Plane
  cmp.w   #2,d7              ;Plane 2 ?
  beq.s   mgv_draw_lines_single_line ;Ja -> verzweige
  add.l   d5,d1              ;nächste Plane
mgv_draw_lines_single_line
  move.w  d0,cl2_ext2_BLTCON1-cl2_ext2_BLTCON0(a6) ;BLTCON1
  swap    d0
  move.w  d0,(a6)            ;BLTCON0
  MULUF.W 2,d2               ;2*(2*dx) = 4*dx
  move.w  d4,cl2_ext2_BLTBMOD-cl2_ext2_BLTCON0(a6) ;4*dy
  sub.w   d2,d4              ;(4*dy)-(4*dx)
  move.w  d1,cl2_ext2_BLTCPTL-cl2_ext2_BLTCON0(a6) ;Playfield lesen
  addq.w  #1,a4              ;Linienzähler erhöhen
  move.w  d1,cl2_ext2_BLTDPTL-cl2_ext2_BLTCON0(a6) ;Playfield schreiben
  addq.w  #1*4,d2            ;(4*dx)+(1*4)
  move.w  d3,cl2_ext2_BLTAPTL-cl2_ext2_BLTCON0(a6) ;(4*dy)-(2*dx)
  MULUF.W 16,d2              ;((4*dx)+(1*4))*16 = Länge der Linie
  move.w  d4,cl2_ext2_BLTAMOD-cl2_ext2_BLTCON0(a6) ;4*(dy-dx)
  addq.w  #2,d2              ;Breite = 1 Wort
  move.w  d2,cl2_ext2_BLTSIZE-cl2_ext2_BLTCON0(a6)
  SUBF.W  cl2_extension2_SIZE,a6
mgv_draw_lines_no_line
  dbf     d6,mgv_draw_lines_loop2
mgv_draw_lines_no_face
  swap    d7                 ;Flächenzähler holen
  dbf     d7,mgv_draw_lines_loop1
  lea     variables+mgv_lines_counter(pc),a0
  move.w  a4,(a0)            ;Anzahl der Linien retten
  movem.l (a7)+,a3-a6
  rts
  CNOP 0,4
mgv_draw_lines_init
  move.l  pf1_construction1(a3),a0
  move.l  (a0),d0
  add.l   #ALIGN64KB,d0
  clr.w   d0
  move.l  cl2_construction2(a3),a0
  swap    d0                 ;High
  move.w  d0,cl2_extension1_entry+cl2_ext1_BLTCPTH+2(a0) ;Playfield lesen
  move.w  d0,cl2_extension1_entry+cl2_ext1_BLTDPTH+2(a0) ;Playfield schreiben
  rts

; ** Playfield füllen **
; ----------------------
  CNOP 0,4
mgv_fill_playfield1
  move.l  pf1_construction1(a3),a0
  move.l  (a0),d0
  add.l   #ALIGN64KB,d0
  clr.w   d0
  move.l  cl2_construction2(a3),a0
  ADDF.L  ((pf1_plane_width*visible_lines_number*pf1_depth3)-(pf1_plane_width-(visible_pixels_number/8)))-2,d0 ;Ende des Playfieldes
  move.w  d0,cl2_extension3_entry+cl2_ext3_BLTAPTL+2(a0) ;Quelle
  move.w  d0,cl2_extension3_entry+cl2_ext3_BLTDPTL+2(a0) ;Ziel
  swap    d0
  move.w  d0,cl2_extension3_entry+cl2_ext3_BLTAPTH+2(a0) ;Quelle
  move.w  d0,cl2_extension3_entry+cl2_ext3_BLTDPTH+2(a0) ;Ziel
  rts

; ** Einsprung in Blits setzen **
; -------------------------------
  CNOP 0,4
mgv_set_second_copperlist_jump
  move.l  cl2_construction2(a3),a0 
  move.l  a0,d0
  ADDF.L  cl2_extension3_entry,d0
  moveq   #TRUE,d1           ;32-Bit-Zugriff
  move.w  mgv_lines_counter(a3),d1
  IFEQ mgv_count_lines
    cmp.w   $140000,d1
    blt.s   mgv_skip
    move.w  d1,$140000
mgv_skip
  ENDC
  MULUF.W cl2_extension2_SIZE,d1,d2
  sub.l   d1,d0
  move.w  d0,cl2_extension1_entry+cl2_ext1_COP2LCL+2(a0)
  swap    d0
  move.w  d0,cl2_extension1_entry+cl2_ext1_COP2LCH+2(a0)
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
  add.w   #spb_y_centre,d0   ;y' + Y-Mittelpunkt
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
  tst.w   spbo_state(a3)     ;Vert-Scroll-Playfild-Out an ?
  bne.s   no_scroll_playfield_bottom_out ;Nein -> verzweige
  move.w  spbo_y_angle(a3),d2 ;Y-Winkel holen
  cmp.w   #sine_table_length/2,d2 ;180 Grad ?
  bgt.s   spbo_finished      ;Ja -> verzweige
  lea     sine_table(pc),a0  
  move.w  (a0,d2.w*2),d0     ;cos(w)
  muls.w  #spb_y_radius*2,d0 ;y'=(cos(w)*yr)/2^15
  swap    d0
  add.w   #spb_y_centre,d0   ;y' + Y-Mittelpunkt
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
  move.l  cl2_construction2(a3),a1 
  moveq   #spb_min_VSTART,d1
  add.w   d0,d1              ;+ Y-Offset
  cmp.w   d3,d1              ;VSTOP-Maximum erreicht ?
  blt.s   spb_no_max_VSTOP1  ;Nein -> verzweige
  move.w  d3,d1              ;VSTOP korrigieren
spb_no_max_VSTOP1
  move.b  d1,cl2_DIWSTRT+2(a1) ;VSTART V7-V0
  move.w  d1,d2
  add.w   #visible_lines_number,d2 ;VSTOP
  cmp.w   d3,d2              ;VSTOP-Maximum erreicht ?
  ble.s   spb_no_max_VSTOP2 ;Nein -> verzweige
  move.w  d3,d2              ;VSTOP korrigieren
spb_no_max_VSTOP2
  move.b  d2,cl2_DIWSTOP+2(a1) ;VSTOP V7-V0
  lsr.w   #8,d1              ;VSTART V8-Bit in richtige Position bringen
  move.b  d1,d2              ;VSTART V8 + VSTOP V8
  or.w    #DIWHIGHBITS&(~(DIWHIGHF_VSTART8+DIWHIGHF_VSTOP8)),d2 ;restliche Bits
  move.w  d2,cl2_DIWHIGH+2(a1)
  rts


; ** Zähler kontrollieren **
; --------------------------
  CNOP 0,4
mgv_control_counters
  move.w  mgv_morph_delay_counter(a3),d0
  bmi.s   mgv_morph_no_delay_counter ;Wenn Zähler negativ -> verzweige
  subq.w  #1,d0              ;Zähler verringern
  bpl.s   mgv_morph_save_delay_counter ;Wenn positiv -> verzweige
mgv_morph_enable
  clr.w   mgv_morph_state(a3) ;Morphing an
  cmp.w   #mgv_morph_shapes_number-1,mgv_morph_shapes_table_start(a3) ;Ende der Tabelle ?
  bne.s   mgv_morph_save_delay_counter ;Nein -> verzweige
  clr.w   spbo_state(a3)     ;Scroll-Playfield-Bottom-Out an
mgv_morph_save_delay_counter
  move.w  d0,mgv_morph_delay_counter(a3) 
mgv_morph_no_delay_counter
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
  REPT pf1_colors_number
    DC.L COLOR00BITS
  ENDR

; **** Morph-Glenz-Vectors ****
; ** Farben der Glenz-Objekte **
  CNOP 0,4
mgv_glenz_color_table4
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/1xGlenz-Colorgradient4.ct"

; ** Objektdaten **
; -----------------
  CNOP 0,2
mgv_object_coordinates
; * Zoom-In *
  DS.W mgv_object_edge_points_number*3

; ** Formen des Objekts **
; ------------------------
; ** Form 1 **
mgv_object_shape1_coordinates
; ** Polygon 2 **
  DC.W 0,-(65*8),0             ;P0
  DC.W 0,-(50*8),41*8          ;P1
  DC.W 16*8,-(50*8),39*8       ;P2
  DC.W 29*8,-(50*8),30*8       ;P3
  DC.W 38*8,-(50*8),16*8       ;P4
  DC.W 41*8,-(50*8),0          ;P5
  DC.W 38*8,-(50*8),-(16*8)    ;P6
  DC.W 29*8,-(50*8),-(30*8)    ;P7
  DC.W 16*8,-(50*8),-(39*8)    ;P8
  DC.W 0,-(50*8),-(41*8)       ;P9
  DC.W -(16*8),-(50*8),-(39*8) ;P10
  DC.W -(29*8),-(50*8),-(30*8) ;P11
  DC.W -(38*8),-(50*8),-(16*8) ;P12
  DC.W -(41*8),-(50*8),0       ;P13
  DC.W -(38*8),-(50*8),16*8    ;P13
  DC.W -(29*8),-(50*8),30*8    ;P15
  DC.W -(16*8),-(50*8),39*8    ;P16
  DC.W 0,0,65*8                ;P13
  DC.W 13*8,0,63*8             ;P16
  DC.W 25*8,0,60*8             ;P19
  DC.W 34*8,0,53*8             ;P20
  DC.W 46*8,0,46*8             ;P21
  DC.W 53*8,0,36*8             ;P22
  DC.W 59*8,0,25*8             ;P23
  DC.W 63*8,0,13*8             ;P24
  DC.W 65*8,0,0                ;P25
  DC.W 63*8,0,-(13*8)          ;P26
  DC.W 59*8,0,-(25*8)          ;P27
  DC.W 53*8,0,-(36*8)          ;P25
  DC.W 45*8,0,-(46*8)          ;P29
  DC.W 34*8,0,-(53*8)          ;P30
  DC.W 25*8,0,-(60*8)          ;P31
  DC.W 13*8,0,-(63*8)          ;P29
  DC.W 0,0,-(65*8)             ;P30
  DC.W -(13*8),0,-(63*8)       ;P34
  DC.W -(25*8),0,-(60*8)       ;P35
  DC.W -(34*8),0,-(53*8)       ;P36
  DC.W -(45*8),0,-(46*8)       ;P37
  DC.W -(53*8),0,-(36*8)       ;P34
  DC.W -(59*8),0,-(25*8)       ;P39
  DC.W -(63*8),0,-(13*8)       ;P36
  DC.W -(65*8),0,0             ;P41
  DC.W -(63*8),0,13*8          ;P38
  DC.W -(59*8),0,25*8          ;P43
  DC.W -(53*8),0,36*8          ;P44
  DC.W -(45*8),0,46*8          ;P45
  DC.W -(34*8),0,53*8          ;P41
  DC.W -(25*8),0,60*8          ;P47
  DC.W -(13*8),0,63*8          ;P48
  DC.W 0,50*8,41*8             ;P49
  DC.W 16*8,50*8,39*8          ;P50
  DC.W 29*8,50*8,30*8          ;P46
  DC.W 38*8,50*8,16*8          ;P52
  DC.W 41*8,50*8,0             ;P53
  DC.W 38*8,50*8,-(16*8)       ;P54
  DC.W 29*8,50*8,-(30*8)       ;P55
  DC.W 16*8,50*8,-(39*8)       ;P50
  DC.W 0,50*8,-(41*8)          ;P57
  DC.W -(16*8),50*8,-(39*8)    ;P58
  DC.W -(29*8),50*8,-(30*8)    ;P53
  DC.W -(38*8),50*8,-(16*8)    ;P60
  DC.W -(41*8),50*8,0          ;P61
  DC.W -(38*8),50*8,16*8       ;P62
  DC.W -(29*8),50*8,30*8       ;P63
  DC.W -(16*8),50*8,39*8       ;P64
  DC.W 0,65*8,0                ;P65

; ** Form 2 **
mgv_object_shape2_coordinates
; ** Polygon 1 **
  DC.W 0,-(65*8),0             ;P0
  DC.W 0,-(32*8),65*8          ;P1
  DC.W 25*8,-(32*8),60*8       ;P2
  DC.W 45*8,-(32*8),46*8       ;P3
  DC.W 59*8,-(32*8),25*8       ;P4
  DC.W 65*8,-(32*8),0          ;P5
  DC.W 59*8,-(32*8),-(25*8)    ;P6
  DC.W 45*8,-(32*8),-(46*8)    ;P7
  DC.W 25*8,-(32*8),-(60*8)    ;P8
  DC.W 0,-(32*8),-(65*8)       ;P9
  DC.W -(25*8),-(32*8),-(60*8) ;P10
  DC.W -(45*8),-(32*8),-(46*8) ;P11
  DC.W -(59*8),-(32*8),-(25*8) ;P12
  DC.W -(65*8),-(32*8),0       ;P13
  DC.W -(59*8),-(32*8),25*8    ;P13
  DC.W -(45*8),-(32*8),46*8    ;P15
  DC.W -(25*8),-(32*8),60*8    ;P16
  DC.W 0,0,65*8                ;P13
  DC.W 13*8,0,63*8             ;P18
  DC.W 25*8,0,60*8             ;P19
  DC.W 34*8,0,59*8             ;P20
  DC.W 46*8,0,46*8             ;P21
  DC.W 53*8,0,36*8             ;P22
  DC.W 59*8,0,25*8             ;P23
  DC.W 63*8,0,13*8             ;P24
  DC.W 65*8,0,0                ;P25
  DC.W 63*8,0,-(13*8)          ;P26
  DC.W 59*8,0,-(25*8)          ;P27
  DC.W 53*8,0,-(36*8)          ;P25
  DC.W 45*8,0,-(46*8)          ;P29
  DC.W 34*8,0,-(59*8)          ;P30
  DC.W 25*8,0,-(60*8)          ;P31
  DC.W 13*8,0,-(63*8)          ;P32
  DC.W 0,0,-(65*8)             ;P33
  DC.W -(13*8),0,-(63*8)       ;P34
  DC.W -(25*8),0,-(60*8)       ;P25
  DC.W -(34*8),0,-(59*8)       ;P32
  DC.W -(45*8),0,-(46*8)       ;P37
  DC.W -(59*8),0,-(36*8)       ;P34
  DC.W -(59*8),0,-(25*8)       ;P39
  DC.W -(63*8),0,-(13*8)       ;P36
  DC.W -(65*8),0,0             ;P41
  DC.W -(63*8),0,13*8          ;P42
  DC.W -(59*8),0,25*8          ;P43
  DC.W -(53*8),0,36*8          ;P44
  DC.W -(45*8),0,46*8          ;P32
  DC.W -(34*8),0,59*8          ;P46
  DC.W -(25*8),0,60*8          ;P47
  DC.W -(13*8),0,63*8          ;P34
  DC.W 0,32*8,65*8             ;P49
  DC.W 25*8,32*8,60*8          ;P36
  DC.W 45*8,32*8,46*8          ;P46
  DC.W 59*8,32*8,25*8          ;P52
  DC.W 65*8,32*8,0             ;P53
  DC.W 59*8,32*8,-(25*8)       ;P54
  DC.W 45*8,32*8,-(46*8)       ;P55
  DC.W 25*8,32*8,-(60*8)       ;P56
  DC.W 0,32*8,-(65*8)          ;P57
  DC.W -(25*8),32*8,-(60*8)    ;P58
  DC.W -(45*8),32*8,-(46*8)    ;P59
  DC.W -(59*8),32*8,-(25*8)    ;P60
  DC.W -(65*8),32*8,0          ;P61
  DC.W -(59*8),32*8,25*8       ;P62
  DC.W -(45*8),32*8,46*8       ;P45
  DC.W -(25*8),32*8,60*8       ;P46
  DC.W 0,65*8,0                ;P65

; ** Form 3 **
mgv_object_shape3_coordinates
; ** Quader **
  DC.W 0,-(32*8),0             ;P0
  DC.W 0,-(32*8),50*8          ;P1
  DC.W 25*8,-(32*8),50*8       ;P2
  DC.W 50*8,-(32*8),50*8       ;P3
  DC.W 50*8,-(32*8),25*8       ;P4
  DC.W 50*8,-(32*8),0          ;P5
  DC.W 50*8,-(32*8),-(25*8)    ;P6
  DC.W 50*8,-(32*8),-(50*8)    ;P7
  DC.W 25*8,-(32*8),-(50*8)    ;P8
  DC.W 0,-(32*8),-(50*8)       ;P9
  DC.W -(25*8),-(32*8),-(50*8) ;P10
  DC.W -(50*8),-(32*8),-(50*8) ;P11
  DC.W -(50*8),-(32*8),-(25*8) ;P12
  DC.W -(50*8),-(32*8),0       ;P13
  DC.W -(50*8),-(32*8),25*8    ;P13
  DC.W -(50*8),-(32*8),50*8    ;P15
  DC.W -(25*8),-(32*8),50*8    ;P16
  DC.W 0,0,50*8                ;P17
  DC.W 13*8,0,50*8             ;P18
  DC.W 25*8,0,50*8             ;P19
  DC.W 34*8,0,50*8             ;P20
  DC.W 50*8,0,50*8             ;P21
  DC.W 50*8,0,36*8             ;P22
  DC.W 50*8,0,25*8             ;P23
  DC.W 50*8,0,13*8             ;P24
  DC.W 50*8,0,0                ;P25
  DC.W 50*8,0,-(13*8)          ;P26
  DC.W 50*8,0,-(25*8)          ;P27
  DC.W 50*8,0,-(36*8)          ;P28
  DC.W 50*8,0,-(50*8)          ;P29
  DC.W 34*8,0,-(50*8)          ;P30
  DC.W 25*8,0,-(50*8)          ;P31
  DC.W 13*8,0,-(50*8)          ;P32
  DC.W 0,0,-(50*8)             ;P33
  DC.W -(13*8),0,-(50*8)       ;P34
  DC.W -(25*8),0,-(50*8)       ;P35
  DC.W -(34*8),0,-(50*8)       ;P36
  DC.W -(50*8),0,-(50*8)       ;P37
  DC.W -(50*8),0,-(36*8)       ;P38
  DC.W -(50*8),0,-(25*8)       ;P39
  DC.W -(50*8),0,-(13*8)       ;P40
  DC.W -(50*8),0,0             ;P41
  DC.W -(50*8),0,13*8          ;P42
  DC.W -(50*8),0,25*8          ;P43
  DC.W -(50*8),0,36*8          ;P44
  DC.W -(50*8),0,50*8          ;P45
  DC.W -(34*8),0,50*8          ;P46
  DC.W -(25*8),0,50*8          ;P47
  DC.W -(13*8),0,50*8          ;P48
  DC.W 0,32*8,50*8             ;P49
  DC.W 25*8,32*8,50*8          ;P50
  DC.W 50*8,32*8,50*8          ;P51
  DC.W 50*8,32*8,25*8          ;P52
  DC.W 50*8,32*8,0             ;P53
  DC.W 50*8,32*8,-(25*8)       ;P54
  DC.W 50*8,32*8,-(50*8)       ;P55
  DC.W 25*8,32*8,-(50*8)       ;P56
  DC.W 0,32*8,-(50*8)          ;P57
  DC.W -(25*8),32*8,-(50*8)    ;P58
  DC.W -(50*8),32*8,-(50*8)    ;P59
  DC.W -(50*8),32*8,-(25*8)    ;P60
  DC.W -(50*8),32*8,0          ;P61
  DC.W -(50*8),32*8,25*8       ;P62
  DC.W -(50*8),32*8,50*8       ;P63
  DC.W -(25*8),32*8,50*8       ;P64
  DC.W 0,32*8,0                ;P65

  IFNE mgv_morph_loop
; ** Form 4 **
; * Zoom-Out *
mgv_object_shape4_coordinates
    DS.W mgv_object_edge_points_number*3
  ENDC

; ** Information über Objekt **
; -----------------------------
  CNOP 0,4
mgv_object_info_table
; ** 1. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face1_color ;Farbe der Fläche
  DC.W mgv_object_face1_lines_number-1 ;Anzahl der Linien
; ** 2. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face2_color ;Farbe der Fläche
  DC.W mgv_object_face2_lines_number-1 ;Anzahl der Linien
; ** 3. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face3_color ;Farbe der Fläche
  DC.W mgv_object_face3_lines_number-1 ;Anzahl der Linien
; ** 4. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face4_color ;Farbe der Fläche
  DC.W mgv_object_face4_lines_number-1 ;Anzahl der Linien
; ** 5. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face5_color ;Farbe der Fläche
  DC.W mgv_object_face5_lines_number-1 ;Anzahl der Linien
; ** 6. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face6_color ;Farbe der Fläche
  DC.W mgv_object_face6_lines_number-1 ;Anzahl der Linien
; ** 7. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face7_color ;Farbe der Fläche
  DC.W mgv_object_face7_lines_number-1 ;Anzahl der Linien
; ** 8. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face8_color ;Farbe der Fläche
  DC.W mgv_object_face8_lines_number-1 ;Anzahl der Linien
; ** 9. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face9_color ;Farbe der Fläche
  DC.W mgv_object_face9_lines_number-1 ;Anzahl der Linien
; ** 10. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face10_color ;Farbe der Fläche
  DC.W mgv_object_face10_lines_number-1 ;Anzahl der Linien
; ** 11. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face11_color ;Farbe der Fläche
  DC.W mgv_object_face11_lines_number-1 ;Anzahl der Linien
; ** 12. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face12_color ;Farbe der Fläche
  DC.W mgv_object_face12_lines_number-1 ;Anzahl der Linien
; ** 13. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face13_color ;Farbe der Fläche
  DC.W mgv_object_face13_lines_number-1 ;Anzahl der Linien
; ** 14. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face14_color ;Farbe der Fläche
  DC.W mgv_object_face14_lines_number-1 ;Anzahl der Linien
; ** 15. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face15_color ;Farbe der Fläche
  DC.W mgv_object_face15_lines_number-1 ;Anzahl der Linien
; ** 16. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face16_color ;Farbe der Fläche
  DC.W mgv_object_face16_lines_number-1 ;Anzahl der Linien

; ** 17. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face17_color ;Farbe der Fläche
  DC.W mgv_object_face17_lines_number-1 ;Anzahl der Linien
; ** 18. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face18_color ;Farbe der Fläche
  DC.W mgv_object_face18_lines_number-1 ;Anzahl der Linien
; ** 19. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face19_color ;Farbe der Fläche
  DC.W mgv_object_face19_lines_number-1 ;Anzahl der Linien

; ** 20. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face20_color ;Farbe der Fläche
  DC.W mgv_object_face20_lines_number-1 ;Anzahl der Linien
; ** 21. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face21_color ;Farbe der Fläche
  DC.W mgv_object_face21_lines_number-1 ;Anzahl der Linien
; ** 22. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face22_color ;Farbe der Fläche
  DC.W mgv_object_face22_lines_number-1 ;Anzahl der Linien

; ** 23. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face23_color ;Farbe der Fläche
  DC.W mgv_object_face23_lines_number-1 ;Anzahl der Linien
; ** 24. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face24_color ;Farbe der Fläche
  DC.W mgv_object_face24_lines_number-1 ;Anzahl der Linien
; ** 25. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face25_color ;Farbe der Fläche
  DC.W mgv_object_face25_lines_number-1 ;Anzahl der Linien

; ** 26. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face26_color ;Farbe der Fläche
  DC.W mgv_object_face26_lines_number-1 ;Anzahl der Linien
; ** 27. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face27_color ;Farbe der Fläche
  DC.W mgv_object_face27_lines_number-1 ;Anzahl der Linien
; ** 28. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face28_color ;Farbe der Fläche
  DC.W mgv_object_face28_lines_number-1 ;Anzahl der Linien

; ** 29. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face29_color ;Farbe der Fläche
  DC.W mgv_object_face29_lines_number-1 ;Anzahl der Linien
; ** 30. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face30_color ;Farbe der Fläche
  DC.W mgv_object_face30_lines_number-1 ;Anzahl der Linien
; ** 31. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face31_color ;Farbe der Fläche
  DC.W mgv_object_face31_lines_number-1 ;Anzahl der Linien

; ** 32. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face32_color ;Farbe der Fläche
  DC.W mgv_object_face32_lines_number-1 ;Anzahl der Linien
; ** 33. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face33_color ;Farbe der Fläche
  DC.W mgv_object_face33_lines_number-1 ;Anzahl der Linien
; ** 34. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face34_color ;Farbe der Fläche
  DC.W mgv_object_face34_lines_number-1 ;Anzahl der Linien

; ** 35. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face35_color ;Farbe der Fläche
  DC.W mgv_object_face35_lines_number-1 ;Anzahl der Linien
; ** 36. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face36_color ;Farbe der Fläche
  DC.W mgv_object_face36_lines_number-1 ;Anzahl der Linien
; ** 37. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face37_color ;Farbe der Fläche
  DC.W mgv_object_face37_lines_number-1 ;Anzahl der Linien

; ** 38. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face38_color ;Farbe der Fläche
  DC.W mgv_object_face38_lines_number-1 ;Anzahl der Linien
; ** 39. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face39_color ;Farbe der Fläche
  DC.W mgv_object_face39_lines_number-1 ;Anzahl der Linien
; ** 40. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face40_color ;Farbe der Fläche
  DC.W mgv_object_face40_lines_number-1 ;Anzahl der Linien

; ** 41. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face41_color ;Farbe der Fläche
  DC.W mgv_object_face41_lines_number-1 ;Anzahl der Linien
; ** 42. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face42_color ;Farbe der Fläche
  DC.W mgv_object_face42_lines_number-1 ;Anzahl der Linien
; ** 43. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face43_color ;Farbe der Fläche
  DC.W mgv_object_face43_lines_number-1 ;Anzahl der Linien

; ** 44. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face44_color ;Farbe der Fläche
  DC.W mgv_object_face44_lines_number-1 ;Anzahl der Linien
; ** 45. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face45_color ;Farbe der Fläche
  DC.W mgv_object_face45_lines_number-1 ;Anzahl der Linien
; ** 46. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face46_color ;Farbe der Fläche
  DC.W mgv_object_face46_lines_number-1 ;Anzahl der Linien

; ** 47. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face47_color ;Farbe der Fläche
  DC.W mgv_object_face47_lines_number-1 ;Anzahl der Linien
; ** 48. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face48_color ;Farbe der Fläche
  DC.W mgv_object_face48_lines_number-1 ;Anzahl der Linien
; ** 49. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face49_color ;Farbe der Fläche
  DC.W mgv_object_face49_lines_number-1 ;Anzahl der Linien

; ** 50. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face50_color ;Farbe der Fläche
  DC.W mgv_object_face50_lines_number-1 ;Anzahl der Linien
; ** 51. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face51_color ;Farbe der Fläche
  DC.W mgv_object_face51_lines_number-1 ;Anzahl der Linien
; ** 52. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face52_color ;Farbe der Fläche
  DC.W mgv_object_face52_lines_number-1 ;Anzahl der Linien

; ** 53. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face53_color ;Farbe der Fläche
  DC.W mgv_object_face53_lines_number-1 ;Anzahl der Linien
; ** 54. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face54_color ;Farbe der Fläche
  DC.W mgv_object_face54_lines_number-1 ;Anzahl der Linien
; ** 55. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face55_color ;Farbe der Fläche
  DC.W mgv_object_face55_lines_number-1 ;Anzahl der Linien

; ** 56. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face56_color ;Farbe der Fläche
  DC.W mgv_object_face56_lines_number-1 ;Anzahl der Linien
; ** 57. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face57_color ;Farbe der Fläche
  DC.W mgv_object_face57_lines_number-1 ;Anzahl der Linien
; ** 58. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face58_color ;Farbe der Fläche
  DC.W mgv_object_face58_lines_number-1 ;Anzahl der Linien

; ** 59. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face59_color ;Farbe der Fläche
  DC.W mgv_object_face59_lines_number-1 ;Anzahl der Linien
; ** 60. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face60_color ;Farbe der Fläche
  DC.W mgv_object_face60_lines_number-1 ;Anzahl der Linien
; ** 61. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face61_color ;Farbe der Fläche
  DC.W mgv_object_face61_lines_number-1 ;Anzahl der Linien

; ** 62. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face62_color ;Farbe der Fläche
  DC.W mgv_object_face62_lines_number-1 ;Anzahl der Linien
; ** 63. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face63_color ;Farbe der Fläche
  DC.W mgv_object_face63_lines_number-1 ;Anzahl der Linien
; ** 64. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face64_color ;Farbe der Fläche
  DC.W mgv_object_face64_lines_number-1 ;Anzahl der Linien


; ** 65. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face65_color ;Farbe der Fläche
  DC.W mgv_object_face65_lines_number-1 ;Anzahl der Linien
; ** 66. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face66_color ;Farbe der Fläche
  DC.W mgv_object_face66_lines_number-1 ;Anzahl der Linien
; ** 67. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face67_color ;Farbe der Fläche
  DC.W mgv_object_face67_lines_number-1 ;Anzahl der Linien

; ** 68. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face68_color ;Farbe der Fläche
  DC.W mgv_object_face68_lines_number-1 ;Anzahl der Linien
; ** 69. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face69_color ;Farbe der Fläche
  DC.W mgv_object_face69_lines_number-1 ;Anzahl der Linien
; ** 70. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face70_color ;Farbe der Fläche
  DC.W mgv_object_face70_lines_number-1 ;Anzahl der Linien

; ** 71. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face71_color ;Farbe der Fläche
  DC.W mgv_object_face71_lines_number-1 ;Anzahl der Linien
; ** 72. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face72_color ;Farbe der Fläche
  DC.W mgv_object_face72_lines_number-1 ;Anzahl der Linien
; ** 73. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face73_color ;Farbe der Fläche
  DC.W mgv_object_face73_lines_number-1 ;Anzahl der Linien

; ** 74. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face74_color ;Farbe der Fläche
  DC.W mgv_object_face74_lines_number-1 ;Anzahl der Linien
; ** 75. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face75_color ;Farbe der Fläche
  DC.W mgv_object_face75_lines_number-1 ;Anzahl der Linien
; ** 76. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face76_color ;Farbe der Fläche
  DC.W mgv_object_face76_lines_number-1 ;Anzahl der Linien

; ** 77. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face77_color ;Farbe der Fläche
  DC.W mgv_object_face77_lines_number-1 ;Anzahl der Linien
; ** 78. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face78_color ;Farbe der Fläche
  DC.W mgv_object_face78_lines_number-1 ;Anzahl der Linien
; ** 79. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face79_color ;Farbe der Fläche
  DC.W mgv_object_face79_lines_number-1 ;Anzahl der Linien

; ** 80. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face80_color ;Farbe der Fläche
  DC.W mgv_object_face80_lines_number-1 ;Anzahl der Linien
; ** 81. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face81_color ;Farbe der Fläche
  DC.W mgv_object_face81_lines_number-1 ;Anzahl der Linien
; ** 82. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face82_color ;Farbe der Fläche
  DC.W mgv_object_face82_lines_number-1 ;Anzahl der Linien

; ** 83. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face83_color ;Farbe der Fläche
  DC.W mgv_object_face83_lines_number-1 ;Anzahl der Linien
; ** 84. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face84_color ;Farbe der Fläche
  DC.W mgv_object_face84_lines_number-1 ;Anzahl der Linien
; ** 85. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face85_color ;Farbe der Fläche
  DC.W mgv_object_face85_lines_number-1 ;Anzahl der Linien

; ** 86. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face86_color ;Farbe der Fläche
  DC.W mgv_object_face86_lines_number-1 ;Anzahl der Linien
; ** 87. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face87_color ;Farbe der Fläche
  DC.W mgv_object_face87_lines_number-1 ;Anzahl der Linien
; ** 88. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face88_color ;Farbe der Fläche
  DC.W mgv_object_face88_lines_number-1 ;Anzahl der Linien

; ** 89. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face89_color ;Farbe der Fläche
  DC.W mgv_object_face89_lines_number-1 ;Anzahl der Linien
; ** 90. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face90_color ;Farbe der Fläche
  DC.W mgv_object_face90_lines_number-1 ;Anzahl der Linien
; ** 91. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face91_color ;Farbe der Fläche
  DC.W mgv_object_face91_lines_number-1 ;Anzahl der Linien

; ** 92. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face92_color ;Farbe der Fläche
  DC.W mgv_object_face92_lines_number-1 ;Anzahl der Linien
; ** 93. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face93_color ;Farbe der Fläche
  DC.W mgv_object_face93_lines_number-1 ;Anzahl der Linien
; ** 94. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face94_color ;Farbe der Fläche
  DC.W mgv_object_face94_lines_number-1 ;Anzahl der Linien

; ** 95. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face95_color ;Farbe der Fläche
  DC.W mgv_object_face95_lines_number-1 ;Anzahl der Linien
; ** 96. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face96_color ;Farbe der Fläche
  DC.W mgv_object_face96_lines_number-1 ;Anzahl der Linien
; ** 97. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face97_color ;Farbe der Fläche
  DC.W mgv_object_face97_lines_number-1 ;Anzahl der Linien

; ** 98. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face98_color ;Farbe der Fläche
  DC.W mgv_object_face98_lines_number-1 ;Anzahl der Linien
; ** 99. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face99_color ;Farbe der Fläche
  DC.W mgv_object_face99_lines_number-1 ;Anzahl der Linien
; ** 100. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face100_color ;Farbe der Fläche
  DC.W mgv_object_face100_lines_number-1 ;Anzahl der Linien

; ** 101. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face101_color ;Farbe der Fläche
  DC.W mgv_object_face101_lines_number-1 ;Anzahl der Linien
; ** 102. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face102_color ;Farbe der Fläche
  DC.W mgv_object_face102_lines_number-1 ;Anzahl der Linien
; ** 103. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face103_color ;Farbe der Fläche
  DC.W mgv_object_face103_lines_number-1 ;Anzahl der Linien

; ** 104. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face104_color ;Farbe der Fläche
  DC.W mgv_object_face104_lines_number-1 ;Anzahl der Linien
; ** 105. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face105_color ;Farbe der Fläche
  DC.W mgv_object_face105_lines_number-1 ;Anzahl der Linien
; ** 106. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face106_color ;Farbe der Fläche
  DC.W mgv_object_face106_lines_number-1 ;Anzahl der Linien

; ** 107. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face107_color ;Farbe der Fläche
  DC.W mgv_object_face107_lines_number-1 ;Anzahl der Linien
; ** 108. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face108_color ;Farbe der Fläche
  DC.W mgv_object_face108_lines_number-1 ;Anzahl der Linien
; ** 109. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face109_color ;Farbe der Fläche
  DC.W mgv_object_face109_lines_number-1 ;Anzahl der Linien

; ** 110. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face110_color ;Farbe der Fläche
  DC.W mgv_object_face110_lines_number-1 ;Anzahl der Linien
; ** 111. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face111_color ;Farbe der Fläche
  DC.W mgv_object_face111_lines_number-1 ;Anzahl der Linien
; ** 112. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face112_color ;Farbe der Fläche
  DC.W mgv_object_face112_lines_number-1 ;Anzahl der Linien


; ** 113. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face113_color ;Farbe der Fläche
  DC.W mgv_object_face113_lines_number-1 ;Anzahl der Linien

; ** 114. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face114_color ;Farbe der Fläche
  DC.W mgv_object_face114_lines_number-1 ;Anzahl der Linien

; ** 115. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face115_color ;Farbe der Fläche
  DC.W mgv_object_face115_lines_number-1 ;Anzahl der Linien

; ** 116. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face116_color ;Farbe der Fläche
  DC.W mgv_object_face116_lines_number-1 ;Anzahl der Linien

; ** 117. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face117_color ;Farbe der Fläche
  DC.W mgv_object_face117_lines_number-1 ;Anzahl der Linien

; ** 118. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face118_color ;Farbe der Fläche
  DC.W mgv_object_face118_lines_number-1 ;Anzahl der Linien

; ** 119. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face119_color ;Farbe der Fläche
  DC.W mgv_object_face119_lines_number-1 ;Anzahl der Linien

; ** 120. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face120_color ;Farbe der Fläche
  DC.W mgv_object_face120_lines_number-1 ;Anzahl der Linien

; ** 121. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face121_color ;Farbe der Fläche
  DC.W mgv_object_face121_lines_number-1 ;Anzahl der Linien

; ** 122. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face122_color ;Farbe der Fläche
  DC.W mgv_object_face122_lines_number-1 ;Anzahl der Linien

; ** 123. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face123_color ;Farbe der Fläche
  DC.W mgv_object_face123_lines_number-1 ;Anzahl der Linien

; ** 124. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face124_color ;Farbe der Fläche
  DC.W mgv_object_face124_lines_number-1 ;Anzahl der Linien

; ** 125. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face125_color ;Farbe der Fläche
  DC.W mgv_object_face125_lines_number-1 ;Anzahl der Linien

; ** 126. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face126_color ;Farbe der Fläche
  DC.W mgv_object_face126_lines_number-1 ;Anzahl der Linien

; ** 127. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face127_color ;Farbe der Fläche
  DC.W mgv_object_face127_lines_number-1 ;Anzahl der Linien

; ** 128. Fläche **
; ----------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face128_color ;Farbe der Fläche
  DC.W mgv_object_face128_lines_number-1 ;Anzahl der Linien


  ; ** Eckpunkte der Flächen **
; ---------------------------
  CNOP 0,2
mgv_object_edge_table
  DC.W 0*2,1*2,2*2,0*2       ;Fläche 1
  DC.W 0*2,2*2,3*2,0*2       ;Fläche 2
  DC.W 0*2,3*2,4*2,0*2       ;Fläche 3
  DC.W 0*2,4*2,5*2,0*2       ;Fläche 4
  DC.W 0*2,5*2,6*2,0*2       ;Fläche 5
  DC.W 0*2,6*2,7*2,0*2       ;Fläche 6
  DC.W 0*2,7*2,8*2,0*2       ;Fläche 7
  DC.W 0*2,8*2,9*2,0*2       ;Fläche 8
  DC.W 0*2,9*2,10*2,0*2      ;Fläche 9
  DC.W 0*2,10*2,11*2,0*2     ;Fläche 10
  DC.W 0*2,11*2,12*2,0*2     ;Fläche 11
  DC.W 0*2,12*2,13*2,0*2     ;Fläche 12
  DC.W 0*2,13*2,14*2,0*2     ;Fläche 13
  DC.W 0*2,14*2,15*2,0*2     ;Fläche 14
  DC.W 0*2,15*2,16*2,0*2     ;Fläche 15
  DC.W 0*2,16*2,1*2,0*2      ;Fläche 16

  DC.W 2*2,18*2,19*2,2*2     ;Fläche 17
  DC.W 2*2,1*2,18*2,2*2      ;Fläche 18
  DC.W 1*2,17*2,18*2,1*2     ;Fläche 19

  DC.W 3*2,20*2,21*2,3*2     ;Fläche 20
  DC.W 3*2,2*2,20*2,3*2      ;Fläche 21
  DC.W 2*2,19*2,20*2,2*2     ;Fläche 22

  DC.W 4*2,22*2,23*2,4*2     ;Fläche 23
  DC.W 4*2,3*2,22*2,4*2      ;Fläche 24
  DC.W 3*2,21*2,22*2,3*2     ;Fläche 25

  DC.W 5*2,24*2,25*2,5*2     ;Fläche 26
  DC.W 5*2,4*2,24*2,5*2      ;Fläche 27
  DC.W 4*2,23*2,24*2,4*2     ;Fläche 28

  DC.W 6*2,26*2,27*2,6*2     ;Fläche 29
  DC.W 6*2,5*2,26*2,6*2      ;Fläche 30
  DC.W 5*2,25*2,26*2,5*2     ;Fläche 31

  DC.W 7*2,28*2,29*2,7*2     ;Fläche 32
  DC.W 7*2,6*2,28*2,7*2      ;Fläche 33
  DC.W 6*2,27*2,28*2,6*2     ;Fläche 34

  DC.W 8*2,30*2,31*2,8*2     ;Fläche 35
  DC.W 8*2,7*2,30*2,8*2      ;Fläche 36
  DC.W 7*2,29*2,30*2,7*2     ;Fläche 37

  DC.W 9*2,32*2,33*2,9*2     ;Fläche 38
  DC.W 9*2,8*2,32*2,9*2      ;Fläche 39
  DC.W 8*2,31*2,32*2,8*2     ;Fläche 40

  DC.W 10*2,34*2,35*2,10*2   ;Fläche 41
  DC.W 10*2,9*2,34*2,10*2    ;Fläche 42
  DC.W 9*2,33*2,34*2,9*2     ;Fläche 43

  DC.W 11*2,36*2,37*2,11*2   ;Fläche 44
  DC.W 11*2,10*2,36*2,11*2   ;Fläche 45
  DC.W 10*2,35*2,36*2,10*2   ;Fläche 46

  DC.W 12*2,38*2,39*2,12*2   ;Fläche 47
  DC.W 12*2,11*2,38*2,12*2   ;Fläche 48
  DC.W 11*2,37*2,38*2,11*2   ;Fläche 49

  DC.W 13*2,40*2,41*2,13*2   ;Fläche 50
  DC.W 13*2,12*2,40*2,13*2   ;Fläche 51
  DC.W 12*2,39*2,40*2,12*2   ;Fläche 52

  DC.W 14*2,42*2,43*2,14*2   ;Fläche 53
  DC.W 14*2,13*2,42*2,14*2   ;Fläche 54
  DC.W 13*2,41*2,42*2,13*2   ;Fläche 55

  DC.W 15*2,44*2,45*2,15*2   ;Fläche 56
  DC.W 15*2,14*2,44*2,15*2   ;Fläche 57
  DC.W 14*2,43*2,44*2,14*2   ;Fläche 58

  DC.W 16*2,46*2,47*2,16*2   ;Fläche 59
  DC.W 16*2,15*2,46*2,16*2   ;Fläche 60
  DC.W 15*2,45*2,46*2,15*2   ;Fläche 61

  DC.W 1*2,48*2,17*2,1*2     ;Fläche 62
  DC.W 1*2,16*2,48*2,1*2     ;Fläche 63
  DC.W 16*2,47*2,48*2,16*2   ;Fläche 64


  DC.W 19*2,18*2,50*2,19*2   ;Fläche 65
  DC.W 18*2,49*2,50*2,18*2   ;Fläche 66
  DC.W 18*2,17*2,49*2,18*2   ;Fläche 67

  DC.W 21*2,20*2,51*2,21*2   ;Fläche 68
  DC.W 20*2,50*2,51*2,20*2   ;Fläche 69
  DC.W 20*2,19*2,50*2,20*2   ;Fläche 70

  DC.W 23*2,22*2,52*2,23*2   ;Fläche 71
  DC.W 22*2,51*2,52*2,22*2   ;Fläche 72
  DC.W 22*2,21*2,51*2,22*2   ;Fläche 73

  DC.W 25*2,24*2,53*2,25*2   ;Fläche 74
  DC.W 24*2,52*2,53*2,24*2   ;Fläche 75
  DC.W 24*2,23*2,52*2,24*2   ;Fläche 76

  DC.W 27*2,26*2,54*2,27*2   ;Fläche 77
  DC.W 26*2,53*2,54*2,26*2   ;Fläche 78
  DC.W 26*2,25*2,53*2,26*2   ;Fläche 79

  DC.W 29*2,28*2,55*2,29*2   ;Fläche 80
  DC.W 28*2,54*2,55*2,28*2   ;Fläche 81
  DC.W 28*2,27*2,54*2,28*2   ;Fläche 82

  DC.W 31*2,30*2,56*2,31*2   ;Fläche 83
  DC.W 30*2,55*2,56*2,30*2   ;Fläche 84
  DC.W 30*2,29*2,55*2,30*2   ;Fläche 85

  DC.W 33*2,32*2,57*2,33*2   ;Fläche 86
  DC.W 32*2,56*2,57*2,32*2   ;Fläche 87
  DC.W 32*2,31*2,56*2,32*2   ;Fläche 88

  DC.W 35*2,34*2,58*2,35*2   ;Fläche 89
  DC.W 34*2,57*2,58*2,34*2   ;Fläche 90
  DC.W 34*2,33*2,57*2,34*2   ;Fläche 91

  DC.W 37*2,36*2,59*2,37*2   ;Fläche 92
  DC.W 36*2,58*2,59*2,36*2   ;Fläche 93
  DC.W 36*2,35*2,58*2,36*2   ;Fläche 94

  DC.W 39*2,38*2,60*2,39*2   ;Fläche 95
  DC.W 38*2,59*2,60*2,38*2   ;Fläche 96
  DC.W 38*2,37*2,59*2,38*2   ;Fläche 97

  DC.W 41*2,40*2,61*2,41*2   ;Fläche 98
  DC.W 40*2,60*2,61*2,40*2   ;Fläche 99
  DC.W 40*2,39*2,60*2,40*2   ;Fläche 100

  DC.W 43*2,42*2,62*2,43*2   ;Fläche 101
  DC.W 42*2,61*2,62*2,42*2   ;Fläche 102
  DC.W 42*2,41*2,61*2,42*2   ;Fläche 103

  DC.W 45*2,44*2,63*2,45*2   ;Fläche 104
  DC.W 44*2,62*2,63*2,44*2   ;Fläche 105
  DC.W 44*2,43*2,62*2,44*2   ;Fläche 106

  DC.W 47*2,46*2,64*2,47*2   ;Fläche 107
  DC.W 46*2,63*2,64*2,46*2   ;Fläche 108
  DC.W 46*2,45*2,63*2,46*2   ;Fläche 109


  DC.W 17*2,48*2,49*2,17*2   ;Fläche 110
  DC.W 48*2,64*2,49*2,48*2   ;Fläche 111
  DC.W 48*2,47*2,64*2,48*2   ;Fläche 112
  DC.W 65*2,50*2,49*2,65*2   ;Fläche 113
  DC.W 65*2,51*2,50*2,65*2   ;Fläche 114
  DC.W 65*2,52*2,51*2,65*2   ;Fläche 115
  DC.W 65*2,53*2,52*2,65*2   ;Fläche 116
  DC.W 65*2,54*2,53*2,65*2   ;Fläche 117
  DC.W 65*2,55*2,54*2,65*2   ;Fläche 118
  DC.W 65*2,56*2,55*2,65*2   ;Fläche 119
  DC.W 65*2,57*2,56*2,65*2   ;Fläche 120
  DC.W 65*2,58*2,57*2,65*2   ;Fläche 121
  DC.W 65*2,59*2,58*2,65*2   ;Fläche 122
  DC.W 65*2,60*2,59*2,65*2   ;Fläche 123
  DC.W 65*2,61*2,60*2,65*2   ;Fläche 124
  DC.W 65*2,62*2,61*2,65*2   ;Fläche 125
  DC.W 65*2,63*2,62*2,65*2   ;Fläche 126
  DC.W 65*2,64*2,63*2,65*2   ;Fläche 127
  DC.W 65*2,49*2,64*2,65*2   ;Fläche 128

; ** Koordinaten der Linien **
; ----------------------------
mgv_rotation_xy_coordinates
  DS.W mgv_object_edge_points_number*2

; ** Tabelle mit Adressen der Objekttabellen **
; ---------------------------------------------
  CNOP 0,4
mgv_morph_shapes_table
  DS.B mgv_morph_shape_SIZE*mgv_morph_shapes_number


; ## Speicherstellen allgemein ##
; -------------------------------

  INCLUDE "sys-variables.i"


; ## Speicherstellen für Namen ##
; -------------------------------

  INCLUDE "sys-names.i"


; ## Speicherstellen für Texte ##
; -------------------------------

  INCLUDE "error-texts.i"

  END

; Polygon 2 -  100 %
  DC.W 0,-(72*8),0             ;P0
  DC.W 0,-(56*8),46*8          ;P1
  DC.W 18*8,-(56*8),43*8       ;P2
  DC.W 32*8,-(56*8),33*8       ;P3
  DC.W 42*8,-(56*8),18*8       ;P4
  DC.W 46*8,-(56*8),0          ;P5
  DC.W 42*8,-(56*8),-(18*8)    ;P6
  DC.W 32*8,-(56*8),-(33*8)    ;P7
  DC.W 18*8,-(56*8),-(43*8)    ;P8
  DC.W 0,-(56*8),-(46*8)       ;P9
  DC.W -(18*8),-(56*8),-(43*8) ;P10
  DC.W -(32*8),-(56*8),-(33*8) ;P11
  DC.W -(42*8),-(56*8),-(18*8) ;P12
  DC.W -(46*8),-(56*8),0       ;P13
  DC.W -(42*8),-(56*8),18*8    ;P14
  DC.W -(32*8),-(56*8),33*8    ;P15
  DC.W -(18*8),-(56*8),43*8    ;P16
  DC.W 0,0,72*8                ;P14
  DC.W 14*8,0,70*8             ;P18
  DC.W 28*8,0,67*8             ;P19
  DC.W 38*8,0,59*8             ;P20
  DC.W 51*8,0,51*8             ;P21
  DC.W 59*8,0,40*8             ;P22
  DC.W 66*8,0,28*8             ;P23
  DC.W 70*8,0,14*8             ;P24
  DC.W 72*8,0,0                ;P25
  DC.W 70*8,0,-(14*8)          ;P26
  DC.W 66*8,0,-(28*8)          ;P27
  DC.W 59*8,0,-(40*8)          ;P28
  DC.W 50*8,0,-(51*8)          ;P29
  DC.W 38*8,0,-(59*8)          ;P30
  DC.W 28*8,0,-(67*8)          ;P31
  DC.W 14*8,0,-(70*8)          ;P32
  DC.W 0,0,-(72*8)             ;P33
  DC.W -(14*8),0,-(70*8)       ;P34
  DC.W -(28*8),0,-(67*8)       ;P35
  DC.W -(38*8),0,-(59*8)       ;P36
  DC.W -(50*8),0,-(51*8)       ;P37
  DC.W -(59*8),0,-(40*8)       ;P38
  DC.W -(66*8),0,-(28*8)       ;P39
  DC.W -(70*8),0,-(14*8)       ;P40
  DC.W -(72*8),0,0             ;P41
  DC.W -(70*8),0,14*8          ;P42
  DC.W -(66*8),0,28*8          ;P43
  DC.W -(59*8),0,40*8          ;P44
  DC.W -(50*8),0,51*8          ;P45
  DC.W -(38*8),0,59*8          ;P46
  DC.W -(28*8),0,67*8          ;P47
  DC.W -(14*8),0,70*8          ;P48
  DC.W 0,56*8,46*8             ;P49
  DC.W 18*8,56*8,43*8          ;P50
  DC.W 32*8,56*8,33*8          ;P51
  DC.W 42*8,56*8,18*8          ;P52
  DC.W 46*8,56*8,0             ;P53
  DC.W 42*8,56*8,-(18*8)       ;P54
  DC.W 32*8,56*8,-(33*8)       ;P55
  DC.W 18*8,56*8,-(43*8)       ;P56
  DC.W 0,56*8,-(46*8)          ;P57
  DC.W -(18*8),56*8,-(43*8)    ;P58
  DC.W -(32*8),56*8,-(33*8)    ;P59
  DC.W -(42*8),56*8,-(18*8)    ;P60
  DC.W -(46*8),56*8,0          ;P61
  DC.W -(42*8),56*8,18*8       ;P62
  DC.W -(32*8),56*8,33*8       ;P63
  DC.W -(18*8),56*8,43*8       ;P64
  DC.W 0,72*8,0                ;P65
