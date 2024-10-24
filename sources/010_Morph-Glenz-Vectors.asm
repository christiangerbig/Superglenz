; #########################################
; # Programm: 010_Morph-Glenz-Vectors.asm #
; # Autor:    Christian Gerbig            #
; # Datum:    14.04.2024                  #
; # Version:  1.0                         #
; # CPU:      68020+                      #
; # Fast-Memory: -                        #
; # Chipset:  AGA PAL                     #
; # OS:       3.0+                        #
; #########################################

; Morphendes 1x20-Flächen-Glenz auf einem 256x256-Screen.
; Der Copper wartet auf den Blitter. 
; Beam-Position-Timing wegen flexibler Ausführungszeit der Copperliste.
; Das Playfield ist auf 64 kB aligned damit Blitter-High-Pointer der
; Linien-Blits nur 1x initialisiert werden müssen.

  SECTION code_and_variables,CODE

  MC68040


  XDEF start_010_morph_glenz_vectors

  XREF v_bplcon0_bits
  XREF v_bplcon3_bits1
  XREF v_bplcon3_bits2
  XREF v_bplcon4_bits
  XREF v_fmode_bits
  XREF color00_bits
  XREF nop_second_copperlist
  XREF mouse_handler
  XREF sine_table


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


SYS_TAKEN_OVER                    SET 1
PASS_GLOBAL_REFERENCES            SET 1
PASS_RETURN_CODE                  SET 1


  INCLUDE "macros.i"


  INCLUDE "equals.i"

requires_030_cpu                  EQU FALSE
requires_040_cpu                  EQU FALSE
requires_060_cpu                  EQU FALSE
requires_fast_memory              EQU FALSE
requires_multiscan_monitor        EQU FALSE

workbench_start_enabled           EQU FALSE
screen_fader_enabled              EQU FALSE
text_output_enabled               EQU FALSE

mgv_count_lines_enabled           EQU FALSE
mgv_premorph_enabled              EQU TRUE
mgv_morph_loop_enabled            EQU FALSE

dma_bits                          EQU DMAF_BLITTER+DMAF_RASTER+DMAF_BLITHOG+DMAF_SETCLR

intena_bits                       EQU INTF_SETCLR

ciaa_icr_bits                     EQU CIAICRF_SETCLR
ciab_icr_bits                     EQU CIAICRF_SETCLR

copcon_bits                       EQU COPCONF_CDANG

pf1_x_size1                       EQU 256
pf1_y_size1                       EQU 256+683
pf1_depth1                        EQU 3
pf1_x_size2                       EQU 256
pf1_y_size2                       EQU 256+683
pf1_depth2                        EQU 3
pf1_x_size3                       EQU 256
pf1_y_size3                       EQU 256+683
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

pf_extra_number                   EQU 0

spr_number                        EQU 0
spr_x_size1                       EQU 0
spr_x_size2                       EQU 0
spr_depth                         EQU 0
spr_colors_number                 EQU 0

audio_memory_size                 EQU 0

disk_memory_size                  EQU 0

extra_memory_size                 EQU 0

chip_memory_size                  EQU 0
ciaa_ta_time                      EQU 0
ciaa_tb_time                      EQU 0
ciab_ta_time                      EQU 0
ciab_tb_time                      EQU 0
ciaa_ta_continuous_enabled        EQU FALSE
ciaa_tb_continuous_enabled        EQU FALSE
ciab_ta_continuous_enabled        EQU FALSE
ciab_tb_continuous_enabled        EQU FALSE

beam_position                     EQU $133

pixel_per_line                    EQU 256
visible_pixels_number             EQU 256
visible_lines_number              EQU 256
MINROW                            EQU VSTOP_OVERSCAN_PAL

pf_pixel_per_datafetch            EQU 64 ;4x

display_window_hstart             EQU HSTART_256_PIXEL
display_window_vstart             EQU MINROW
display_window_hstop              EQU HSTOP_256_pixel
display_window_vstop              EQU VSTOP_OVERSCAN_PAL

pf1_plane_width                   EQU pf1_x_size3/8
data_fetch_width                  EQU pixel_per_line/8
pf1_plane_moduli                  EQU (pf1_plane_width*(pf1_depth3-1))+pf1_plane_width-data_fetch_width

diwstrt_bits                      EQU ((display_window_vstart&$ff)*DIWSTRTF_V0)+(display_window_hstart&$ff)
diwstop_bits                      EQU ((display_window_vstop&$ff)*DIWSTOPF_V0)+(display_window_hstop&$ff)
ddfstrt_bits                      EQU DDFSTART_320_PIXEL
ddfstop_bits                      EQU DDFSTOP_256_PIXEL_LALGN_4X
bplcon0_bits                      EQU BPLCON0F_ECSENA+((pf_depth>>3)*BPLCON0F_BPU3)+(BPLCON0F_COLOR)+((pf_depth&$07)*BPLCON0F_BPU0) 
bplcon1_bits                      EQU $8800
bplcon2_bits                      EQU 0
bplcon3_bits1                     EQU 0
bplcon3_bits2                     EQU bplcon3_bits1+BPLCON3F_LOCT
bplcon4_bits                      EQU 0
diwhigh_bits                      EQU (((display_window_hstop&$100)>>8)*DIWHIGHF_HSTOP8)+(((display_window_vstop&$700)>>8)*DIWHIGHF_VSTOP8)+(((display_window_hstart&$100)>>8)*DIWHIGHF_HSTART8)+((display_window_vstart&$700)>>8)
fmode_bits                        EQU FMODEF_BPL32+FMODEF_BPAGEM

cl2_hstart                        EQU $00
cl2_vstart                        EQU beam_position&$ff

sine_table_length                 EQU 512

; **** Morph-Glenz-Vectors ****
mgv_rotation_d                    EQU 512
mgv_rotation_xy_center            EQU visible_lines_number/2

mgv_rotation_x_angle_speed_radius EQU 1
mgv_rotation_x_angle_speed_center EQU 2
mgv_rotation_x_angle_speed_speed  EQU 2

mgv_rotation_y_angle_speed_radius EQU 2
mgv_rotation_y_angle_speed_center EQU 3
mgv_rotation_y_angle_speed_speed  EQU -2

mgv_rotation_z_angle_speed_radius EQU 1
mgv_rotation_z_angle_speed_center EQU 2
mgv_rotation_z_angle_speed_speed  EQU 1

mgv_object_edge_points_number     EQU 12
mgv_object_edge_points_per_face   EQU 3
mgv_object_faces_number           EQU 20

mgv_object_face1_color            EQU 4
mgv_object_face1_lines_number     EQU 3
mgv_object_face2_color            EQU 4
mgv_object_face2_lines_number     EQU 3
mgv_object_face3_color            EQU 2
mgv_object_face3_lines_number     EQU 3
mgv_object_face4_color            EQU 4
mgv_object_face4_lines_number     EQU 3

mgv_object_face5_color            EQU 2
mgv_object_face5_lines_number     EQU 3
mgv_object_face6_color            EQU 2
mgv_object_face6_lines_number     EQU 3
mgv_object_face7_color            EQU 4
mgv_object_face7_lines_number     EQU 3
mgv_object_face8_color            EQU 2
mgv_object_face8_lines_number     EQU 3

mgv_object_face9_color            EQU 4
mgv_object_face9_lines_number     EQU 3
mgv_object_face10_color           EQU 2
mgv_object_face10_lines_number    EQU 3
mgv_object_face11_color           EQU 4
mgv_object_face11_lines_number    EQU 3
mgv_object_face12_color           EQU 2
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

mgv_lines_number_max              EQU 54

  IFEQ mgv_morph_loop_enabled
mgv_morph_shapes_number           EQU 3
  ELSE
mgv_morph_shapes_number           EQU 4
  ENDC
mgv_morph_speed                   EQU 8
mgv_morph_delay                   EQU 6*PAL_FPS

; **** Fill-Blit ****
mgv_fill_blit_x_size              EQU visible_pixels_number
mgv_fill_blit_y_size              EQU visible_lines_number
mgv_fill_blit_depth               EQU pf1_depth3

; **** Scroll-Playfield-Bottom ****
spb_min_vstart                    EQU VSTART_256_LINES
spb_max_vstop                     EQU VSTOP_OVERSCAN_PAL
spb_y_radius                      EQU spb_max_vstop-spb_min_vstart
spb_y_centre                      EQU spb_max_vstop-spb_min_vstart


; **** Scroll-Playfield-Bottom-In ****
spbi_y_angle_speed                EQU 4

; **** Scroll-Playfield-Bottom-Out ****
spbo_y_angle_speed                EQU 5


  INCLUDE "except-vectors-offsets.i"


  INCLUDE "extra-pf-attributes.i"


  INCLUDE "sprite-attributes.i"


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

cl2_extension1_size RS.B 0


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

cl2_extension2_size RS.B 0


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

cl2_extension3_size RS.B 0


  RSRESET

cl2_begin            RS.B 0

  INCLUDE "copperlist2-offsets.i"

cl2_extension1_entry RS.B cl2_extension1_size
cl2_extension2_entry RS.B cl2_extension2_size*mgv_lines_number_max
cl2_extension3_entry RS.B cl2_extension3_size

cl2_end              RS.L 1

copperlist2_size     RS.B 0


; ** Konstanten für die größe der Copperlisten **
cl1_size1             EQU 0
cl1_size2             EQU 0
cl1_size3             EQU 0
cl2_size1             EQU 0
cl2_size2             EQU copperlist2_size
cl2_size3             EQU copperlist2_size

; ** Konstanten für die Größe der Spritestrukturen **
spr0_x_size1          EQU spr_x_size1
spr0_y_size1          EQU 0
spr1_x_size1          EQU spr_x_size1
spr1_y_size1          EQU 0
spr2_x_size1          EQU spr_x_size1
spr2_y_size1          EQU 0
spr3_x_size1          EQU spr_x_size1
spr3_y_size1          EQU 0
spr4_x_size1          EQU spr_x_size1
spr4_y_size1          EQU 0
spr5_x_size1          EQU spr_x_size1
spr5_y_size1          EQU 0
spr6_x_size1          EQU spr_x_size1
spr6_y_size1          EQU 0
spr7_x_size1          EQU spr_x_size1
spr7_y_size1          EQU 0

spr0_x_size2          EQU spr_x_size2
spr0_y_size2          EQU 0
spr1_x_size2          EQU spr_x_size2
spr1_y_size2          EQU 0
spr2_x_size2          EQU spr_x_size2
spr2_y_size2          EQU 0
spr3_x_size2          EQU spr_x_size2
spr3_y_size2          EQU 0
spr4_x_size2          EQU spr_x_size2
spr4_y_size2          EQU 0
spr5_x_size2          EQU spr_x_size2
spr5_y_size2          EQU 0
spr6_x_size2          EQU spr_x_size2
spr6_y_size2          EQU 0
spr7_x_size2          EQU spr_x_size2
spr7_y_size2          EQU 0


  RSRESET

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

mgv_morph_active                 RS.W 1
mgv_morph_shapes_table_start     RS.W 1
mgv_morph_delay_counter          RS.W 1

; **** Scroll-Playfield-Bottom-In ****
spbi_active                      RS.W 1
spbi_y_angle                     RS.W 1

; **** Scroll-Playfield-Bottom-Out ****
spbo_active                      RS.W 1
spbo_y_angle                     RS.W 1

; **** Main ****
fx_active                        RS.W 1

variables_size                   RS.B 0


; **** Morph-Glenz-Vectors ****
; ** Objekt-Info-Struktur **
  RSRESET

mgv_object_info              RS.B 0

mgv_object_info_edge_table   RS.L 1
mgv_object_info_face_color   RS.W 1
mgv_object_info_lines_number RS.W 1

mgv_object_info_size         RS.B 0

; ** Morph-Shape-Struktur **
  RSRESET

mgv_morph_shape                   RS.B 0

mgv_morph_shape_object_edge_table RS.L 1

mgv_morph_shape_size              RS.B 0


start_010_morph_glenz_vectors

  INCLUDE "sys-wrapper.i"

  CNOP 0,4
init_main_variables

; **** Morphing-Glenz-Vectors ****
  moveq   #0,d0
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

  IFEQ mgv_premorph_enabled
    move.w  d0,mgv_morph_active(a3)
  ELSE
    move.w  d1,mgv_morph_active(a3)
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
  moveq   #FALSE,d1
  move.w  d1,spbo_active(a3)
  move.w  #sine_table_length/4,spbo_y_angle(a3) ;90 Grad

; **** Main ****
  move.w  d1,fx_active(a3)
  rts

; ** Alle Initialisierungsroutinen ausführen **
  CNOP 0,4
init_main
  bsr.s   mgv_init_object_info_table
  bsr.s   mgv_init_morph_shapes_table
  IFEQ mgv_premorph_enabled
    bsr.s   mgv_init_start_shape
  ENDC
  bsr.s   mgv_init_color_table
  bsr     spb_init_display_window
  bra     init_second_copperlist

; **** Morph-Glenz-Vectors ****
; ** Object-Info-Tabelle initialisieren **
  CNOP 0,4
mgv_init_object_info_table
  lea     mgv_object_info_table+mgv_object_info_edge_table(pc),a0 ;Zeiger auf Object-Info-Tabelle
  lea     mgv_object_edge_table(pc),a1 ;Zeiger auf Tebelle mit Eckpunkten
  move.w  #mgv_object_info_size,a2
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
  CNOP 0,4
mgv_init_morph_shapes_table
; ** Form 1 **
  lea     mgv_object_shape1_coords(pc),a0 ;Zeiger auf 1. Form
  lea     mgv_morph_shapes_table(pc),a1 ;Tabelle mit Zeigern auf Objektdaten
  move.l  a0,(a1)+           ;Zeiger auf Form-Tabelle
; ** Form 2 **
  lea     mgv_object_shape2_coords(pc),a0 ;Zeiger auf 2. Form
  move.l  a0,(a1)+           ;Zeiger auf Form-Tabelle
; ** Form 3 **
  lea     mgv_object_shape3_coords(pc),a0 ;Zeiger auf 3. Form
  IFEQ mgv_morph_loop_enabled
    move.l  a0,(a1)          ;Zeiger auf Form-Tabelle
  ELSE
    move.l  a0,(a1)+         ;Zeiger auf Form-Tabelle
; ** Form 4 **
    lea     mgv_object_shape4_coords(pc),a0 ;Zeiger auf 4. Form
    move.l  a0,(a1)          ;Zeiger auf Form-Tabelle
  ENDC
  rts

  IFEQ mgv_premorph_enabled
    CNOP 0,4
mgv_init_start_shape
    bsr     mgv_morph_object
    tst.w   mgv_morph_active(a3) ;Morphing beendet?
    beq.s   mgv_init_start_shape ;Nein -> verzweige
    rts
  ENDC

; ** Farbtabelle initialisieren **
  CNOP 0,4
mgv_init_color_table
  lea     pf1_rgb8_color_table(pc),a0 ;Zeiger auf Farbtableelle
  lea     mgv_glenz_color_table1(pc),a1 ;Farben der einzelnen Glenz-Objekte
  move.l  (a1)+,2*LONGWORD_SIZE(a0) ;COLOR02
  move.l  (a1)+,3*LONGWORD_SIZE(a0) ;COLOR03
  move.l  (a1)+,4*LONGWORD_SIZE(a0) ;COLOR04
  move.l  (a1),5*LONGWORD_SIZE(a0) ;COLOR05
  rts

  CNOP 0,4
spb_init_display_window
  move.w  #diwstrt_bits,DIWSTRT-DMACONR(a6)
  move.w  #diwstop_bits,DIWSTOP-DMACONR(a6)
  move.w  #diwhigh_bits,DIWHIGH-DMACONR(a6) ; Muss sein, da LoadView() DIWHIGH=$0000 setzt -> Anzeigefehler
  rts

  CNOP 0,4
init_second_copperlist
  move.l  cl2_construction2(a3),a0
  bsr.s   cl2_init_playfield_props
  bsr     cl2_init_colors
  bsr     cl2_init_plane_ptrs
  bsr     cl2_init_line_blits_steady
  bsr     cl2_init_line_blits
  bsr     cl2_init_fill_blit
  COP_LISTEND
  bsr     get_wrapper_view_values
  bsr     cl2_set_plane_ptrs
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
cl2_init_colors
  COP_INIT_COLOR_HIGH COLOR00,8,pf1_rgb8_color_table

  COP_SELECT_COLOR_LOW_BANK 0,v_bplcon3_bits2
  COP_INIT_COLOR_LOW COLOR00,8,pf1_rgb8_color_table
  rts

  COP_INIT_BITPLANE_POINTERS cl2

  CNOP 0,4
cl2_init_line_blits_steady
  COP_WAITBLIT
  COP_MOVEQ FALSE_WORD,BLTAFWM    ;Keine Ausmaskierung
  COP_MOVEQ FALSE_WORD,BLTALWM
  COP_MOVEQ TRUE,BLTCPTH
  COP_MOVEQ TRUE,BLTDPTH
  COP_MOVEQ pf1_plane_width*pf1_depth3,BLTCMOD ;Moduli für interleaved Bitmaps
  COP_MOVEQ pf1_plane_width*pf1_depth3,BLTDMOD
  COP_MOVEQ FALSE_WORD,BLTBDAT    ;Linientextur
  COP_MOVEQ $8000,BLTADAT     ;Linientextur beginnt ab MSB
  COP_MOVEQ TRUE,COP2LCH
  COP_MOVEQ TRUE,COP2LCL
  COP_MOVEQ TRUE,COPJMP2
  rts

  CNOP 0,4
cl2_init_line_blits
  moveq   #mgv_lines_number_max-1,d7
cl2_init_line_blits_loop
  COP_MOVEQ TRUE,BLTCON0
  COP_MOVEQ TRUE,BLTCON1
  COP_MOVEQ TRUE,BLTCPTL
  COP_MOVEQ TRUE,BLTAPTL
  COP_MOVEQ TRUE,BLTDPTL
  COP_MOVEQ TRUE,BLTBMOD
  COP_MOVEQ TRUE,BLTAMOD
  COP_MOVEQ TRUE,BLTSIZE
  COP_WAITBLIT
  dbf     d7,cl2_init_line_blits_loop
  rts

  CNOP 0,4
cl2_init_fill_blit
  COP_MOVEQ BC0F_SRCA+BC0F_DEST+ANBNC+ANBC+ABNC+ABC,BLTCON0 ;Minterm D=A
  COP_MOVEQ BLTCON1F_DESC+BLTCON1F_EFE,BLTCON1 ;Füll-Modus, Rückwärts
  COP_MOVEQ TRUE,BLTAPTH
  COP_MOVEQ TRUE,BLTAPTL
  COP_MOVEQ TRUE,BLTDPTH
  COP_MOVEQ TRUE,BLTDPTL
  COP_MOVEQ pf1_plane_width-(visible_pixels_number/8),BLTAMOD
  COP_MOVEQ pf1_plane_width-(visible_pixels_number/8),BLTDMOD
  COP_MOVEQ (mgv_fill_blit_y_size*mgv_fill_blit_depth*64)+(mgv_fill_blit_x_size/16),BLTSIZE
  rts

  CNOP 0,4
get_wrapper_view_values
  move.l  cl2_construction2(a3),a0
  or.w    #v_bplcon0_bits,cl2_BPLCON0+2(a0)
  or.w    #v_bplcon3_bits1,cl2_BPLCON3_1+2(a0)
  or.w    #v_bplcon4_bits,cl2_BPLCON4+2(a0)
  or.w    #v_fmode_bits,cl2_FMODE+2(a0)
  rts

  COP_SET_BITPLANE_POINTERS cl2,construction2,pf1_depth3

  COPY_COPPERLIST cl2,2


  CNOP 0,4
main

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
  tst.w   fx_active(a3)      ;Effekte beendet ?
  bne.s   beam_routines      ;Nein -> verzweige
fast_exit
  move.l  nop_second_copperlist(pc),COP2LC-DMACONR(a6) ;2. Copperliste deaktivieren
  move.w  d0,COPJMP2-DMACONR(a6)
  move.w  custom_error_code(a3),d1
  rts


  SWAP_COPPERLIST cl2,2

; ** Playfields vertauschen **
  CNOP 0,4
swap_playfield1
  move.l  pf1_construction1(a3),a0
  move.l  pf1_construction2(a3),a1
  move.l  pf1_display(a3),pf1_construction1(a3)
  move.l  a0,pf1_construction2(a3)
  move.l  a1,pf1_display(a3)
  move.l  #ALIGN_64KB,d1
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
  add.l   #ALIGN_64KB,d0
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
; Rest 272 Bytes
  movem.l d0-d6/a0-a6,-(a7)
  movem.l d0-d6/a0-a6,-(a7) 
  movem.l d0-d6/a0-a6,-(a7) 
  movem.l d0-d6/a0-a6,-(a7) 
  movem.l d0-d6/a0-a4,-(a7)
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
  and.w   d3,d2              ;Überlauf entfwernen
  move.w  d2,mgv_rotation_z_angle_speed_angle(a3)
  rts

; ** 3D-Rotation **
  CNOP 0,4
mgv_rotation
  movem.l a4-a5,-(a7)
  move.w  mgv_rotation_x_angle(a3),d1 ;X-Winkel
  move.w  d1,d0              
  lea     sine_table(pc),a2  
  move.w  (a2,d0.w*2),d4     ;sin(a)
  move.w  #sine_table_length/4,a4
  MOVEF.W sine_table_length-1,d3
  add.w   a4,d0              ;+ 90 Grad
  swap    d4                 ;Bits 16-31 = sin(a)
  and.w   d3,d0              ;Übertrag entfernen
  move.w  (a2,d0.w*2),d4     ;Bits  0-15 = cos(a)
  add.w   mgv_rotation_variable_x_speed(a3),d1 ;nächster X-Winkel
  and.w   d3,d1              ;Übertrag entfernen
  move.w  d1,mgv_rotation_x_angle(a3) 
  move.w  mgv_rotation_y_angle(a3),d1 ;Y-Winkel
  move.w  d1,d0              
  move.w  (a2,d0.w*2),d5     ;sin(b)
  add.w   a4,d0              ;+ 90 Grad
  swap    d5                 ;Bits 16-31 = sin(b)
  and.w   d3,d0              ;Übertrag entfernen
  move.w  (a2,d0.w*2),d5     ;Bits  0-15 = cos(b)
  add.w   mgv_rotation_variable_y_speed(a3),d1 ;nächster Y-Winkel
  and.w   d3,d1              ;Übertrag entfernen
  move.w  d1,mgv_rotation_y_angle(a3) 
  move.w  mgv_rotation_z_angle(a3),d1 ;Z-Winkel
  move.w  d1,d0              
  move.w  (a2,d0.w*2),d6     ;sin(c)
  add.w   a4,d0              ;+ 90 Grad
  swap    d6                 ;Bits 16-31 = sin(c)
  and.w   d3,d0              ;Übertrag entfernen
  move.w  (a2,d0.w*2),d6     ;Bits  0-15 = cos(c)
  add.w   mgv_rotation_variable_z_speed(a3),d1 ;nächster Z-Winkel
  and.w   d3,d1              ;Übertrag entfernen
  move.w  d1,mgv_rotation_z_angle(a3) 
  lea     mgv_object_coords(pc),a0 ;Koordinaten der Linien
  lea     mgv_rotation_xy_coords(pc),a1 ;Koord.-Tab.
  move.w  #(mgv_rotation_d-100)*8,a4 ;d
  move.w  #mgv_rotation_xy_center,a5 ;X+Y-Mittelpunkt
  moveq   #mgv_object_edge_points_number-1,d7 ;Anzahl der Punkte
mgv_rotate_loop
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
  divs.w  d2,d1              ;y'= (y*d)/(z+d)
  move.l  a2,d7              ;Schleifenzähler 
  add.w   a5,d1              ;y' + Y-Mittelpunkt
  move.w  d1,(a1)+           ;Y-Pos.
  dbf     d7,mgv_rotate_loop
  movem.l (a7)+,a4-a5
  rts

; ** Form des Objekts ändern **
  CNOP 0,4
mgv_morph_object
  tst.w   mgv_morph_active(a3) ;Morphing an ?
  bne.s   mgv_no_morph_object ;Nein -> verzweige
  move.w  mgv_morph_shapes_table_start(a3),d1 ;Startwert
  moveq   #TRUE,d2           ;Koordinatenzähler
  lea     mgv_object_coords(pc),a0 ;Aktuelle Objektdaten
  lea     mgv_morph_shapes_table(pc),a1 ;Tabelle mit Adressen der Formen-Tabellen
  move.l  (a1,d1.w*4),a1     ;Zeiger auf Tabelle 
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
  move.w  d0,(a0)            
  addq.w  #1,d2              ;Koordinatenzähler erhöhen
mgv_morph_object_next_coordinate
  addq.w  #2,a0              ;Nächste Koordinate
  dbf     d7,mgv_morph_object_loop

  tst.w   d2                 ;Morphing beendet?
  bne.s   mgv_no_morph_object ;Nein -> verzweige
  addq.w  #1,d1              ;nächster Eintrag in Objekttablelle
  cmp.w   #mgv_morph_shapes_number,d1 ;Ende der Tabelle ?
  IFEQ mgv_morph_loop_enabled
    bne.s   mgv_save_morph_shapes_table_start ;Nein -> verzweige
    moveq   #TRUE,d1         ;Neustart
mgv_save_morph_shapes_table_start
  ELSE
    beq.s   mgv_morph_object_disable ;Ja -> verzweige
  ENDC
  move.w  d1,mgv_morph_shapes_table_start(a3) 
  move.w  #mgv_morph_delay,mgv_morph_delay_counter(a3) ;Zähler zurücksetzen
mgv_morph_object_disable
  move.w  #FALSE,mgv_morph_active(a3) ;Morhing aus
mgv_no_morph_object
  rts

; ** Linien ziehen **
  CNOP 0,4
mgv_draw_lines
  movem.l a3-a6,-(a7)
  bsr     mgv_draw_lines_init
  lea     mgv_object_info_table(pc),a0 ;Zeiger auf Info-Daten zum Objekt
  lea     mgv_rotation_xy_coords(pc),a1 ;Zeiger auf XY-Koordinaten
  move.l  pf1_construction1(a3),a2 ;Plane0
  move.l  (a2),d0
  add.l   #ALIGN_64KB,d0
  clr.w   d0
  move.l  d0,a2
  sub.l   a4,a4              ;Linienzähler zurücksetzen
  move.l  cl2_construction2(a3),a6 
  ADDF.W  cl2_extension3_entry-cl2_extension2_size+cl2_ext2_BLTCON0+2,a6
  move.l  #((BC0F_SRCA+BC0F_SRCC+BC0F_DEST+NANBC+NABC+ABNC)<<16)+(BLTCON1F_LINE+BLTCON1F_SING),a3
  MOVEF.W mgv_object_faces_number-1,d7 ;Anzahl der Flächen
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
  SUBF.W  cl2_extension2_size,a6
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
  add.l   #ALIGN_64KB,d0
  clr.w   d0
  move.l  cl2_construction2(a3),a0
  swap    d0                 ;High
  move.w  d0,cl2_extension1_entry+cl2_ext1_BLTCPTH+2(a0) ;Playfield lesen
  move.w  d0,cl2_extension1_entry+cl2_ext1_BLTDPTH+2(a0) ;Playfield schreiben
  rts

; ** Playfield füllen **
  CNOP 0,4
mgv_fill_playfield1
  move.l  pf1_construction1(a3),a0
  move.l  (a0),d0
  add.l   #ALIGN_64KB,d0
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
  CNOP 0,4
mgv_set_second_copperlist_jump
  move.l  cl2_construction2(a3),a0 
  move.l  a0,d0
  ADDF.L  cl2_extension3_entry,d0
  moveq   #TRUE,d1           ;32-Bit-Zugriff
  move.w  mgv_lines_counter(a3),d1
  IFEQ mgv_count_lines_enabled
    cmp.w   $140000,d1
    blt.s   mgv_skip
    move.w  d1,$140000
mgv_skip
  ENDC
  MULUF.W cl2_extension2_size,d1,d2
  sub.l   d1,d0
  move.w  d0,cl2_extension1_entry+cl2_ext1_COP2LCL+2(a0)
  swap    d0
  move.w  d0,cl2_extension1_entry+cl2_ext1_COP2LCH+2(a0)
  rts


; ** Playfield von unten einscrollen **
  CNOP 0,4
scroll_playfield_bottom_in
  tst.w   spbi_active(a3)    ;Scroll-Playfield-Bottom-In an ?
  bne.s   no_scroll_playfield_bottom_in ;Nein -> verzweige
  move.w  spbi_y_angle(a3),d2 ;Y-Winkel
  cmp.w   #sine_table_length/4,d2 ;90 Grad ?
  bgt.s   spbi_finished      ;Ja -> verzweige
  lea     sine_table(pc),a0
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
  move.w  #FALSE,spbi_active(a3) ;Scroll-Playfield-Bottom-In aus
  rts

; ** Playfield nach unten ausscrollen **
  CNOP 0,4
scroll_playfield_bottom_out
  tst.w   spbo_active(a3)    ;Vert-Scroll-Playfild-Out an ?
  bne.s   no_scroll_playfield_bottom_out ;Nein -> verzweige
  move.w  spbo_y_angle(a3),d2 ;Y-Winkel
  cmp.w   #sine_table_length/2,d2 ;180 Grad ?
  bgt.s   spbo_finished      ;Ja -> verzweige
  lea     sine_table(pc),a0  
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
  move.w  #FALSE,spbo_active(a3) ;Scroll-Playfield-Bottom-Out aus
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
  or.w    #diwhigh_bits&(~(DIWHIGHF_VSTART8+DIWHIGHF_VSTOP8)),d2 ;restliche Bits
  move.w  d2,cl2_DIWHIGH+2(a1)
  rts


; ** Zähler kontrollieren **
  CNOP 0,4
mgv_control_counters
  move.w  mgv_morph_delay_counter(a3),d0
  bmi.s   mgv_morph_no_delay_counter ;Wenn Zähler negativ -> verzweige
  subq.w  #1,d0              ;Zähler verringern
  bpl.s   mgv_morph_save_delay_counter ;Wenn positiv -> verzweige
mgv_morph_enable
  clr.w   mgv_morph_active(a3) ;Morphing an
  cmp.w   #mgv_morph_shapes_number-1,mgv_morph_shapes_table_start(a3) ;Ende der Tabelle ?
  bne.s   mgv_morph_save_delay_counter ;Nein -> verzweige
  clr.w   spbo_active(a3)    ;Scroll-Playfield-Bottom-Out an
mgv_morph_save_delay_counter
  move.w  d0,mgv_morph_delay_counter(a3) 
mgv_morph_no_delay_counter
  rts


  

  INCLUDE "int-autovectors-handlers.i"

; ** Level-7-Interrupt-Server **
  CNOP 0,4
NMI_int_server
  rts


  INCLUDE "help-routines.i"


  INCLUDE "sys-structures.i"


  CNOP 0,4
pf1_rgb8_color_table
  REPT pf1_colors_number
    DC.L color00_bits
  ENDR

; **** Morph-Glenz-Vectors ****
; ** Farben der Glenz-Objekte **
  CNOP 0,4
mgv_glenz_color_table1
  INCLUDE "Daten:Asm-Sources.AGA/projects/Superglenz/colortables/1xGlenz-Colorgradient1.ct"

; ** Objektdaten **
  CNOP 0,2
mgv_object_coords
; * Zoom-In *
  DS.W mgv_object_edge_points_number*3

; ** Formen des Objekts **
; ** Form 1 **
mgv_object_shape1_coords
; ** Polygon **
  DC.W 0,-(64*8),-(32*8)    ;P0
  DC.W 32*8,0,-(32*8)       ;P1
  DC.W 64*8,64*8,-(32*8)    ;P2
  DC.W 0,64*8,-(32*8)       ;P3
  DC.W -(64*8),64*8,-(32*8) ;P4
  DC.W -(32*8),0,-(32*8)    ;P5
  DC.W 0,-(64*8),32*8       ;P6
  DC.W 32*8,0,32*8          ;P7
  DC.W 64*8,64*8,32*8       ;P8
  DC.W 0,64*8,32*8          ;P9
  DC.W -(64*8),64*8,32*8    ;P10
  DC.W -(32*8),0,32*8       ;P11

; ** Form 2 **
mgv_object_shape2_coords
; ** Pyramide **
  DC.W 0,-(54*8),-(14*8)    ;P0
  DC.W 27*8,0,-(34*8)       ;P1
  DC.W 54*8,54*8,-(54*8)    ;P2
  DC.W 0,54*8,-(54*8)       ;P3
  DC.W -(54*8),54*8,-(54*8) ;P4
  DC.W -(27*8),0,-(34*8)    ;P5
  DC.W 0,-(54*8),14*8       ;P6
  DC.W 27*8,0,34*8          ;P7
  DC.W 54*8,54*8,54*8       ;P8
  DC.W 0*8,54*8,54*8        ;P9
  DC.W -(54*8),54*8,54*8    ;P10
  DC.W -(27*8),0,34*8       ;P11

; ** Form 3 **
mgv_object_shape3_coords
; ** Polygon2 **
  DC.W 0,-(64*8),-(32*8)    ;P0
  DC.W 64*8,0,-(64*8)       ;P1
  DC.W 32*8,64*8,-(32*8)    ;P2
  DC.W 0*8,64*8,-(32*8)     ;P3
  DC.W -(32*8),64*8,-(32*8) ;P4
  DC.W -(64*8),0,-(64*8)    ;P5
  DC.W 0,-(64*8),32*8       ;P6
  DC.W 64*8,0,64*8          ;P7
  DC.W 32*8,64*8,32*8       ;P8
  DC.W 0,64*8,32*8          ;P9
  DC.W -(32*8),64*8,32*8    ;P10
  DC.W -(64*8),0,64*8       ;P11

  IFNE mgv_morph_loop_enabled
; ** Form 4 **
; * Zoom-Out *
mgv_object_shape4_coords
    DS.W mgv_object_edge_points_number*3
  ENDC

; ** Information über Objekt **
  CNOP 0,4
mgv_object_info_table
; ** 1. Fläche **
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face1_color ;Farbe der Fläche
  DC.W mgv_object_face1_lines_number-1 ;Anzahl der Linien
; ** 2. Fläche **
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face2_color ;Farbe der Fläche
  DC.W mgv_object_face2_lines_number-1 ;Anzahl der Linien
; ** 3. Fläche **
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face3_color ;Farbe der Fläche
  DC.W mgv_object_face3_lines_number-1 ;Anzahl der Linien
; ** 4. Fläche **
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face4_color ;Farbe der Fläche
  DC.W mgv_object_face4_lines_number-1 ;Anzahl der Linien

; ** 5. Fläche **
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face5_color ;Farbe der Fläche
  DC.W mgv_object_face5_lines_number-1 ;Anzahl der Linien
; ** 6. Fläche **
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face6_color ;Farbe der Fläche
  DC.W mgv_object_face6_lines_number-1 ;Anzahl der Linien
; ** 7. Fläche **
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face7_color ;Farbe der Fläche
  DC.W mgv_object_face7_lines_number-1 ;Anzahl der Linien
; ** 8. Fläche **
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face8_color ;Farbe der Fläche
  DC.W mgv_object_face8_lines_number-1 ;Anzahl der Linien

; ** 9. Fläche **
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face9_color ;Farbe der Fläche
  DC.W mgv_object_face9_lines_number-1 ;Anzahl der Linien
; ** 10. Fläche **
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face10_color ;Farbe der Fläche
  DC.W mgv_object_face10_lines_number-1 ;Anzahl der Linien
; ** 11. Fläche **
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face11_color ;Farbe der Fläche
  DC.W mgv_object_face11_lines_number-1 ;Anzahl der Linien
; ** 12. Fläche **
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face12_color ;Farbe der Fläche
  DC.W mgv_object_face12_lines_number-1 ;Anzahl der Linien

; ** 13. Fläche **
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face13_color ;Farbe der Fläche
  DC.W mgv_object_face13_lines_number-1 ;Anzahl der Linien
; ** 14. Fläche **
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face14_color ;Farbe der Fläche
  DC.W mgv_object_face14_lines_number-1 ;Anzahl der Linien
; ** 15. Fläche **
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face15_color ;Farbe der Fläche
  DC.W mgv_object_face15_lines_number-1 ;Anzahl der Linien
; ** 16. Fläche **
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face16_color ;Farbe der Fläche
  DC.W mgv_object_face16_lines_number-1 ;Anzahl der Linien

; ** 17. Fläche **
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face17_color ;Farbe der Fläche
  DC.W mgv_object_face17_lines_number-1 ;Anzahl der Linien
; ** 18. Fläche **
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face18_color ;Farbe der Fläche
  DC.W mgv_object_face18_lines_number-1 ;Anzahl der Linien
; ** 19. Fläche **
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face19_color ;Farbe der Fläche
  DC.W mgv_object_face19_lines_number-1 ;Anzahl der Linien
; ** 20. Fläche **
  DC.L 0                     ;Zeiger auf Koords
  DC.W mgv_object_face20_color ;Farbe der Fläche
  DC.W mgv_object_face20_lines_number-1 ;Anzahl der Linien

; ** Eckpunkte der Flächen **
  CNOP 0,2
mgv_object_edge_table
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

; ** Koordinaten der Linien **
mgv_rotation_xy_coords
  DS.W mgv_object_edge_points_number*2

; ** Tabelle mit Adressen der Objekttabellen **
  CNOP 0,4
mgv_morph_shapes_table
  DS.B mgv_morph_shape_size*mgv_morph_shapes_number


  INCLUDE "sys-variables.i"


  INCLUDE "sys-names.i"


  INCLUDE "error-texts.i"

  END
