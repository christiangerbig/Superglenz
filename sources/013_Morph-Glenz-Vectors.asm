; Morphing 1x48 faces glenz on a 240x240 screen
; Copper waits for the blitter
; Beam position timing
; 64kB aligned playfield


	MC68040


	XDEF start_013_morph_glenz_vectors

	XREF v_bplcon0_bits
	XREF v_bplcon3_bits1
	XREF v_bplcon3_bits2
	XREF v_bplcon4_bits
	XREF v_fmode_bits
	XREF color00_bits
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


SYS_TAKEN_OVER			SET 1
PASS_GLOBAL_REFERENCES		SET 1
PASS_RETURN_CODE		SET 1


	INCDIR "custom-includes-aga:"


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

; Morph-Glenz-Vectors
mgv_count_lines_enabled		EQU FALSE

mgv_premorph_enabled		EQU TRUE

dma_bits			EQU DMAF_BLITTER|DMAF_RASTER|DMAF_BLITHOG|DMAF_SETCLR

intena_bits			EQU INTF_SETCLR

ciaa_icr_bits			EQU CIAICRF_SETCLR
ciab_icr_bits			EQU CIAICRF_SETCLR

copcon_bits			EQU COPCONF_CDANG

pf1_x_size1			EQU 256
pf1_y_size1			EQU 240+683
pf1_depth1			EQU 3
pf1_x_size2			EQU 256
pf1_y_size2			EQU 240+683
pf1_depth2			EQU 3
pf1_x_size3			EQU 256
pf1_y_size3			EQU 240+683
pf1_depth3			EQU 3
pf1_colors_number		EQU 8

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
spr_x_size2			EQU 0
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

pixel_per_line			EQU 256
visible_pixels_number		EQU 240
visible_lines_number		EQU 240
MINROW				EQU VSTOP_OVERSCAN_PAL

pf_pixel_per_datafetch		EQU 64	; 4x

display_window_hstart		EQU HSTART_240_PIXEL
display_window_vstart		EQU MINROW
display_window_hstop		EQU HSTOP_240_pixel
display_window_vstop		EQU VSTOP_OVERSCAN_PAL

pf1_plane_width			EQU pf1_x_size3/8
data_fetch_width		EQU pixel_per_line/8
pf1_plane_moduli		EQU (pf1_plane_width*(pf1_depth3-1))+pf1_plane_width-data_fetch_width

diwstrt_bits			EQU ((display_window_vstart&$ff)*DIWSTRTF_V0)|(display_window_hstart&$ff)
diwstop_bits			EQU ((display_window_vstop&$ff)*DIWSTOPF_V0)|(display_window_hstop&$ff)
ddfstrt_bits			EQU DDFSTART_320_PIXEL
ddfstop_bits			EQU DDFSTOP_256_PIXEL_LALGN_4X
bplcon0_bits			EQU BPLCON0F_ECSENA|((pf_depth>>3)*BPLCON0F_BPU3)|(BPLCON0F_COLOR)|((pf_depth&$07)*BPLCON0F_BPU0)
bplcon1_bits			EQU $8888
bplcon2_bits			EQU 0
bplcon3_bits1			EQU 0
bplcon3_bits2			EQU bplcon3_bits1|BPLCON3F_LOCT
bplcon4_bits			EQU 0
diwhigh_bits			EQU (((display_window_hstop&$100)>>8)*DIWHIGHF_HSTOP8)|(((display_window_vstop&$700)>>8)*DIWHIGHF_VSTOP8)|(((display_window_hstart&$100)>>8)*DIWHIGHF_HSTART8)|((display_window_vstart&$700)>>8)
fmode_bits			EQU FMODEF_BPL32|FMODEF_BPAGEM

cl2_hstart			EQU 0
cl2_vstart			EQU beam_position&CL_Y_WRAPPING

sine_table_length		EQU 512

; Morph-Glenz-Vectors
mgv_distance			EQU 512
mgv_xy_center			EQU visible_lines_number/2

mgv_x_anglespeed_radius		EQU 4
mgv_x_anglespeed_center		EQU 1
mgv_x_anglespeed_speed		EQU -4

mgv_y_anglespeed_radius		EQU 2
mgv_y_anglespeed_center		EQU 2
mgv_y_anglespeed_speed		EQU -3

mgv_z_anglespeed_radius		EQU 2
mgv_z_anglespeed_center		EQU 1
mgv_z_anglespeed_speed		EQU -1

mgv_object_edge_points_number	EQU 26
mgv_object_edge_points_per_face	EQU 3
mgv_object_faces_number		EQU 48

mgv_object_face1_color		EQU 2
mgv_object_face1_lines_number	EQU 3
mgv_object_face2_color		EQU 4
mgv_object_face2_lines_number	EQU 3
mgv_object_face3_color		EQU 2
mgv_object_face3_lines_number	EQU 3
mgv_object_face4_color		EQU 4
mgv_object_face4_lines_number	EQU 3
mgv_object_face5_color		EQU 2
mgv_object_face5_lines_number	EQU 3
mgv_object_face6_color		EQU 4
mgv_object_face6_lines_number	EQU 3
mgv_object_face7_color		EQU 2
mgv_object_face7_lines_number	EQU 3
mgv_object_face8_color		EQU 4
mgv_object_face8_lines_number	EQU 3

mgv_object_face9_color		EQU 4
mgv_object_face9_lines_number	EQU 3
mgv_object_face10_color		EQU 2
mgv_object_face10_lines_number	EQU 3
mgv_object_face11_color		EQU 4
mgv_object_face11_lines_number	EQU 3
mgv_object_face12_color		EQU 2
mgv_object_face12_lines_number	EQU 3

mgv_object_face13_color		EQU 2
mgv_object_face13_lines_number	EQU 3
mgv_object_face14_color		EQU 4
mgv_object_face14_lines_number	EQU 3
mgv_object_face15_color		EQU 2
mgv_object_face15_lines_number	EQU 3
mgv_object_face16_color		EQU 4
mgv_object_face16_lines_number	EQU 3

mgv_object_face17_color		EQU 4
mgv_object_face17_lines_number	EQU 3
mgv_object_face18_color		EQU 2
mgv_object_face18_lines_number	EQU 3
mgv_object_face19_color		EQU 4
mgv_object_face19_lines_number	EQU 3
mgv_object_face20_color		EQU 2
mgv_object_face20_lines_number	EQU 3

mgv_object_face21_color		EQU 2
mgv_object_face21_lines_number	EQU 3
mgv_object_face22_color		EQU 4
mgv_object_face22_lines_number	EQU 3
mgv_object_face23_color		EQU 2
mgv_object_face23_lines_number	EQU 3
mgv_object_face24_color		EQU 4
mgv_object_face24_lines_number	EQU 3

mgv_object_face25_color		EQU 4
mgv_object_face25_lines_number	EQU 3
mgv_object_face26_color		EQU 2
mgv_object_face26_lines_number	EQU 3
mgv_object_face27_color		EQU 4
mgv_object_face27_lines_number	EQU 3
mgv_object_face28_color		EQU 2
mgv_object_face28_lines_number	EQU 3

mgv_object_face29_color		EQU 2
mgv_object_face29_lines_number	EQU 3
mgv_object_face30_color		EQU 4
mgv_object_face30_lines_number	EQU 3
mgv_object_face31_color		EQU 2
mgv_object_face31_lines_number	EQU 3
mgv_object_face32_color		EQU 4
mgv_object_face32_lines_number	EQU 3

mgv_object_face33_color		EQU 4
mgv_object_face33_lines_number	EQU 3
mgv_object_face34_color		EQU 2
mgv_object_face34_lines_number	EQU 3
mgv_object_face35_color		EQU 4
mgv_object_face35_lines_number	EQU 3
mgv_object_face36_color		EQU 2
mgv_object_face36_lines_number	EQU 3

mgv_object_face37_color		EQU 2
mgv_object_face37_lines_number	EQU 3
mgv_object_face38_color		EQU 4
mgv_object_face38_lines_number	EQU 3
mgv_object_face39_color		EQU 2
mgv_object_face39_lines_number	EQU 3
mgv_object_face40_color		EQU 4
mgv_object_face40_lines_number	EQU 3

mgv_object_face41_color		EQU 2
mgv_object_face41_lines_number	EQU 3
mgv_object_face42_color		EQU 4
mgv_object_face42_lines_number	EQU 3
mgv_object_face43_color		EQU 2
mgv_object_face43_lines_number	EQU 3
mgv_object_face44_color		EQU 4
mgv_object_face44_lines_number	EQU 3
mgv_object_face45_color		EQU 2
mgv_object_face45_lines_number	EQU 3
mgv_object_face46_color		EQU 4
mgv_object_face46_lines_number	EQU 3
mgv_object_face47_color		EQU 2
mgv_object_face47_lines_number	EQU 3
mgv_object_face48_color		EQU 4
mgv_object_face48_lines_number	EQU 3

mgv_lines_number_max		EQU 132
mgv_glenz_colors_number		EQU 4

mgv_morph_shapes_number		EQU 4
mgv_morph_speed			EQU 8

; Fill-Blit
mgv_fill_blit_x_size		EQU visible_pixels_number
mgv_fill_blit_y_size		EQU visible_lines_number
mgv_fill_blit_depth		EQU pf1_depth3

; Scroll-Playfield-Bottom
spb_min_vstart			EQU VSTART_240_LINES
spb_max_vstop			EQU VSTOP_OVERSCAN_PAL
spb_y_radius			EQU spb_max_vstop-spb_min_vstart
spb_y_centre			EQU spb_max_vstop-spb_min_vstart

; Scroll-Playfield-Bottom-In
spbi_y_angle_speed		EQU 5

; Scroll-Playfield-Bottom-Out
spbo_y_angle_speed		EQU 4

; Effects-Handler
eh_trigger_number_max		EQU 4


	INCLUDE "except-vectors.i"


	INCLUDE "extra-pf-attributes.i"


	INCLUDE "sprite-attributes.i"


; Morph-Glenz-Vectors
	RSRESET

object_info			RS.B 0

object_info_edges		RS.L 1
object_info_face_color		RS.W 1
object_info_lines_number	RS.W 1

object_info_size		RS.B 0

	RSRESET

morph_shape			RS.B 0

morph_shape_object_edges	RS.L 1

morph_shape_size		RS.B 0


	RSRESET

cl2_extension1			RS.B 0

cl2_ext1_WAITBLIT		RS.L 1
cl2_ext1_BLTAFWM		RS.L 1
cl2_ext1_BLTALWM		RS.L 1
cl2_ext1_BLTCPTH		RS.L 1
cl2_ext1_BLTDPTH		RS.L 1
cl2_ext1_BLTCMOD		RS.L 1
cl2_ext1_BLTDMOD		RS.L 1
cl2_ext1_BLTBDAT		RS.L 1
cl2_ext1_BLTADAT		RS.L 1
cl2_ext1_COP2LCH		RS.L 1
cl2_ext1_COP2LCL		RS.L 1
cl2_ext1_COPJMP2		RS.L 1

cl2_extension1_size		RS.B 0


	RSRESET

cl2_extension2			RS.B 0

cl2_ext2_BLTCON0		RS.L 1
cl2_ext2_BLTCON1		RS.L 1
cl2_ext2_BLTCPTL		RS.L 1
cl2_ext2_BLTAPTL		RS.L 1
cl2_ext2_BLTDPTL		RS.L 1
cl2_ext2_BLTBMOD		RS.L 1
cl2_ext2_BLTAMOD		RS.L 1
cl2_ext2_BLTSIZE		RS.L 1
cl2_ext2_WAITBLIT		RS.L 1

cl2_extension2_size		RS.B 0


	RSRESET

cl2_extension3			RS.B 0

cl2_ext3_BLTCON0		RS.L 1
cl2_ext3_BLTCON1		RS.L 1
cl2_ext3_BLTAPTH		RS.L 1
cl2_ext3_BLTAPTL		RS.L 1
cl2_ext3_BLTDPTH		RS.L 1
cl2_ext3_BLTDPTL		RS.L 1
cl2_ext3_BLTAMOD		RS.L 1
cl2_ext3_BLTDMOD		RS.L 1
cl2_ext3_BLTSIZE		RS.L 1

cl2_extension3_size		RS.B 0


	RSRESET

cl2_begin			RS.B 0

	INCLUDE "copperlist2.i"

cl2_extension1_entry		RS.B cl2_extension1_size
cl2_extension2_entry		RS.B cl2_extension2_size*mgv_lines_number_max
cl2_extension3_entry		RS.B cl2_extension3_size

cl2_end				RS.L 1

copperlist2_size		RS.B 0


cl1_size1			EQU 0
cl1_size2			EQU 0
cl1_size3			EQU 0
cl2_size1			EQU 0
cl2_size2			EQU copperlist2_size
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

save_a7				RS.L 1

; Morph-Glenz-Vectors
mgv_x_angle			RS.W 1
mgv_y_angle			RS.W 1
mgv_z_angle			RS.W 1

mgv_variable_x_speed		RS.W 1
mgv_x_anglespeed_angle		RS.W 1
mgv_variable_y_speed		RS.W 1
mgv_y_anglespeed_angle		RS.W 1
mgv_variable_z_speed		RS.W 1
mgv_z_anglespeed_angle		RS.W 1

mgv_lines_counter		RS.W 1

mgv_morph_active		RS.W 1
mgv_morph_shapes_start		RS.W 1

; Scroll-Playfield-Bottom-In
spbi_active			RS.W 1
spbi_y_angle			RS.W 1

; Scroll-Playfield-Bottom-Out
spbo_active			RS.W 1
spbo_y_angle			RS.W 1

; Effects-Handler
eh_trigger_number		RS.W 1

; Main
	RS_ALIGN_LONGWORD
cl_end				RS.L 1
stop_fx_active			RS.W 1

variables_size			RS.B 0


	SECTION code,CODE


start_013_morph_glenz_vectors


	INCLUDE "sys-wrapper.i"


	CNOP 0,4
init_main_variables

; Morphing-Glenz-Vectors
	moveq	#TRUE,d0
	move.w	d0,mgv_x_angle(a3)
	move.w	d0,mgv_y_angle(a3)
	move.w	d0,mgv_z_angle(a3)

	move.w	d0,mgv_variable_x_speed(a3)
	move.w	d0,mgv_x_anglespeed_angle(a3)
	move.w	d0,mgv_variable_y_speed(a3)
	move.w	d0,mgv_y_anglespeed_angle(a3)
	move.w	d0,mgv_variable_z_speed(a3)
	move.w	d0,mgv_z_anglespeed_angle(a3)

	move.w	d0,mgv_lines_counter(a3)

	moveq	#FALSE,d1
	IFEQ mgv_premorph_enabled
		move.w	d0,mgv_morph_active(a3)
	ELSE
		move.w	d1,mgv_morph_active(a3)
	ENDC
	move.w	d0,mgv_morph_shapes_start(a3)

; Scroll-Playfield-Bottom-In
	move.w	d0,spbi_active(a3)
	move.w	d0,spbi_y_angle(a3)	; 0°

; Scroll-Playfield-Bottom-Out
	move.w	d1,spbo_active(a3)
	move.w	#sine_table_length/4,spbo_y_angle(a3) ; 90°

; Effects-Handler
	move.w	d0,eh_trigger_number(a3)

; Main
	move.w	d1,stop_fx_active(a3)
	rts


	CNOP 0,4
init_main
	bsr.s	mgv_init_object_info
	bsr.s	mgv_init_morph_shapes
	IFEQ mgv_premorph_enabled
		bsr.s	mgv_init_start_shape
	ENDC
	bsr.s	mgv_init_color_table
	bsr	spb_init_display_window
	bra	init_second_copperlist


; Morph-Glenz-Vectors
	CNOP 0,4
mgv_init_object_info
	lea	mgv_object_info+object_info_edges(pc),a0
	lea	mgv_object_edges(pc),a1
	move.w	#object_info_size,a2
	MOVEF.W mgv_object_faces_number-1,d7
mgv_init_object_info_loop
	move.w	object_info_lines_number(a0),d0
	addq.w	#1+1,d0			; number of edge points
	move.l	a1,(a0)			; edge table
	lea	(a1,d0.w*2),a1		; next edge table
	add.l	a2,a0			; next object info structure
	dbf	d7,mgv_init_object_info_loop
	rts

	CNOP 0,4
mgv_init_morph_shapes
	lea	mgv_morph_shapes_table(pc),a0
	lea	mgv_object_shape1_coordinates(pc),a1
	move.l	a1,(a0)+		; shape table
	lea	mgv_object_shape2_coordinates(pc),a1
	move.l	a1,(a0)+		; shape table
	lea	mgv_object_shape3_coordinates(pc),a1
	move.l	a1,(a0)			; shape table
	rts

	IFEQ mgv_premorph_enabled
		CNOP 0,4
mgv_init_start_shape
		bsr	mgv_morph_object
		tst.w	mgv_morph_active(a3) ; morphing finished ?
		beq.s	mgv_init_start_shape
		rts
	ENDC

	CNOP 0,4
mgv_init_color_table
	lea	pf1_rgb8_color_table(pc),a0
	lea	mgv_rgb8_color_table(pc),a1
	move.l	(a1)+,QUADWORD_SIZE(a0) ; COLOR02
	move.l	(a1)+,3*LONGWORD_SIZE(a0) ; COLOR03
	move.l	(a1)+,4*LONGWORD_SIZE(a0) ; COLOR04
	move.l	(a1),5*LONGWORD_SIZE(a0) ; COLOR05
	rts


	CNOP 0,4
spb_init_display_window
	move.w	#diwstrt_bits,DIWSTRT-DMACONR(a6)
	move.w	#diwstop_bits,DIWSTOP-DMACONR(a6)
	move.w	#diwhigh_bits,DIWHIGH-DMACONR(a6) ; OS 3.x  LoadView() sets DIWHIGH=$0000 -> display glitches
	rts


	CNOP 0,4
init_second_copperlist
	move.l	cl2_construction2(a3),a0
	bsr.s	cl2_init_playfield_props
	bsr	cl2_init_colors
	bsr	cl2_init_bitplane_pointers
	bsr	cl2_init_line_blits_steady
	bsr	cl2_init_line_blits
	bsr	cl2_init_fill_blit
	COP_LISTEND SAVETAIL
	bsr	get_wrappingper_view_values
	bsr	cl2_set_bitplane_pointers
	bsr	copy_second_copperlist
	bsr	swap_second_copperlist
	bsr	set_second_copperlist
	bsr	mgv_fill_playfield1
	bsr	mgv_draw_lines
	bsr	mgv_set_second_copperlist
	bsr	swap_second_copperlist
	bsr	set_second_copperlist
	bsr	mgv_fill_playfield1
	bsr	mgv_draw_lines
	bra	mgv_set_second_copperlist

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
	COP_MOVEQ -1,BLTAFWM
	COP_MOVEQ -1,BLTALWM
	COP_MOVEQ 0,BLTCPTH
	COP_MOVEQ 0,BLTDPTH
	COP_MOVEQ pf1_plane_width*pf1_depth3,BLTCMOD ; moduli interleaved bitmaps
	COP_MOVEQ pf1_plane_width*pf1_depth3,BLTDMOD
	COP_MOVEQ -1,BLTBDAT		; line texture
	COP_MOVEQ $8000,BLTADAT		; line texture starts with MSB
	COP_MOVEQ 0,COP2LCH
	COP_MOVEQ 0,COP2LCL
	COP_MOVEQ 0,COPJMP2
	rts


	CNOP 0,4
cl2_init_line_blits
	MOVEF.W	mgv_lines_number_max-1,d7
cl1_init_line_blits_loop
	COP_MOVEQ 0,BLTCON0
	COP_MOVEQ 0,BLTCON1
	COP_MOVEQ 0,BLTCPTL
	COP_MOVEQ 0,BLTAPTL
	COP_MOVEQ 0,BLTDPTL
	COP_MOVEQ 0,BLTBMOD
	COP_MOVEQ 0,BLTAMOD
	COP_MOVEQ 0,BLTSIZE
	COP_WAITBLIT
	dbf	d7,cl1_init_line_blits_loop
	rts


	CNOP 0,4
cl2_init_fill_blit
	COP_MOVEQ BC0F_SRCA|BC0F_DEST|ANBNC|ANBC|ABNC|ABC,BLTCON0 ; minterm D=A
	COP_MOVEQ BLTCON1F_DESC+BLTCON1F_EFE,BLTCON1 ; fill mode, backwards
	COP_MOVEQ 0,BLTAPTH
	COP_MOVEQ 0,BLTAPTL
	COP_MOVEQ 0,BLTDPTH
	COP_MOVEQ 0,BLTDPTL
	COP_MOVEQ pf1_plane_width-(visible_pixels_number/8),BLTAMOD
	COP_MOVEQ pf1_plane_width-(visible_pixels_number/8),BLTDMOD
	COP_MOVEQ ((mgv_fill_blit_y_size*mgv_fill_blit_depth)<<6)+(mgv_fill_blit_x_size/WORD_BITS),BLTSIZE
	rts


	CNOP 0,4
get_wrappingper_view_values
	move.l	cl2_construction2(a3),a0
	or.w	#v_bplcon0_bits,cl2_BPLCON0+WORD_SIZE(a0)
	or.w	#v_bplcon3_bits1,cl2_BPLCON3_1+WORD_SIZE(a0)
	or.w	#v_bplcon4_bits,cl2_BPLCON4+WORD_SIZE(a0)
	or.w	#v_fmode_bits,cl2_FMODE+WORD_SIZE(a0)
	rts


	COP_SET_BITPLANE_POINTERS cl2,construction2,pf1_depth3


	COPY_COPPERLIST cl2,2


	CNOP 0,4
main
	bsr.s	beam_routines
	rts


	CNOP 0,4
beam_routines
	bsr	wait_beam_position
	bsr.s	swap_second_copperlist
	bsr.s	set_second_copperlist
	bsr.s	swap_playfield1
	bsr	set_playfield1
	bsr	effects_handler
	bsr	mgv_clear_playfield1
	bsr	mgv_calculate_xyz_speed
	bsr	mgv_rotation
	bsr	mgv_morph_object
	bsr	mgv_draw_lines
	bsr	mgv_fill_playfield1
	bsr	mgv_set_second_copperlist
	bsr	scroll_pf_bottom_in
	bsr	scroll_pf_bottom_out
	bsr	mouse_handler
	tst.l	d0			; exit ?
	bne.s	beam_routines_exit
	tst.w	stop_fx_active(a3)
	bne.s	beam_routines
beam_routines_exit
	move.l	cl_end(a3),COP2LC-DMACONR(a6)
	move.w	d0,COPJMP2-DMACONR(a6)
	move.w	custom_error_code(a3),d1
	rts


	SWAP_COPPERLIST cl2,2


	SET_COPPERLIST cl2


	SWAP_PLAYFIELD pf1,3


	CNOP 0,4
set_playfield1
	move.l	#ALIGN_64KB,d1
	moveq	#0,d2
	moveq	#pf1_plane_width,d3
	move.l	cl2_display(a3),a0
	ADDF.W	cl2_BPL1PTH+WORD_SIZE,a0
	move.l	pf1_display(a3),a1
	moveq	#pf1_depth3-1,d7
set_playfield1_loop
	move.l	(a1)+,d0
	add.l	d1,d0			; 64 kB alignment
	clr.w	d0
	add.l	d2,d0			; bitplanes offset
	move.w	d0,LONGWORD_SIZE(a0)	; BPLxPTL
	swap	d0
	move.w	d0,(a0)			; BPLxPTH
	add.l	d3,d2			; next bitplane
	addq.w	#QUADWORD_SIZE,a0
	dbf	d7,set_playfield1_loop
	rts


	CNOP 0,4
mgv_clear_playfield1
	movem.l a3-a6,-(a7)
	move.l	a7,save_a7(a3)
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	move.l	d1,a0
	move.l	d1,a1
	move.l	d1,a2
	move.l	d1,a4
	move.l	d1,a5
	move.l	d1,a6
	move.l	pf1_construction1(a3),a7
	move.l	(a7),d0
	add.l	#ALIGN_64KB,d0
	clr.w	d0
	move.l	d0,a7
	ADDF.L	pf1_plane_width*visible_lines_number*pf1_depth3,a7 ; end of playfield
	moveq	#0,d0
	move.l	d0,a3
	moveq	#7-1,d7
mgv_clear_playfield1_loop
	REPT ((pf1_plane_width*visible_lines_number*pf1_depth3)/56)/7
		movem.l d0-d6/a0-a6,-(a7) ; clear 56 bytes
	ENDR
	dbf	d7,mgv_clear_playfield1_loop
	movem.l d0-d6/a0-a6,-(a7)	; clear remaining 304 bytes
	movem.l d0-d6/a0-a6,-(a7) 
	movem.l d0-d6/a0-a6,-(a7) 
	movem.l d0-d6/a0-a6,-(a7)
	movem.l d0-d6/a0-a6,-(a7) 
	movem.l d0-d5,-(a7)
	move.l	variables+save_a7(pc),a7
	movem.l (a7)+,a3-a6
	rts


	CNOP 0,4
mgv_calculate_xyz_speed
	move.w	mgv_x_anglespeed_angle(a3),d2
	lea	sine_table(pc),a0
	move.w	(a0,d2.w*2),d0		; sin(w)
	MULSF.W mgv_x_anglespeed_radius*2,d0,d1 ; x speed = (r*sin(w))/2^15
	swap	d0
	MOVEF.W sine_table_length-1,d3
	add.w	#mgv_x_anglespeed_center,d0
	move.w	d0,mgv_variable_x_speed(a3)
	add.w	#mgv_x_anglespeed_speed,d2
	and.w	d3,d2			; remove overflow
	move.w	d2,mgv_x_anglespeed_angle(a3)

	move.w	mgv_y_anglespeed_angle(a3),d2
	move.w	(a0,d2.w*2),d0		; sin(w)
	MULSF.W mgv_y_anglespeed_radius*2,d0,d1 ; y speed = (r*sin(w))/2^15
	swap	d0
	add.w	#mgv_y_anglespeed_center,d0
	move.w	d0,mgv_variable_y_speed(a3)
	add.w	#mgv_y_anglespeed_speed,d2
	and.w	d3,d2			; remove overflow
	move.w	d2,mgv_y_anglespeed_angle(a3)

	move.w	mgv_z_anglespeed_angle(a3),d2
	move.w	(a0,d2.w*2),d0		; sin(w)
	MULSF.W mgv_z_anglespeed_radius*2,d0,d1 ; z speed = (r*sin(w))/2^15
	swap	d0
	add.w	#mgv_z_anglespeed_center,d0
	move.w	d0,mgv_variable_z_speed(a3)
	add.w	#mgv_z_anglespeed_speed,d2
	and.w	d3,d2			; remove overflow
	move.w	d2,mgv_z_anglespeed_angle(a3)
	rts


	CNOP 0,4
mgv_rotation
	movem.l a4-a5,-(a7)
	move.w	mgv_x_angle(a3),d1
	move.w	d1,d0		
	lea	sine_table(pc),a2	
	move.w	(a2,d0.w*2),d4		; sin(a)
	move.w	#sine_table_length/4,a4
	MOVEF.W sine_table_length-1,d3
	add.w	a4,d0			; + 90°
	swap	d4 			; high word: sin(a)
	and.w	d3,d0			; remove overflow
	move.w	(a2,d0.w*2),d4	 	; low word: cos(a)
	add.w	mgv_variable_x_speed(a3),d1
	and.w	d3,d1			; remove overflow
	move.w	d1,mgv_x_angle(a3) 
	move.w	mgv_y_angle(a3),d1
	move.w	d1,d0		
	move.w	(a2,d0.w*2),d5		; sin(b)
	add.w	a4,d0			; + 90°
	swap	d5 			; high word: sin(b)
	and.w	d3,d0			; Übertrag entfernen
	move.w	(a2,d0.w*2),d5	 	; low word: cos(b)
	add.w	mgv_variable_y_speed(a3),d1
	and.w	d3,d1			; remove overflow
	move.w	d1,mgv_y_angle(a3) 
	move.w	mgv_z_angle(a3),d1
	move.w	d1,d0		
	move.w	(a2,d0.w*2),d6		; sin(c)
	add.w	a4,d0			; + 90°
	swap	d6 			; high word: sin(c)
	and.w	d3,d0			; remove overflow
	move.w	(a2,d0.w*2),d6	 	; low word: cos(c)
	add.w	mgv_variable_z_speed(a3),d1
	and.w	d3,d1			; remove overflow
	move.w	d1,mgv_z_angle(a3) 
	lea	mgv_object_coordinates(pc),a0
	lea	mgv_xy_coordinates(pc),a1
	move.w	#mgv_distance*8,a4
	move.w	#mgv_xy_center,a5
	moveq	#mgv_object_edge_points_number-1,d7
mgv_rotation_loop
	move.w	(a0)+,d0		; x
	move.l	d7,a2		
	move.w	(a0)+,d1		; y
	move.w	(a0)+,d2		; z
	ROTATE_X_AXIS
	ROTATE_Y_AXIS
	ROTATE_Z_AXIS
; Central projection and translation
	MULSF.W mgv_distance,d0,d3	; x projection
	add.w	a4,d2			; z+d
	divs.w	d2,d0			; x' = (x*d)/(z+d)
	MULSF.W mgv_distance,d1,d3	; y projection
	add.w	a5,d0			; x' + x center
	move.w	d0,(a1)+		; x position
	divs.w	d2,d1			; y'= (y*d)/(z+d)
	move.l	a2,d7			; loop counter
	add.w	a5,d1			; y' + y center
	move.w	d1,(a1)+		; y position
	dbf	d7,mgv_rotation_loop
	movem.l (a7)+,a4-a5
	rts


	CNOP 0,4
mgv_morph_object
	tst.w	mgv_morph_active(a3)
	bne.s	mgv_morph_object_quit
	move.w	mgv_morph_shapes_start(a3),d1
	moveq	#0,d2			; coordinates counter
	lea	mgv_object_coordinates(pc),a0
	lea	mgv_morph_shapes_table(pc),a1
	move.l	(a1,d1.w*4),a1		; shape table
	MOVEF.W mgv_object_edge_points_number*3-1,d7
mgv_morph_object_loop
	move.w	(a0),d0			; current coordinate
	cmp.w	(a1)+,d0		; destination coordinate reached ?
	beq.s	mgv_morph_object_skip3
	bgt.s	mgv_morph_object_skip1
	addq.w	#mgv_morph_speed,d0	; increase current coordinate
	bra.s	mgv_morph_object_skip2
	CNOP 0,4
mgv_morph_object_skip1
	subq.w	#mgv_morph_speed,d0; decrease current coordinate
mgv_morph_object_skip2
	move.w	d0,(a0)		
	addq.w	#1,d2			; increase coordinates counter
mgv_morph_object_skip3
	addq.w	#WORD_SIZE,a0		; next coordinate
	dbf	d7,mgv_morph_object_loop
	tst.w	d2			; morphing finished ?
	bne.s	mgv_morph_object_quit
	addq.w	#1,d1			; next entry in objects table
	cmp.w	#mgv_morph_shapes_number,d1 ; end of table ?
	beq.s	mgv_morph_object_skip5
	move.w	d1,mgv_morph_shapes_start(a3)
mgv_morph_object_skip5
	move.w	#FALSE,mgv_morph_active(a3)
mgv_morph_object_quit
	rts


	CNOP 0,4
mgv_draw_lines
	movem.l a3-a6,-(a7)
	bsr	mgv_draw_lines_init
	lea	mgv_object_info(pc),a0
	lea	mgv_xy_coordinates(pc),a1
	move.l	pf1_construction1(a3),a2
	move.l	(a2),d0
	add.l	#ALIGN_64KB,d0
	clr.w	d0
	move.l	d0,a2
	sub.l	a4,a4			; lines counter
	move.l	cl2_construction2(a3),a6 
	ADDF.W	cl2_extension3_entry-cl2_extension2_size+cl2_ext2_BLTCON0+WORD_SIZE,a6
	move.l	#((BC0F_SRCA|BC0F_SRCC|BC0F_DEST+NANBC|NABC|ABNC)<<16)+(BLTCON1F_LINE+BLTCON1F_SING),a3 ;Minterm Linien
	MOVEF.W mgv_object_faces_number-1,d7
mgv_draw_lines_loop1
	move.l	(a0)+,a5		; starts
	move.w	(a5),d4			; p1 start
	move.w	2(a5),d5		; p2 start
	move.w	4(a5),d6		; p3 start
	swap	d7 			; high word: loop counter
	movem.w (a1,d5.w*2),d0-d1	; p2(x,y)
	movem.w (a1,d6.w*2),d2-d3	; p3(x,y)
	sub.w	d0,d2			; xv = xp3-xp2
	sub.w	(a1,d4.w*2),d0		; xu = xp2-xp1
	sub.w	d1,d3			; yv = yp3-yp2
	sub.w	2(a1,d4.w*2),d1		; yu = yp2-yp1
	muls.w	d3,d0			; xu*yv
	move.w	(a0)+,d7		; face color
	muls.w	d2,d1			; yu*xv
	move.w	(a0)+,d6		; number of lines
	sub.l	d0,d1			; zn = (yu*xv)-(xu*yv)
	bmi.s	mgv_draw_lines_loop2
	lsr.w	#2,d7			; COLOR02/04 -> COLOR00/01
	beq	mgv_draw_lines_skip3
mgv_draw_lines_loop2
	move.w	(a5)+,d0		; p1,p2 starts
	move.w	(a5),d2
	movem.w (a1,d0.w*2),d0-d1	; xp1,xp2
	movem.w (a1,d2.w*2),d2-d3	; yp1,yp2
	GET_LINE_PARAMETERS mgv,AREAFILL,COPPERUSE,,mgv_draw_lines_skip2
	add.l	a3,d0			; remaining BLTCON0 & BLTCON1 bits
	add.l	a2,d1			; + playfield address
	cmp.w	#1,d7			; bitplane 1 ?
	beq.s	mgv_draw_lines_skip1
	moveq	#pf1_plane_width,d5
	add.l	d5,d1			; next bitplane
	cmp.w	#2,d7			; bitplane 2 ?
	beq.s	mgv_draw_lines_skip1
	add.l	d5,d1			; next bitplane
mgv_draw_lines_skip1
	move.w	d0,cl2_ext2_BLTCON1-cl2_ext2_BLTCON0(a6)
	swap	d0
	move.w	d0,(a6)			; BLTCON0
	MULUF.W 2,d2			; 4*dx
	move.w	d4,cl2_ext2_BLTBMOD-cl2_ext2_BLTCON0(a6) ; 4*dy
	sub.w	d2,d4			; (4*dy)-(4*dx)
	move.w	d1,cl2_ext2_BLTCPTL-cl2_ext2_BLTCON0(a6) ; playfield read
	addq.w	#1,a4			; increase lines counter
	move.w	d1,cl2_ext2_BLTDPTL-cl2_ext2_BLTCON0(a6) ; playfield write
	addq.w	#1*4,d2			; (4*dx)+(1*4)
	move.w	d3,cl2_ext2_BLTAPTL-cl2_ext2_BLTCON0(a6) ; (4*dy)-(2*dx)
	MULUF.W 16,d2			; ((4*dx)+(1*4))*16 = line length
	move.w	d4,cl2_ext2_BLTAMOD-cl2_ext2_BLTCON0(a6) ; 4*(dy-dx)
	addq.w	#WORD_SIZE,d2		; width
	move.w	d2,cl2_ext2_BLTSIZE-cl2_ext2_BLTCON0(a6)
	SUBF.W	cl2_extension2_size,a6
mgv_draw_lines_skip2
	dbf	d6,mgv_draw_lines_loop2
mgv_draw_lines_skip3
	swap	d7		 	; low word: loop counter
	dbf	d7,mgv_draw_lines_loop1
	lea	variables+mgv_lines_counter(pc),a0
	move.w	a4,(a0)			; number of lines
	movem.l (a7)+,a3-a6
	rts
	CNOP 0,4
mgv_draw_lines_init
	move.l	pf1_construction1(a3),a0
	move.l	(a0),d0
	add.l	#ALIGN_64KB,d0
	clr.w	d0
	move.l	cl2_construction2(a3),a0
	swap	d0
	move.w	d0,cl2_extension1_entry+cl2_ext1_BLTCPTH+WORD_SIZE(a0) ; playfield read
	move.w	d0,cl2_extension1_entry+cl2_ext1_BLTDPTH+WORD_SIZE(a0) ; playfield write
	rts


	CNOP 0,4
mgv_fill_playfield1
	move.l	pf1_construction1(a3),a0
	move.l	(a0),d0
	add.l	#ALIGN_64KB,d0
	clr.w	d0
	move.l	cl2_construction2(a3),a0
	ADDF.L	((pf1_plane_width*visible_lines_number*pf1_depth3)-(pf1_plane_width-(visible_pixels_number/8)))-2,d0 ; end of playfield
	move.w	d0,cl2_extension3_entry+cl2_ext3_BLTAPTL+WORD_SIZE(a0) ; source
	move.w	d0,cl2_extension3_entry+cl2_ext3_BLTDPTL+WORD_SIZE(a0) ; destination
	swap	d0
	move.w	d0,cl2_extension3_entry+cl2_ext3_BLTAPTH+WORD_SIZE(a0) ; source
	move.w	d0,cl2_extension3_entry+cl2_ext3_BLTDPTH+WORD_SIZE(a0) ; destination
	rts


	CNOP 0,4
mgv_set_second_copperlist
	move.l	cl2_construction2(a3),a0 
	move.l	a0,d0
	ADDF.L	cl2_extension3_entry,d0
	moveq	#0,d1
	move.w	mgv_lines_counter(a3),d1
	IFEQ mgv_count_lines_enabled
		cmp.w	$1a0000,d1
		blt.s	mgv_set_second_copperlist_skip
		move.w	d1,$1a0000
mgv_set_second_copperlist_skip
	ENDC
	MULUF.W cl2_extension2_size,d1,d2
	sub.l	d1,d0
	move.w	d0,cl2_extension1_entry+cl2_ext1_COP2LCL+WORD_SIZE(a0)
	swap	d0
	move.w	d0,cl2_extension1_entry+cl2_ext1_COP2LCH+WORD_SIZE(a0)
	rts


	CNOP 0,4
scroll_pf_bottom_in
	tst.w	spbi_active(a3)
	bne.s	scroll_pf_bottom_in_quit
	move.w	spbi_y_angle(a3),d2
	cmp.w	#sine_table_length/4,d2 ; 90° ?
	ble.s	scroll_pf_bottom_in_skip
	move.w	#FALSE,spbi_active(a3)
	bra.s	scroll_pf_bottom_in_quit
	CNOP 0,4
scroll_pf_bottom_in_skip
	lea	sine_table,a0
	move.w	(a0,d2.w*2),d0		; sin(w)
	muls.w	#spb_y_radius*2,d0	; y'=(sin(w)*yr)/2^15
	swap	d0
	add.w	#spb_y_centre,d0	; y' + y center
	addq.w	#spbi_y_angle_speed,d2
	move.w	d2,spbi_y_angle(a3) 
	MOVEF.W spb_max_VSTOP,d3
	bsr.s	spb_set_display_window
scroll_pf_bottom_in_quit
	rts


	CNOP 0,4
scroll_pf_bottom_out
	tst.w	spbo_active(a3)
	bne.s	scroll_pf_bottom_out_quit
	move.w	spbo_y_angle(a3),d2
	cmp.w	#sine_table_length/2,d2	; 180° ?
	ble.s	scroll_pf_bottom_out_skip
	move.w	#FALSE,spbo_active(a3)
	clr.w	stop_fx_active(a3)
	bra.s	scroll_pf_bottom_out_quit
	CNOP 0,4
scroll_pf_bottom_out_skip
	lea	sine_table,a0
	move.w	(a0,d2.w*2),d0		; cos(w)
	muls.w	#spb_y_radius*2,d0	; y'=(cos(w)*yr)/2^15
	swap	d0
	add.w	#spb_y_centre,d0	; y' + y center
	addq.w	#spbo_y_angle_speed,d2
	move.w	d2,spbo_y_angle(a3) 
	MOVEF.W spb_max_VSTOP,d3
	bsr.s	spb_set_display_window
scroll_pf_bottom_out_quit
	rts


; Input
; d0.w	y offset
; d3.w	y max
; Result
	CNOP 0,4
spb_set_display_window
	move.l	cl2_construction2(a3),a1
	moveq	#spb_min_VSTART,d1
	add.w	d0,d1			; add y offset
	cmp.w	d3,d1			; VSTART max ?
	ble.s	spb_set_display_window_skip1
	move.w	d3,d1			; correct VSTART
spb_set_display_window_skip1
	move.b	d1,cl2_DIWSTRT+WORD_SIZE(a1) ; VSTART V7-V0
	move.w	d1,d2
	add.w	#visible_lines_number,d2 ; VSTOP
	cmp.w	d3,d2			; VSTOP max ?
	ble.s	spb_set_display_window_skip2
	move.w	d3,d2			; correct VSTOP
spb_set_display_window_skip2
	move.b	d2,cl2_DIWSTOP+WORD_SIZE(a1) ; VSTOP V7-V0
	lsr.w	#8,d1			; adjust V8 bit
	move.b	d1,d2			; add V8 bit
	or.w	#diwhigh_bits&(~(DIWHIGHF_VSTART8|DIWHIGHF_VSTOP8)),d2
	move.w	d2,cl2_DIWHIGH+WORD_SIZE(a1)
	rts


	CNOP 0,4
effects_handler
	moveq	#INTF_SOFTINT,d1
	and.w	INTREQR-DMACONR(a6),d1
	beq.s	effects_handler_quit
	move.w	eh_trigger_number(a3),d0
	cmp.w	#eh_trigger_number_max,d0
	bgt.s	effects_handler_quit
	move.w	d1,INTREQ-DMACONR(a6)
	addq.w	#1,d0
	move.w	d0,eh_trigger_number(a3)
	subq.w	#1,d0
	beq.s	eh_start_scroll_pf_bottom_in
	subq.w	#1,d0
	beq.s	eh_start_morphing
	subq.w	#1,d0
	beq.s	eh_start_morphing
	subq.w	#1,d0
	beq.s	eh_start_scroll_pf_bottom_out
effects_handler_quit
	rts
	CNOP 0,4
eh_start_scroll_pf_bottom_in
	clr.w	spbi_active(a3)
	rts
	CNOP 0,4
eh_start_morphing
	clr.w	mgv_morph_active(a3)
	rts
	CNOP 0,4
eh_start_scroll_pf_bottom_out
	clr.w	spbo_active(a3)
	rts


	INCLUDE "int-autovectors-handlers.i"


	CNOP 0,4
nmi_int_server
	rts


	INCLUDE "help-routines.i"


	INCLUDE "sys-structures.i"


	CNOP 0,4
pf1_rgb8_color_table
	REPT pf1_colors_number
		DC.L color00_bits
	ENDR


; Morph-Glenz-Vectors
	CNOP 0,4
mgv_rgb8_color_table
	INCLUDE "Superglenz:colortables/1xGlenz-Colorgradient6.ct"

	CNOP 0,2
mgv_object_coordinates
; Zoom-In
	DS.W mgv_object_edge_points_number*3

; Object shapes
; Shape 1
	CNOP 0,2
mgv_object_shape1_coordinates
; Polygon3
	DC.W 0,-(13*8),0		; P0
	DC.W -(13*8),-(13*8),-(31*8)	; P1
	DC.W 13*8,-13*8,-(31*8)		; P2
	DC.W 31*8,-13*8,-(13*8)		; P3
	DC.W 31*8,-13*8,13*8		; P4
	DC.W 13*8,-13*8,31*8		; P5
	DC.W -(13*8),-(13*8),31*8	; P6
	DC.W -(31*8),-(13*8),13*8	; P7
	DC.W -(31*8),-(13*8),-(13*8)	; P8
	DC.W 0,0,-(47*8)		; P9
	DC.W 31*8,0,-(31*8)		; P10
	DC.W 47*8,0,0			; P13
	DC.W 31*8,0,31*8		; P12
	DC.W 0,0,47*8			; P13
	DC.W -(31*8),0,31*8		; P14
	DC.W -(47*8),0,0		; P15
	DC.W -(31*8),0,-(31*8)		; P16
	DC.W -(31*8),31*8,-(84*8)	; P17
	DC.W 31*8,31*8,-(84*8)		; P18
	DC.W 84*8,31*8,-(31*8)		; P19
	DC.W 84*8,31*8,31*8		; P20
	DC.W 31*8,31*8,84*8		; P21
	DC.W -(31*8),31*8,84*8		; P22
	DC.W -(84*8),31*8,31*8		; P23
	DC.W -(84*8),31*8,-(31*8)	; P24
	DC.W 0,60*8,0			; P25

; Shape 2
	CNOP 0,2
mgv_object_shape2_coordinates
; Polygon 1
	DC.W 0,-(95*8),0		; P0
	DC.W -(40*8),-(40*8),-(95*8)	; P1
	DC.W 40*8,-40*8,-(95*8)		; P2
	DC.W 95*8,-40*8,-(40*8)		; P3
	DC.W 95*8,-40*8,40*8		; P4
	DC.W 40*8,-40*8,95*8		; P5
	DC.W -(40*8),-(40*8),95*8	; P6
	DC.W -(95*8),-(40*8),40*8	; P7
	DC.W -(95*8),-(40*8),-(40*8)	; P8
	DC.W 0,0,-(95*8)		; P9
	DC.W 66*8,0,-(66*8)		; P10
	DC.W 95*8,0,0			; P11
	DC.W 66*8,0,66*8		; P12
	DC.W 0,0,95*8			; P13
	DC.W -(66*8),0,66*8		; P14
	DC.W -(95*8),0,0		; P15
	DC.W -(66*8),0,-(66*8)		; P16
	DC.W -(40*8),40*8,-(95*8)	; P17
	DC.W 40*8,40*8,-(95*8)		; P18
	DC.W 95*8,40*8,-(40*8)		; P19
	DC.W 95*8,40*8,40*8		; P20
	DC.W 40*8,40*8,95*8		; P21
	DC.W -(40*8),40*8,95*8		; P22
	DC.W -(95*8),40*8,40*8		; P23
	DC.W -(95*8),40*8,-(40*8)	; P24
	DC.W 0,95*8,0			; P25

; Shape 3
	CNOP 0,2
mgv_object_shape3_coordinates
; Polygon 2
	DC.W 0,-(48*8),0		; P0
	DC.W -(32*8),-(48*8),-(82*8)	; P1
	DC.W 32*8,-(48*8),-(82*8)	; P2
	DC.W 82*8,-(48*8),-(32*8)	; P3
	DC.W 82*8,-(48*8),32*8		; P4
	DC.W 32*8,-(48*8),82*8		; P5
	DC.W -(32*8),-(48*8),82*8	; P6
	DC.W -(82*8),-(48*8),32*8	; P7
	DC.W -(82*8),-(48*8),-(32*8)	; P8
	DC.W 0,0,-(82*8)		; P9
	DC.W 58*8,0,-(58*8)		; P10
	DC.W 82*8,0,0			; P11
	DC.W 58*8,0,58*8		; P12
	DC.W 0,0,82*8			; P13
	DC.W -(58*8),0,58*8		; P14
	DC.W -(82*8),0,0		; P15
	DC.W -(58*8),0,-58*8		; P16
	DC.W -(32*8),48*8,-(82*8)	; P17
	DC.W 32*8,48*8,-(82*8)		; P18
	DC.W 82*8,48*8,-(32*8)		; P19
	DC.W 82*8,48*8,32*8		; P20
	DC.W 32*8,48*8,82*8		; P21
	DC.W -(32*8),48*8,82*8		; P22
	DC.W -(82*8),48*8,32*8		; P23
	DC.W -(82*8),48*8,-32*8		; P24
	DC.W 0,48*8,0			; P25

	CNOP 0,4
mgv_object_info
; 1. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face1_color	; Farbe der face
	DC.W mgv_object_face1_lines_number-1 ; Anzahl der Linien
; 2. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face2_color	
	DC.W mgv_object_face2_lines_number-1 
; 3. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face3_color	
	DC.W mgv_object_face3_lines_number-1 
; 4. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face4_color	
	DC.W mgv_object_face4_lines_number-1 
; 5. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face5_color	
	DC.W mgv_object_face5_lines_number-1 
; 6. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face6_color	
	DC.W mgv_object_face6_lines_number-1 
; 7. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face7_color	
	DC.W mgv_object_face7_lines_number-1 
; 8. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face8_color	
	DC.W mgv_object_face8_lines_number-1 

; 9. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face9_color	
	DC.W mgv_object_face9_lines_number-1 
; 10. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face10_color	
	DC.W mgv_object_face10_lines_number-1 
; 11. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face11_color	
	DC.W mgv_object_face11_lines_number-1 
; 12. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face12_color	
	DC.W mgv_object_face12_lines_number-1 

; 13. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face13_color	
	DC.W mgv_object_face13_lines_number-1 
; 14. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face14_color	
	DC.W mgv_object_face14_lines_number-1 
; 15. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face15_color	
	DC.W mgv_object_face15_lines_number-1 
; 16. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face16_color	
	DC.W mgv_object_face16_lines_number-1 

; 17. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face17_color	
	DC.W mgv_object_face17_lines_number-1 
; 18. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face18_color	
	DC.W mgv_object_face18_lines_number-1 
; 19. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face19_color	
	DC.W mgv_object_face19_lines_number-1 
; 20. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face20_color	
	DC.W mgv_object_face20_lines_number-1 

; 21. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face21_color	
	DC.W mgv_object_face21_lines_number-1 
; 22. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face22_color	
	DC.W mgv_object_face22_lines_number-1 
; 23. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face23_color	
	DC.W mgv_object_face23_lines_number-1 
; 24. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face24_color	
	DC.W mgv_object_face24_lines_number-1 

; 25. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face25_color	
	DC.W mgv_object_face25_lines_number-1 
; 26. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face26_color	
	DC.W mgv_object_face26_lines_number-1 
; 27. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face27_color	
	DC.W mgv_object_face27_lines_number-1 
; 28. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face28_color	
	DC.W mgv_object_face28_lines_number-1 

; 29. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face29_color	
	DC.W mgv_object_face29_lines_number-1 
; 30. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face30_color	
	DC.W mgv_object_face30_lines_number-1 
; 31. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face31_color	
	DC.W mgv_object_face31_lines_number-1 
; 32. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face32_color	
	DC.W mgv_object_face32_lines_number-1 

; 33. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face33_color	
	DC.W mgv_object_face33_lines_number-1 
; 34. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face34_color	
	DC.W mgv_object_face34_lines_number-1 
; 35. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face35_color	
	DC.W mgv_object_face35_lines_number-1 
; 36. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face36_color	
	DC.W mgv_object_face36_lines_number-1 

; 37. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face37_color	
	DC.W mgv_object_face37_lines_number-1 
; 38. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face38_color	
	DC.W mgv_object_face38_lines_number-1 
; 39. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face39_color	
	DC.W mgv_object_face39_lines_number-1 
; 40. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face40_color	
	DC.W mgv_object_face40_lines_number-1 

; 41. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face41_color	
	DC.W mgv_object_face41_lines_number-1 
; 42. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face42_color	
	DC.W mgv_object_face42_lines_number-1 
; 43. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face43_color	
	DC.W mgv_object_face43_lines_number-1 
; 44. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face44_color	
	DC.W mgv_object_face44_lines_number-1 
; 45. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face45_color	
	DC.W mgv_object_face45_lines_number-1 
; 46. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face46_color	
	DC.W mgv_object_face46_lines_number-1 
; 47. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face47_color	
	DC.W mgv_object_face47_lines_number-1 
; 48. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face48_color	
	DC.W mgv_object_face48_lines_number-1 

	CNOP 0,2
mgv_object_edges
	DC.W 0*2,6*2,5*2,0*2		; face 5 top, triangle 12 o'clock
	DC.W 0*2,5*2,4*2,0*2		; face 4 top, triangle 1,5 o'clock
	DC.W 3*2,0*2,4*2,3*2		; face 3 top, triangle 3 o'clock
	DC.W 0*2,3*2,2*2,0*2		; face 2 top, triangle 4,5 o'clock
	DC.W 1*2,0*2,2*2,1*2		; face 1 top, triangle 6 o'clock
	DC.W 1*2,8*2,0*2,1*2		; face 8 top, triangle 7,5 o'clock
	DC.W 8*2,7*2,0*2,8*2		; face 7 top, triangle 9 o'clock
	DC.W 0*2,7*2,6*2,0*2		; face 6 top, triangle 10,5 o'clock

	DC.W 2*2,9*2,1*2,2*2		; face 9 front, triangle 12 o'clock
	DC.W 2*2,18*2,9*2,2*2		; face 12 front, triangle 3 o'clock
	DC.W 9*2,18*2,17*2,9*2		; face 11 front, triangle 6 o'clock
	DC.W 1*2,9*2,17*2,1*2		; face 10 front, triangle 9 o'clock

	DC.W 3*2,10*2,2*2,3*2		; face 13 front right, triangle 12 o'clock
	DC.W 19*2,10*2,3*2,19*2		; face 16 front right, triangle 3 o'clock
	DC.W 10*2,19*2,18*2,10*2	; face 15 front right, triangle 6 o'clock
	DC.W 2*2,10*2,18*2,2*2		; face 14 front right, triangle 9 o'clock

	DC.W 4*2,11*2,3*2,4*2		; face 17 right, triangle 12 o'clock
	DC.W 4*2,20*2,11*2,4*2		; face 20 right, triangle 3 o'clock
	DC.W 11*2,20*2,19*2,11*2	; face 19 right, triangle 6 o'clock
	DC.W 3*2,11*2,19*2,3*2		; face 18 right, triangle 9 o'clock

	DC.W 5*2,12*2,4*2,5*2		; face 21 back right, triangle 12 o'clock
	DC.W 5*2,21*2,12*2,5*2		; face 24 back right, triangle 3 o'clock
	DC.W 12*2,21*2,20*2,12*2	; face 23 back right, triangle 6 o'clock
	DC.W 12*2,20*2,4*2,12*2		; face 22 back right, triangle 9 o'clock

	DC.W 6*2,13*2,5*2,6*2		; face 25 back, triangle 12 o'clock
	DC.W 6*2,22*2,13*2,6*2		; face 28 back, triangle 3 o'clock
	DC.W 13*2,22*2,21*2,13*2	; face 27 back, triangle 6 o'clock
	DC.W 5*2,13*2,21*2,5*2		; face 26 back, triangle 9 o'clock

	DC.W 7*2,14*2,6*2,7*2		; face 29 back left, triangle 12 o'clock
	DC.W 7*2,23*2,14*2,7*2		; face 32 back left, triangle 3 o'clock
	DC.W 14*2,23*2,22*2,14*2	; face 31 back left, triangle 6 o'clock
	DC.W 6*2,14*2,22*2,6*2		; face 30 back left, triangle 9 o'clock

	DC.W 8*2,15*2,7*2,8*2		; face 33 left, triangle 12 o'clock
	DC.W 8*2,24*2,15*2,8*2		; face 36 left, triangle 3 o'clock
	DC.W 15*2,24*2,23*2,15*2	; face 35 left, triangle 6 o'clock
	DC.W 7*2,15*2,23*2,7*2		; face 34 left, triangle 9 o'clock

	DC.W 1*2,16*2,8*2,1*2		; face 37 front left, triangle 12 o'clock
	DC.W 1*2,17*2,16*2,1*2		; face 40 front left, triangle 3 o'clock
	DC.W 16*2,17*2,24*2,16*2	; face 39 front left, triangle 6 o'clock
	DC.W 8*2,16*2,24*2,8*2		; face 38 front left, triangle 9 o'clock

	DC.W 25*2,21*2,22*2,25*2	; face 45 unten, triangle 12 o'clock
	DC.W 25*2,20*2,21*2,25*2	; face 44 unten, triangle 1,5 o'clock
	DC.W 19*2,20*2,25*2,19*2	; face 43 unten, triangle 3 o'clock
	DC.W 18*2,19*2,25*2,18*2	; face 42 unten, triangle 4,5 o'clock
	DC.W 17*2,18*2,25*2,17*2	; face 41 unten, triangle 6 o'clock
	DC.W 17*2,25*2,24*2,17*2	; face 48 unten, triangle 7,5 o'clock
	DC.W 24*2,25*2,23*2,24*2	; face 47 unten, triangle 9 o'clock
	DC.W 25*2,22*2,23*2,25*2	; face 46 unten, triangle 10,5 o'clock

	CNOP 0,2
mgv_xy_coordinates
	DS.W mgv_object_edge_points_number*2

	CNOP 0,4
mgv_morph_shapes_table
	DS.B morph_shape_size*mgv_morph_shapes_number


	INCLUDE "sys-variables.i"


	INCLUDE "sys-names.i"


	INCLUDE "error-texts.i"

	END
