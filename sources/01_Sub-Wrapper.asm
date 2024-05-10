; ################################
; # Programm: 01_Sub-Wrapper.asm #
; # Autor:    Christian Gerbig   #
; # Datum:    13.04.2024         #
; # Version:  1.0                #
; # CPU:      68020+             #
; # FASTMEM:  -                  #
; # Chipset:  AGA                #
; # OS:       3.0+               #
; ################################

; Zusätzliches Playfield in 16 Farben aus vier attached 64-Pixel-Sprites,
; wobei nach 256 Pixeln jedes Sprite wiederholt wird.

  SECTION code_and_variables,CODE

  XDEF v_BPLCON0BITS
  XDEF v_BPLCON3BITS1
  XDEF v_BPLCON3BITS2
  XDEF v_BPLCON4BITS
  XDEF v_FMODEBITS
  XDEF start_01_wrapper

  XREF COLOR00BITS
  XREF start_010_morph_glenz_vectors
  XREF start_011_morph_glenz_vectors
  XREF start_012_morph_glenz_vectors
  XREF start_013_morph_2xglenz_vectors
  XREF start_014_morph_3xglenz_vectors
  XREF mouse_handler
  XREF sine_table

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

requires_68030              EQU FALSE  
requires_68040              EQU FALSE
requires_68060              EQU FALSE
requires_fast_memory        EQU FALSE
requires_multiscan_monitor  EQU FALSE

workbench_start             EQU FALSE
workbench_fade              EQU FALSE
text_output                 EQU FALSE

sys_taken_over
own_display_set_second_copperlist
pass_global_references
pass_return_code

DMABITS                     EQU DMAF_SPRITE+DMAF_COPPER+DMAF_SETCLR
INTENABITS                  EQU INTF_SETCLR

CIAAICRBITS                 EQU CIAICRF_SETCLR
CIABICRBITS                 EQU CIAICRF_SETCLR

COPCONBITS                  EQU TRUE

pf1_x_size1                 EQU 0
pf1_y_size1                 EQU 0
pf1_depth1                  EQU 0
pf1_x_size2                 EQU 0
pf1_y_size2                 EQU 0
pf1_depth2                  EQU 0
pf1_x_size3                 EQU 0
pf1_y_size3                 EQU 0
pf1_depth3                  EQU 0
pf1_colors_number           EQU 0 ;1

pf2_x_size1                 EQU 0
pf2_y_size1                 EQU 0
pf2_depth1                  EQU 0
pf2_x_size2                 EQU 0
pf2_y_size2                 EQU 0
pf2_depth2                  EQU 0
pf2_x_size3                 EQU 0
pf2_y_size3                 EQU 0
pf2_depth3                  EQU 0
pf2_colors_number           EQU 0
pf_colors_number            EQU pf1_colors_number+pf2_colors_number
pf_depth                    EQU pf1_depth3+pf2_depth3

extra_pf_number             EQU 0

spr_number                  EQU 8
spr_x_size1                 EQU 0
spr_x_size2                 EQU 64
spr_depth                   EQU 2
spr_colors_number           EQU 16
spr_odd_color_table_select  EQU 8
spr_even_color_table_select EQU 8
spr_used_number             EQU 8

audio_memory_size           EQU 0

disk_memory_size            EQU 0

extra_memory_size           EQU 0

chip_memory_size            EQU 0

AGA_OS_Version              EQU 39

CIAA_TA_value               EQU 0
CIAA_TB_value               EQU 0
CIAB_TA_value               EQU 0
CIAB_TB_value               EQU 0
CIAA_TA_continuous          EQU FALSE
CIAA_TB_continuous          EQU FALSE
CIAB_TA_continuous          EQU FALSE
CIAB_TB_continuous          EQU FALSE

beam_position               EQU $133

MINROW                      EQU VSTART_OVERSCAN_PAL

spr_pixel_per_datafetch     EQU 64 ;4x

BPLCON0BITS                 EQU BPLCON0F_ECSENA+((pf_depth>>3)*BPLCON0F_BPU3)+(BPLCON0F_COLOR)+((pf_depth&$07)*BPLCON0F_BPU0) ;lores
BPLCON3BITS1                EQU BPLCON3F_BRDSPRT+BPLCON3F_SPRES0
BPLCON3BITS2                EQU BPLCON3BITS1+BPLCON3F_LOCT
BPLCON4BITS                 EQU (BPLCON4F_OSPRM4*spr_odd_color_table_select)+(BPLCON4F_ESPRM4*spr_even_color_table_select)
FMODEBITS                   EQU FMODEF_SPR32+FMODEF_SPAGEM+FMODEF_SSCAN2

v_BPLCON0BITS               EQU BPLCON0BITS
v_BPLCON3BITS1              EQU BPLCON3BITS1
v_BPLCON3BITS2              EQU BPLCON3BITS2
v_BPLCON4BITS               EQU BPLCON4BITS
v_FMODEBITS                 EQU FMODEBITS

cl2_HSTART                  EQU $00
cl2_VSTART                  EQU beam_position&cl_y_wrap

sine_table_length           EQU 512

; **** Hintergrundbild ****
bg_image_x_size             EQU 256
bg_image_plane_width        EQU bg_image_x_size/8
bg_image_y_size             EQU 283
bg_image_depth              EQU 4
bg_image_x_position         EQU 8
bg_image_y_position         EQU MINROW

; **** Sprite-Fader ****
sprf_colors_number          EQU spr_colors_number-1

sprfi_fader_speed_max       EQU 4
sprfi_fader_radius          EQU sprfi_fader_speed_max
sprfi_fader_center          EQU sprfi_fader_speed_max+1
sprfi_fader_angle_speed     EQU 2

sprfo_fader_speed_max       EQU 4
sprfo_fader_radius          EQU sprfo_fader_speed_max
sprfo_fader_center          EQU sprfo_fader_speed_max+1
sprfo_fader_angle_speed     EQU 2


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

cl1_begin        RS.B 0

  INCLUDE "copperlist1-offsets.i"

cl1_COPJMP2      RS.L 1

copperlist1_SIZE RS.B 0


; ** Struktur, die alle Registeroffsets der zweiten Copperliste enthält **
; ------------------------------------------------------------------------
  RSRESET

cl2_begin        RS.B 0

cl2_end          RS.L 1

copperlist2_SIZE RS.B 0


; ** Konstanten für die Größe der Copperlisten **
; -----------------------------------------------
cl1_size1        EQU 0
cl1_size2        EQU 0
cl1_size3        EQU copperlist1_SIZE

cl2_size1        EQU 0
cl2_size2        EQU 0
cl2_size3        EQU copperlist2_SIZE


; ** Sprite0-Zusatzstruktur **
; ----------------------------
  RSRESET

spr0_extension1       RS.B 0

spr0_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr0_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*bg_image_y_size

spr0_extension1_SIZE  RS.B 0

; ** Sprite0-Hauptstruktur **
; ---------------------------
  RSRESET

spr0_begin            RS.B 0

spr0_extension1_entry RS.B spr0_extension1_SIZE

spr0_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite0_SIZE          RS.B 0

; ** Sprite1-Zusatzstruktur **
; ----------------------------
  RSRESET

spr1_extension1       RS.B 0

spr1_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr1_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*bg_image_y_size

spr1_extension1_SIZE  RS.B 0

; ** Sprite1-Hauptstruktur **
; ---------------------------
  RSRESET

spr1_begin            RS.B 0

spr1_extension1_entry RS.B spr1_extension1_SIZE

spr1_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite1_SIZE          RS.B 0

; ** Sprite2-Zusatzstruktur **
; ----------------------------
  RSRESET

spr2_extension1       RS.B 0

spr2_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr2_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*bg_image_y_size

spr2_extension1_SIZE  RS.B 0

; ** Sprite2-Hauptstruktur **
; ---------------------------
  RSRESET

spr2_begin            RS.B 0

spr2_extension1_entry RS.B spr2_extension1_SIZE

spr2_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite2_SIZE          RS.B 0

; ** Sprite3-Zusatzstruktur **
; ----------------------------
  RSRESET

spr3_extension1       RS.B 0

spr3_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr3_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*bg_image_y_size

spr3_extension1_SIZE  RS.B 0

; ** Sprite3-Hauptstruktur **
; ---------------------------
  RSRESET

spr3_begin            RS.B 0

spr3_extension1_entry RS.B spr3_extension1_SIZE

spr3_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite3_SIZE          RS.B 0

; ** Sprite4-Zusatzstruktur **
; ----------------------------
  RSRESET

spr4_extension1       RS.B 0

spr4_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr4_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*bg_image_y_size

spr4_extension1_SIZE  RS.B 0

; ** Sprite4-Hauptstruktur **
; ---------------------------
  RSRESET

spr4_begin            RS.B 0

spr4_extension1_entry RS.B spr4_extension1_SIZE

spr4_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite4_SIZE          RS.B 0

; ** Sprite5-Zusatzstruktur **
; ----------------------------
  RSRESET

spr5_extension1       RS.B 0

spr5_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr5_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*bg_image_y_size

spr5_extension1_SIZE  RS.B 0

; ** Sprite5-Hauptstruktur **
; ---------------------------
  RSRESET

spr5_begin            RS.B 0

spr5_extension1_entry RS.B spr5_extension1_SIZE

spr5_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite5_SIZE          RS.B 0

; ** Sprite6-Zusatzstruktur **
; ----------------------------
  RSRESET

spr6_extension1       RS.B 0

spr6_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr6_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*bg_image_y_size

spr6_extension1_SIZE  RS.B 0

; ** Sprite6-Hauptstruktur **
; ---------------------------
  RSRESET

spr6_begin            RS.B 0

spr6_extension1_entry RS.B spr6_extension1_SIZE

spr6_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite6_SIZE          RS.B 0

; ** Sprite7-Zusatzstruktur **
; ----------------------------
  RSRESET

spr7_extension1       RS.B 0

spr7_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr7_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*bg_image_y_size

spr7_extension1_SIZE  RS.B 0

; ** Sprite7-Hauptstruktur **
; ---------------------------
  RSRESET

spr7_begin            RS.B 0

spr7_extension1_entry RS.B spr7_extension1_SIZE

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

; **** Sprite-Fader ****
sprf_colors_counter    RS.W 1
sprf_copy_colors_state RS.W 1

; **** Sprite-Fader-In ****
sprfi_state            RS.W 1
sprfi_fader_angle      RS.W 1

; **** Sprite-Fader-Out ****
sprfo_state            RS.W 1
sprfo_fader_angle      RS.W 1

variables_SIZE         RS.B 0


; ## Beginn des Initialisierungsprogramms ##
; ------------------------------------------
start_01_wrapper
  INCLUDE "sys-init.i"

; ** Eigene Variablen initialisieren **
; -------------------------------------
  CNOP 0,4
init_own_variables

; **** Sprite-Fader ****
  move.w  #sprf_colors_number*3,sprf_colors_counter(a3)
  moveq   #TRUE,d0
  move.w  d0,sprf_copy_colors_state(a3) ;Kopieren der Farben an

; **** Sprite-Fader-In ****
  move.w  d0,sprfi_state(a3) ;Sprite-Fader-In an
  move.w  #sine_table_length/4,sprfi_fader_angle(a3) ;90 Grad

; **** Sprite-Fader-Out ****
  moveq   #FALSE,d1
  move.w  d1,sprfo_state(a3)
  move.w  #sine_table_length/4,sprfo_fader_angle(a3) ;90 Grad
  rts

; ** Alle Initialisierungsroutinen ausführen **
; ---------------------------------------------
  CNOP 0,4
init_all
  bsr.s   init_sprites
  bsr     init_color_registers
  bsr     init_first_copperlist
  bra     init_second_copperlist

; ** Sprites initialisieren **
; ----------------------------
  CNOP 0,4
init_sprites
  bsr.s   spr_init_pointers_table
  bra.s   bg_init_attached_sprites_cluster

; ** Tabelle mit Zeigern auf Sprites initialisieren **
; ----------------------------------------------------
  INIT_SPRITE_POINTERS_TABLE

; ** Spritestrukturen initialisieren **
; -------------------------------------
  INIT_ATTACHED_SPRITES_CLUSTER bg,spr_pointers_display,bg_image_x_position,bg_image_y_position,spr_x_size2,bg_image_y_size,,,REPEAT

; ** Farbregister initialisieren **
; ---------------------------------
  CNOP 0,4
init_color_registers
  CPU_SELECT_COLORHI_BANK 0
  CPU_INIT_COLORHI COLOR00,1,pf1_color_table

  CPU_SELECT_COLORLO_BANK 0
  CPU_INIT_COLORLO COLOR00,1,pf1_color_table
  rts


; ** 1. Copperliste initialisieren **
; -----------------------------------
  CNOP 0,4
init_first_copperlist
  move.l  cl1_display(a3),a0
  bsr.s   cl1_init_playfield_registers
  bsr.s   cl1_init_sprite_pointers
  bsr     cl1_init_color_registers
  COPMOVEQ TRUE,COPJMP2
  bra     cl1_set_sprite_pointers

  COP_INIT_PLAYFIELD_REGISTERS cl1,BLANKSPR

  COP_INIT_SPRITE_POINTERS cl1

  CNOP 0,4
cl1_init_color_registers
  COP_SELECT_COLORHI_BANK 4
  COP_INIT_COLORHI COLOR00,16,spr_color_table

  COP_SELECT_COLORLO_BANK 4
  COP_INIT_COLORLO COLOR00,16,spr_color_table
  rts

  COP_SET_SPRITE_POINTERS cl1,display,spr_number


; ** 2. Copperliste initialisieren **
; -----------------------------------
  CNOP 0,4
init_second_copperlist
  move.l  cl2_display(a3),a0
  COPLISTEND
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
  move.l  a0,-(a7)
  bsr.s   beam_routines
  move.l  (a7)+,a0

  movem.l a0/a3-a6,-(a7)
  bsr     start_010_morph_glenz_vectors
  movem.l (a7)+,a0/a3-a6
  tst.l   d0
  bne.s   exit
  movem.l a0/a3-a6,-(a7)
  bsr     start_011_morph_glenz_vectors
  movem.l (a7)+,a0/a3-a6
  tst.l   d0
  bne.s   exit
  movem.l a0/a3-a6,-(a7)
  bsr     start_012_morph_glenz_vectors
  movem.l (a7)+,a0/a3-a6
  tst.l   d0
  bne.s   exit
  movem.l a0/a3-a6,-(a7)
  bsr     start_013_morph_2xglenz_vectors
  movem.l (a7)+,a0/a3-a6
  tst.l   d0
  bne.s   exit
  movem.l a0/a3-a6,-(a7)
  bsr     start_014_morph_3xglenz_vectors
  movem.l (a7)+,a0/a3-a6
  tst.l   d0
  bne.s   exit

  move.w  #sprf_colors_number*3,sprf_colors_counter(a3)
  moveq   #TRUE,d0
  move.w  d0,sprf_copy_colors_state(a3) ;Kopieren der Farben an
  move.w  d0,sprfo_state(a3) ;Sprite-Fader-Out an

; ## Rasterstahl-Routinen ##
; --------------------------
beam_routines
  bsr     wait_beam_position
  bsr     sprf_copy_color_table
  bsr     sprite_fader_in
  bsr     sprite_fader_out
  bsr     mouse_handler
  tst.l   d0                 ;Abbruch ?
  bne.s   fast_exit          ;Ja -> verzweige
  tst.w   sprfi_state(a3)    ;Sprite-Fader-In an ?
  beq.s   beam_routines      ;Ja -> Schleife
  tst.w   sprfo_state(a3)    ;Sprite-Fader-Out an ?
  beq.s   beam_routines      ;Ja -> Schleife
fast_exit
  move.w  custom_error_code(a3),d1
exit
  rts

; ** Sprites einblenden **
; ------------------------
  CNOP 0,4
sprite_fader_in
  tst.w   sprfi_state(a3)    ;Sprite-Fader-In an ?
  bne.s   no_sprite_fader_in ;Nein -> verzweige
  movem.l a4-a6,-(a7)
  move.w  sprfi_fader_angle(a3),d2 ;Fader-Winkel holen
  move.w  d2,d0
  ADDF.W  sprfi_fader_angle_speed,d0 ;nächster Fader-Winkel
  cmp.w   #sine_table_length/2,d0 ;Y-Winkel <= 180 Grad ?
  ble.s   sprfi_no_restart_fader_angle ;Ja -> verzweige
  MOVEF.W sine_table_length/2,d0 ;180 Grad
sprfi_no_restart_fader_angle
  move.w  d0,sprfi_fader_angle(a3) ;Fader-Winkel retten
  MOVEF.W sprf_colors_number*3,d6 ;Zähler
  lea     sine_table(pc),a0  ;Sinus-Tabelle
  move.w  (a0,d2.w*2),d0     ;sin(w)
  MULSF.W sprfi_fader_radius*2,d0,d1 ;y'=(yr*sin(w))/2^15
  swap    d0
  ADDF.W  sprfi_fader_center,d0 ;+ Fader-Mittelpunkt
  lea     spr_color_table+(1*LONGWORDSIZE)(pc),a0 ;Puffer für Farbwerte
  lea     sprfi_color_table+(1*LONGWORDSIZE)(pc),a1 ;Sollwerte
  move.w  d0,a5              ;Additions-/Subtraktionswert für Blau
  swap    d0                 ;WORDSHIFT
  clr.w   d0                 ;Bits 0-15 löschen
  move.l  d0,a2              ;Additions-/Subtraktionswert für Rot
  lsr.l   #8,d0              ;BYTESHIFT
  move.l  d0,a4              ;Additions-/Subtraktionswert für Grün
  MOVEF.W sprf_colors_number-1,d7 ;Anzahl der Farben
  bsr     sprf_fader_loop
  movem.l (a7)+,a4-a6
  move.w  d6,sprf_colors_counter(a3) ;Image-Fader-In fertig ?
  bne.s   no_sprite_fader_in  ;Nein -> verzweige
  moveq   #FALSE,d0
  move.w  d0,sprfi_state(a3) ;Sprite-Fader-In aus
no_sprite_fader_in
  rts

; ** Sprites ausblenden **
; ------------------------
  CNOP 0,4
sprite_fader_out
  tst.w   sprfo_state(a3)    ;Sprite-Fader-Out an ?
  bne.s   no_sprite_fader_out ;Nein -> verzweige
  movem.l a4-a6,-(a7)
  move.w  sprfo_fader_angle(a3),d2 ;Fader-Winkel holen
  move.w  d2,d0
  ADDF.W  sprfo_fader_angle_speed,d0 ;nächster Fader-Winkel
  cmp.w   #sine_table_length/2,d0 ;Y-Winkel <= 180 Grad ?
  ble.s   sprfo_no_restart_fader_angle ;Ja -> verzweige
  MOVEF.W sine_table_length/2,d0 ;180 Grad
sprfo_no_restart_fader_angle
  move.w  d0,sprfo_fader_angle(a3) ;Fader-Winkel retten
  MOVEF.W sprf_colors_number*3,d6 ;Zähler
  lea     sine_table(pc),a0  ;Sinus-Tabelle
  move.w  (a0,d2.w*2),d0     ;sin(w)
  MULSF.W sprfo_fader_radius*2,d0,d1 ;y'=(yr*sin(w))/2^15
  swap    d0
  ADDF.W  sprfo_fader_center,d0 ;+ Fader-Mittelpunkt
  lea     spr_color_table+(1*LONGWORDSIZE)(pc),a0 ;Puffer für Farbwerte
  lea     sprfo_color_table+(1*LONGWORDSIZE)(pc),a1 ;Sollwerte
  move.w  d0,a5              ;Additions-/Subtraktionswert für Blau
  swap    d0                 ;WORDSHIFT
  clr.w   d0                 ;Bits 0-15 löschen
  move.l  d0,a2              ;Additions-/Subtraktionswert für Rot
  lsr.l   #8,d0              ;BYTESHIFT
  move.l  d0,a4              ;Additions-/Subtraktionswert für Grün
  MOVEF.W sprf_colors_number-1,d7 ;Anzahl der Farben
  bsr     sprf_fader_loop
  movem.l (a7)+,a4-a6
  move.w  d6,sprf_colors_counter(a3) ;Image-Fader-Out fertig ?
  bne.s   no_sprite_fader_out ;Nein -> verzweige
  moveq   #FALSE,d0
  move.w  d0,sprfo_state(a3) ;Sprite-Fader-Out aus
no_sprite_fader_out
  rts

  COLOR_FADER sprf

; ** Farbwerte in Copperliste kopieren **
; ---------------------------------------
  CNOP 0,4
sprf_copy_color_table
  IFNE cl1_size2
    move.l  a4,-(a7)
  ENDC
  tst.w   sprf_copy_colors_state(a3)  ;Kopieren der Farbwerte beendet ?
  bne.s   sprf_no_copy_color_table ;Ja -> verzweige
  move.w  #$0f0f,d3          ;Maske für RGB-Nibbles
  IFGT sprf_colors_number-32
    moveq   #1*8,d4          ;Color-Bank Farbregisterzähler
  ENDC
  lea     spr_color_table+(1*LONGWORDSIZE)(pc),a0 ;Puffer für Farbwerte
  move.l  cl1_display(a3),a1 ;CL
  ADDF.W  cl1_COLOR01_high5+2,a1
  IFNE cl1_size1
    move.l  cl1_construction1(a3),a2 ;CL
    ADDF.W  cl1_COLOR01_high5+2,a2
  ENDC
  IFNE cl1_size2
    move.l  cl1_construction2(a3),a4 ;CL
    ADDF.W  cl1_COLOR01_high5+2,a4
  ENDC
  MOVEF.W sprf_colors_number-1,d7 ;Anzahl der Farben
sprf_copy_color_table_loop
  move.l  (a0)+,d0           ;RGB8-Farbwert
  move.l  d0,d2              ;retten
  RGB8_TO_RGB4HI d0,d1,d3
  move.w  d0,(a1)            ;COLORxx High-Bits
  IFNE cl1_size1
    move.w  d0,(a2)          ;COLORxx High-Bits
  ENDC
  IFNE cl1_size2
    move.w  d0,(a4)          ;COLORxx High-Bits
  ENDC
  RGB8_TO_RGB4LO d2,d1,d3
  move.w  d2,cl1_COLOR01_low5-cl1_COLOR01_high5(a1) ;Low-Bits COLORxx
  addq.w  #4,a1              ;nächstes Farbregister
  IFNE cl1_size1
    move.w  d2,cl1_COLOR01_low5-cl1_COLOR01_high5(a2) ;Low-Bits COLORxx
    addq.w  #4,a2            ;nächstes Farbregister
  ENDC
  IFNE cl1_size2
    move.w  d2,cl1_COLOR01_low5-cl1_COLOR01_high5(a4) ;Low-Bits COLORxx
    addq.w  #4,a4            ;nächstes Farbregister
  ENDC
  IFGT sprf_colors_number-32
    addq.b  #1*8,d4          ;Farbregister-Zähler erhöhen
    bne.s   sprf_no_restart_color_bank ;Nein -> verzweige
    addq.w  #4,a1            ;CMOVE überspringen
    IFNE cl1_size1
      addq.w  #4,a2          ;CMOVE überspringen
    ENDC
    IFNE cl1_size2
      addq.w  #4,a4          ;CMOVE überspringen
    ENDC
sprf_no_restart_color_bank
  ENDC
  dbf     d7,sprf_copy_color_table_loop
  tst.w   sprf_colors_counter(a3) ;Fading beendet ?
  bne.s   sprf_no_copy_color_table ;Nein -> verzweige
  moveq   #FALSE,d0
  move.w  d0,sprf_copy_colors_state(a3) ;Kopieren beendet
sprf_no_copy_color_table
  IFNE cl1_size2
    move.l  (a7)+,a4
  ENDC
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
  DC.L COLOR00BITS

; ** Farben der Sprites **
; ------------------------
spr_color_table
  REPT spr_colors_number
    DC.L COLOR00BITS
  ENDR

; ** Adressen der Sprites **
; --------------------------
spr_pointers_construction
  DS.L spr_number

spr_pointers_display
  DS.L spr_number

; **** Sprite-Fader ****
; ** Zielfarbwerte für Sprite-Fader-In **
; ---------------------------------------
  CNOP 0,4
sprfi_color_table
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/256x283x16-Skyline.ct"

; ** Zielfarbwerte für Sprite-Fader-Out **
; ----------------------------------------
sprfo_color_table
  REPT spr_colors_number
    DC.L COLOR00BITS
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


; ## Grafikdaten nachladen ##
; ---------------------------

; **** Hintergrundbild ****
bg_image_data SECTION gfx1,DATA
  INCBIN "Daten:Asm-Sources.AGA/Superglenz/graphics/256x283x16-Skyline.rawblit"

  END
