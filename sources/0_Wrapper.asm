; ##############################
; # Programm: 0_Wrapper.asm    #
; # Autor:    Christian Gerbig #
; # Datum:    06.04.2024       #
; # Version:  1.0              #
; # CPU:      68020+           #
; # FASTMEM:  -                #
; # Chipset:  AGA              #
; # OS:       3.0+             #
; ##############################

  SECTION code_and_variables,CODE

  MC68040


  XREF color00_bits
  XREF start_00_intro
  XREF start_01_wrapper

  XDEF start_0_pt_replay
  XDEF sc_start


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


SYS_TAKEN_OVER             SET 1
WRAPPER                    SET 1
PASS_GLOBAL_REFERENCES     SET 1
PASS_RETURN_CODE           SET 1
SET_SECOND_COPPERLIST      SET 1
CUSTOM_MEMORY_USED         SET 1
PROTRACKER_VERSION_3.0B    SET 1


  INCLUDE "macros.i"


  INCLUDE "equals.i"

requires_030_cpu           EQU FALSE  
requires_040_cpu           EQU FALSE
requires_060_cpu           EQU FALSE
requires_fast_memory       EQU FALSE
requires_multiscan_monitor EQU FALSE

workbench_start_enabled    EQU FALSE
screen_fader_enabled       EQU FALSE
text_output_enabled        EQU FALSE

CUSTOM_MEMORY_CHIP         EQU $00000000
CUSTOM_MEMORY_FAST         EQU $00000001

  IFD PROTRACKER_VERSION_2.3A 
    INCLUDE "music-tracker/pt2-equals.i"
  ENDC
  IFD PROTRACKER_VERSION_3.0B
    INCLUDE "music-tracker/pt3-equals.i"
  ENDC
pt_ciatiming_enabled       EQU TRUE
pt_finetune_enabled        EQU FALSE
  IFD PROTRACKER_VERSION_3.0B
pt_metronome_enabled       EQU FALSE
  ENDC
pt_mute_enabled            EQU TRUE
pt_track_volumes_enabled   EQU FALSE
pt_track_periods_enabled   EQU FALSE
pt_music_fader_enabled     EQU FALSE
pt_split_module_enabled    EQU TRUE
pt_usedfx                  EQU %1101010100010110
pt_usedefx                 EQU %0000000000000001

dma_bits                   EQU DMAF_COPPER+DMAF_SETCLR

  IFEQ pt_ciatiming_enabled
intena_bits                EQU INTF_EXTER+INTF_SETCLR
  ELSE
intena_bits                EQU INTF_VERTB+INTF_EXTER+INTF_SETCLR
  ENDC

ciaa_icr_bits              EQU CIAICRF_SETCLR
  IFEQ pt_ciatiming_enabled
ciab_icr_bits              EQU CIAICRF_TA+CIAICRF_TB+CIAICRF_SETCLR
  ELSE
ciab_icr_bits              EQU CIAICRF_TB+CIAICRF_SETCLR
  ENDC

copcon_bits                EQU 0

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

pf_extra_number            EQU 0

spr_number                 EQU 0
spr_x_size1                EQU 0
spr_y_size1                EQU 0
spr_x_size2                EQU 0
spr_y_size2                EQU 0
spr_depth                  EQU 0
spr_colors_number          EQU 0

  IFD PROTRACKER_VERSION_2.3A 
audio_memory_size          EQU 0
  ENDC
  IFD PROTRACKER_VERSION_3.0B
audio_memory_size          EQU 2
  ENDC

disk_memory_size           EQU 0

extra_memory_size          EQU 0

chip_memory_size           EQU 0
  IFEQ pt_ciatiming_enabled
ciab_cra_bits              EQU CIACRBF_LOAD
  ENDC
ciab_crb_bits              EQU CIACRBF_LOAD+CIACRBF_RUNMODE ;Oneshot mode
ciaa_ta_time               EQU 0
ciaa_tb_time               EQU 0
  IFEQ pt_ciatiming_enabled
ciab_ta_time               EQU 14187 ;= 0.709379 MHz * [20000 �s = 50 Hz duration for one frame on a PAL machine]
;ciab_ta_time               EQU 14318 ;= 0.715909 MHz * [20000 �s = 50 Hz duration for one frame on a NTSC machine]
  ELSE
ciab_ta_time               EQU 0
  ENDC
ciab_tb_time               EQU 362 ;= 0.709379 MHz * [511.43 �s = Lowest note period C1 with Tuning=-8 * 2 / PAL clock constant = 907*2/3546895 ticks per second]
                                   ;= 0.715909 MHz * [506.76 �s = Lowest note period C1 with Tuning=-8 * 2 / NTSC clock constant = 907*2/3579545 ticks per second]
ciaa_ta_continuous_enabled EQU FALSE
ciaa_tb_continuous_enabled EQU FALSE
  IFEQ pt_ciatiming_enabled
ciab_ta_continuous_enabled EQU TRUE
  ELSE
ciab_ta_continuous_enabled EQU FALSE
  ENDC
ciab_tb_continuous_enabled EQU FALSE

beam_position              EQU $136

bplcon0_bits               EQU BPLCON0F_ECSENA+((pf_depth>>3)*BPLCON0F_BPU3)+(BPLCON0F_COLOR)+((pf_depth&$07)*BPLCON0F_BPU0) 
bplcon3_bits1              EQU 0
bplcon3_bits2              EQU bplcon3_bits1+BPLCON3F_LOCT
bplcon4_bits               EQU 0

cl1_hstart                 EQU $00
cl1_vstart                 EQU beam_position&$ff

; **** Custom Memory ****
custom_memory_number       EQU 2
part_0_audio_memory_size1  EQU 29756 ;Song
part_0_audio_memory_size2  EQU 149020 ;Samples

; **** PT-Replay ****
pt_fade_out_delay          EQU 2 ;Ticks


  INCLUDE "except-vectors-offsets.i"


  INCLUDE "extra-pf-attributes.i"


  INCLUDE "sprite-attributes.i"


  RSRESET

cl1_begin        RS.B 0

  INCLUDE "copperlist1-offsets.i"

cl1_end          RS.L 1

copperlist1_size RS.B 0


  RSRESET

cl2_begin        RS.B 0

cl2_end          RS.L 1

copperlist2_size RS.B 0


; ** Konstanten f�r die gr��e der Copperlisten **
cl1_size1          EQU 0
cl1_size2          EQU 0
cl1_size3          EQU copperlist1_size
cl2_size1          EQU 0
cl2_size2          EQU 0
cl2_size3          EQU copperlist2_size

; ** Konstanten f�r die Gr��e der Spritestrukturen **
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


  RSRESET

  INCLUDE "variables-offsets.i"

; ** Relative offsets for variables **

; **** PT-Replay ****
  IFD PROTRACKER_VERSION_2.3A 
    INCLUDE "music-tracker/pt2-variables-offsets.i"
  ENDC
  IFD PROTRACKER_VERSION_3.0B
    INCLUDE "music-tracker/pt3-variables-offsets.i"
  ENDC

variables_size RS.B 0


; **** PT-Replay ****
; ** PT-Song-Structure **
  INCLUDE "music-tracker/pt-song.i"

; ** Temporary channel structure **
  INCLUDE "music-tracker/pt-temp-channel.i"


; **** Custom-Memory ****
; ** Custom Memory Entry-Structure **
  RSRESET

custom_memory_entry      RS.B 0
cme_memory_size          RS.L 1
cme_memory_type          RS.L 1
cme_memory_pointer       RS.L 1
custom_memory_entry_size RS.B 0


start_0_pt_replay

  INCLUDE "sys-wrapper.i"

; ** Custom-Memory-Table initialisieren **
  CNOP 0,4
init_custom_memory_table
  lea     custom_memory_table(pc),a0
  move.l  #part_0_audio_memory_size1,(a0)+ ;Speichergr��e
  moveq   #CUSTOM_MEMORY_FAST,d2
  move.l  d2,(a0)+           ;Speicherart: vorrangig fast-memory
  moveq   #0,d0
  move.l  d0,(a0)+           ;Zeiger auf Speicherbereich = Null
  move.l  #part_0_audio_memory_size2,(a0)+ ;Speichergr��e
  move.l  d0,(a0)+           ;Speicherart: chip-memory
  move.l  d0,(a0)            ;Zeiger auf Speicherbereich = Null
  rts

  CNOP 0,4
init_own_variables

; **** PT-Replay ****
  IFD PROTRACKER_VERSION_2.3A 
    PT2_INIT_VARIABLES
  ENDC
  IFD PROTRACKER_VERSION_3.0B
    PT3_INIT_VARIABLES
  ENDC
  rts

; **** Main ****
; ** Globale Referenzen erweitern **
  CNOP 0,4
extend_global_references_table
  move.l  global_references_table(a3),a0
  lea     custom_memory_table(pc),a1 ;Zeiger auf Custom-Memory-Tabelle
  move.l  a1,gr_custom_memory_table(a0) ;eintragen
  rts

; ** Alle Initialisierungsroutinen ausf�hren **
  CNOP 0,4
init_all
  bsr.s   pt_DetectSysFrequ
  bsr     pt_decrunch_audio_data
  bsr     pt_InitRegisters
  bsr     pt_InitAudTempStrucs
  bsr     pt_ExamineSongStruc
  IFEQ pt_finetune_enabled
    bsr     pt_InitFtuPeriodTableStarts
  ENDC
  bsr     init_color_registers
  bsr     init_CIA_timers
  bsr     init_first_copperlist
  bra     init_second_copperlist

; **** PT-Replay ****
; ** Detect system frequency NTSC/PAL **
  PT_DETECT_SYS_FREQUENCY

; ** Audiodaten entpacken **
  CNOP 0,4
pt_decrunch_audio_data
  lea     pt_auddata,a0      ;Quelle: gepackte Daten
  lea     custom_memory_table(pc),a2
  move.l  cme_memory_pointer(a2),a1 ;Ziel: entpackte Daten
  move.l  a1,pt_SongDataPointer(a3)
  movem.l a2-a6,-(a7)
  bsr     sc_start
  movem.l (a7)+,a2-a6
  ADDF.W  custom_memory_entry_size,a2 ;n�chster Custom-Memory-Block
  lea     pt_audsmps,a0
  move.l  cme_memory_pointer(a2),a1
  move.l  a1,pt_SamplesDataPointer(a3)
  movem.l a2-a6,-(a7)
  bsr     sc_start
  movem.l (a7)+,a2-a6
  rts

; ** Audioregister initialisieren **
  PT_INIT_REGISTERS

; ** Tempor�re Audio-Kanal-Struktur initialisieren **
  PT_INIT_AUDIO_TEMP_STRUCTURES

; ** H�chstes Pattern ermitteln und Tabelle mit Zeigern auf Samples initialisieren **

  PT_EXAMINE_SONG_STRUCTURE

  IFEQ pt_finetune_enabled
; ** FineTuning-Offset-Tabelle initialisieren **
    PT_INIT_FINETUNE_TABLE_STARTS
  ENDC


  CNOP 0,4
init_color_registers
  CPU_SELECT_COLOR_HIGH_BANK 0
  CPU_INIT_COLOR_HIGH COLOR00,1,pf1_color_table

  CPU_SELECT_COLOR_LOW_BANK 0
  CPU_INIT_COLOR_LOW COLOR00,1,pf1_color_table
  rts

; ** CIA-Timer initialisieren **
  CNOP 0,4
init_CIA_timers

; **** PT-Replay ****
  PT_INIT_TIMERS
  rts

  CNOP 0,4
init_first_copperlist
  move.l  cl1_display(a3),a0
  bsr.s   cl1_init_playfield_registers
  COP_LISTEND
  rts

  COP_INIT_PLAYFIELD_REGISTERS cl1,BLANK

  CNOP 0,4
init_second_copperlist
  move.l  cl2_display(a3),a0
  COP_LISTEND
  rts

; ** Custom-Memory belegen **
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

  CNOP 0,4
main_routine
  bsr     start_00_intro
  tst.l   d0
  bne.s   no_start_01_wrapper
  bsr     start_01_wrapper
no_start_01_wrapper
  rts

  IFEQ pt_music_fader_enabled
; ** Mouse-Handler **
    CNOP 0,4
pt_mouse_handler
    btst    #POTINPB_DATLY,POTINP-DMACONR(a6) ;Rechte Mustaste gedr�ckt?
    bne.s   pt_no_mouse_handler ;Nein -> verzweige
    clr.w   pt_music_fader_active(a3) ;Fader an
pt_no_mouse_handler
    rts
  ENDC

; ** Speicherbelegung f�r Custom-Memory freigeben **
  CNOP 0,4
free_custom_memory
  move.l  global_references_table(a3),a2
  move.l  gr_custom_memory_table(a2),a2 ;Zeiger auf ersten Listeneintrag
  moveq   #custom_memory_number-1,d7 ;Anzahl der Speicherbl�cke zum Freigeben
free_custom_memory_loop
  move.l  (a2),d0            ;Gr��e der Speicherbereiches
  addq.w  #8,a2              ;Speicherattribute �berspringen
  move.l  (a2)+,d1           ;Zeiger auf Speicherbereich 
  beq.s   free_next_custom_memory ;Wenn NULL -> verzweige
  move.l  d1,a1              ;Zeiger auf Speicherbereich
  CALLEXEC FreeMem           ;Speicher freigeben
free_next_custom_memory
  dbf     d7,free_custom_memory_loop
  rts


  INCLUDE "int-autovectors-handlers.i"

  IFEQ pt_ciatiming_enabled
; ** CIA-B timer A interrupt server **
  CNOP 0,4
ciab_ta_int_server
  ENDC

  IFNE pt_ciatiming_enabled
; ** Vertical blank interrupt server **
  CNOP 0,4
VERTB_int_server
  ENDC

  IFEQ pt_music_fader_enabled
    bsr.s   pt_music_fader
    bra.s   pt_PlayMusic

; ** Musik ausblenden **
    PT_FADE_OUT_VOLUME

    CNOP 0,4
  ENDC

; ** PT-replay routine **
  IFD PROTRACKER_VERSION_2.3A 
    PT2_REPLAY pt_SetSoftInterrupt
  ENDC
  IFD PROTRACKER_VERSION_3.0B
    PT3_REPLAY pt_SetSoftInterrupt
  ENDC

; ** 800 "Set Soft Interrupt" **
  CNOP 0,4
pt_SetSoftInterrupt
  move.w  #INTF_SOFTINT+INTF_SETCLR,_CUSTOM+INTREQ
  rts

; ** CIA-B Timer B interrupt server **
  CNOP 0,4
ciab_tb_int_server
  PT_TIMER_INTERRUPT_SERVER

; ** Level-6-Interrupt-Server **
  CNOP 0,4
EXTER_int_server
  rts

; ** Level-7-Interrupt-Server **
  CNOP 0,4
NMI_int_server
  rts


  INCLUDE "help-routines.i"

;-----------------------------------------------------------------------------
;- S404 highly optimized data decruncher v1.1 turbo
;- 27.11.93 by Marcus 'Cozine' Ottosson
;-----------------------------------------------------------------------------
;- Based on S404 data_decruncher v0.2
;- (c) 1993 by Jouni 'Mr.Spiv' Korhonen (SWSW)
;-----------------------------------------------------------------------------
;- call with registers: a0 = crunched datas
;-                      a1 = destination address
;-----------------------------------------------------------------------------
;- d0-d7/a0-a6 are trashed
;-----------------------------------------------------------------------------

  CNOP 0,4
sc_start
  addq.w  #8,a0              ;ID string & security length �berspringen
  move.l  a1,a5
  add.l   (a0)+,a1
  moveq   #0,d4
  add.l   (a0),a0
  moveq   #16,d5
  movem.w (a0),d2/d6/d7
  not.w	  d4
  lea     sc_off6(pc),a3
  lea     sc_len5a(pc),a4
  moveq	  #1,d0
  moveq	  #-1,d3
  bra.s	  sc_test1
  CNOP 0,4
sc_ins
  subq.w  #8,d7
  bpl.s	  sc_ins2
sc_ins1
  move.w  d7,d1
  addq.w  #8,d7
  lsl.l   d7,d6
  move.w  -(a0),d6
  neg.w	  d1
  lsl.l	  d1,d6
  addq.w  #8,d7
  swap	  d6
  move.b  d6,-(a1)
  swap	  d6
  cmp.l	  a1,a5
  dbhs	  d7,sc_main
  bra.s	  sc_exma
  CNOP 0,4
sc_ins2
  rol.w	  #8,d6
  move.b  d6,-(a1)
sc_test1
  cmp.l	  a1,a5
  dbhs	  d7,sc_main
sc_exma
  bhs.s   sc_exit

sc_main1
  move.w  -(a0),d6
  moveq	  #16-1,d7
sc_main
  add.w	  d6,d6
  bcc.s	  sc_ins
  dbf	  d7,sc_len1
  move.w  -(a0),d6
  moveq	  #16-1,d7
sc_len1
  add.w   d6,d6
  bcs.s	  sc_len6
  dbf	  d7,sc_len2
  move.w  -(a0),d6
  moveq	  #16-1,d7
sc_len2
  moveq	  #2,d1
  moveq	  #2,d3
  add.w	  d6,d6
  bcs.s	  sc_len5
  dbf	  d7,sc_len3
  move.w  -(a0),d6
  moveq	  #16-1,d7
sc_len3
  add.w	  d6,d6
  bcc.s	  sc_len4
  moveq	  #4,d1
  moveq	  #6,d3
  lea	  sc_len3a(pc),a6
  bra.s	  sc_bits
  CNOP 0,4
sc_len3a
  add.w	  d1,d3
  cmp.w	  #15,d1
  blo.s	  sc_off1
  moveq	  #5,d1
  moveq	  #14,d3
  lea	  sc_len3b(pc),a6
  bra.s	  sc_bits
  CNOP 0,4
sc_len4
  moveq	  #21,d3
sc_loop
  moveq	  #8,d1
sc_len5
  move.l  a4,a6
  bra.s	  sc_bits
  CNOP 0,4
sc_len5a
  add.w	  d1,d3
  not.b	  d1
  dbeq	  d7,sc_off2
  bne.s	  sc_off2a
  beq.s	  sc_loop

sc_off6
  add.w	  d1,a2
  move.b  (a2),-(a1)
sc_copy
  move.b  -(a2),-(a1)
  dbf	  d3,sc_copy
sc_test
  cmp.l	  a1,a5
  dbhs	  d7,sc_main
  blo.s   sc_main1
sc_exit
  CALLEXECQ CacheClearU      ;Caches flushen

  CNOP 0,4
sc_len6
  dbf     d7,sc_len7
  move.w  -(a0),d6
  moveq	  #16-1,d7
sc_len7
  add.w	  d6,d6
  addx.w  d0,d3
sc_off1
  dbf     d7,sc_off2
sc_off2a
  move.w  -(a0),d6
  moveq	  #16-1,d7
sc_off2
  add.w	  d6,d6
  bcs.s	  sc_off3
  dbf     d7,sc_off4
  move.w  -(a0),d6
  moveq	  #16-1,d7
sc_off4
  moveq	  #9,d1
  lea     32(a1),a2
  add.w	  d6,d6
  bcc.s	  sc_off5
  moveq	  #5,d1
  move.l  a1,a2
  bra.s	  sc_off5
  CNOP 0,4
sc_off3
  lea     544(a1),a2
  move.w  d2,d1
sc_off5
  move.l  a3,a6

sc_bits
  and.l	  d4,d6
  sub.w	  d1,d7
  bpl.s	  sc_bits2
  add.w	  d7,d1
  lsl.l	  d1,d6
  move.w  d7,d1
  move.w  -(a0),d6
  neg.w	  d1
  add.w	  d5,d7
sc_bits2
  lsl.l	  d1,d6
  move.l  d6,d1
  swap.w  d1
  jmp	  (a6)
  CNOP    0,4
sc_pins2
  moveq	  #-1,d3
  bra.w	  sc_ins2
  CNOP 0,4
sc_2ins2
  rol.w	  #8,d6
  move.b  d6,-(a1)
sc_2ins1
  lsl.l	  d7,d6
  move.w  -(a0),d6
  lsl.l	  d1,d6
  swap	  d6
  move.b  d6,-(a1)
  swap	  d6
  subq.w  #2,d3
  bgt.s	  sc_2ins2
  beq.s	  sc_pins2
  addq.w  #8,d7
  bra	  sc_test
  CNOP 0,4
sc_len3b
  add.w	  d1,d3
  move.b  sc_newd1(pc,d7),d1
  bpl.s	  sc_2ins1
  subq.w  #8,d7
  dbf	  d3,sc_2ins2
  rts                        ;Sicherheitshalber erg�nzt

sc_newd1
  DC.B $08,$07,$06,$05,$04,$03,$02,$01
  DC.B $88,$87,$86,$85,$84,$83,$82,$81


  INCLUDE "sys-structures.i"


  CNOP 0,4
pf1_color_table
  DC.L color00_bits

; **** PT-Replay ****
; ** Tables for effect commands **
; ** "Invert Loop" **
  INCLUDE "music-tracker/pt-invert-table.i"

; ** "Vibrato/Tremolo" **
  INCLUDE "music-tracker/pt-vibrato-tremolo-table.i"

; ** "Arpeggio/Tone Portamento" **
  IFD PROTRACKER_VERSION_2.3A 
    INCLUDE "music-tracker/pt2-period-table.i"
  ENDC
  IFD PROTRACKER_VERSION_3.0B
    INCLUDE "music-tracker/pt3-period-table.i"
  ENDC

; ** Temporary channel structures **
  INCLUDE "music-tracker/pt-temp-channel-data-tables.i"

; ** Pointers to samples **
  INCLUDE "music-tracker/pt-sample-starts-table.i"

; ** Pointers to priod tables for different tuning **
  INCLUDE "music-tracker/pt-finetune-starts-table.i"

; **** Custom Memory ****
  CNOP 0,4
custom_memory_table
  DS.B custom_memory_entry_size*custom_memory_number


  INCLUDE "sys-variables.i"


  INCLUDE "sys-names.i"


  INCLUDE "error-texts.i"


; ** Audiodaten nachladen **

; **** PT-Replay ****
  IFEQ pt_split_module_enabled
pt_auddata SECTION pt_audio,DATA
    INCBIN "Daten:Asm-Sources.AGA/projects/Superglenz/modules/MOD.1989-a number.song.stc"
pt_audsmps SECTION pt_audio2,DATA_C
    INCBIN "Daten:Asm-Sources.AGA/projects/Superglenz/modules/MOD.1989-a number.smps.stc"
  ELSE
pt_auddata SECTION pt_audio,DATA_C
    INCBIN "Daten:Asm-Sources.AGA/projects/Superglenz/modules/MOD.1989-a number"
  ENDC

  END
