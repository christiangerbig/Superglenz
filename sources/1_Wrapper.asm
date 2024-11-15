; Programm:	1_Wrapper
; Autor:	Christian Gerbig
; Datum:	23.04.2024
; Version:	1.0


; CPU:		68020+
; Fast-Memory:	-
; Chipset:	AGA PAL
; OS:		3.0+


	SECTION code_and_variables,CODE

	MC68040


	XREF color00_bits
	XREF start_10_credits
	XREF sc_start

	XDEF start_1_pt_replay
	XDEF global_music_fader_active
	XDEF global_stop_fx_active


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


	INCDIR "Daten:Asm-Sources.AGA/custom-includes/"


SYS_TAKEN_OVER			SET 1
WRAPPER				SET 1
PASS_GLOBAL_REFERENCES		SET 1
PASS_RETURN_CODE		SET 1
SET_SECOND_COPPERLIST		SET 1
CUSTOM_MEMORY_USED		SET 1
PROTRACKER_VERSION_3.0B		SET 1


	INCLUDE "macros.i"


	INCLUDE "equals.i"

requires_030_cpu		EQU FALSE	
requires_040_cpu		EQU FALSE
requires_060_cpu		EQU FALSE
requires_fast_memory		EQU FALSE
requires_multiscan_monitor	EQU FALSE

workbench_start_enabled		EQU FALSE
screen_fader_enabled		EQU FALSE
text_output_enabled		EQU FALSE

CUSTOM_MEMORY_CHIP		EQU $00000000
CUSTOM_MEMORY_FAST		EQU $00000001

pt_ciatiming_enabled		EQU TRUE
pt_finetune_enabled		EQU FALSE
pt_metronome_enabled		EQU FALSE
pt_mute_enabled			EQU FALSE
pt_track_volumes_enabled	EQU FALSE
pt_track_periods_enabled	EQU FALSE
pt_music_fader_enabled		EQU TRUE
pt_split_module_enabled		EQU TRUE
pt_usedfx			EQU %1101011100001000
pt_usedefx			EQU %0011000000000000

dma_bits			EQU DMAF_COPPER|DMAF_SETCLR

	IFEQ pt_ciatiming_enabled
intena_bits			EQU INTF_EXTER|INTF_SETCLR
	ELSE
intena_bits			EQU INTF_VERTB|INTF_EXTER|INTF_SETCLR
	ENDC

ciaa_icr_bits			EQU CIAICRF_SETCLR
	IFEQ pt_ciatiming_enabled
ciab_icr_bits			EQU CIAICRF_TA|CIAICRF_TB|CIAICRF_SETCLR
	ELSE
ciab_icr_bits			EQU CIAICRF_TB|CIAICRF_SETCLR
	ENDC

copcon_bits			EQU 0

pf1_x_size1			EQU 0
pf1_y_size1			EQU 0
pf1_depth1			EQU 0
pf1_x_size2			EQU 0
pf1_y_size2			EQU 0
pf1_depth2			EQU 0
pf1_x_size3			EQU 0
pf1_y_size3			EQU 0
pf1_depth3			EQU 0
pf1_colors_number		EQU 0	; 1

pf2_x_size1			EQU 0
pf2_y_size1			EQU 0
pf2_depth1			EQU 0
pf2_x_size2			EQU 0
pf2_y_size2			EQU 0
pf2_depth2			EQU 0
pf2_x_size3			EQU 0
pf2_y_size3			EQU 0
pf2_depth3			EQU 0
pf2_colors_number		EQU 0
pf_colors_number		EQU pf1_colors_number+pf2_colors_number
pf_depth			EQU pf1_depth3+pf2_depth3

pf_extra_number			EQU 0

spr_number			EQU 0
spr_x_size1			EQU 0
spr_y_size1			EQU 0
spr_x_size2			EQU 0
spr_y_size2			EQU 0
spr_depth			EQU 0
spr_colors_number		EQU 0

	IFD PROTRACKER_VERSION_2.3A 
audio_memory_size		EQU 0
	ENDC
	IFD PROTRACKER_VERSION_3.0B
audio_memory_size		EQU 2
	ENDC

disk_memory_size		EQU 0

extra_memory_size		EQU 0

chip_memory_size		EQU 0

	IFEQ pt_ciatiming_enabled
ciab_cra_bits			EQU CIACRBF_LOAD
	ENDC
ciab_crb_bits			EQU CIACRBF_LOAD|CIACRBF_RUNMODE ; Oneshot mode
ciaa_ta_time			EQU 0
ciaa_tb_time			EQU 0
	IFEQ pt_ciatiming_enabled
ciab_ta_time			EQU 14187 ;= 0.709379 MHz * [20000 �s = 50 Hz duration for one frame on a PAL machine]
;ciab_ta_time			EQU 14318 ;= 0.715909 MHz * [20000 �s = 50 Hz duration for one frame on a NTSC machine]
	ELSE
ciab_ta_time			EQU 0
	ENDC
ciab_tb_time			EQU 362 ;= 0.709379 MHz * [511.43 �s = Lowest note period C1 with Tuning=-8 * 2 / PAL clock constant = 907*2/3546895 ticks per second]
					;= 0.715909 MHz * [506.76 �s = Lowest note period C1 with Tuning=-8 * 2 / NTSC clock constant = 907*2/3579545 ticks per second]
ciaa_ta_continuous_enabled	EQU FALSE
ciaa_tb_continuous_enabled	EQU FALSE
	IFEQ pt_ciatiming_enabled
ciab_ta_continuous_enabled	EQU TRUE
	ELSE
ciab_ta_continuous_enabled	EQU FALSE
	ENDC
ciab_tb_continuous_enabled	EQU FALSE

beam_position			EQU $136

bplcon0_bits			EQU BPLCON0F_ECSENA|((pf_depth>>3)*BPLCON0F_BPU3)|(BPLCON0F_COLOR)|((pf_depth&$07)*BPLCON0F_BPU0)
bplcon3_bits1			EQU 0
bplcon3_bits2			EQU bplcon3_bits1|BPLCON3F_LOCT
bplcon4_bits			EQU 0

cl1_hstart			EQU $00
cl1_vstart			EQU beam_position&$ff

; **** Custom Memory ****
custom_memory_number		EQU 2
part_1_audio_memory_size1	EQU 11324 ; Song
part_1_audio_memory_size2	EQU 285900 ; Samples

; **** PT-Replay ****
pt_fade_out_delay		EQU 3	; Ticks


	INCLUDE "except-vectors-offsets.i"


	INCLUDE "extra-pf-attributes.i"


	INCLUDE "sprite-attributes.i"


	RSRESET

cl1_begin			RS.B 0

	INCLUDE "copperlist1-offsets.i"

cl1_end				RS.L 1

copperlist1_size 		RS.B 0


	RSRESET

cl2_begin			RS.B 0

cl2_end				RS.L 1

copperlist2_size		RS.B 0


; ** Konstanten f�r die gr��e der Copperlisten **
cl1_size1			EQU 0
cl1_size2			EQU 0
cl1_size3			EQU copperlist1_size
cl2_size1			EQU 0
cl2_size2			EQU 0
cl2_size3			EQU copperlist2_size


; ** Konstanten f�r die Gr��e der Spritestrukturen **
spr0_x_size1			EQU spr_x_size1
spr0_y_size1			EQU 0
spr1_x_size1			EQU spr_x_size1
spr1_y_size1			EQU 0
spr2_x_size1			EQU spr_x_size1
spr2_y_size1			EQU 0
spr3_x_size1			EQU spr_x_size1
spr3_y_size1			EQU 0
spr4_x_size1			EQU spr_x_size1
spr4_y_size1			EQU 0
spr5_x_size1			EQU spr_x_size1
spr5_y_size1			EQU 0
spr6_x_size1			EQU spr_x_size1
spr6_y_size1			EQU 0
spr7_x_size1			EQU spr_x_size1
spr7_y_size1			EQU 0

spr0_x_size2			EQU spr_x_size2
spr0_y_size2			EQU 0
spr1_x_size2			EQU spr_x_size2
spr1_y_size2			EQU 0
spr2_x_size2			EQU spr_x_size2
spr2_y_size2			EQU 0
spr3_x_size2			EQU spr_x_size2
spr3_y_size2			EQU 0
spr4_x_size2			EQU spr_x_size2
spr4_y_size2			EQU 0
spr5_x_size2			EQU spr_x_size2
spr5_y_size2			EQU 0
spr6_x_size2			EQU spr_x_size2
spr6_y_size2			EQU 0
spr7_x_size2			EQU spr_x_size2
spr7_y_size2			EQU 0


	RSRESET

	INCLUDE "variables-offsets.i"

; **** PT-Replay ****
	IFD PROTRACKER_VERSION_2.3A 
		INCLUDE "music-tracker/pt2-variables-offsets.i"
	ENDC
	IFD PROTRACKER_VERSION_3.0B
		INCLUDE "music-tracker/pt3-variables-offsets.i"
	ENDC

; **** Main ****
stop_fx_active			RS.W 1

variables_size			RS.B 0


; **** PT-Replay ****
	INCLUDE "music-tracker/pt-song.i"

	INCLUDE "music-tracker/pt-temp-channel.i"


; **** Custom-Memory ****
	RSRESET

custom_memory_entry		RS.B 0
cme_memory_size			RS.L 1
cme_memory_type			RS.L 1
cme_memory_pointer		RS.L 1
custom_memory_entry_size	RS.B 0


start_1_pt_replay

	INCLUDE "sys-wrapper.i"


	CNOP 0,4
init_custom_memory_table
	lea	custom_memory_table(pc),a0
	move.l	#part_1_audio_memory_size1,(a0)+ ; Speichergr��e
	moveq	#CUSTOM_MEMORY_FAST,d2
	move.l	d2,(a0)+		; Speicherart: vorrangig fast-memory
	moveq	#0,d0
	move.l	d0,(a0)+		; Zeiger auf Speicherbereich = Null
	move.l	#part_1_audio_memory_size2,(a0)+ ; Speichergr��e
	moveq	#CUSTOM_MEMORY_CHIP,d2
	move.l	d0,(a0)+		; Speicherart: chip-memory
	move.l	d0,(a0)			; Zeiger auf Speicherbereich = Null
	rts


	CNOP 0,4
init_main_variables

; **** PT-Replay ****
	IFD PROTRACKER_VERSION_2.3A 
		PT2_INIT_VARIABLES
	ENDC
	IFD PROTRACKER_VERSION_3.0B
		PT3_INIT_VARIABLES
	ENDC
	lea	pt_music_fader_active(a3),a0
	lea	global_music_fader_active(pc),a1
	move.l	a0,(a1)
	lea	stop_fx_active(a3),a0
	lea	global_stop_fx_active(pc),a1
	move.l	a0,(a1)

; **** Main ****
	move.w	#FALSE,stop_fx_active(a3)
	rts

	CNOP 0,4
extend_global_references_table
	move.l	global_references_table(a3),a0
	lea	custom_memory_table(pc),a1
	move.l	a1,gr_custom_memory_table(a0)
	rts

	CNOP 0,4
init_main
	bsr.s	pt_DetectSysFrequ
	bsr.s	pt_decrunch_audio_data
	bsr	pt_InitRegisters
	bsr	pt_InitAudTempStrucs
	bsr	pt_ExamineSongStruc
	IFEQ pt_finetune_enabled
		bsr	pt_InitFtuPeriodTableStarts
	ENDC
	bsr	init_colors
	bsr	init_CIA_timers
	bsr	init_first_copperlist
	bra	init_second_copperlist

; **** PT-Replay ****
	PT_DETECT_SYS_FREQUENCY

	CNOP 0,4
pt_decrunch_audio_data
	lea	pt_auddata,a0		; Quelle: gepackte Daten
	lea	custom_memory_table(pc),a2
	move.l	cme_memory_pointer(a2),a1 ; Ziel: entpackte Daten
	move.l	a1,pt_SongDataPointer(a3)
	movem.l a2-a6,-(a7)
	jsr	sc_start
	movem.l (a7)+,a2-a6
	ADDF.W	custom_memory_entry_size,a2 ; n�chster Custom-Memory-Block
	lea	pt_audsmps,a0
	move.l	cme_memory_pointer(a2),a1
	move.l	a1,pt_SamplesDataPointer(a3)
	movem.l a2-a6,-(a7)
	jsr	sc_start
	movem.l (a7)+,a2-a6
	rts

	PT_INIT_REGISTERS

	PT_INIT_AUDIO_TEMP_STRUCTURES

	PT_EXAMINE_SONG_STRUCTURE

	IFEQ pt_finetune_enabled
		PT_INIT_FINETUNE_TABLE_STARTS
	ENDC


	CNOP 0,4
init_colors
	CPU_SELECT_COLOR_HIGH_BANK 0
	CPU_INIT_COLOR_HIGH COLOR00,1,pf1_rgb8_color_table

	CPU_SELECT_COLOR_LOW_BANK 0
	CPU_INIT_COLOR_LOW COLOR00,1,pf1_rgb8_color_table
	rts

	CNOP 0,4
init_CIA_timers

; **** PT-Replay ****
	PT_INIT_TIMERS
	rts


	CNOP 0,4
init_first_copperlist
	move.l	cl1_display(a3),a0
	bsr.s	cl1_init_playfield_props
	COP_LISTEND
	rts

	COP_INIT_PLAYFIELD_REGISTERS cl1,BLANK

	CNOP 0,4
init_second_copperlist
	move.l	cl2_display(a3),a0
	COP_LISTEND
	rts


	CNOP 0,4
alloc_custom_memory
	move.l	global_references_table(a3),a2
	move.l	gr_custom_memory_table(a2),a2 ; Zeiger auf ersten Listeneintrag
	moveq	#custom_memory_number-1,d7
alloc_custom_memory_loop
	move.l	(a2)+,d0		; Gr��e der Speicherbereiches
	CMPF.L	CUSTOM_MEMORY_CHIP,(a2)+ ; Speichersart: Chip-Memory reservieren ?
	bne.s	alloc_custom_memory_skip1
	bsr	do_alloc_chip_memory
	move.l	d0,(a2)+		; Zeiger auf Speicherbereich
	bne.s	alloc_custom_memory_skip2
	bsr.s	alloc_custom_memory_fail
	bra.s	alloc_custom_memory_quit
	CNOP 0,4
alloc_custom_memory_skip1
	bsr	do_alloc_memory
	move.l	d0,(a2)+		; Zeiger auf Speicherbereich
	bne.s	alloc_custom_memory_skip2
	bsr.s	alloc_custom_memory_fail
	bra.s	alloc_custom_memory_quit
	CNOP 0,4
alloc_custom_memory_skip2
	dbf	d7,alloc_custom_memory_loop
	moveq	#RETURN_OK,d0
alloc_custom_memory_quit
	rts
	CNOP 0,4
alloc_custom_memory_fail
        move.w	#CUSTOM_MEMORY_NO_MEMORY,custom_error_code(a3)
	moveq	#RETURN_ERROR,d0
	rts


	CNOP 0,4
main
	jmp	start_10_credits

	IFEQ pt_music_fader_enabled
		CNOP 0,4
pt_mouse_handler
		btst	#POTINPB_DATLY,POTINP-DMACONR(a6) ; Rechte Mustaste gedr�ckt?
		bne.s	pt_mouse_handler_skip
		clr.w	pt_music_fader_active(a3)
pt_mouse_handler_skip
		rts
	ENDC


	CNOP 0,4
free_custom_memory
	move.l	global_references_table(a3),a2
	move.l	gr_custom_memory_table(a2),a2 ; Zeiger auf ersten Listeneintrag
	moveq	#custom_memory_number-1,d7
free_custom_memory_loop
	move.l	(a2),d0			; Gr��e der Speicherbereiches
	addq.w	#QUADWORD_SIZE,a2	; Gr��e + Speicherart �berspringen
	move.l	(a2)+,d1		; Zeiger auf Speicher-Block
	beq.s	free_custom_memory_skip
	move.l	d1,a1			; Zeiger auf Speicher-Block
	CALLEXEC FreeMem
free_custom_memory_skip
	dbf	d7,free_custom_memory_loop
	rts


	INCLUDE "int-autovectors-handlers.i"

	IFEQ pt_ciatiming_enabled
	CNOP 0,4
ciab_ta_int_server
	ENDC

	IFNE pt_ciatiming_enabled
	CNOP 0,4
VERTB_int_server
	ENDC

; **** PT-Replay ****
	IFEQ pt_music_fader_enabled
		bsr.s	pt_music_fader
		bra.s	pt_PlayMusic

		PT_FADE_OUT_VOLUME stop_fx_active

		CNOP 0,4
	ENDC

	IFD PROTRACKER_VERSION_2.3A 
		PT2_REPLAY pt_SetSoftInterrupt
	ENDC

	IFD PROTRACKER_VERSION_3.0B
		PT3_REPLAY pt_SetSoftInterrupt
	ENDC

	CNOP 0,4
pt_SetSoftInterrupt
	move.w	#INTF_SOFTINT+INTF_SETCLR,_CUSTOM+INTREQ
	rts

	CNOP 0,4
ciab_tb_int_server
	PT_TIMER_INTERRUPT_SERVER

	CNOP 0,4
EXTER_int_server
	rts

	CNOP 0,4
NMI_int_server
	rts


	INCLUDE "help-routines.i"


	INCLUDE "sys-structures.i"


	CNOP 0,4
pf1_rgb8_color_table
	DC.L color00_bits

; **** PT-Replay ****
	INCLUDE "music-tracker/pt-invert-table.i"

	INCLUDE "music-tracker/pt-vibrato-tremolo-table.i"

	IFD PROTRACKER_VERSION_2.3A 
		INCLUDE "music-tracker/pt2-period-table.i"
	ENDC

	IFD PROTRACKER_VERSION_3.0B
		INCLUDE "music-tracker/pt3-period-table.i"
	ENDC

	INCLUDE "music-tracker/pt-temp-channel-data-tables.i"

	INCLUDE "music-tracker/pt-sample-starts-table.i"

	INCLUDE "music-tracker/pt-finetune-starts-table.i"

; **** Custom Memory ****
	CNOP 0,4
custom_memory_table
	DS.B custom_memory_entry_size*custom_memory_number


	INCLUDE "sys-variables.i"


	CNOP 0,4
global_music_fader_active 	DC.L 0
global_stop_fx_active		DC.L 0


	INCLUDE "sys-names.i"


	INCLUDE "error-texts.i"


; ## Audiodaten nachladen ##

; **** PT-Replay ****
	IFEQ pt_split_module_enabled
pt_auddata SECTION pt_audio,DATA
		INCBIN "Daten:Asm-Sources.AGA/projects/Superglenz/modules/MOD.Funky Evening.song.stc"
pt_audsmps SECTION pt_audio2,DATA_C
		INCBIN "Daten:Asm-Sources.AGA/projects/Superglenz/modules/MOD.Funky Evening.smps.stc"
	ELSE
pt_auddata SECTION pt_audio,DATA_C
		INCBIN "Daten:Asm-Sources.AGA/projects/Superglenz/modules/MOD.Funky Evening"
	ENDC

	END
