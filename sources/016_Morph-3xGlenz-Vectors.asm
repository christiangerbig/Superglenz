; ###########################################
; # Programm: 015_Morph-Glenz-3xVectors.asm #
; # Autor:    Christian Gerbig              #
; # Datum:    17.04.2024                    #
; # Version:  1.0                           #
; # CPU:      68020+                        #
; # FASTMEM:  -                             #
; # Chipset:  AGA                           #
; # OS:       3.0+                          #
; ###########################################

; Morphendes 3x20-Flächen-Glenz auf einem 144x144 Screen
; Der Copper wartet auf den Blitter. 
; Beam-Position-Timing wegen flexibler Ausführungszeit der Copperliste.
; Das Playfield ist auf 64 kB aligned damit Blitter-High-Pointer der
; Linien-Blits nur 1x initialisiert werden müssen.

  XDEF start_016_morph_3xglenz_vectors

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
  INCDIR "Daten:include3.5/"

  INCLUDE "exec/exec.i"
  INCLUDE "exec/exec_lib.i"

  INCLUDE "dos/dos.i"

  INCLUDE "graphics/gfxbase.i"
  INCLUDE "graphics/graphics_lib.i"

  INCLUDE "libraries/any_lib.i"

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

requires_68030                      EQU FALSE
requires_68040                      EQU FALSE
requires_68060                      EQU FALSE
requires_fast_memory                EQU FALSE
requires_multiscan_monitor          EQU FALSE

workbench_start_enabled             EQU FALSE
workbench_fade_enabled              EQU FALSE
text_output_enabled                 EQU FALSE

sys_taken_over
pass_global_references
pass_return_code

mgv_count_lines                     EQU FALSE
mgv_premorph_enabled                EQU TRUE
mgv_morph_loop_enabled              EQU FALSE

DMABITS                             EQU DMAF_BLITTER+DMAF_RASTER+DMAF_BLITHOG+DMAF_SETCLR

INTENABITS                          EQU INTF_SETCLR

CIAAICRBITS                         EQU CIAICRF_SETCLR
CIABICRBITS                         EQU CIAICRF_SETCLR

COPCONBITS                          EQU COPCONF_CDANG

pf1_x_size1                         EQU 192
pf1_y_size1                         EQU 144+391
pf1_depth1                          EQU 7
pf1_x_size2                         EQU 192
pf1_y_size2                         EQU 144+391
pf1_depth2                          EQU 7
pf1_x_size3                         EQU 192
pf1_y_size3                         EQU 144+391
pf1_depth3                          EQU 7
pf1_colors_number                   EQU 128

pf2_x_size1                         EQU 0
pf2_y_size1                         EQU 0
pf2_depth1                          EQU 0
pf2_x_size2                         EQU 0
pf2_y_size2                         EQU 0
pf2_depth2                          EQU 0
pf2_x_size3                         EQU 0
pf2_y_size3                         EQU 0
pf2_depth3                          EQU 0
pf2_colors_number                   EQU 0
pf_colors_number                    EQU pf1_colors_number+pf2_colors_number
pf_depth                            EQU pf1_depth3+pf2_depth3

extra_pf_number                     EQU 0

spr_number                          EQU 0
spr_x_size1                         EQU 0
spr_x_size2                         EQU 0
spr_depth                           EQU 0
spr_colors_number                   EQU 0

audio_memory_size                   EQU 0

disk_memory_size                    EQU 0

extra_memory_size                   EQU 0

chip_memory_size                    EQU 0
CIAA_TA_time                        EQU 0
CIAA_TB_time                        EQU 0
CIAB_TA_time                        EQU 0
CIAB_TB_time                        EQU 0
CIAA_TA_continuous_enabled          EQU FALSE
CIAA_TB_continuous_enabled          EQU FALSE
CIAB_TA_continuous_enabled          EQU FALSE
CIAB_TB_continuous_enabled          EQU FALSE

beam_position                       EQU $133

pixel_per_line                      EQU 192
visible_pixels_number               EQU 144
visible_lines_number                EQU 144
MINROW                              EQU VSTOP_OVERSCAN_PAL

pf_pixel_per_datafetch              EQU 64 ;4x
DDFSTRTBITS                         EQU DDFSTART_192_pixel_4x
DDFSTOPBITS                         EQU DDFSTOP_192_pixel_4x

display_window_HSTART               EQU HSTART_144_pixel
display_window_VSTART               EQU MINROW
DIWSTRTBITS                         EQU ((display_window_VSTART&$ff)*DIWSTRTF_V0)+(display_window_HSTART&$ff)
display_window_HSTOP                EQU HSTOP_144_pixel
display_window_VSTOP                EQU VSTOP_OVERSCAN_PAL
DIWSTOPBITS                         EQU ((display_window_VSTOP&$ff)*DIWSTOPF_V0)+(display_window_HSTOP&$ff)

pf1_plane_width                     EQU pf1_x_size3/8
data_fetch_width                    EQU pixel_per_line/8
pf1_plane_moduli                    EQU (pf1_plane_width*(pf1_depth3-1))+pf1_plane_width-data_fetch_width

BPLCON0BITS                         EQU BPLCON0F_ECSENA+((pf_depth>>3)*BPLCON0F_BPU3)+(BPLCON0F_COLOR)+((pf_depth&$07)*BPLCON0F_BPU0) ;lores
BPLCON1BITS                         EQU $4488
BPLCON2BITS                         EQU 0
BPLCON3BITS1                        EQU 0
BPLCON3BITS2                        EQU BPLCON3BITS1+BPLCON3F_LOCT
BPLCON4BITS                         EQU 0
DIWHIGHBITS                         EQU (((display_window_HSTOP&$100)>>8)*DIWHIGHF_HSTOP8)+(((display_window_VSTOP&$700)>>8)*DIWHIGHF_VSTOP8)+(((display_window_HSTART&$100)>>8)*DIWHIGHF_HSTART8)+((display_window_VSTART&$700)>>8)
FMODEBITS                           EQU FMODEF_BPL32+FMODEF_BPAGEM

cl2_HSTART                          EQU $00
cl2_VSTART                          EQU beam_position&$ff

sine_table_length                   EQU 512

; **** Morph-Glenz-Vectors****
mgv_rotation_d                      EQU 512
mgv_rotation_xy_center              EQU visible_lines_number/2
mgv_rotation_x_angle_speed          EQU 1
mgv_rotation_y_angle_speed          EQU 2
mgv_rotation_z_angle_speed          EQU 2
; ** Objekt 1 **
mgv_object1_edge_points_number      EQU 12
mgv_object1_edge_points_per_face    EQU 3
mgv_object1_faces_number            EQU 20

mgv_object1_face1_color             EQU 4
mgv_object1_face1_lines_number      EQU 3
mgv_object1_face2_color             EQU 4
mgv_object1_face2_lines_number      EQU 3
mgv_object1_face3_color             EQU 2
mgv_object1_face3_lines_number      EQU 3
mgv_object1_face4_color             EQU 4
mgv_object1_face4_lines_number      EQU 3

mgv_object1_face5_color             EQU 2
mgv_object1_face5_lines_number      EQU 3
mgv_object1_face6_color             EQU 2
mgv_object1_face6_lines_number      EQU 3
mgv_object1_face7_color             EQU 4
mgv_object1_face7_lines_number      EQU 3
mgv_object1_face8_color             EQU 2
mgv_object1_face8_lines_number      EQU 3

mgv_object1_face9_color             EQU 4
mgv_object1_face9_lines_number      EQU 3
mgv_object1_face10_color            EQU 2
mgv_object1_face10_lines_number     EQU 3
mgv_object1_face11_color            EQU 4
mgv_object1_face11_lines_number     EQU 3
mgv_object1_face12_color            EQU 2
mgv_object1_face12_lines_number     EQU 3

mgv_object1_face13_color            EQU 2
mgv_object1_face13_lines_number     EQU 3
mgv_object1_face14_color            EQU 4
mgv_object1_face14_lines_number     EQU 3
mgv_object1_face15_color            EQU 2
mgv_object1_face15_lines_number     EQU 3
mgv_object1_face16_color            EQU 4
mgv_object1_face16_lines_number     EQU 3

mgv_object1_face17_color            EQU 2
mgv_object1_face17_lines_number     EQU 3
mgv_object1_face18_color            EQU 4
mgv_object1_face18_lines_number     EQU 3
mgv_object1_face19_color            EQU 2
mgv_object1_face19_lines_number     EQU 3
mgv_object1_face20_color            EQU 4
mgv_object1_face20_lines_number     EQU 3
; ** Objekt 2 **
mgv_object2_edge_points_number      EQU 12
mgv_object2_edge_points_per_face    EQU 3
mgv_object2_faces_number            EQU 20

mgv_object2_face1_color             EQU 16
mgv_object2_face1_lines_number      EQU 3
mgv_object2_face2_color             EQU 16
mgv_object2_face2_lines_number      EQU 3
mgv_object2_face3_color             EQU 8
mgv_object2_face3_lines_number      EQU 3
mgv_object2_face4_color             EQU 16
mgv_object2_face4_lines_number      EQU 3

mgv_object2_face5_color             EQU 8
mgv_object2_face5_lines_number      EQU 3
mgv_object2_face6_color             EQU 8
mgv_object2_face6_lines_number      EQU 3
mgv_object2_face7_color             EQU 16
mgv_object2_face7_lines_number      EQU 3
mgv_object2_face8_color             EQU 8
mgv_object2_face8_lines_number      EQU 3

mgv_object2_face9_color             EQU 16
mgv_object2_face9_lines_number      EQU 3
mgv_object2_face10_color            EQU 8
mgv_object2_face10_lines_number     EQU 3
mgv_object2_face11_color            EQU 16
mgv_object2_face11_lines_number     EQU 3
mgv_object2_face12_color            EQU 8
mgv_object2_face12_lines_number     EQU 3

mgv_object2_face13_color            EQU 8
mgv_object2_face13_lines_number     EQU 3
mgv_object2_face14_color            EQU 16
mgv_object2_face14_lines_number     EQU 3
mgv_object2_face15_color            EQU 8
mgv_object2_face15_lines_number     EQU 3
mgv_object2_face16_color            EQU 16
mgv_object2_face16_lines_number     EQU 3

mgv_object2_face17_color            EQU 8
mgv_object2_face17_lines_number     EQU 3
mgv_object2_face18_color            EQU 16
mgv_object2_face18_lines_number     EQU 3
mgv_object2_face19_color            EQU 8
mgv_object2_face19_lines_number     EQU 3
mgv_object2_face20_color            EQU 16
mgv_object2_face20_lines_number     EQU 3
; ** Objekt 3 **
mgv_object3_edge_points_number      EQU 12
mgv_object3_edge_points_per_face    EQU 3
mgv_object3_faces_number            EQU 20

mgv_object3_face1_color             EQU 64
mgv_object3_face1_lines_number      EQU 3
mgv_object3_face2_color             EQU 64
mgv_object3_face2_lines_number      EQU 3
mgv_object3_face3_color             EQU 32
mgv_object3_face3_lines_number      EQU 3
mgv_object3_face4_color             EQU 64
mgv_object3_face4_lines_number      EQU 3

mgv_object3_face5_color             EQU 32
mgv_object3_face5_lines_number      EQU 3
mgv_object3_face6_color             EQU 32
mgv_object3_face6_lines_number      EQU 3
mgv_object3_face7_color             EQU 64
mgv_object3_face7_lines_number      EQU 3
mgv_object3_face8_color             EQU 32
mgv_object3_face8_lines_number      EQU 3

mgv_object3_face9_color             EQU 64
mgv_object3_face9_lines_number      EQU 3
mgv_object3_face10_color            EQU 32
mgv_object3_face10_lines_number     EQU 3
mgv_object3_face11_color            EQU 64
mgv_object3_face11_lines_number     EQU 3
mgv_object3_face12_color            EQU 32
mgv_object3_face12_lines_number     EQU 3

mgv_object3_face13_color            EQU 32
mgv_object3_face13_lines_number     EQU 3
mgv_object3_face14_color            EQU 64
mgv_object3_face14_lines_number     EQU 3
mgv_object3_face15_color            EQU 32
mgv_object3_face15_lines_number     EQU 3
mgv_object3_face16_color            EQU 64
mgv_object3_face16_lines_number     EQU 3

mgv_object3_face17_color            EQU 32
mgv_object3_face17_lines_number     EQU 3
mgv_object3_face18_color            EQU 64
mgv_object3_face18_lines_number     EQU 3
mgv_object3_face19_color            EQU 32
mgv_object3_face19_lines_number     EQU 3
mgv_object3_face20_color            EQU 64
mgv_object3_face20_lines_number     EQU 3

mgv_objects_number                  EQU 3
mgv_objects_edge_points_number      EQU mgv_object1_edge_points_number+mgv_object2_edge_points_number+mgv_object3_edge_points_number
mgv_objects_faces_number            EQU mgv_object1_faces_number+mgv_object2_faces_number+mgv_object3_faces_number

mgv_lines_number_max                EQU 162

  IFEQ mgv_morph_loop_enabled
mgv_morph_shapes_number             EQU 6
  ELSE
mgv_morph_shapes_number             EQU 7
  ENDC
mgv_morph_speed                     EQU 8
; ** Form 1 **
mgv_object1_shape1_x_rotation_speed EQU 0
mgv_object1_shape1_y_rotation_speed EQU 0
mgv_object1_shape1_z_rotation_speed EQU 0
mgv_object2_shape1_x_rotation_speed EQU 0
mgv_object2_shape1_y_rotation_speed EQU 0
mgv_object2_shape1_z_rotation_speed EQU 0
mgv_object3_shape1_x_rotation_speed EQU 0
mgv_object3_shape1_y_rotation_speed EQU 0
mgv_object3_shape1_z_rotation_speed EQU 0
mgv_morph_shape1_delay              EQU 2*PALFPS

; ** Form 2 **
mgv_object1_shape2_x_rotation_speed EQU 0
mgv_object1_shape2_y_rotation_speed EQU 0
mgv_object1_shape2_z_rotation_speed EQU 0
mgv_object2_shape2_x_rotation_speed EQU 0
mgv_object2_shape2_y_rotation_speed EQU 0
mgv_object2_shape2_z_rotation_speed EQU 0
mgv_object3_shape2_x_rotation_speed EQU 0
mgv_object3_shape2_y_rotation_speed EQU 0
mgv_object3_shape2_z_rotation_speed EQU 0
mgv_morph_shape2_delay              EQU 3*PALFPS

; ** Form 3 **
mgv_object1_shape3_x_rotation_speed EQU 0
mgv_object1_shape3_y_rotation_speed EQU 0
mgv_object1_shape3_z_rotation_speed EQU 0
mgv_object2_shape3_x_rotation_speed EQU 0
mgv_object2_shape3_y_rotation_speed EQU 0
mgv_object2_shape3_z_rotation_speed EQU 0
mgv_object3_shape3_x_rotation_speed EQU 0
mgv_object3_shape3_y_rotation_speed EQU 0
mgv_object3_shape3_z_rotation_speed EQU 0
mgv_morph_shape3_delay              EQU 6*PALFPS

; ** Form 4 **
mgv_object1_shape4_x_rotation_speed EQU 0
mgv_object1_shape4_y_rotation_speed EQU 0
mgv_object1_shape4_z_rotation_speed EQU 0
mgv_object2_shape4_x_rotation_speed EQU 0
mgv_object2_shape4_y_rotation_speed EQU 0
mgv_object2_shape4_z_rotation_speed EQU 0
mgv_object3_shape4_x_rotation_speed EQU 0
mgv_object3_shape4_y_rotation_speed EQU 0
mgv_object3_shape4_z_rotation_speed EQU 0
mgv_morph_shape4_delay              EQU 6*PALFPS

; ** Form 5 **
mgv_object1_shape5_x_rotation_speed EQU 0
mgv_object1_shape5_y_rotation_speed EQU -5
mgv_object1_shape5_z_rotation_speed EQU 0
mgv_object2_shape5_x_rotation_speed EQU 0
mgv_object2_shape5_y_rotation_speed EQU -6
mgv_object2_shape5_z_rotation_speed EQU 0
mgv_object3_shape5_x_rotation_speed EQU 0
mgv_object3_shape5_y_rotation_speed EQU -7
mgv_object3_shape5_z_rotation_speed EQU 0
mgv_morph_shape5_delay              EQU 6*PALFPS

; ** Form 6 **
mgv_object1_shape6_x_rotation_speed EQU 0
mgv_object1_shape6_y_rotation_speed EQU 0
mgv_object1_shape6_z_rotation_speed EQU -4
mgv_object2_shape6_x_rotation_speed EQU 0
mgv_object2_shape6_y_rotation_speed EQU 0
mgv_object2_shape6_z_rotation_speed EQU 4
mgv_object3_shape6_x_rotation_speed EQU 0
mgv_object3_shape6_y_rotation_speed EQU 0
mgv_object3_shape6_z_rotation_speed EQU -4
mgv_morph_shape6_delay              EQU 6*PALFPS

; ** Form 7 **
mgv_object1_shape7_x_rotation_speed EQU 0
mgv_object1_shape7_y_rotation_speed EQU 0
mgv_object1_shape7_z_rotation_speed EQU -4
mgv_object2_shape7_x_rotation_speed EQU 0
mgv_object2_shape7_y_rotation_speed EQU 0
mgv_object2_shape7_z_rotation_speed EQU 4
mgv_object3_shape7_x_rotation_speed EQU 0
mgv_object3_shape7_y_rotation_speed EQU 0
mgv_object3_shape7_z_rotation_speed EQU -4
mgv_morph_shape7_delay              EQU 2*PALFPS

; **** Fill-Blit ****
mgv_fill_blit_x_size                EQU visible_pixels_number
mgv_fill_blit_y_size                EQU visible_lines_number
mgv_fill_blit_depth                 EQU pf1_depth3

; **** Scroll-Playfield-Bottom ****
spb_min_VSTART                      EQU VSTART_144_lines
spb_max_VSTOP                       EQU VSTOP_OVERSCAN_PAL
spb_max_visible_lines_number        EQU 283
spb_y_radius                        EQU visible_lines_number+(spb_max_visible_lines_number-visible_lines_number)
spb_y_centre                        EQU visible_lines_number+(spb_max_visible_lines_number-visible_lines_number)

; **** Scroll-Playfield-Bottom-In ****
spbi_y_angle_speed                  EQU 4

; **** Scroll-Playfield-Bottom-Out ****
spbo_y_angle_speed                  EQU 5


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

save_a7                                   RS.L 1

; **** Morph-Glenz-Vectors ****
mgv_rotation_x_angle                      RS.W 1
mgv_rotation_y_angle                      RS.W 1
mgv_rotation_z_angle                      RS.W 1

mgv_pre_rotate_active                     RS.W 1
  RS_ALIGN_LONGWORD
mgv_object1_x_pre_rotation_angle          RS.W 1
mgv_object1_y_pre_rotation_angle          RS.W 1
mgv_object1_z_pre_rotation_angle          RS.W 1

mgv_object2_x_pre_rotation_angle          RS.W 1
mgv_object2_y_pre_rotation_angle          RS.W 1
mgv_object2_z_pre_rotation_angle          RS.W 1

mgv_object3_x_pre_rotation_angle          RS.W 1
mgv_object3_y_pre_rotation_angle          RS.W 1
mgv_object3_z_pre_rotation_angle          RS.W 1
  RS_ALIGN_LONGWORD
mgv_object1_variable_x_pre_rotation_speed RS.W 1
mgv_object1_variable_y_pre_rotation_speed RS.W 1
mgv_object1_variable_z_pre_rotation_speed RS.W 1

mgv_object2_variable_x_pre_rotation_speed RS.W 1
mgv_object2_variable_y_pre_rotation_speed RS.W 1
mgv_object2_variable_z_pre_rotation_speed RS.W 1

mgv_object3_variable_x_pre_rotation_speed RS.W 1
mgv_object3_variable_y_pre_rotation_speed RS.W 1
mgv_object3_variable_z_pre_rotation_speed RS.W 1

mgv_lines_counter                         RS.W 1

mgv_morph_active                          RS.W 1
mgv_morph_shapes_table_start              RS.W 1
mgv_morph_delay_counter                   RS.W 1

; **** Scroll-Playfield-Bottom-In ****
spbi_active                               RS.W 1
spbi_y_angle                              RS.W 1

; **** Scroll-Playfield-Bottom-out ****
spbo_active                               RS.W 1
spbo_y_angle                              RS.W 1

; **** Main ****
fx_active                                 RS.W 1

variables_SIZE                            RS.B 0


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

mgv_morph_shape                          RS.B 0

mgv_morph_shape_object1_edge_table       RS.L 1
mgv_morph_shape_object2_edge_table       RS.L 1
mgv_morph_shape_object3_edge_table       RS.L 1
mgv_morph_shape_object1_x_rotation_speed RS.W 1
mgv_morph_shape_object1_y_rotation_speed RS.W 1
mgv_morph_shape_object1_z_rotation_speed RS.W 1
mgv_morph_shape_object2_x_rotation_speed RS.W 1
mgv_morph_shape_object2_y_rotation_speed RS.W 1
mgv_morph_shape_object2_z_rotation_speed RS.W 1
mgv_morph_shape_object3_x_rotation_speed RS.W 1
mgv_morph_shape_object3_y_rotation_speed RS.W 1
mgv_morph_shape_object3_z_rotation_speed RS.W 1
mgv_morph_shape_delay                    RS.W 1

mgv_morph_shape_SIZE                     RS.B 0


start_016_morph_3xglenz_vectors

  INCLUDE "sys-wrapper.i"

; ** Eigene Variablen initialisieren **
; -------------------------------------
  CNOP 0,4
init_own_variables

; **** Morph-Glenz-Vectors ****
  moveq   #0,d0
  move.w  d0,mgv_rotation_x_angle(a3)
  move.w  d0,mgv_rotation_y_angle(a3)
  move.w  d0,mgv_rotation_z_angle(a3)

  moveq   #FALSE,d1
  move.w  d1,mgv_pre_rotate_active(a3)

  move.w  d0,mgv_object1_x_pre_rotation_angle(a3)
  move.w  d0,mgv_object1_y_pre_rotation_angle(a3)
  move.w  d0,mgv_object1_z_pre_rotation_angle(a3)

  move.w  d0,mgv_object2_x_pre_rotation_angle(a3)
  move.w  d0,mgv_object2_y_pre_rotation_angle(a3)
  move.w  d0,mgv_object2_z_pre_rotation_angle(a3)

  move.w  d0,mgv_object3_x_pre_rotation_angle(a3)
  move.w  d0,mgv_object3_y_pre_rotation_angle(a3)
  move.w  d0,mgv_object3_z_pre_rotation_angle(a3)

  move.w  d0,mgv_object1_variable_x_pre_rotation_speed(a3)
  move.w  d0,mgv_object1_variable_y_pre_rotation_speed(a3)
  move.w  d0,mgv_object1_variable_z_pre_rotation_speed(a3)

  move.w  d0,mgv_object2_variable_x_pre_rotation_speed(a3)
  move.w  d0,mgv_object2_variable_y_pre_rotation_speed(a3)
  move.w  d0,mgv_object2_variable_z_pre_rotation_speed(a3)

  move.w  d0,mgv_object3_variable_x_pre_rotation_speed(a3)
  move.w  d0,mgv_object3_variable_y_pre_rotation_speed(a3)
  move.w  d0,mgv_object3_variable_z_pre_rotation_speed(a3)

  move.w  d0,mgv_lines_counter(a3)

  IFEQ mgv_premorph_enabled
    move.w  d0,mgv_morph_active(a3)
  ELSE
    move.w  dq,mgv_morph_active(a3)
  ENDC
  move.w  d0,mgv_morph_shapes_table_start(a3)
  IFEQ mgv_premorph_enabled
    move.w  d1,mgv_morph_delay_counter(a3) ;Delay-Counter aktivieren
  ELSE
    moveq   #1,d2
    move.w  d2,mgv_morph_delay_counter(a3) ;Delay-Counter aktivieren
  ENDC 

; **** Scroll-Playfield-Bottom-In ****
  move.w  d0,spbi_active(a3)
  move.w  d0,spbi_y_angle(a3) ;0 Grad

; **** Scroll-Playfield-Bottom-Out ****
  move.w  d1,spbo_active(a3)
  move.w  #sine_table_length/4,spbo_y_angle(a3) ;90 Grad

; **** Main ****
  move.w  d1,fx_active(a3)
  rts

; ** Alle Initialisierungsroutinen ausführen **
; ---------------------------------------------
  CNOP 0,4
init_all
  bsr.s   mgv_init_objects_info_table
  bsr     mgv_init_morph_shapes_table
  IFEQ mgv_premorph_enabled
    bsr     mgv_init_start_shape
  ENDC
  bsr     mgv_init_color_table
  bra     init_second_copperlist

; **** Morph-Glenz-Vectors ****
; ** Object-Info-Tabelle initialisieren **
; ----------------------------------------
  CNOP 0,4
mgv_init_objects_info_table
  lea     mgv_objects_info_table+mgv_object_info_edge_table(pc),a0 ;Zeiger auf Object-Info-Tabelle
  lea     mgv_objects_edge_table(pc),a1 ;Zeiger auf Tabelle mit Eckpunkten
  move.w  #mgv_object_info_SIZE,a2
; ** Object 1 **
  moveq   #mgv_object1_faces_number-1,d7 ;Anzahl der Flächen
  bsr.s   mgv_init_objects_info_table_loop
; ** Object 2 **
  moveq   #mgv_object2_faces_number-1,d7 ;Anzahl der Flächen
  bsr.s   mgv_init_objects_info_table_loop
; ** Object 3 **
  moveq   #mgv_object3_faces_number-1,d7 ;Anzahl der Flächen

; d7 ... Anzahl der Flächen
; a0 ... Object-Info-Tabelle
; a1 ... Tabelle mit Eckpunkten
mgv_init_objects_info_table_loop
  move.w  mgv_object_info_lines_number(a0),d0 
  addq.w  #2,d0              ;Anzahl der Linien + 2 = Anzahl der Eckpunkte
  move.l  a1,(a0)            ;Zeiger auf Tabelle mit Eckpunkten eintragen
  lea     (a1,d0.w*2),a1     ;Zeiger auf Eckpunkte-Tabelle erhöhen
  add.l   a2,a0              ;Object-Info-Struktur der nächsten Fläche
  dbf     d7,mgv_init_objects_info_table_loop
  rts

; ** Morph-Objects-Tabelle initialisieren **
; ------------------------------------------
  CNOP 0,4
mgv_init_morph_shapes_table
; ** Form 1 **
  lea     mgv_morph_shapes_table(pc),a1 ;Tabelle mit Zeigern auf Objektdaten
  lea     mgv_object1_shape1_coordinates(pc),a0
  move.l  a0,(a1)+           ;Zeiger auf Koords-Tabelle
  lea     mgv_object2_shape1_coordinates(pc),a0
  move.l  a0,(a1)+           ;Zeiger auf Koords-Tabelle
  lea     mgv_object3_shape1_coordinates(pc),a0
  move.l  a0,(a1)+           ;Zeiger auf Koords-Tabelle
  moveq   #mgv_object1_shape1_x_rotation_speed,d2
  move.w  d2,(a1)+           ;X-Achse
  moveq   #mgv_object1_shape1_y_rotation_speed,d2
  move.w  d2,(a1)+           ;Y-Achse
  moveq   #mgv_object1_shape1_z_rotation_speed,d2
  move.w  d2,(a1)+           ;Z-Achse
  moveq   #mgv_object2_shape1_x_rotation_speed,d2
  move.w  d2,(a1)+           ;X-Achse
  moveq   #mgv_object2_shape1_y_rotation_speed,d2
  move.w  d2,(a1)+           ;Y-Achse
  moveq   #mgv_object2_shape1_z_rotation_speed,d2
  move.w  d2,(a1)+           ;Z-Achse
  moveq   #mgv_object3_shape1_x_rotation_speed,d2
  move.w  d2,(a1)+           ;X-Achse
  moveq   #mgv_object3_shape1_y_rotation_speed,d2
  move.w  d2,(a1)+           ;Y-Achse
  moveq   #mgv_object3_shape1_z_rotation_speed,d2
  move.w  d2,(a1)+           ;Z-Achse
  move.w  #mgv_morph_shape1_delay,(a1)+
; ** Form 2 **
  lea     mgv_object1_shape2_coordinates(pc),a0
  move.l  a0,(a1)+           ;Zeiger auf Objekt-Tabelle
  lea     mgv_object2_shape2_coordinates(pc),a0
  move.l  a0,(a1)+           ;Zeiger auf Koords-Tabelle
  lea     mgv_object3_shape2_coordinates(pc),a0
  move.l  a0,(a1)+           ;Zeiger auf Koords-Tabelle
  moveq   #mgv_object1_shape2_x_rotation_speed,d2
  move.w  d2,(a1)+           ;X-Achse
  moveq   #mgv_object1_shape2_y_rotation_speed,d2
  move.w  d2,(a1)+           ;Y-Achse
  moveq   #mgv_object1_shape2_z_rotation_speed,d2
  move.w  d2,(a1)+           ;Z-Achse
  moveq   #mgv_object2_shape2_x_rotation_speed,d2
  move.w  d2,(a1)+           ;X-Achse
  moveq   #mgv_object2_shape2_y_rotation_speed,d2
  move.w  d2,(a1)+           ;Y-Achse
  moveq   #mgv_object2_shape2_z_rotation_speed,d2
  move.w  d2,(a1)+           ;Z-Achse
  moveq   #mgv_object3_shape2_x_rotation_speed,d2
  move.w  d2,(a1)+           ;X-Achse
  moveq   #mgv_object3_shape2_y_rotation_speed,d2
  move.w  d2,(a1)+           ;Y-Achse
  moveq   #mgv_object3_shape2_z_rotation_speed,d2
  move.w  d2,(a1)+           ;Z-Achse
  move.w  #mgv_morph_shape2_delay,(a1)+
; ** Form 3 **
  lea     mgv_object1_shape3_coordinates(pc),a0
  move.l  a0,(a1)+           ;Zeiger auf Objekt-Tabelle
  lea     mgv_object2_shape3_coordinates(pc),a0
  move.l  a0,(a1)+           ;Zeiger auf Koords-Tabelle
  lea     mgv_object3_shape3_coordinates(pc),a0
  move.l  a0,(a1)+           ;Zeiger auf Koords-Tabelle
  moveq   #mgv_object1_shape3_x_rotation_speed,d2
  move.w  d2,(a1)+           ;X-Achse
  moveq   #mgv_object1_shape3_y_rotation_speed,d2
  move.w  d2,(a1)+           ;Y-Achse
  moveq   #mgv_object1_shape3_z_rotation_speed,d2
  move.w  d2,(a1)+           ;Z-Achse
  moveq   #mgv_object2_shape3_x_rotation_speed,d2
  move.w  d2,(a1)+           ;X-Achse
  moveq   #mgv_object2_shape3_y_rotation_speed,d2
  move.w  d2,(a1)+           ;Y-Achse
  moveq   #mgv_object2_shape3_z_rotation_speed,d2
  move.w  d2,(a1)+           ;Z-Achse
  moveq   #mgv_object3_shape3_x_rotation_speed,d2
  move.w  d2,(a1)+           ;X-Achse
  moveq   #mgv_object3_shape3_y_rotation_speed,d2
  move.w  d2,(a1)+           ;Y-Achse
  moveq   #mgv_object3_shape3_z_rotation_speed,d2
  move.w  d2,(a1)+           ;Z-Achse
  move.w  #mgv_morph_shape3_delay,(a1)+
; ** Form 4 **
  lea     mgv_object1_shape4_coordinates(pc),a0
  move.l  a0,(a1)+           ;Zeiger auf Objekt-Tabelle
  lea     mgv_object2_shape4_coordinates(pc),a0
  move.l  a0,(a1)+           ;Zeiger auf Koords-Tabelle
  lea     mgv_object3_shape4_coordinates(pc),a0
  move.l  a0,(a1)+           ;Zeiger auf Koords-Tabelle
  moveq   #mgv_object1_shape4_x_rotation_speed,d2
  move.w  d2,(a1)+           ;X-Achse
  moveq   #mgv_object1_shape4_y_rotation_speed,d2
  move.w  d2,(a1)+           ;Y-Achse
  moveq   #mgv_object1_shape4_z_rotation_speed,d2
  move.w  d2,(a1)+           ;Z-Achse
  moveq   #mgv_object2_shape4_x_rotation_speed,d2
  move.w  d2,(a1)+           ;X-Achse
  moveq   #mgv_object2_shape4_y_rotation_speed,d2
  move.w  d2,(a1)+           ;Y-Achse
  moveq   #mgv_object2_shape4_z_rotation_speed,d2
  move.w  d2,(a1)+           ;Z-Achse
  moveq   #mgv_object3_shape4_x_rotation_speed,d2
  move.w  d2,(a1)+           ;X-Achse
  moveq   #mgv_object3_shape4_y_rotation_speed,d2
  move.w  d2,(a1)+           ;Y-Achse
  moveq   #mgv_object3_shape4_z_rotation_speed,d2
  move.w  d2,(a1)+           ;Z-Achse
  move.w  #mgv_morph_shape4_delay,(a1)+
; ** Form 5 **
  lea     mgv_object1_shape5_coordinates(pc),a0
  move.l  a0,(a1)+           ;Zeiger auf Objekt-Tabelle
  lea     mgv_object2_shape5_coordinates(pc),a0
  move.l  a0,(a1)+           ;Zeiger auf Koords-Tabelle
  lea     mgv_object3_shape5_coordinates(pc),a0
  move.l  a0,(a1)+           ;Zeiger auf Koords-Tabelle
  moveq   #mgv_object1_shape5_x_rotation_speed,d2
  move.w  d2,(a1)+           ;X-Achse
  moveq   #mgv_object1_shape5_y_rotation_speed,d2
  move.w  d2,(a1)+           ;Y-Achse
  moveq   #mgv_object1_shape5_z_rotation_speed,d2
  move.w  d2,(a1)+           ;Z-Achse
  moveq   #mgv_object2_shape5_x_rotation_speed,d2
  move.w  d2,(a1)+           ;X-Achse
  moveq   #mgv_object2_shape5_y_rotation_speed,d2
  move.w  d2,(a1)+           ;Y-Achse
  moveq   #mgv_object2_shape5_z_rotation_speed,d2
  move.w  d2,(a1)+           ;Z-Achse
  moveq   #mgv_object3_shape5_x_rotation_speed,d2
  move.w  d2,(a1)+           ;X-Achse
  moveq   #mgv_object3_shape5_y_rotation_speed,d2
  move.w  d2,(a1)+           ;Y-Achse
  moveq   #mgv_object3_shape5_z_rotation_speed,d2
  move.w  d2,(a1)+           ;Z-Achse
  move.w  #mgv_morph_shape5_delay,(a1)+

; ** Form 6 **
  lea     mgv_object1_shape6_coordinates(pc),a0
  move.l  a0,(a1)+           ;Zeiger auf Objekt-Tabelle
  lea     mgv_object2_shape6_coordinates(pc),a0
  move.l  a0,(a1)+           ;Zeiger auf Koords-Tabelle
  lea     mgv_object3_shape6_coordinates(pc),a0
  move.l  a0,(a1)+           ;Zeiger auf Koords-Tabelle
  moveq   #mgv_object1_shape6_x_rotation_speed,d2
  move.w  d2,(a1)+           ;X-Achse
  moveq   #mgv_object1_shape6_y_rotation_speed,d2
  move.w  d2,(a1)+           ;Y-Achse
  moveq   #mgv_object1_shape6_z_rotation_speed,d2
  move.w  d2,(a1)+           ;Z-Achse
  moveq   #mgv_object2_shape6_x_rotation_speed,d2
  move.w  d2,(a1)+           ;X-Achse
  moveq   #mgv_object2_shape6_y_rotation_speed,d2
  move.w  d2,(a1)+           ;Y-Achse
  moveq   #mgv_object2_shape6_z_rotation_speed,d2
  move.w  d2,(a1)+           ;Z-Achse
  moveq   #mgv_object3_shape6_x_rotation_speed,d2
  move.w  d2,(a1)+           ;X-Achse
  moveq   #mgv_object3_shape6_y_rotation_speed,d2
  move.w  d2,(a1)+           ;Y-Achse
  moveq   #mgv_object3_shape6_z_rotation_speed,d2
  move.w  d2,(a1)+           ;Z-Achse
  IFEQ mgv_morph_loop_enabled
    move.w  #mgv_morph_shape6_delay,(a1)
  ELSE
    move.w  #mgv_morph_shape6_delay,(a1)+

; ** Form 7 **
    lea     mgv_object1_shape7_coordinates(pc),a0
    move.l  a0,(a1)+           ;Zeiger auf Objekt-Tabelle
    lea     mgv_object2_shape7_coordinates(pc),a0
    move.l  a0,(a1)+           ;Zeiger auf Koords-Tabelle
    lea     mgv_object3_shape7_coordinates(pc),a0
    move.l  a0,(a1)+           ;Zeiger auf Koords-Tabelle
    moveq   #mgv_object1_shape7_x_rotation_speed,d2
    move.w  d2,(a1)+           ;X-Achse
    moveq   #mgv_object1_shape7_y_rotation_speed,d2
    move.w  d2,(a1)+           ;Y-Achse
    moveq   #mgv_object1_shape7_z_rotation_speed,d2
    move.w  d2,(a1)+           ;Z-Achse
    moveq   #mgv_object2_shape7_x_rotation_speed,d2
    move.w  d2,(a1)+           ;X-Achse
    moveq   #mgv_object2_shape7_y_rotation_speed,d2
    move.w  d2,(a1)+           ;Y-Achse
    moveq   #mgv_object2_shape7_z_rotation_speed,d2
    move.w  d2,(a1)+           ;Z-Achse
    moveq   #mgv_object3_shape7_x_rotation_speed,d2
    move.w  d2,(a1)+           ;X-Achse
    moveq   #mgv_object3_shape7_y_rotation_speed,d2
    move.w  d2,(a1)+           ;Y-Achse
    moveq   #mgv_object3_shape7_z_rotation_speed,d2
    move.w  d2,(a1)+           ;Z-Achse
    move.w  #mgv_morph_shape7_delay,(a1)
  ENDC
  rts

  IFEQ mgv_premorph_enabled
    CNOP 0,4
mgv_init_start_shape
    bsr     mgv_morph_objects
    tst.w   mgv_morph_active(a3) ;Morphing beendet?
    beq.s   mgv_init_start_shape ;Nein -> verzweige
    rts
  ENDC

; ** Farbtabelle initialisieren **
; --------------------------------
  CNOP 0,4
mgv_init_color_table
  lea     pf1_color_table(pc),a0    ;Zeiger auf Farbtabelle
  lea     mgv_glenz_color_table(pc),a1 ;Farben der einzelnen Glenz-Objekte
; ** Reinfarben des 1. Glenz **
  move.l  (a1)+,2*LONGWORDSIZE(a0) ;COLOR02
  move.l  (a1)+,3*LONGWORDSIZE(a0) ;COLOR03
  move.l  (a1)+,4*LONGWORDSIZE(a0) ;COLOR04
  move.l  (a1)+,5*LONGWORDSIZE(a0) ;COLOR05
; ** Reinfarben des 2. Glenz **
  move.l  (a1)+,8*LONGWORDSIZE(a0) ;COLOR08
  move.l  (a1)+,9*LONGWORDSIZE(a0) ;COLOR09
  move.l  (a1)+,16*LONGWORDSIZE(a0) ;COLOR16
  move.l  (a1)+,17*LONGWORDSIZE(a0) ;COLOR17
; ** Reinfarben des 3. Glenz **
  move.l  (a1)+,32*LONGWORDSIZE(a0) ;COLOR32
  move.l  (a1)+,33*LONGWORDSIZE(a0) ;COLOR33
  move.l  (a1)+,64*LONGWORDSIZE(a0) ;COLOR64
  move.l  (a1),65*LONGWORDSIZE(a0) ;COLOR65

; ** Mischfarben aus 1. und 2. Glenz **
  moveq   #2,d6              ;COLOR02
  moveq   #8,d7              ;COLOR08  10
  bsr     mgv_get_colorvalues_average
  moveq   #2,d6              ;COLOR02
  moveq   #9,d7              ;COLOR09  11
  bsr     mgv_get_colorvalues_average
  moveq   #2,d6              ;COLOR02
  moveq   #16,d7             ;COLOR16  18
  bsr     mgv_get_colorvalues_average
  moveq   #2,d6              ;COLOR02
  moveq   #17,d7             ;COLOR17  19
  bsr     mgv_get_colorvalues_average
  moveq   #3,d6              ;COLOR03
  moveq   #9,d7              ;COLOR09  12
  bsr     mgv_get_colorvalues_average
  moveq   #3,d6              ;COLOR03
  moveq   #17,d7             ;COLOR17  20
  bsr     mgv_get_colorvalues_average
  moveq   #4,d6              ;COLOR04
  moveq   #9,d7              ;COLOR09  13
  bsr     mgv_get_colorvalues_average
  moveq   #4,d6              ;COLOR04
  moveq   #17,d7             ;COLOR17  21
  bsr     mgv_get_colorvalues_average
  moveq   #5,d6              ;COLOR05
  moveq   #9,d7              ;COLOR09  14
  bsr     mgv_get_colorvalues_average
  moveq   #5,d6              ;COLOR05
  moveq   #17,d7             ;COLOR17  22
  bsr     mgv_get_colorvalues_average

  moveq   #16,d6             ;COLOR16
  moveq   #8,d7              ;COLOR08  24
  bsr     mgv_get_colorvalues_average
  moveq   #16,d6             ;COLOR16
  moveq   #9,d7              ;COLOR09  25
  bsr     mgv_get_colorvalues_average
  moveq   #16,d6             ;COLOR16
  moveq   #10,d7             ;COLOR10  26
  bsr     mgv_get_colorvalues_average
  moveq   #16,d6             ;COLOR16
  moveq   #11,d7             ;COLOR11  27
  bsr     mgv_get_colorvalues_average
  moveq   #16,d6             ;COLOR16
  moveq   #12,d7             ;COLOR12  28
  bsr     mgv_get_colorvalues_average
  moveq   #16,d6             ;COLOR16
  moveq   #13,d7             ;COLOR13  29
  bsr     mgv_get_colorvalues_average
  moveq   #16,d6             ;COLOR16
  moveq   #14,d7             ;COLOR14  30
  bsr     mgv_get_colorvalues_average
; ** Mischfarben aus 1. und 3. Glenz **
  moveq   #2,d6              ;COLOR02
  moveq   #32,d7             ;COLOR32  34
  bsr     mgv_get_colorvalues_average
  moveq   #2,d6              ;COLOR02
  moveq   #33,d7             ;COLOR33  35
  bsr     mgv_get_colorvalues_average
  moveq   #2,d6              ;COLOR02
  moveq   #64,d7             ;COLOR64  66
  bsr     mgv_get_colorvalues_average
  moveq   #2,d6              ;COLOR02
  moveq   #65,d7             ;COLOR65  67
  bsr     mgv_get_colorvalues_average
  moveq   #3,d6              ;COLOR03
  moveq   #33,d7             ;COLOR33  36
  bsr     mgv_get_colorvalues_average
  moveq   #3,d6              ;COLOR03
  moveq   #65,d7             ;COLOR65  68
  bsr     mgv_get_colorvalues_average
  moveq   #4,d6              ;COLOR04
  moveq   #33,d7             ;COLOR33  37
  bsr     mgv_get_colorvalues_average
  moveq   #4,d6              ;COLOR04
  moveq   #65,d7             ;COLOR65  69
  bsr     mgv_get_colorvalues_average
  moveq   #5,d6              ;COLOR05
  moveq   #33,d7             ;COLOR33  38
  bsr     mgv_get_colorvalues_average
  moveq   #5,d6              ;COLOR05
  moveq   #65,d7             ;COLOR65  70
  bsr     mgv_get_colorvalues_average

; ** Mischfarben aus 2. und 3. Glenz **
  moveq   #08,d6             ;COLOR08
  moveq   #32,d7             ;COLOR32  40
  bsr     mgv_get_colorvalues_average
  moveq   #08,d6             ;COLOR08
  moveq   #33,d7             ;COLOR33  41
  bsr     mgv_get_colorvalues_average
  moveq   #08,d6             ;COLOR08
  moveq   #64,d7             ;COLOR64  72
  bsr     mgv_get_colorvalues_average
  moveq   #08,d6             ;COLOR08
  moveq   #65,d7             ;COLOR65  73
  bsr     mgv_get_colorvalues_average
  moveq   #09,d6             ;COLOR09
  moveq   #65,d7             ;COLOR65  74
  bsr     mgv_get_colorvalues_average
  moveq   #16,d6             ;COLOR16
  moveq   #32,d7             ;COLOR32  48
  bsr     mgv_get_colorvalues_average
  moveq   #16,d6             ;COLOR16
  moveq   #33,d7             ;COLOR33  49
  bsr     mgv_get_colorvalues_average
  moveq   #16,d6             ;COLOR16
  moveq   #64,d7             ;COLOR64  80
  bsr     mgv_get_colorvalues_average
  moveq   #16,d6             ;COLOR16
  moveq   #65,d7             ;COLOR65  81
  bsr     mgv_get_colorvalues_average
  moveq   #17,d6             ;COLOR17
  moveq   #33,d7             ;COLOR33  50
  bsr     mgv_get_colorvalues_average
  moveq   #17,d6             ;COLOR17
  moveq   #65,d7             ;COLOR65  82
  bsr     mgv_get_colorvalues_average

; ** Mischfarben aus 1., 2. und 3. Glenz **
  moveq   #32,d6             ;COLOR32
  moveq   #10,d7             ;COLOR10  42
  bsr     mgv_get_colorvalues_average
  moveq   #32,d6             ;COLOR32
  moveq   #11,d7             ;COLOR11  43
  bsr     mgv_get_colorvalues_average
  moveq   #32,d6             ;COLOR32
  moveq   #12,d7             ;COLOR12  44
  bsr     mgv_get_colorvalues_average
  moveq   #32,d6             ;COLOR32
  moveq   #13,d7             ;COLOR13  45
  bsr     mgv_get_colorvalues_average
  moveq   #32,d6             ;COLOR32
  moveq   #14,d7             ;COLOR13  46
  bsr     mgv_get_colorvalues_average
  moveq   #32,d6             ;COLOR32
  moveq   #19,d7             ;COLOR19  51
  bsr     mgv_get_colorvalues_average
  moveq   #32,d6             ;COLOR32
  moveq   #20,d7             ;COLOR20  52
  bsr     mgv_get_colorvalues_average
  moveq   #32,d6             ;COLOR32
  moveq   #21,d7             ;COLOR21  53
  bsr     mgv_get_colorvalues_average
  moveq   #32,d6             ;COLOR32
  moveq   #22,d7             ;COLOR21  54
  bsr     mgv_get_colorvalues_average

  moveq   #32,d6             ;COLOR32
  moveq   #24,d7             ;COLOR24  56
  bsr     mgv_get_colorvalues_average
  moveq   #32,d6             ;COLOR32
  moveq   #25,d7             ;COLOR25  57
  bsr     mgv_get_colorvalues_average
  moveq   #32,d6             ;COLOR32
  moveq   #26,d7             ;COLOR26  58
  bsr     mgv_get_colorvalues_average
  moveq   #32,d6             ;COLOR32
  moveq   #27,d7             ;COLOR27  59
  bsr     mgv_get_colorvalues_average
  moveq   #32,d6             ;COLOR32
  moveq   #28,d7             ;COLOR28  60
  bsr     mgv_get_colorvalues_average
  moveq   #32,d6             ;COLOR32
  moveq   #29,d7             ;COLOR29  61
  bsr     mgv_get_colorvalues_average
  moveq   #32,d6             ;COLOR32
  moveq   #30,d7             ;COLOR30  62
  bsr     mgv_get_colorvalues_average

  moveq   #64,d6             ;COLOR64
  moveq   #11,d7             ;COLOR11  75
  bsr     mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #12,d7             ;COLOR12  76
  bsr     mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #13,d7             ;COLOR13  77
  bsr     mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #14,d7             ;COLOR13  78
  bsr     mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #19,d7             ;COLOR19  83
  bsr     mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #20,d7             ;COLOR20  84
  bsr     mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #21,d7             ;COLOR21  85
  bsr     mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #22,d7             ;COLOR22  86
  bsr     mgv_get_colorvalues_average

  moveq   #64,d6             ;COLOR64
  moveq   #24,d7             ;COLOR24  88
  bsr     mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #25,d7             ;COLOR25  89
  bsr     mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #26,d7             ;COLOR26  90
  bsr     mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #27,d7             ;COLOR27  91
  bsr     mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #28,d7             ;COLOR28  92
  bsr     mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #29,d7             ;COLOR29  93
  bsr     mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #30,d7             ;COLOR30  94
  bsr     mgv_get_colorvalues_average

  moveq   #64,d6             ;COLOR64
  moveq   #32,d7             ;COLOR32  96
  bsr     mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #33,d7             ;COLOR33  97
  bsr     mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #34,d7             ;COLOR34  98
  bsr     mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #35,d7             ;COLOR35  99
  bsr     mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #36,d7             ;COLOR36  100
  bsr     mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #37,d7             ;COLOR37  101
  bsr     mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #38,d7             ;COLOR38  102
  bsr.s   mgv_get_colorvalues_average

  moveq   #64,d6             ;COLOR64
  moveq   #40,d7             ;COLOR40  104
  bsr.s   mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #41,d7             ;COLOR41  105
  bsr.s   mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #42,d7             ;COLOR42  106
  bsr.s   mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #43,d7             ;COLOR43  107
  bsr.s   mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #44,d7             ;COLOR44  108
  bsr.s   mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #45,d7             ;COLOR45  109
  bsr.s   mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #46,d7             ;COLOR46  110
  bsr.s   mgv_get_colorvalues_average

  moveq   #64,d6             ;COLOR64
  moveq   #48,d7             ;COLOR48  112
  bsr.s   mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #49,d7             ;COLOR49  113
  bsr.s   mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #50,d7             ;COLOR50  114
  bsr.s   mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #51,d7             ;COLOR51  115
  bsr.s   mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #52,d7             ;COLOR52  116
  bsr.s   mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #53,d7             ;COLOR53  117
  bsr.s   mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #54,d7             ;COLOR54  118
  bsr.s   mgv_get_colorvalues_average

  moveq   #64,d6             ;COLOR64
  moveq   #56,d7             ;COLOR56  120
  bsr.s   mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #57,d7             ;COLOR57  121
  bsr.s   mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #58,d7             ;COLOR58  122
  bsr.s   mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #59,d7             ;COLOR59  123
  bsr.s   mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #60,d7             ;COLOR60  124
  bsr.s   mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #61,d7             ;COLOR61  125
  bsr.s   mgv_get_colorvalues_average
  moveq   #64,d6             ;COLOR64
  moveq   #62,d7             ;COLOR62  126

; Get-Colorvalues-Average-Routine
; a0 ... Farbtablelle mit RGB8-Werten
; d6 ... 1. Quellfarbnumbermer
; d7 ... 2. Quellfarbnumbermer
mgv_get_colorvalues_average
  moveq   #0,d0
  move.b  1(a0,d6.w*4),d0    ;1. Quellfarbe Rotanteil
  moveq   #TRUE,d1
  move.b  2(a0,d6.w*4),d1    ;1. Quellfarbe Grümanteil
  moveq   #TRUE,d2
  move.b  3(a0,d6.w*4),d2    ;1. Quellfarbe Blauanteil
  moveq   #TRUE,d3
  move.b  1(a0,d7.w*4),d3    ;2. Quellfarbe Rotanteil
  moveq   #TRUE,d4
  move.b  2(a0,d7.w*4),d4    ;2. Quellfarbe Grümanteil
  moveq   #TRUE,d5
  move.b  3(a0,d7.w*4),d5    ;2. Quellfarbe Blauanteil
  add.w   d7,d6              ;Quellfarbnummern addieren
  add.w   d3,d0              ;Rotanteile addieren
  lsr.w   #1,d0              ;/2
  move.b  d0,1(a0,d6.w*4)    ;Rotanteil-Mischwert retten
  add.w   d4,d1              ;Grünteile addieren
  lsr.w   #1,d1              ;/2
  move.b  d1,2(a0,d6.w*4)    ;Grünanteil-Mischwert retten
  add.w   d5,d2              ;Blauanteile addieren
  lsr.w   #1,d2              ;/2
  move.b  d2,3(a0,d6.w*4)    ;Blauanteil-Mischwert retten
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
  COP_INIT_COLORHI COLOR00,32,pf1_color_table
  COP_SELECT_COLORHI_BANK 1,v_BPLCON3BITS1
  COP_INIT_COLORHI COLOR00,32
  COP_SELECT_COLORHI_BANK 2,v_BPLCON3BITS1
  COP_INIT_COLORHI COLOR00,32
  COP_SELECT_COLORHI_BANK 3,v_BPLCON3BITS1
  COP_INIT_COLORHI COLOR00,32

  COP_SELECT_COLORLO_BANK 0,v_BPLCON3BITS2
  COP_INIT_COLORLO COLOR00,32,pf1_color_table
  COP_SELECT_COLORLO_BANK 1,v_BPLCON3BITS2
  COP_INIT_COLORLO COLOR00,32
  COP_SELECT_COLORLO_BANK 2,v_BPLCON3BITS2
  COP_INIT_COLORLO COLOR00,32
  COP_SELECT_COLORLO_BANK 3,v_BPLCON3BITS2
  COP_INIT_COLORLO COLOR00,32
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
  bsr     mgv_pre_rotate_objects
  bsr     mgv_rotate_objects
  bsr     mgv_morph_objects
  bsr     mgv_draw_lines
  bsr     mgv_fill_playfield1
  bsr     mgv_set_second_copperlist_jump
  bsr     scroll_playfield_bottom_in
  bsr     scroll_playfield_bottom_out
  bsr     mgv_control_counters
  jsr     mouse_handler
  tst.l   d0                 ;Abbruch ?
  bne.s   fast_exit          ;Ja -> verzweige
  tst.w   fx_active(a3)      ;Effekte beendet ?
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
  moveq   #0,d0
  move.l  d0,a3
  moveq   #7-1,d7
mgv_clear_playfield1_loop
  REPT ((pf1_plane_width*visible_lines_number*pf1_depth3)/56)/7
  movem.l d0-d6/a0-a6,-(a7)  ;56 Bytes löschen
  ENDR
  dbf     d7,mgv_clear_playfield1_loop
; Rest 280 Bytes
  movem.l d0-d6/a0-a6,-(a7)
  movem.l d0-d6/a0-a6,-(a7)
  movem.l d0-d6/a0-a6,-(a7)
  movem.l d0-d6/a0-a6,-(a7)
  movem.l d0-d6/a0-a6,-(a7)
  move.l  variables+save_a7(pc),a7 ;Alter Stackpointer
  movem.l (a7)+,a3-a6
  rts

; ** 3D-Pre-Rotation **
; ---------------------
  CNOP 0,4
mgv_pre_rotate_objects
  tst.w   mgv_pre_rotate_active(a3) ;Pre-Rotation an ?
  bne.s   mgv_no_pre_rotate_objects ;Nein -> verzweige
  movem.l a4-a6,-(a7)
  moveq   #0,d0           ;32-Bit-Zugriff
  move.w  mgv_morph_shapes_table_start(a3),d0 ;Startwert
  subq.w  #1,d0
  MULUF.W mgv_morph_shape_SIZE,d0,d1 ;Offset in Morph-Shapes-Tabelle
  lea     mgv_morph_shapes_table(pc),a4 ;Tabelle mit Adressen der Objekttabellen
  add.l   d0,a4
; ** Objekt 1 **
  move.l  (a4)+,a0           ;Koordinaten des Objekts
  lea     mgv_object1_coordinates(pc),a1 ;Ziel-Koord.-Tab.
  lea     mgv_object1_x_pre_rotation_angle(a3),a5
  lea     mgv_object1_variable_x_pre_rotation_speed(a3),a6
  moveq   #mgv_object1_edge_points_number-1,d7 ;Anzahl der Punkte
  bsr.s   mgv_pre_rotation
; ** Objekt 2 **
  move.l  (a4)+,a0           ;Koordinaten des Objekts
  lea     mgv_object2_coordinates(pc),a1 ;Ziel-Koord.-Tab.
  lea     mgv_object2_x_pre_rotation_angle(a3),a5
  lea     mgv_object2_variable_x_pre_rotation_speed(a3),a6
  moveq   #mgv_object2_edge_points_number-1,d7 ;Anzahl der Punkte
  bsr.s   mgv_pre_rotation
; ** Objekt 3 **
  move.l  (a4),a0            ;Koordinaten des Objekts
  lea     mgv_object3_coordinates(pc),a1 ;Ziel-Koord.-Tab.
  lea     mgv_object3_x_pre_rotation_angle(a3),a5
  lea     mgv_object3_variable_x_pre_rotation_speed(a3),a6
  moveq   #mgv_object3_edge_points_number-1,d7 ;Anzahl der Punkte
  bsr.s   mgv_pre_rotation
  movem.l (a7)+,a4-a6
mgv_no_pre_rotate_objects
  rts

; ** Pre-Rotate-Routine **
; ------------------------
; d7 ... Anzahl der Punkte
; a0 ... Koodinaten des Objekts
; a1 ... Koordinaten der Linien
; a5 ... Zeiger auf Variable x_rotation_angle
; a6 ... Zeiger auf Variable variable_x_rotation_speed
  CNOP 0,4
mgv_pre_rotation
  move.w  (a5),d1            ;X-Winkel
  move.w  d1,d0              
  lea     sine_table,a2  
  move.w  (a2,d0.w*2),d4     ;sin(a)
  MOVEF.W sine_table_length-1,d3
  add.w   #sine_table_length/4,d0 ;+ 90 Grad
  swap    d4                 ;Bits 16-31 = sin(a)
  and.w   d3,d0              ;Übertrag entfernen
  move.w  (a2,d0.w*2),d4     ;Bits  0-15 = cos(a)
  add.w   (a6)+,d1           ;nächster X-Winkel
  and.w   d3,d1              ;Übertrag entfernen
  move.w  d1,(a5)+           
  move.w  (a5),d1            ;Y-Winkel
  move.w  d1,d0              
  move.w  (a2,d0.w*2),d5     ;sin(b)
  add.w   #sine_table_length/4,d0 ;+ 90 Grad
  swap    d5                 ;Bits 16-31 = sin(b)
  and.w   d3,d0              ;Übertrag entfernen
  move.w  (a2,d0.w*2),d5     ;Bits  0-15 = cos(b)
  add.w   (a6)+,d1           ;nächster Y-Winkel
  and.w   d3,d1              ;Übertrag entfernen
  move.w  d1,(a5)+           
  move.w  (a5),d1            ;Z-Winkel
  move.w  d1,d0              
  move.w  (a2,d0.w*2),d6     ;sin(c)
  add.w   #sine_table_length/4,d0 ;+ 90 Grad
  swap    d6                 ;Bits 16-31 = sin(c)
  and.w   d3,d0              ;Übertrag entfernen
  move.w  (a2,d0.w*2),d6     ;Bits  0-15 = cos(c)
  add.w   (a6),d1            ;nächster Z-Winkel
  and.w   d3,d1              ;Übertrag entfernen
  move.w  d1,(a5)            
mgv_pre_rotation_loop
  move.w  (a0)+,d0           ;X-Koord.
  move.l  d7,a2              
  move.w  (a0)+,d1           ;Y-Koord.
  move.w  (a0)+,d2           ;Z-Koord.
  ROTATE_X_AXIS
  ROTATE_Y_AXIS
  ROTATE_Z_AXIS
  moveq   #-8,d3             ;Nur Werte, die ein Vielfaches von 8 sind
  and.b   d3,d0              ;Bits 0-2 löschen
  move.w  d0,(a1)+           ;X-Pos.
  and.b   d3,d1
  move.w  d1,(a1)+           ;Y-Pos.
  and.b   d3,d2
  move.l  a2,d7              ;Schleifenzähler 
  move.w  d2,(a1)+           ;Z-Pos.
  dbf     d7,mgv_pre_rotation_loop
  rts

; ** 3D-Rotation **
; -----------------
  CNOP 0,4
mgv_rotate_objects
  movem.l a4-a5,-(a7)
  move.w  mgv_rotation_x_angle(a3),d1 ;X-Winkel
  move.w  d1,d0              
  lea     sine_table,a2  
  move.w  (a2,d0.w*2),d4     ;sin(a)
  move.w  #sine_table_length/4,a4
  MOVEF.W sine_table_length-1,d3
  add.w   a4,d0              ;+ 90 Grad
  swap    d4                 ;Bits 16-31 = sin(a)
  and.w   d3,d0              ;Übertrag entfernen
  move.w  (a2,d0.w*2),d4     ;Bits  0-15 = cos(a)
  addq.w  #mgv_rotation_x_angle_speed,d1 ;nächster X-Winkel
  and.w   d3,d1              ;Übertrag entfernen
  move.w  d1,mgv_rotation_x_angle(a3) 
  move.w  mgv_rotation_y_angle(a3),d1 ;Y-Winkel
  move.w  d1,d0              
  move.w  (a2,d0.w*2),d5     ;sin(b)
  add.w   a4,d0              ;+ 90 Grad
  swap    d5                 ;Bits 16-31 = sin(b)
  and.w   d3,d0              ;Übertrag entfernen
  move.w  (a2,d0.w*2),d5     ;Bits  0-15 = cos(b)
  addq.w  #mgv_rotation_y_angle_speed,d1 ;nächster Y-Winkel
  and.w   d3,d1              ;Übertrag entfernen
  move.w  d1,mgv_rotation_y_angle(a3) 
  move.w  mgv_rotation_z_angle(a3),d1 ;Z-Winkel
  move.w  d1,d0              
  move.w  (a2,d0.w*2),d6     ;sin(c)
  add.w   a4,d0              ;+ 90 Grad
  swap    d6                 ;Bits 16-31 = sin(c)
  and.w   d3,d0              ;Übertrag entfernen
  move.w  (a2,d0.w*2),d6     ;Bits  0-15 = cos(c)
  addq.w  #mgv_rotation_z_angle_speed,d1 ;nächster Z-Winkel
  and.w   d3,d1              ;Übertrag entfernen
  move.w  d1,mgv_rotation_z_angle(a3) 
; ** Objekt 1 **
  lea     mgv_object1_coordinates(pc),a0 ;Koordinaten der Linien
  lea     mgv_rotation_xy_coordinates(pc),a1 ;Koord.-Tab.
  moveq   #mgv_object1_edge_points_number-1,d7 ;Anzahl der Punkte
  bsr.s   mgv_rotation
; ** Objekt 2 **
  lea     mgv_object2_coordinates(pc),a0 ;Koordinaten der Linien
  moveq   #mgv_object2_edge_points_number-1,d7 ;Anzahl der Punkte
  bsr.s   mgv_rotation
; ** Objekt 3 **
  lea     mgv_object3_coordinates(pc),a0 ;Koordinaten der Linien
  moveq   #mgv_object3_edge_points_number-1,d7 ;Anzahl der Punkte
  bsr.s   mgv_rotation
  movem.l (a7)+,a4-a5
  rts

; ** Rotate-Routine **
; --------------------
  CNOP 0,4
mgv_rotation
  move.w  #mgv_rotation_d*8,a4 ;d
  move.w  #mgv_rotation_xy_center,a5 ;X+Y-Mittelpunkt
mgv_rotation_loop
  move.w  (a0)+,d0           ;X-Koord.
  move.l  d7,a2              
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
  divs.w  d2,d1              ;y' = (y*d)/(z+d)
  move.l  a2,d7              ;Schleifenzähler 
  add.w   a5,d1              ;y' + Y-Mittelpunkt
  move.w  d1,(a1)+           ;Y-Pos.
  dbf     d7,mgv_rotation_loop
  rts

; ** Form der Objekte ändern **
; -----------------------------
  CNOP 0,4
mgv_morph_objects
  tst.w   mgv_morph_active(a3) ;Morphing an ?
  bne     mgv_no_morph_objects ;Nein -> verzweige
  move.w  mgv_morph_shapes_table_start(a3),d1 ;Startwert
  cmp.w   #mgv_morph_shapes_number,d1 ;Ende der Tabelle ?
  IFEQ mgv_morph_loop_enabled
    bne.s  mgv_no_restart_morph_shapes_table_start
    moveq  #TRUE,d1          ;Neustart
mgv_no_restart_morph_shapes_table_start
  ELSE
    beq.s   mgv_morph_objects_disable ;Ja -> verzweige
  ENDC
  moveq   #TRUE,d2           ;Koordinatenzähler
  moveq   #TRUE,d3           ;32-Bit-Zugriff
  move.w  d1,d3              ;Startwert retten
  MULUF.W mgv_morph_shape_SIZE,d3,d0
  lea     mgv_morph_shapes_table(pc),a2 ;Tabelle mit Adressen der Objekttabellen
  add.l   d3,a2              ;Offset in Morph-Shapes-Tabelle
; ** Object 1 **
  lea     mgv_object1_coordinates(pc),a0 ;Aktuelle Objektdaten
  move.l  (a2)+,a1           ;Zeiger auf Tabelle 
  MOVEF.W (mgv_object1_edge_points_number*3)-1,d7 ;Anzahl der Koordinaten
  bsr.s   mgv_morph_objects_loop
; ** Object 2 **
  lea     mgv_object2_coordinates(pc),a0 ;Aktuelle Objektdaten
  move.l  (a2)+,a1           ;Zeiger auf Tabelle 
  MOVEF.W (mgv_object2_edge_points_number*3)-1,d7 ;Anzahl der Koordinaten
  bsr.s   mgv_morph_objects_loop
; ** Object 3 **
  lea     mgv_object3_coordinates(pc),a0 ;Aktuelle Objektdaten
  move.l  (a2)+,a1           ;Zeiger auf Tabelle 
  moveq   #(mgv_object3_edge_points_number*3)-1,d7 ;Anzahl der Koordinaten
  bsr.s   mgv_morph_objects_loop

  tst.w   d2                 ;Morhing beendet?
  bne.s   mgv_no_morph_objects ;Nein -> verzweige
  addq.w  #1,d1              ;nächster Eintrag in Objekttablelle
  move.w  d1,mgv_morph_shapes_table_start(a3) 
  move.l  (a2)+,mgv_object1_variable_x_pre_rotation_speed(a3) ;Neue X,Y,Z-Rotationsgeschwindigkeiten setzen
  move.l  (a2)+,mgv_object1_variable_z_pre_rotation_speed(a3)
  move.l  (a2)+,mgv_object2_variable_y_pre_rotation_speed(a3)
  move.l  (a2)+,mgv_object3_variable_x_pre_rotation_speed(a3)
  move.w  (a2)+,mgv_object3_variable_z_pre_rotation_speed(a3)
  move.w  (a2),mgv_morph_delay_counter(a3) ;Zähler zurücksetzen
  moveq   #0,d0
  move.w  d0,mgv_pre_rotate_active(a3) ;Pre-Rotation an
  move.l  d0,mgv_object1_x_pre_rotation_angle(a3) ;X,Y,Z-Winkel zurücksetzen
  move.l  d0,mgv_object1_z_pre_rotation_angle(a3)
  move.l  d0,mgv_object2_y_pre_rotation_angle(a3)
  move.l  d0,mgv_object3_x_pre_rotation_angle(a3)
  move.w  d0,mgv_object3_z_pre_rotation_angle(a3)
mgv_morph_objects_disable
  moveq   #FALSE,d0
  move.w  d0,mgv_morph_active(a3) ;Morhing aus
mgv_no_morph_objects
  rts

; d7 ... Anzahl der Koordinaten
; a0 ... Aktuelle Objektdaten
; a1 ... Ziel-Objektdaten
  CNOP 0,4
mgv_morph_objects_loop
  move.w  (a0),d0            ;aktuelle Koordinate lesen
  cmp.w   (a1)+,d0           ;mit Ziel-Koordinate vergleichen
  beq.s   mgv_morph_objects_next_coordinate ;Wenn aktuelle Koordinate = Ziel-Koordinate, dann verzweige
  bgt.s   mgv_morph_objects_zoom_size ;Wenn aktuelle Koordinate < Ziel-Koordinate, dann Koordinate erhöhen
mgv_morph_objects_reduce_size
  addq.w  #mgv_morph_speed,d0 ;aktuelle Koordinate erhöhen
  bra.s   mgv_morph_objects_save_coordinate
  CNOP 0,4
mgv_morph_objects_zoom_size
  subq.w  #mgv_morph_speed,d0 ;aktuelle Koordinate verringern
mgv_morph_objects_save_coordinate
  move.w  d0,(a0)            
  addq.w  #1,d2              ;Koordinatenzähler erhöhen
mgv_morph_objects_next_coordinate
  addq.w  #2,a0              ;Nächste Koordinate
  dbf     d7,mgv_morph_objects_loop
  rts

; ** Linien ziehen **
; -------------------
  CNOP 0,4
mgv_draw_lines
  movem.l a3-a6,-(a7)
  bsr     mgv_draw_lines_init
  lea     mgv_objects_info_table(pc),a0 ;Zeiger auf Info-Daten zum Objekt
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
  MOVEF.W mgv_objects_faces_number-1,d7 ;Anzahl der Flächen
mgv_draw_lines_loop1
; ** Z-Koordinate des Vektors N durch das Kreuzprodukt u x v berechnen **
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
  cmp.w   #1,d7              ;Hintere Fläche von Object1 ?
  beq.s   mgv_draw_lines_loop2 ;Ja -> verzweige
  lsr.w   #2,d7              ;COLOR32/64 -> COLOR00/01
  beq     mgv_draw_lines_no_face ;Wenn COLOR00 -> verzweige
mgv_draw_lines_loop2
  move.w  (a5)+,d0           ;Startwerte der Punkte P1,P2
  move.w  (a5),d2
  movem.w (a1,d0.w*2),d0-d1  ;P1(x,y)
  movem.w (a1,d2.w*2),d2-d3  ;P2(x,y)
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
  cmp.w   #4,d7              ;Plane 3 ?
  beq.s   mgv_draw_lines_single_line ;Ja -> verzweige
  add.l   d5,d1              ;nächste Plane
  cmp.w   #8,d7              ;Plane 4 ?
  beq.s   mgv_draw_lines_single_line ;Ja -> verzweige
  add.l   d5,d1              ;nächste Plane
  cmp.w   #16,d7             ;Plane 5 ?
  beq.s   mgv_draw_lines_single_line ;Ja -> verzweige
  add.l   d5,d1              ;nächste Plane
  cmp.w   #32,d7             ;Plane 6 ?
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
  swap    d7                 ;Flächenzähler 
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
  tst.w   spbi_active(a3)    ;Scroll-Playfield-Bottom-In an ?
  bne.s   no_scroll_playfield_bottom_in ;Nein -> verzweige
  move.w  spbi_y_angle(a3),d2 ;Y-Winkel
  cmp.w   #sine_table_length/4,d2 ;90 Grad ?
  bgt.s   spbi_finished      ;Ja -> verzweige
  lea     sine_table,a0  
  move.w  (a0,d2.w*2),d0     ;sin(w)
  muls.w  #spb_y_radius*2,d0 ;y'=(sin(w)*yr)/2^15
  swap    d0
  add.w   #spb_y_centre,d0   ;y' + Y-Mittelpunkt
  addq.w  #spbi_y_angle_speed,d2 ;nächster Y-Winkel
  move.w  d2,spbi_y_angle(a3) 
  MOVEF.W spb_max_VSTOP,d3
  bsr.s   spb_set_display_window
no_scroll_playfield_bottom_in
  rts
  CNOP 0,4
spbi_finished
  moveq   #FALSE,d0
  move.w  d0,spbi_active(a3) ;Scroll-Playfield-Bottom-In aus
  rts

; ** Playfield nach unten ausscrollen **
; --------------------------------------
  CNOP 0,4
scroll_playfield_bottom_out
  tst.w   spbo_active(a3)    ;Vert-Scroll-Playfild-Out an ?
  bne.s   no_scroll_playfield_bottom_out ;Nein -> verzweige
  move.w  spbo_y_angle(a3),d2 ;Y-Winkel
  cmp.w   #sine_table_length/2,d2 ;180 Grad ?
  bgt.s   spbo_finished      ;Ja -> verzweige
  lea     sine_table,a0  
  move.w  (a0,d2.w*2),d0     ;cos(w)
  muls.w  #spb_y_radius*2,d0 ;y'=(cos(w)*yr)/2^15
  swap    d0
  add.w   #spb_y_centre,d0   ;y' + Y-Mittelpunkt
  addq.w  #spbo_y_angle_speed,d2 ;nächster Y-Winkel
  move.w  d2,spbo_y_angle(a3) 
  MOVEF.W spb_max_VSTOP,d3
  bsr.s   spb_set_display_window
no_scroll_playfield_bottom_out
  rts
  CNOP 0,4
spbo_finished
  clr.w   fx_active(a3)      ;Effekte beendet
  moveq   #FALSE,d0
  move.w  d0,spbo_active(a3) ;Scroll-Playfield-Bottom-Out aus
  rts

  CNOP 0,4
spb_set_display_window
  move.l  cl2_construction2(a3),a1 
  moveq   #spb_min_VSTART,d1
  add.w   d0,d1              ;+ Y-Offset
  cmp.w   d3,d1              ;VSTOP-Maximum erreicht ?
  ble.s   spb_no_max_VSTOP1  ;Nein -> verzweige
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
  clr.w   mgv_morph_active(a3) ;Morphing an
  moveq   #FALSE,d1
  move.w  d1,mgv_pre_rotate_active(a3) ;Pre-Rotation aus
  cmp.w   #mgv_morph_shapes_number-1,mgv_morph_shapes_table_start(a3) ;Ende der Tabelle ?
  bne.s   mgv_morph_save_delay_counter ;Nein -> verzweige
  clr.w   spbo_active(a3)    ;Scroll-Playfield-Bottom-Out an
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
mgv_glenz_color_table
  INCLUDE "Daten:Asm-Sources.AGA/projects/Superglenz/colortables/3xGlenz-Colorgradient.ct"

; ** Objektdaten **
; -----------------
  CNOP 0,2
mgv_object1_coordinates
; ** Zoom-In **
  DS.W mgv_object1_edge_points_number*3
mgv_object2_coordinates
; ** Zoom-In **
  DS.W mgv_object2_edge_points_number*3
mgv_object3_coordinates
; ** Zoom-In **
  DS.W mgv_object3_edge_points_number*3

; ** Formen der Objekte **
; ------------------------
; ** Form 1 **
mgv_object1_shape1_coordinates
; ** Pyramide 70 % **
  DC.W 0,-(38*8),-(10*8)    ;P0
  DC.W 19*8,0,-(24*8)       ;P1
  DC.W 38*8,38*8,-(38*8)    ;P2
  DC.W 0,38*8,-(38*8)       ;P3
  DC.W -(38*8),38*8,-(38*8) ;P4
  DC.W -(19*8),0,-(24*8)    ;P5
  DC.W 0,-(38*8),10*8       ;P6
  DC.W 19*8,0,24*8          ;P7
  DC.W 38*8,38*8,38*8       ;P8
  DC.W 0,38*8,38*8          ;P9
  DC.W -(38*8),38*8,38*8    ;P10
  DC.W -(19*8),0,24*8       ;P11
mgv_object2_shape1_coordinates
; ** Kein Objekt **
  DS.W mgv_object2_edge_points_number*3
mgv_object3_shape1_coordinates
; ** Kein Objekt **
  DS.W mgv_object2_edge_points_number*3

; ** Form 2 **
mgv_object1_shape2_coordinates
; ** Pyramide 70 % **
  DC.W 0,-(38*8),-(10*8)    ;P0
  DC.W 19*8,0,-(24*8)       ;P1
  DC.W 38*8,38*8,-(38*8)    ;P2
  DC.W 0,38*8,-(38*8)       ;P3
  DC.W -(38*8),38*8,-(38*8) ;P4
  DC.W -(19*8),0,-(24*8)    ;P5
  DC.W 0,-(38*8),10*8       ;P6
  DC.W 19*8,0,24*8          ;P7
  DC.W 38*8,38*8,38*8       ;P8
  DC.W 0,38*8,38*8          ;P9
  DC.W -(38*8),38*8,38*8    ;P10
  DC.W -(19*8),0,24*8       ;P11
mgv_object2_shape2_coordinates
; ** Pyramide 50 % **
  DC.W 0,-(27*8),-(7*8)     ;P0
  DC.W 14*8,0,-(17*8)       ;P1
  DC.W 27*8,27*8,-(27*8)    ;P2
  DC.W 0,27*8,-(27*8)       ;P3
  DC.W -(27*8),27*8,-(27*8) ;P4
  DC.W -(14*8),0,-(17*8)    ;P5
  DC.W 0,-(27*8),7*8        ;P6
  DC.W 14*8,0,17*8          ;P7
  DC.W 27*8,27*8,27*8       ;P8
  DC.W 0,27*8,27*8          ;P9
  DC.W -(27*8),27*8,27*8    ;P10
  DC.W -(14*8),0,17*8       ;P11
mgv_object3_shape2_coordinates
; ** Kein Objekt **
  DS.W mgv_object2_edge_points_number*3

; ** Form 3 **
mgv_object1_shape3_coordinates
; ** Pyramide 70 % **
  DC.W 0,-(38*8),-(10*8)    ;P0
  DC.W 19*8,0,-(24*8)       ;P1
  DC.W 38*8,38*8,-(38*8)    ;P2
  DC.W 0,38*8,-(38*8)       ;P3
  DC.W -(38*8),38*8,-(38*8) ;P4
  DC.W -(19*8),0,-(24*8)    ;P5
  DC.W 0,-(38*8),10*8       ;P6
  DC.W 19*8,0,24*8          ;P7
  DC.W 38*8,38*8,38*8       ;P8
  DC.W 0,38*8,38*8          ;P9
  DC.W -(38*8),38*8,38*8    ;P10
  DC.W -(19*8),0,24*8       ;P11
mgv_object2_shape3_coordinates
; ** Pyramide 50 % **
  DC.W 0,-(27*8),-(7*8)     ;P0
  DC.W 14*8,0,-(17*8)       ;P1
  DC.W 27*8,27*8,-(27*8)    ;P2
  DC.W 0,27*8,-(27*8)       ;P3
  DC.W -(27*8),27*8,-(27*8) ;P4
  DC.W -(14*8),0,-(17*8)    ;P5
  DC.W 0,-(27*8),7*8        ;P6
  DC.W 14*8,0,17*8          ;P7
  DC.W 27*8,27*8,27*8       ;P8
  DC.W 0,27*8,27*8          ;P9
  DC.W -(27*8),27*8,27*8    ;P10
  DC.W -(14*8),0,17*8       ;P11
mgv_object3_shape3_coordinates
; ** Pyramide 30 % **
  DC.W 0,-(17*8),-(4*8)      ;P0
  DC.W 8*8,0,-(10*8)         ;P1
  DC.W 17*8,17*8,-(17*8)     ;P2
  DC.W 0,17*8,-(17*8)        ;P3
  DC.W -(17*8),17*8,-(17*8)  ;P4
  DC.W -(8*8),0,-(10*8)      ;P5
  DC.W 0,-(17*8),4*8         ;P6
  DC.W 8*8,0,10*8            ;P7
  DC.W 17*8,17*8,17*8        ;P8
  DC.W 0,17*8,17*8           ;P9
  DC.W -(17*8),17*8,17*8     ;P10
  DC.W -(8*8),0,10*8         ;P11

; ** Form 4 **
mgv_object1_shape4_coordinates
; ** Polygon 50 % **
  DC.W 0,-(23*8),7*8         ;P0
  DC.W 12*8,0,7*8            ;P1
  DC.W 23*8,23*8,7*8         ;P2
  DC.W 0,23*8,7*8            ;P3
  DC.W -(23*8),23*8,7*8      ;P4
  DC.W -(12*8),0,7*8         ;P5
  DC.W 0,-(23*8),23*8        ;P6
  DC.W 12*8,0,23*8           ;P7
  DC.W 23*8,23*8,23*8        ;P8
  DC.W 0,23*8,23*8           ;P9
  DC.W -(23*8),23*8,23*8     ;P10
  DC.W -(12*8),0,23*8        ;P11
mgv_object2_shape4_coordinates
; ** Polygon2 70 % **
  DC.W 0,-(38*8),-(19*8)     ;P0
  DC.W 58*8,0,-(38*8)        ;P1
  DC.W 39*8,38*8,-(19*8)     ;P2
  DC.W 0,38*8,-(19*8)        ;P3
  DC.W -(39*8),38*8,-(19*8)  ;P4
  DC.W -(58*8),0,-(38*8)     ;P5
  DC.W 0,-(38*8),19*8        ;P6
  DC.W 58*8,0,38*8           ;P7
  DC.W 39*8,38*8,19*8        ;P8
  DC.W 0,38*8,19*8           ;P9
  DC.W -(39*8),38*8,19*8     ;P10
  DC.W -(58*8),0,38*8        ;P11
mgv_object3_shape4_coordinates
; ** Polygon 50 % **
  DC.W 0,-(23*8),-(23*8)     ;P24
  DC.W 12*8,0,-(23*8)        ;P25
  DC.W 23*8,23*8,-(23*8)     ;P26
  DC.W 0,23*8,-(23*8)        ;P27
  DC.W -(23*8),23*8,-(23*8)  ;P28
  DC.W -(12*8),0,-(23*8)     ;P29
  DC.W 0,-(23*8),-(7*8)      ;P30
  DC.W 12*8,0,-(7*8)         ;P31
  DC.W 23*8,23*8,-(7*8)      ;P32
  DC.W 0,23*8,-(7*8)         ;P33
  DC.W -(23*8),23*8,-(7*8)   ;P34
  DC.W -(12*8),0,-(7*8)      ;P35

; ** Form 5 **
mgv_object1_shape5_coordinates
; ** Polygon 100% **
  DC.W 0,-(46*8),-(19*8)     ;P0
  DC.W 23*8,0,-(19*8)        ;P1
  DC.W 46*8,46*8,-(19*8)     ;P2
  DC.W 0,46*8,-(19*8)        ;P3
  DC.W -(46*8),46*8,-(19*8)  ;P4
  DC.W -(23*8),0,-(19*8)     ;P5
  DC.W 0,-(46*8),19*8        ;P6
  DC.W 23*8,0,19*8           ;P7
  DC.W 46*8,46*8,19*8        ;P8
  DC.W 0,46*8,19*8           ;P9
  DC.W -(46*8),46*8,19*8     ;P10
  DC.W -(23*8),0,19*8        ;P11
mgv_object2_shape5_coordinates
; ** Polygon 100 % **
  DC.W 0,-(46*8),-(19*8)     ;P12
  DC.W 23*8,0,-(19*8)        ;P13
  DC.W 46*8,46*8,-(19*8)     ;P14
  DC.W 0,46*8,-(19*8)        ;P15
  DC.W -(46*8),46*8,-(19*8)  ;P16
  DC.W -(23*8),0,-(19*8)     ;P17
  DC.W 0,-(46*8),19*8        ;P18
  DC.W 23*8,0,19*8           ;P19
  DC.W 46*8,46*8,19*8        ;P20
  DC.W 0,46*8,19*8           ;P21
  DC.W -(46*8),46*8,19*8     ;P22
  DC.W -(23*8),0,19*8        ;P23
mgv_object3_shape5_coordinates
; ** Polygon 100 % **
  DC.W 0,-(46*8),-(19*8)     ;P24
  DC.W 23*8,0,-(19*8)        ;P25
  DC.W 46*8,46*8,-(19*8)     ;P26
  DC.W 0,46*8,-(19*8)        ;P27
  DC.W -(46*8),46*8,-(19*8)  ;P28
  DC.W -(23*8),0,-(19*8)     ;P29
  DC.W 0,-(46*8),19*8        ;P30
  DC.W 23*8,0,19*8           ;P31
  DC.W 46*8,46*8,19*8        ;P32
  DC.W 0,46*8,19*8           ;P33
  DC.W -(46*8),46*8,19*8     ;P34
  DC.W -(23*8),0,19*8        ;P35

; ** Form 6 **
mgv_object1_shape6_coordinates
; ** Polygon 80% **
  DC.W 0,-(37*8),28*8        ;P0
  DC.W 19*8,0,28*8           ;P1
  DC.W 37*8,37*8,28*8        ;P2
  DC.W 0,37*8,28*8           ;P3
  DC.W -(37*8),37*8,28*8     ;P4
  DC.W -(19*8),0,28*8        ;P5
  DC.W 0,-(37*8),45*8        ;P6
  DC.W 19*8,0,45*8           ;P7
  DC.W 37*8,37*8,45*8        ;P8
  DC.W 0,37*8,45*8           ;P9
  DC.W -(37*8),37*8,45*8     ;P10
  DC.W -(19*8),0,45*8        ;P11
mgv_object2_shape6_coordinates
; ** Polygon 80% **
  DC.W 0,-(37*8),-(9*8)      ;P0
  DC.W 19*8,0,-(9*8)         ;P1
  DC.W 37*8,37*8,-(9*8)      ;P2
  DC.W 0,37*8,-(9*8)         ;P3
  DC.W -(37*8),37*8,-(9*8)   ;P4
  DC.W -(19*8),0,-(9*8)      ;P5
  DC.W 0,-(37*8),9*8         ;P6
  DC.W 19*8,0,9*8            ;P7
  DC.W 37*8,37*8,9*8         ;P8
  DC.W 0,37*8,9*8            ;P9
  DC.W -(37*8),37*8,9*8      ;P10
  DC.W -(19*8),0,9*8         ;P11
mgv_object3_shape6_coordinates
; ** Polygon 80% **
  DC.W 0,-(37*8),-(45*8)     ;P0
  DC.W 19*8,0,-(45*8)        ;P1
  DC.W 37*8,37*8,-(45*8)     ;P2
  DC.W 0,37*8,-(45*8)        ;P3
  DC.W -(37*8),37*8,-(45*8)  ;P4
  DC.W -(19*8),0,-(45*8)     ;P5
  DC.W 0,-(37*8),-(28*8)     ;P6
  DC.W 19*8,0,-(28*8)        ;P7
  DC.W 37*8,37*8,-(28*8)     ;P8
  DC.W 0,37*8,-(28*8)        ;P9
  DC.W -(37*8),37*8,-(28*8)  ;P10
  DC.W -(19*8),0,-(28*8)     ;P11

  IFNE mgv_morph_loop_enabled
; ** Form 7 **
mgv_object1_shape7_coordinates
; ** Zoom-Out **
    DS.W mgv_object1_edge_points_number*3
mgv_object2_shape7_coordinates
; ** Zoom-Out **
    DS.W mgv_object2_edge_points_number*3
mgv_object3_shape7_coordinates
; ** Zoom-Out **
    DS.W mgv_object3_edge_points_number*3
  ENDC

; ** Information über Objekt **
; -----------------------------
  CNOP 0,4
mgv_objects_info_table
; ** Objekt 1 **
; ** 1. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object1_face1_color ;Farbe der Fläche
  DC.W mgv_object1_face1_lines_number-1 ;Anzahl der Linien
; ** 2. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object1_face2_color ;Farbe der Fläche
  DC.W mgv_object1_face2_lines_number-1 ;Anzahl der Linien
; ** 3. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object1_face3_color ;Farbe der Fläche
  DC.W mgv_object1_face3_lines_number-1 ;Anzahl der Linien
; ** 4. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object1_face4_color ;Farbe der Fläche
  DC.W mgv_object1_face4_lines_number-1 ;Anzahl der Linien

; ** 5. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object1_face5_color ;Farbe der Fläche
  DC.W mgv_object1_face5_lines_number-1 ;Anzahl der Linien
; ** 6. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object1_face6_color ;Farbe der Fläche
  DC.W mgv_object1_face6_lines_number-1 ;Anzahl der Linien
; ** 7. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object1_face7_color ;Farbe der Fläche
  DC.W mgv_object1_face7_lines_number-1 ;Anzahl der Linien
; ** 8. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object1_face8_color ;Farbe der Fläche
  DC.W mgv_object1_face8_lines_number-1 ;Anzahl der Linien

; ** 9. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object1_face9_color ;Farbe der Fläche
  DC.W mgv_object1_face9_lines_number-1 ;Anzahl der Linien
; ** 10. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object1_face10_color ;Farbe der Fläche
  DC.W mgv_object1_face10_lines_number-1 ;Anzahl der Linien
; ** 11. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object1_face11_color ;Farbe der Fläche
  DC.W mgv_object1_face11_lines_number-1 ;Anzahl der Linien
; ** 12. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object1_face12_color ;Farbe der Fläche
  DC.W mgv_object1_face12_lines_number-1 ;Anzahl der Linien

; ** 13. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object1_face13_color ;Farbe der Fläche
  DC.W mgv_object1_face13_lines_number-1 ;Anzahl der Linien
; ** 14. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object1_face14_color ;Farbe der Fläche
  DC.W mgv_object1_face14_lines_number-1 ;Anzahl der Linien
; ** 15. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object1_face15_color ;Farbe der Fläche
  DC.W mgv_object1_face15_lines_number-1 ;Anzahl der Linien
; ** 16. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object1_face16_color ;Farbe der Fläche
  DC.W mgv_object1_face16_lines_number-1 ;Anzahl der Linien

; ** 17. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object1_face17_color ;Farbe der Fläche
  DC.W mgv_object1_face17_lines_number-1 ;Anzahl der Linien
; ** 18. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object1_face18_color ;Farbe der Fläche
  DC.W mgv_object1_face18_lines_number-1 ;Anzahl der Linien
; ** 19. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object1_face19_color ;Farbe der Fläche
  DC.W mgv_object1_face19_lines_number-1 ;Anzahl der Linien
; ** 20. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object1_face20_color ;Farbe der Fläche
  DC.W mgv_object1_face20_lines_number-1 ;Anzahl der Linien

; ** Objekt 2 **
; ** 1. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object2_face1_color ;Farbe der Fläche
  DC.W mgv_object2_face1_lines_number-1 ;Anzahl der Linien
; ** 2. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object2_face2_color ;Farbe der Fläche
  DC.W mgv_object2_face2_lines_number-1 ;Anzahl der Linien
; ** 3. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object2_face3_color ;Farbe der Fläche
  DC.W mgv_object2_face3_lines_number-1 ;Anzahl der Linien
; ** 4. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object2_face4_color ;Farbe der Fläche
  DC.W mgv_object2_face4_lines_number-1 ;Anzahl der Linien

; ** 5. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object2_face5_color ;Farbe der Fläche
  DC.W mgv_object2_face5_lines_number-1 ;Anzahl der Linien
; ** 6. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object2_face6_color ;Farbe der Fläche
  DC.W mgv_object2_face6_lines_number-1 ;Anzahl der Linien
; ** 7. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object2_face7_color ;Farbe der Fläche
  DC.W mgv_object2_face7_lines_number-1 ;Anzahl der Linien
; ** 8. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object2_face8_color ;Farbe der Fläche
  DC.W mgv_object2_face8_lines_number-1 ;Anzahl der Linien

; ** 9. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object2_face9_color ;Farbe der Fläche
  DC.W mgv_object2_face9_lines_number-1 ;Anzahl der Linien
; ** 10. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object2_face10_color ;Farbe der Fläche
  DC.W mgv_object2_face10_lines_number-1 ;Anzahl der Linien
; ** 11. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object2_face11_color ;Farbe der Fläche
  DC.W mgv_object2_face11_lines_number-1 ;Anzahl der Linien
; ** 12. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object2_face12_color ;Farbe der Fläche
  DC.W mgv_object2_face12_lines_number-1 ;Anzahl der Linien

; ** 13. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object2_face13_color ;Farbe der Fläche
  DC.W mgv_object2_face13_lines_number-1 ;Anzahl der Linien
; ** 14. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object2_face14_color ;Farbe der Fläche
  DC.W mgv_object2_face14_lines_number-1 ;Anzahl der Linien
; ** 15. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object2_face15_color ;Farbe der Fläche
  DC.W mgv_object2_face15_lines_number-1 ;Anzahl der Linien
; ** 16. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object2_face16_color ;Farbe der Fläche
  DC.W mgv_object2_face16_lines_number-1 ;Anzahl der Linien

; ** 17. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object2_face17_color ;Farbe der Fläche
  DC.W mgv_object2_face17_lines_number-1 ;Anzahl der Linien
; ** 18. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object2_face18_color ;Farbe der Fläche
  DC.W mgv_object2_face18_lines_number-1 ;Anzahl der Linien
; ** 19. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object2_face19_color ;Farbe der Fläche
  DC.W mgv_object2_face19_lines_number-1 ;Anzahl der Linien
; ** 20. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object2_face20_color ;Farbe der Fläche
  DC.W mgv_object2_face20_lines_number-1 ;Anzahl der Linien

; ** Objekt 3 **
; ** 1. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object3_face1_color ;Farbe der Fläche
  DC.W mgv_object3_face1_lines_number-1 ;Anzahl der Linien
; ** 2. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object3_face2_color ;Farbe der Fläche
  DC.W mgv_object3_face2_lines_number-1 ;Anzahl der Linien
; ** 3. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object3_face3_color ;Farbe der Fläche
  DC.W mgv_object3_face3_lines_number-1 ;Anzahl der Linien
; ** 4. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object3_face4_color ;Farbe der Fläche
  DC.W mgv_object3_face4_lines_number-1 ;Anzahl der Linien

; ** 5. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object3_face5_color ;Farbe der Fläche
  DC.W mgv_object3_face5_lines_number-1 ;Anzahl der Linien
; ** 6. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object3_face6_color ;Farbe der Fläche
  DC.W mgv_object3_face6_lines_number-1 ;Anzahl der Linien
; ** 7. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object3_face7_color ;Farbe der Fläche
  DC.W mgv_object3_face7_lines_number-1 ;Anzahl der Linien
; ** 8. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object3_face8_color ;Farbe der Fläche
  DC.W mgv_object3_face8_lines_number-1 ;Anzahl der Linien

; ** 9. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object3_face9_color ;Farbe der Fläche
  DC.W mgv_object3_face9_lines_number-1 ;Anzahl der Linien
; ** 10. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object3_face10_color ;Farbe der Fläche
  DC.W mgv_object3_face10_lines_number-1 ;Anzahl der Linien
; ** 11. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object3_face11_color ;Farbe der Fläche
  DC.W mgv_object3_face11_lines_number-1 ;Anzahl der Linien
; ** 12. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object3_face12_color ;Farbe der Fläche
  DC.W mgv_object3_face12_lines_number-1 ;Anzahl der Linien

; ** 13. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object3_face13_color ;Farbe der Fläche
  DC.W mgv_object3_face13_lines_number-1 ;Anzahl der Linien
; ** 14. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object3_face14_color ;Farbe der Fläche
  DC.W mgv_object3_face14_lines_number-1 ;Anzahl der Linien
; ** 15. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object3_face15_color ;Farbe der Fläche
  DC.W mgv_object3_face15_lines_number-1 ;Anzahl der Linien
; ** 16. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object3_face16_color ;Farbe der Fläche
  DC.W mgv_object3_face16_lines_number-1 ;Anzahl der Linien

; ** 17. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object3_face17_color ;Farbe der Fläche
  DC.W mgv_object3_face17_lines_number-1 ;Anzahl der Linien
; ** 18. Fläche **
; ---------------
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object3_face18_color ;Farbe der Fläche
  DC.W mgv_object3_face18_lines_number-1 ;Anzahl der Linien
; ** 19. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object3_face19_color ;Farbe der Fläche
  DC.W mgv_object3_face19_lines_number-1 ;Anzahl der Linien
; ** 20. Fläche **
; ---------------  
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object3_face20_color ;Farbe der Fläche
  DC.W mgv_object3_face20_lines_number-1 ;Anzahl der Linien

; ** Eckpunkte der Flächen **
; ---------------------------
  CNOP 0,2
mgv_objects_edge_table
; ** Objekt 1 **
  DC.W 0*2,1*2,5*2,0*2       ;Flächen vorne
  DC.W 1*2,2*2,3*2,1*2
  DC.W 1*2,3*2,5*2,1*2
  DC.W 5*2,3*2,4*2,5*2

  DC.W 6*2,11*2,7*2,6*2      ;Flächen hinten
  DC.W 7*2,9*2,8*2,7*2
  DC.W 7*2,11*2,9*2,7*2
  DC.W 11*2,10*2,9*2,11*2

  DC.W 0*2,6*2,7*2,0*2       ;Flächen links
  DC.W 0*2,7*2,1*2,0*2
  DC.W 1*2,7*2,8*2,1*2
  DC.W 1*2,8*2,2*2,1*2

  DC.W 0*2,5*2,6*2,0*2       ;Flächen rechts
  DC.W 6*2,5*2,11*2,6*2
  DC.W 11*2,5*2,4*2,11*2
  DC.W 11*2,4*2,10*2,11*2

  DC.W 4*2,3*2,10*2,4*2      ;Flächen unten
  DC.W 3*2,9*2,10*2,3*2
  DC.W 3*2,2*2,9*2,3*2
  DC.W 2*2,8*2,9*2,2*2

; ** Objekt 2 **
  DC.W 12*2,13*2,17*2,12*2   ;Flächen vorne
  DC.W 13*2,14*2,15*2,13*2
  DC.W 13*2,15*2,17*2,13*2
  DC.W 17*2,15*2,16*2,17*2

  DC.W 18*2,23*2,19*2,18*2   ;Flächen hinten
  DC.W 19*2,21*2,20*2,19*2
  DC.W 19*2,23*2,21*2,19*2
  DC.W 23*2,22*2,21*2,23*2

  DC.W 12*2,18*2,19*2,12*2   ;Flächen links
  DC.W 12*2,19*2,13*2,12*2
  DC.W 13*2,19*2,20*2,13*2
  DC.W 13*2,20*2,14*2,13*2

  DC.W 12*2,17*2,18*2,12*2   ;Flächen rechts
  DC.W 18*2,17*2,23*2,18*2
  DC.W 23*2,17*2,16*2,23*2
  DC.W 23*2,16*2,22*2,23*2

  DC.W 16*2,15*2,22*2,16*2   ;Flächen unten
  DC.W 15*2,21*2,22*2,15*2
  DC.W 15*2,14*2,21*2,15*2
  DC.W 14*2,20*2,21*2,14*2

; ** Objekt 3 **
  DC.W 24*2,25*2,29*2,24*2   ;Flächen vorne
  DC.W 25*2,26*2,27*2,25*2
  DC.W 25*2,27*2,29*2,25*2
  DC.W 29*2,27*2,28*2,29*2

  DC.W 30*2,35*2,31*2,30*2   ;Flächen hinten
  DC.W 31*2,33*2,32*2,31*2
  DC.W 31*2,35*2,33*2,31*2
  DC.W 35*2,34*2,33*2,35*2

  DC.W 24*2,30*2,31*2,24*2   ;Flächen links
  DC.W 24*2,31*2,25*2,24*2
  DC.W 25*2,31*2,32*2,25*2
  DC.W 25*2,32*2,26*2,25*2

  DC.W 24*2,29*2,30*2,24*2   ;Flächen rechts
  DC.W 30*2,29*2,35*2,30*2
  DC.W 35*2,29*2,28*2,35*2
  DC.W 35*2,28*2,34*2,35*2

  DC.W 28*2,27*2,34*2,28*2   ;Flächen unten
  DC.W 27*2,33*2,34*2,27*2
  DC.W 27*2,26*2,33*2,27*2
  DC.W 26*2,32*2,33*2,26*2

; ** Koordinaten der Linien **
; ----------------------------
mgv_rotation_xy_coordinates
  DS.W mgv_objects_edge_points_number*2

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
