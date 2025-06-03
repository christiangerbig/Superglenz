; Morphing 3x20 faces glenz on a 144x144 screen
; Copper waits for the blitter
; Beam posistion timing
; 64 kB aligned playfield


	MC68040


	XDEF start_016_morph_3xglenz_vectors

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
pf1_y_size1			EQU 144+391
pf1_depth1			EQU 7
pf1_x_size2			EQU 192
pf1_y_size2			EQU 144+391
pf1_depth2			EQU 7
pf1_x_size3			EQU 192
pf1_y_size3			EQU 144+391
pf1_depth3			EQU 7
pf1_colors_number		EQU 128

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
visible_pixels_number		EQU 144
visible_lines_number		EQU 144
MINROW				EQU VSTOP_OVERSCAN_PAL

pf_pixel_per_datafetch		EQU 64	; 4x

display_window_hstart		EQU HSTART_144_PIXEL
display_window_vstart		EQU MINROW
display_window_hstop		EQU HSTOP_144_pixel
display_window_vstop		EQU VSTOP_OVERSCAN_PAL

pf1_plane_width			EQU pf1_x_size3/8
data_fetch_width		EQU pixel_per_line/8
pf1_plane_moduli		EQU (pf1_plane_width*(pf1_depth3-1))+pf1_plane_width-data_fetch_width

diwstrt_bits			EQU ((display_window_vstart&$ff)*DIWSTRTF_V0)|(display_window_hstart&$ff)
diwstop_bits			EQU ((display_window_vstop&$ff)*DIWSTOPF_V0)|(display_window_hstop&$ff)
ddfstrt_bits			EQU DDFSTART_192_PIXEL_4X
ddfstop_bits			EQU DDFSTOP_192_PIXEL_4X
bplcon0_bits			EQU BPLCON0F_ECSENA|((pf_depth>>3)*BPLCON0F_BPU3)|(BPLCON0F_COLOR)|((pf_depth&$07)*BPLCON0F_BPU0)
bplcon1_bits			EQU $4488
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
mgv_x_angle_speed		EQU 2
mgv_y_angle_speed		EQU 3
mgv_z_angle_speed		EQU 3

mgv_object1_edge_points_number	EQU 12
mgv_object1_edge_points_face	EQU 3
mgv_object1_faces_number	EQU 20
mgv_object1_face1_color		EQU 4
mgv_object1_face1_lines_number	EQU 3
mgv_object1_face2_color		EQU 4
mgv_object1_face2_lines_number	EQU 3
mgv_object1_face3_color		EQU 2
mgv_object1_face3_lines_number	EQU 3
mgv_object1_face4_color		EQU 4
mgv_object1_face4_lines_number	EQU 3
mgv_object1_face5_color		EQU 2
mgv_object1_face5_lines_number	EQU 3
mgv_object1_face6_color		EQU 2
mgv_object1_face6_lines_number	EQU 3
mgv_object1_face7_color		EQU 4
mgv_object1_face7_lines_number	EQU 3
mgv_object1_face8_color		EQU 2
mgv_object1_face8_lines_number	EQU 3
mgv_object1_face9_color		EQU 4
mgv_object1_face9_lines_number	EQU 3
mgv_object1_face10_color	EQU 2
mgv_object1_face10_lines_number	EQU 3
mgv_object1_face11_color	EQU 4
mgv_object1_face11_lines_number	EQU 3
mgv_object1_face12_color	EQU 2
mgv_object1_face12_lines_number	EQU 3
mgv_object1_face13_color	EQU 2
mgv_object1_face13_lines_number	EQU 3
mgv_object1_face14_color	EQU 4
mgv_object1_face14_lines_number	EQU 3
mgv_object1_face15_color	EQU 2
mgv_object1_face15_lines_number	EQU 3
mgv_object1_face16_color	EQU 4
mgv_object1_face16_lines_number	EQU 3
mgv_object1_face17_color	EQU 2
mgv_object1_face17_lines_number	EQU 3
mgv_object1_face18_color	EQU 4
mgv_object1_face18_lines_number	EQU 3
mgv_object1_face19_color	EQU 2
mgv_object1_face19_lines_number	EQU 3
mgv_object1_face20_color	EQU 4
mgv_object1_face20_lines_number	EQU 3

mgv_object2_edge_points_number	EQU 12
mgv_object2_edge_points_face	EQU 3
mgv_object2_faces_number	EQU 20
mgv_object2_face1_color		EQU 16
mgv_object2_face1_lines_number	EQU 3
mgv_object2_face2_color		EQU 16
mgv_object2_face2_lines_number	EQU 3
mgv_object2_face3_color		EQU 8
mgv_object2_face3_lines_number	EQU 3
mgv_object2_face4_color		EQU 16
mgv_object2_face4_lines_number	EQU 3
mgv_object2_face5_color		EQU 8
mgv_object2_face5_lines_number	EQU 3
mgv_object2_face6_color		EQU 8
mgv_object2_face6_lines_number	EQU 3
mgv_object2_face7_color		EQU 16
mgv_object2_face7_lines_number	EQU 3
mgv_object2_face8_color		EQU 8
mgv_object2_face8_lines_number	EQU 3
mgv_object2_face9_color		EQU 16
mgv_object2_face9_lines_number	EQU 3
mgv_object2_face10_color	EQU 8
mgv_object2_face10_lines_number	EQU 3
mgv_object2_face11_color	EQU 16
mgv_object2_face11_lines_number	EQU 3
mgv_object2_face12_color	EQU 8
mgv_object2_face12_lines_number	EQU 3
mgv_object2_face13_color	EQU 8
mgv_object2_face13_lines_number	EQU 3
mgv_object2_face14_color	EQU 16
mgv_object2_face14_lines_number	EQU 3
mgv_object2_face15_color	EQU 8
mgv_object2_face15_lines_number	EQU 3
mgv_object2_face16_color	EQU 16
mgv_object2_face16_lines_number	EQU 3
mgv_object2_face17_color	EQU 8
mgv_object2_face17_lines_number	EQU 3
mgv_object2_face18_color	EQU 16
mgv_object2_face18_lines_number	EQU 3
mgv_object2_face19_color	EQU 8
mgv_object2_face19_lines_number	EQU 3
mgv_object2_face20_color	EQU 16
mgv_object2_face20_lines_number	EQU 3

mgv_object3_edge_points_number	EQU 12
mgv_object3_edge_points_face	EQU 3
mgv_object3_faces_number	EQU 20
mgv_object3_face1_color		EQU 64
mgv_object3_face1_lines_number	EQU 3
mgv_object3_face2_color		EQU 64
mgv_object3_face2_lines_number	EQU 3
mgv_object3_face3_color		EQU 32
mgv_object3_face3_lines_number	EQU 3
mgv_object3_face4_color		EQU 64
mgv_object3_face4_lines_number	EQU 3
mgv_object3_face5_color		EQU 32
mgv_object3_face5_lines_number	EQU 3
mgv_object3_face6_color		EQU 32
mgv_object3_face6_lines_number	EQU 3
mgv_object3_face7_color		EQU 64
mgv_object3_face7_lines_number	EQU 3
mgv_object3_face8_color		EQU 32
mgv_object3_face8_lines_number	EQU 3
mgv_object3_face9_color		EQU 64
mgv_object3_face9_lines_number	EQU 3
mgv_object3_face10_color	EQU 32
mgv_object3_face10_lines_number	EQU 3
mgv_object3_face11_color	EQU 64
mgv_object3_face11_lines_number	EQU 3
mgv_object3_face12_color	EQU 32
mgv_object3_face12_lines_number	EQU 3
mgv_object3_face13_color	EQU 32
mgv_object3_face13_lines_number	EQU 3
mgv_object3_face14_color	EQU 64
mgv_object3_face14_lines_number	EQU 3
mgv_object3_face15_color	EQU 32
mgv_object3_face15_lines_number	EQU 3
mgv_object3_face16_color	EQU 64
mgv_object3_face16_lines_number	EQU 3
mgv_object3_face17_color	EQU 32
mgv_object3_face17_lines_number	EQU 3
mgv_object3_face18_color	EQU 64
mgv_object3_face18_lines_number	EQU 3
mgv_object3_face19_color	EQU 32
mgv_object3_face19_lines_number	EQU 3
mgv_object3_face20_color	EQU 64
mgv_object3_face20_lines_number	EQU 3

mgv_objects_number		EQU 3
mgv_objects_edge_points_number	EQU mgv_object1_edge_points_number+mgv_object2_edge_points_number+mgv_object3_edge_points_number
mgv_objects_faces_number	EQU mgv_object1_faces_number+mgv_object2_faces_number+mgv_object3_faces_number

mgv_lines_number_max		EQU 162

mgv_morph_shapes_number		EQU 7
mgv_morph_speed			EQU 8

mgv_object1_shape1_x_speed	EQU 0
mgv_object1_shape1_y_speed	EQU 0
mgv_object1_shape1_z_speed	EQU 0
mgv_object2_shape1_x_speed	EQU 0
mgv_object2_shape1_y_speed	EQU 0
mgv_object2_shape1_z_speed	EQU 0
mgv_object3_shape1_x_speed	EQU 0
mgv_object3_shape1_y_speed	EQU 0
mgv_object3_shape1_z_speed	EQU 0

mgv_object1_shape2_x_speed	EQU 0
mgv_object1_shape2_y_speed	EQU 0
mgv_object1_shape2_z_speed	EQU 0
mgv_object2_shape2_x_speed	EQU 0
mgv_object2_shape2_y_speed	EQU 0
mgv_object2_shape2_z_speed	EQU 0
mgv_object3_shape2_x_speed	EQU 0
mgv_object3_shape2_y_speed	EQU 0
mgv_object3_shape2_z_speed	EQU 0

mgv_object1_shape3_x_speed	EQU 0
mgv_object1_shape3_y_speed	EQU 0
mgv_object1_shape3_z_speed	EQU 0
mgv_object2_shape3_x_speed	EQU 0
mgv_object2_shape3_y_speed	EQU 0
mgv_object2_shape3_z_speed	EQU 0
mgv_object3_shape3_x_speed	EQU 0
mgv_object3_shape3_y_speed	EQU 0
mgv_object3_shape3_z_speed	EQU 0

mgv_object1_shape4_x_speed	EQU 0
mgv_object1_shape4_y_speed	EQU 0
mgv_object1_shape4_z_speed	EQU 0
mgv_object2_shape4_x_speed	EQU 0
mgv_object2_shape4_y_speed	EQU 0
mgv_object2_shape4_z_speed	EQU 0
mgv_object3_shape4_x_speed	EQU 0
mgv_object3_shape4_y_speed	EQU 0
mgv_object3_shape4_z_speed	EQU 0

mgv_object1_shape5_x_speed	EQU 0
mgv_object1_shape5_y_speed	EQU -5
mgv_object1_shape5_z_speed	EQU 0
mgv_object2_shape5_x_speed	EQU 0
mgv_object2_shape5_y_speed	EQU -6
mgv_object2_shape5_z_speed	EQU 0
mgv_object3_shape5_x_speed	EQU 0
mgv_object3_shape5_y_speed	EQU -7
mgv_object3_shape5_z_speed	EQU 0

mgv_object1_shape6_x_speed	EQU 0
mgv_object1_shape6_y_speed	EQU 0
mgv_object1_shape6_z_speed	EQU -4
mgv_object2_shape6_x_speed	EQU 0
mgv_object2_shape6_y_speed	EQU 0
mgv_object2_shape6_z_speed	EQU 4
mgv_object3_shape6_x_speed	EQU 0
mgv_object3_shape6_y_speed	EQU 0
mgv_object3_shape6_z_speed	EQU -4

; Fill-Blit
mgv_fill_blit_x_size		EQU visible_pixels_number
mgv_fill_blit_y_size		EQU visible_lines_number
mgv_fill_blit_depth		EQU pf1_depth3

; Scroll-Playfield-Bottom
spb_min_vstart			EQU VSTART_144_LINES
spb_max_vstop			EQU VSTOP_OVERSCAN_PAL
spb_y_radius			EQU spb_max_vstop-spb_min_vstart
spb_y_centre			EQU spb_max_vstop-spb_min_vstart

; Scroll-Playfield-Bottom-In
spbi_y_angle_speed		EQU 2

; Scroll-Playfield-Bottom-Out
spbo_y_angle_speed		EQU 2

; Effects-Handler
eh_trigger_number_max		EQU 8


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
morph_shape_object3_edges	RS.L 1
morph_shape_object1_x_speed	RS.W 1
morph_shape_object1_y_speed	RS.W 1
morph_shape_object1_z_speed	RS.W 1
morph_shape_object2_x_speed	RS.W 1
morph_shape_object2_y_speed	RS.W 1
morph_shape_object2_z_speed	RS.W 1
morph_shape_object3_x_speed	RS.W 1
morph_shape_object3_y_speed	RS.W 1
morph_shape_object3_z_speed	RS.W 1

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

mgv_prerotation_active		RS.W 1

mgv_object1_x_prerotation_angle	RS.W 1
mgv_object1_y_prerotation_angle	RS.W 1
mgv_object1_z_prerotation_angle	RS.W 1

mgv_object2_x_prerotation_angle	RS.W 1
mgv_object2_y_prerotation_angle	RS.W 1
mgv_object2_z_prerotation_angle	RS.W 1

mgv_object3_x_prerotation_angle	RS.W 1
mgv_object3_y_prerotation_angle	RS.W 1
mgv_object3_z_prerotation_angle	RS.W 1

mgv_object1_x_prerotation_speed	RS.W 1
mgv_object1_y_prerotation_speed	RS.W 1
mgv_object1_z_prerotation_speed	RS.W 1

mgv_object2_x_prerotation_speed	RS.W 1
mgv_object2_y_prerotation_speed	RS.W 1
mgv_object2_z_prerotation_speed	RS.W 1

mgv_object3_x_prerotation_speed	RS.W 1
mgv_object3_y_prerotation_speed	RS.W 1
mgv_object3_z_prerotation_speed	RS.W 1

mgv_lines_counter		RS.W 1

mgv_morph_active		RS.W 1
mgv_morph_shapes_table_start	RS.W 1

; Scroll-Playfield-Bottom-In
spbi_active			RS.W 1
spbi_y_angle			RS.W 1

; Scroll-Playfield-Bottom-out
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


start_016_morph_3xglenz_vectors


	INCLUDE "sys-wrapper.i"


	CNOP 0,4
init_main_variables

; Morph-Glenz-Vectors
	moveq	#TRUE,d0
	move.w	d0,mgv_x_angle(a3)
	move.w	d0,mgv_y_angle(a3)
	move.w	d0,mgv_z_angle(a3)

	moveq	#FALSE,d1
	move.w	d1,mgv_prerotation_active(a3)

	move.w	d0,mgv_object1_x_prerotation_angle(a3)
	move.w	d0,mgv_object1_y_prerotation_angle(a3)
	move.w	d0,mgv_object1_z_prerotation_angle(a3)

	move.w	d0,mgv_object2_x_prerotation_angle(a3)
	move.w	d0,mgv_object2_y_prerotation_angle(a3)
	move.w	d0,mgv_object2_z_prerotation_angle(a3)

	move.w	d0,mgv_object3_x_prerotation_angle(a3)
	move.w	d0,mgv_object3_y_prerotation_angle(a3)
	move.w	d0,mgv_object3_z_prerotation_angle(a3)

	move.w	d0,mgv_object1_x_prerotation_speed(a3)
	move.w	d0,mgv_object1_y_prerotation_speed(a3)
	move.w	d0,mgv_object1_z_prerotation_speed(a3)

	move.w	d0,mgv_object2_x_prerotation_speed(a3)
	move.w	d0,mgv_object2_y_prerotation_speed(a3)
	move.w	d0,mgv_object2_z_prerotation_speed(a3)

	move.w	d0,mgv_object3_x_prerotation_speed(a3)
	move.w	d0,mgv_object3_y_prerotation_speed(a3)
	move.w	d0,mgv_object3_z_prerotation_speed(a3)

	move.w	d0,mgv_lines_counter(a3)

	IFEQ mgv_premorph_enabled
		move.w	d0,mgv_morph_active(a3)
	ELSE
		move.w	d1,mgv_morph_active(a3)
	ENDC
	move.w	d0,mgv_morph_shapes_table_start(a3)

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
	bsr	mgv_init_morph_shapes
	IFEQ mgv_premorph_enabled
		bsr	mgv_init_start_shape
	ENDC
	bsr	mgv_init_color_table
	bsr	spb_init_display_window
	bra	init_second_copperlist


; Morph-Glenz-Vectors
	CNOP 0,4
mgv_init_objects_info
	lea	mgv_objects_info+object_info_edges(pc),a0
	lea	mgv_objects_edges(pc),a1
	move.w	#object_info_size,a2
	moveq	#mgv_object1_faces_number-1,d7
	bsr.s	mgv_init_objects_info_loop
	moveq	#mgv_object2_faces_number-1,d7
	bsr.s	mgv_init_objects_info_loop
	moveq	#mgv_object3_faces_number-1,d7
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
	lea	(a1,d0.w*2),a1		; next edge table
	add.l	a2,a0			; object info structure of next face
	dbf	d7,mgv_init_objects_info_loop
	rts

	CNOP 0,4
mgv_init_morph_shapes
	lea	mgv_morph_shapes(pc),a0
; Shape 1
	lea	mgv_object1_shape1_coords(pc),a1
	move.l	a1,(a0)+
	lea	mgv_object2_shape1_coords(pc),a1
	move.l	a1,(a0)+
	lea	mgv_object3_shape1_coords(pc),a1
	move.l	a1,(a0)+
	move.w	#mgv_object1_shape1_x_speed,(a0)+
	move.w	#mgv_object1_shape1_y_speed,(a0)+
	move.w	#mgv_object1_shape1_z_speed,(a0)+
	move.w	#mgv_object2_shape1_x_speed,(a0)+
	move.w	#mgv_object2_shape1_y_speed,(a0)+
	move.w	#mgv_object2_shape1_z_speed,(a0)+
	move.w	#mgv_object3_shape1_x_speed,(a0)+
	move.w	#mgv_object3_shape1_y_speed,(a0)+
	move.w	#mgv_object3_shape1_z_speed,(a0)+
; Shape 2
	lea	mgv_object1_shape2_coords(pc),a1
	move.l	a1,(a0)+
	lea	mgv_object2_shape2_coords(pc),a1
	move.l	a1,(a0)+
	lea	mgv_object3_shape2_coords(pc),a1
	move.l	a1,(a0)+
	move.w	#mgv_object1_shape2_x_speed,(a0)+
	move.w	#mgv_object1_shape2_y_speed,(a0)+
	move.w	#mgv_object1_shape2_z_speed,(a0)+
	move.w	#mgv_object2_shape2_x_speed,(a0)+
	move.w	#mgv_object2_shape2_y_speed,(a0)+
	move.w	#mgv_object2_shape2_z_speed,(a0)+
	move.w	#mgv_object3_shape2_x_speed,(a0)+
	move.w	#mgv_object3_shape2_y_speed,(a0)+
	move.w	#mgv_object3_shape2_z_speed,(a0)+
; Shape 3
	lea	mgv_object1_shape3_coords(pc),a1
	move.l	a1,(a0)+
	lea	mgv_object2_shape3_coords(pc),a1
	move.l	a1,(a0)+
	lea	mgv_object3_shape3_coords(pc),a1
	move.l	a1,(a0)+
	move.w	#mgv_object1_shape3_x_speed,(a0)+
	move.w	#mgv_object1_shape3_y_speed,(a0)+
	move.w	#mgv_object1_shape3_z_speed,(a0)+
	move.w	#mgv_object2_shape3_x_speed,(a0)+
	move.w	#mgv_object2_shape3_y_speed,(a0)+
	move.w	#mgv_object2_shape3_z_speed,(a0)+
	move.w	#mgv_object3_shape3_x_speed,(a0)+
	move.w	#mgv_object3_shape3_y_speed,(a0)+
	move.w	#mgv_object3_shape3_z_speed,(a0)+
; Shape 4
	lea	mgv_object1_shape4_coords(pc),a1
	move.l	a1,(a0)+
	lea	mgv_object2_shape4_coords(pc),a1
	move.l	a1,(a0)+
	lea	mgv_object3_shape4_coords(pc),a1
	move.l	a1,(a0)+
	move.w	#mgv_object1_shape4_x_speed,(a0)+
	move.w	#mgv_object1_shape4_y_speed,(a0)+
	move.w	#mgv_object1_shape4_z_speed,(a0)+
	move.w	#mgv_object2_shape4_x_speed,(a0)+
	move.w	#mgv_object2_shape4_y_speed,(a0)+
	move.w	#mgv_object2_shape4_z_speed,(a0)+
	move.w	#mgv_object3_shape4_x_speed,(a0)+
	move.w	#mgv_object3_shape4_y_speed,(a0)+
	move.w	#mgv_object3_shape4_z_speed,(a0)+
; Shape 5
	lea	mgv_object1_shape5_coords(pc),a1
	move.l	a1,(a0)+
	lea	mgv_object2_shape5_coords(pc),a1
	move.l	a1,(a0)+
	lea	mgv_object3_shape5_coords(pc),a1
	move.l	a1,(a0)+
	move.w	#mgv_object1_shape5_x_speed,(a0)+
	move.w	#mgv_object1_shape5_y_speed,(a0)+
	move.w	#mgv_object1_shape5_z_speed,(a0)+
	move.w	#mgv_object2_shape5_x_speed,(a0)+
	move.w	#mgv_object2_shape5_y_speed,(a0)+
	move.w	#mgv_object2_shape5_z_speed,(a0)+
	move.w	#mgv_object3_shape5_x_speed,(a0)+
	move.w	#mgv_object3_shape5_y_speed,(a0)+
	move.w	#mgv_object3_shape5_z_speed,(a0)+
; Shape 6
	lea	mgv_object1_shape6_coords(pc),a1
	move.l	a1,(a0)+
	lea	mgv_object2_shape6_coords(pc),a1
	move.l	a1,(a0)+
	lea	mgv_object3_shape6_coords(pc),a1
	move.l	a1,(a0)+
	move.w	#mgv_object1_shape6_x_speed,(a0)+
	move.w	#mgv_object1_shape6_y_speed,(a0)+
	move.w	#mgv_object1_shape6_z_speed,(a0)+
	move.w	#mgv_object2_shape6_x_speed,(a0)+
	move.w	#mgv_object2_shape6_y_speed,(a0)+
	move.w	#mgv_object2_shape6_z_speed,(a0)+
	move.w	#mgv_object3_shape6_x_speed,(a0)+
	move.w	#mgv_object3_shape6_y_speed,(a0)+
	move.w	#mgv_object3_shape6_z_speed,(a0)
	rts

	IFEQ mgv_premorph_enabled
		CNOP 0,4
mgv_init_start_shape
		bsr	mgv_morph_objects
		tst.w	mgv_morph_active(a3) ; morphing fnished ?
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
	move.l	(a1)+,17*LONGWORD_SIZE(a0) ; COLOR17
; Pure colors 3rd glenz
	move.l	(a1)+,32*LONGWORD_SIZE(a0) ; COLOR32
	move.l	(a1)+,33*LONGWORD_SIZE(a0) ; COLOR33
	move.l	(a1)+,64*LONGWORD_SIZE(a0) ; COLOR64
	move.l	(a1),65*LONGWORD_SIZE(a0) ; COLOR65
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
	bsr	mgv_get_colorvalues_average
; Mixed colors 1st and 3rd glenz
	moveq	#2,d6			; COLOR02
	moveq	#32,d7			; COLOR32
	bsr	mgv_get_colorvalues_average
	moveq	#2,d6			; COLOR02
	moveq	#33,d7			; COLOR33
	bsr	mgv_get_colorvalues_average
	moveq	#2,d6			; COLOR02
	moveq	#64,d7			; COLOR64
	bsr	mgv_get_colorvalues_average
	moveq	#2,d6			; COLOR02
	moveq	#65,d7			; COLOR65
	bsr	mgv_get_colorvalues_average
	moveq	#3,d6			; COLOR03
	moveq	#33,d7			; COLOR33
	bsr	mgv_get_colorvalues_average
	moveq	#3,d6			; COLOR03
	moveq	#65,d7			; COLOR65
	bsr	mgv_get_colorvalues_average
	moveq	#4,d6			; COLOR04
	moveq	#33,d7			; COLOR33
	bsr	mgv_get_colorvalues_average
	moveq	#4,d6			; COLOR04
	moveq	#65,d7			; COLOR65
	bsr	mgv_get_colorvalues_average
	moveq	#5,d6			; COLOR05
	moveq	#33,d7			; COLOR33
	bsr	mgv_get_colorvalues_average
	moveq	#5,d6			; COLOR05
	moveq	#65,d7			; COLOR65
	bsr	mgv_get_colorvalues_average
; Mixes colors 2nd and 3rd glenz
	moveq	#08,d6			; COLOR08
	moveq	#32,d7			; COLOR32
	bsr	mgv_get_colorvalues_average
	moveq	#08,d6			; COLOR08
	moveq	#33,d7			; COLOR33
	bsr	mgv_get_colorvalues_average
	moveq	#08,d6			; COLOR08
	moveq	#64,d7			; COLOR64
	bsr	mgv_get_colorvalues_average
	moveq	#08,d6			; COLOR08
	moveq	#65,d7			; COLOR65
	bsr	mgv_get_colorvalues_average
	moveq	#09,d6			; COLOR09
	moveq	#65,d7			; COLOR65
	bsr	mgv_get_colorvalues_average
	moveq	#16,d6			; COLOR16
	moveq	#32,d7			; COLOR32
	bsr	mgv_get_colorvalues_average
	moveq	#16,d6			; COLOR16
	moveq	#33,d7			; COLOR33
	bsr	mgv_get_colorvalues_average
	moveq	#16,d6			; COLOR16
	moveq	#64,d7			; COLOR64
	bsr	mgv_get_colorvalues_average
	moveq	#16,d6			; COLOR16
	moveq	#65,d7			; COLOR65
	bsr	mgv_get_colorvalues_average
	moveq	#17,d6			; COLOR17
	moveq	#33,d7			; COLOR33
	bsr	mgv_get_colorvalues_average
	moveq	#17,d6			; COLOR17
	moveq	#65,d7			; COLOR65
	bsr	mgv_get_colorvalues_average
; Mixed colors 1st, 2nd and 3rd glenz
	moveq	#32,d6			; COLOR32
	moveq	#10,d7			; COLOR10
	bsr	mgv_get_colorvalues_average
	moveq	#32,d6			; COLOR32
	moveq	#11,d7			; COLOR11
	bsr	mgv_get_colorvalues_average
	moveq	#32,d6			; COLOR32
	moveq	#12,d7			; COLOR12
	bsr	mgv_get_colorvalues_average
	moveq	#32,d6			; COLOR32
	moveq	#13,d7			; COLOR13
	bsr	mgv_get_colorvalues_average
	moveq	#32,d6			; COLOR32
	moveq	#14,d7			; COLOR13
	bsr	mgv_get_colorvalues_average
	moveq	#32,d6			; COLOR32
	moveq	#19,d7			; COLOR19
	bsr	mgv_get_colorvalues_average
	moveq	#32,d6			; COLOR32
	moveq	#20,d7			; COLOR20
	bsr	mgv_get_colorvalues_average
	moveq	#32,d6			; COLOR32
	moveq	#21,d7			; COLOR21
	bsr	mgv_get_colorvalues_average
	moveq	#32,d6			; COLOR32
	moveq	#22,d7			; COLOR21
	bsr	mgv_get_colorvalues_average

	moveq	#32,d6			; COLOR32
	moveq	#24,d7			; COLOR24
	bsr	mgv_get_colorvalues_average
	moveq	#32,d6			; COLOR32
	moveq	#25,d7			; COLOR25
	bsr	mgv_get_colorvalues_average
	moveq	#32,d6			; COLOR32
	moveq	#26,d7			; COLOR26
	bsr	mgv_get_colorvalues_average
	moveq	#32,d6			; COLOR32
	moveq	#27,d7			; COLOR27
	bsr	mgv_get_colorvalues_average
	moveq	#32,d6			; COLOR32
	moveq	#28,d7			; COLOR28
	bsr	mgv_get_colorvalues_average
	moveq	#32,d6			; COLOR32
	moveq	#29,d7			; COLOR29
	bsr	mgv_get_colorvalues_average
	moveq	#32,d6			; COLOR32
	moveq	#30,d7			; COLOR30
	bsr	mgv_get_colorvalues_average

	moveq	#64,d6			; COLOR64
	moveq	#11,d7			; COLOR11
	bsr	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#12,d7			; COLOR12
	bsr	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#13,d7			; COLOR13
	bsr	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#14,d7			; COLOR13
	bsr	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#19,d7			; COLOR19
	bsr	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#20,d7			; COLOR20
	bsr	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#21,d7			; COLOR21
	bsr	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#22,d7			; COLOR22
	bsr	mgv_get_colorvalues_average

	moveq	#64,d6			; COLOR64
	moveq	#24,d7			; COLOR24
	bsr	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#25,d7			; COLOR25
	bsr	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#26,d7			; COLOR26
	bsr	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#27,d7			; COLOR27
	bsr	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#28,d7			; COLOR28
	bsr	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#29,d7			; COLOR29
	bsr	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#30,d7			; COLOR30
	bsr	mgv_get_colorvalues_average

	moveq	#64,d6			; COLOR64
	moveq	#32,d7			; COLOR32
	bsr	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#33,d7			; COLOR33
	bsr	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#34,d7			; COLOR34
	bsr	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#35,d7			; COLOR35
	bsr	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#36,d7			; COLOR36
	bsr	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#37,d7			; COLOR37
	bsr	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#38,d7			; COLOR38
	bsr	mgv_get_colorvalues_average

	moveq	#64,d6			; COLOR64
	moveq	#40,d7			; COLOR40
	bsr.s	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#41,d7			; COLOR41
	bsr.s	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#42,d7			; COLOR42
	bsr.s	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#43,d7			; COLOR43
	bsr.s	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#44,d7			; COLOR44
	bsr.s	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#45,d7			; COLOR45
	bsr.s	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#46,d7			; COLOR46
	bsr.s	mgv_get_colorvalues_average

	moveq	#64,d6			; COLOR64
	moveq	#48,d7			; COLOR48
	bsr.s	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#49,d7			; COLOR49
	bsr.s	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#50,d7			; COLOR50
	bsr.s	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#51,d7			; COLOR51
	bsr.s	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#52,d7			; COLOR52
	bsr.s	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#53,d7			; COLOR53
	bsr.s	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#54,d7			; COLOR54
	bsr.s	mgv_get_colorvalues_average

	moveq	#64,d6			; COLOR64
	moveq	#56,d7			; COLOR56
	bsr.s	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#57,d7			; COLOR57
	bsr.s	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#58,d7			; COLOR58
	bsr.s	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#59,d7			; COLOR59
	bsr.s	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#60,d7			; COLOR60
	bsr.s	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#61,d7			; COLOR61
	bsr.s	mgv_get_colorvalues_average
	moveq	#64,d6			; COLOR64
	moveq	#62,d7			; COLOR62
	bsr.s	mgv_get_colorvalues_average
	rts

; Input
; d6.w	1st source color number
; d7.w	2nd source color number
; a0.l	Pointer	color table
	CNOP 0,4
mgv_get_colorvalues_average
; Result
	moveq	#0,d0
	move.b	1(a0,d6.w*4),d0		; 1st source color red
	moveq	#0,d1
	move.b	2(a0,d6.w*4),d1		; 1st source color green
	moveq	#0,d2
	move.b	3(a0,d6.w*4),d2		; 1st source color blue
	moveq	#0,d3
	move.b	1(a0,d7.w*4),d3		; 2nd source color red
	moveq	#0,d4
	move.b	2(a0,d7.w*4),d4		; 2nd source color green
	moveq	#0,d5
	move.b	3(a0,d7.w*4),d5		; 2nd source color blue
	add.w	d7,d6
	add.w	d3,d0
	lsr.w	#1,d0
	move.b	d0,1(a0,d6.w*4)		; mixed red
	add.w	d4,d1
	lsr.w	#1,d1
	move.b	d1,2(a0,d6.w*4)		; mixed green
	add.w	d5,d2
	lsr.w	#1,d2
	move.b	d2,3(a0,d6.w*4)		; mixed blue
	rts


	CNOP 0,4
spb_init_display_window
	move.w	#diwstrt_bits,DIWSTRT-DMACONR(a6)
	move.w	#diwstop_bits,DIWSTOP-DMACONR(a6)
	move.w	#diwhigh_bits,DIWHIGH-DMACONR(a6) ; OS3.x LoadView() sets DIWHIGH=$0000 setzt -> display glitches
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
	COP_INIT_COLOR_HIGH COLOR00,32,pf1_rgb8_color_table
	COP_SELECT_COLOR_HIGH_BANK 1,v_bplcon3_bits1
	COP_INIT_COLOR_HIGH COLOR00,32
	COP_SELECT_COLOR_HIGH_BANK 2,v_bplcon3_bits1
	COP_INIT_COLOR_HIGH COLOR00,32
	COP_SELECT_COLOR_HIGH_BANK 3,v_bplcon3_bits1
	COP_INIT_COLOR_HIGH COLOR00,32

	COP_SELECT_COLOR_LOW_BANK 0,v_bplcon3_bits2
	COP_INIT_COLOR_LOW COLOR00,32,pf1_rgb8_color_table
	COP_SELECT_COLOR_LOW_BANK 1,v_bplcon3_bits2
	COP_INIT_COLOR_LOW COLOR00,32
	COP_SELECT_COLOR_LOW_BANK 2,v_bplcon3_bits2
	COP_INIT_COLOR_LOW COLOR00,32
	COP_SELECT_COLOR_LOW_BANK 3,v_bplcon3_bits2
	COP_INIT_COLOR_LOW COLOR00,32
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
	bsr     effects_handler
	bsr	mgv_clear_playfield1
	bsr	mgv_prerotation_objects
	bsr	mgv_objects_rotation
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
	moveq	#7-1,d7			; number of runs
mgv_clear_playfield1_loop
	REPT ((pf1_plane_width*visible_lines_number*pf1_depth3)/56)/7
		movem.l d0-d6/a0-a6,-(a7) ; clear 56 bytes
	ENDR
	dbf	d7,mgv_clear_playfield1_loop
	movem.l d0-d6/a0-a6,-(a7)	; clear remaining 280 bytes
	movem.l d0-d6/a0-a6,-(a7)
	movem.l d0-d6/a0-a6,-(a7)
	movem.l d0-d6/a0-a6,-(a7)
	movem.l d0-d6/a0-a6,-(a7)
	move.l	variables+save_a7(pc),a7
	movem.l (a7)+,a3-a6
	rts


	CNOP 0,4
mgv_prerotation_objects
	movem.l a4-a6,-(a7)
	tst.w	mgv_prerotation_active(a3)
	bne.s	mgv_prerotation_objects_quit
	moveq	#0,d0
	move.w	mgv_morph_shapes_table_start(a3),d0
	subq.w	#1,d0
	MULUF.W morph_shape_size,d0,d1	; offset in morph shapes table
	lea	mgv_morph_shapes(pc),a4
	add.l	d0,a4
; Objekt 1
	move.l	(a4)+,a0		; object coordinates table
	lea	mgv_object1_coords(pc),a1
	lea	mgv_object1_x_prerotation_angle(a3),a5
	lea	mgv_object1_x_prerotation_speed(a3),a6
	moveq	#mgv_object1_edge_points_number-1,d7
	bsr.s	mgv_prerotation
; Objekt 2
	move.l	(a4)+,a0		; object coordinates table
	lea	mgv_object2_coords(pc),a1
	lea	mgv_object2_x_prerotation_angle(a3),a5
	lea	mgv_object2_x_prerotation_speed(a3),a6
	moveq	#mgv_object2_edge_points_number-1,d7
	bsr.s	mgv_prerotation
; Objekt 3
	move.l	(a4),a0			; object coordinates table
	lea	mgv_object3_coords(pc),a1
	lea	mgv_object3_x_prerotation_angle(a3),a5
	lea	mgv_object3_x_prerotation_speed(a3),a6
	moveq	#mgv_object3_edge_points_number-1,d7
	bsr.s	mgv_prerotation
mgv_prerotation_objects_quit
	movem.l (a7)+,a4-a6
	rts


; Input
; d7.w	number of points
; a0.l	Pointer	object coordinates table
; a1.l	Pointer	destination coordinates table
; a5.l	Pointer	variable x_angle
; a6.l	Pointer	variable x_speed
; Result
	CNOP 0,4
mgv_prerotation
	move.w	(a5),d1			; x angle
	move.w	d1,d0		
	lea	sine_table,a2	
	move.w	(a2,d0.w*2),d4		; sin(a)
	MOVEF.W sine_table_length-1,d3
	add.w	#sine_table_length/4,d0	; + 90°
	swap	d4 			; high word: sin(a)
	and.w	d3,d0			; remove overflow
	move.w	(a2,d0.w*2),d4	 	; low word: cos(a)
	add.w	(a6)+,d1		; next x angle
	and.w	d3,d1			; remove overflow
	move.w	d1,(a5)+		
	move.w	(a5),d1			; y angle
	move.w	d1,d0		
	move.w	(a2,d0.w*2),d5		; sin(b)
	add.w	#sine_table_length/4,d0 ; + 90°
	swap	d5 			; high word: sin(b)
	and.w	d3,d0			; remove overflow
	move.w	(a2,d0.w*2),d5	 	; low word: cos(b)
	add.w	(a6)+,d1		; next y angle
	and.w	d3,d1			; remove overflow
	move.w	d1,(a5)+		
	move.w	(a5),d1			; z angle
	move.w	d1,d0		
	move.w	(a2,d0.w*2),d6	;sin(c)
	add.w	#sine_table_length/4,d0	; + 90°
	swap	d6 			; high word: sin(c)
	and.w	d3,d0			; remove overflow
	move.w	(a2,d0.w*2),d6	 	; low word: cos(c)
	add.w	(a6),d1			; next z angle
	and.w	d3,d1			; remove overflow
	move.w	d1,(a5)		
mgv_prerotation_loop
	move.w	(a0)+,d0		; x
	move.l	d7,a2		
	move.w	(a0)+,d1		; y
	move.w	(a0)+,d2		; z
	ROTATE_X_AXIS
	ROTATE_Y_AXIS
	ROTATE_Z_AXIS
	moveq	#-8,d3			; only values which are a multiple of 8
	and.b	d3,d0			; clear bits 0..2
	move.w	d0,(a1)+		; x position
	and.b	d3,d1
	move.w	d1,(a1)+		; y position
	and.b	d3,d2
	move.l	a2,d7			; loop counter
	move.w	d2,(a1)+		; z position
	dbf	d7,mgv_prerotation_loop
	rts


	CNOP 0,4
mgv_objects_rotation
	movem.l a4-a5,-(a7)
	move.w	mgv_x_angle(a3),d1
	move.w	d1,d0		
	lea	sine_table,a2	
	move.w	(a2,d0.w*2),d4		; sin(a)
	move.w	#sine_table_length/4,a4
	MOVEF.W sine_table_length-1,d3
	add.w	a4,d0			; + 90°
	swap	d4 			; high word: sin(a)
	and.w	d3,d0			; remove overflow
	move.w	(a2,d0.w*2),d4	 	; low word: cos(a)
	addq.w	#mgv_x_angle_speed,d1
	and.w	d3,d1			; remove overflow
	move.w	d1,mgv_x_angle(a3) 
	move.w	mgv_y_angle(a3),d1
	move.w	d1,d0		
	move.w	(a2,d0.w*2),d5		; sin(b)
	add.w	a4,d0			; + 90°
	swap	d5 			; high word: sin(b)
	and.w	d3,d0			; remove overflow
	move.w	(a2,d0.w*2),d5	 	; low word: cos(b)
	addq.w	#mgv_y_angle_speed,d1
	and.w	d3,d1			; remove overflow
	move.w	d1,mgv_y_angle(a3) 
	move.w	mgv_z_angle(a3),d1
	move.w	d1,d0		
	move.w	(a2,d0.w*2),d6		; sin(c)
	add.w	a4,d0			; + 90°
	swap	d6 			; high word: sin(c)
	and.w	d3,d0			; remove overflow
	move.w	(a2,d0.w*2),d6		; low word: cos(c)
	addq.w	#mgv_z_angle_speed,d1
	and.w	d3,d1			; remove overflow
	move.w	d1,mgv_z_angle(a3) 
; Object 1
	lea	mgv_object1_coords(pc),a0
	lea	mgv_xy_coords(pc),a1
	moveq	#mgv_object1_edge_points_number-1,d7
	bsr.s	mgv_rotation
; Object 2
	lea	mgv_object2_coords(pc),a0
	moveq	#mgv_object2_edge_points_number-1,d7
	bsr.s	mgv_rotation
; Object 3
	lea	mgv_object3_coords(pc),a0
	moveq	#mgv_object3_edge_points_number-1,d7
	bsr.s	mgv_rotation
	movem.l (a7)+,a4-a5
	rts


	CNOP 0,4
mgv_rotation
	move.w	#mgv_distance*8,a4
	move.w	#mgv_xy_center,a5
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
	add.w	a5,d0			; x' + x enter
	move.w	d0,(a1)+		; x position
	divs.w	d2,d1			; y' = (y*d)/(z+d)
	move.l	a2,d7			; loop counter
	add.w	a5,d1			; y' + y center
	move.w	d1,(a1)+		; y position
	dbf	d7,mgv_rotation_loop
	rts


	CNOP 0,4
mgv_morph_objects
	tst.w	mgv_morph_active(a3)
	bne	mgv_morph_objects_quit
	move.w	mgv_morph_shapes_table_start(a3),d1
	cmp.w	#mgv_morph_shapes_number,d1 ; end of table ?
	beq	mgv_morph_objects_skip2
	moveq	#0,d3
	move.w	d1,d3			; start
	MULUF.W morph_shape_size,d3,d0,d2
	moveq	#0,d2			; coordinates counter
	lea	mgv_morph_shapes(pc),a2
	add.l	d3,a2			; offset in morph shapes table
	lea	mgv_object1_coords(pc),a0
	move.l	(a2)+,a1		; morph shapes table
	MOVEF.W (mgv_object1_edge_points_number*3)-1,d7
	bsr.s	mgv_morph_objects_loop
	lea	mgv_object2_coords(pc),a0
	move.l	(a2)+,a1		; morph shapes table
	MOVEF.W (mgv_object2_edge_points_number*3)-1,d7
	bsr.s	mgv_morph_objects_loop
	lea	mgv_object3_coords(pc),a0
	move.l	(a2)+,a1		; morph shapes table
	moveq	#(mgv_object3_edge_points_number*3)-1,d7
	bsr.s	mgv_morph_objects_loop
	tst.w	d2			; morphing finished ?
	bne.s	mgv_morph_objects_quit
	addq.w	#1,d1			; next entry in object table
	move.w	d1,mgv_morph_shapes_table_start(a3) 
	move.w	(a2)+,mgv_object1_x_prerotation_speed(a3)
	move.w	(a2)+,mgv_object1_y_prerotation_speed(a3)
	move.w	(a2)+,mgv_object1_z_prerotation_speed(a3)
	move.w	(a2)+,mgv_object2_x_prerotation_speed(a3)
	move.w	(a2)+,mgv_object2_y_prerotation_speed(a3)
	move.w	(a2)+,mgv_object2_z_prerotation_speed(a3)
	move.w	(a2)+,mgv_object3_x_prerotation_speed(a3)
	move.w	(a2)+,mgv_object3_y_prerotation_speed(a3)
	move.w	(a2),mgv_object3_z_prerotation_speed(a3)
	moveq	#0,d0
	move.w	d0,mgv_prerotation_active(a3)
	move.w	d0,mgv_object1_x_prerotation_angle(a3)
	move.w	d0,mgv_object1_y_prerotation_angle(a3)
	move.w	d0,mgv_object1_z_prerotation_angle(a3)
	move.w	d0,mgv_object2_x_prerotation_angle(a3)
	move.w	d0,mgv_object2_y_prerotation_angle(a3)
	move.w	d0,mgv_object2_z_prerotation_angle(a3)
	move.w	d0,mgv_object3_x_prerotation_angle(a3)
	move.w	d0,mgv_object3_y_prerotation_angle(a3)
	move.w	d0,mgv_object3_z_prerotation_angle(a3)
mgv_morph_objects_skip2
	move.w	#FALSE,mgv_morph_active(a3)
mgv_morph_objects_quit
	rts

; Input
; d7.w	number of coordinates
; a0.l	Pointer	current coordinates table
; a1.l	Pointer	destination coordinatws table
; Result
	CNOP 0,4
mgv_morph_objects_loop
	move.w	(a0),d0			; current coordinate
	cmp.w	(a1)+,d0		; destination coordinate reached ?
	beq.s	mgv_morph_objects_skip5
	bgt.s	mgv_morph_objects_skip3
	addq.w	#mgv_morph_speed,d0; increase current coordinate
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
	lea	mgv_objects_info(pc),a0
	lea	mgv_xy_coords(pc),a1
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
	move.l	(a0)+,a5		; starts table
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
	cmp.w	#1,d7			; backface ?
	beq.s	mgv_draw_lines_loop2
	lsr.w	#2,d7			; COLOR08/16 -> COLOR00/01
	beq	mgv_draw_lines_skip3
	cmp.w	#1,d7			; backface ?
	beq.s	mgv_draw_lines_loop2
	lsr.w	#2,d7			; COLOR32/64 -> COLOR00/01
	beq	mgv_draw_lines_skip3
mgv_draw_lines_loop2
	move.w	(a5)+,d0		; p1,p2 starts
	move.w	(a5),d2
	movem.w (a1,d0.w*2),d0-d1	; p1(x,y)
	movem.w (a1,d2.w*2),d2-d3	; p2(x,y)
	GET_LINE_PARAMETERS mgv,AREAFILL,COPPERUSE,,mgv_draw_lines_skip2
	add.l	a3,d0			; remaining BLTCON0 & BLTCON1 bits
	add.l	a2,d1			; add playfield address
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
	cmp.w	#16,d7			; bitplane 5 ?
	beq.s	mgv_draw_lines_skip1
	add.l	d5,d1			; next bitplane
	cmp.w	#32,d7			; bitplane 6 ?
	beq.s	mgv_draw_lines_skip1
	add.l	d5,d1			; next bitplane
mgv_draw_lines_skip1
	move.w	d0,cl2_ext2_BLTCON1-cl2_ext2_BLTCON0(a6)
	swap	d0
	move.w	d0,(a6)			; BLTCON0
	MULUF.W 2,d2			; 4*dx
	move.w	d4,cl2_ext2_BLTBMOD-cl2_ext2_BLTCON0(a6) ;4*dy
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
	swap	d7		 	; low word: loop couner
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
	swap	d0			; High
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
; d3.w y max
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
	subq.w	#1,d0
	beq.s	eh_stop_all
effects_handler_quit
	rts
	CNOP 0,4
eh_start_scroll_pf_bottom_in
	clr.w	spbi_active(a3)
	rts
	CNOP 0,4
eh_start_morphing
	clr.w	mgv_morph_active(a3)
	move.w	#FALSE,mgv_prerotation_active(a3)
	rts
	CNOP 0,4
eh_start_scroll_pf_bottom_out
	clr.w	spbo_active(a3)
	rts
	CNOP 0,4
eh_stop_all
	clr.w	stop_fx_active(a3)
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
	INCLUDE "Superglenz:colortables/3xGlenz-Colorgradient.ct"

	CNOP 0,2
mgv_object1_coords
; Zoom-In
	DS.W mgv_object1_edge_points_number*3
	CNOP 0,2
mgv_object2_coords
; Zoom-In
	DS.W mgv_object2_edge_points_number*3
	CNOP 0,2
mgv_object3_coords
; Zoom-In
	DS.W mgv_object3_edge_points_number*3

; Shape 1
	CNOP 0,2
mgv_object1_shape1_coords
; Pyramide
	DC.W 0,-(38*8),-(10*8)		; P0
	DC.W 19*8,0,-(24*8)		; P1
	DC.W 38*8,38*8,-(38*8)		; P2
	DC.W 0,38*8,-(38*8)		; P3
	DC.W -(38*8),38*8,-(38*8)	; P4
	DC.W -(19*8),0,-(24*8)		; P5
	DC.W 0,-(38*8),10*8		; P6
	DC.W 19*8,0,24*8		; P7
	DC.W 38*8,38*8,38*8		; P8
	DC.W 0,38*8,38*8		; P9
	DC.W -(38*8),38*8,38*8		; P10
	DC.W -(19*8),0,24*8		; P11
	CNOP 0,2
mgv_object2_shape1_coords
; No object
	DS.W mgv_object2_edge_points_number*3
	CNOP 0,2
mgv_object3_shape1_coords
; No object
	DS.W mgv_object2_edge_points_number*3

; Shape 2
	CNOP 0,2
mgv_object1_shape2_coords
; Pyramide 70 %
	DC.W 0,-(38*8),-(10*8)		; P0
	DC.W 19*8,0,-(24*8)		; P1
	DC.W 38*8,38*8,-(38*8)		; P2
	DC.W 0,38*8,-(38*8)		; P3
	DC.W -(38*8),38*8,-(38*8)	; P4
	DC.W -(19*8),0,-(24*8)		; P5
	DC.W 0,-(38*8),10*8		; P6
	DC.W 19*8,0,24*8		; P7
	DC.W 38*8,38*8,38*8		; P8
	DC.W 0,38*8,38*8		; P9
	DC.W -(38*8),38*8,38*8		; P10
	DC.W -(19*8),0,24*8		; P11
	CNOP 0,2
mgv_object2_shape2_coords
; Pyramide 50 %
	DC.W 0,-(27*8),-(7*8)		; P0
	DC.W 14*8,0,-(17*8)		; P1
	DC.W 27*8,27*8,-(27*8)		; P2
	DC.W 0,27*8,-(27*8)		; P3
	DC.W -(27*8),27*8,-(27*8)	; P4
	DC.W -(14*8),0,-(17*8)		; P5
	DC.W 0,-(27*8),7*8		; P6
	DC.W 14*8,0,17*8		; P7
	DC.W 27*8,27*8,27*8		; P8
	DC.W 0,27*8,27*8		; P9
	DC.W -(27*8),27*8,27*8		; P10
	DC.W -(14*8),0,17*8		; P11
	CNOP 0,2
mgv_object3_shape2_coords
; No object
	DS.W mgv_object2_edge_points_number*3
; Form 3
	CNOP 0,2
mgv_object1_shape3_coords
; Pyramide 70%
	DC.W 0,-(38*8),-(10*8)		; P0
	DC.W 19*8,0,-(24*8)		; P1
	DC.W 38*8,38*8,-(38*8)		; P2
	DC.W 0,38*8,-(38*8)		; P3
	DC.W -(38*8),38*8,-(38*8)	; P4
	DC.W -(19*8),0,-(24*8)		; P5
	DC.W 0,-(38*8),10*8		; P6
	DC.W 19*8,0,24*8		; P7
	DC.W 38*8,38*8,38*8		; P8
	DC.W 0,38*8,38*8		; P9
	DC.W -(38*8),38*8,38*8		; P10
	DC.W -(19*8),0,24*8		; P11
	CNOP 0,2
mgv_object2_shape3_coords
; Pyramide 50 %
	DC.W 0,-(27*8),-(7*8)		; P0
	DC.W 14*8,0,-(17*8)		; P1
	DC.W 27*8,27*8,-(27*8)		; P2
	DC.W 0,27*8,-(27*8)		; P3
	DC.W -(27*8),27*8,-(27*8)	; P4
	DC.W -(14*8),0,-(17*8)		; P5
	DC.W 0,-(27*8),7*8		; P6
	DC.W 14*8,0,17*8		; P7
	DC.W 27*8,27*8,27*8		; P8
	DC.W 0,27*8,27*8		; P9
	DC.W -(27*8),27*8,27*8		; P10
	DC.W -(14*8),0,17*8		; P11
	CNOP 0,2
mgv_object3_shape3_coords
; Pyramide 30 %
	DC.W 0,-(17*8),-(4*8)		; P0
	DC.W 8*8,0,-(10*8)		; P1
	DC.W 17*8,17*8,-(17*8)		; P2
	DC.W 0,17*8,-(17*8)		; P3
	DC.W -(17*8),17*8,-(17*8)	; P4
	DC.W -(8*8),0,-(10*8)		; P5
	DC.W 0,-(17*8),4*8		; P6
	DC.W 8*8,0,10*8			; P7
	DC.W 17*8,17*8,17*8		; P8
	DC.W 0,17*8,17*8		; P9
	DC.W -(17*8),17*8,17*8		; P10
	DC.W -(8*8),0,10*8		; P11

; Shape 4
	CNOP 0,2
mgv_object1_shape4_coords
; Polygon 50 %
	DC.W 0,-(23*8),7*8		; P0
	DC.W 12*8,0,7*8			; P1
	DC.W 23*8,23*8,7*8		; P2
	DC.W 0,23*8,7*8			; P3
	DC.W -(23*8),23*8,7*8		; P4
	DC.W -(12*8),0,7*8		; P5
	DC.W 0,-(23*8),23*8		; P6
	DC.W 12*8,0,23*8		; P7
	DC.W 23*8,23*8,23*8		; P8
	DC.W 0,23*8,23*8		; P9
	DC.W -(23*8),23*8,23*8		; P10
	DC.W -(12*8),0,23*8		; P11
	CNOP 0,2
mgv_object2_shape4_coords
; Polygon2 70 %
	DC.W 0,-(38*8),-(19*8)		; P0
	DC.W 58*8,0,-(38*8)		; P1
	DC.W 39*8,38*8,-(19*8)		; P2
	DC.W 0,38*8,-(19*8)		; P3
	DC.W -(39*8),38*8,-(19*8)	; P4
	DC.W -(58*8),0,-(38*8)		; P5
	DC.W 0,-(38*8),19*8		; P6
	DC.W 58*8,0,38*8		; P7
	DC.W 39*8,38*8,19*8		; P8
	DC.W 0,38*8,19*8		; P9
	DC.W -(39*8),38*8,19*8		; P10
	DC.W -(58*8),0,38*8		; P11
	CNOP 0,2
mgv_object3_shape4_coords
; Polygon 50 %
	DC.W 0,-(23*8),-(23*8)		; P24
	DC.W 12*8,0,-(23*8)		; P25
	DC.W 23*8,23*8,-(23*8)		; P26
	DC.W 0,23*8,-(23*8)		; P27
	DC.W -(23*8),23*8,-(23*8)	; P28
	DC.W -(12*8),0,-(23*8)		; P29
	DC.W 0,-(23*8),-(7*8)		; P30
	DC.W 12*8,0,-(7*8)		; P31
	DC.W 23*8,23*8,-(7*8)		; P32
	DC.W 0,23*8,-(7*8)		; P33
	DC.W -(23*8),23*8,-(7*8)	; P34
	DC.W -(12*8),0,-(7*8)		; P35

; Shape 5
	CNOP 0,2
mgv_object1_shape5_coords
; Polygon 100%
	DC.W 0,-(46*8),-(19*8)		; P0
	DC.W 23*8,0,-(19*8)		; P1
	DC.W 46*8,46*8,-(19*8)		; P2
	DC.W 0,46*8,-(19*8)		; P3
	DC.W -(46*8),46*8,-(19*8)	; P4
	DC.W -(23*8),0,-(19*8)		; P5
	DC.W 0,-(46*8),19*8		; P6
	DC.W 23*8,0,19*8		; P7
	DC.W 46*8,46*8,19*8		; P8
	DC.W 0,46*8,19*8		; P9
	DC.W -(46*8),46*8,19*8		; P10
	DC.W -(23*8),0,19*8		; P11
	CNOP 0,2
mgv_object2_shape5_coords
; Polygon 100 %
	DC.W 0,-(46*8),-(19*8)		; P12
	DC.W 23*8,0,-(19*8)		; P13
	DC.W 46*8,46*8,-(19*8)		; P14
	DC.W 0,46*8,-(19*8)		; P15
	DC.W -(46*8),46*8,-(19*8)	; P16
	DC.W -(23*8),0,-(19*8)		; P17
	DC.W 0,-(46*8),19*8		; P18
	DC.W 23*8,0,19*8		; P19
	DC.W 46*8,46*8,19*8		; P20
	DC.W 0,46*8,19*8		; P21
	DC.W -(46*8),46*8,19*8		; P22
	DC.W -(23*8),0,19*8		; P23
	CNOP 0,2
mgv_object3_shape5_coords
; Polygon 100 %
	DC.W 0,-(46*8),-(19*8)		; P24
	DC.W 23*8,0,-(19*8)		; P25
	DC.W 46*8,46*8,-(19*8)		; P26
	DC.W 0,46*8,-(19*8)		; P27
	DC.W -(46*8),46*8,-(19*8)	; P28
	DC.W -(23*8),0,-(19*8)		; P29
	DC.W 0,-(46*8),19*8		; P30
	DC.W 23*8,0,19*8		; P31
	DC.W 46*8,46*8,19*8		; P32
	DC.W 0,46*8,19*8		; P33
	DC.W -(46*8),46*8,19*8		; P34
	DC.W -(23*8),0,19*8		; P35

; Shape 6
	CNOP 0,2
mgv_object1_shape6_coords
; Polygon 80%
	DC.W 0,-(37*8),28*8		; P0
	DC.W 19*8,0,28*8		; P1
	DC.W 37*8,37*8,28*8		; P2
	DC.W 0,37*8,28*8		; P3
	DC.W -(37*8),37*8,28*8		; P4
	DC.W -(19*8),0,28*8		; P5
	DC.W 0,-(37*8),45*8		; P6
	DC.W 19*8,0,45*8		; P7
	DC.W 37*8,37*8,45*8		; P8
	DC.W 0,37*8,45*8		; P9
	DC.W -(37*8),37*8,45*8		; P10
	DC.W -(19*8),0,45*8		; P11
	CNOP 0,2
mgv_object2_shape6_coords
; Polygon 80%
	DC.W 0,-(37*8),-(9*8)		; P0
	DC.W 19*8,0,-(9*8)		; P1
	DC.W 37*8,37*8,-(9*8)		; P2
	DC.W 0,37*8,-(9*8)		; P3
	DC.W -(37*8),37*8,-(9*8)	; P4
	DC.W -(19*8),0,-(9*8)		; P5
	DC.W 0,-(37*8),9*8		; P6
	DC.W 19*8,0,9*8			; P7
	DC.W 37*8,37*8,9*8		; P8
	DC.W 0,37*8,9*8			; P9
	DC.W -(37*8),37*8,9*8		; P10
	DC.W -(19*8),0,9*8		; P11
	CNOP 0,2
mgv_object3_shape6_coords
; Polygon 80%
	DC.W 0,-(37*8),-(45*8)		; P0
	DC.W 19*8,0,-(45*8)		; P1
	DC.W 37*8,37*8,-(45*8)		; P2
	DC.W 0,37*8,-(45*8)		; P3
	DC.W -(37*8),37*8,-(45*8)	; P4
	DC.W -(19*8),0,-(45*8)		; P5
	DC.W 0,-(37*8),-(28*8)		; P6
	DC.W 19*8,0,-(28*8)		; P7
	DC.W 37*8,37*8,-(28*8)		; P8
	DC.W 0,37*8,-(28*8)		; P9
	DC.W -(37*8),37*8,-(28*8)	; P10
	DC.W -(19*8),0,-(28*8)		; P11

	CNOP 0,4
mgv_objects_info
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

; Objekt 2
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

; Objekt 3
; 1. face
	DC.L 0				; coordinates table
	DC.W mgv_object3_face1_color
	DC.W mgv_object3_face1_lines_number-1 
; 2. face
	DC.L 0				; coordinates table
	DC.W mgv_object3_face2_color
	DC.W mgv_object3_face2_lines_number-1 
; 3. face
	DC.L 0				; coordinates table
	DC.W mgv_object3_face3_color
	DC.W mgv_object3_face3_lines_number-1 
; 4. face
	DC.L 0				; coordinates table
	DC.W mgv_object3_face4_color
	DC.W mgv_object3_face4_lines_number-1 

; 5. face
	DC.L 0				; coordinates table
	DC.W mgv_object3_face5_color
	DC.W mgv_object3_face5_lines_number-1 
; 6. face
	DC.L 0				; coordinates table
	DC.W mgv_object3_face6_color
	DC.W mgv_object3_face6_lines_number-1 
; 7. face
	DC.L 0				; coordinates table
	DC.W mgv_object3_face7_color
	DC.W mgv_object3_face7_lines_number-1 
; 8. face
	DC.L 0				; coordinates table
	DC.W mgv_object3_face8_color
	DC.W mgv_object3_face8_lines_number-1 

; 9. face
	DC.L 0				; coordinates table
	DC.W mgv_object3_face9_color
	DC.W mgv_object3_face9_lines_number-1 
; 10. face
	DC.L 0				; coordinates table
	DC.W mgv_object3_face10_color
	DC.W mgv_object3_face10_lines_number-1 
; 11. face
	DC.L 0				; coordinates table
	DC.W mgv_object3_face11_color
	DC.W mgv_object3_face11_lines_number-1 
; 12. face
	DC.L 0				; coordinates table
	DC.W mgv_object3_face12_color
	DC.W mgv_object3_face12_lines_number-1 

; 13. face
	DC.L 0				; coordinates table
	DC.W mgv_object3_face13_color
	DC.W mgv_object3_face13_lines_number-1 
; 14. face
	DC.L 0				; coordinates table
	DC.W mgv_object3_face14_color
	DC.W mgv_object3_face14_lines_number-1 
; 15. face
	DC.L 0				; coordinates table
	DC.W mgv_object3_face15_color
	DC.W mgv_object3_face15_lines_number-1 
; 16. face
	DC.L 0				; coordinates table
	DC.W mgv_object3_face16_color
	DC.W mgv_object3_face16_lines_number-1 

; 17. face
	DC.L 0				; coordinates table
	DC.W mgv_object3_face17_color
	DC.W mgv_object3_face17_lines_number-1 
; 18. face
	DC.L 0				; coordinates table
	DC.W mgv_object3_face18_color
	DC.W mgv_object3_face18_lines_number-1 
; 19. face
	DC.L 0				; coordinates table
	DC.W mgv_object3_face19_color
	DC.W mgv_object3_face19_lines_number-1 
; 20. face
	DC.L 0				; coordinates table
	DC.W mgv_object3_face20_color
	DC.W mgv_object3_face20_lines_number-1 

	CNOP 0,2
mgv_objects_edges
; Objekt 1
	DC.W 0*2,1*2,5*2,0*2		; front faces
	DC.W 1*2,2*2,3*2,1*2
	DC.W 1*2,3*2,5*2,1*2
	DC.W 5*2,3*2,4*2,5*2

	DC.W 6*2,11*2,7*2,6*2		; back faces
	DC.W 7*2,9*2,8*2,7*2
	DC.W 7*2,11*2,9*2,7*2
	DC.W 11*2,10*2,9*2,11*2

	DC.W 0*2,6*2,7*2,0*2		; left faces
	DC.W 0*2,7*2,1*2,0*2
	DC.W 1*2,7*2,8*2,1*2
	DC.W 1*2,8*2,2*2,1*2

	DC.W 0*2,5*2,6*2,0*2		; right faces
	DC.W 6*2,5*2,11*2,6*2
	DC.W 11*2,5*2,4*2,11*2
	DC.W 11*2,4*2,10*2,11*2

	DC.W 4*2,3*2,10*2,4*2		; bottom faces
	DC.W 3*2,9*2,10*2,3*2
	DC.W 3*2,2*2,9*2,3*2
	DC.W 2*2,8*2,9*2,2*2
; Objekt 2
	DC.W 12*2,13*2,17*2,12*2	; front faces
	DC.W 13*2,14*2,15*2,13*2
	DC.W 13*2,15*2,17*2,13*2
	DC.W 17*2,15*2,16*2,17*2

	DC.W 18*2,23*2,19*2,18*2	; back faces
	DC.W 19*2,21*2,20*2,19*2
	DC.W 19*2,23*2,21*2,19*2
	DC.W 23*2,22*2,21*2,23*2

	DC.W 12*2,18*2,19*2,12*2	; left faces
	DC.W 12*2,19*2,13*2,12*2
	DC.W 13*2,19*2,20*2,13*2
	DC.W 13*2,20*2,14*2,13*2

	DC.W 12*2,17*2,18*2,12*2	; right faces
	DC.W 18*2,17*2,23*2,18*2
	DC.W 23*2,17*2,16*2,23*2
	DC.W 23*2,16*2,22*2,23*2

	DC.W 16*2,15*2,22*2,16*2	; bottom faces
	DC.W 15*2,21*2,22*2,15*2
	DC.W 15*2,14*2,21*2,15*2
	DC.W 14*2,20*2,21*2,14*2
; Objekt 3
	DC.W 24*2,25*2,29*2,24*2	; front faces
	DC.W 25*2,26*2,27*2,25*2
	DC.W 25*2,27*2,29*2,25*2
	DC.W 29*2,27*2,28*2,29*2

	DC.W 30*2,35*2,31*2,30*2	; back faces
	DC.W 31*2,33*2,32*2,31*2
	DC.W 31*2,35*2,33*2,31*2
	DC.W 35*2,34*2,33*2,35*2

	DC.W 24*2,30*2,31*2,24*2	; left faces
	DC.W 24*2,31*2,25*2,24*2
	DC.W 25*2,31*2,32*2,25*2
	DC.W 25*2,32*2,26*2,25*2

	DC.W 24*2,29*2,30*2,24*2	; right faces
	DC.W 30*2,29*2,35*2,30*2
	DC.W 35*2,29*2,28*2,35*2
	DC.W 35*2,28*2,34*2,35*2

	DC.W 28*2,27*2,34*2,28*2	; bottom faces
	DC.W 27*2,33*2,34*2,27*2
	DC.W 27*2,26*2,33*2,27*2
	DC.W 26*2,32*2,33*2,26*2

	CNOP 0,2
mgv_xy_coords
	DS.W mgv_objects_edge_points_number*2

	CNOP 0,4
mgv_morph_shapes
	DS.B morph_shape_size*mgv_morph_shapes_number


	INCLUDE "sys-variables.i"


	INCLUDE "sys-names.i"


	INCLUDE "error-texts.i"

	END
