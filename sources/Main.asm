; ##############################
; # Programm: Main.asm         #
; # Autor:    Christian Gerbig #
; # Datum:    08.06.2024       #
; # Version:  1.4 beta         #
; # CPU:      68020+           #
; # FASTMEM:  -                #
; # Chipset:  AGA              #
; # OS:       3.0+             #
; ##############################

; V.1.0 Beta
; Erstes Release

; V.1.1 Beta
; Intro: Bugfix, Starterte des horizontal Faders waren dem Wert -1 zugewiesen
; Glenz-Parts 1-3: Bugfix, Für das 3. Playfield waren immer 100 Zeilen zu wenig angegeben -> Guru
; Glenz-Part4: Bugfix, Einscrollen jetzt nicht mehr mit Anzeigefehler, Es wurden von der CPU 8 Bytes zu viel gelöscht
; Glenz-Part5: Morphing-Delay bei 3. Form verkürzt
; Sub-Wrapper: - Ist jetzt kein Wrapper mehr
;              - Bugfix, Fehlerabfrage, jetzt wird sofort bei einem Fehler der Glenz-Parts ausgestiegen
; Alle Module sind jetzt stumm

; V.1.2 Beta
; Bugfix Spritefield-Display-Bug rechter Rand: Alle Sprites weitere 8 Pixel
; nach rechts (X+16).
; Neue Glenz-Parts: 48-Faces-Glenz + 128-Faces-Glenz.


; V.1.3 Beta
; Bugfix: Intro-Part Y-Wrap-Befehl wurde nicht berücksichtigt -> Random-Speicherfehler.
; Alle Morphingsequenzen gekürzt und geändert.
; End-Part: Dual-Playfield mit Schatten für Abspann-Text.

; V1.4 Beta
; End-Part: Cross-Fader für Glenz
; Mit überarbeiteten Include-Files (COPCON)



  SECTION code_and_variables,CODE

  MC68040

  XDEF COLOR00BITS
  XDEF nop_first_copperlist
  XDEF nop_second_copperlist
 
  XREF start_0_pt_replay
  XREF start_1_pt_replay


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

requires_68030             EQU FALSE  
requires_68040             EQU FALSE
requires_68060             EQU FALSE
requires_fast_memory       EQU FALSE
requires_multiscan_monitor EQU FALSE

workbench_start            EQU FALSE
workbench_fade             EQU FALSE
text_output                EQU FALSE

own_display_set_second_copperlist
pass_global_references
pass_return_code

DMABITS                    EQU DMAF_COPPER+DMAF_MASTER+DMAF_SETCLR
INTENABITS                 EQU INTF_INTEN+INTF_SETCLR

CIAAICRBITS                EQU CIAICRF_SETCLR
CIABICRBITS                EQU CIAICRF_SETCLR

COPCONBITS                 EQU TRUE

pf1_x_size1                EQU 0
pf1_y_size1                EQU 0
pf1_depth1                 EQU 0
pf1_x_size2                EQU 0
pf1_y_size2                EQU 0
pf1_depth2                 EQU 0
pf1_x_size3                EQU 0
pf1_y_size3                EQU 0
pf1_depth3                 EQU 0
pf1_colors_number          EQU 0 ;1

pf2_x_size1                EQU 0
pf2_y_size1                EQU 0
pf2_depth1                 EQU 0
pf2_x_size2                EQU 0
pf2_y_size2                EQU 0
pf2_depth2                 EQU 0
pf2_x_size3                EQU 0
pf2_y_size3                EQU 0
pf2_depth3                 EQU 0
pf2_colors_number          EQU 0
pf_colors_number           EQU pf1_colors_number+pf2_colors_number
pf_depth                   EQU pf1_depth3+pf2_depth3

extra_pf_number            EQU 0

spr_number                 EQU 0
spr_x_size1                EQU 0
spr_y_size1                EQU 0
spr_x_size2                EQU 0
spr_y_size2                EQU 0
spr_depth                  EQU 0
spr_colors_number          EQU 0

audio_memory_size          EQU 0

disk_memory_size           EQU 0

extra_memory_size          EQU 0

chip_memory_size           EQU 0

AGA_OS_Version             EQU 39

CIAA_TA_value              EQU 0
CIAA_TB_value              EQU 0
CIAB_TA_value              EQU 0
CIAB_TB_value              EQU 0
CIAA_TA_continuous         EQU FALSE
CIAA_TB_continuous         EQU FALSE
CIAB_TA_continuous         EQU FALSE
CIAB_TB_continuous         EQU FALSE

beam_position              EQU $136

BPLCON0BITS                EQU BPLCON0F_ECSENA+((pf_depth>>3)*BPLCON0F_BPU3)+(BPLCON0F_COLOR)+((pf_depth&$07)*BPLCON0F_BPU0) ;lores
BPLCON3BITS1               EQU TRUE
BPLCON3BITS2               EQU BPLCON3BITS1+BPLCON3F_LOCT
BPLCON4BITS                EQU TRUE
COLOR00BITS                EQU $23388e

cl1_HSTART                 EQU $00
cl1_VSTART                 EQU beam_position&$ff


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

cl1_end          RS.L 1

copperlist1_SIZE RS.B 0


; ** Struktur, die alle Registeroffsets der zweiten Copperliste enthält **
; ------------------------------------------------------------------------
  RSRESET

cl2_begin        RS.B 0

cl2_end          RS.L 1

copperlist2_SIZE RS.B 0


; ** Konstanten für die größe der Copperlisten **
; -----------------------------------------------
cl1_size1          EQU 0
cl1_size2          EQU 0
cl1_size3          EQU copperlist1_SIZE
cl2_size1          EQU 0
cl2_size2          EQU 0
cl2_size3          EQU copperlist2_SIZE

; ** Konstanten für die Größe der Spritestrukturen **
; ---------------------------------------------------
spr0_x_size1       EQU spr_x_size1
spr0_y_size1       EQU 0
spr1_x_size1       EQU spr_x_size1
spr1_y_size1       EQU 0
spr2_x_size1       EQU spr_x_size1
spr2_y_size1       EQU 0
spr3_x_size1       EQU spr_x_size1
spr3_y_size1       EQU 0
spr4_x_size1       EQU spr_x_size1
spr4_y_size1       EQU 0
spr5_x_size1       EQU spr_x_size1
spr5_y_size1       EQU 0
spr6_x_size1       EQU spr_x_size1
spr6_y_size1       EQU 0
spr7_x_size1       EQU spr_x_size1
spr7_y_size1       EQU 0

spr0_x_size2       EQU spr_x_size2
spr0_y_size2       EQU 0
spr1_x_size2       EQU spr_x_size2
spr1_y_size2       EQU 0
spr2_x_size2       EQU spr_x_size2
spr2_y_size2       EQU 0
spr3_x_size2       EQU spr_x_size2
spr3_y_size2       EQU 0
spr4_x_size2       EQU spr_x_size2
spr4_y_size2       EQU 0
spr5_x_size2       EQU spr_x_size2
spr5_y_size2       EQU 0
spr6_x_size2       EQU spr_x_size2
spr6_y_size2       EQU 0
spr7_x_size2       EQU spr_x_size2
spr7_y_size2       EQU 0

; ** Struktur, die alle Variablenoffsets enthält **
; -------------------------------------------------

  INCLUDE "variables-offsets.i"

; ** Relative offsets for variables **
; ------------------------------------

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
  bsr.s   init_color_registers
  bsr     init_first_copperlist
  bra     init_second_copperlist

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
  lea     nop_first_copperlist(pc),a1
  move.l  a0,(a1)
  bsr.s   cl1_init_playfield_registers
  COPLISTEND
  rts

  COP_INIT_PLAYFIELD_REGISTERS cl1,BLANK

; ** 2. Copperliste initialisieren **
; -----------------------------------
  CNOP 0,4
init_second_copperlist
  move.l  cl2_display(a3),a0
  lea     nop_second_copperlist(pc),a1
  move.l  a0,(a1)
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
  bsr    start_0_pt_replay
  tst.l  d0                  ;Ist ein Fehler aufgetreten ?
  bne.s  no_start_1_pt_replay ;Ja -> verzweige
  jmp    start_1_pt_replay
  CNOP 0,4
no_start_1_pt_replay
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


; ## Speicherstellen allgemein ##
; -------------------------------

  INCLUDE "sys-variables.i"

nop_first_copperlist  DC.L 0
nop_second_copperlist DC.L 0


; ## Speicherstellen für Namen ##
; -------------------------------

  INCLUDE "sys-names.i"


; ## Speicherstellen für Texte ##
; -------------------------------

  INCLUDE "error-texts.i"

; ** Programmversion für Version-Befehl **
; ----------------------------------------
prg_version DC.B "$VER: RSE-Superglenz 1.4 beta (8.6.24)",TRUE
  EVEN

  END
