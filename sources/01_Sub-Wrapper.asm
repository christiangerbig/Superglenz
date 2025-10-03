; overscan background image in 16 colors with attached sprites
; 1st copperlist calls 2nd copperlist


	MC68040


	XDEF v_bplcon0_bits
	XDEF v_bplcon3_bits1
	XDEF v_bplcon3_bits2
	XDEF v_bplcon4_bits
	XDEF v_fmode_bits
	XDEF start_01_sub_wrappingper

	XREF color00_bits
	XREF start_010_morph_glenz_vectors
	XREF start_011_morph_glenz_vectors
	XREF start_012_morph_glenz_vectors
	XREF start_013_morph_glenz_vectors
	XREF start_014_morph_glenz_vectors
	XREF start_015_morph_2xglenz_vectors
	XREF start_016_morph_3xglenz_vectors
	XREF mouse_handler
	XREF sine_table


	INCDIR "include3.5:"

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


	INCDIR "custom-includes-aga:"


SYS_TAKEN_OVER			SET 1
PASS_GLOBAL_REFERENCES		SET 1
PASS_RETURN_CODE		SET 1
SET_SECOND_COPPERLIST		SET 1


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

dma_bits			EQU DMAF_SPRITE|DMAF_COPPER|DMAF_SETCLR

intena_bits			EQU INTF_SETCLR

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

spr_number			EQU 8
spr_x_size1			EQU 0
spr_x_size2			EQU 64
spr_depth			EQU 2
spr_colors_number		EQU 16
spr_odd_color_table_select	EQU 8
spr_even_color_table_select	EQU 8
spr_used_number			EQU 8

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

MINROW				EQU VSTART_OVERSCAN_PAL

spr_pixel_per_datafetch		EQU 64	; 4x

bplcon0_bits			EQU BPLCON0F_ECSENA|((pf_depth>>3)*BPLCON0F_BPU3)|BPLCON0F_COLOR|((pf_depth&$07)*BPLCON0F_BPU0)
bplcon3_bits1			EQU BPLCON3F_BRDSPRT|BPLCON3F_SPRES0
bplcon3_bits2			EQU bplcon3_bits1|BPLCON3F_LOCT
bplcon4_bits			EQU (BPLCON4F_OSPRM4*spr_odd_color_table_select)|(BPLCON4F_ESPRM4*spr_even_color_table_select)
fmode_bits			EQU FMODEF_SPR32|FMODEF_SPAGEM|FMODEF_SSCAN2

v_bplcon0_bits			EQU bplcon0_bits
v_bplcon3_bits1			EQU bplcon3_bits1
v_bplcon3_bits2			EQU bplcon3_bits2
v_bplcon4_bits			EQU bplcon4_bits
v_fmode_bits			EQU fmode_bits

cl2_hstart			EQU 0
cl2_vstart			EQU beam_position&CL_Y_WRAPPING

sine_table_length		EQU 512

; Background-Image
bg_image_x_size			EQU 256
bg_image_plane_width		EQU bg_image_x_size/8
bg_image_y_size			EQU 283
bg_image_depth			EQU 4
bg_image_x_position		EQU 18
bg_image_y_position		EQU MINROW

; Sprite-Fader
sprf_rgb8_start_color		EQU 1
sprf_rgb8_color_table_offset	EQU 1
sprf_rgb8_colors_number		EQU spr_colors_number-1

; Sprite-Fader-In
sprfi_rgb8_fader_speed_max	EQU 48
sprfi_rgb8_fader_radius		EQU sprfi_rgb8_fader_speed_max
sprfi_rgb8_fader_center		EQU sprfi_rgb8_fader_speed_max+1
sprfi_rgb8_fader_angle_speed	EQU 2

; Sprite-Fader-Out
sprfo_rgb8_fader_speed_max	EQU 16
sprfo_rgb8_fader_radius		EQU sprfo_rgb8_fader_speed_max
sprfo_rgb8_fader_center		EQU sprfo_rgb8_fader_speed_max+1
sprfo_rgb8_fader_angle_speed	EQU 2


	INCLUDE "except-vectors.i"


	INCLUDE "extra-pf-attributes.i"


	INCLUDE "sprite-attributes.i"


	RSRESET

cl1_begin			RS.B 0

	INCLUDE "copperlist1.i"

cl1_COPJMP2			RS.L 1

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


; Sprite0 additional structure
	RSRESET

spr0_extension1	RS.B 0

spr0_ext1_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr0_ext1_planedata		RS.L (spr_pixel_per_datafetch/WORD_BITS)*bg_image_y_size

spr0_extension1_size		RS.B 0

; Sprite0 main structure
	RSRESET

spr0_begin			RS.B 0

spr0_extension1_entry		RS.B spr0_extension1_size

spr0_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite0_size			RS.B 0

; Sprite1 additional structure
	RSRESET

spr1_extension1	RS.B 0

spr1_ext1_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr1_ext1_planedata		RS.L (spr_pixel_per_datafetch/WORD_BITS)*bg_image_y_size

spr1_extension1_size		RS.B 0

; Sprite1 main structure
	RSRESET

spr1_begin			RS.B 0

spr1_extension1_entry		RS.B spr1_extension1_size

spr1_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite1_size			RS.B 0

; Sprite2 additional structure
	RSRESET

spr2_extension1			RS.B 0

spr2_ext1_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr2_ext1_planedata		RS.L (spr_pixel_per_datafetch/WORD_BITS)*bg_image_y_size

spr2_extension1_size		RS.B 0

; Sprite2 main structure
	RSRESET

spr2_begin			RS.B 0

spr2_extension1_entry		RS.B spr2_extension1_size

spr2_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite2_size			RS.B 0

; Sprite3 additional structure
	RSRESET

spr3_extension1	RS.B 0

spr3_ext1_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr3_ext1_planedata		RS.L (spr_pixel_per_datafetch/WORD_BITS)*bg_image_y_size

spr3_extension1_size		RS.B 0

; Sprite3 main structure
	RSRESET

spr3_begin			RS.B 0

spr3_extension1_entry		RS.B spr3_extension1_size

spr3_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite3_size			RS.B 0

; Sprite4 additional structure
	RSRESET

spr4_extension1	RS.B 0

spr4_ext1_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr4_ext1_planedata		RS.L (spr_pixel_per_datafetch/WORD_BITS)*bg_image_y_size

spr4_extension1_size		RS.B 0

; Sprite4 main structure
	RSRESET

spr4_begin			RS.B 0

spr4_extension1_entry		RS.B spr4_extension1_size

spr4_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite4_size			RS.B 0

; Sprite5 additional structure
	RSRESET

spr5_extension1			RS.B 0

spr5_ext1_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr5_ext1_planedata		RS.L (spr_pixel_per_datafetch/WORD_BITS)*bg_image_y_size

spr5_extension1_size		RS.B 0

; Sprite5 main structure
	RSRESET

spr5_begin			RS.B 0

spr5_extension1_entry		RS.B spr5_extension1_size

spr5_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite5_size			RS.B 0

; Sprite6 additional structure
	RSRESET

spr6_extension1			RS.B 0

spr6_ext1_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr6_ext1_planedata		RS.L (spr_pixel_per_datafetch/WORD_BITS)*bg_image_y_size

spr6_extension1_size		RS.B 0

; Sprite6 main structure
	RSRESET

spr6_begin			RS.B 0

spr6_extension1_entry		RS.B spr6_extension1_size

spr6_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite6_size			RS.B 0

; Sprite7 additional structure
	RSRESET

spr7_extension1	RS.B 0

spr7_ext1_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr7_ext1_planedata		RS.L (spr_pixel_per_datafetch/WORD_BITS)*bg_image_y_size

spr7_extension1_size		RS.B 0

; Sprite7 main structure
	RSRESET

spr7_begin			RS.B 0

spr7_extension1_entry		RS.B spr7_extension1_size

spr7_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite7_size			RS.B 0


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
spr0_y_size2			EQU sprite0_size/(spr_x_size2/4)
spr1_x_size2			EQU spr_x_size2
spr1_y_size2			EQU sprite1_size/(spr_x_size2/4)
spr2_x_size2			EQU spr_x_size2
spr2_y_size2			EQU sprite2_size/(spr_x_size2/4)
spr3_x_size2			EQU spr_x_size2
spr3_y_size2			EQU sprite3_size/(spr_x_size2/4)
spr4_x_size2			EQU spr_x_size2
spr4_y_size2			EQU sprite4_size/(spr_x_size2/4)
spr5_x_size2			EQU spr_x_size2
spr5_y_size2			EQU sprite5_size/(spr_x_size2/4)
spr6_x_size2			EQU spr_x_size2
spr6_y_size2			EQU sprite6_size/(spr_x_size2/4)
spr7_x_size2			EQU spr_x_size2
spr7_y_size2			EQU sprite7_size/(spr_x_size2/4)


	RSRESET

	INCLUDE "main-variables.i"

; Sprite-Fader
sprf_rgb8_colors_counter	RS.W 1
sprf_rgb8_copy_colors_active	RS.W 1

; Sprite-Fader-In
sprfi_rgb8_active		RS.W 1
sprfi_rgb8_fader_angle		RS.W 1

; Sprite-Fader-Out
sprfo_rgb8_active		RS.W 1
sprfo_rgb8_fader_angle		RS.W 1

; Main
	RS_ALIGN_LONGWORD
cl_end				RS.L 1

variables_size			RS.B 0


	SECTION code,CODE


start_01_sub_wrappingper


	INCLUDE "sys-wrapper.i"


	CNOP 0,4
init_main_variables

; Sprite-Fader
	move.w	#sprf_rgb8_colors_number*3,sprf_rgb8_colors_counter(a3)
	moveq	#TRUE,d0
	move.w	d0,sprf_rgb8_copy_colors_active(a3)

; Sprite-Fader-In
	move.w	d0,sprfi_rgb8_active(a3)
	move.w	#sine_table_length/4,sprfi_rgb8_fader_angle(a3) ; 90°

; Sprite-Fader-Out
	move.w	#FALSE,sprfo_rgb8_active(a3)
	move.w	#sine_table_length/4,sprfo_rgb8_fader_angle(a3) ; 90°
	rts

	CNOP 0,4
init_main
	bsr.s	init_sprites
	bsr	init_first_copperlist
	bra	init_second_copperlist


	CNOP 0,4
init_sprites
	bsr.s	spr_init_pointers_table
	bra.s	bg_init_attached_sprites_cluster


	INIT_SPRITE_POINTERS_TABLE


	INIT_ATTACHED_SPRITES_CLUSTER bg,spr_pointers_display,bg_image_x_position,bg_image_y_position,spr_x_size2,bg_image_y_size,,,REPEAT


	CNOP 0,4
init_first_copperlist
	move.l	cl1_display(a3),a0
	bsr.s	cl1_init_playfield_props
	bsr.s	cl1_init_sprite_pointers
	bsr	cl1_init_colors
	COP_MOVEQ 0,COPJMP2
	bra	cl1_set_sprite_pointers

	COP_INIT_PLAYFIELD_REGISTERS cl1,BLANKSPR

	COP_INIT_SPRITE_POINTERS cl1


	CNOP 0,4
cl1_init_colors
	COP_SELECT_COLOR_HIGH_BANK 4
	COP_INIT_COLOR_HIGH COLOR00,16,spr_rgb8_color_table

	COP_SELECT_COLOR_LOW_BANK 4
	COP_INIT_COLOR_LOW COLOR00,16,spr_rgb8_color_table
	rts

	COP_SET_SPRITE_POINTERS cl1,display,spr_number


	CNOP 0,4
init_second_copperlist
	move.l	cl2_display(a3),a0
	COP_LISTEND SAVETAIL
	rts


	CNOP 0,4
main
	move.l	a0,-(a7)
	bsr	beam_routines
	move.l	(a7)+,a0
	tst.l	d0
	bne	exit

	movem.l a0/a3-a6,-(a7)
	bsr	start_010_morph_glenz_vectors
	movem.l (a7)+,a0/a3-a6
	tst.l	d0
	bne	exit

	movem.l a0/a3-a6,-(a7)
	bsr	start_011_morph_glenz_vectors
	movem.l (a7)+,a0/a3-a6
	tst.l	d0
	bne	exit

	movem.l a0/a3-a6,-(a7)
	bsr	start_012_morph_glenz_vectors
	movem.l (a7)+,a0/a3-a6
	tst.l	d0
	bne.s	exit

	movem.l a0/a3-a6,-(a7)
	bsr	start_013_morph_glenz_vectors
	movem.l (a7)+,a0/a3-a6
	tst.l	d0
	bne.s	exit

	movem.l a0/a3-a6,-(a7)
	bsr	start_014_morph_glenz_vectors
	movem.l (a7)+,a0/a3-a6
	tst.l	d0
	bne.s	exit

	movem.l a0/a3-a6,-(a7)
	bsr	start_015_morph_2xglenz_vectors
	movem.l (a7)+,a0/a3-a6
	tst.l	d0
	bne.s	exit

	movem.l a0/a3-a6,-(a7)
	jsr	start_016_morph_3xglenz_vectors
	movem.l (a7)+,a0/a3-a6
	tst.l	d0
	bne.s	exit

	move.w	#sprf_rgb8_colors_number*3,sprf_rgb8_colors_counter(a3)
	clr.w	sprf_rgb8_copy_colors_active(a3)
	clr.w	sprfo_rgb8_active(a3)
	bsr.s	beam_routines
	rts


	CNOP 0,4
beam_routines
	bsr	wait_beam_position
	bsr	sprite_fader_in
	bsr	sprite_fader_out
	bsr	sprf_rgb8_copy_color_table
	bsr	mouse_handler
	tst.l	d0			; exit ?
	bne.s	fast_exit
	tst.w	sprfi_rgb8_active(a3)
	beq.s	beam_routines
	tst.w	sprfo_rgb8_active(a3)
	beq.s	beam_routines
fast_exit
	move.w	custom_error_code(a3),d1
exit
	move.l	cl_end(a3),COP2LC-DMACONR(a6)
	move.w	d0,COPJMP2-DMACONR(a6)
	rts


	CNOP 0,4
sprite_fader_in
	movem.l a4-a6,-(a7)
	tst.w	sprfi_rgb8_active(a3)
	bne.s	sprite_fader_in_quit
	move.w	sprfi_rgb8_fader_angle(a3),d2
	move.w	d2,d0
	ADDF.W	sprfi_rgb8_fader_angle_speed,d0
	cmp.w	#sine_table_length/2,d0 ; <= 180° ?
	ble.s   sprite_fader_in_skip
	MOVEF.W sine_table_length/2,d0
sprite_fader_in_skip
	move.w	d0,sprfi_rgb8_fader_angle(a3) 
	MOVEF.W sprf_rgb8_colors_number*3,d6 ; RGB counter
	lea	sine_table(pc),a0	
	move.w	(a0,d2.w*2),d0		; sin(w)
	MULSF.W sprfi_rgb8_fader_radius*2,d0,d1 ; y'=(yr*sin(w))/2^15
	swap	d0
	ADDF.W	sprfi_rgb8_fader_center,d0
	lea	spr_rgb8_color_table+(sprf_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a0 ; colors buffer
	lea	sprfi_rgb8_color_table+(sprf_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a1 ; destination values
	move.w	d0,a5			; decrease/increase blue
	swap	d0
	clr.w	d0
	move.l	d0,a2			; decrease/increase red
	lsr.l	#8,d0
	move.l	d0,a4			; decrease/increase green
	MOVEF.W sprf_rgb8_colors_number-1,d7
	bsr	sprf_rgb8_fader_loop
	move.w	d6,sprf_rgb8_colors_counter(a3) ; fading-in finished ?
	bne.s	sprite_fader_in_quit
	move.w	#FALSE,sprfi_rgb8_active(a3)
sprite_fader_in_quit
	movem.l (a7)+,a4-a6
	rts


	CNOP 0,4
sprite_fader_out
	movem.l a4-a6,-(a7)
	tst.w	sprfo_rgb8_active(a3)
	bne.s	sprite_fader_out_quit
	move.w	sprfo_rgb8_fader_angle(a3),d2
	move.w	d2,d0
	ADDF.W	sprfo_rgb8_fader_angle_speed,d0
	cmp.w	#sine_table_length/2,d0 ; <= 180° ?
	ble.s	sprite_fader_out_skip
	MOVEF.W sine_table_length/2,d0
sprite_fader_out_skip
	move.w	d0,sprfo_rgb8_fader_angle(a3) 
	MOVEF.W sprf_rgb8_colors_number*3,d6 ; RGB counter
	lea	sine_table(pc),a0	
	move.w	(a0,d2.w*2),d0		; sin(w)
	MULSF.W sprfo_rgb8_fader_radius*2,d0,d1 ; y'=(yr*sin(w))/2^15
	swap	d0
	ADDF.W	sprfo_rgb8_fader_center,d0
	lea	spr_rgb8_color_table+(sprf_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a0 ; colors buffer
	lea	sprfo_rgb8_color_table+(sprf_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a1 ; destination values
	move.w	d0,a5			; decrease/increase blue
	swap	d0
	clr.w	d0
	move.l	d0,a2			; decrease/increase red
	lsr.l	#8,d0
	move.l	d0,a4			; decrease/increase green
	MOVEF.W sprf_rgb8_colors_number-1,d7
	bsr	sprf_rgb8_fader_loop
	move.w	d6,sprf_rgb8_colors_counter(a3) ; fading-in finished ?
	bne.s	sprite_fader_out_quit
	move.w	#FALSE,sprfo_rgb8_active(a3)
sprite_fader_out_quit
	movem.l (a7)+,a4-a6
	rts


	RGB8_COLOR_FADER sprf


	COPY_RGB8_COLORS_TO_COPPERLIST sprf,spr,cl1,cl1_COLOR00_high5,cl1_COLOR00_low5


	INCLUDE "int-autovectors-handlers.i"

	CNOP 0,4
nmi_server
	rts


	INCLUDE "help-routines.i"


	INCLUDE "sys-structures.i"


	CNOP 0,4
spr_rgb8_color_table
	REPT spr_colors_number
		DC.L color00_bits
	ENDR


	CNOP 0,4
spr_pointers_display
	DS.L spr_number


; Sprite-Fader
	CNOP 0,4
sprfi_rgb8_color_table
	INCLUDE "Superglenz:colortables/256x283x16-Skyline.ct"

	CNOP 0,4
sprfo_rgb8_color_table
	REPT spr_colors_number
		DC.L color00_bits
	ENDR


	INCLUDE "sys-variables.i"


	INCLUDE "sys-names.i"


	INCLUDE "error-texts.i"


; Gfx data

; Background-Image
bg_image_data			SECTION gfx1,DATA
	INCBIN "Superglenz:graphics/256x283x16-Skyline.rawblit"

	END
