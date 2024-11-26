; ##############################
; # Programm: 01_Wrapper.asm   #
; # Autor:    Christian Gerbig #
; # Datum:    13.04.2024       #
; # Version:  1.0              #
; # CPU:      68020+           #
; # FASTMEM:  -                #
; # Chipset:  AGA              #
; # OS:       3.0+             #
; ##############################

; Zusätzliches Playfield in 16 Farben aus vier attached 64-Pixel-Sprites,
; wobei nach 256 Pixeln jedes Sprite wiederholt wird.

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

  INCDIR "Daten:Asm-Sources.AGA/custom-includes/"


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

DMABITS                     EQU DMAF_SPRITE+DMAF_COPPER+DMAF_MASTER+DMAF_SETCLR
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
spr_y_size2                 EQU 283
spr_depth                   EQU 2
spr_colors_number           EQU 16
spr_odd_color_table_select  EQU 1
spr_even_color_table_select EQU 1
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

beam_position               EQU $136

MINROW                      EQU VSTART_OVERSCAN_PAL

spr_pixel_per_datafetch     EQU 64 ;4x

BPLCON0BITS                 EQU BPLCON0F_ECSENA+((pf_depth>>3)*BPLCON0F_BPU3)+(BPLCON0F_COLOR)+((pf_depth&$07)*BPLCON0F_BPU0) ;lores
BPLCON3BITS1                EQU BPLCON3F_BRDSPRT+BPLCON3F_SPRES0
BPLCON3BITS2                EQU BPLCON3BITS1+BPLCON3F_LOCT
BPLCON4BITS                 EQU (BPLCON4F_OSPRM4*spr_odd_color_table_select)+(BPLCON4F_ESPRM4*spr_even_color_table_select)
FMODEBITS                   EQU FMODEF_SPR32+FMODEF_SPAGEM+FMODEF_SSCAN2
COLOR00BITS                 EQU $23388e

cl1_HSTART                  EQU $00
cl1_VSTART                  EQU beam_position&cl_y_wrap

; **** Hintergrundbild ****
bg_image_x_size             EQU 256
bg_image_plane_width        EQU bg_image_x_size/8
bg_image_y_size             EQU 283
bg_image_depth              EQU 4
bg_image_x_position         EQU 8
bg_image_y_position         EQU MINROW


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

cl1_WAIT1        RS.L 1
cl1_WAIT2        RS.L 1
cl1_INTREQ       RS.L 1

cl1_end          RS.L 1

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
spr0_ext1_planedata   RS.L spr_y_size2*(spr_pixel_per_datafetch/16)

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
spr1_ext1_planedata   RS.L spr_y_size2*(spr_pixel_per_datafetch/16)

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
spr2_ext1_planedata   RS.L spr_y_size2*(spr_pixel_per_datafetch/16)

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
spr3_ext1_planedata   RS.L spr_y_size2*(spr_pixel_per_datafetch/16)

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
spr4_ext1_planedata   RS.L spr_y_size2*(spr_pixel_per_datafetch/16)

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
spr5_ext1_planedata   RS.L spr_y_size2*(spr_pixel_per_datafetch/16)

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
spr6_ext1_planedata   RS.L spr_y_size2*(spr_pixel_per_datafetch/16)

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
spr7_ext1_planedata   RS.L spr_y_size2*(spr_pixel_per_datafetch/16)

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

variables_SIZE RS.B 0


; ## Beginn des Initialisierungsprogramms ##
; ------------------------------------------

  INCLUDE "sys-init.i"

; ** Eigene Variablen initialisieren **
; -------------------------------------
  CNOP 0,4
init_own_variables
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
  INIT_ATTACHED_SPRITES_CLUSTER bg,spr_pointers_display,bg_image_x_position,bg_image_y_position,spr_x_size2,,,REPEAT

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
  bsr     cl1_init_copint
  COPLISTEND
  bra     cl1_set_sprite_pointers

  COP_INIT_PLAYFIELD_REGISTERS cl1,ONLYSPRITES

  COP_INIT_SPRITE_POINTERS cl1

  CNOP 0,4
cl1_init_color_registers
  COP_INIT_COLORHI COLOR16,16,spr_color_table

  COP_SELECT_COLORLO_BANK 0
  COP_INIT_COLORLO COLOR16,16,spr_color_table
  rts

  COP_INIT_COPINT cl1,cl1_HSTART,cl1_VSTART,YWRAP

  COP_SET_SPRITE_POINTERS cl1,display,spr_number


; ** 2. Copperliste initialisieren **
; -----------------------------------
  CNOP 0,4
init_second_copperlist
  move.l  cl2_display(a3),a0 ;Darstellen-CL
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
  btst    #CIAB_GAMEPORT0,CIAPRA(a4) ;Auf linke Maustaste warten
  bne.s   beam_routines
  rts


; ## Interrupt-Routinen ##
; ------------------------
  
  INCLUDE "int-autovectors-handlers.i"

; ** Level-7-Interrupt-Server **
; ------------------------------
  CNOP 0,4
nmi_int_server
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
  INCLUDE "Daten:Asm-Sources.AGA/Superglenz/colortables/256x283x16-Skyline.ct"

; ** Adressen der Sprites **
; --------------------------
spr_pointers_construction
  DS.L spr_number

spr_pointers_display
  DS.L spr_number


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
prg_version DC.B "$VER: Spriteplayfield2 1.0 (22.10.23)",TRUE
  EVEN


; ## Grafikdaten nachladen ##
; ---------------------------

; **** Hintergrundbild ****
bg_image_data SECTION gfx1,DATA
  INCBIN "Daten:Asm-Sources.AGA/Superglenz/graphics/256x283x16-Skyline.rawblit"

  END
