; Morphing 2x24 faces glenz on a 192x192 screen
; Copper waits for blitter
; Beam position timing
; 64 kB aligned playfield


	MC68040


	XDEF start_015_morph_2xglenz_vectors

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

pf1_x_size1			EQU 192
pf1_y_size1			EQU 192+547
pf1_depth1			EQU 5
pf1_x_size2			EQU 192
pf1_y_size2			EQU 192+547
pf1_depth2			EQU 5
pf1_x_size3			EQU 192
pf1_y_size3			EQU 192+547
pf1_depth3			EQU 5
pf1_colors_number		EQU 32

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

pixel_per_line			EQU 192
visible_pixels_number		EQU 192
visible_lines_number		EQU 192
MINROW				EQU VSTOP_OVERSCAN_PAL

pf_pixel_per_datafetch		EQU 64	; 4x

display_window_hstart		EQU HSTART_192_PIXEL
display_window_vstart		EQU MINROW
display_window_hstop		EQU HSTOP_192_pixel
display_window_vstop		EQU VSTOP_OVERSCAN_PAL

pf1_plane_width			EQU pf1_x_size3/8
data_fetch_width		EQU pixel_per_line/8
pf1_plane_moduli		EQU (pf1_plane_width*(pf1_depth3-1))+pf1_plane_width-data_fetch_width

diwstrt_bits			EQU ((display_window_vstart&$ff)*DIWSTRTF_V0)|(display_window_hstart&$ff)
diwstop_bits			EQU ((display_window_vstop&$ff)*DIWSTOPF_V0)|(display_window_hstop&$ff)
ddfstrt_bits			EQU DDFSTART_192_PIXEL_4X
ddfstop_bits			EQU DDFSTOP_192_PIXEL_4X
bplcon0_bits			EQU BPLCON0F_ECSENA|((pf_depth>>3)*BPLCON0F_BPU3)|(BPLCON0F_COLOR)|((pf_depth&$07)*BPLCON0F_BPU0)
bplcon1_bits			EQU 0
bplcon2_bits			EQU 0
bplcon3_bits1			EQU 0
bplcon3_bits2			EQU bplcon3_bits1|BPLCON3F_LOCT
bplcon4_bits			EQU 0
diwhigh_bits			EQU (((display_window_hstop&$100)>>8)*DIWHIGHF_HSTOP8)|(((display_window_vstop&$700)>>8)*DIWHIGHF_VSTOP8)|(((display_window_hstart&$100)>>8)*DIWHIGHF_HSTART8)|((display_window_vstart&$700)>>8)
fmode_bits			EQU FMODEF_BPL32|FMODEF_BPAGEM

cl2_hstart			EQU $00
cl2_vstart			EQU beam_position&$ff

sine_table_length		EQU 512

; Morph-Glenz-Vectors
mgv_rot_d			EQU 512
mgv_rot_xy_center		EQU visible_lines_number/2

mgv_rot_x_angle_speed_radius	EQU 2 ; 1
mgv_rot_x_angle_speed_center	EQU 4 ; 2
mgv_rot_x_angle_speed_speed	EQU -4 ; -2

mgv_rot_y_angle_speed_radius	EQU 4 ; 2
mgv_rot_y_angle_speed_center	EQU 5 ; 3
mgv_rot_y_angle_speed_speed	EQU 2 ; 1

mgv_rot_z_angle_speed_radius	EQU 2 ; 1
mgv_rot_z_angle_speed_center	EQU 4 ; 2
mgv_rot_z_angle_speed_speed	EQU 4 ; 2

; Objekt 1
mgv_object1_edge_points_number	EQU 14
mgv_object1_edge_points_face	EQU 3
mgv_object1_faces_number	EQU 24

mgv_object1_face1_color		EQU 2
mgv_object1_face1_lines_number	EQU 3
mgv_object1_face2_color		EQU 4
mgv_object1_face2_lines_number	EQU 3
mgv_object1_face3_color		EQU 2
mgv_object1_face3_lines_number	EQU 3
mgv_object1_face4_color		EQU 4
mgv_object1_face4_lines_number	EQU 3

mgv_object1_face5_color		EQU 2
mgv_object1_face5_lines_number	EQU 3
mgv_object1_face6_color		EQU 4
mgv_object1_face6_lines_number	EQU 3
mgv_object1_face7_color		EQU 2
mgv_object1_face7_lines_number	EQU 3
mgv_object1_face8_color		EQU 4
mgv_object1_face8_lines_number	EQU 3

mgv_object1_face9_color		EQU 4
mgv_object1_face9_lines_number	EQU 3
mgv_object1_face10_color	EQU 2
mgv_object1_face10_lines_number	EQU 3
mgv_object1_face11_color	EQU 4
mgv_object1_face11_lines_number	EQU 3
mgv_object1_face12_color	EQU 2
mgv_object1_face12_lines_number	EQU 3

mgv_object1_face13_color	EQU 4
mgv_object1_face13_lines_number	EQU 3
mgv_object1_face14_color	EQU 2
mgv_object1_face14_lines_number	EQU 3
mgv_object1_face15_color	EQU 4
mgv_object1_face15_lines_number	EQU 3
mgv_object1_face16_color	EQU 2
mgv_object1_face16_lines_number	EQU 3

mgv_object1_face17_color	EQU 4
mgv_object1_face17_lines_number	EQU 3
mgv_object1_face18_color	EQU 2
mgv_object1_face18_lines_number	EQU 3
mgv_object1_face19_color	EQU 4
mgv_object1_face19_lines_number	EQU 3
mgv_object1_face20_color	EQU 2
mgv_object1_face20_lines_number	EQU 3

mgv_object1_face21_color	EQU 4
mgv_object1_face21_lines_number	EQU 3
mgv_object1_face22_color	EQU 2
mgv_object1_face22_lines_number	EQU 3
mgv_object1_face23_color	EQU 4
mgv_object1_face23_lines_number	EQU 3
mgv_object1_face24_color	EQU 2
mgv_object1_face24_lines_number	EQU 3

; Objekt 2
mgv_object2_edge_points_number	EQU 14
mgv_object2_edge_points_face	EQU 3
mgv_object2_faces_number	EQU 24

mgv_object2_face1_color		EQU 8
mgv_object2_face1_lines_number	EQU 3
mgv_object2_face2_color		EQU 16
mgv_object2_face2_lines_number	EQU 3
mgv_object2_face3_color		EQU 8
mgv_object2_face3_lines_number	EQU 3
mgv_object2_face4_color		EQU 16
mgv_object2_face4_lines_number	EQU 3

mgv_object2_face5_color		EQU 8
mgv_object2_face5_lines_number	EQU 3
mgv_object2_face6_color		EQU 16
mgv_object2_face6_lines_number	EQU 3
mgv_object2_face7_color		EQU 8
mgv_object2_face7_lines_number	EQU 3
mgv_object2_face8_color		EQU 16
mgv_object2_face8_lines_number	EQU 3

mgv_object2_face9_color		EQU 16
mgv_object2_face9_lines_number	EQU 3
mgv_object2_face10_color	EQU 8
mgv_object2_face10_lines_number	EQU 3
mgv_object2_face11_color	EQU 16
mgv_object2_face11_lines_number	EQU 3
mgv_object2_face12_color	EQU 8
mgv_object2_face12_lines_number	EQU 3

mgv_object2_face13_color	EQU 16
mgv_object2_face13_lines_number	EQU 3
mgv_object2_face14_color	EQU 8
mgv_object2_face14_lines_number	EQU 3
mgv_object2_face15_color	EQU 16
mgv_object2_face15_lines_number	EQU 3
mgv_object2_face16_color	EQU 8
mgv_object2_face16_lines_number	EQU 3

mgv_object2_face17_color	EQU 16
mgv_object2_face17_lines_number	EQU 3
mgv_object2_face18_color	EQU 8
mgv_object2_face18_lines_number	EQU 3
mgv_object2_face19_color	EQU 16
mgv_object2_face19_lines_number	EQU 3
mgv_object2_face20_color	EQU 8
mgv_object2_face20_lines_number	EQU 3

mgv_object2_face21_color	EQU 16
mgv_object2_face21_lines_number	EQU 3
mgv_object2_face22_color	EQU 8
mgv_object2_face22_lines_number	EQU 3
mgv_object2_face23_color	EQU 16
mgv_object2_face23_lines_number	EQU 3
mgv_object2_face24_color	EQU 8
mgv_object2_face24_lines_number	EQU 3

mgv_objects_number		EQU 2
mgv_objects_d			EQU 256
mgv_objects_xy_rot_center	EQU visible_lines_number/2
mgv_objects_x_rot_angle_speed	EQU 2
mgv_objects_y_rot_angle_speed	EQU 2
mgv_objects_z_rot_angle_speed	EQU 1
mgv_objects_edge_points_number	EQU mgv_object1_edge_points_number+mgv_object2_edge_points_number
mgv_objects_faces_number	EQU mgv_object1_faces_number+mgv_object2_faces_number

mgv_lines_number_max		EQU 114

mgv_morph_shapes_number		EQU 7
mgv_morph_speed			EQU 8

; Shape 1
mgv_object1_shape1_x_rot_speed	EQU 2
mgv_object1_shape1_y_rot_speed	EQU 2
mgv_object1_shape1_z_rot_speed	EQU 1
mgv_object2_shape1_x_rot_speed	EQU 2
mgv_object2_shape1_y_rot_speed	EQU 2
mgv_object2_shape1_z_rot_speed	EQU 1

; Shape 2
mgv_object1_shape2_x_rot_speed	EQU 2
mgv_object1_shape2_y_rot_speed	EQU 2
mgv_object1_shape2_z_rot_speed	EQU 1
mgv_object2_shape2_x_rot_speed	EQU 2
mgv_object2_shape2_y_rot_speed	EQU 2
mgv_object2_shape2_z_rot_speed	EQU 1

; Shape 3
mgv_object1_shape3_x_rot_speed	EQU 2
mgv_object1_shape3_y_rot_speed	EQU 2
mgv_object1_shape3_z_rot_speed	EQU 1
mgv_object2_shape3_x_rot_speed	EQU 1
mgv_object2_shape3_y_rot_speed	EQU 3
mgv_object2_shape3_z_rot_speed	EQU 1

; Shape 4
mgv_object1_shape4_x_rot_speed	EQU 2
mgv_object1_shape4_y_rot_speed	EQU 2
mgv_object1_shape4_z_rot_speed	EQU 1
mgv_object2_shape4_x_rot_speed	EQU 1
mgv_object2_shape4_y_rot_speed	EQU 4
mgv_object2_shape4_z_rot_speed	EQU 1

; Shape 5
mgv_object1_shape5_x_rot_speed	EQU 1
mgv_object1_shape5_y_rot_speed	EQU 2
mgv_object1_shape5_z_rot_speed	EQU 1
mgv_object2_shape5_x_rot_speed	EQU 2
mgv_object2_shape5_y_rot_speed	EQU 2
mgv_object2_shape5_z_rot_speed	EQU 1

; Shape 6
mgv_object1_shape6_x_rot_speed	EQU 2
mgv_object1_shape6_y_rot_speed	EQU 2
mgv_object1_shape6_z_rot_speed	EQU 2
mgv_object2_shape6_x_rot_speed	EQU 2
mgv_object2_shape6_y_rot_speed	EQU 3
mgv_object2_shape6_z_rot_speed	EQU 1

; Fill-Blit
mgv_fill_blit_x_size		EQU visible_pixels_number
mgv_fill_blit_y_size		EQU visible_lines_number
mgv_fill_blit_depth		EQU pf1_depth3

; Scroll-Playfield-Bottom
spb_min_vstart			EQU VSTART_192_LINES
spb_max_vstop			EQU VSTOP_OVERSCAN_PAL
spb_y_radius			EQU spb_max_vstop-spb_min_vstart
spb_y_centre			EQU spb_max_vstop-spb_min_vstart

; Scroll-Playfield-Bottom-In
spbi_y_angle_speed		EQU 4

; Scroll-Playfield-Bottom-Out
spbo_y_angle_speed		EQU 10

; Effects-Handler
eh_trigger_number_max		EQU 6


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

morph_shape_object1_edges	RS.L 1
morph_shape_object2_edges	RS.L 1
morph_shape_object1_x_rot_speed RS.W 1
morph_shape_object1_y_rot_speed RS.W 1
morph_shape_object1_z_rot_speed RS.W 1
morph_shape_object2_x_rot_speed RS.W 1
morph_shape_object2_y_rot_speed RS.W 1
morph_shape_object2_z_rot_speed RS.W 1

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

cl2_extension1_size	RS.B 0


	RSRESET

cl2_extension2	RS.B 0

cl2_ext2_BLTCON0		RS.L 1
cl2_ext2_BLTCON1		RS.L 1
cl2_ext2_BLTCPTL		RS.L 1
cl2_ext2_BLTAPTL		RS.L 1
cl2_ext2_BLTDPTL		RS.L 1
cl2_ext2_BLTBMOD		RS.L 1
cl2_ext2_BLTAMOD		RS.L 1
cl2_ext2_BLTSIZE		RS.L 1
cl2_ext2_WAITBLIT		RS.L 1

cl2_extension2_size	RS.B 0


	RSRESET

cl2_extension3	RS.B 0

cl2_ext3_BLTCON0		RS.L 1
cl2_ext3_BLTCON1		RS.L 1
cl2_ext3_BLTAPTH		RS.L 1
cl2_ext3_BLTAPTL		RS.L 1
cl2_ext3_BLTDPTH		RS.L 1
cl2_ext3_BLTDPTL		RS.L 1
cl2_ext3_BLTAMOD		RS.L 1
cl2_ext3_BLTDMOD		RS.L 1
cl2_ext3_BLTSIZE		RS.L 1

cl2_extension3_size	RS.B 0


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
mgv_object1_x_rot_angle		RS.W 1
mgv_object1_y_rot_angle		RS.W 1
mgv_object1_z_rot_angle		RS.W 1

mgv_object2_x_rot_angle		RS.W 1
mgv_object2_y_rot_angle		RS.W 1
mgv_object2_z_rot_angle		RS.W 1

mgv_object1_x_rot_speed		RS.W 1
mgv_object1_y_rot_speed		RS.W 1
mgv_object1_z_rot_speed		RS.W 1

mgv_object2_x_rot_speed		RS.W 1
mgv_object2_y_rot_speed		RS.W 1
mgv_object2_z_rot_speed		RS.W 1

mgv_lines_counter		RS.W 1

mgv_morph_active		RS.W 1
mgv_morph_shapes_start		RS.W 1
mgv_morph_delay_counter		RS.W 1

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


start_015_morph_2xglenz_vectors


	INCLUDE "sys-wrapper.i"


	CNOP 0,4
init_main_variables

; Morph-Glenz-Vectors
	moveq	#TRUE,d0
	move.w	d0,mgv_object1_x_rot_angle(a3)
	move.w	d0,mgv_object1_y_rot_angle(a3)
	move.w	d0,mgv_object1_z_rot_angle(a3)

	move.w	d0,mgv_object2_x_rot_angle(a3)
	move.w	d0,mgv_object2_y_rot_angle(a3)
	move.w	d0,mgv_object2_z_rot_angle(a3)

	move.w	#mgv_objects_x_rot_angle_speed,mgv_object1_x_rot_speed(a3)
	move.w	#mgv_objects_y_rot_angle_speed,mgv_object1_y_rot_speed(a3)
	move.w	#mgv_objects_z_rot_angle_speed,mgv_object1_z_rot_speed(a3)

	move.w	#mgv_objects_x_rot_angle_speed,mgv_object2_x_rot_speed(a3)
	move.w	#mgv_objects_y_rot_angle_speed,mgv_object2_y_rot_speed(a3)
	move.w	#mgv_objects_z_rot_angle_speed,mgv_object2_z_rot_speed(a3)

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
	bsr.s	mgv_init_objects_info
	bsr.s	mgv_init_morph_shapes
	IFEQ mgv_premorph_enabled
		bsr	mgv_init_start_shape
	ENDC
	bsr	mgv_init_color_table
	bsr	spb_init_display_window
	bra	init_second_copperlist

; Morph-Glenz-Vectors
	CNOP 0,4
mgv_init_objects_info
	lea	mgv_objects_info_table+object_info_edges(pc),a0
	lea	mgv_objects_edges(pc),a1
	move.w	#object_info_size,a2
; Object 1
	moveq	#mgv_object1_faces_number-1,d7
	bsr.s	mgv_init_objects_info_loop
; Object 2
	moveq	#mgv_object2_faces_number-1,d7
	bsr.s	mgv_init_objects_info_loop
	rts

; Input
; d7.w	number of faces
; a0.l	Pointer	object info table
; a1.l	Pointer	edge table
; Result
	CNOP 0,4
mgv_init_objects_info_loop
	move.w	object_info_lines_number(a0),d0
	addq.w	#1+1,d0			; number of edge points
	move.l	a1,(a0)			; edge table
	lea	(a1,d0.w*2),a1		; next pointer edge table
	add.l	a2,a0			; object info structure next face
	dbf	d7,mgv_init_objects_info_loop
	rts

	CNOP 0,4
mgv_init_morph_shapes
	lea	mgv_morph_shapes_table(pc),a0
	lea	mgv_object1_shape1_coords(pc),a1
	move.l	a1,(a0)+		; coordinates table
	lea	mgv_object2_shape1_coords(pc),a1
	move.l	a1,(a0)+		; coordinates table
	move.w	#mgv_object1_shape1_x_rot_speed,(a0)+
	move.w	#mgv_object1_shape1_y_rot_speed,(a0)+
	move.w	#mgv_object1_shape1_z_rot_speed,(a0)+
	move.w	#mgv_object2_shape1_x_rot_speed,(a0)+
	move.w	#mgv_object2_shape1_y_rot_speed,(a0)+
	move.w	#mgv_object2_shape1_z_rot_speed,(a0)+

	lea	mgv_object1_shape2_coords(pc),a1
	move.l	a1,(a0)+		; object table
	lea	mgv_object2_shape2_coords(pc),a1
	move.l	a1,(a0)+		; coordinates table
	move.w	#mgv_object1_shape2_x_rot_speed,(a0)+
	move.w	#mgv_object1_shape2_y_rot_speed,(a0)+
	move.w	#mgv_object1_shape2_z_rot_speed,(a0)+
	move.w	#mgv_object2_shape2_x_rot_speed,(a0)+
	move.w	#mgv_object2_shape2_y_rot_speed,(a0)+
	move.w	#mgv_object2_shape2_z_rot_speed,(a0)+

	lea	mgv_object1_shape3_coords(pc),a1
	move.l	a1,(a0)+		; object table
	lea	mgv_object2_shape3_coords(pc),a1
	move.l	a1,(a0)+		; coordinates table
	move.w	#mgv_object1_shape3_x_rot_speed,(a0)+
	move.w	#mgv_object1_shape3_y_rot_speed,(a0)+
	move.w	#mgv_object1_shape3_z_rot_speed,(a0)+
	move.w	#mgv_object2_shape3_x_rot_speed,(a0)+
	move.w	#mgv_object2_shape3_y_rot_speed,(a0)+
	move.w	#mgv_object2_shape3_z_rot_speed,(a0)+

	lea	mgv_object1_shape4_coords(pc),a1
	move.l	a1,(a0)+		; object table
	lea	mgv_object2_shape4_coords(pc),a1
	move.l	a1,(a0)+		; coordinates table
	move.w	#mgv_object1_shape4_x_rot_speed,(a0)+
	move.w	#mgv_object1_shape4_y_rot_speed,(a0)+
	move.w	#mgv_object1_shape4_z_rot_speed,(a0)+
	move.w	#mgv_object2_shape4_x_rot_speed,(a0)+
	move.w	#mgv_object2_shape4_y_rot_speed,(a0)+
	move.w	#mgv_object2_shape4_z_rot_speed,(a0)+

	lea	mgv_object1_shape5_coords(pc),a1
	move.l	a1,(a0)+		; object table
	lea	mgv_object2_shape5_coords(pc),a1
	move.l	a1,(a0)+		; coordinates table
	move.w	#mgv_object1_shape5_x_rot_speed,(a0)+
	move.w	#mgv_object1_shape5_y_rot_speed,(a0)+
	move.w	#mgv_object1_shape5_z_rot_speed,(a0)+
	move.w	#mgv_object2_shape5_x_rot_speed,(a0)+
	move.w	#mgv_object2_shape5_y_rot_speed,(a0)+
	move.w	#mgv_object2_shape5_z_rot_speed,(a0)+

	lea	mgv_object1_shape6_coords(pc),a1
	move.l	a1,(a0)+		; object table
	lea	mgv_object2_shape6_coords(pc),a1
	move.l	a1,(a0)+		; coordinates table
	move.w	#mgv_object1_shape6_x_rot_speed,(a0)+
	move.w	#mgv_object1_shape6_y_rot_speed,(a0)+
	move.w	#mgv_object1_shape6_z_rot_speed,(a0)+
	move.w	#mgv_object2_shape6_x_rot_speed,(a0)+
	move.w	#mgv_object2_shape6_y_rot_speed,(a0)+
	move.w	#mgv_object2_shape6_z_rot_speed,(a0)
	rts

	IFEQ mgv_premorph_enabled
		CNOP 0,4
mgv_init_start_shape
		bsr	mgv_morph_objects
		tst.w	mgv_morph_active(a3) ; morphing finished ?
		beq.s	mgv_init_start_shape
		rts
	ENDC

	CNOP 0,4
mgv_init_color_table
	lea	pf1_rgb8_color_table(pc),a0
	lea	mgv_rgb8_color_table(pc),a1
; Pure colors 1st glenz
	move.l	(a1)+,QUADWORD_SIZE(a0) ; COLOR02
	move.l	(a1)+,3*LONGWORD_SIZE(a0) ; COLOR03
	move.l	(a1)+,4*LONGWORD_SIZE(a0) ; COLOR04
	move.l	(a1)+,5*LONGWORD_SIZE(a0) ; COLOR05
; Pure colors 2nd glenz
	move.l	(a1)+,8*LONGWORD_SIZE(a0) ; COLOR08
	move.l	(a1)+,9*LONGWORD_SIZE(a0) ; COLOR09
	move.l	(a1)+,16*LONGWORD_SIZE(a0) ; COLOR16
	move.l	(a1),17*LONGWORD_SIZE(a0) ; COLOR17
; Mixed colors 1st and 2nd glenz
	moveq	#2,d6			; COLOR02
	moveq	#8,d7			; COLOR08
	bsr	mgv_get_colorvalues_average
	moveq	#2,d6			; COLOR02
	moveq	#9,d7			; COLOR09
	bsr	mgv_get_colorvalues_average
	moveq	#2,d6			; COLOR02
	moveq	#16,d7			; COLOR16
	bsr	mgv_get_colorvalues_average
	moveq	#2,d6			; COLOR02
	moveq	#17,d7			; COLOR17
	bsr	mgv_get_colorvalues_average
	moveq	#3,d6			; COLOR03
	moveq	#9,d7			; COLOR09
	bsr	mgv_get_colorvalues_average
	moveq	#3,d6			; COLOR03
	moveq	#17,d7			; COLOR17
	bsr	mgv_get_colorvalues_average
	moveq	#4,d6			; COLOR04
	moveq	#9,d7			; COLOR09
	bsr	mgv_get_colorvalues_average
	moveq	#4,d6			; COLOR04
	moveq	#17,d7			; COLOR17
	bsr	mgv_get_colorvalues_average
	moveq	#5,d6			; COLOR05
	moveq	#9,d7			; COLOR09
	bsr	mgv_get_colorvalues_average
	moveq	#5,d6			; COLOR05
	moveq	#17,d7			; COLOR17
	bsr	mgv_get_colorvalues_average

	moveq	#16,d6			; COLOR16
	moveq	#8,d7			; COLOR08
	bsr	mgv_get_colorvalues_average
	moveq	#16,d6			; COLOR16
	moveq	#9,d7			; COLOR09
	bsr	mgv_get_colorvalues_average
	moveq	#16,d6			; COLOR16
	moveq	#10,d7			; COLOR10
	bsr	mgv_get_colorvalues_average
	moveq	#16,d6			; COLOR16
	moveq	#11,d7			; COLOR11
	bsr	mgv_get_colorvalues_average
	moveq	#16,d6			; COLOR16
	moveq	#12,d7			; COLOR12
	bsr	mgv_get_colorvalues_average
	moveq	#16,d6			; COLOR16
	moveq	#13,d7			; COLOR13
	bsr	mgv_get_colorvalues_average
	moveq	#16,d6			; COLOR16
	moveq	#14,d7			; COLOR14
	bsr.s	mgv_get_colorvalues_average
	rts

; Input
; d6.w	1st source color number
; d7.w	2nd source color number
; a0.l	RGB8-Farbtabelle
; Result
	CNOP 0,4
mgv_get_colorvalues_average
	moveq	#0,d0
	move.b	1(a0,d6.w*4),d0		; 1st source color red
	moveq	#0,d1
	move.b	2(a0,d6.w*4),d1		; 1st source color green
	moveq	#0,d2
	move.b	3(a0,d6.w*4),d2		; 1st source color blue
	moveq	#0,d3
	move.b	1(a0,d7.w*4),d3		; 2nd source color red
	moveq	#0,d4
	move.b	2(a0,d7.w*4),d4		; 2nd source color grün
	moveq	#0,d5
	move.b	3(a0,d7.w*4),d5		; 2nd source color blau
	add.w	d7,d6			; mix source colors
	add.w	d3,d0
	lsr.w	#1,d0
	move.b	d0,1(a0,d6.w*4)		; mixed red
	add.w	d4,d1
	lsr.w	#1,d1
	move.b	d1,2(a0,d6.w*4)		; mixed green
	add.w	d5,d2			;
	lsr.w	#1,d2
	move.b	d2,3(a0,d6.w*4)		; mixed blue
	rts


	CNOP 0,4
spb_init_display_window
	move.w	#diwstrt_bits,DIWSTRT-DMACONR(a6)
	move.w	#diwstop_bits,DIWSTOP-DMACONR(a6)
	move.w	#diwhigh_bits,DIWHIGH-DMACONR(a6) ; OS 3.x LoadView() sets DIWHIGH=$0000 -> display glitches
	rts


	CNOP 0,4
init_second_copperlist
	move.l	cl2_construction2(a3),a0
	bsr.s	cl2_init_playfield_props
	bsr	cl2_init_colors
	bsr	cl2_init_plane_ptrs
	bsr	cl2_init_line_blits_steady
	bsr	cl2_init_line_blits
	bsr	cl2_init_fill_blit
	COP_LISTEND SAVETAIL
	bsr	get_wrapper_view_values
	bsr	cl2_set_plane_ptrs
	bsr	copy_second_copperlist
	bsr	swap_second_copperlist
	bsr	mgv_fill_playfield1
	bsr	mgv_draw_lines
	bsr	mgv_set_second_copperlist
	bsr	swap_second_copperlist
	bsr	mgv_fill_playfield1
	bsr	mgv_draw_lines
	bra	mgv_set_second_copperlist


	COP_INIT_PLAYFIELD_REGISTERS cl2


	CNOP 0,4
cl2_init_colors
	COP_INIT_COLOR_HIGH COLOR00,32,pf1_rgb8_color_table

	COP_SELECT_COLOR_LOW_BANK 0,v_bplcon3_bits2
	COP_INIT_COLOR_LOW COLOR00,32,pf1_rgb8_color_table
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
	moveq	#mgv_lines_number_max-1,d7
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
	COP_MOVEQ (mgv_fill_blit_y_size*mgv_fill_blit_depth<<6)+(mgv_fill_blit_x_size/WORD_BITS),BLTSIZE
	rts


	CNOP 0,4
get_wrapper_view_values
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
	bsr.s	swap_playfield1
	bsr	set_playfield1
	bsr     effects_handler
	bsr	mgv_clear_playfield1
	bsr	mgv_rotate_objects
	bsr	mgv_morph_objects
	bsr	mgv_draw_lines
	bsr	mgv_fill_playfield1
	bsr	mgv_set_second_copperlist
	bsr	scroll_pf_bottom_in
	bsr	scroll_pf_bottom_out
	jsr	mouse_handler
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
	moveq	#7-1,d7			; number of durations
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
mgv_rotate_objects
	movem.l a4-a6,-(a7)
	lea	mgv_object1_coords(pc),a0
	lea	mgv_rot_xy_coords(pc),a1
	lea	mgv_object1_x_rot_angle(a3),a5
	lea	mgv_object1_x_rot_speed(a3),a6
	moveq	#mgv_object1_edge_points_number-1,d7
	bsr.s	mgv_rotation

	lea	mgv_object2_coords(pc),a0
	lea	mgv_object2_x_rot_angle(a3),a5
	lea	mgv_object2_x_rot_speed(a3),a6
	moveq	#mgv_object2_edge_points_number-1,d7
	bsr.s	mgv_rotation
	movem.l (a7)+,a4-a6
	rts

; Input
; d7.w	number of points
; a0.l	Pointer	object table
; a1.l	Koordinaten der Linien
; a5.l	Pointer	variable x_rot_angle
; a6.l	Pointer	variable x_rot_speed
; Result
	CNOP 0,4
mgv_rotation
	move.w	(a5),d1			; x angle
	move.w	d1,d0		
	lea	sine_table,a2	
	move.w	(a2,d0.w*2),d4		; sin(a)
	move.w	#sine_table_length/4,a4
	MOVEF.W sine_table_length-1,d3
	add.w	a4,d0			; + 90°
	swap	d4 			; high word: sin(a)
	and.w	d3,d0			; remove overflow
	move.w	(a2,d0.w*2),d4	 	; low word: cos(a)
	add.w	(a6)+,d1		; next x angle
	and.w	d3,d1			; remove overflow
	move.w	d1,(a5)+		
	move.w	(a5),d1			; y angle
	move.w	d1,d0		
	move.w	(a2,d0.w*2),d5		; sin(b)
	add.w	a4,d0			; + 90°
	swap	d5 			; high word: sin(b)
	and.w	d3,d0			; remove overflow
	move.w	(a2,d0.w*2),d5	 	; low word: cos(b)
	add.w	(a6)+,d1		; next y angle
	and.w	d3,d1			; remove overflow
	move.w	d1,(a5)+		
	move.w	(a5),d1			; z angle
	move.w	d1,d0		
	move.w	(a2,d0.w*2),d6		; sin(c)
	add.w	a4,d0			; + 90°
	swap	d6 			; high word: sin(c)
	and.w	d3,d0			; remove overflow
	move.w	(a2,d0.w*2),d6	 	; low word: cos(c)
	add.w	(a6),d1			; next z angle
	and.w	d3,d1			; remove overflow
	move.w	d1,(a5)		
	move.w	#mgv_rot_d*8,a4
	move.w	#mgv_rot_xy_center,a5
mgv_rot_loop
	move.w	(a0)+,d0		; x
	move.l	d7,a2
	move.w	(a0)+,d1		; y
	move.w	(a0)+,d2		; z
	ROTATE_X_AXIS
	ROTATE_Y_AXIS
	ROTATE_Z_AXIS
; Central projection and translation
	MULSF.W mgv_rot_d,d0,d3; x projection
	add.w	a4,d2			; z+d
	divs.w	d2,d0			; x' = (x*d)/(z+d)
	MULSF.W mgv_rot_d,d1,d3; y projection
	add.w	a5,d0			; x' + X-Mittelpunkt
	move.w	d0,(a1)+		; x position
	divs.w	d2,d1			; y' = (y*d)/(z+d)
	move.l	a2,d7			; loop counter
	add.w	a5,d1			; y' + Y-Mittelpunkt
	move.w	d1,(a1)+		; y position
	dbf	d7,mgv_rot_loop
	rts


	CNOP 0,4
mgv_morph_objects
	tst.w	mgv_morph_active(a3)
	bne.s	mgv_morph_objects_quit
	move.w	mgv_morph_shapes_start(a3),d1
	moveq	#0,d2			; coordinates counter
	moveq	#0,d3
	move.w	d1,d3			; start
	MULUF.W morph_shape_size,d3,d0
	lea	mgv_morph_shapes_table(pc),a2
	add.l	d3,a2			; offset in morph shapes table
	lea	mgv_object1_coords(pc),a0
	move.l	(a2)+,a1		; morph shapes table
	MOVEF.W (mgv_object1_edge_points_number*3)-1,d7
	bsr.s	mgv_morph_objects_loop
	lea	mgv_object2_coords(pc),a0
	move.l	(a2)+,a1		; morph shapes table
	MOVEF.W (mgv_object2_edge_points_number*3)-1,d7
	bsr.s	mgv_morph_objects_loop

	tst.w	d2			; morphing finished ?
	bne.s	mgv_morph_objects_quit
	addq.w	#1,d1			; next entry in object table
	cmp.w	#mgv_morph_shapes_number,d1 ; end of table ?
	beq.s	mgv_morph_objects_skip2
	move.w	d1,mgv_morph_shapes_start(a3)
	move.w	(a2)+,mgv_object1_x_rot_speed(a3)
	move.w	(a2)+,mgv_object1_y_rot_speed(a3)
	move.w	(a2)+,mgv_object1_z_rot_speed(a3)
	move.w	(a2)+,mgv_object2_x_rot_speed(a3)
	move.w	(a2)+,mgv_object2_y_rot_speed(a3)
	move.w	(a2),mgv_object2_z_rot_speed(a3)
mgv_morph_objects_skip2
	move.w	#FALSE,mgv_morph_active(a3)
mgv_morph_objects_quit
	rts

; Input
; d7.w	number of coordinates
; a0.l	Pointer	current object
; a1.l	Pointer	destination object
; Result
	CNOP 0,4
mgv_morph_objects_loop
	move.w	(a0),d0			; current coordinate
	cmp.w	(a1)+,d0		; destination coordinate reached ?
	beq.s	mgv_morph_objects_skip5
	bgt.s	mgv_morph_objects_skip3
	addq.w	#mgv_morph_speed,d0	; increase current coordinate
	bra.s	mgv_morph_objects_skip4
	CNOP 0,4
mgv_morph_objects_skip3
	subq.w	#mgv_morph_speed,d0	; decrease current coordinate
mgv_morph_objects_skip4
	move.w	d0,(a0)		
	addq.w	#1,d2			; increase coordinates counter
mgv_morph_objects_skip5
	addq.w	#WORD_SIZE,a0		; next coordinate
	dbf	d7,mgv_morph_objects_loop
	rts


	CNOP 0,4
mgv_draw_lines
	movem.l a3-a6,-(a7)
	bsr	mgv_draw_lines_init
	lea	mgv_objects_info_table(pc),a0
	lea	mgv_rot_xy_coords(pc),a1
	move.l	pf1_construction1(a3),a2
	move.l	(a2),d0
	add.l	#ALIGN_64KB,d0
	clr.w	d0
	move.l	d0,a2
	sub.l	a4,a4			; lines counter
	move.l	cl2_construction2(a3),a6 
	ADDF.W	cl2_extension3_entry-cl2_extension2_size+cl2_ext2_BLTCON0+WORD_SIZE,a6
	move.l	#((BC0F_SRCA|BC0F_SRCC|BC0F_DEST+NANBC|NABC|ABNC)<<16)+(BLTCON1F_LINE+BLTCON1F_SING),a3 ; minterm line mode
	MOVEF.W mgv_objects_faces_number-1,d7
mgv_draw_lines_loop1
	move.l	(a0)+,a5		; starts
	move.w	(a5),d4			; p1 starts
	move.w	2(a5),d5		; p2 starts
	move.w	4(a5),d6		; p3 starts
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
	cmp.w	#1,d7			; backface ?
	beq.s	mgv_draw_lines_loop2
	lsr.w	#2,d7			; COLOR08/16 -> COLOR00/01
	beq	mgv_draw_lines_skip3
mgv_draw_lines_loop2
	move.w	(a5)+,d0		; p1,p2 starts
	move.w	(a5),d2
	movem.w (a1,d0.w*2),d0-d1	; p1(x,y)
	movem.w (a1,d2.w*2),d2-d3	; p2(x,y)
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
	cmp.w	#4,d7			; bitplane 3 ?
	beq.s	mgv_draw_lines_skip1
	add.l	d5,d1			; next bitplane
	cmp.w	#8,d7			; bitplane 4 ?
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
	move.w	d0,cl2_extension3_entry+cl2_ext3_BLTAPTH+WORD_SIZE(a0) ; spource
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
	muls.w	#spb_y_radius*2,d0; y'=(sin(w)*yr)/2^15
	swap	d0
	add.w	#spb_y_centre,d0	; y' + y centre
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
	add.w	#spbo_y_angle_speed,d2
	move.w	d2,spbo_y_angle(a3) 
	MOVEF.W spb_max_VSTOP,d3
	bsr.s	spb_set_display_window
scroll_pf_bottom_out_quit
	rts


; Input
; d0.w	y offset
; d3.w	vertical max
; Result
	CNOP 0,4
spb_set_display_window
	move.l	cl2_construction2(a3),a1
	moveq	#spb_min_VSTART,d1
	add.w	d0,d1			; + y offset
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
	beq.s	eh_start_morphing
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
	INCLUDE "Superglenz:colortables/2xGlenz-Colorgradient.ct"

	CNOP 0,2
mgv_object1_coords
; Zoom-In
	DS.W mgv_object1_edge_points_number*3
	CNOP 0,2
mgv_object2_coords
; Zoom-In
	DS.W mgv_object2_edge_points_number*3

; Object shapes
; Shape 1
	CNOP 0,2
mgv_object1_shape1_coords
; Cube
	DC.W -(48*8),-(48*8),-(48*8)	; P0
	DC.W 48*8,-(48*8),-(48*8)	; P1
	DC.W 48*8,48*8,-(48*8)		; P2
	DC.W -(48*8),48*8,-(48*8)	; P3
	DC.W -(48*8),-(48*8),-(24*8)	; P4
	DC.W 48*8,-(48*8),-(24*8)	; P5
	DC.W 48*8,48*8,-(24*8)		; P6
	DC.W -(48*8),48*8,-(24*8)	; P7
	DC.W 0,0,-(67*8)		; P8
	DC.W 0,0,-(24*8)		; P9
	DC.W -(67*8),0,-(24*8)		; P10
	DC.W 67*8,0,-(24*8)		; P11
	DC.W 0,-(67*8),-(24*8)		; P12
	DC.W 0,67*8,-(24*8)		; P13
	CNOP 0,2
mgv_object2_shape1_coords
; Cube
	DC.W 48*8,-(48*8),48*8		; P18
	DC.W -(48*8),-(48*8),48*8	; P15
	DC.W -(48*8),48*8,48*8		; P16
	DC.W 48*8,48*8,48*8		; P17
	DC.W 48*8,-(48*8),24*8		; P18
	DC.W -(48*8),-(48*8),24*8	; P19
	DC.W -(48*8),48*8,24*8		; P19
	DC.W 48*8,48*8,24*8		; P21
	DC.W 0,0,67*8			; P22
	DC.W 0,0,24*8			; P23
	DC.W 67*8,0,24*8		; P23
	DC.W -(67*8),0,24*8		; P24
	DC.W 0,-(67*8),24*8		; P26
	DC.W 0,67*8,24*8		; P27

; Shape 2
	CNOP 0,2
mgv_object1_shape2_coords
; Cube
	DC.W -(30*8),-(56*8),-(40*8)	; P0
	DC.W 30*8,-(56*8),-(40*8)	; P1
	DC.W 30*8,56*8,-(40*8)		; P2
	DC.W -(30*8),56*8,-(40*8)	; P3
	DC.W -(30*8),-(56*8),-(10*8)	; P4
	DC.W 56*8,0,-(10*8)		; P5
	DC.W 30*8,56*8,-(10*8)		; P6
	DC.W -(56*8),0,-(10*8)		; P7
	DC.W 0,0,-(40*8)		; P8
	DC.W 0,0,-(10*8)		; P9
	DC.W -(56*8),0,-(40*8)		; P10
	DC.W 56*8,0,-(40*8)		; P11
	DC.W 30*8,-(56*8),-(10*8)	; P10
	DC.W -(30*8),56*8,-(10*8)	; P13
	CNOP 0,2
mgv_object2_shape2_coords
; Cube
	DC.W 30*8,-(56*8),40*8		; P18
	DC.W -(30*8),-(56*8),40*8	; P15
	DC.W -(30*8),56*8,40*8		; P16
	DC.W 30*8,56*8,40*8		; P17
	DC.W 30*8,-(56*8),10*8		; P18
	DC.W -(56*8),0,10*8		; P19
	DC.W -(30*8),56*8,10*8		; P20
	DC.W 56*8,0,10*8		; P21
	DC.W 0,0,40*8			; P22
	DC.W 0,0,10*8			; P23
	DC.W 56*8,0,40*8		; P28
	DC.W -(56*8),0,40*8		; P25
	DC.W -(30*8),-(56*8),10*8	; P26
	DC.W 30*8,56*8,10*8		; P27

; Shape 3
	CNOP 0,2
mgv_object1_shape3_coords
; Cube
	DC.W -(35*8),-(67*8),-(48*8); P0
	DC.W 35*8,-(67*8),-(48*8)	; P1
	DC.W 35*8,67*8,-(48*8)		; P2
	DC.W -(35*8),67*8,-(48*8)	; P3
	DC.W -(35*8),-(67*8),48*8	; P4
	DC.W 67*8,0,48*8		; P5
	DC.W 35*8,67*8,48*8		; P6
	DC.W -(67*8),0,48*8		; P7
	DC.W 0,0,-(48*8)		; P8
	DC.W 0,0,48*8			; P9
	DC.W -(67*8),0,-(48*8)		; P10
	DC.W 67*8,0,-(48*8)		; P11
	DC.W 35*8,-(67*8),48*8		; P12
	DC.W -(35*8),67*8,48*8		; P13
mgv_object2_shape3_coords
; Cube
	DC.W 24*8,-(24*8),24*8		; P14
	DC.W -(24*8),-(24*8),24*8	; P15
	DC.W -(24*8),24*8,24*8		; P16
	DC.W 24*8,24*8,24*8		; P17
	DC.W 24*8,-(24*8),-(24*8)	; P18
	DC.W -(24*8),-(24*8),-(24*8)	; P19
	DC.W -(24*8),24*8,-(24*8)	; P19
	DC.W 24*8,24*8,-(24*8)		; P21
	DC.W 0,0,24*8			; P22
	DC.W 0,0,-(24*8)		; P23
	DC.W 24*8,0,0			; P24
	DC.W -(24*8),0,0		; P25
	DC.W 0,-(24*8),0		; P26
	DC.W 0,24*8,0			; P27

; Shape 4
	CNOP 0,2
mgv_object1_shape4_coords
; Cube
	DC.W -(52*8),-(52*8),-(52*8); P0
	DC.W 52*8,-(52*8),-(52*8)	; P1
	DC.W 52*8,52*8,-(52*8)		; P2
	DC.W -(52*8),52*8,-(52*8)	; P3
	DC.W -(52*8),-(52*8),52*8	; P4
	DC.W 52*8,-(52*8),52*8		; P5
	DC.W 52*8,52*8,52*8		; P6
	DC.W -(52*8),52*8,52*8		; P7
	DC.W 0,0,-(76*8)		; P8
	DC.W 0,0,76*8			; P9
	DC.W -(76*8),0,0		; P10
	DC.W 76*8,0,0			; P11
	DC.W 0,-(76*8),0		; P12
	DC.W 0,76*8,0			; P13
mgv_object2_shape4_coords
; Spaceship
	DC.W 24*8,-(11*8),52*8		; P18
	DC.W -(24*8),-(11*8),52*8	; P15
	DC.W -(24*8),11*8,52*8		; P16
	DC.W 24*8,11*8,52*8		; P17
	DC.W 19*8,-(4*8),-(33*8)	; P18
	DC.W -(19*8),-(4*8),-(33*8)	; P19
	DC.W -(19*8),4*8,-(33*8)	; P19
	DC.W 19*8,4*8,-(33*8)		; P21
	DC.W 0,0,52*8			; P22
	DC.W 0,4*8,-(62*8)		; P23
	DC.W 57*8,0,43*8		; P24
	DC.W -(57*8),0,43*8		; P25
	DC.W 0,-(11*8),0		; P26
	DC.W 0,11*8,0			; P27

; Shape 5
	CNOP 0,2
mgv_object1_shape5_coords
; Cube
	DC.W -(48*8),-(48*8),-(11*8); P0
	DC.W 48*8,-(48*8),-(11*8)	; P1
	DC.W 48*8,48*8,-(11*8)		; P2
	DC.W -(48*8),48*8,-(11*8)	; P3
	DC.W -(48*8),-(48*8),11*8	; P4
	DC.W 48*8,-(48*8),11*8		; P5
	DC.W 48*8,48*8,11*8		; P6
	DC.W -(48*8),48*8,11*8		; P7
	DC.W 0,0,-(19*8)		; P8
	DC.W 0,0,19*8			; P9
	DC.W -(67*8),0,0		; P10
	DC.W 67*8,0,0			; P11
	DC.W 0,-(67*8),0		; P12
	DC.W 0,67*8,0			; P13
mgv_object2_shape5_coords
; Cube
	DC.W 48*8,-(11*8),48*8		; P18
	DC.W -(48*8),-(11*8),48*8	; P15
	DC.W -(48*8),11*8,48*8		; P16
	DC.W 48*8,11*8,48*8		; P17
	DC.W 48*8,-(11*8),-(48*8)	; P18
	DC.W -(48*8),-(11*8),-(48*8)	; P19
	DC.W -(48*8),11*8,-(48*8)	; P19
	DC.W 48*8,11*8,-(48*8)		; P21
	DC.W 0,0,67*8			; P22
	DC.W 0,0,-(67*8)		; P23
	DC.W 67*8,0,0			; P24
	DC.W -(67*8),0,0		; P25
	DC.W 0,-(19*8),0		; P26
	DC.W 0,19*8,0			; P27

; Shape 6
	CNOP 0,2
mgv_object1_shape6_coords
; Cube
	DC.W -(48*8),-(48*8),-(48*8)	; P0
	DC.W 48*8,-(48*8),-(48*8)	; P1
	DC.W 48*8,48*8,-(48*8)		; P2
	DC.W -(48*8),48*8,-(48*8)	; P3
	DC.W -(48*8),-(48*8),-(24*8)	; P4
	DC.W 48*8,-(48*8),-(24*8)	; P5
	DC.W 48*8,48*8,-(24*8)		; P6
	DC.W -(48*8),48*8,-(24*8)	; P7
	DC.W 0,0,-(48*8)		; P8
	DC.W 0,0,-(24*8)		; P9
	DC.W -(48*8),0,-(35*8)		; P10
	DC.W 48*8,0,-(35*8)		; P11
	DC.W 0,-(48*8),-(35*8)		; P12
	DC.W 0,48*8,-(35*8)		; P13
mgv_object2_shape6_coords
; Cube
	DC.W 48*8,-(48*8),48*8		; P18
	DC.W -(48*8),-(48*8),48*8	; P15
	DC.W -(48*8),48*8,48*8		; P16
	DC.W 48*8,48*8,48*8		; P17
	DC.W 48*8,-(48*8),24*8		; P18
	DC.W -(48*8),-(48*8),24*8	; P19
	DC.W -(48*8),48*8,24*8		; P19
	DC.W 48*8,48*8,24*8		; P21
	DC.W 0,0,48*8			; P22
	DC.W 0,0,24*8			; P23
	DC.W 48*8,0,35*8		; P24
	DC.W -(48*8),0,35*8		; P25
	DC.W 0,-(48*8),35*8		; P26
	DC.W 0,48*8,35*8		; P27

	CNOP 0,4
mgv_objects_info_table
; Objekt 1
; 1. face
	DC.L 0				; coordinates table
	DC.W mgv_object1_face1_color	
	DC.W mgv_object1_face1_lines_number-1
; 2. face
	DC.L 0				; coordinates table
	DC.W mgv_object1_face2_color	
	DC.W mgv_object1_face2_lines_number-1 
; 3. face
	DC.L 0				; coordinates table
	DC.W mgv_object1_face3_color	
	DC.W mgv_object1_face3_lines_number-1 

; 4. face
	DC.L 0				; coordinates table
	DC.W mgv_object1_face4_color	
	DC.W mgv_object1_face4_lines_number-1 
; 5. face
	DC.L 0				; coordinates table
	DC.W mgv_object1_face5_color	
	DC.W mgv_object1_face5_lines_number-1 
; 6. face
	DC.L 0				; coordinates table
	DC.W mgv_object1_face6_color	
	DC.W mgv_object1_face6_lines_number-1 
; 7. face
	DC.L 0				; coordinates table
	DC.W mgv_object1_face7_color	
	DC.W mgv_object1_face7_lines_number-1 
; 8. face
	DC.L 0				; coordinates table
	DC.W mgv_object1_face8_color	
	DC.W mgv_object1_face8_lines_number-1 

; 9. face
	DC.L 0				; coordinates table
	DC.W mgv_object1_face9_color	
	DC.W mgv_object1_face9_lines_number-1 
; 10. face
	DC.L 0				; coordinates table
	DC.W mgv_object1_face10_color	
	DC.W mgv_object1_face10_lines_number-1 
; 11. face
	DC.L 0				; coordinates table
	DC.W mgv_object1_face11_color	
	DC.W mgv_object1_face11_lines_number-1 
; 12. face
	DC.L 0				; coordinates table
	DC.W mgv_object1_face12_color	
	DC.W mgv_object1_face12_lines_number-1 

; 13. face
	DC.L 0				; coordinates table
	DC.W mgv_object1_face13_color	
	DC.W mgv_object1_face13_lines_number-1 
; 14. face
	DC.L 0				; coordinates table
	DC.W mgv_object1_face14_color	
	DC.W mgv_object1_face14_lines_number-1 
; 15. face
	DC.L 0				; coordinates table
	DC.W mgv_object1_face15_color	
	DC.W mgv_object1_face15_lines_number-1 
; 16. face
	DC.L 0				; coordinates table
	DC.W mgv_object1_face16_color	
	DC.W mgv_object1_face16_lines_number-1 

; 17. face
	DC.L 0				; coordinates table
	DC.W mgv_object1_face17_color	
	DC.W mgv_object1_face17_lines_number-1 
; 18. face
	DC.L 0				; coordinates table
	DC.W mgv_object1_face18_color	
	DC.W mgv_object1_face18_lines_number-1 
; 19. face
	DC.L 0				; coordinates table
	DC.W mgv_object1_face19_color	
	DC.W mgv_object1_face19_lines_number-1 
; 20. face
	DC.L 0				; coordinates table
	DC.W mgv_object1_face20_color	
	DC.W mgv_object1_face20_lines_number-1 

; 21. face
	DC.L 0				; coordinates table
	DC.W mgv_object1_face21_color	
	DC.W mgv_object1_face21_lines_number-1 
; 22. face
	DC.L 0				; coordinates table
	DC.W mgv_object1_face22_color	
	DC.W mgv_object1_face22_lines_number-1 
; 23. face
	DC.L 0				; coordinates table
	DC.W mgv_object1_face23_color	
	DC.W mgv_object1_face23_lines_number-1 
; 24. face
	DC.L 0				; coordinates table
	DC.W mgv_object1_face24_color	
	DC.W mgv_object1_face24_lines_number-1 

; Object2
; 1. face
	DC.L 0				; coordinates table
	DC.W mgv_object2_face1_color	
	DC.W mgv_object2_face1_lines_number-1 
; 2. face
	DC.L 0				; coordinates table
	DC.W mgv_object2_face2_color	
	DC.W mgv_object2_face2_lines_number-1 
; 3. face
	DC.L 0				; coordinates table
	DC.W mgv_object2_face3_color	
	DC.W mgv_object2_face3_lines_number-1 

; 4. face
	DC.L 0				; coordinates table
	DC.W mgv_object2_face4_color	
	DC.W mgv_object2_face4_lines_number-1 
; 5. face
	DC.L 0				; coordinates table
	DC.W mgv_object2_face5_color	
	DC.W mgv_object2_face5_lines_number-1 
; 6. face
	DC.L 0				; coordinates table
	DC.W mgv_object2_face6_color	
	DC.W mgv_object2_face6_lines_number-1 
; 7. face
	DC.L 0				; coordinates table
	DC.W mgv_object2_face7_color	
	DC.W mgv_object2_face7_lines_number-1 
; 8. face
	DC.L 0				; coordinates table
	DC.W mgv_object2_face8_color	
	DC.W mgv_object2_face8_lines_number-1 

; 9. face
	DC.L 0				; coordinates table
	DC.W mgv_object2_face9_color	
	DC.W mgv_object2_face9_lines_number-1 
; 10. face
	DC.L 0				; coordinates table
	DC.W mgv_object2_face10_color	
	DC.W mgv_object2_face10_lines_number-1 
; 11. face
	DC.L 0				; coordinates table
	DC.W mgv_object2_face11_color	
	DC.W mgv_object2_face11_lines_number-1 
; 12. face
	DC.L 0				; coordinates table
	DC.W mgv_object2_face12_color	
	DC.W mgv_object2_face12_lines_number-1 

; 13. face
	DC.L 0				; coordinates table
	DC.W mgv_object2_face13_color	
	DC.W mgv_object2_face13_lines_number-1 
; 14. face
	DC.L 0				; coordinates table
	DC.W mgv_object2_face14_color	
	DC.W mgv_object2_face14_lines_number-1 
; 15. face
	DC.L 0				; coordinates table
	DC.W mgv_object2_face15_color	
	DC.W mgv_object2_face15_lines_number-1 
; 16. face
	DC.L 0				; coordinates table
	DC.W mgv_object2_face16_color	
	DC.W mgv_object2_face16_lines_number-1 

; 17. face
	DC.L 0				; coordinates table
	DC.W mgv_object2_face17_color	
	DC.W mgv_object2_face17_lines_number-1 
; 18. face
	DC.L 0				; coordinates table
	DC.W mgv_object2_face18_color	
	DC.W mgv_object2_face18_lines_number-1 
; 19. face
	DC.L 0				; coordinates table
	DC.W mgv_object2_face19_color	
	DC.W mgv_object2_face19_lines_number-1 
; 20. face
	DC.L 0				; coordinates table
	DC.W mgv_object2_face20_color	
	DC.W mgv_object2_face20_lines_number-1 

; 21. face
	DC.L 0				; coordinates table
	DC.W mgv_object2_face21_color	
	DC.W mgv_object2_face21_lines_number-1 
; 22. face
	DC.L 0				; coordinates table
	DC.W mgv_object2_face22_color	
	DC.W mgv_object2_face22_lines_number-1 
; 23. face
	DC.L 0				; coordinates table
	DC.W mgv_object2_face23_color	
	DC.W mgv_object2_face23_lines_number-1 
; 24. face
	DC.L 0				; coordinates table
	DC.W mgv_object2_face24_color	
	DC.W mgv_object2_face24_lines_number-1 

	CNOP 0,2
mgv_objects_edges
; Object1
	DC.W 0*2,1*2,8*2,0*2		; face front, triangle 12 o'clock
	DC.W 1*2,2*2,8*2,1*2		; face front, triangle 3 o'clock
	DC.W 2*2,3*2,8*2,2*2		; face front, triangle 6 o'clock
	DC.W 3*2,0*2,8*2,3*2		; face front, triangle 9 o'clock

	DC.W 5*2,4*2,9*2,5*2		; face back, triangle 12 o'clock
	DC.W 4*2,7*2,9*2,4*2		; face back, triangle 3 o'clock
	DC.W 7*2,6*2,9*2,7*2		; face back, triangle 6 o'clock
	DC.W 6*2,5*2,9*2,6*2		; face back, triangle 9 o'clock

	DC.W 4*2,0*2,10*2,4*2		; face left, triangle 12 o'clock
	DC.W 0*2,3*2,10*2,0*2		; face left, triangle 3 o'clock
	DC.W 3*2,7*2,10*2,3*2		; face left, triangle 6 o'clock
	DC.W 7*2,4*2,10*2,7*2		; face left, triangle 9 o'clock

	DC.W 1*2,5*2,11*2,1*2		; face right, triangle 12 o'clock
	DC.W 5*2,6*2,11*2,5*2		; face right, triangle 3 o'clock
	DC.W 6*2,2*2,11*2,6*2		; face right, triangle 6 o'clock
	DC.W 2*2,1*2,11*2,2*2		; face right, triangle 9 o'clock

	DC.W 4*2,5*2,12*2,4*2		; face top, triangle 12 o'clock
	DC.W 5*2,1*2,12*2,5*2		; face top, triangle 3 o'clock
	DC.W 1*2,0*2,12*2,1*2		; face top, triangle 6 o'clock
	DC.W 0*2,4*2,12*2,0*2		; face top, triangle 9 o'clock

	DC.W 3*2,2*2,13*2,3*2		; face bottom, triangle 12 o'clock
	DC.W 2*2,6*2,13*2,2*2		; face bottom, triangle 3 o'clock
	DC.W 6*2,7*2,13*2,6*2		; face bottom, triangle 6 o'clock
	DC.W 7*2,3*2,13*2,7*2		; face bottom, triangle 9 o'clock

; Object2
	DC.W 14*2,15*2,22*2,14*2	; face front, triangle 12 o'clock
	DC.W 15*2,16*2,22*2,15*2	; face front, triangle 3 o'clock
	DC.W 16*2,17*2,22*2,16*2	; face front, triangle 6 o'clock
	DC.W 17*2,14*2,22*2,17*2	; face front, triangle 9 o'clock

	DC.W 19*2,18*2,23*2,19*2	; face back, triangle 12 o'clock
	DC.W 18*2,21*2,23*2,18*2	; face back, triangle 3 o'clock
	DC.W 21*2,20*2,23*2,21*2	; face back, triangle 6 o'clock
	DC.W 20*2,19*2,23*2,20*2	; face back, triangle 9 o'clock

	DC.W 18*2,14*2,24*2,18*2	; face left, triangle 12 o'clock
	DC.W 14*2,17*2,24*2,14*2	; face left, triangle 3 o'clock
	DC.W 17*2,21*2,24*2,17*2	; face left, triangle 6 o'clock
	DC.W 21*2,18*2,24*2,21*2	; face left, triangle 9 o'clock

	DC.W 15*2,19*2,25*2,15*2	; face right, triangle 12 o'clock
	DC.W 19*2,20*2,25*2,19*2	; face right, triangle 3 o'clock
	DC.W 20*2,16*2,25*2,20*2	; face right, triangle 6 o'clock
	DC.W 16*2,15*2,25*2,16*2	; face right, triangle 9 o'clock

	DC.W 18*2,19*2,26*2,18*2	; face top, triangle 12 o'clock
	DC.W 19*2,15*2,26*2,19*2	; face top, triangle 3 o'clock
	DC.W 15*2,14*2,26*2,15*2	; face top, triangle 6 o'clock
	DC.W 14*2,18*2,26*2,14*2	; face top, triangle 9 o'clock

	DC.W 17*2,16*2,27*2,17*2	; face bottom, triangle 12 o'clock
	DC.W 16*2,20*2,27*2,16*2	; face bottom, triangle 3 o'clock
	DC.W 20*2,21*2,27*2,20*2	; face bottom, triangle 6 o'clock
	DC.W 21*2,17*2,27*2,21*2	; face bottom, triangle 9 o'clock

	CNOP 0,4
mgv_rot_xy_coords
	DS.W mgv_objects_edge_points_number*2

	CNOP 0,4
mgv_morph_shapes_table
	DS.B morph_shape_size*mgv_morph_shapes_number


	INCLUDE "sys-variables.i"


	INCLUDE "sys-names.i"


	INCLUDE "error-texts.i"

	END
