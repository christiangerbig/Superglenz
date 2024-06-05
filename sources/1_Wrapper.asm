; ##############################
; # Programm: 1_Wrapper.asm    #
; # Autor:    Christian Gerbig #
; # Datum:    23.04.2024       #
; # Version:  1.0              #
; # CPU:      68020+           #
; # FASTMEM:  -                #
; # Chipset:  AGA              #
; # OS:       3.0+             #
; ##############################

  SECTION code_and_variables,CODE

  MC68040

  XREF COLOR00BITS
  XREF start_10_credits
  XREF sc_start

  XDEF start_1_pt_replay

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

sys_taken_over
wrapper
own_display_set_second_copperlist
pass_global_references
pass_return_code
custom_memory_used
custom_memory_chip         EQU $00000000
custom_memory_fast         EQU $00000001

pt_v3.0b
  IFD pt_v2.3a
    INCLUDE "music-tracker/pt2-equals.i"
  ENDC
  IFD pt_v3.0b
    INCLUDE "music-tracker/pt3-equals.i"
  ENDC
pt_mute_volume
pt_ciatiming               EQU TRUE
pt_usedfx                  EQU %1101000100000000
pt_usedefx                 EQU %0000000000000001
pt_finetune                EQU FALSE

  IFD pt_v3.0b
pt_metronome               EQU FALSE
  ENDC
pt_track_channel_volumes   EQU FALSE
pt_track_channel_periods   EQU FALSE
pt_music_fader             EQU FALSE
pt_split_module            EQU TRUE

DMABITS                    EQU DMAF_COPPER+DMAF_SETCLR

  IFEQ pt_ciatiming
INTENABITS                 EQU INTF_EXTER+INTF_SETCLR
  ELSE
INTENABITS                 EQU INTF_VERTB+INTF_EXTER+INTF_SETCLR
  ENDC

CIAAICRBITS                EQU CIAICRF_SETCLR
  IFEQ pt_ciatiming
CIABICRBITS                EQU CIAICRF_TA+CIAICRF_TB+CIAICRF_SETCLR
  ELSE
CIABICRBITS                EQU CIAICRF_TB+CIAICRF_SETCLR
  ENDC

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

  IFD pt_v2.3a
audio_memory_size          EQU 0
  ENDC
  IFD pt_v3.0b
audio_memory_size          EQU 2
  ENDC

disk_memory_size           EQU 0

extra_memory_size          EQU 0

chip_memory_size           EQU 0

AGA_OS_Version             EQU 39

  IFEQ pt_ciatiming
CIABCRABITS                EQU CIACRBF_LOAD
  ENDC
CIABCRBBITS                EQU CIACRBF_LOAD+CIACRBF_RUNMODE ;Oneshot mode
CIAA_TA_value              EQU 0
CIAA_TB_value              EQU 0
  IFEQ pt_ciatiming
CIAB_TA_value              EQU 14187 ;= 0.709379 MHz * [20000 �s = 50 Hz duration for one frame on a PAL machine]
;CIAB_TA_value              EQU 14318 ;= 0.715909 MHz * [20000 �s = 50 Hz duration for one frame on a NTSC machine]
  ELSE
CIAB_TA_value              EQU 0
  ENDC
CIAB_TB_value              EQU 362 ;= 0.709379 MHz * [511.43 �s = Lowest note period C1 with Tuning=-8 * 2 / PAL clock constant = 907*2/3546895 ticks per second]
                                 ;= 0.715909 MHz * [506.76 �s = Lowest note period C1 with Tuning=-8 * 2 / NTSC clock constant = 907*2/3579545 ticks per second]
CIAA_TA_continuous         EQU FALSE
CIAA_TB_continuous         EQU FALSE
  IFEQ pt_ciatiming
CIAB_TA_continuous         EQU TRUE
  ELSE
CIAB_TA_continuous         EQU FALSE
  ENDC
CIAB_TB_continuous         EQU FALSE

beam_position              EQU $135

BPLCON0BITS                EQU BPLCON0F_ECSENA+((pf_depth>>3)*BPLCON0F_BPU3)+(BPLCON0F_COLOR)+((pf_depth&$07)*BPLCON0F_BPU0) ;lores
BPLCON3BITS1               EQU TRUE
BPLCON3BITS2               EQU BPLCON3BITS1+BPLCON3F_LOCT
BPLCON4BITS                EQU TRUE

cl1_HSTART                 EQU $00
cl1_VSTART                 EQU beam_position&$ff

; **** Custom Memory ****
custom_memory_number       EQU 2
part_1_audio_memory_size1  EQU 19516 ;Song
part_1_audio_memory_size2  EQU 54000 ;Samples

; **** PT-Replay ****
pt_fade_out_delay          EQU 2 ;Ticks


; ## Makrobefehle ##
; ------------------

  INCLUDE "macros.i"


; ** Struktur, die alle Exception-Vektoren-Offsets enth�lt **
; -----------------------------------------------------------

  INCLUDE "except-vectors-offsets.i"


; ** Struktur, die alle Eigenschaften des Extra-Playfields enth�lt **
; -------------------------------------------------------------------

  INCLUDE "extra-pf-attributes-structure.i"


; ** Struktur, die alle Eigenschaften der Sprites enth�lt **
; ----------------------------------------------------------

  INCLUDE "sprite-attributes-structure.i"


; ** Struktur, die alle Registeroffsets der ersten Copperliste enth�lt **
; -----------------------------------------------------------------------
  RSRESET

cl1_begin        RS.B 0

  INCLUDE "copperlist1-offsets.i"

cl1_end          RS.L 1

copperlist1_SIZE RS.B 0


; ** Struktur, die alle Registeroffsets der zweiten Copperliste enth�lt **
; ------------------------------------------------------------------------
  RSRESET

cl2_begin        RS.B 0

cl2_end          RS.L 1

copperlist2_SIZE RS.B 0


; ** Konstanten f�r die gr��e der Copperlisten **
; -----------------------------------------------
cl1_size1          EQU 0
cl1_size2          EQU 0
cl1_size3          EQU copperlist1_SIZE
cl2_size1          EQU 0
cl2_size2          EQU 0
cl2_size3          EQU copperlist2_SIZE

; ** Konstanten f�r die Gr��e der Spritestrukturen **
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

; ** Struktur, die alle Variablenoffsets enth�lt **
; -------------------------------------------------

  INCLUDE "variables-offsets.i"

; ** Relative offsets for variables **
; ------------------------------------

; **** PT-Replay ****
  IFD pt_v2.3a
    INCLUDE "music-tracker/pt2-variables-offsets.i"
  ENDC
  IFD pt_v3.0b
    INCLUDE "music-tracker/pt3-variables-offsets.i"
  ENDC

variables_SIZE RS.B 0


; **** PT-Replay ****
; ** PT-Song-Structure **
; -----------------------
  INCLUDE "music-tracker/pt-song-structure.i"

; ** Temporary channel structure **
; ---------------------------------
  INCLUDE "music-tracker/pt-temp-channel-structure.i"


; **** Custom-Memory ****
; ** Custom Memory Entry-Structure **
; -----------------------------------
  RSRESET

custom_memory_entry      RS.B 0
cme_memory_size          RS.L 1
cme_memory_type          RS.L 1
cme_memory_pointer       RS.L 1
custom_memory_entry_SIZE RS.B 0


; ## Beginn des Initialisierungsprogramms ##
; ------------------------------------------
start_1_pt_replay
  INCLUDE "sys-init.i"

; ** Custom-Memory-Table initialisieren **
; ----------------------------------------
  CNOP 0,4
init_custom_memory_table
  lea     custom_memory_table(pc),a0
  move.l  #part_1_audio_memory_size1,(a0)+ ;Speichergr��e
  moveq   #custom_memory_fast,d2
  move.l  d2,(a0)+           ;Speicherart: vorrangig fast-memory
  moveq   #TRUE,d0
  move.l  d0,(a0)+           ;Zeiger auf Speicherbereich = Null
  move.l  #part_1_audio_memory_size2,(a0)+ ;Speichergr��e
  move.l  d0,(a0)+           ;Speicherart: chip-memory
  move.l  d0,(a0)            ;Zeiger auf Speicherbereich = Null
  rts

; ** Eigene Variablen initialisieren **
; -------------------------------------
  CNOP 0,4
init_own_variables

; **** PT-Replay ****
  IFD pt_v2.3a
    PT2_INIT_VARIABLES
  ENDC
  IFD pt_v3.0b
    PT3_INIT_VARIABLES
  ENDC
  rts

; **** Main ****
; ** Globale Referenzen erweitern **
; ----------------------------------
  CNOP 0,4
extend_global_references_table
  move.l  global_references_table(a3),a0
  lea     custom_memory_table(pc),a1 ;Zeiger auf Custom-Memory-Tabelle
  move.l  a1,gr_custom_memory_table(a0) ;eintragen
  rts

; ** Alle Initialisierungsroutinen ausf�hren **
; ---------------------------------------------
  CNOP 0,4
init_all
  bsr.s   pt_DetectSysFrequ
  bsr.s   init_CIA_timers
  bsr.s   init_color_registers
  bsr     pt_decrunch_audio_data
  bsr     pt_InitRegisters
  bsr     pt_InitAudTempStrucs
  bsr     pt_ExamineSongStruc
  IFEQ pt_finetune
    bsr     pt_InitFtuPeriodTableStarts
  ENDC
  bsr     init_first_copperlist
  bra     init_second_copperlist

; ** Detect system frequency NTSC/PAL **
; --------------------------------------
  PT_DETECT_SYS_FREQUENCY

; ** CIA-Timer initialisieren **
; ------------------------------
  CNOP 0,4
init_CIA_timers

; **** PT-Replay ****
  PT_INIT_TIMERS
  rts

; ** Farbregister initialisieren **
; ---------------------------------
  CNOP 0,4
init_color_registers
  CPU_SELECT_COLORHI_BANK 0
  CPU_INIT_COLORHI COLOR00,1,pf1_color_table

  CPU_SELECT_COLORLO_BANK 0
  CPU_INIT_COLORLO COLOR00,1,pf1_color_table
  rts

; **** PT-Replay ****
; ** Audiodaten entpacken **
; --------------------------
  CNOP 0,4
pt_decrunch_audio_data
  lea     pt_auddata,a0      ;Quelle: gepackte Daten
  lea     custom_memory_table(pc),a2
  move.l  cme_memory_pointer(a2),a1 ;Ziel: entpackte Daten
  move.l  a1,pt_SongDataPointer(a3)
  movem.l a2-a6,-(a7)
  jsr     sc_start
  movem.l (a7)+,a2-a6
  ADDF.W  custom_memory_entry_size,a2 ;n�chster Custom-Memory-Block
  lea     pt_audsmps,a0
  move.l  cme_memory_pointer(a2),a1
  move.l  a1,pt_SamplesDataPointer(a3)
  movem.l a2-a6,-(a7)
  jsr     sc_start
  movem.l (a7)+,a2-a6
  rts

; ** Audioregister initialisieren **
; ----------------------------------
   PT_INIT_REGISTERS

; ** Tempor�re Audio-Kanal-Struktur initialisieren **
; ---------------------------------------------------
   PT_INIT_AUDIO_TEMP_STRUCTURES

; ** H�chstes Pattern ermitteln und Tabelle mit Zeigern auf Samples initialisieren **
; -----------------------------------------------------------------------------------
   PT_EXAMINE_SONG_STRUCTURE

  IFEQ pt_finetune
; ** FineTuning-Offset-Tabelle initialisieren **
; ----------------------------------------------
    PT_INIT_FINETUNING_PERIOD_TABLE_STARTS
  ENDC


; ** 1. Copperliste initialisieren **
; -----------------------------------
  CNOP 0,4
init_first_copperlist
  move.l  cl1_display(a3),a0
  bsr.s   cl1_init_playfield_registers
  COPLISTEND
  rts

  COP_INIT_PLAYFIELD_REGISTERS cl1,BLANK

; ** 2. Copperliste initialisieren **
; -----------------------------------
  CNOP 0,4
init_second_copperlist
  move.l  cl2_display(a3),a0
  COPLISTEND
  rts

; ** Custom-Memory belegen **
; ---------------------------
  CNOP 0,4
alloc_custom_memory
  move.l  global_references_table(a3),a2
  move.l  gr_custom_memory_table(a2),a2 ;Zeiger auf ersten Listeneintrag
  moveq   #custom_memory_number-1,d7 ;Anzahl der Speicherbl�cke zum Belegen
alloc_custom_memory_loop
  move.l  (a2)+,d0           ;Gr��e der Speicherbereiches
  tst.l   (a2)+              ;Soll Chip-Memory reserviert werden ?
  bne.s   acm_alloc_memory   ;Nein -> verzweige
acm_alloc_chip_memory
  bsr     do_alloc_chip_memory
  move.l  d0,(a2)+           ;Zeiger auf Speicherbereich retten
  beq.s   custom_memory_error ;Wenn NULL -> verzweige
  bra.s   alloc_next_custom_memory
  CNOP 0,4
acm_alloc_memory
  bsr     do_alloc_memory
  move.l  d0,(a2)+           ;Zeiger auf Speicherbereich retten
  beq.s   custom_memory_error ;Wenn NULL -> verzweige
alloc_next_custom_memory
  dbf     d7,alloc_custom_memory_loop
  moveq   #RETURN_OK,d0
  rts
  CNOP 0,4
custom_memory_error
  moveq   #CUSTOM_MEMORY_NO_MEMORY,d0
  move.w  d0,custom_error_code(a3)
  moveq   #RETURN_ERROR,d0
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
  jmp     start_10_credits

  IFEQ pt_music_fader
; ** Mouse-Handler **
; -------------------
    CNOP 0,4
pt_mouse_handler
    btst    #POTINPB_DATLY,POTINP-DMACONR(a6) ;Rechte Mustaste gedr�ckt?
    bne.s   pt_no_mouse_handler ;Nein -> verzweige
    clr.w   pt_fade_out_music_state(a3) ;Fader an
pt_no_mouse_handler
    rts
  ENDC

; ** Speicherbelegung f�r Custom-Memory freigeben **
; --------------------------------------------------
  CNOP 0,4
free_custom_memory
  move.l  global_references_table(a3),a2
  move.l  gr_custom_memory_table(a2),a2 ;Zeiger auf ersten Listeneintrag
  moveq   #custom_memory_number-1,d7 ;Anzahl der Speicherbl�cke zum Freigeben
free_custom_memory_loop
  move.l  (a2),d0            ;Gr��e der Speicherbereiches
  addq.w  #8,a2              ;Speicherattribute �berspringen
  move.l  (a2)+,d1           ;Zeiger auf Speicherbereich holen
  beq.s   free_next_custom_memory ;Wenn NULL -> verzweige
  move.l  d1,a1              ;Zeiger auf Speicherbereich
  CALLEXEC FreeMem           ;Speicher freigeben
free_next_custom_memory
  dbf     d7,free_custom_memory_loop
  rts


; ## Interrupt-Routinen ##
; ------------------------
  
  INCLUDE "int-autovectors-handlers.i"

  IFEQ pt_ciatiming
; ** CIA-B timer A interrupt server **
; ------------------------------------
  CNOP 0,4
CIAB_TA_int_server
  ENDC

  IFNE pt_ciatiming
; ** Vertical blank interrupt server **
; -------------------------------------
  CNOP 0,4
VERTB_int_server
  ENDC

  IFEQ pt_music_fader
    bsr.s   pt_fade_out_music
    bra.s   pt_PlayMusic

; ** Musik ausblenden **
; ----------------------
    PT_FADE_OUT

    CNOP 0,4
  ENDC

; ** PT-replay routine **
; -----------------------
  IFD pt_v2.3a
    PT2_REPLAY pt_SetSoftInterrupt
  ENDC
  IFD pt_v3.0b
    PT3_REPLAY pt_SetSoftInterrupt
  ENDC

; ** 800 "Set Soft Interrupt" **
  CNOP 0,4
pt_SetSoftInterrupt
  move.w  #INTF_SOFTINT+INTF_SETCLR,_CUSTOM+INTREQ
  rts

; ** CIA-B Timer B interrupt server **
  CNOP 0,4
CIAB_TB_int_server
  PT_TIMER_INTERRUPT_SERVER

; ** Level-6-Interrupt-Server **
; ------------------------------
  CNOP 0,4
EXTER_int_server
  rts

; ** Level-7-Interrupt-Server **
; ------------------------------
  CNOP 0,4
NMI_int_server
  rts


; ** Timer stoppen **
; -------------------

  INCLUDE "continuous-timers-stop.i"


; ## System wieder in Ausganszustand zur�cksetzen ##
; --------------------------------------------------

  INCLUDE "sys-return.i"


; ## Hilfsroutinen ##
; -------------------

  INCLUDE "help-routines.i"


; ## Speicherstellen f�r Tabellen und Strukturen ##
; -------------------------------------------------

  INCLUDE "sys-structures.i"

; ** Farben des ersten Playfields **
; ----------------------------------
  CNOP 0,4
pf1_color_table
  DC.L COLOR00BITS

; **** PT-Replay ****
; ** Tables for effect commands **
; --------------------------------
; ** "Invert Loop" **
  INCLUDE "music-tracker/pt-invert-table.i"

; ** "Vibrato/Tremolo" **
  INCLUDE "music-tracker/pt-vibrato-tremolo-table.i"

; ** "Arpeggio/Tone Portamento" **
  IFD pt_v2.3a
    INCLUDE "music-tracker/pt2-period-table.i"
  ENDC
  IFD pt_v3.0b
    INCLUDE "music-tracker/pt3-period-table.i"
  ENDC

; ** Temporary channel structures **
; ----------------------------------
  INCLUDE "music-tracker/pt-temp-channel-data-tables.i"

; ** Pointers to samples **
; -------------------------
  INCLUDE "music-tracker/pt-sample-starts-table.i"

; ** Pointers to priod tables for different tuning **
; ---------------------------------------------------
  INCLUDE "music-tracker/pt-finetune-starts-table.i"

; **** Custom Memory ****
  CNOP 0,4
custom_memory_table
  DS.B custom_memory_entry_SIZE*custom_memory_number


; ## Speicherstellen allgemein ##
; -------------------------------

  INCLUDE "sys-variables.i"


; ## Speicherstellen f�r Namen ##
; -------------------------------

  INCLUDE "sys-names.i"


; ## Speicherstellen f�r Texte ##
; -------------------------------

  INCLUDE "error-texts.i"

; ## Audiodaten nachladen ##
; --------------------------

; **** PT-Replay ****
  IFEQ pt_split_module
pt_auddata SECTION pt_audio,DATA
    INCBIN "Daten:Asm-Sources.AGA/Superglenz/modules/MOD.altitudes2.song.stc"
pt_audsmps SECTION pt_audio2,DATA_C
    INCBIN "Daten:Asm-Sources.AGA/Superglenz/modules/MOD.altitudes2.smps.stc"
  ELSE
pt_auddata SECTION pt_audio,DATA_C
    INCBIN "Daten:Asm-Sources.AGA/Superglenz/modules/MOD.altitudes2"
  ENDC

  END
