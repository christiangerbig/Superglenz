; Requirements
; 68020+
; AGA PAL
; 3.0+


; History/Changes

; V.1.0 beta
; - 1st release

; V.1.1 beta
; - Intro: Bugfix, Start values of horizontal faders were -1
; - Glenz-Parts 1-3: Bugfix, for 3rd playfield missing 100 lines -> Guru
; - Glenz-Part4: Bugfix, Scroll in without glitches. cpu cleared 8 bytes which were too much
; - Glenz-Part5: Morphing delay 3rd shape shortened
; - Sub-Wrapper: no more a wrapper
; - Bugfix, error handling, exit immediately from any part
; - all modules muted

; V.1.2 beta
; - Bugfix spritefield display bug right border (all sprites x+16)
; - New glenz parts: 48 faces glenz + 128 faces glenz

; V.1.3 beta
; - Bugfix: Intro-Part y wrapping command was not considered -> random memory error
; - All Morphing sequences shortened and changed
; - End-Part: Dual playfield with shadow for font

; V.1.4 beta
; - End-Part: Cross fader for glenz
; - With revised include files (COPCON)

; V.1.5 beta
; - With revised include files
; - 1-Wrapper: Music fader activated, global variables defined
; - Endpart: Magnetic Fox' module included, Vertical-Scroller now triggers music fader.
; - Global FX state of the music fader ends the demo
; - Parts 013/014: Movements changed
; - Bugfix: DIWSTRT/DIWSTOP/DIWHIGH will be pre-initialized, because OS3.x
; LoadView(NULL) sets DIWHIGH = $0000

; V.1.6 beta
; - with Aceman's module "Voyage Fantastique" as a placeholder

; V.1.7 beta
; - with Grass' gfx for the intro part and a reduced size of the glenz

; V.1.8 beta
; - with Grass' background skyline image

; V.1.9 beta
; - credits part: with Grass' font, text changed

; V.2.0 beta
; - main part: bugfix: The 1x glenz vectors were checked for colors 16/08 for
; the backface. Code removed and number of max lines corrected

; V.2.1 beta
; - AceMan's module included
; - fx syncronized with music, morphing now triggered by the 8 command of the module
; - code optimized
; - credits: text changed
; - generally all parts changed to beam position $131

; V2.2 beta
; - Bugfix: noop cl not global anymore, because the 68060 data cache can't
; handle the content of global variables

; V.1.0
; - Sub wrapper: Background fading in & out speeded up
; - Credits part: Text changed
; - Fader enabled
; - Workbench message handler enabled
; - ADF created

; V.1.1
; - new includes used
; - final version
; - credits part: text changed


	MC68040

; Imports
	XREF start_0_pt_replay
	XREF start_1_pt_replay

; Exports
	XDEF color00_bits


	INCDIR "include3.5:"

	INCLUDE "exec/exec.i"
	INCLUDE "exec/exec_lib.i"

	INCLUDE "dos/dos.i"
	INCLUDE "dos/dos_lib.i"
	INCLUDE "dos/dosextens.i"

	INCLUDE "graphics/gfxbase.i"
	INCLUDE "graphics/graphics_lib.i"
	INCLUDE "graphics/videocontrol.i"

	INCLUDE "intuition/intuition.i"
	INCLUDE "intuition/intuition_lib.i"

	INCLUDE "libraries/any_lib.i"

	INCLUDE "resources/cia_lib.i"

	INCLUDE "hardware/adkbits.i"
	INCLUDE "hardware/blit.i"
	INCLUDE "hardware/cia.i"
	INCLUDE "hardware/custom.i"
	INCLUDE "hardware/dmabits.i"
	INCLUDE "hardware/intbits.i"


	INCDIR "custom-includes-aga:"


PASS_GLOBAL_REFERENCES		SET 1
PASS_RETURN_CODE		SET 1
START_SECOND_COPPERLIST		SET 1


	INCLUDE "macros.i"


	INCLUDE "equals.i"

requires_030_cpu		EQU FALSE	
requires_040_cpu		EQU FALSE
requires_060_cpu		EQU FALSE
requires_fast_memory		EQU FALSE
requires_multiscan_monitor	EQU FALSE

workbench_start_enabled		EQU TRUE
screen_fader_enabled		EQU TRUE
text_output_enabled		EQU FALSE

dma_bits			EQU DMAF_COPPER|DMAF_MASTER|DMAF_SETCLR

intena_bits			EQU INTF_INTEN|INTF_SETCLR

ciaa_icr_bits			EQU CIAICRF_SETCLR
ciab_icr_bits			EQU CIAICRF_SETCLR

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

audio_memory_size		EQU 0

disk_memory_size		EQU 0

extra_memory_size		EQU 0

chip_memory_size		EQU 0

ciaa_ta_time			EQU 0
ciaa_tb_time			EQU 0
ciab_ta_time			EQU 0
ciab_tb_time			EQU 0
ciaa_ta_continuous_enabled	EQU FALSE
ciaa_tb_continuous_enabled	EQU FALSE
ciab_ta_continuous_enabled	EQU FALSE
ciab_tb_continuous_enabled	EQU FALSE

beam_position			EQU $131

bplcon0_bits			EQU BPLCON0F_ECSENA|((pf_depth>>3)*BPLCON0F_BPU3)|BPLCON0F_COLOR|((pf_depth&$07)*BPLCON0F_BPU0)
bplcon3_bits1			EQU 0
bplcon3_bits2			EQU bplcon3_bits1|BPLCON3F_LOCT
bplcon4_bits			EQU 0
color00_bits			EQU $23388e

cl1_hstart			EQU 0
cl1_vstart			EQU beam_position&CL_Y_WRAPPING


	INCLUDE "except-vectors.i"


	INCLUDE "extra-pf-attributes.i"


	INCLUDE "sprite-attributes.i"


	RSRESET

cl1_begin			RS.B 0

	INCLUDE "copperlist1.i"

cl1_end				RS.L 1

copperlist1_size		RS.B 0


	RSRESET

cl2_begin			RS.B 0

cl2_end				RS.L 1

copperlist2_size		RS.B 0


cl1_size1			EQU 0
cl1_size2			EQU 0
cl1_size3			EQU copperlist1_size
cl2_size1			EQU 0
cl2_size2			EQU 0
cl2_size3			EQU copperlist2_size


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

	INCLUDE "main-variables.i"

variables_size RS.B 0


	SECTION code,CODE


	INCLUDE "sys-wrapper.i"


	CNOP 0,4
init_main_variables
	rts


	CNOP 0,4
init_main
	bsr.s	init_colors
	bsr	init_first_copperlist
	bsr	init_second_copperlist
	rts


	CNOP 0,4
init_colors
	CPU_SELECT_COLOR_HIGH_BANK 0
	CPU_INIT_COLOR_HIGH COLOR00,1,pf1_rgb8_color_table

	CPU_SELECT_COLOR_LOW_BANK 0
	CPU_INIT_COLOR_LOW COLOR00,1,pf1_rgb8_color_table
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
main
	bsr	start_0_pt_replay
	tst.l	d0			; any error ?
	beq.s	main_skip
	rts
	CNOP 0,4
main_skip
	jmp	start_1_pt_replay


	INCLUDE "int-autovectors-handlers.i"

	CNOP 0,4
nmi_interrupt_server
	rts


	INCLUDE "help-routines.i"


	INCLUDE "sys-structures.i"


	CNOP 0,4
pf1_rgb8_color_table
	DC.L color00_bits


	INCLUDE "sys-variables.i"


	INCLUDE "sys-names.i"


	INCLUDE "error-texts.i"


	DC.B "$VER: "
	DC.B "RSE-Superglenz "
	DC.B "1.1 "
	DC.B "(17.6.25)",0
	EVEN

	END
