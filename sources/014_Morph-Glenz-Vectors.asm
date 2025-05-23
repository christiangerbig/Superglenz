; Morphing 1x128 faces glenz on a 160x160 screen
; Copper waits for blitter
; Beam posistion timing
; 64 kByte aligned playfield


	MC68040


	XDEF start_014_morph_glenz_vectors

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
pf1_y_size1			EQU 160+911
pf1_depth1			EQU 3
pf1_x_size2			EQU 192
pf1_y_size2			EQU 160+911
pf1_depth2			EQU 3
pf1_x_size3			EQU 192
pf1_y_size3			EQU 160+911
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

pixel_per_line			EQU 192
visible_pixels_number		EQU 160
visible_lines_number		EQU 160
MINROW				EQU VSTOP_OVERSCAN_PAL

pf_pixel_per_datafetch		EQU 64	; 4x

display_window_hstart		EQU HSTART_160_PIXEL
display_window_vstart		EQU MINROW
display_window_hstop		EQU HSTOP_160_pixel
display_window_vstop		EQU VSTOP_OVERSCAN_PAL

pf1_plane_width			EQU pf1_x_size3/8
data_fetch_width		EQU pixel_per_line/8
pf1_plane_moduli		EQU (pf1_plane_width*(pf1_depth3-1))+pf1_plane_width-data_fetch_width

diwstrt_bits			EQU ((display_window_vstart&$ff)*DIWSTRTF_V0)|(display_window_hstart&$ff)
diwstop_bits			EQU ((display_window_vstop&$ff)*DIWSTOPF_V0)|(display_window_hstop&$ff)
ddfstrt_bits			EQU DDFSTART_192_PIXEL_4X
ddfstop_bits			EQU DDFSTOP_192_PIXEL_4X
bplcon0_bits			EQU BPLCON0F_ECSENA|((pf_depth>>3)*BPLCON0F_BPU3)|(BPLCON0F_COLOR)|((pf_depth&$07)*BPLCON0F_BPU0)
bplcon1_bits			EQU $4400
bplcon2_bits			EQU 0
bplcon3_bits1			EQU 0
bplcon3_bits2			EQU bplcon3_bits1|BPLCON3F_LOCT
bplcon4_bits			EQU 0
diwhigh_bits			EQU (((display_window_hstop&$100)>>8)*DIWHIGHF_HSTOP8)|(((display_window_vstop&$700)>>8)*DIWHIGHF_VSTOP8)+(((display_window_hstart&$100)>>8)*DIWHIGHF_HSTART8)+((display_window_vstart&$700)>>8)
fmode_bits			EQU FMODEF_BPL32|FMODEF_BPAGEM

cl2_hstart			EQU $00
cl2_vstart			EQU beam_position&$ff

sine_table_length		EQU 512

; Morph-Glenz-Vectors
mgv_rot_d			EQU 512
mgv_rot_xy_center		EQU visible_lines_number/2

mgv_rot_x_angle_speed_radius	EQU 4
mgv_rot_x_angle_speed_center	EQU 6
mgv_rot_x_angle_speed_speed	EQU 4

mgv_rot_y_angle_speed_radius	EQU 4
mgv_rot_y_angle_speed_center	EQU 4
mgv_rot_y_angle_speed_speed	EQU 2

mgv_rot_z_angle_speed_radius	EQU 1
mgv_rot_z_angle_speed_center	EQU 2
mgv_rot_z_angle_speed_speed	EQU 2

mgv_object_edge_points_number	EQU 66
mgv_object_edge_points_per_face	EQU 3
mgv_object_faces_number		EQU 128

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
mgv_object_face9_color		EQU 2
mgv_object_face9_lines_number	EQU 3
mgv_object_face10_color		EQU 4
mgv_object_face10_lines_number	EQU 3
mgv_object_face11_color		EQU 2
mgv_object_face11_lines_number	EQU 3
mgv_object_face12_color		EQU 4
mgv_object_face12_lines_number	EQU 3
mgv_object_face13_color		EQU 2
mgv_object_face13_lines_number	EQU 3
mgv_object_face14_color		EQU 4
mgv_object_face14_lines_number	EQU 3
mgv_object_face15_color		EQU 2
mgv_object_face15_lines_number	EQU 3
mgv_object_face16_color		EQU 4
mgv_object_face16_lines_number	EQU 3

mgv_object_face17_color		EQU 2
mgv_object_face17_lines_number	EQU 3
mgv_object_face18_color		EQU 4
mgv_object_face18_lines_number	EQU 3
mgv_object_face19_color		EQU 2
mgv_object_face19_lines_number	EQU 3

mgv_object_face20_color		EQU 4
mgv_object_face20_lines_number	EQU 3
mgv_object_face21_color		EQU 2
mgv_object_face21_lines_number	EQU 3
mgv_object_face22_color		EQU 4
mgv_object_face22_lines_number	EQU 3

mgv_object_face23_color		EQU 2
mgv_object_face23_lines_number	EQU 3
mgv_object_face24_color		EQU 4
mgv_object_face24_lines_number	EQU 3
mgv_object_face25_color		EQU 2
mgv_object_face25_lines_number	EQU 3

mgv_object_face26_color		EQU 4
mgv_object_face26_lines_number	EQU 3
mgv_object_face27_color		EQU 2
mgv_object_face27_lines_number	EQU 3
mgv_object_face28_color		EQU 4
mgv_object_face28_lines_number	EQU 3

mgv_object_face29_color		EQU 2
mgv_object_face29_lines_number	EQU 3
mgv_object_face30_color		EQU 4
mgv_object_face30_lines_number	EQU 3
mgv_object_face31_color		EQU 2
mgv_object_face31_lines_number	EQU 3

mgv_object_face32_color		EQU 4
mgv_object_face32_lines_number	EQU 3
mgv_object_face33_color		EQU 2
mgv_object_face33_lines_number	EQU 3
mgv_object_face34_color		EQU 4
mgv_object_face34_lines_number	EQU 3

mgv_object_face35_color		EQU 2
mgv_object_face35_lines_number	EQU 3
mgv_object_face36_color		EQU 4
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
mgv_object_face49_color		EQU 2
mgv_object_face49_lines_number	EQU 3

mgv_object_face50_color		EQU 4
mgv_object_face50_lines_number	EQU 3
mgv_object_face51_color		EQU 2
mgv_object_face51_lines_number	EQU 3
mgv_object_face52_color		EQU 4
mgv_object_face52_lines_number	EQU 3

mgv_object_face53_color		EQU 2
mgv_object_face53_lines_number	EQU 3
mgv_object_face54_color		EQU 4
mgv_object_face54_lines_number	EQU 3
mgv_object_face55_color		EQU 2
mgv_object_face55_lines_number	EQU 3

mgv_object_face56_color		EQU 4
mgv_object_face56_lines_number	EQU 3
mgv_object_face57_color		EQU 2
mgv_object_face57_lines_number	EQU 3
mgv_object_face58_color		EQU 4
mgv_object_face58_lines_number	EQU 3

mgv_object_face59_color		EQU 2
mgv_object_face59_lines_number	EQU 3
mgv_object_face60_color		EQU 4
mgv_object_face60_lines_number	EQU 3
mgv_object_face61_color		EQU 2
mgv_object_face61_lines_number	EQU 3

mgv_object_face62_color		EQU 4
mgv_object_face62_lines_number	EQU 3
mgv_object_face63_color		EQU 2
mgv_object_face63_lines_number	EQU 3
mgv_object_face64_color		EQU 4
mgv_object_face64_lines_number	EQU 3


mgv_object_face65_color		EQU 4
mgv_object_face65_lines_number	EQU 3
mgv_object_face66_color		EQU 2
mgv_object_face66_lines_number	EQU 3
mgv_object_face67_color		EQU 4
mgv_object_face67_lines_number	EQU 3

mgv_object_face68_color		EQU 2
mgv_object_face68_lines_number	EQU 3
mgv_object_face69_color		EQU 4
mgv_object_face69_lines_number	EQU 3
mgv_object_face70_color		EQU 2
mgv_object_face70_lines_number	EQU 3

mgv_object_face71_color		EQU 4
mgv_object_face71_lines_number	EQU 3
mgv_object_face72_color		EQU 2
mgv_object_face72_lines_number	EQU 3
mgv_object_face73_color		EQU 4
mgv_object_face73_lines_number	EQU 3

mgv_object_face74_color		EQU 2
mgv_object_face74_lines_number	EQU 3
mgv_object_face75_color		EQU 4
mgv_object_face75_lines_number	EQU 3
mgv_object_face76_color		EQU 2
mgv_object_face76_lines_number	EQU 3

mgv_object_face77_color		EQU 4
mgv_object_face77_lines_number	EQU 3
mgv_object_face78_color		EQU 2
mgv_object_face78_lines_number	EQU 3
mgv_object_face79_color		EQU 4
mgv_object_face79_lines_number	EQU 3

mgv_object_face80_color		EQU 2
mgv_object_face80_lines_number	EQU 3
mgv_object_face81_color		EQU 4
mgv_object_face81_lines_number	EQU 3
mgv_object_face82_color		EQU 2
mgv_object_face82_lines_number	EQU 3

mgv_object_face83_color		EQU 4
mgv_object_face83_lines_number	EQU 3
mgv_object_face84_color		EQU 2
mgv_object_face84_lines_number	EQU 3
mgv_object_face85_color		EQU 4
mgv_object_face85_lines_number	EQU 3

mgv_object_face86_color		EQU 2
mgv_object_face86_lines_number	EQU 3
mgv_object_face87_color		EQU 4
mgv_object_face87_lines_number	EQU 3
mgv_object_face88_color		EQU 2
mgv_object_face88_lines_number	EQU 3

mgv_object_face89_color		EQU 4
mgv_object_face89_lines_number	EQU 3
mgv_object_face90_color		EQU 2
mgv_object_face90_lines_number	EQU 3
mgv_object_face91_color		EQU 4
mgv_object_face91_lines_number	EQU 3

mgv_object_face92_color		EQU 2
mgv_object_face92_lines_number	EQU 3
mgv_object_face93_color		EQU 4
mgv_object_face93_lines_number	EQU 3
mgv_object_face94_color		EQU 2
mgv_object_face94_lines_number	EQU 3

mgv_object_face95_color		EQU 4
mgv_object_face95_lines_number	EQU 3
mgv_object_face96_color		EQU 2
mgv_object_face96_lines_number	EQU 3
mgv_object_face97_color		EQU 4
mgv_object_face97_lines_number	EQU 3

mgv_object_face98_color		EQU 2
mgv_object_face98_lines_number	EQU 3
mgv_object_face99_color		EQU 4
mgv_object_face99_lines_number	EQU 3
mgv_object_face100_color	EQU 2
mgv_object_face100_lines_number	EQU 3

mgv_object_face101_color	EQU 4
mgv_object_face101_lines_number	EQU 3
mgv_object_face102_color	EQU 2
mgv_object_face102_lines_number	EQU 3
mgv_object_face103_color	EQU 4
mgv_object_face103_lines_number	EQU 3

mgv_object_face104_color	EQU 2
mgv_object_face104_lines_number	EQU 3
mgv_object_face105_color	EQU 4
mgv_object_face105_lines_number	EQU 3
mgv_object_face106_color	EQU 2
mgv_object_face106_lines_number	EQU 3

mgv_object_face107_color	EQU 4
mgv_object_face107_lines_number	EQU 3
mgv_object_face108_color	EQU 2
mgv_object_face108_lines_number	EQU 3
mgv_object_face109_color	EQU 4
mgv_object_face109_lines_number	EQU 3

mgv_object_face110_color	EQU 2
mgv_object_face110_lines_number	EQU 3
mgv_object_face111_color	EQU 4
mgv_object_face111_lines_number	EQU 3
mgv_object_face112_color	EQU 2
mgv_object_face112_lines_number	EQU 3


mgv_object_face113_color	EQU 4
mgv_object_face113_lines_number	EQU 3

mgv_object_face114_color	EQU 2
mgv_object_face114_lines_number	EQU 3

mgv_object_face115_color	EQU 4
mgv_object_face115_lines_number	EQU 3

mgv_object_face116_color	EQU 2
mgv_object_face116_lines_number	EQU 3

mgv_object_face117_color	EQU 4
mgv_object_face117_lines_number	EQU 3

mgv_object_face118_color	EQU 2
mgv_object_face118_lines_number	EQU 3

mgv_object_face119_color	EQU 4
mgv_object_face119_lines_number	EQU 3

mgv_object_face120_color	EQU 2
mgv_object_face120_lines_number	EQU 3

mgv_object_face121_color	EQU 4
mgv_object_face121_lines_number	EQU 3

mgv_object_face122_color	EQU 2
mgv_object_face122_lines_number	EQU 3

mgv_object_face123_color	EQU 4
mgv_object_face123_lines_number	EQU 3

mgv_object_face124_color	EQU 2
mgv_object_face124_lines_number	EQU 3

mgv_object_face125_color	EQU 4
mgv_object_face125_lines_number	EQU 3

mgv_object_face126_color	EQU 2
mgv_object_face126_lines_number	EQU 3

mgv_object_face127_color	EQU 4
mgv_object_face127_lines_number	EQU 3

mgv_object_face128_color	EQU 2
mgv_object_face128_lines_number	EQU 3

mgv_lines_number_max		EQU 288
mgv_glenz_colors_number		EQU 4

mgv_morph_shapes_number		EQU 4
mgv_morph_speed			EQU 8

; Fill-Blit
mgv_fill_blit_x_size		EQU visible_pixels_number
mgv_fill_blit_y_size		EQU visible_lines_number
mgv_fill_blit_depth		EQU pf1_depth3

; Scroll-Playfield-Bottom
spb_min_vstart			EQU VSTART_160_LINES
spb_max_vstop			EQU VSTOP_OVERSCAN_PAL
spb_y_radius			EQU spb_max_vstop-spb_min_vstart
spb_y_centre			EQU spb_max_vstop-spb_min_vstart

; Scroll-Playfield-Bottom-In
spbi_y_angle_speed		EQU 4

; Scroll-Playfield-Bottom-Out
spbo_y_angle_speed		EQU 5

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

cl2_extension1	RS.B 0

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

cl2_extension2_size	RS.B 0


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
mgv_rot_x_angle			RS.W 1
mgv_rot_y_angle			RS.W 1
mgv_rot_z_angle			RS.W 1

mgv_rot_variable_x_speed	RS.W 1
mgv_rot_x_angle_speed_angle	RS.W 1
mgv_rot_variable_y_speed	RS.W 1
mgv_rot_y_angle_speed_angle	RS.W 1
mgv_rot_variable_z_speed	RS.W 1
mgv_rot_z_angle_speed_angle	RS.W 1

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


start_014_morph_glenz_vectors


	INCLUDE "sys-wrapper.i"


	CNOP 0,4
init_main_variables

; Morphing-Glenz-Vectors
	moveq	#TRUE,d0
	move.w	d0,mgv_rot_x_angle(a3)
	move.w	d0,mgv_rot_y_angle(a3)
	move.w	d0,mgv_rot_z_angle(a3)

	move.w	d0,mgv_rot_variable_x_speed(a3)
	move.w	d0,mgv_rot_x_angle_speed_angle(a3)
	move.w	d0,mgv_rot_variable_y_speed(a3)
	move.w	d0,mgv_rot_y_angle_speed_angle(a3)
	move.w	d0,mgv_rot_variable_z_speed(a3)
	move.w	d0,mgv_rot_z_angle_speed_angle(a3)

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
	move.w	d0,spbi_y_angle(a3); 0°

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
	bsr.s	spb_init_display_window
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
	lea	mgv_object_shape1_coords(pc),a1
	move.l	a1,(a0)+		; shape table
	lea	mgv_object_shape2_coords(pc),a1
	move.l	a1,(a0)+		; shape table
	lea	mgv_object_shape3_coords(pc),a1
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
	COP_MOVEQ $8000,BLTADAT		; line texture strts with MSB
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
	COP_MOVEQ BLTCON1F_DESC+BLTCON1F_EFE,BLTCON1 ; fill mode,  backwards
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
	bsr	effects_handler
	bsr	mgv_clear_playfield1
	bsr	mgv_calculate_rot_xyz_speed
	bsr	mgv_rotation
	bsr	mgv_morph_object
	bsr	mgv_draw_lines
	bsr	mgv_fill_playfield1
	bsr	mgv_set_second_copperlist
	bsr	scroll_pf_bottom_in
	bsr	scroll_pf_bottom_out
	bsr	mouse_handler
	tst.l	d0			; exit ?
	bne.s   beam_routines_exit
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
	moveq	#4-1,d7			; number of runs
mgv_clear_playfield1_loop
	REPT ((pf1_plane_width*visible_lines_number*pf1_depth3)/56)/4
		movem.l d0-d6/a0-a6,-(a7) ; clear 56 bytes
	ENDR
	dbf	d7,mgv_clear_playfield1_loop
	movem.l d0-d6/a0-a6,-(a7)	; clear remaining 96 bytes
	movem.l d0-d6/a0-a2,-(a7)
	move.l	variables+save_a7(pc),a7
	movem.l (a7)+,a3-a6
	rts


	CNOP 0,4
mgv_calculate_rot_xyz_speed
	move.w	mgv_rot_x_angle_speed_angle(a3),d2
	lea	sine_table(pc),a0
	move.w	(a0,d2.w*2),d0		; sin(w)
	MULSF.W mgv_rot_x_angle_speed_radius*2,d0,d1 ; x speed = (r*sin(w))/2^15
	swap	d0
	MOVEF.W sine_table_length-1,d3
	add.w	#mgv_rot_x_angle_speed_center,d0
	move.w	d0,mgv_rot_variable_x_speed(a3)
	add.w	#mgv_rot_x_angle_speed_speed,d2
	and.w	d3,d2			; remove overflow
	move.w	d2,mgv_rot_x_angle_speed_angle(a3)

	move.w	mgv_rot_y_angle_speed_angle(a3),d2
	move.w	(a0,d2.w*2),d0		; sin(w)
	MULSF.W mgv_rot_y_angle_speed_radius*2,d0,d1 ; y speed = (r*sin(w))/2^15
	swap	d0
	add.w	#mgv_rot_y_angle_speed_center,d0
	move.w	d0,mgv_rot_variable_y_speed(a3)
	add.w	#mgv_rot_y_angle_speed_speed,d2
	and.w	d3,d2			; remove overflow
	move.w	d2,mgv_rot_y_angle_speed_angle(a3)

	move.w	mgv_rot_z_angle_speed_angle(a3),d2
	move.w	(a0,d2.w*2),d0		; sin(w)
	MULSF.W mgv_rot_z_angle_speed_radius*2,d0,d1 ; z speed = (r*sin(w))/2^15
	swap	d0
	add.w	#mgv_rot_z_angle_speed_center,d0
	move.w	d0,mgv_rot_variable_z_speed(a3)
	add.w	#mgv_rot_z_angle_speed_speed,d2
	and.w	d3,d2			; remove overflow
	move.w	d2,mgv_rot_z_angle_speed_angle(a3)
	rts


	CNOP 0,4
mgv_rotation
	movem.l a4-a5,-(a7)
	move.w	mgv_rot_x_angle(a3),d1
	move.w	d1,d0		
	lea	sine_table(pc),a2	
	move.w	(a2,d0.w*2),d4		; sin(a)
	move.w	#sine_table_length/4,a4
	MOVEF.W sine_table_length-1,d3
	add.w	a4,d0			; + 90°
	swap	d4 			; high word: sin(a)
	and.w	d3,d0			; remove overflow
	move.w	(a2,d0.w*2),d4	 	; low word: cos(a)
	add.w	mgv_rot_variable_x_speed(a3),d1
	and.w	d3,d1			; remove overflow
	move.w	d1,mgv_rot_x_angle(a3) 
	move.w	mgv_rot_y_angle(a3),d1
	move.w	d1,d0		
	move.w	(a2,d0.w*2),d5		; sin(b)
	add.w	a4,d0			; + 90°
	swap	d5 			; high word: sin(b)
	and.w	d3,d0			; remove overflow
	move.w	(a2,d0.w*2),d5	 	; low word: cos(b)
	add.w	mgv_rot_variable_y_speed(a3),d1
	and.w	d3,d1			; remove overflow
	move.w	d1,mgv_rot_y_angle(a3) 
	move.w	mgv_rot_z_angle(a3),d1
	move.w	d1,d0		
	move.w	(a2,d0.w*2),d6		; sin(c)
	add.w	a4,d0			; + 90°
	swap	d6 			; high word: sin(c)
	and.w	d3,d0			; remove overflow
	move.w	(a2,d0.w*2),d6	 	; low word: cos(c)
	add.w	mgv_rot_variable_z_speed(a3),d1
	and.w	d3,d1			; remove overflow
	move.w	d1,mgv_rot_z_angle(a3) 
	lea	mgv_object_coords(pc),a0
	lea	mgv_rot_xy_coords(pc),a1
	move.w	#mgv_rot_d*8,a4
	move.w	#mgv_rot_xy_center,a5
	moveq	#mgv_object_edge_points_number-1,d7
mgv_rotate_loop
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
	add.w	a5,d0			; x' + x center
	move.w	d0,(a1)+		; x position
	divs.w	d2,d1			; y'= (y*d)/(z+d)
	move.l	a2,d7			; loop counter
	add.w	a5,d1			; y' + y center
	move.w	d1,(a1)+		; y position
	dbf	d7,mgv_rotate_loop
	movem.l (a7)+,a4-a5
	rts


	CNOP 0,4
mgv_morph_object
	tst.w	mgv_morph_active(a3)
	bne.s	mgv_morph_object_quit
	move.w	mgv_morph_shapes_start(a3),d1
	moveq	#0,d2			; coordinates counter
	lea	mgv_object_coords(pc),a0
	lea	mgv_morph_shapes_table(pc),a1
	move.l	(a1,d1.w*4),a1		; shape table
	MOVEF.W mgv_object_edge_points_number*3-1,d7
mgv_morph_object_loop
	move.w	(a0),d0			; current coordinate
	cmp.w	(a1)+,d0		; destination coordinate reached ?
	beq.s	mgv_morph_object_skip3
	bgt.s	mgv_morph_object_skip1
	addq.w	#mgv_morph_speed,d0; increase current coordinate
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
	addq.w	#1,d1			; next entry in object table
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
	lea	mgv_rot_xy_coords(pc),a1
	move.l	pf1_construction1(a3),a2
	move.l	(a2),d0
	add.l	#ALIGN_64KB,d0
	clr.w	d0
	move.l	d0,a2
	sub.l	a4,a4			; lines counter
	move.l	cl2_construction2(a3),a6 
	ADDF.W	cl2_extension3_entry-cl2_extension2_size+cl2_ext2_BLTCON0+WORD_SIZE,a6
	move.l	#((BC0F_SRCA|BC0F_SRCC|BC0F_DEST+NANBC|NABC|ABNC)<<16)+(BLTCON1F_LINE+BLTCON1F_SING),a3 ; minterm linde mode
	MOVEF.W mgv_object_faces_number-1,d7
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
	addq.w	#1,a4			; Linienzähler erhöhen
	move.w	d1,cl2_ext2_BLTDPTL-cl2_ext2_BLTCON0(a6) ; playfield write
	addq.w	#1*4,d2			; (4*dx)+(1*4)
	move.w	d3,cl2_ext2_BLTAPTL-cl2_ext2_BLTCON0(a6) ; (4*dy)-(2*dx)
	MULUF.W 16,d2			; ((4*dx)+(1*4))*16 = line mength
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
	muls.w	#spb_y_radius*2,d0; y'=(sin(w)*yr)/2^15
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
	INCLUDE "Superglenz:colortables/1xGlenz-Colorgradient4.ct"

	CNOP 0,2
mgv_object_coords
; Zoom-In
	DS.W mgv_object_edge_points_number*3

; Object shapes
; Shape 1
	CNOP 0,2
mgv_object_shape1_coords
; Polygon 2
	DC.W 0,-(65*8),0		; P0
	DC.W 0,-(50*8),41*8		; P1
	DC.W 16*8,-(50*8),39*8		; P2
	DC.W 29*8,-(50*8),30*8		; P3
	DC.W 38*8,-(50*8),16*8		; P4
	DC.W 41*8,-(50*8),0		; P5
	DC.W 38*8,-(50*8),-(16*8)	; P6
	DC.W 29*8,-(50*8),-(30*8)	; P7
	DC.W 16*8,-(50*8),-(39*8)	; P8
	DC.W 0,-(50*8),-(41*8)		; P9
	DC.W -(16*8),-(50*8),-(39*8)	; P10
	DC.W -(29*8),-(50*8),-(30*8)	; P11
	DC.W -(38*8),-(50*8),-(16*8)	; P12
	DC.W -(41*8),-(50*8),0		; P13
	DC.W -(38*8),-(50*8),16*8	; P13
	DC.W -(29*8),-(50*8),30*8	; P15
	DC.W -(16*8),-(50*8),39*8	; P16
	DC.W 0,0,65*8			; P13
	DC.W 13*8,0,63*8		; P16
	DC.W 25*8,0,60*8		; P19
	DC.W 34*8,0,53*8		; P20
	DC.W 46*8,0,46*8		; P21
	DC.W 53*8,0,36*8		; P22
	DC.W 59*8,0,25*8		; P23
	DC.W 63*8,0,13*8		; P24
	DC.W 65*8,0,0			; P25
	DC.W 63*8,0,-(13*8)		; P26
	DC.W 59*8,0,-(25*8)		; P27
	DC.W 53*8,0,-(36*8)		; P25
	DC.W 45*8,0,-(46*8)		; P29
	DC.W 34*8,0,-(53*8)		; P30
	DC.W 25*8,0,-(60*8)		; P31
	DC.W 13*8,0,-(63*8)		; P29
	DC.W 0,0,-(65*8)		; P30
	DC.W -(13*8),0,-(63*8)		; P34
	DC.W -(25*8),0,-(60*8)		; P35
	DC.W -(34*8),0,-(53*8)		; P36
	DC.W -(45*8),0,-(46*8)		; P37
	DC.W -(53*8),0,-(36*8)		; P34
	DC.W -(59*8),0,-(25*8)		; P39
	DC.W -(63*8),0,-(13*8)		; P36
	DC.W -(65*8),0,0		; P41
	DC.W -(63*8),0,13*8		; P38
	DC.W -(59*8),0,25*8		; P43
	DC.W -(53*8),0,36*8		; P44
	DC.W -(45*8),0,46*8		; P45
	DC.W -(34*8),0,53*8		; P41
	DC.W -(25*8),0,60*8		; P47
	DC.W -(13*8),0,63*8		; P48
	DC.W 0,50*8,41*8		; P49
	DC.W 16*8,50*8,39*8		; P50
	DC.W 29*8,50*8,30*8		; P46
	DC.W 38*8,50*8,16*8		; P52
	DC.W 41*8,50*8,0		; P53
	DC.W 38*8,50*8,-(16*8)		; P54
	DC.W 29*8,50*8,-(30*8)		; P55
	DC.W 16*8,50*8,-(39*8)		; P50
	DC.W 0,50*8,-(41*8)		; P57
	DC.W -(16*8),50*8,-(39*8)	; P58
	DC.W -(29*8),50*8,-(30*8)	; P53
	DC.W -(38*8),50*8,-(16*8)	; P60
	DC.W -(41*8),50*8,0		; P61
	DC.W -(38*8),50*8,16*8		; P62
	DC.W -(29*8),50*8,30*8		; P63
	DC.W -(16*8),50*8,39*8		; P64
	DC.W 0,65*8,0			; P65

; Shape 2
	CNOP 0,2
mgv_object_shape2_coords
; Polygon 1
	DC.W 0,-(65*8),0		; P0
	DC.W 0,-(32*8),65*8		; P1
	DC.W 25*8,-(32*8),60*8		; P2
	DC.W 45*8,-(32*8),46*8		; P3
	DC.W 59*8,-(32*8),25*8		; P4
	DC.W 65*8,-(32*8),0		; P5
	DC.W 59*8,-(32*8),-(25*8)	; P6
	DC.W 45*8,-(32*8),-(46*8)	; P7
	DC.W 25*8,-(32*8),-(60*8)	; P8
	DC.W 0,-(32*8),-(65*8)		; P9
	DC.W -(25*8),-(32*8),-(60*8)	; P10
	DC.W -(45*8),-(32*8),-(46*8)	; P11
	DC.W -(59*8),-(32*8),-(25*8)	; P12
	DC.W -(65*8),-(32*8),0		; P13
	DC.W -(59*8),-(32*8),25*8	; P13
	DC.W -(45*8),-(32*8),46*8	; P15
	DC.W -(25*8),-(32*8),60*8	; P16
	DC.W 0,0,65*8			; P13
	DC.W 13*8,0,63*8		; P18
	DC.W 25*8,0,60*8		; P19
	DC.W 34*8,0,59*8		; P20
	DC.W 46*8,0,46*8		; P21
	DC.W 53*8,0,36*8		; P22
	DC.W 59*8,0,25*8		; P23
	DC.W 63*8,0,13*8		; P24
	DC.W 65*8,0,0			; P25
	DC.W 63*8,0,-(13*8)		; P26
	DC.W 59*8,0,-(25*8)		; P27
	DC.W 53*8,0,-(36*8)		; P25
	DC.W 45*8,0,-(46*8)		; P29
	DC.W 34*8,0,-(59*8)		; P30
	DC.W 25*8,0,-(60*8)		; P31
	DC.W 13*8,0,-(63*8)		; P32
	DC.W 0,0,-(65*8)		; P33
	DC.W -(13*8),0,-(63*8)		; P34
	DC.W -(25*8),0,-(60*8)		; P25
	DC.W -(34*8),0,-(59*8)		; P32
	DC.W -(45*8),0,-(46*8)		; P37
	DC.W -(59*8),0,-(36*8)		; P34
	DC.W -(59*8),0,-(25*8)		; P39
	DC.W -(63*8),0,-(13*8)		; P36
	DC.W -(65*8),0,0		; P41
	DC.W -(63*8),0,13*8		; P42
	DC.W -(59*8),0,25*8		; P43
	DC.W -(53*8),0,36*8		; P44
	DC.W -(45*8),0,46*8		; P32
	DC.W -(34*8),0,59*8		; P46
	DC.W -(25*8),0,60*8		; P47
	DC.W -(13*8),0,63*8		; P34
	DC.W 0,32*8,65*8		; P49
	DC.W 25*8,32*8,60*8		; P36
	DC.W 45*8,32*8,46*8		; P46
	DC.W 59*8,32*8,25*8		; P52
	DC.W 65*8,32*8,0		; P53
	DC.W 59*8,32*8,-(25*8)		; P54
	DC.W 45*8,32*8,-(46*8)		; P55
	DC.W 25*8,32*8,-(60*8)		; P56
	DC.W 0,32*8,-(65*8)		; P57
	DC.W -(25*8),32*8,-(60*8)	; P58
	DC.W -(45*8),32*8,-(46*8)	; P59
	DC.W -(59*8),32*8,-(25*8)	; P60
	DC.W -(65*8),32*8,0		; P61
	DC.W -(59*8),32*8,25*8		; P62
	DC.W -(45*8),32*8,46*8		; P45
	DC.W -(25*8),32*8,60*8		; P46
	DC.W 0,65*8,0			; P65

; Shape 3
	CNOP 0,2
mgv_object_shape3_coords
; Cube
	DC.W 0,-(32*8),0		; P0
	DC.W 0,-(32*8),50*8		; P1
	DC.W 25*8,-(32*8),50*8		; P2
	DC.W 50*8,-(32*8),50*8		; P3
	DC.W 50*8,-(32*8),25*8		; P4
	DC.W 50*8,-(32*8),0		; P5
	DC.W 50*8,-(32*8),-(25*8)	; P6
	DC.W 50*8,-(32*8),-(50*8)	; P7
	DC.W 25*8,-(32*8),-(50*8)	; P8
	DC.W 0,-(32*8),-(50*8)		; P9
	DC.W -(25*8),-(32*8),-(50*8)	; P10
	DC.W -(50*8),-(32*8),-(50*8)	; P11
	DC.W -(50*8),-(32*8),-(25*8)	; P12
	DC.W -(50*8),-(32*8),0		; P13
	DC.W -(50*8),-(32*8),25*8	; P13
	DC.W -(50*8),-(32*8),50*8	; P15
	DC.W -(25*8),-(32*8),50*8	; P16
	DC.W 0,0,50*8			; P17
	DC.W 13*8,0,50*8		; P18
	DC.W 25*8,0,50*8		; P19
	DC.W 34*8,0,50*8		; P20
	DC.W 50*8,0,50*8		; P21
	DC.W 50*8,0,36*8		; P22
	DC.W 50*8,0,25*8		; P23
	DC.W 50*8,0,13*8		; P24
	DC.W 50*8,0,0			; P25
	DC.W 50*8,0,-(13*8)		; P26
	DC.W 50*8,0,-(25*8)		; P27
	DC.W 50*8,0,-(36*8)		; P28
	DC.W 50*8,0,-(50*8)		; P29
	DC.W 34*8,0,-(50*8)		; P30
	DC.W 25*8,0,-(50*8)		; P31
	DC.W 13*8,0,-(50*8)		; P32
	DC.W 0,0,-(50*8)		; P33
	DC.W -(13*8),0,-(50*8)		; P34
	DC.W -(25*8),0,-(50*8)		; P35
	DC.W -(34*8),0,-(50*8)		; P36
	DC.W -(50*8),0,-(50*8)		; P37
	DC.W -(50*8),0,-(36*8)		; P38
	DC.W -(50*8),0,-(25*8)		; P39
	DC.W -(50*8),0,-(13*8)		; P40
	DC.W -(50*8),0,0		; P41
	DC.W -(50*8),0,13*8		; P42
	DC.W -(50*8),0,25*8		; P43
	DC.W -(50*8),0,36*8		; P44
	DC.W -(50*8),0,50*8		; P45
	DC.W -(34*8),0,50*8		; P46
	DC.W -(25*8),0,50*8		; P47
	DC.W -(13*8),0,50*8		; P48
	DC.W 0,32*8,50*8		; P49
	DC.W 25*8,32*8,50*8		; P50
	DC.W 50*8,32*8,50*8		; P51
	DC.W 50*8,32*8,25*8		; P52
	DC.W 50*8,32*8,0		; P53
	DC.W 50*8,32*8,-(25*8)		; P54
	DC.W 50*8,32*8,-(50*8)		; P55
	DC.W 25*8,32*8,-(50*8)		; P56
	DC.W 0,32*8,-(50*8)		; P57
	DC.W -(25*8),32*8,-(50*8)	; P58
	DC.W -(50*8),32*8,-(50*8)	; P59
	DC.W -(50*8),32*8,-(25*8)	; P60
	DC.W -(50*8),32*8,0		; P61
	DC.W -(50*8),32*8,25*8		; P62
	DC.W -(50*8),32*8,50*8		; P63
	DC.W -(25*8),32*8,50*8		; P64
	DC.W 0,32*8,0			; P65

	CNOP 0,4
mgv_object_info
; 1. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face1_color	
	DC.W mgv_object_face1_lines_number-1 
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
; 49. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face49_color
	DC.W mgv_object_face49_lines_number-1 

; 50. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face50_color
	DC.W mgv_object_face50_lines_number-1 
; 51. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face51_color
	DC.W mgv_object_face51_lines_number-1 
; 52. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face52_color
	DC.W mgv_object_face52_lines_number-1 

; 53. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face53_color
	DC.W mgv_object_face53_lines_number-1 
; 54. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face54_color
	DC.W mgv_object_face54_lines_number-1 
; 55. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face55_color
	DC.W mgv_object_face55_lines_number-1 

; 56. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face56_color
	DC.W mgv_object_face56_lines_number-1 
; 57. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face57_color
	DC.W mgv_object_face57_lines_number-1 
; 58. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face58_color
	DC.W mgv_object_face58_lines_number-1 

; 59. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face59_color
	DC.W mgv_object_face59_lines_number-1 
; 60. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face60_color
	DC.W mgv_object_face60_lines_number-1 
; 61. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face61_color
	DC.W mgv_object_face61_lines_number-1 

; 62. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face62_color
	DC.W mgv_object_face62_lines_number-1 
; 63. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face63_color
	DC.W mgv_object_face63_lines_number-1 
; 64. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face64_color
	DC.W mgv_object_face64_lines_number-1 


; 65. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face65_color
	DC.W mgv_object_face65_lines_number-1 
; 66. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face66_color
	DC.W mgv_object_face66_lines_number-1 
; 67. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face67_color
	DC.W mgv_object_face67_lines_number-1 

; 68. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face68_color
	DC.W mgv_object_face68_lines_number-1 
; 69. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face69_color
	DC.W mgv_object_face69_lines_number-1 
; 70. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face70_color
	DC.W mgv_object_face70_lines_number-1 

; 71. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face71_color
	DC.W mgv_object_face71_lines_number-1 
; 72. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face72_color
	DC.W mgv_object_face72_lines_number-1 
; 73. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face73_color
	DC.W mgv_object_face73_lines_number-1 

; 74. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face74_color
	DC.W mgv_object_face74_lines_number-1 
; 75. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face75_color
	DC.W mgv_object_face75_lines_number-1 
; 76. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face76_color
	DC.W mgv_object_face76_lines_number-1 

; 77. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face77_color
	DC.W mgv_object_face77_lines_number-1 
; 78. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face78_color
	DC.W mgv_object_face78_lines_number-1 
; 79. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face79_color
	DC.W mgv_object_face79_lines_number-1 

; 80. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face80_color
	DC.W mgv_object_face80_lines_number-1 
; 81. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face81_color
	DC.W mgv_object_face81_lines_number-1 
; 82. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face82_color
	DC.W mgv_object_face82_lines_number-1 

; 83. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face83_color
	DC.W mgv_object_face83_lines_number-1 
; 84. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face84_color
	DC.W mgv_object_face84_lines_number-1 
; 85. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face85_color
	DC.W mgv_object_face85_lines_number-1 

; 86. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face86_color
	DC.W mgv_object_face86_lines_number-1 
; 87. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face87_color
	DC.W mgv_object_face87_lines_number-1 
; 88. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face88_color
	DC.W mgv_object_face88_lines_number-1 

; 89. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face89_color
	DC.W mgv_object_face89_lines_number-1 
; 90. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face90_color
	DC.W mgv_object_face90_lines_number-1 
; 91. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face91_color
	DC.W mgv_object_face91_lines_number-1 

; 92. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face92_color
	DC.W mgv_object_face92_lines_number-1 
; 93. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face93_color
	DC.W mgv_object_face93_lines_number-1 
; 94. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face94_color
	DC.W mgv_object_face94_lines_number-1 

; 95. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face95_color
	DC.W mgv_object_face95_lines_number-1 
; 96. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face96_color
	DC.W mgv_object_face96_lines_number-1 
; 97. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face97_color
	DC.W mgv_object_face97_lines_number-1 

; 98. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face98_color
	DC.W mgv_object_face98_lines_number-1 
; 99. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face99_color
	DC.W mgv_object_face99_lines_number-1 
; 100. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face100_color
	DC.W mgv_object_face100_lines_number-1 

; 101. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face101_color
	DC.W mgv_object_face101_lines_number-1 
; 102. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face102_color
	DC.W mgv_object_face102_lines_number-1 
; 103. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face103_color
	DC.W mgv_object_face103_lines_number-1 

; 104. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face104_color
	DC.W mgv_object_face104_lines_number-1 
; 105. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face105_color
	DC.W mgv_object_face105_lines_number-1 
; 106. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face106_color
	DC.W mgv_object_face106_lines_number-1 

; 107. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face107_color
	DC.W mgv_object_face107_lines_number-1 
; 108. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face108_color
	DC.W mgv_object_face108_lines_number-1 
; 109. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face109_color
	DC.W mgv_object_face109_lines_number-1 

; 110. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face110_color
	DC.W mgv_object_face110_lines_number-1 
; 111. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face111_color
	DC.W mgv_object_face111_lines_number-1 
; 112. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face112_color
	DC.W mgv_object_face112_lines_number-1 


; 113. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face113_color
	DC.W mgv_object_face113_lines_number-1 

; 114. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face114_color
	DC.W mgv_object_face114_lines_number-1 

; 115. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face115_color
	DC.W mgv_object_face115_lines_number-1 

; 116. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face116_color
	DC.W mgv_object_face116_lines_number-1 

; 117. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face117_color
	DC.W mgv_object_face117_lines_number-1 

; 118. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face118_color
	DC.W mgv_object_face118_lines_number-1 

; 119. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face119_color
	DC.W mgv_object_face119_lines_number-1 

; 120. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face120_color
	DC.W mgv_object_face120_lines_number-1 

; 121. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face121_color
	DC.W mgv_object_face121_lines_number-1 

; 122. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face122_color
	DC.W mgv_object_face122_lines_number-1 

; 123. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face123_color
	DC.W mgv_object_face123_lines_number-1 

; 124. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face124_color
	DC.W mgv_object_face124_lines_number-1 

; 125. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face125_color
	DC.W mgv_object_face125_lines_number-1 

; 126. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face126_color
	DC.W mgv_object_face126_lines_number-1 

; 127. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face127_color
	DC.W mgv_object_face127_lines_number-1 

; 128. face
	DC.L 0				; coordinates table
	DC.W mgv_object_face128_color
	DC.W mgv_object_face128_lines_number-1 


	CNOP 0,2
mgv_object_edges
	DC.W 0*2,1*2,2*2,0*2		; face 1
	DC.W 0*2,2*2,3*2,0*2		; face 2
	DC.W 0*2,3*2,4*2,0*2		; face 3
	DC.W 0*2,4*2,5*2,0*2		; face 4
	DC.W 0*2,5*2,6*2,0*2		; face 5
	DC.W 0*2,6*2,7*2,0*2		; face 6
	DC.W 0*2,7*2,8*2,0*2		; face 7
	DC.W 0*2,8*2,9*2,0*2		; face 8
	DC.W 0*2,9*2,10*2,0*2		; face 9
	DC.W 0*2,10*2,11*2,0*2		; face 10
	DC.W 0*2,11*2,12*2,0*2		; face 11
	DC.W 0*2,12*2,13*2,0*2		; face 12
	DC.W 0*2,13*2,14*2,0*2		; face 13
	DC.W 0*2,14*2,15*2,0*2		; face 14
	DC.W 0*2,15*2,16*2,0*2		; face 15
	DC.W 0*2,16*2,1*2,0*2		; face 16

	DC.W 2*2,18*2,19*2,2*2		; face 17
	DC.W 2*2,1*2,18*2,2*2		; face 18
	DC.W 1*2,17*2,18*2,1*2		; face 19

	DC.W 3*2,20*2,21*2,3*2		; face 20
	DC.W 3*2,2*2,20*2,3*2		; face 21
	DC.W 2*2,19*2,20*2,2*2		; face 22

	DC.W 4*2,22*2,23*2,4*2		; face 23
	DC.W 4*2,3*2,22*2,4*2		; face 24
	DC.W 3*2,21*2,22*2,3*2		; face 25

	DC.W 5*2,24*2,25*2,5*2		; face 26
	DC.W 5*2,4*2,24*2,5*2		; face 27
	DC.W 4*2,23*2,24*2,4*2		; face 28

	DC.W 6*2,26*2,27*2,6*2		; face 29
	DC.W 6*2,5*2,26*2,6*2		; face 30
	DC.W 5*2,25*2,26*2,5*2		; face 31

	DC.W 7*2,28*2,29*2,7*2		; face 32
	DC.W 7*2,6*2,28*2,7*2		; face 33
	DC.W 6*2,27*2,28*2,6*2		; face 34

	DC.W 8*2,30*2,31*2,8*2		; face 35
	DC.W 8*2,7*2,30*2,8*2		; face 36
	DC.W 7*2,29*2,30*2,7*2		; face 37

	DC.W 9*2,32*2,33*2,9*2		; face 38
	DC.W 9*2,8*2,32*2,9*2		; face 39
	DC.W 8*2,31*2,32*2,8*2		; face 40

	DC.W 10*2,34*2,35*2,10*2	; face 41
	DC.W 10*2,9*2,34*2,10*2		; face 42
	DC.W 9*2,33*2,34*2,9*2		; face 43

	DC.W 11*2,36*2,37*2,11*2	; face 44
	DC.W 11*2,10*2,36*2,11*2	; face 45
	DC.W 10*2,35*2,36*2,10*2	; face 46

	DC.W 12*2,38*2,39*2,12*2	; face 47
	DC.W 12*2,11*2,38*2,12*2	; face 48
	DC.W 11*2,37*2,38*2,11*2	; face 49

	DC.W 13*2,40*2,41*2,13*2	; face 50
	DC.W 13*2,12*2,40*2,13*2	; face 51
	DC.W 12*2,39*2,40*2,12*2	; face 52

	DC.W 14*2,42*2,43*2,14*2	; face 53
	DC.W 14*2,13*2,42*2,14*2	; face 54
	DC.W 13*2,41*2,42*2,13*2	; face 55

	DC.W 15*2,44*2,45*2,15*2	; face 56
	DC.W 15*2,14*2,44*2,15*2	; face 57
	DC.W 14*2,43*2,44*2,14*2	; face 58

	DC.W 16*2,46*2,47*2,16*2	; face 59
	DC.W 16*2,15*2,46*2,16*2	; face 60
	DC.W 15*2,45*2,46*2,15*2	; face 61

	DC.W 1*2,48*2,17*2,1*2		; face 62
	DC.W 1*2,16*2,48*2,1*2		; face 63
	DC.W 16*2,47*2,48*2,16*2	; face 64


	DC.W 19*2,18*2,50*2,19*2	; face 65
	DC.W 18*2,49*2,50*2,18*2	; face 66
	DC.W 18*2,17*2,49*2,18*2	; face 67

	DC.W 21*2,20*2,51*2,21*2	; face 68
	DC.W 20*2,50*2,51*2,20*2	; face 69
	DC.W 20*2,19*2,50*2,20*2	; face 70

	DC.W 23*2,22*2,52*2,23*2	; face 71
	DC.W 22*2,51*2,52*2,22*2	; face 72
	DC.W 22*2,21*2,51*2,22*2	; face 73

	DC.W 25*2,24*2,53*2,25*2	; face 74
	DC.W 24*2,52*2,53*2,24*2	; face 75
	DC.W 24*2,23*2,52*2,24*2	; face 76

	DC.W 27*2,26*2,54*2,27*2	; face 77
	DC.W 26*2,53*2,54*2,26*2	; face 78
	DC.W 26*2,25*2,53*2,26*2	; face 79

	DC.W 29*2,28*2,55*2,29*2	; face 80
	DC.W 28*2,54*2,55*2,28*2	; face 81
	DC.W 28*2,27*2,54*2,28*2	; face 82

	DC.W 31*2,30*2,56*2,31*2	; face 83
	DC.W 30*2,55*2,56*2,30*2	; face 84
	DC.W 30*2,29*2,55*2,30*2	; face 85

	DC.W 33*2,32*2,57*2,33*2	; face 86
	DC.W 32*2,56*2,57*2,32*2	; face 87
	DC.W 32*2,31*2,56*2,32*2	; face 88

	DC.W 35*2,34*2,58*2,35*2	; face 89
	DC.W 34*2,57*2,58*2,34*2	; face 90
	DC.W 34*2,33*2,57*2,34*2	; face 91

	DC.W 37*2,36*2,59*2,37*2	; face 92
	DC.W 36*2,58*2,59*2,36*2	; face 93
	DC.W 36*2,35*2,58*2,36*2	; face 94

	DC.W 39*2,38*2,60*2,39*2	; face 95
	DC.W 38*2,59*2,60*2,38*2	; face 96
	DC.W 38*2,37*2,59*2,38*2	; face 97

	DC.W 41*2,40*2,61*2,41*2	; face 98
	DC.W 40*2,60*2,61*2,40*2	; face 99
	DC.W 40*2,39*2,60*2,40*2	; face 100

	DC.W 43*2,42*2,62*2,43*2	; face 101
	DC.W 42*2,61*2,62*2,42*2	; face 102
	DC.W 42*2,41*2,61*2,42*2	; face 103

	DC.W 45*2,44*2,63*2,45*2	; face 104
	DC.W 44*2,62*2,63*2,44*2	; face 105
	DC.W 44*2,43*2,62*2,44*2	; face 106

	DC.W 47*2,46*2,64*2,47*2	; face 107
	DC.W 46*2,63*2,64*2,46*2	; face 108
	DC.W 46*2,45*2,63*2,46*2	; face 109


	DC.W 17*2,48*2,49*2,17*2	; face 110
	DC.W 48*2,64*2,49*2,48*2	; face 111
	DC.W 48*2,47*2,64*2,48*2	; face 112
	DC.W 65*2,50*2,49*2,65*2	; face 113
	DC.W 65*2,51*2,50*2,65*2	; face 114
	DC.W 65*2,52*2,51*2,65*2	; face 115
	DC.W 65*2,53*2,52*2,65*2	; face 116
	DC.W 65*2,54*2,53*2,65*2	; face 117
	DC.W 65*2,55*2,54*2,65*2	; face 118
	DC.W 65*2,56*2,55*2,65*2	; face 119
	DC.W 65*2,57*2,56*2,65*2	; face 120
	DC.W 65*2,58*2,57*2,65*2	; face 121
	DC.W 65*2,59*2,58*2,65*2	; face 122
	DC.W 65*2,60*2,59*2,65*2	; face 123
	DC.W 65*2,61*2,60*2,65*2	; face 124
	DC.W 65*2,62*2,61*2,65*2	; face 125
	DC.W 65*2,63*2,62*2,65*2	; face 126
	DC.W 65*2,64*2,63*2,65*2	; face 127
	DC.W 65*2,49*2,64*2,65*2	; face 128

	CNOP 0,2
mgv_rot_xy_coords
	DS.W mgv_object_edge_points_number*2

	CNOP 0,4
mgv_morph_shapes_table
	DS.B morph_shape_size*mgv_morph_shapes_number


	INCLUDE "sys-variables.i"


	INCLUDE "sys-names.i"


	INCLUDE "error-texts.i"

	END
