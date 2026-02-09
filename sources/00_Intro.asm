	MC68040


; Imports
	XREF color00_bits

; Exports
	XDEF start_00_intro
	XDEF mouse_handler
	XDEF sine_table


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
START_SECOND_COPPERLIST		SET 1


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

dma_bits			EQU DMAF_SPRITE|DMAF_BLITTER|DMAF_RASTER|DMAF_SETCLR

intena_bits			EQU INTF_SETCLR

ciaa_icr_bits			EQU CIAICRF_SETCLR
ciab_icr_bits			EQU CIAICRF_SETCLR

copcon_bits			EQU 0

pf1_x_size1			EQU 192
pf1_y_size1			EQU 192
pf1_depth1			EQU 3
pf1_x_size2			EQU 192
pf1_y_size2			EQU 192
pf1_depth2			EQU 3
pf1_x_size3			EQU 192
pf1_y_size3			EQU 192
pf1_depth3			EQU 3
pf1_colors_number		EQU 0	; 8

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
spr_colors_number		EQU 0	; 16
spr_odd_color_table_select	EQU 1	; COLOR16..COLOR31
spr_even_color_table_select	EQU 1	; COLOR16..COLOR31
spr_used_number			EQU 3

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
spr_pixel_per_datafetch		EQU 64	; 4x

display_window_hstart		EQU HSTART_192_PIXEL
display_window_vstart		EQU MINROW
display_window_hstop		EQU HSTOP_192_pixel
display_window_vstop		EQU VSTOP_OVERSCAN_PAL

pf1_plane_width			EQU pf1_x_size3/8
data_fetch_width		EQU pixel_per_line/8
pf1_plane_moduli		EQU (pf1_plane_width*(pf1_depth3-1))+pf1_plane_width-data_fetch_width

diwstrt_bits			EQU ((display_window_vstart&$ff)*DIWSTRTF_V0)|(display_window_hstart&$ff)
diwstop_bits			EQU ((display_window_vstop&$ff)*DIWSTOPF_V0)|(display_window_hstop&$ff)
ddfstrt_bits			EQU DDFSTRT_192_PIXEL_4X
ddfstop_bits			EQU DDFSTOP_192_PIXEL_4X
bplcon0_bits			EQU BPLCON0F_ECSENA|((pf_depth>>3)*BPLCON0F_BPU3)|BPLCON0F_COLOR|((pf_depth&$07)*BPLCON0F_BPU0)
bplcon1_bits			EQU 0
bplcon2_bits			EQU 0
bplcon3_bits1			EQU BPLCON3F_SPRES0
bplcon3_bits2			EQU bplcon3_bits1|BPLCON3F_LOCT
bplcon4_bits			EQU (BPLCON4F_OSPRM4*spr_odd_color_table_select)|(BPLCON4F_ESPRM4*spr_even_color_table_select)
diwhigh_bits			EQU (((display_window_hstop&$100)>>8)*DIWHIGHF_HSTOP8)|(((display_window_vstop&$700)>>8)*DIWHIGHF_VSTOP8)|(((display_window_hstart&$100)>>8)*DIWHIGHF_HSTART8)|((display_window_vstart&$700)>>8)
fmode_bits			EQU FMODEF_SPR32|FMODEF_SPAGEM|FMODEF_BPL32|FMODEF_BPAGEM

cl1_display_y_size1		EQU 39
cl1_display_y_size2		EQU 56
cl2_display_x_size1		EQU 192
cl2_display_width1		EQU cl2_display_x_size1/8
cl2_display_x_size2		EQU 192
cl2_display_width2		EQU cl2_display_x_size2/8
cl1_hstart1			EQU display_window_hstart-(4*CMOVE_SLOT_PERIOD)-4
cl1_vstart1			EQU VSTART_192_LINES+8
cl1_hstart2			EQU display_window_hstart-(4*CMOVE_SLOT_PERIOD)-4
cl1_vstart2			EQU VSTART_192_LINES+124
cl1_hstart3			EQU 0
cl1_vstart3			EQU beam_position&CL_Y_WRAPPING

sine_table_length		EQU 512

; Title
title_image_x_position		EQU display_window_hstart
title_image_y_position		EQU VSTART_192_LINES+8
title_image_x_size		EQU 192
title_image_width		EQU title_image_x_size/8
title_image_y_size		EQU 39

; RSE letters
rse_letters_image_x_position1	EQU display_window_hstart+28
rse_letters_image_y_position1	EQU VSTART_192_LINES+124
rse_letters_image_x_position2	EQU display_window_hstart+88
rse_letters_image_y_position2	EQU VSTART_192_LINES+164
rse_letters_image_x_position3	EQU display_window_hstart+148
rse_letters_image_y_position3	EQU VSTART_192_LINES+124
rse_letters_image_x_size	EQU 192
rse_letters_image_width		EQU rse_letters_image_x_size/8
rse_letters_image_y_size	EQU 16

; Glenz-Vectors
gv_distance			EQU 512+512
gv_xy_center			EQU visible_lines_number/2
gv_y_angle_speed		EQU 4

gv_object_edge_points_number	EQU 26
gv_object_edge_points_per_face	EQU 3
gv_object_faces_number		EQU 48

gv_object_face1_color		EQU 2
gv_object_face1_lines_number	EQU 3
gv_object_face2_color		EQU 4
gv_object_face2_lines_number	EQU 3
gv_object_face3_color		EQU 2
gv_object_face3_lines_number	EQU 3
gv_object_face4_color		EQU 4
gv_object_face4_lines_number	EQU 3
gv_object_face5_color		EQU 2
gv_object_face5_lines_number	EQU 3
gv_object_face6_color		EQU 4
gv_object_face6_lines_number	EQU 3
gv_object_face7_color		EQU 2
gv_object_face7_lines_number	EQU 3
gv_object_face8_color		EQU 4
gv_object_face8_lines_number	EQU 3

gv_object_face9_color		EQU 4
gv_object_face9_lines_number	EQU 3
gv_object_face10_color		EQU 2
gv_object_face10_lines_number	EQU 3
gv_object_face11_color		EQU 4
gv_object_face11_lines_number	EQU 3
gv_object_face12_color		EQU 2
gv_object_face12_lines_number	EQU 3

gv_object_face13_color		EQU 2
gv_object_face13_lines_number	EQU 3
gv_object_face14_color		EQU 4
gv_object_face14_lines_number	EQU 3
gv_object_face15_color		EQU 2
gv_object_face15_lines_number	EQU 3
gv_object_face16_color		EQU 4
gv_object_face16_lines_number	EQU 3

gv_object_face17_color		EQU 4
gv_object_face17_lines_number	EQU 3
gv_object_face18_color		EQU 2
gv_object_face18_lines_number	EQU 3
gv_object_face19_color		EQU 4
gv_object_face19_lines_number	EQU 3
gv_object_face20_color		EQU 2
gv_object_face20_lines_number	EQU 3

gv_object_face21_color		EQU 2
gv_object_face21_lines_number	EQU 3
gv_object_face22_color		EQU 4
gv_object_face22_lines_number	EQU 3
gv_object_face23_color		EQU 2
gv_object_face23_lines_number	EQU 3
gv_object_face24_color		EQU 4
gv_object_face24_lines_number	EQU 3

gv_object_face25_color		EQU 4
gv_object_face25_lines_number	EQU 3
gv_object_face26_color		EQU 2
gv_object_face26_lines_number	EQU 3
gv_object_face27_color		EQU 4
gv_object_face27_lines_number	EQU 3
gv_object_face28_color		EQU 2
gv_object_face28_lines_number	EQU 3

gv_object_face29_color		EQU 2
gv_object_face29_lines_number	EQU 3
gv_object_face30_color		EQU 4
gv_object_face30_lines_number	EQU 3
gv_object_face31_color		EQU 2
gv_object_face31_lines_number	EQU 3
gv_object_face32_color		EQU 4
gv_object_face32_lines_number	EQU 3

gv_object_face33_color		EQU 4
gv_object_face33_lines_number	EQU 3
gv_object_face34_color		EQU 2
gv_object_face34_lines_number	EQU 3
gv_object_face35_color		EQU 4
gv_object_face35_lines_number	EQU 3
gv_object_face36_color		EQU 2
gv_object_face36_lines_number	EQU 3

gv_object_face37_color		EQU 2
gv_object_face37_lines_number	EQU 3
gv_object_face38_color		EQU 4
gv_object_face38_lines_number	EQU 3
gv_object_face39_color		EQU 2
gv_object_face39_lines_number	EQU 3
gv_object_face40_color		EQU 4
gv_object_face40_lines_number	EQU 3

gv_object_face41_color		EQU 2
gv_object_face41_lines_number	EQU 3
gv_object_face42_color		EQU 4
gv_object_face42_lines_number	EQU 3
gv_object_face43_color		EQU 2
gv_object_face43_lines_number	EQU 3
gv_object_face44_color		EQU 4
gv_object_face44_lines_number	EQU 3
gv_object_face45_color		EQU 2
gv_object_face45_lines_number	EQU 3
gv_object_face46_color		EQU 4
gv_object_face46_lines_number	EQU 3
gv_object_face47_color		EQU 2
gv_object_face47_lines_number	EQU 3
gv_object_face48_color		EQU 4
gv_object_face48_lines_number	EQU 3

; Fill-Blit
gv_fill_blit_x_size		EQU visible_pixels_number
gv_fill_blit_y_size		EQU visible_lines_number
gv_fill_blit_depth		EQU pf1_depth3

; Scroll-Playfield-Bottom
spb_min_vstart			EQU VSTART_192_LINES
spb_max_vstop			EQU VSTOP_OVERSCAN_PAL
spb_y_radius			EQU spb_max_vstop-spb_min_vstart
spb_y_center			EQU spb_max_vstop-spb_min_vstart

; Scroll-Playfield-Bottom-In
spbi_y_angle_speed		EQU 3

; Scroll-Playfield-Bottom-Out
spbo_y_angle_speed		EQU 10

; Horiz-Fader
hf_colors_per_colorbank		EQU 16
hf_colorbanks_number		EQU 240/hf_colors_per_colorbank

; Effects-Handler
eh_trigger_number_max		EQU 5


	INCLUDE "except-vectors.i"


	INCLUDE "extra-pf-attributes.i"


	INCLUDE "sprite-attributes.i"


; Glenz-Vectors
	RSRESET

object_info			RS.B 0

object_info_edges		RS.L 1
object_info_face_color		RS.W 1
object_info_lines_number	RS.W 1

object_info_size		RS.B 0


	RSRESET

cl1_subextension1		RS.B 0
cl1_subext1_WAIT		RS.L 1
cl1_subext1_COP1LCH		RS.L 1
cl1_subext1_COP1LCL		RS.L 1
cl1_subext1_COPJMP2		RS.L 1
cl1_subextension1_size		RS.B 0

	RSRESET

cl1_extension1			RS.B 0
cl1_ext1_COP2LCH		RS.L 1
cl1_ext1_COP2LCL		RS.L 1
cl1_ext1_subextension1_entry	RS.B cl1_subextension1_size*cl1_display_y_size1
cl1_extension1_size		RS.B 0

	RSRESET

cl1_extension2			RS.B 0
cl1_ext2_COP2LCH		RS.L 1
cl1_ext2_COP2LCL		RS.L 1
cl1_ext2_subextension1_entry	RS.B cl1_subextension1_size*cl1_display_y_size2
cl1_extension2_size		RS.B 0

	RSRESET

cl1_begin			RS.B 0

	INCLUDE "copperlist1.i"

cl1_extension1_entry		RS.B cl1_extension1_size
cl1_extension2_entry		RS.B cl1_extension2_size
cl1_COP1LCH			RS.L 1
cl1_COP1LCL			RS.L 1
cl1_WAIT1			RS.L 1
cl1_WAIT2			RS.L 1
cl1_INTREQ			RS.L 1

cl1_end				RS.L 1

copperlist1_size		RS.B 0

	RSRESET

cl2_extension1			RS.B 0

cl2_ext1_BPLCON4_1		RS.L 1
cl2_ext1_BPLCON4_2		RS.L 1
cl2_ext1_BPLCON4_3		RS.L 1
cl2_ext1_BPLCON4_4		RS.L 1
cl2_ext1_BPLCON4_5		RS.L 1
cl2_ext1_BPLCON4_6		RS.L 1
cl2_ext1_BPLCON4_7		RS.L 1
cl2_ext1_BPLCON4_8		RS.L 1
cl2_ext1_BPLCON4_9		RS.L 1
cl2_ext1_BPLCON4_10		RS.L 1
cl2_ext1_BPLCON4_11		RS.L 1
cl2_ext1_BPLCON4_12		RS.L 1
cl2_ext1_BPLCON4_13		RS.L 1
cl2_ext1_BPLCON4_14		RS.L 1
cl2_ext1_BPLCON4_15		RS.L 1
cl2_ext1_BPLCON4_16		RS.L 1
cl2_ext1_BPLCON4_17		RS.L 1
cl2_ext1_BPLCON4_18		RS.L 1
cl2_ext1_BPLCON4_19		RS.L 1
cl2_ext1_BPLCON4_20		RS.L 1
cl2_ext1_BPLCON4_21		RS.L 1
cl2_ext1_BPLCON4_22		RS.L 1
cl2_ext1_BPLCON4_23		RS.L 1
cl2_ext1_BPLCON4_24		RS.L 1
cl2_ext1_COPJMP1		RS.L 1

cl2_extension1_size		RS.B 0

	RSRESET

cl2_extension2			RS.B 0

cl2_ext2_BPLCON4_1		RS.L 1
cl2_ext2_BPLCON4_2		RS.L 1
cl2_ext2_BPLCON4_3		RS.L 1
cl2_ext2_BPLCON4_4		RS.L 1
cl2_ext2_BPLCON4_5		RS.L 1
cl2_ext2_BPLCON4_6		RS.L 1
cl2_ext2_BPLCON4_7		RS.L 1
cl2_ext2_BPLCON4_8		RS.L 1
cl2_ext2_BPLCON4_9		RS.L 1
cl2_ext2_BPLCON4_10		RS.L 1
cl2_ext2_BPLCON4_11		RS.L 1
cl2_ext2_BPLCON4_12		RS.L 1
cl2_ext2_BPLCON4_13		RS.L 1
cl2_ext2_BPLCON4_14		RS.L 1
cl2_ext2_BPLCON4_15		RS.L 1
cl2_ext2_BPLCON4_16		RS.L 1
cl2_ext2_BPLCON4_17		RS.L 1
cl2_ext2_BPLCON4_18		RS.L 1
cl2_ext2_BPLCON4_19		RS.L 1
cl2_ext2_BPLCON4_20		RS.L 1
cl2_ext2_BPLCON4_21		RS.L 1
cl2_ext2_BPLCON4_22		RS.L 1
cl2_ext2_BPLCON4_23		RS.L 1
cl2_ext2_BPLCON4_24		RS.L 1
cl2_ext2_COPJMP1		RS.L 1

cl2_extension2_size		RS.B 0

	RSRESET

cl2_begin			RS.B 0

cl2_extension1_entry		RS.B cl2_extension1_size
cl2_extension2_entry		RS.B cl2_extension2_size

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
spr0_ext1_planedata		RS.L (spr_pixel_per_datafetch/WORD_BITS)*title_image_y_size

spr0_extension1_size		RS.B 0

	RSRESET

spr0_extension2			RS.B 0

spr0_ext2_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr0_ext2_planedata		RS.L (spr_pixel_per_datafetch/WORD_BITS)*rse_letters_image_y_size

spr0_extension2_size		RS.B 0

; Sprite0 main structure
	RSRESET

spr0_begin			RS.B 0

spr0_extension1_entry		RS.B spr0_extension1_size
spr0_extension2_entry		RS.B spr0_extension2_size

spr0_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite0_size			RS.B 0

; Sprite1 additional structure
	RSRESET

spr1_extension1			RS.B 0

spr1_ext1_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr1_ext1_planedata		RS.L (spr_pixel_per_datafetch/WORD_BITS)*title_image_y_size

spr1_extension1_size		RS.B 0

	RSRESET

spr1_extension2			RS.B 0

spr1_ext2_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr1_ext2_planedata		RS.L (spr_pixel_per_datafetch/WORD_BITS)*rse_letters_image_y_size

spr1_extension2_size		RS.B 0

; Sprite1 main structure
	RSRESET

spr1_begin			RS.B 0

spr1_extension1_entry		RS.B spr1_extension1_size
spr1_extension2_entry		RS.B spr1_extension2_size

spr1_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite1_size			RS.B 0

; Sprite2 additional structure
	RSRESET

spr2_extension1	RS.B 0

spr2_ext1_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr2_ext1_planedata		RS.L (spr_pixel_per_datafetch/WORD_BITS)*title_image_y_size

spr2_extension1_size		RS.B 0

	RSRESET

spr2_extension2	RS.B 0

spr2_ext2_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr2_ext2_planedata		RS.L (spr_pixel_per_datafetch/WORD_BITS)*rse_letters_image_y_size

spr2_extension2_size		RS.B 0

; Sprite2 main structure
	RSRESET

spr2_begin			RS.B 0

spr2_extension1_entry		RS.B spr2_extension1_size
spr2_extension2_entry		RS.B spr2_extension2_size

spr2_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite2_size			RS.B 0

; Sprite3 main structure
	RSRESET

spr3_begin			RS.B 0

spr3_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite3_size			RS.B 0

; Sprite4 main structure
	RSRESET

spr4_begin			RS.B 0

spr4_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite4_size			RS.B 0

; Sprite5 main structure
	RSRESET

spr5_begin			RS.B 0

spr5_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite5_size			RS.B 0

; Sprite6 main structure
	RSRESET

spr6_begin			RS.B 0

spr6_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite6_size			RS.B 0

; Sprite7 main structure
	RSRESET

spr7_begin			RS.B 0

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

save_a7				RS.L 1

; Glenz-Vectors
gv_x_angle			RS.W 1
gv_y_angle			RS.W 1
gv_z_angle			RS.W 1

; Scroll-Playfield-Bottom-In
spbi_active			RS.W 1
spbi_y_angle			RS.W 1

; Scroll-Playfield-Bottom-Out
spbo_active			RS.W 1
spbo_y_angle			RS.W 1

; Horiz-Fader
hf1_bplam_table_start		RS.W 1
hf2_bplam_table_start		RS.W 1

; Horiz-Fader-In
hfi1_active			RS.W 1
hfi2_active			RS.W 1

; Horiz-Fader-Out
hfo1_active			RS.W 1
hfo2_active			RS.W 1

; Effects-Handler
eh_trigger_number		RS.W 1

; Main
	RS_ALIGN_LONGWORD
cl_end				RS.L 1
stop_fx_active			RS.W 1

variables_size			RS.B 0


	SECTION code,CODE


start_00_intro


	INCLUDE "sys-wrapper.i"


	CNOP 0,4
init_main_variables

; Glenz-Vectors
	moveq	#TRUE,d0
	move.w	d0,gv_x_angle(a3)
	move.w	d0,gv_y_angle(a3)
	move.w	d0,gv_z_angle(a3)

; Scroll-Playfield-Bottom-In
	moveq	#FALSE,d1
	move.w	d1,spbi_active(a3)
	move.w	d0,spbi_y_angle(a3)	; 0°

; Scroll-Playfield-Bottom-Out
	move.w	d1,spbo_active(a3)
	move.w	#sine_table_length/4,spbo_y_angle(a3) ; 90°

; Horiz-Fader
	move.w	d0,hf1_bplam_table_start(a3)
	move.w	d0,hf2_bplam_table_start(a3)

; Horiz-Fader-In
	move.w	d1,hfi1_active(a3)
	move.w	d1,hfi2_active(a3)

; Horiz-Fader-Out
	move.w	d1,hfo1_active(a3)
	move.w	d1,hfo2_active(a3)

; Effects-Handler
	move.w	d0,eh_trigger_number(a3)

; Main
	move.w	d1,stop_fx_active(a3)
	rts


	CNOP 0,4
init_main
	bsr.s	init_sprites
	bsr	gv_init_object_info
	bsr	gv_init_color_table
	bsr	hf_dim_colors
	bsr	init_colors
	bsr	spb_init_display_window
	bsr	init_first_copperlist
	bsr	init_second_copperlist
	rts


	CNOP 0,4
init_sprites
	bsr.s	spr_init_pointers_table
	bsr.s	init_sprites_cluster
	rts


	INIT_SPRITE_POINTERS_TABLE


; RSE letters
	CNOP 0,4
init_sprites_cluster
	move.l	a4,-(a7)
	MOVEF.W (title_image_x_position+(spr_x_size2*0))*SHIRES_PIXEL_FACTOR,d0
	moveq	#title_image_y_position,d1
	MOVEF.W title_image_y_size,d2
	moveq	#((title_image_x_size-spr_x_size2)/8)+title_image_width,d3
	lea	spr_pointers_display(pc),a1
	move.l	(a1)+,a0		; SPR0 structure
	lea	title_image_data+((spr_x_size2/8)*0),a2 ; bitplane 1
	lea	title_image_width(a2),a4 ; bitplane 2
	MOVEF.W title_image_y_size-1,d7
	bsr	copy_sprite_planes

	MOVEF.W (title_image_x_position+(spr_x_size2*1))*SHIRES_PIXEL_FACTOR,d0
	moveq	#title_image_y_position,d1
	MOVEF.W title_image_y_size,d2
	move.l	(a1)+,a0		; SPR1 structure
	lea	title_image_data+((spr_x_size2/8)*1),a2 ; bitplane 1
	lea	title_image_width(a2),a4 ; bitplane 2
	MOVEF.W title_image_y_size-1,d7
	bsr.s	copy_sprite_planes

	MOVEF.W (title_image_x_position+(spr_x_size2*2))*SHIRES_PIXEL_FACTOR,d0
	moveq	#title_image_y_position,d1
	MOVEF.W title_image_y_size,d2
	move.l	(a1),a0			; SPR2 structure
	lea	title_image_data+((spr_x_size2/8)*2),a2 ; bitplane 1
	lea	title_image_width(a2),a4 ; bitplane 2
	MOVEF.W title_image_y_size-1,d7
	bsr.s	copy_sprite_planes

	MOVEF.W rse_letters_image_x_position1*SHIRES_PIXEL_FACTOR,d0
	MOVEF.W rse_letters_image_y_position1,d1
	MOVEF.W rse_letters_image_y_size,d2
	moveq	#((rse_letters_image_x_size-spr_x_size2)/8)+rse_letters_image_width,d3
	lea	spr_pointers_display(pc),a1
	move.l	(a1)+,a0		; SPR0 structure
	ADDF.W	spr0_extension2_entry,a0
	lea	rse_letters_image_data+((spr_x_size2/8)*0),a2 ; bitplane 1
	lea	rse_letters_image_width(a2),a4 ; bitplane 2
	MOVEF.W rse_letters_image_y_size-1,d7
	bsr.s	copy_sprite_planes

	MOVEF.W rse_letters_image_x_position2*SHIRES_PIXEL_FACTOR,d0
	MOVEF.W rse_letters_image_y_position2,d1
	MOVEF.W rse_letters_image_y_size,d2
	move.l	(a1)+,a0		; SPR1 structure
	ADDF.W	spr1_extension2_entry,a0
	lea	rse_letters_image_data+((spr_x_size2/8)*1),a2 ; bitplane 1
	lea	rse_letters_image_width(a2),a4 ; bitplane 2
	MOVEF.W rse_letters_image_y_size-1,d7
	bsr.s	copy_sprite_planes

	MOVEF.W rse_letters_image_x_position3*SHIRES_PIXEL_FACTOR,d0
	MOVEF.W rse_letters_image_y_position3,d1
	MOVEF.W rse_letters_image_y_size,d2
	move.l	(a1),a0			; SPR2 structure
	ADDF.W	spr2_extension2_entry,a0
	lea	rse_letters_image_data+((spr_x_size2/8)*2),a2 ; bitplane 1
	lea	rse_letters_image_width(a2),a4 ; bitplane 2
	MOVEF.W rse_letters_image_y_size-1,d7
	bsr.s	copy_sprite_planes
	move.l	(a7)+,a4
	rts


; Input
; d0.w	X position
; d1.w	Y position
; d2.w	Height
; d7.w	Height of single sprite
; a0.l	Sprite structure
; a2.l	 bitplane 1
; a4.l	 bitplane 2
; Result
	CNOP 0,4
copy_sprite_planes
	add.w	d1,d2			; VSTOP
	SET_SPRITE_POSITION d0,d1,d2
	move.w	d1,(a0)			; SPRxPOS
	move.w	d2,spr_pixel_per_datafetch/8(a0) ; SPRxCTL
	ADDF.W	(spr_pixel_per_datafetch/4),a0 ; skip sprite structure header
copy_sprite_planes_loop
	move.l	(a2)+,(a0)+		; bitplane 1
	move.l	(a2)+,(a0)+
	add.l	d3,a2
	move.l	(a4)+,(a0)+		; bitplane 2
	move.l	(a4)+,(a0)+
	add.l	d3,a4
	dbf	d7,copy_sprite_planes_loop
	rts


; Glenz-Vectors
	CNOP 0,4
gv_init_object_info
	lea	gv_object_info+object_info_edges(pc),a0
	lea	gv_object_edges(pc),a1
	move.w	#object_info_size,a2
	moveq	#gv_object_faces_number-1,d7
gv_init_object_info_loop
	move.w	object_info_lines_number(a0),d0
	addq.w	#1+1,d0			; number of edge points
	move.l	a1,(a0)			; edge table
	lea	(a1,d0.w*2),a1		; next edge table
	add.l	a2,a0			; next object info structure
	dbf	d7,gv_init_object_info_loop
	rts

	CNOP 0,4
gv_init_color_table
	lea	pf1_rgb8_color_table(pc),a0
	lea	gv_rgb8_color_table(pc),a1
	move.l	(a1)+,QUADWORD_SIZE(a0) ; COLOR02
	move.l	(a1)+,3*LONGWORD_SIZE(a0) ; COLOR03
	move.l	(a1)+,4*LONGWORD_SIZE(a0) ; COLOR04
	move.l	(a1),5*LONGWORD_SIZE(a0) ; COLOR05
	rts


; Horiz-Fader
	CNOP 0,4
hf_dim_colors
	moveq	#1,d3			; min brightness
	moveq	#hf_colorbanks_number,d4 ; max brightness
	lea	spr_rgb8_color_table+(hf_colors_per_colorbank*LONGWORD_SIZE)+(1*LONGWORD_SIZE)(pc),a0
	MOVEF.W (hf_colorbanks_number-1)-1,d7
hf_dim_colors_loop1
	moveq	#hf_colorbanks_number,d5
	sub.b	d3,d5			; invert brightness
	move.l	#color00_bits,d0
	swap	d0			; R8
	mulu.w	d5,d0			; dim red
	divu.w	d4,d0
	move.l	#color00_bits,d1
	lsr.w	#8,d1			; G8
	mulu.w	d5,d1			; dim green
	divu.w	d4,d1
	move.l	#color00_bits,d2
	and.l	#$0000ff,d2
	mulu.w	d5,d2			; dim blue
	divu.w	d4,d2
	swap	d0			; R80000
	lsl.w	#8,d1
	move.w	d1,d0			; R8G800
	move.b	d2,d0			; R8G8B8
	move.l	d0,d5			; RGB8 background color
	MOVEF.W (hf_colors_per_colorbank-1)-1,d6
hf_dim_colors_loop2
	move.l	(a0),d0			; RGB8
	moveq	#0,d2
	move.b	d0,d2			; B8
	lsr.w	#8,d0
	moveq	#0,d1
	move.b	d0,d1			; G8
	swap	d0			; R8
	mulu.w	d3,d0			; dim red
	divu.w	d4,d0
	mulu.w	d3,d1			; dim green
	divu.w	d4,d1
	mulu.w	d3,d2			; dim blue
	divu.w	d4,d2
	swap	d0			; R80000
	lsl.w	#8,d1
	move.w	d1,d0			; R8G800
	move.b	d2,d0			; R8G8B8
	or.l	d5,d0			; background color
	move.l	d0,(a0)+		; dimmed RGB8
	dbf	d6,hf_dim_colors_loop2
	addq.w	#LONGWORD_SIZE,a0	; skip background color
	addq.w	#1,d3			; decrease brightness
	dbf	d7,hf_dim_colors_loop1
	rts


	CNOP 0,4
init_colors
	CPU_SELECT_COLOR_HIGH_BANK 0
	CPU_INIT_COLOR_HIGH COLOR00,8,pf1_rgb8_color_table
	CPU_INIT_COLOR_HIGH COLOR16,16,spr_rgb8_color_table
	CPU_SELECT_COLOR_HIGH_BANK 1
	CPU_INIT_COLOR_HIGH COLOR00,32
	CPU_SELECT_COLOR_HIGH_BANK 2
	CPU_INIT_COLOR_HIGH COLOR00,32
	CPU_SELECT_COLOR_HIGH_BANK 3
	CPU_INIT_COLOR_HIGH COLOR00,32
	CPU_SELECT_COLOR_HIGH_BANK 4
	CPU_INIT_COLOR_HIGH COLOR00,32
	CPU_SELECT_COLOR_HIGH_BANK 5
	CPU_INIT_COLOR_HIGH COLOR00,32
	CPU_SELECT_COLOR_HIGH_BANK 6
	CPU_INIT_COLOR_HIGH COLOR00,32
	CPU_SELECT_COLOR_HIGH_BANK 7
	CPU_INIT_COLOR_HIGH COLOR00,32

	CPU_SELECT_COLOR_LOW_BANK 0
	CPU_INIT_COLOR_LOW COLOR00,8,pf1_rgb8_color_table
	CPU_INIT_COLOR_LOW COLOR16,16,spr_rgb8_color_table
	CPU_SELECT_COLOR_LOW_BANK 1
	CPU_INIT_COLOR_LOW COLOR00,32
	CPU_SELECT_COLOR_LOW_BANK 2
	CPU_INIT_COLOR_LOW COLOR00,32
	CPU_SELECT_COLOR_LOW_BANK 3
	CPU_INIT_COLOR_LOW COLOR00,32
	CPU_SELECT_COLOR_LOW_BANK 4
	CPU_INIT_COLOR_LOW COLOR00,32
	CPU_SELECT_COLOR_LOW_BANK 5
	CPU_INIT_COLOR_LOW COLOR00,32
	CPU_SELECT_COLOR_LOW_BANK 6
	CPU_INIT_COLOR_LOW COLOR00,32
	CPU_SELECT_COLOR_LOW_BANK 7
	CPU_INIT_COLOR_LOW COLOR00,32
	rts


	CNOP 0,4
spb_init_display_window
	move.w	#diwstrt_bits,DIWSTRT-DMACONR(a6)
	move.w	#diwstop_bits,DIWSTOP-DMACONR(a6)
	move.w	#diwhigh_bits,DIWHIGH-DMACONR(a6) ; OS3.x LoadView() sets DIWHIGH = $0000 -> display glitches
	rts


	CNOP 0,4
init_first_copperlist
	move.l	cl1_display(a3),a0
	bsr.s	cl1_init_playfield_props
	bsr	cl1_init_sprite_pointers
	bsr	cl1_init_bitplane_pointers
	bsr	cl1_init_branches_pointers1
	bsr	cl1_init_branches_pointers2
	bsr	cl1_reset_pointer
	bsr	cl1_init_copper_interrupt
	COP_LISTEND
	move.l	a0,cl_end(a3)		; store pointer to CWAIT end of copperlist
	bsr	cl1_set_sprite_pointers
	bsr	cl1_set_bitplane_pointers
	rts


	COP_INIT_PLAYFIELD_REGISTERS cl1


	COP_INIT_SPRITE_POINTERS cl1


	COP_INIT_BITPLANE_POINTERS cl1


	CNOP 0,4
cl1_init_branches_pointers1
	move.l	#(((cl1_vstart1<<24)|(((cl1_hstart1/4)*2)<<16))|$10000)|$fffe,d0 ; CWAIT
	move.l	cl1_display(a3),d1
	ADDF.L	cl1_extension1_entry+cl1_ext1_subextension1_entry+cl1_subextension1_size,d1
	move.l	#$01000000,d2
	move.l	cl2_display(a3),d4
	swap	d4
	move.w	#COP2LCH,(a0)+
	moveq	#cl1_subextension1_size,d3
	move.w	d4,(a0)+
	swap	d4		
	move.w	#COP2LCL,(a0)+
	move.w	d4,(a0)+
	MOVEF.W cl1_display_y_size1-1,d7
cl1_init_branches_pointers1_loop
	move.l	d0,(a0)+		; CWAIT
	swap	d1
	move.w	#COP1LCH,(a0)+
	add.l	d2,d0			; next scanline
	move.w	d1,(a0)+
	swap	d1		
	move.w	#COP1LCL,(a0)+
	move.w	d1,(a0)+
	add.l	d3,d1			; increase jump in cl1
	COP_MOVEQ 0,COPJMP2
	dbf	d7,cl1_init_branches_pointers1_loop
	rts


	CNOP 0,4
cl1_init_branches_pointers2
	move.l	#(((cl1_vstart2<<24)|(((cl1_hstart2/4)*2)<<16))|$10000)|$fffe,d0 ; CWAIT
	move.l	cl1_display(a3),d1
	ADDF.L	cl1_extension2_entry+cl1_ext2_subextension1_entry+cl1_subextension1_size,d1
	move.l	#$01000000,d2
	move.l	cl2_display(a3),d4
	ADDF.L	cl2_extension2_entry,d4
	swap	d4
	move.w	#COP2LCH,(a0)+
	moveq	#cl1_subextension1_size,d3
	move.w	d4,(a0)+
	swap	d4		
	move.w	#COP2LCL,(a0)+
	move.w	d4,(a0)+
	MOVEF.W cl1_display_y_size2-1,d7
cl1_init_branches_pointers2_loop
	move.l	d0,(a0)+		; CWAIT
	swap	d1
	move.w	#COP1LCH,(a0)+
	add.l	d2,d0			; next scanline
	move.w	d1,(a0)+
	swap	d1		
	move.w	#COP1LCL,(a0)+
	move.w	d1,(a0)+
	add.l	d3,d1			; increase jump in cl1
	COP_MOVEQ 0,COPJMP2
	dbf	d7,cl1_init_branches_pointers2_loop
	rts


	CNOP 0,4
cl1_reset_pointer
	move.l	cl1_display(a3),d0
	swap	d0
	move.w	#COP1LCH,(a0)+
	move.w	d0,(a0)+
	swap	d0		
	move.w	#COP1LCL,(a0)+
	move.w	d0,(a0)+
	rts


	COP_INIT_COPINT cl1,cl1_hstart3,cl1_vstart3,YWRAP


	COP_SET_SPRITE_POINTERS cl1,display,spr_number


	COP_SET_BITPLANE_POINTERS cl1,display,pf1_depth3


	CNOP 0,4
init_second_copperlist
	move.l	cl2_display(a3),a0
	bsr.s	cl2_init_bplcon4_chunky1
	bsr.s	cl2_init_bplcon4_chunky2
	rts


	CNOP 0,4
cl2_init_bplcon4_chunky1
	move.l	#(BPLCON4<<16)|bplcon4_bits,d0
	moveq	#cl2_display_width1-1,d7 ; number of columns
cl2_init_bplcon4_chunky1_loop
	move.l	d0,(a0)+		; BPLCON4
	dbf	d7,cl2_init_bplcon4_chunky1_loop
	COP_MOVEQ 0,COPJMP1
	rts


	CNOP 0,4
cl2_init_bplcon4_chunky2
	move.l	#(BPLCON4<<16)|bplcon4_bits,d0
	moveq	#cl2_display_width2-1,d7 ; number of columns
cl2_init_bplcon4_chunky2_loop
	move.l	d0,(a0)+		; BPLCON4
	dbf	d7,cl2_init_bplcon4_chunky2_loop
	COP_MOVEQ 0,COPJMP1
	rts


	CNOP 0,4
main
	bsr.s	no_sync_routines
	bsr.s	beam_routines
	rts


	CNOP 0,4
no_sync_routines
	rts


	CNOP 0,4
beam_routines
	bsr	wait_copint
	bsr.s	pf1_swap_playfields
	bsr	pf1_set_playfield
	bsr	effects_handler
	bsr	horiz_fader_in1
	bsr	horiz_fader_in2
	bsr	horiz_fader_out1
	bsr	horiz_fader_out2
	bsr	gv_clear_playfield1
	bsr	gv_draw_lines
	bsr	gv_fill_playfield1
	bsr	gv_rotation
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
	move.l	cl_end(a3),COP1LC-DMACONR(a6)
	move.w	d0,COPJMP1-DMACONR(a6)
	move.w	custom_error_code(a3),d1
	rts


	SWAP_PLAYFIELD_BUFFERS pf1,3,pf1_depth3


	SET_PLAYFIELD pf1,pf1_depth3


	CNOP 0,4
gv_clear_playfield1
	movem.l a3-a6,-(a7)
	move.l	a7,save_a7(a3)	
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	move.l	d0,a0
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a4
	move.l	d0,a5
	move.l	d0,a6
	move.l	pf1_construction1(a3),a7
	move.l	(a7),a7
	ADDF.L	pf1_plane_width*pf1_y_size3*pf1_depth3,a7 ; end of playfield
	move.l	d0,a3
	moveq	#4-1,d7			; number of runs
gv_clear_playfield1_loop
	REPT ((pf1_plane_width*pf1_y_size3*pf1_depth3)/56)/4
		movem.l d0-d6/a0-a6,-(a7) ; clear 56 bytes
	ENDR
	dbf	d7,gv_clear_playfield1_loop
	movem.l d0-d6/a0-a6,-(a7)	; clear remaining 160 bytes
	movem.l d0-d6/a0-a6,-(a7)
	movem.l d0-d6/a0-a4,-(a7)
	move.l	variables+save_a7(pc),a7
	movem.l (a7)+,a3-a6
	rts


	CNOP 0,4
gv_rotation
	movem.l a4-a5,-(a7)
	move.w	gv_y_angle(a3),d1
	move.w	d1,d0		
	lea	sine_table(pc),a2	
	move.w	(a2,d0.w*2),d5		; sin(b)
	IFEQ sine_table_length-512
		MOVEF.W sine_table_length-1,d3
	ELSE
		MOVEF.W sine_table_length,d3
	ENDC
	add.w	#sine_table_length/4,d0 ; + 90°
	swap	d5			; high word: sin(b)
	IFEQ sine_table_length-512
		and.w	d3,d0		; remove overflow
	ELSE
		cmp.w	d3,d0		; 360° ?
		blt.s	gv_rotation_skip1
		sub.w	d3,d0		; restart
gv_rotation_skip1
	ENDC
	move.w	(a2,d0.w*2),d5	 	; low word: cos(b)
	addq.w	#gv_y_angle_speed,d1
	IFEQ sine_table_length-512
		and.w	d3,d1		; remove overflow
	ELSE
		cmp.w	d3,d1		; 360° ?
		blt.s	gv_rotation_skip2
		sub.w	d3,d1		; restart
gv_rotation_skip2
	ENDC
	move.w	d1,gv_y_angle(a3) 
	lea	gv_object_coordinates(pc),a0
	lea	gv_xy_coordinates(pc),a1
	move.w	#gv_distance*8,a4
	move.w	#gv_xy_center,a5
	moveq	#gv_object_edge_points_number-1,d7
gv_rotation_loop
	move.w	(a0)+,d0		; x
	move.l	d7,a2		
	move.w	(a0)+,d1		; y
	move.w	(a0)+,d2		; z
	ROTATE_Y_AXIS
; Central projection and translation
	MULSF.W gv_distance,d0,d3	; x projection
	add.w	a4,d2			; z+d
	divs.w	d2,d0			; x' = (x*d)/(z+d)
	MULSF.W gv_distance,d1,d3	; y projection
	add.w	a5,d0			; x' + x center
	move.w	d0,(a1)+		; x position
	divs.w	d2,d1			; y' = (y*d)/(z+d)
	move.l	a2,d7			; loop counter
	add.w	a5,d1			; y' + y center
	move.w	d1,(a1)+		; y position
	dbf	d7,gv_rotation_loop
	movem.l (a7)+,a4-a5
	rts


	CNOP 0,4
gv_draw_lines
	movem.l a3-a5,-(a7)
	bsr	gv_draw_lines_init
	lea	gv_object_info(pc),a0
	lea	gv_xy_coordinates(pc),a1
	move.l	pf1_construction2(a3),a2
	move.l	(a2),a2
	move.l	#((BC0F_SRCA|BC0F_SRCC|BC0F_DEST+NANBC|NABC|ABNC)<<16)|(BLTCON1F_LINE+BLTCON1F_SING),a3 ; minterm line drawing mode
	move.w	#pf1_plane_width,a4
	moveq	#gv_object_faces_number-1,d7
gv_draw_lines_loop1
	move.l	(a0)+,a5		; p starts
	swap	d7			; save faces counter
	move.w	(a5),d4			; p1 start
	move.w	WORD_SIZE(a5),d5	; p2 start
	move.w	LONGWORD_SIZE(a5),d6	; p3 start
	movem.w (a1,d5.w*2),d0-d1	; p2(x,y)
	movem.w (a1,d6.w*2),d2-d3	; p3(x,y)
	sub.w	d0,d2			; xv = xp3-xp2
	sub.w	(a1,d4.w*2),d0		; xu = xp2-xp1
	sub.w	d1,d3			; yv = yp3-yp2
	sub.w	WORD_SIZE(a1,d4.w*2),d1	; yu = yp2-yp1
	muls.w	d3,d0			; xu*yv
	move.w	(a0)+,d7		; face color
	muls.w	d2,d1			; yu*xv
	move.w	(a0)+,d6		; number of lines of face
	sub.l	d0,d1			; zn = (yu*xv)-(xu*yv)
	bmi.s	gv_draw_lines_loop2
	lsr.w	#2,d7			; COLOR02/04 -> COLOR00/01
	beq	gv_draw_lines_skip3
gv_draw_lines_loop2
	move.w	(a5)+,d0		; p1,p2 starts
	move.w	(a5),d2
	movem.w (a1,d0.w*2),d0-d1	; p1(x,y)
	movem.w (a1,d2.w*2),d2-d3	; p2(x,y)
	GET_LINE_PARAMETERS gv,AREAFILL,,,gv_draw_lines_skip2
	add.l	a3,d0			; remaining BLTCON0 & BLTCON1 bits
	add.l	a2,d1			; playfield
	cmp.w	#1,d7			; bitplane 1 ?
	beq.s	gv_draw_lines_skip1
	add.l	a4,d1			; next bitplane
	cmp.w	#2,d7			; bitplane 2 ?
	beq.s	gv_draw_lines_skip1
	add.l	a4,d1			; next bitplane
gv_draw_lines_skip1
	WAITBLIT
	move.l	d0,BLTCON0-DMACONR(a6) 	; low word: BLTCON1, high word: BLTCON0
	move.l	d1,BLTCPT-DMACONR(a6)	; playfield read
	move.w	d3,BLTAPTL-DMACONR(a6)	; (4*dy)-(2*dx)
	move.l	d1,BLTDPT-DMACONR(a6)	; playfield write
	move.l	d4,BLTBMOD-DMACONR(a6) 	; low word word: 4*(dy-dx), high word: 4*dy
	move.w	d2,BLTSIZE-DMACONR(a6)
gv_draw_lines_skip2
	dbf	d6,gv_draw_lines_loop2
gv_draw_lines_skip3
	swap	d7			; face counter
	dbf	d7,gv_draw_lines_loop1
	movem.l (a7)+,a3-a5
	rts
	CNOP 0,4
gv_draw_lines_init
	move.w	#DMAF_BLITHOG|DMAF_SETCLR,DMACON-DMACONR(a6)
	WAITBLIT
	move.l	#$ffff8000,BLTBDAT-DMACONR(a6) ; low word: line texture starts with MSB,  high word: line texture
	moveq	#-1,d0
	move.l	d0,BLTAFWM-DMACONR(a6)
	moveq	#pf1_plane_width*pf1_depth3,d0 ; moduli interleaved bitmaps
	move.w	d0,BLTCMOD-DMACONR(a6)
	move.w	d0,BLTDMOD-DMACONR(a6)
	rts


	CNOP 0,4
gv_fill_playfield1
	move.l	pf1_construction2(a3),a0
	move.l	(a0),a0
	ADDF.L	(pf1_plane_width*pf1_y_size3*pf1_depth3)-2,a0 ; end of playfield
	WAITBLIT
	move.w	#DMAF_BLITHOG,DMACON-DMACONR(a6)
	move.l	#((BC0F_SRCA|BC0F_DEST|ANBNC|ANBC|ABNC|ABC)<<16)|(BLTCON1F_DESC+BLTCON1F_EFE),BLTCON0-DMACONR(a6) ; minterm D = A, fill mode, backwards
	move.l	a0,BLTAPT-DMACONR(a6)	; source
	move.l	a0,BLTDPT-DMACONR(a6)	; destination
	moveq	#0,d0
	move.l	d0,BLTAMOD-DMACONR(a6)	; A&D moduli
	move.w	#((gv_fill_blit_y_size*gv_fill_blit_depth)<<6)|(gv_fill_blit_x_size/WORD_BITS),BLTSIZE-DMACONR(a6)
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
	lea	sine_table(pc),a0	
	move.w	(a0,d2.w*2),d0		; sin(w)
	muls.w	#spb_y_radius*2,d0	; y' = (sin(w)*yr)/2^15
	swap	d0
	add.w	#spb_y_center,d0	; y' + y center
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
	lea	sine_table(pc),a0	
	move.w	(a0,d2.w*2),d0		; cos(w)
	muls.w	#spb_y_radius*2,d0	; y' = (cos(w)*yr)/2^15
	swap	d0
	add.w	#spb_y_center,d0	; y' + y center
	add.w	#spbo_y_angle_speed,d2
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
	move.l	cl1_display(a3),a1
	moveq	#spb_min_VSTART,d1
	add.w	d0,d1
	cmp.w	d3,d1			; VSTART max ?
	ble.s	spb_set_display_window_skip1
	move.w	d3,d1			; correct VSTART
spb_set_display_window_skip1
	move.b	d1,cl1_DIWSTRT+WORD_SIZE(a1) ; VSTART V0..V7
	move.w	d1,d2
	add.w	#visible_lines_number,d2 ; VSTOP
	cmp.w	d3,d2			; VSTOP max ?
	ble.s	spb_set_display_window_skip2
	move.w	d3,d2			; correct VSTOP
spb_set_display_window_skip2
	move.b	d2,cl1_DIWSTOP+WORD_SIZE(a1) ; VSTOP V0..V7
	lsr.w	#8,d1			; adjust V8 bit
	move.b	d1,d2			; add V8 bit
	or.w	#diwhigh_bits&(~(DIWHIGHF_VSTART8|DIWHIGHF_VSTOP8)),d2
	move.w	d2,cl1_DIWHIGH+WORD_SIZE(a1)
	rts


	CNOP 0,4
horiz_fader_in1
	tst.w	hfi1_active(a3)
	bne.s	horiz_fader_in1_quit
	move.w	hf1_bplam_table_start(a3),d2
	move.w	d2,d0
	cmp.w	#cl2_display_width1+hf_colorbanks_number-1,d0 ; end of table ?
	blt.s	horiz_fader_in1_skip
	move.w	#FALSE,hfi1_active(a3)
	bra.s	horiz_fader_in1_quit
	CNOP 0,4
horiz_fader_in1_skip
	addq.w	#BYTE_SIZE,d2		; next entry
	move.w	d2,hf1_bplam_table_start(a3)
	lea	hf_bplam_table(pc),a0
	lea	(a0,d0.w),a0		; offset
	move.l	cl2_display(a3),a1
	ADDF.W	cl2_extension1_entry+cl2_ext1_BPLCON4_24+WORD_SIZE+BYTE_SIZE,a1
	MOVEF.W cl2_display_width1-1,d7
horiz_fader_in1_loop
	move.b	(a0)+,d0
	move.b	d0,d1			; odd & even sprites color switch
	lsr.b	#4,d1
	or.b	d1,d0
	move.b	d0,(a1)
	subq.w	#LONGWORD_SIZE,a1	; next column
	dbf	d7,horiz_fader_in1_loop
horiz_fader_in1_quit
	rts


	CNOP 0,4
horiz_fader_in2
	tst.w	hfi2_active(a3)
	bne.s	horiz_fader_in2_quit
	move.w	hf2_bplam_table_start(a3),d2
	move.w	d2,d0
	cmp.w	#cl2_display_width2+hf_colorbanks_number-1,d0 ; end of table ?
	blt.s	horiz_fader_in2_skip
	move.w	#FALSE,hfi2_active(a3)
	bra.s	horiz_fader_in2_quit
	CNOP 0,4
horiz_fader_in2_skip
	addq.w	#BYTE_SIZE,d2		; next entry
	move.w	d2,hf2_bplam_table_start(a3)
	lea	hf_bplam_table(pc),a0
	lea	(a0,d0.w),a0		; offset
	move.l	cl2_display(a3),a1
	ADDF.W	cl2_extension2_entry+cl2_ext2_BPLCON4_24+3,a1
	MOVEF.W cl2_display_width2-1,d7
horiz_fader_in2_loop
	move.b	(a0)+,d0
	move.b	d0,d1			; odd & even sprites color switch
	lsr.b	#4,d1
	or.b	d1,d0
	move.b	d0,(a1)
	subq.w	#LONGWORD_SIZE,a1	; next column
	dbf	d7,horiz_fader_in2_loop
horiz_fader_in2_quit
	rts


	CNOP 0,4
horiz_fader_out1
	tst.w	hfo1_active(a3)
	bne.s	horiz_fader_out1_quit
	move.w	hf1_bplam_table_start(a3),d2
	move.w	d2,d0
	bpl.s	horiz_fader_out1_skip
	move.w	#FALSE,hfo1_active(a3)
	bra.s	horiz_fader_out1_quit
	CNOP 0,4
horiz_fader_out1_skip
	subq.w	#BYTE_SIZE,d2
	move.w	d2,hf1_bplam_table_start(a3)
	lea	hf_bplam_table(pc),a0
	lea	(a0,d0.w),a0		; offset
	move.l	cl2_display(a3),a1
	ADDF.W	cl2_extension1_entry+3,a1
	MOVEF.W cl2_display_width1-1,d7
horiz_fader_out1_loop
	move.b	(a0)+,d0
	move.b	d0,d1			; odd & even sprites color switch
	lsr.b	#4,d1
	or.b	d1,d0
	move.b	d0,(a1)
	addq.w	#LONGWORD_SIZE,a1	; next column
	dbf	d7,horiz_fader_out1_loop
horiz_fader_out1_quit
	rts


	CNOP 0,4
horiz_fader_out2
	tst.w	hfo2_active(a3)
	bne.s	horiz_fader_out2_quit
	move.w	hf2_bplam_table_start(a3),d2
	move.w	d2,d0
	bpl.s	horiz_fader_out2_skip
	move.w	#FALSE,hfo2_active(a3)
	bra.s	horiz_fader_out2_quit
	CNOP 0,4
horiz_fader_out2_skip
	subq.w	#BYTE_SIZE,d2		; penultimate entry
	move.w	d2,hf2_bplam_table_start(a3)
	lea	hf_bplam_table(pc),a0
	lea	(a0,d0.w),a0		; offset
	move.l	cl2_display(a3),a1
	ADDF.W	cl2_extension2_entry+3,a1
	MOVEF.W cl2_display_width2-1,d7
horiz_fader_out2_loop
	move.b	(a0)+,d0
	move.b	d0,d1			; odd & even sprites color switch
	lsr.b	#4,d1
	or.b	d1,d0
	move.b	d0,(a1)
	addq.w	#LONGWORD_SIZE,a1	; next column
	dbf	d7,horiz_fader_out2_loop
horiz_fader_out2_quit
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
	beq.s	eh_start_horiz_fader_in1
	subq.w	#1,d0
	beq.s	eh_start_horiz_fader_in2
	subq.w	#1,d0
	beq.s	eh_start_horiz_fader_out
	subq.w	#1,d0
	beq.s	eh_start_scroll_pf_bottom_out
effects_handler_quit
	rts
	CNOP 0,4
eh_start_scroll_pf_bottom_in
	clr.w	spbi_active(a3)
	rts
	CNOP 0,4
eh_start_horiz_fader_in1
	clr.w	hfi1_active(a3)
	rts
	CNOP 0,4
eh_start_horiz_fader_in2
	clr.w	hfi2_active(a3)
	rts
	CNOP 0,4
eh_start_horiz_fader_out
	moveq	#TRUE,d0
	move.w	d0,hfo1_active(a3)
	move.w	d0,hfo2_active(a3)
	rts
	CNOP 0,4
eh_start_scroll_pf_bottom_out
	clr.w	spbo_active(a3)
	rts


	CNOP 0,4
mouse_handler
	btst	#CIAB_GAMEPORT0,CIAPRA(a4) ; LMB pressed ?
	beq.s	mouse_handler_skip
	moveq	#RETURN_OK,d0
	rts
	CNOP 0,4
mouse_handler_skip
	moveq	#RETURN_WARN,d0		; exit
	rts


	INCLUDE "int-autovectors-handlers.i"

	CNOP 0,4
nmi_interrupt_server
	rts


	INCLUDE "help-routines.i"


	INCLUDE "sys-structures.i"


	CNOP 0,4
pf1_rgb8_color_table
	REPT 8			; pf1_colors_number
		DC.L color00_bits
	ENDR


	CNOP 0,4
spr_rgb8_color_table
	REPT hf_colors_per_colorbank
		DC.L color00_bits
	ENDR
	INCLUDE "Superglenz:colortables/192x39x4-Title.ct"
	INCLUDE "Superglenz:colortables/192x39x4-Title.ct"
	REPT 8
		DC.L color00_bits
	ENDR
	INCLUDE "Superglenz:colortables/192x39x4-Title.ct"
	INCLUDE "Superglenz:colortables/192x39x4-Title.ct"
	REPT 8
		DC.L color00_bits
	ENDR
	INCLUDE "Superglenz:colortables/192x39x4-Title.ct"
	INCLUDE "Superglenz:colortables/192x39x4-Title.ct"
	REPT 8
		DC.L color00_bits
	ENDR
	INCLUDE "Superglenz:colortables/192x39x4-Title.ct"
	INCLUDE "Superglenz:colortables/192x39x4-Title.ct"
	REPT 8
		DC.L color00_bits
	ENDR
	INCLUDE "Superglenz:colortables/192x39x4-Title.ct"
	INCLUDE "Superglenz:colortables/192x39x4-Title.ct"
	REPT 8
		DC.L color00_bits
	ENDR
	INCLUDE "Superglenz:colortables/192x39x4-Title.ct"
	INCLUDE "Superglenz:colortables/192x39x4-Title.ct"
	REPT 8
		DC.L color00_bits
	ENDR
	INCLUDE "Superglenz:colortables/192x39x4-Title.ct"
	INCLUDE "Superglenz:colortables/192x39x4-Title.ct"
	REPT 8
		DC.L color00_bits
	ENDR
	INCLUDE "Superglenz:colortables/192x39x4-Title.ct"
	INCLUDE "Superglenz:colortables/192x39x4-Title.ct"
	REPT 8
		DC.L color00_bits
	ENDR
	INCLUDE "Superglenz:colortables/192x39x4-Title.ct"
	INCLUDE "Superglenz:colortables/192x39x4-Title.ct"
	REPT 8
		DC.L color00_bits
	ENDR
	INCLUDE "Superglenz:colortables/192x39x4-Title.ct"
	INCLUDE "Superglenz:colortables/192x39x4-Title.ct"
	REPT 8
		DC.L color00_bits
	ENDR
	INCLUDE "Superglenz:colortables/192x39x4-Title.ct"
	INCLUDE "Superglenz:colortables/192x39x4-Title.ct"
	REPT 8
		DC.L color00_bits
	ENDR
	INCLUDE "Superglenz:colortables/192x39x4-Title.ct"
	INCLUDE "Superglenz:colortables/192x39x4-Title.ct"
	REPT 8
		DC.L color00_bits
	ENDR
	INCLUDE "Superglenz:colortables/192x39x4-Title.ct"
	INCLUDE "Superglenz:colortables/192x39x4-Title.ct"
	REPT 8
		DC.L color00_bits
	ENDR
	INCLUDE "Superglenz:colortables/192x39x4-Title.ct"
	INCLUDE "Superglenz:colortables/192x39x4-Title.ct"
	REPT 8
		DC.L color00_bits
	ENDR


	CNOP 0,4
spr_pointers_display
	DS.L spr_number


	CNOP 0,2
sine_table
	IFEQ sine_table_length-512
		INCLUDE "sine-table-512x16.i"
	ELSE
		INCLUDE "sine-table-360x16.i"
	ENDC


; Morph-Glenz-Vectors
	CNOP 0,4
gv_rgb8_color_table
	INCLUDE "Blitter.AGA:graphics/1xGlenz-Colorgradient5.ct"

	CNOP 0,2
gv_object_coordinates
	DC.W 0,-(36*8),0		; P0
	DC.W -(19*8),-(36*8),-(48*8)	; P1
	DC.W 19*8,-(36*8),-(48*8)	; P2
	DC.W 48*8,-(36*8),-(19*8)	; P3
	DC.W 48*8,-(36*8),19*8		; P4
	DC.W 19*8,-(36*8),48*8		; P5
	DC.W -(19*8),-(36*8),48*8	; P6
	DC.W -(48*8),-(36*8),19*8	; P7
	DC.W -(48*8),-(36*8),-(19*8)	; P8
	DC.W 0,-(24*8),-(58*8)		; P9
	DC.W 40*8,-(24*8),-(40*8)	; P10
	DC.W 58*8,-(24*8),0		; P11
	DC.W 40*8,-(24*8),40*8		; P12
	DC.W 0,-(24*8),58*8		; P13
	DC.W -(40*8),-(24*8),40*8	; P14
	DC.W -(58*8),-(24*8),0		; P15
	DC.W -(40*8),-(24*8),-(40*8)	; P16
	DC.W -(27*8),-(12*8),-(68*8)	; P17
	DC.W 27*8,-(12*8),-(68*8)	; P18
	DC.W 68*8,-(12*8),-(27*8)	; P19
	DC.W 68*8,-(12*8),27*8		; P20
	DC.W 27*8,-(12*8),68*8		; P21
	DC.W -(27*8),-(12*8),68*8	; P22
	DC.W -(68*8),-(12*8),27*8	; P23
	DC.W -(68*8),-(12*8),-(27*8)	; P24
	DC.W 0,48*8,0			; P25

	CNOP 0,4
gv_object_info
; 1. face
	DC.L 0				; face coordinates
	DC.W gv_object_face1_color
	DC.W gv_object_face1_lines_number-1
; 2. face
	DC.L 0				; face coordinates
	DC.W gv_object_face2_color
	DC.W gv_object_face2_lines_number-1
; 3. face
	DC.L 0				; face coordinates
	DC.W gv_object_face3_color
	DC.W gv_object_face3_lines_number-1
; 4. face
	DC.L 0				; face coordinates
	DC.W gv_object_face4_color
	DC.W gv_object_face4_lines_number-1
; 5. face
	DC.L 0				; face coordinates
	DC.W gv_object_face5_color
	DC.W gv_object_face5_lines_number-1
; 6. face
	DC.L 0				; face coordinates
	DC.W gv_object_face6_color
	DC.W gv_object_face6_lines_number-1
; 7. face
	DC.L 0				; face coordinates
	DC.W gv_object_face7_color
	DC.W gv_object_face7_lines_number-1
; 8. face
	DC.L 0				; face coordinates
	DC.W gv_object_face8_color
	DC.W gv_object_face8_lines_number-1

; 9. face
	DC.L 0				; face coordinates
	DC.W gv_object_face9_color
	DC.W gv_object_face9_lines_number-1
; 10. face
	DC.L 0				; face coordinates
	DC.W gv_object_face10_color
	DC.W gv_object_face10_lines_number-1
; 11. face
	DC.L 0				; face coordinates
	DC.W gv_object_face11_color
	DC.W gv_object_face11_lines_number-1
; 12. face
	DC.L 0				; face coordinates
	DC.W gv_object_face12_color
	DC.W gv_object_face12_lines_number-1

; 13. face
	DC.L 0				; face coordinates
	DC.W gv_object_face13_color
	DC.W gv_object_face13_lines_number-1
; 14. face
	DC.L 0				; face coordinates
	DC.W gv_object_face14_color
	DC.W gv_object_face14_lines_number-1
; 15. face
	DC.L 0				; face coordinates
	DC.W gv_object_face15_color
	DC.W gv_object_face15_lines_number-1
; 16. face
	DC.L 0				; face coordinates
	DC.W gv_object_face16_color
	DC.W gv_object_face16_lines_number-1

; 17. face
	DC.L 0				; face coordinates
	DC.W gv_object_face17_color
	DC.W gv_object_face17_lines_number-1
; 18. face
	DC.L 0				; face coordinates
	DC.W gv_object_face18_color
	DC.W gv_object_face18_lines_number-1
; 19. face
	DC.L 0				; face coordinates
	DC.W gv_object_face19_color
	DC.W gv_object_face19_lines_number-1
; 20. face
	DC.L 0				; face coordinates
	DC.W gv_object_face20_color
	DC.W gv_object_face20_lines_number-1

; 21. face
	DC.L 0				; face coordinates
	DC.W gv_object_face21_color
	DC.W gv_object_face21_lines_number-1
; 22. face
	DC.L 0				; face coordinates
	DC.W gv_object_face22_color
	DC.W gv_object_face22_lines_number-1
; 23. face
	DC.L 0				; face coordinates
	DC.W gv_object_face23_color
	DC.W gv_object_face23_lines_number-1
; 24. face
	DC.L 0				; face coordinates
	DC.W gv_object_face24_color
	DC.W gv_object_face24_lines_number-1

; 25. face
	DC.L 0				; face coordinates
	DC.W gv_object_face25_color
	DC.W gv_object_face25_lines_number-1
; 26. face
	DC.L 0				; face coordinates
	DC.W gv_object_face26_color
	DC.W gv_object_face26_lines_number-1
; 27. face
	DC.L 0				; face coordinates
	DC.W gv_object_face27_color
	DC.W gv_object_face27_lines_number-1
; 28. face
	DC.L 0				; face coordinates
	DC.W gv_object_face28_color
	DC.W gv_object_face28_lines_number-1

; 29. face
	DC.L 0				; face coordinates
	DC.W gv_object_face29_color
	DC.W gv_object_face29_lines_number-1
; 30. face
	DC.L 0				; face coordinates
	DC.W gv_object_face30_color
	DC.W gv_object_face30_lines_number-1
; 31. face
	DC.L 0				; face coordinates
	DC.W gv_object_face31_color
	DC.W gv_object_face31_lines_number-1
; 32. face
	DC.L 0				; face coordinates
	DC.W gv_object_face32_color
	DC.W gv_object_face32_lines_number-1

; 33. face
	DC.L 0				; face coordinates
	DC.W gv_object_face33_color
	DC.W gv_object_face33_lines_number-1
; 34. face
	DC.L 0				; face coordinates
	DC.W gv_object_face34_color
	DC.W gv_object_face34_lines_number-1
; 35. face
	DC.L 0				; face coordinates
	DC.W gv_object_face35_color
	DC.W gv_object_face35_lines_number-1
; 36. face
	DC.L 0				; face coordinates
	DC.W gv_object_face36_color
	DC.W gv_object_face36_lines_number-1

; 37. face
	DC.L 0				; face coordinates
	DC.W gv_object_face37_color
	DC.W gv_object_face37_lines_number-1
; 38. face
	DC.L 0				; face coordinates
	DC.W gv_object_face38_color
	DC.W gv_object_face38_lines_number-1
; 39. face
	DC.L 0				; face coordinates
	DC.W gv_object_face39_color
	DC.W gv_object_face39_lines_number-1
; 40. face
	DC.L 0				; face coordinates
	DC.W gv_object_face40_color
	DC.W gv_object_face40_lines_number-1

; 41. face
	DC.L 0				; face coordinates
	DC.W gv_object_face41_color
	DC.W gv_object_face41_lines_number-1
; 42. face
	DC.L 0				; face coordinates
	DC.W gv_object_face42_color
	DC.W gv_object_face42_lines_number-1
; 43. face
	DC.L 0				; face coordinates
	DC.W gv_object_face43_color
	DC.W gv_object_face43_lines_number-1
; 44. face
	DC.L 0				; face coordinates
	DC.W gv_object_face44_color
	DC.W gv_object_face44_lines_number-1
; 45. face
	DC.L 0				; face coordinates
	DC.W gv_object_face45_color
	DC.W gv_object_face45_lines_number-1
; 46. face
	DC.L 0				; face coordinates
	DC.W gv_object_face46_color
	DC.W gv_object_face46_lines_number-1
; 47. face
	DC.L 0				; face coordinates
	DC.W gv_object_face47_color
	DC.W gv_object_face47_lines_number-1
; 48. face
	DC.L 0				; face coordinates
	DC.W gv_object_face48_color
	DC.W gv_object_face48_lines_number-1

	CNOP 0,2
gv_object_edges
	DC.W 0*2,6*2,5*2,0*2		; face 5 top, triangle 12 o'clock
	DC.W 0*2,5*2,4*2,0*2		; face 4 top, triangle 1,5 o'clock
	DC.W 3*2,0*2,4*2,3*2		; face 3 top, triangle 3 o'clock
	DC.W 0*2,3*2,2*2,0*2		; face 2 top, triangle 4,5 o'clock
	DC.W 1*2,0*2,2*2,1*2		; face 1 top, triangle 6 o'clock
	DC.W 1*2,8*2,0*2,1*2		; face 8 top, triangle 7,5 o'clock
	DC.W 8*2,7*2,0*2,8*2		; face 7 top, triangle 9 o'clock
	DC.W 0*2,7*2,6*2,0*2		; face 6 top, triangle 10,5 o'clock

	DC.W 2*2,9*2,1*2,2*2		; face 9 vorne, triangle 12 o'clock
	DC.W 2*2,18*2,9*2,2*2		; face 12 vorne, triangle 3 o'clock
	DC.W 9*2,18*2,17*2,9*2		; face 11 vorne, triangle 6 o'clock
	DC.W 1*2,9*2,17*2,1*2		; face 10 vorne, triangle 9 o'clock

	DC.W 3*2,10*2,2*2,3*2		; face 13 vorne rechts, triangle 12 o'clock
	DC.W 19*2,10*2,3*2,19*2		; face 16 vorne rechts, triangle 3 o'clock
	DC.W 10*2,19*2,18*2,10*2	; face 15 vorne rechts, triangle 6 o'clock
	DC.W 2*2,10*2,18*2,2*2		; face 14 vorne rechts, triangle 9 o'clock

	DC.W 4*2,11*2,3*2,4*2		; face 17 rechts, triangle 12 o'clock
	DC.W 4*2,20*2,11*2,4*2		; face 20 rechts, triangle 3 o'clock
	DC.W 11*2,20*2,19*2,11*2	; face 19 rechts, triangle 6 o'clock
	DC.W 3*2,11*2,19*2,3*2		; face 18 rechts, triangle 9 o'clock

	DC.W 5*2,12*2,4*2,5*2		; face 21 hinten rechts, triangle 12 o'clock
	DC.W 5*2,21*2,12*2,5*2		; face 24 hinten rechts, triangle 3 o'clock
	DC.W 12*2,21*2,20*2,12*2	; face 23 hinten rechts, triangle 6 o'clock
	DC.W 12*2,20*2,4*2,12*2		; face 22 hinten rechts, triangle 9 o'clock

	DC.W 6*2,13*2,5*2,6*2		; face 25 hinten, triangle 12 o'clock
	DC.W 6*2,22*2,13*2,6*2		; face 28 hinten, triangle 3 o'clock
	DC.W 13*2,22*2,21*2,13*2	; face 27 hinten, triangle 6 o'clock
	DC.W 5*2,13*2,21*2,5*2		; face 26 hinten, triangle 9 o'clock

	DC.W 7*2,14*2,6*2,7*2		; face 29 hinten links, triangle 12 o'clock
	DC.W 7*2,23*2,14*2,7*2		; face 32 hinten links, triangle 3 o'clock
	DC.W 14*2,23*2,22*2,14*2	; face 31 hinten links, triangle 6 o'clock
	DC.W 6*2,14*2,22*2,6*2		; face 30 hinten links, triangle 9 o'clock

	DC.W 8*2,15*2,7*2,8*2		; face 33 links, triangle 12 o'clock
	DC.W 8*2,24*2,15*2,8*2		; face 36 links, triangle 3 o'clock
	DC.W 15*2,24*2,23*2,15*2	; face 35 links, triangle 6 o'clock
	DC.W 7*2,15*2,23*2,7*2		; face 34 links, triangle 9 o'clock

	DC.W 1*2,16*2,8*2,1*2		; face 37 vorne links, triangle 12 o'clock
	DC.W 1*2,17*2,16*2,1*2		; face 40 vorne links, triangle 3 o'clock
	DC.W 16*2,17*2,24*2,16*2	; face 39 vorne links, triangle 6 o'clock
	DC.W 8*2,16*2,24*2,8*2		; face 38 vorne links, triangle 9 o'clock

	DC.W 25*2,21*2,22*2,25*2	; face 45 unten, triangle 12 o'clock
	DC.W 25*2,20*2,21*2,25*2	; face 44 unten, triangle 1,5 o'clock
	DC.W 19*2,20*2,25*2,19*2	; face 43 unten, triangle 3 o'clock
	DC.W 18*2,19*2,25*2,18*2	; face 42 unten, triangle 4,5 o'clock
	DC.W 17*2,18*2,25*2,17*2	; face 41 unten, triangle 6 o'clock
	DC.W 17*2,25*2,24*2,17*2	; face 48 unten, triangle 7,5 o'clock
	DC.W 24*2,25*2,23*2,24*2	; face 47 unten, triangle 9 o'clock
	DC.W 25*2,22*2,23*2,25*2	; face 46 unten, triangle 10,5 o'clock

	CNOP 0,2
gv_xy_coordinates
	DS.W gv_object_edge_points_number*2


; Horiz-Fader
hf_bplam_table
; from dark to bright
	REPT cl2_display_width1
		DC.B 256-(hf_colors_per_colorbank*15)
	ENDR
	DC.B 256-(hf_colors_per_colorbank*14)
	DC.B 256-(hf_colors_per_colorbank*13)
	DC.B 256-(hf_colors_per_colorbank*12)
	DC.B 256-(hf_colors_per_colorbank*11)
	DC.B 256-(hf_colors_per_colorbank*10)
	DC.B 256-(hf_colors_per_colorbank*9)
	DC.B 256-(hf_colors_per_colorbank*8)
	DC.B 256-(hf_colors_per_colorbank*7)
	DC.B 256-(hf_colors_per_colorbank*6)
	DC.B 256-(hf_colors_per_colorbank*5)
	DC.B 256-(hf_colors_per_colorbank*4)
	DC.B 256-(hf_colors_per_colorbank*3)
	DC.B 256-(hf_colors_per_colorbank*2)
	REPT cl2_display_width1
		DC.B 256-(hf_colors_per_colorbank*1)
	ENDR


	INCLUDE "sys-variables.i"


	INCLUDE "sys-names.i"


	INCLUDE "error-texts.i"


	EVEN


; Gfx data

; Title
title_image_data		SECTION title_gfx,DATA
	INCBIN "Superglenz:graphics/192x39x4-Title.rawblit"

; RSE letters
rse_letters_image_data		SECTION rse_letters_gfx,DATA
	INCBIN "Superglenz:graphics/3x64x16x4-RSE.rawblit"

	END
