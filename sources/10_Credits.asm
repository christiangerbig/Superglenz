; Programm:	10_Credits
; Autor:	Christian Gerbig
; Datum:	23.04.2024
; Version:	1.0


; Requirements
; CPU:		68020+
; Fast-Memory:	-
; Chipset:	AGA PAL
; OS:		3.0+


	SECTION code_and_variables,CODE

	MC68040


	XREF color00_bits
	XREF nop_first_copperlist
	XREF nop_second_copperlist
	XREF mouse_handler
	XREF sine_table
	XREF global_music_fader_active
	XREF global_stop_fx_active

	XDEF start_10_credits


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
PASS_GLOBAL_REFERENCES		SET 1
PASS_RETURN_CODE		SET 1


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

mgv_count_lines_enabled		EQU FALSE
mgv_premorph_enabled		EQU TRUE
mgv_morph_loop_enabled		EQU TRUE

cfc_rgb8_prefade_enabled	EQU FALSE

dma_bits			EQU DMAF_SPRITE|DMAF_BLITTER|DMAF_COPPER|DMAF_RASTER|DMAF_SETCLR

intena_bits			EQU INTF_SETCLR

ciaa_icr_bits			EQU CIAICRF_SETCLR
ciab_icr_bits			EQU CIAICRF_SETCLR

copcon_bits			EQU COPCONF_CDANG

pf1_x_size1			EQU 0
pf1_y_size1			EQU 0
pf1_depth1			EQU 0
pf1_x_size2			EQU 256
pf1_y_size2			EQU 256+(8*2)
pf1_depth2			EQU 1
pf1_x_size3			EQU 256
pf1_y_size3			EQU 256+(8*2)
pf1_depth3			EQU 1
pf1_colors_number		EQU 0	; 2

pf2_x_size1			EQU 0
pf2_y_size1			EQU 0
pf2_depth1			EQU 0
pf2_x_size2			EQU 0
pf2_y_size2			EQU 0
pf2_depth2			EQU 0
pf2_x_size3			EQU 0
pf2_y_size3			EQU 0
pf2_depth3			EQU 1
pf2_colors_number		EQU 0	; 2
pf_colors_number		EQU pf1_colors_number+pf2_colors_number
pf_depth			EQU pf1_depth3+pf2_depth3

pf_extra_number			EQU 2
extra_pf1_x_size		EQU 64
extra_pf1_y_size		EQU 256+2732
extra_pf1_depth			EQU 3
extra_pf2_x_size		EQU 64
extra_pf2_y_size		EQU 256+2732
extra_pf2_depth			EQU 3

spr_number			EQU 8
spr_x_size1			EQU 64
spr_x_size2			EQU 64
spr_depth			EQU 2
spr_colors_number		EQU 16
spr_odd_color_table_select	EQU 1
spr_even_color_table_select	EQU 1
spr_used_number			EQU 2
spr_swap_number			EQU 2

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

beam_position			EQU $133

pixel_per_line			EQU 192
visible_pixels_number		EQU 192
visible_lines_number		EQU 256
MINROW				EQU VSTART_256_LINES

pf_pixel_per_datafetch		EQU 64	; 4x
spr_pixel_per_datafetch		EQU 64	; 4x

display_window_hstart		EQU HSTART_192_PIXEL
display_window_vstart		EQU MINROW
display_window_hstop		EQU HSTOP_192_pixel
display_window_vstop		EQU VSTOP_256_LINES

pf1_plane_width			EQU pf1_x_size3/8
extra_pf1_plane_width		EQU extra_pf1_x_size/8
extra_pf2_plane_width		EQU extra_pf2_x_size/8
data_fetch_width		EQU pixel_per_line/8
pf1_plane_moduli		EQU (pf1_plane_width*(pf1_depth3-1))+pf1_plane_width-data_fetch_width
pf2_plane_moduli		EQU (pf1_plane_width*(pf1_depth3-1))+pf1_plane_width-data_fetch_width

diwstrt_bits			EQU ((display_window_vstart&$ff)*DIWSTRTF_V0)|(display_window_hstart&$ff)
diwstop_bits			EQU ((display_window_vstop&$ff)*DIWSTOPF_V0)|(display_window_hstop&$ff)
ddfstrt_bits			EQU DDFSTART_192_PIXEL_4X
ddfstop_bits			EQU DDFSTOP_192_PIXEL_4X
bplcon0_bits			EQU BPLCON0F_ECSENA|((pf_depth>>3)*BPLCON0F_BPU3)|(BPLCON0F_COLOR)|BPLCON0F_DPF|((pf_depth&$07)*BPLCON0F_BPU0)
bplcon1_bits			EQU $4454
bplcon2_bits			EQU 0
bplcon3_bits1			EQU BPLCON3F_BRDSPRT|BPLCON3F_SPRES0|BPLCON3F_PF2OF0
bplcon3_bits2			EQU bplcon3_bits1|BPLCON3F_LOCT
bplcon4_bits			EQU (BPLCON4F_OSPRM4*spr_odd_color_table_select)|(BPLCON4F_ESPRM4*spr_even_color_table_select)
diwhigh_bits			EQU (((display_window_hstop&$100)>>8)*DIWHIGHF_HSTOP8)|(((display_window_vstop&$700)>>8)*DIWHIGHF_VSTOP8)|(((display_window_hstart&$100)>>8)*DIWHIGHF_HSTART8)|((display_window_vstart&$700)>>8)
fmode_bits			EQU FMODEF_BPL32|FMODEF_BPAGEM|FMODEF_SPR32|FMODEF_SPAGEM|FMODEF_SSCAN2

cl2_hstart			EQU $00
cl2_vstart			EQU beam_position&$ff

sine_table_length		EQU 512

; **** Vert-Text-Scroll ****
vts_image_x_size		EQU 320
vts_image_plane_width		EQU vts_image_x_size/8
vts_image_depth			EQU 1
vts_image_colors_number		EQU 2

vts_origin_character_x_size	EQU 8
vts_origin_character_y_size	EQU 7
vst_origin_charcter_depth	EQU vts_image_depth

vts_text_character_x_size	EQU 8
vts_text_character_width	EQU vts_text_character_x_size/8
vts_text_character_y_size	EQU vts_origin_character_y_size+1
vts_text_character_depth	EQU vts_image_depth

vts_vert_scroll_speed		EQU 1

vts_text_character_y_restart	EQU visible_lines_number+vts_text_character_y_size
vts_text_characters_per_line	EQU (pixel_per_line-32)/vts_text_character_x_size
vts_text_characters_per_column	EQU (visible_lines_number+vts_text_character_y_size)/vts_text_character_y_size
vts_text_characters_number	EQU vts_text_characters_per_line*vts_text_characters_per_column

; **** Morph-Glenz-Vectors ****
mgv_rot_d			EQU 512
mgv_rot_x_center		EQU extra_pf1_x_size/2
mgv_rot_y_center		EQU visible_lines_number/2
mgv_rot_y_angle_speed_radius 	EQU 10
mgv_rot_y_angle_speed_speed	EQU 2

mgv_object_edge_points_number	EQU 14
mgv_object_edge_points_per_face	EQU 3
mgv_object_faces_number		EQU 24

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

mgv_object_face13_color		EQU 4
mgv_object_face13_lines_number	EQU 3
mgv_object_face14_color		EQU 2
mgv_object_face14_lines_number	EQU 3
mgv_object_face15_color		EQU 4
mgv_object_face15_lines_number	EQU 3
mgv_object_face16_color		EQU 2
mgv_object_face16_lines_number	EQU 3

mgv_object_face17_color		EQU 4
mgv_object_face17_lines_number	EQU 3
mgv_object_face18_color		EQU 2
mgv_object_face18_lines_number	EQU 3
mgv_object_face19_color		EQU 4
mgv_object_face19_lines_number	EQU 3
mgv_object_face20_color		EQU 2
mgv_object_face20_lines_number	EQU 3

mgv_object_face21_color		EQU 4
mgv_object_face21_lines_number	EQU 3
mgv_object_face22_color		EQU 2
mgv_object_face22_lines_number	EQU 3
mgv_object_face23_color		EQU 4
mgv_object_face23_lines_number	EQU 3
mgv_object_face24_color		EQU 2
mgv_object_face24_lines_number	EQU 3

mgv_lines_number_max		EQU 54

	IFEQ mgv_morph_loop_enabled
mgv_morph_shapes_number		EQU 4
	ELSE
mgv_morph_shapes_number		EQU 5
	ENDC
mgv_morph_speed			EQU 8
mgv_morph_delay			EQU 4*PAL_FPS

; **** Fill-Blit ****
mgv_fill_blit_x_size		EQU extra_pf1_x_size
mgv_fill_blit_y_size		EQU visible_lines_number
mgv_fill_blit_depth		EQU extra_pf1_depth

; **** Clear-Blit ****
mgv_clear_blit_x_size		EQU extra_pf1_x_size
mgv_clear_blit_y_size		EQU visible_lines_number
mgv_clear_blit_depth		EQU extra_pf1_depth

; **** Colors-Fader-Cross ****
cfc_rgb8_start_color		EQU 18
cfc_rgb8_color_table_offset	EQU 2
cfc_rgb8_colors_number		EQU 4
cfc_rgb8_color_tables_number	EQU 3
cfc_rgb8_fader_speed_max	EQU 6
cfc_rgb8_fader_radius		EQU cfc_rgb8_fader_speed_max
cfc_rgb8_fader_center		EQU cfc_rgb8_fader_speed_max+1
cfc_rgb8_fader_angle_speed	EQU 2
cfc_rgb8_fader_delay		EQU 6*PAL_FPS

; **** Effects-Handler ****
eh_trigger_number_max		EQU 2


pf1_plane_x_offset		EQU 0
pf1_plane_y_offset		EQU vts_text_character_y_size

pf2_plane_x_offset		EQU 0
pf2_plane_y_offset		EQU vts_text_character_y_size-1


	INCLUDE "except-vectors-offsets.i"


	INCLUDE "extra-pf-attributes.i"


	INCLUDE "sprite-attributes.i"


	RSRESET

cl1_begin			RS.B 0

	INCLUDE "copperlist1-offsets.i"

cl1_COPJMP2			RS.L 1

copperlist1_size		RS.B 0



	RSRESET

cl2_extension1	RS.B 0

cl2_ext1_WAITBLIT		RS.L 1
cl2_ext1_BLTCON0		RS.L 1
cl2_ext1_BLTCON1		RS.L 1
cl2_ext1_BLTDPTH		RS.L 1
cl2_ext1_BLTDPTL		RS.L 1
cl2_ext1_BLTDMOD		RS.L 1
cl2_ext1_BLTSIZE		RS.L 1

cl2_extension1_size		RS.B 0


	RSRESET

cl2_extension2			RS.B 0

cl2_ext2_WAITBLIT		RS.L 1
cl2_ext2_BLTAFWM		RS.L 1
cl2_ext2_BLTALWM		RS.L 1
cl2_ext2_BLTCPTH		RS.L 1
cl2_ext2_BLTDPTH		RS.L 1
cl2_ext2_BLTCMOD		RS.L 1
cl2_ext2_BLTDMOD		RS.L 1
cl2_ext2_BLTBDAT		RS.L 1
cl2_ext2_BLTADAT		RS.L 1
cl2_ext2_COP2LCH		RS.L 1
cl2_ext2_COP2LCL		RS.L 1
cl2_ext2_COPJMP2		RS.L 1

cl2_extension2_size		RS.B 0


	RSRESET

cl2_extension3			RS.B 0

cl2_ext3_BLTCON0		RS.L 1
cl2_ext3_BLTCON1		RS.L 1
cl2_ext3_BLTCPTL		RS.L 1
cl2_ext3_BLTAPTL		RS.L 1
cl2_ext3_BLTDPTL		RS.L 1
cl2_ext3_BLTBMOD		RS.L 1
cl2_ext3_BLTAMOD		RS.L 1
cl2_ext3_BLTSIZE		RS.L 1
cl2_ext3_WAITBLIT		RS.L 1

cl2_extension3_size		RS.B 0


	RSRESET

cl2_extension4			RS.B 0

cl2_ext4_BLTCON0		RS.L 1
cl2_ext4_BLTCON1		RS.L 1
cl2_ext4_BLTAPTH		RS.L 1
cl2_ext4_BLTAPTL		RS.L 1
cl2_ext4_BLTDPTH		RS.L 1
cl2_ext4_BLTDPTL		RS.L 1
cl2_ext4_BLTAMOD		RS.L 1
cl2_ext4_BLTDMOD		RS.L 1
cl2_ext4_BLTSIZE		RS.L 1

cl2_extension4_size		RS.B 0


	RSRESET

cl2_begin			RS.B 0

cl2_extension1_entry		RS.B cl2_extension1_size
cl2_extension2_entry		RS.B cl2_extension2_size
cl2_extension3_entry		RS.B cl2_extension3_size*mgv_lines_number_max
cl2_extension4_entry		RS.B cl2_extension4_size

cl2_end				RS.L 1

copperlist2_size		RS.B 0


; ** Konstanten für die größe der Copperlisten **
cl1_size1			EQU 0
cl1_size2			EQU 0
cl1_size3			EQU copperlist1_size
cl2_size1			EQU 0
cl2_size2			EQU copperlist2_size
cl2_size3			EQU copperlist2_size


; ** Sprite0-Zusatzstruktur **
	RSRESET

spr0_extension1	RS.B 0

spr0_ext1_header		RS.L 1*(spr_pixel_per_datafetch/16)
spr0_ext1_planedata		RS.L 1*(spr_pixel_per_datafetch/16)*visible_lines_number

spr0_extension1_size		RS.B 0

; ** Sprite0-Hauptstruktur **
	RSRESET

spr0_begin			RS.B 0

spr0_extension1_entry RS.B spr0_extension1_size

spr0_end			RS.L 1*(spr_pixel_per_datafetch/16)

sprite0_size			RS.B 0

; ** Sprite1-Zusatzstruktur **
	RSRESET

spr1_extension1			RS.B 0

spr1_ext1_header		RS.L 1*(spr_pixel_per_datafetch/16)
spr1_ext1_planedata		RS.L 1*(spr_pixel_per_datafetch/16)*visible_lines_number

spr1_extension1_size		RS.B 0

; ** Sprite1-Hauptstruktur **
	RSRESET

spr1_begin			RS.B 0

spr1_extension1_entry		RS.B spr1_extension1_size

spr1_end			RS.L 1*(spr_pixel_per_datafetch/16)

sprite1_size			RS.B 0

; ** Sprite2-Hauptstruktur **
	RSRESET

spr2_begin			RS.B 0

spr2_end			RS.L 1*(spr_pixel_per_datafetch/16)

sprite2_size			RS.B 0

; ** Sprite3-Hauptstruktur **
	RSRESET

spr3_begin			RS.B 0

spr3_end			RS.L 1*(spr_pixel_per_datafetch/16)

sprite3_size			RS.B 0

; ** Sprite4-Hauptstruktur **
	RSRESET

spr4_begin			RS.B 0

spr4_end			RS.L 1*(spr_pixel_per_datafetch/16)

sprite4_size			RS.B 0

; ** Sprite5-Hauptstruktur **
	RSRESET

spr5_begin			RS.B 0

spr5_end			RS.L 1*(spr_pixel_per_datafetch/16)

sprite5_size			RS.B 0

; ** Sprite6-Hauptstruktur **
	RSRESET

spr6_begin			RS.B 0

spr6_end			RS.L 1*(spr_pixel_per_datafetch/16)

sprite6_size			RS.B 0

; ** Sprite7-Hauptstruktur **
	RSRESET

spr7_begin			RS.B 0

spr7_end			RS.L 1*(spr_pixel_per_datafetch/16)

sprite7_size			RS.B 0

; ** Konstanten für die Größe der Spritestrukturen **
spr0_x_size1			EQU spr_x_size1
spr0_y_size1			EQU sprite0_size/(spr_x_size1/8)
spr1_x_size1			EQU spr_x_size1
spr1_y_size1			EQU sprite1_size/(spr_x_size1/8)
spr2_x_size1			EQU spr_x_size1
spr2_y_size1			EQU sprite2_size/(spr_x_size1/8)
spr3_x_size1			EQU spr_x_size1
spr3_y_size1			EQU sprite3_size/(spr_x_size1/8)
spr4_x_size1			EQU spr_x_size1
spr4_y_size1			EQU sprite4_size/(spr_x_size1/8)
spr5_x_size1			EQU spr_x_size1
spr5_y_size1			EQU sprite5_size/(spr_x_size1/8)
spr6_x_size1			EQU spr_x_size1
spr6_y_size1			EQU sprite6_size/(spr_x_size1/8)
spr7_x_size1			EQU spr_x_size1
spr7_y_size1			EQU sprite7_size/(spr_x_size1/8)

spr0_x_size2			EQU spr_x_size2
spr0_y_size2			EQU sprite0_size/(spr_x_size2/8)
spr1_x_size2			EQU spr_x_size2
spr1_y_size2			EQU sprite1_size/(spr_x_size2/8)
spr2_x_size2			EQU spr_x_size2
spr2_y_size2			EQU sprite2_size/(spr_x_size2/8)
spr3_x_size2			EQU spr_x_size2
spr3_y_size2			EQU sprite3_size/(spr_x_size2/8)
spr4_x_size2			EQU spr_x_size2
spr4_y_size2			EQU sprite4_size/(spr_x_size2/8)
spr5_x_size2			EQU spr_x_size2
spr5_y_size2			EQU sprite5_size/(spr_x_size2/8)
spr6_x_size2			EQU spr_x_size2
spr6_y_size2			EQU sprite6_size/(spr_x_size2/8)
spr7_x_size2			EQU spr_x_size2
spr7_y_size2			EQU sprite7_size/(spr_x_size2/8)


	RSRESET

	INCLUDE "variables-offsets.i"

save_a7				RS.L 1

; **** Vert-Text-Scroll ****
vts_image			RS.L 1
vts_variable_vert_scroll_speed	RS.W 1
vts_text_table_start		RS.W 1

; **** Morph-Glenz-Vectors ****
mgv_rot_y_angle			RS.W 1
mgv_rot_variable_y_speed	RS.W 1
mgv_rot_y_angle_speed_angle 	RS.W 1

mgv_lines_counter		RS.W 1

mgv_morph_active		RS.W 1
mgv_morph_shapes_table_start	RS.W 1
mgv_morph_delay_counter		RS.W 1

; **** Colors-Fader-Cross ****
cfc_rgb8_active			RS.W 1
cfc_rgb8_fader_angle		RS.W 1
cfc_rgb8_fader_delay_counter	RS.W 1
cfc_rgb8_color_table_start	RS.W 1
cfc_rgb8_colors_counter		RS.W 1
cfc_rgb8_copy_colors_active	RS.W 1

; **** Effects-Handler ****
eh_trigger_number		RS.W 1

variables_size			RS.B 0


; **** Morph-Glenz-Vectors ****
	RSRESET

object_info			RS.B 0

object_info_edges_table		RS.L 1
object_info_face_color		RS.W 1
object_info_lines_number 	RS.W 1

object_info_size		RS.B 0

	RSRESET

morph_shape			RS.B 0

morph_shape_object_edges	RS.L 1

morph_shape_size		RS.B 0


start_10_credits 

	INCLUDE "sys-wrapper.i"

	CNOP 0,4
init_main_variables

; **** Vert-Text-Scroll ****
	lea	vts_image_data,a0
	move.l	a0,vts_image(a3)
	moveq	#TRUE,d0
	move.w	d0,vts_variable_vert_scroll_speed(a3)
	move.w	d0,vts_text_table_start(a3)

; **** Morphing-Glenz-Vectors ****
	move.w	d0,mgv_rot_y_angle(a3)
	move.w	d0,mgv_rot_variable_y_speed(a3)
	move.w	d0,mgv_rot_y_angle_speed_angle(a3)

	move.w	d0,mgv_lines_counter(a3)

	moveq	#FALSE,d1
	IFEQ mgv_premorph_enabled
		move.w	d0,mgv_morph_active(a3)
	ELSE
		move.w	d1,mgv_morph_active(a3)
	ENDC
	move.w	d0,mgv_morph_shapes_table_start(a3)
	IFEQ mgv_premorph_enabled
		move.w	d1,mgv_morph_delay_counter(a3) ; Delay-Counter deaktivieren
	ELSE
		move.w	#1,mgv_morph_delay_counter(a3) ; Delay-Counter aktivieren
	ENDC

; **** Colors-Fader-Cross ****
	IFEQ cfc_rgb8_prefade_enabled
		move.w	d0,cfc_rgb8_active(a3)
		move.w	#cfc_rgb8_colors_number*3,cfc_rgb8_colors_counter(a3)
		move.w	d0,cfc_rgb8_copy_colors_active(a3)
	ELSE
		move.w	d1,cfc_rgb8_active(a3)
		move.w	d0,cfc_rgb8_colors_counter(a3)
		move.w	d1,cfc_rgb8_copy_colors_active(a3)
	ENDC
	move.w	#sine_table_length/4,cfc_rgb8_fader_angle(a3) ; 90 Grad
	move.w	#1,cfc_rgb8_fader_delay_counter(a3) ; Delay-Counter aktivieren
	move.w	d0,cfc_rgb8_color_table_start(a3)

; **** Effects-Handler ****
	move.w	d0,eh_trigger_number(a3)
	rts


	CNOP 0,4
init_main
	bsr	init_colors
	bsr.s	init_sprites
	bsr	vts_init_characters_offsets
	bsr	vts_init_characters_x_positions
	bsr	vts_init_characters_y_positions
	bsr	vts_init_characters_images
	bsr	mgv_init_object_info
	bsr	mgv_init_morph_shapes_table
	IFEQ mgv_premorph_enabled
		bsr	mgv_init_start_shape
	ENDC
	bsr	init_first_copperlist
	bra	init_second_copperlist

	CNOP 0,4
init_colors
	CPU_SELECT_COLOR_HIGH_BANK 0
	CPU_INIT_COLOR_HIGH COLOR00,2,pf1_rgb8_color_table
	CPU_INIT_COLOR_HIGH COLOR02,2,pf2_rgb8_color_table

	CPU_SELECT_COLOR_LOW_BANK 0
	CPU_INIT_COLOR_LOW COLOR00,2,pf1_rgb8_color_table
	CPU_INIT_COLOR_LOW COLOR02,2,pf2_rgb8_color_table
	rts

	CNOP 0,4
init_sprites
	bsr.s	spr_init_ptrs_table
	bsr.s	mgv_init_xy_coords
	bra.s	spr_copy_structures

	INIT_SPRITE_POINTERS_TABLE

	CNOP 0,4
mgv_init_xy_coords
	move.w	#HSTART_320_PIXEL*SHIRES_PIXEL_FACTOR,d0 ; X-Koord.
	MOVEF.W display_window_vstart,d1 ; Y-Koord.
	lea	spr_ptrs_construction(pc),a2
	move.l	(a2)+,a0		; SPR0
	move.l	(a2),a1			; SPR1
	bsr.s	mgv_init_sprite_header
	rts

	CNOP 0,4
mgv_init_sprite_header
; Input
; d0.w	... X-Koordinate
; d1.w	... Y-Koordinate
; a0	... Zeiger auf 1. Sprite-Struktur
; a1	... Zeiger auf 2. Sprite-Struktur
; Result
; d0.l	... Kein Rückgabewert
	MOVEF.W visible_lines_number,d2 ; Höhe
	add.w	d1,d2			; VSTOP
	SET_SPRITE_POSITION d0,d1,d2
	move.w	d1,(a0)			; SPRxPOS 1. Sprite-Struktur
	move.w	d1,(a1)			; SPRxPOS 2. Sprite-Struktur
	move.w	d2,spr_pixel_per_datafetch/8(a0) ; SPRxCTL 1. Sprite-Struktur
	or.b	#SPRCTLF_ATT,d2
	move.w	d2,spr_pixel_per_datafetch/8(a1) ; SPRxCTL 2. Sprite-Struktur
	rts

	COPY_SPRITE_STRUCTURES

; **** Vert-Text-Scroll ****
	INIT_CHARACTERS_OFFSETS.W vts

	INIT_CHARACTERS_X_POSITIONS vts,LORES,,text_characters_per_line

	INIT_CHARACTERS_Y_POSITIONS vts,text_characters_per_column

	INIT_CHARACTERS_IMAGES vts

; **** Morph-Glenz-Vectors ****
	CNOP 0,4
mgv_init_object_info
	lea	mgv_object_info+object_info_edges_table(pc),a0 ; Zeiger auf Object-Info-Tabelle
	lea	mgv_object_edges(pc),a1	; Zeiger auf Tebelle mit Eckpunkten
	move.w	#object_info_size,a2
	MOVEF.W mgv_object_faces_number-1,d7
mgv_init_object1_info_loop
	move.w	object_info_lines_number(a0),d0
	addq.w	#1+1,d0			; Anzahl der Eckpunkte
	move.l	a1,(a0)			; Zeiger auf Tabelle mit Eckpunkten
	lea	(a1,d0.w*2),a1		; Zeiger auf Eckpunkte-Tabelle erhöhen
	add.l	a2,a0			; Object-Info-Struktur der nächsten Fläche
	dbf	d7,mgv_init_object1_info_loop
	rts

	CNOP 0,4
mgv_init_morph_shapes_table
	lea	mgv_morph_shapes_table(pc),a0 ; Tabelle mit Zeigern auf Objektdaten
	lea	mgv_object_shape1_coords(pc),a1 ; Zeiger auf 1. Form
	move.l	a1,(a0)+		; Zeiger auf Form-Tabelle
	lea	mgv_object_shape2_coords(pc),a1 ; Zeiger auf 2. Form
	move.l	a1,(a0)+		; Zeiger auf Form-Tabelle
	lea	mgv_object_shape3_coords(pc),a1 ; Zeiger auf 3. Form
	move.l	a1,(a0)+		; Zeiger auf Form-Tabelle
	lea	mgv_object_shape4_coords(pc),a1 ; Zeiger auf 4. Form
	IFEQ mgv_morph_loop_enabled
		move.l	a1,(a0)		; Zeiger auf Form-Tabelle
	ELSE
		move.l	a1,(a0)+	; Zeiger auf Form-Tabelle
		lea	mgv_object_shape5_coords(pc),a1 ; Zeiger auf 6. Form
		move.l	a1,(a0)		; Zeiger auf Form-Tabelle
	ENDC
	rts

	IFEQ mgv_premorph_enabled
		CNOP 0,4
mgv_init_start_shape
		bsr	mgv_morph_object
		tst.w	mgv_morph_active(a3) ; Morphing beendet ?
		beq.s	mgv_init_start_shape
		rts
	ENDC


	CNOP 0,4
init_first_copperlist
	move.l	cl1_display(a3),a0
	bsr.s	cl1_init_playfield_props
	bsr	cl1_init_sprite_ptrs
	bsr	cl1_init_colors
	bsr	cl1_init_plane_ptrs
	COP_MOVEQ 0,COPJMP2
	bsr	cl1_set_sprite_ptrs
	bra	cl1_set_plane_ptrs

	COP_INIT_PLAYFIELD_REGISTERS cl1

	COP_INIT_SPRITE_POINTERS cl1

	COP_INIT_BITPLANE_POINTERS cl1

	CNOP 0,4
cl1_init_colors
	COP_INIT_COLOR_HIGH COLOR16,16,spr_rgb8_color_table

	COP_SELECT_COLOR_LOW_BANK 0
	COP_INIT_COLOR_LOW COLOR16,16,spr_rgb8_color_table
	rts

	COP_SET_SPRITE_POINTERS cl1,display,spr_number

	CNOP 0,4
cl1_set_plane_ptrs
	move.l	cl1_display(a3),a0
	ADDF.W	cl1_BPL1PTH+WORD_SIZE,a0
	move.l	pf1_display(a3),a1
	moveq	#pf1_depth3-1,d7	; Anzahl der Bitplanes
cl1_set_plane_ptrs_loop1
	move.w	(a1)+,(a0)		; BPLxPTH
	ADDF.W	QUADWORD_SIZE*2,a0	; übernächter Playfieldzeiger
	move.w	(a1)+,LONGWORD_SIZE-(QUADWORD_SIZE*2)(a0) ; BPLxPTL
	dbf	d7,cl1_set_plane_ptrs_loop1

	move.l	cl1_display(a3),a0
	ADDF.W	cl1_BPL2PTH+WORD_SIZE,a0
	move.l	pf1_display(a3),a1
	moveq	#pf2_depth3-1,d7	; Anzahl der Bitplanes
cl1_set_plane_ptrs_loop2
	move.w	(a1)+,(a0)		; BPLxPTH
	ADDF.W	QUADWORD_SIZE*2,a0	; übernächter Playfieldzeiger
	move.w	(a1)+,LONGWORD_SIZE-(QUADWORD_SIZE*2)(a0) ; BPLxPTL
	dbf	d7,cl1_set_plane_ptrs_loop2
	rts

	CNOP 0,4
init_second_copperlist
	move.l	cl2_construction2(a3),a0
	bsr.s	cl2_init_clear_blit
	bsr	cl2_init_line_blits_steady
	bsr	cl2_init_line_blits
	bsr	cl2_init_fill_blit
	COP_LISTEND
	bsr	copy_second_copperlist
	bsr	swap_second_copperlist
	bsr	mgv_clear_extra_playfield
	bsr	mgv_draw_lines
	bsr	mgv_fill_extra_playfield
	bsr	mgv_set_second_copperlist
	bsr	swap_second_copperlist
	bsr	mgv_clear_extra_playfield
	bsr	mgv_draw_lines
	bsr	mgv_fill_extra_playfield
	bra	mgv_set_second_copperlist

	CNOP 0,4
cl2_init_clear_blit
	COP_WAITBLIT
	COP_MOVEQ BC0F_DEST,BLTCON0	; Minterm Löschen
	COP_MOVEQ 0,BLTCON1
	COP_MOVEQ 0,BLTDPTH
	COP_MOVEQ 0,BLTDPTL
	COP_MOVEQ 0,BLTDMOD
	COP_MOVEQ (mgv_clear_blit_y_size*mgv_clear_blit_depth*64)+(mgv_clear_blit_x_size/16),BLTSIZE
	rts

	CNOP 0,4
cl2_init_line_blits_steady
	COP_WAITBLIT
	COP_MOVEQ FALSE_WORD,BLTAFWM	; Keine Ausmaskierung
	COP_MOVEQ FALSE_WORD,BLTALWM
	COP_MOVEQ 0,BLTCPTH
	COP_MOVEQ 0,BLTDPTH
	COP_MOVEQ extra_pf1_plane_width*extra_pf1_depth,BLTCMOD ; Moduli für interleaved Bitmap
	COP_MOVEQ extra_pf1_plane_width*extra_pf1_depth,BLTDMOD
	COP_MOVEQ FALSE_WORD,BLTBDAT	; Linientextur
	COP_MOVEQ $8000,BLTADAT		; Linientextur mit MSB beginnen
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
	COP_MOVEQ BC0F_SRCA+BC0F_DEST+ANBNC+ANBC+ABNC+ABC,BLTCON0 ; Minterm D=A
	COP_MOVEQ BLTCON1F_DESC+BLTCON1F_EFE,BLTCON1 ; Füll-Modus, Rückwärts
	COP_MOVEQ 0,BLTAPTH
	COP_MOVEQ 0,BLTAPTL
	COP_MOVEQ 0,BLTDPTH
	COP_MOVEQ 0,BLTDPTL
	COP_MOVEQ 0,BLTAMOD
	COP_MOVEQ 0,BLTDMOD
	COP_MOVEQ (mgv_fill_blit_y_size*mgv_fill_blit_depth*64)+(mgv_fill_blit_x_size/16),BLTSIZE
	rts

	COPY_COPPERLIST cl2,2


	CNOP 0,4
main
	bsr.s	no_sync_routines
	bra.s	beam_routines


	CNOP 0,4
no_sync_routines
	IFEQ cfc_rgb8_prefade_enabled
		bra	cfc_rgb8_init_start_colors
	ELSE
		rts
	ENDC


	CNOP 0,4
beam_routines
	bsr	wait_beam_position
	bsr.s	swap_second_copperlist
	bsr	spr_swap_structures
	bsr	spr_set_sprite_ptrs
	bsr	swap_playfield1
	bsr	set_playfield1
	bsr	set_playfield2
	bsr	swap_extra_playfield
	bsr	effects_handler
	bsr	mgv_clear_extra_playfield
	bsr	mgv_calculate_rot_y_speed
	bsr	mgv_rotation
	bsr	mgv_morph_object
	bsr	mgv_draw_lines
	bsr	mgv_fill_extra_playfield
	bsr	mgv_set_second_copperlist
	bsr	mgv_copy_extra_playfield
	bsr	vert_text_scroll
	bsr	colors_fader_cross
	bsr	cfc_rgb8_copy_color_table
	bsr	control_counters
	jsr	mouse_handler
	tst.l	d0			; Abbruch ?
	bne.s	beam_routines_exit
	move.l	global_stop_fx_active(pc),a0
	tst.w	(a0)
	bne.s	beam_routines
beam_routines_exit
	move.l	nop_second_copperlist,COP2LC-DMACONR(a6)
	move.w	d0,COPJMP2-DMACONR(a6)
	move.l	nop_first_copperlist,COP1LC-DMACONR(a6)
	move.w	d0,COPJMP1-DMACONR(a6)
	move.w	custom_error_code(a3),d1
	rts


	SWAP_COPPERLIST cl2,2

	SWAP_SPRITES spr,spr_swap_number

	SET_SPRITES spr,spr_swap_number

	SWAP_PLAYFIELD pf1,2

	CNOP 0,4
set_playfield1
	MOVEF.L (pf1_plane_x_offset/8)+(pf1_plane_y_offset*pf1_plane_width*pf1_depth3),d1
	move.l	cl1_display(a3),a0
	ADDF.W	cl1_BPL1PTH+WORD_SIZE,a0
	move.l	pf1_display(a3),a1
	moveq	#pf1_depth3-1,d7	; Anzahl der Bitplanes
set_playfield1_loop
	move.l	(a1)+,d0
	add.l	d1,d0
	move.w	d0,LONGWORD_SIZE(a0)	; BPLxPTL
	swap	d0			; High
	move.w	d0,(a0)			; BPLxPTH
	ADDF.W	QUADWORD_SIZE*2,a0
	dbf	d7,set_playfield1_loop
	rts

	CNOP 0,4
set_playfield2
	MOVEF.L (pf2_plane_x_offset/8)+(pf2_plane_y_offset*pf1_plane_width*pf1_depth3),d1
	move.l	cl1_display(a3),a0
	ADDF.W	cl1_BPL2PTH+WORD_SIZE,a0
	move.l	pf1_display(a3),a1
	moveq	#pf2_depth3-1,d7	; Anzahl der Bitplanes
set_playfield2_loop
	move.l	(a1)+,d0
	add.l	d1,d0
	move.w	d0,LONGWORD_SIZE(a0)	; BPLxPTL
	swap	d0			; High
	move.w	d0,(a0)			; BPLxPTH
	ADDF.W	QUADWORD_SIZE*2,a0
	dbf	d7,set_playfield2_loop
	rts

	CNOP 0,4
swap_extra_playfield
	move.l	extra_pf1(a3),a0
	move.l	extra_pf2(a3),extra_pf1(a3)
	move.l	a0,extra_pf2(a3)
	rts


	CNOP 0,4
vert_text_scroll
	movem.l a4-a6,-(a7)
	MOVEF.L vts_text_characters_per_line*SHIRES_PIXEL_FACTOR,d3
	MOVEF.W vts_text_character_y_restart,d4
	lea	vts_characters_y_positions(pc),a1
	lea	vts_characters_image_ptrs(pc),a2
	move.l	pf1_construction2(a3),a4
	move.l	(a4),a4
	moveq	#vts_text_characters_per_column-1,d7
vert_text_scroll_loop1
	move.w	(a1),d1			; Y
	move.w	d1,d2
	MULUF.W pf1_plane_width*pf1_depth3,d1,d0 ; Y-Offset in Playfield
	lea	vts_characters_x_positions(pc),a0
	moveq	#vts_text_characters_per_line-1,d6
vert_text_scroll_loop2
	move.w	(a0)+,d0		; X
	lsr.w	#3,d0			; X/8
	add.w	d1,d0			; XY-Offset
	move.l	(a2)+,a5		; Character-Image
	lea	(a4,d0.w),a6
	move.b	(a5),(a6)		; 8 Pixel kopieren
	move.b	vts_image_plane_width*1(a5),pf1_plane_width*1(a6)
	move.b	vts_image_plane_width*2(a5),pf1_plane_width*2(a6)
	move.b	vts_image_plane_width*3(a5),pf1_plane_width*3(a6)
	move.b	vts_image_plane_width*4(a5),pf1_plane_width*4(a6)
	move.b	vts_image_plane_width*5(a5),pf1_plane_width*5(a6)
	move.b	vts_image_plane_width*6(a5),pf1_plane_width*6(a6)
	move.b	vts_image_plane_width*7(a5),pf1_plane_width*7(a6)
	dbf	d6,vert_text_scroll_loop2
	sub.w	vts_variable_vert_scroll_speed(a3),d2 ; Y-Position verringern
	bpl.s	vert_text_scroll_skip
	sub.l	d3,a2			; Zeiger auf Anfang setzen
	moveq	#vts_text_characters_per_line-1,d5
vert_text_scroll_loop3
	bsr.s	vts_get_new_character_image
	move.l	d0,(a2)+		; Neues Bild für Character
	dbf	d5,vert_text_scroll_loop3
	add.w	d4,d2			; Y-Neustart
vert_text_scroll_skip
	move.w	d2,(a1)+		; Y-Pos.
	dbf	d7,vert_text_scroll_loop1
	movem.l (a7)+,a4-a6
	rts

	GET_NEW_CHARACTER_IMAGE.W vts,vts_check_control_codes,NORESTART

	CNOP 0,4
vts_check_control_codes
; Input
; d0.b	... ASCII-Code
; Result
; d0.l	... Rückgabewert: Return-Code
	cmp.b	#ASCII_CTRL_M,d0
	beq.s	vts_enable_music_fader
	cmp.b	#ASCII_CTRL_V,d0
	beq.s	vts_stop_vert_text_scroll
	cmp.b	#ASCII_CTRL_F,d0
	beq.s	vts_stop_colors_fader_cross
	rts
	CNOP 0,4
vts_enable_music_fader
	move.l	a0,d0
	move.l	global_music_fader_active(pc),a0
	clr.w	(a0)
	move.l	d0,a0
	moveq	#RETURN_OK,d0
	rts
	CNOP 0,4
vts_stop_vert_text_scroll
	clr.w	vts_variable_vert_scroll_speed(a3) ; Geschwindigkeit = Null
	moveq	#RETURN_OK,d0
	rts
	CNOP 0,4
vts_stop_colors_fader_cross
	move.w	#FALSE,cfc_rgb8_color_table_start(a3) ; Startwert für Farbtabelle "Ausblenden"
	tst.w	cfc_rgb8_active(a3)
	beq.s	vts_stop_colors_fader_cross_quit
	move.w	#1,cfc_rgb8_fader_delay_counter(a3) ; Zähler aktivieren
vts_stop_colors_fader_cross_quit
	moveq	#RETURN_OK,d0
	rts


	CNOP 0,4
mgv_clear_extra_playfield
	move.l	extra_pf1(a3),a0
	move.l	(a0),d0
	add.l	#ALIGN_64KB,d0
	clr.w	d0
	move.l	cl2_construction2(a3),a0
	move.w	d0,cl2_extension1_entry+cl2_ext1_BLTDPTL+WORD_SIZE(a0)
	swap	d0
	move.w	d0,cl2_extension1_entry+cl2_ext1_BLTDPTH+WORD_SIZE(a0)
	rts

	CNOP 0,4
mgv_calculate_rot_y_speed
	move.w	mgv_rot_y_angle_speed_angle(a3),d2
	lea	sine_table,a0
	move.w	(a0,d2.w*2),d0		; sin(w)
	MULSF.W mgv_rot_y_angle_speed_radius*2,d0,d1 ; y_speed = (r*sin(w))/2^15
	swap	d0
	move.w	d0,mgv_rot_variable_y_speed(a3)
	addq.w	#mgv_rot_y_angle_speed_speed,d2 ; nächster Y-Winkel
	and.w	#sine_table_length-1,d2 ; Überlauf entfernen
	move.w	d2,mgv_rot_y_angle_speed_angle(a3)
	rts

	CNOP 0,4
mgv_rotation
	movem.l a4-a6,-(a7)
	move.w	mgv_rot_y_angle(a3),d1
	move.w	d1,d0		
	lea	sine_table,a2
	move.w	(a2,d0.w*2),d5		; sin(b)
	move.w	#sine_table_length/4,a4
	MOVEF.W sine_table_length-1,d3
	add.w	a4,d0			; + 90 Grad
	swap	d5			; Bits 16-31 = sin(b)
	and.w	d3,d0			; Übertrag entfernen
	move.w	(a2,d0.w*2),d5		; Bits	0-15 = cos(b)
	add.w	mgv_rot_variable_y_speed(a3),d1 ; nächster Y-Winkel
	and.w	d3,d1			; Übertrag entfernen
	move.w	d1,mgv_rot_y_angle(a3) 
	lea	mgv_object_coords(pc),a0
	lea	mgv_rot_xy_coords(pc),a1
	move.w	#mgv_rot_d*8,a4 ;d
	move.w	#mgv_rot_x_center,a5
	move.w	#mgv_rot_y_center,a6
	moveq	#mgv_object_edge_points_number-1,d7
mgv_rotate_loop
	move.w	(a0)+,d0		; X
	move.l	d7,a2		
	move.w	(a0)+,d1		; Y
	move.w	(a0)+,d2		; Z
	ROTATE_Y_AXIS
; ** Zentralprojektion und Translation **
	MULSF.W mgv_rot_d,d0,d3 	; X-Projektion
	add.w	a4,d2			; z+d
	divs.w	d2,d0			; x' = (x*d)/(z+d)
	MULSF.W mgv_rot_d,d1,d3		; Y-Projektion
	add.w	a5,d0			; x' + X-Mittelpunkt
	move.w	d0,(a1)+		; X-Pos.
	divs.w	d2,d1			; y'= (y*d)/(z+d)
	move.l	a2,d7			; Schleifenzähler
	add.w	a6,d1			; y' + Y-Mittelpunkt
	move.w	d1,(a1)+		; Y-Pos.
	dbf	d7,mgv_rotate_loop
	movem.l (a7)+,a4-a6
	rts

	CNOP 0,4
mgv_morph_object
	tst.w	mgv_morph_active(a3)
	bne.s	mgv_morph_object_quit
	move.w	mgv_morph_shapes_table_start(a3),d1
	moveq	#0,d2			; Koordinatenzähler
	lea	mgv_object_coords(pc),a0
	lea	mgv_morph_shapes_table(pc),a1
	move.l	(a1,d1.w*4),a1		; Zeiger auf Tabelle
	MOVEF.W mgv_object_edge_points_number*3-1,d7
mgv_morph_object_loop
	move.w	(a0),d0			; aktuelle Koordinate
	cmp.w	(a1)+,d0		; mit Ziel-Koordinate vergleichen
	beq.s	mgv_morph_object_skip3
	bgt.s	mgv_morph_object_skip1
	addq.w	#mgv_morph_speed,d0	; aktuelle Koordinate erhöhen
	bra.s	mgv_morph_object_skip2
	CNOP 0,4
mgv_morph_object_skip1
	subq.w	#mgv_morph_speed,d0	; aktuelle Koordinate verringern
mgv_morph_object_skip2
	move.w	d0,(a0)		
	addq.w	#1,d2			; Koordinatenzähler erhöhen
mgv_morph_object_skip3
	addq.w	#WORD_SIZE,a0		; Nächste Koordinate
	dbf	d7,mgv_morph_object_loop
	tst.w	d2			; Morphing beendet ?
	bne.s	mgv_morph_object_quit
	addq.w	#1,d1			; nächster Eintrag in Objekttablelle
	cmp.w	#mgv_morph_shapes_number,d1 ; Ende der Tabelle ?
	IFEQ mgv_morph_loop_enabled
		bne.s	mgv_morph_object_skip4
		moveq	#0,d1		; Neustart
mgv_morph_object_skip4
	ELSE
		beq.s	mgv_morph_object_skip5
	ENDC
	move.w	d1,mgv_morph_shapes_table_start(a3) 
	move.w	#mgv_morph_delay,mgv_morph_delay_counter(a3) ; Zähler zurücksetzen
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
	move.l	extra_pf1(a3),a2
	move.l	(a2),d0
	add.l	#ALIGN_64KB,d0
	clr.w	d0
	move.l	d0,a2
	sub.l	a4,a4			; Linienzähler zurücksetzen
	move.l	cl2_construction2(a3),a6 
	ADDF.W	cl2_extension4_entry-cl2_extension3_size+cl2_ext3_BLTCON0+WORD_SIZE,a6
	move.l	#((BC0F_SRCA+BC0F_SRCC+BC0F_DEST+NANBC+NABC+ABNC)<<16)+(BLTCON1F_LINE+BLTCON1F_SING),a3 ; Mintern Linien
	MOVEF.W mgv_object_faces_number-1,d7
mgv_draw_lines_loop1
; ** Z-Koordinate des Vektors N durch das Kreuzprodukt u x v berechnen **
	move.l	(a0)+,a5		; Zeiger auf Startwerte der Punkte
	move.w	(a5),d4			; P1-Startwert
	move.w	2(a5),d5		; P2-Startwert
	move.w	4(a5),d6		; P3-Startwert
	swap	d7			; Flächenzähler retten
	movem.w (a1,d5.w*2),d0-d1	; P2(x,y)
	movem.w (a1,d6.w*2),d2-d3	; P3(x,y)
	sub.w	d0,d2			; xv = xp3-xp2
	sub.w	(a1,d4.w*2),d0		; xu = xp2-xp1
	sub.w	d1,d3			; yv = yp3-yp2
	sub.w	2(a1,d4.w*2),d1		; yu = yp2-yp1
	muls.w	d3,d0			; xu*yv
	move.w	(a0)+,d7		; Farbe der Fläche
	muls.w	d2,d1			; yu*xv
	move.w	(a0)+,d6		; Anzahl der Linien
	sub.l	d0,d1			; zn = (yu*xv)-(xu*yv)
	bmi.s	mgv_draw_lines_loop2
	lsr.w	#2,d7			; COLOR02/04 -> COLOR00/01
	beq	mgv_draw_lines_skip3
	cmp.w	#1,d7			; Hintere Fläche von Object ?
	beq.s	mgv_draw_lines_loop2
	lsr.w	#2,d7			; COLOR08/16 -> COLOR00/01
	beq	mgv_draw_lines_skip3
mgv_draw_lines_loop2
	move.w	(a5)+,d0		; Startwerte der Punkte P1,P2
	move.w	(a5),d2
	movem.w (a1,d0.w*2),d0-d1	; xp1,xp2-Koords
	movem.w (a1,d2.w*2),d2-d3	; yp1,yp2-Koords
	GET_LINE_PARAMETERS mgv,AREAFILL,COPPERUSE,extra_pf1_plane_width*extra_pf1_depth,mgv_draw_lines_skip2
	add.l	a3,d0			; restliche BLTCON0 & BLTCON1-Bits setzen
	add.l	a2,d1			; + Playfieldadresse
	cmp.w	#1,d7			; Bitplane1 ?
	beq.s	mgv_draw_lines_skip1
	moveq	#extra_pf1_plane_width,d5
	add.l	d5,d1			; nächste Plane
	cmp.w	#2,d7			; Bitplane2 ?
	beq.s	mgv_draw_lines_skip1
	add.l	d5,d1			; nächste Plane
mgv_draw_lines_skip1
	move.w	d0,cl2_ext3_BLTCON1-cl2_ext3_BLTCON0(a6) ; BLTCON1
	swap	d0
	move.w	d0,(a6)			; BLTCON0
	MULUF.W 2,d2			; 4*dx
	move.w	d4,cl2_ext3_BLTBMOD-cl2_ext3_BLTCON0(a6) ; 4*dy
	sub.w	d2,d4			; (4*dy)-(4*dx)
	move.w	d1,cl2_ext3_BLTCPTL-cl2_ext3_BLTCON0(a6) ; Playfield lesen
	addq.w	#1,a4			; Linienzähler erhöhen
	move.w	d1,cl2_ext3_BLTDPTL-cl2_ext3_BLTCON0(a6) ; Playfield schreiben
	addq.w	#1*4,d2			; (4*dx)+(1*4)
	move.w	d3,cl2_ext3_BLTAPTL-cl2_ext3_BLTCON0(a6) ; (4*dy)-(2*dx)
	MULUF.W 16,d2			; ((4*dx)+(1*4))*16 = Länge der Linie
	move.w	d4,cl2_ext3_BLTAMOD-cl2_ext3_BLTCON0(a6) ;4*(dy-dx)
	addq.w	#2,d2			; Breite = 1 Wort
	move.w	d2,cl2_ext3_BLTSIZE-cl2_ext3_BLTCON0(a6)
	SUBF.W	cl2_extension3_size,a6
mgv_draw_lines_skip2
	dbf	d6,mgv_draw_lines_loop2
mgv_draw_lines_skip3
	swap	d7			; Flächenzähler
	dbf	d7,mgv_draw_lines_loop1
	lea	variables+mgv_lines_counter(pc),a0
	move.w	a4,(a0)			; Anzahl der Linien
	movem.l (a7)+,a3-a6
	rts
	CNOP 0,4
mgv_draw_lines_init
	move.l	extra_pf1(a3),a0
	move.l	(a0),d0
	add.l	#ALIGN_64KB,d0
	clr.w	d0
	move.l	cl2_construction2(a3),a0
	swap	d0			;High
	move.w	d0,cl2_extension2_entry+cl2_ext2_BLTCPTH+WORD_SIZE(a0) ; Playfield lesen
	move.w	d0,cl2_extension2_entry+cl2_ext2_BLTDPTH+WORD_SIZE(a0) ; Playfield schreiben
	rts

	CNOP 0,4
mgv_fill_extra_playfield
	move.l	extra_pf1(a3),a0
	move.l	(a0),d0
	add.l	#ALIGN_64KB,d0
	clr.w	d0
	move.l	cl2_construction2(a3),a0
	ADDF.L	(extra_pf1_plane_width*visible_lines_number*extra_pf1_depth)-2,d0 ;Ende des Playfieldes
	move.w	d0,cl2_extension4_entry+cl2_ext4_BLTAPTL+WORD_SIZE(a0) ;Quelle
	move.w	d0,cl2_extension4_entry+cl2_ext4_BLTDPTL+WORD_SIZE(a0) ;Ziel
	swap	d0
	move.w	d0,cl2_extension4_entry+cl2_ext4_BLTAPTH+WORD_SIZE(a0) ;Quelle
	move.w	d0,cl2_extension4_entry+cl2_ext4_BLTDPTH+WORD_SIZE(a0) ;Ziel
	rts

	CNOP 0,4
mgv_copy_extra_playfield
	lea	spr_ptrs_construction(pc),a2
	move.l	(a2)+,a0		; 1. Sprite-Struktur (SPR0)
	ADDF.W	(spr_pixel_per_datafetch/4),a0 ; Sprite-Header überspringen
	move.l	(a2),a1			; 2. Sprite-Struktur (SPR1)
	ADDF.W	(spr_pixel_per_datafetch/4),a1 ; Sprite-Header überspringen
	move.l	extra_pf1(a3),a2
	move.l	(a2),d0
	add.l	#ALIGN_64KB,d0
	clr.w	d0
	move.l	d0,a2
	MOVEF.W visible_lines_number-1,d7 ; Höhe des Einzelsprites
mgv_copy_extra_playfield_loop
	move.l	(a2)+,(a0)+		; Bitplane1 64 Pixel
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+		; Bitplane2 64 Pixel
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a1)+		; Bitplane3 64 Pixel
	move.l	(a2)+,(a1)+
	addq.w	#8,a1			; Bitplane4 64 Pixel überspringen
	dbf	d7,mgv_copy_extra_playfield_loop
	rts

	CNOP 0,4
mgv_set_second_copperlist
	move.l	cl2_construction2(a3),a0 
	move.l	a0,d0
	ADDF.L	cl2_extension4_entry,d0
	moveq	#0,d1
	move.w	mgv_lines_counter(a3),d1
	IFEQ mgv_count_lines_enabled
		cmp.w	$140000,d1
		blt.s	mgv_skip
		move.w	d1,$140000
mgv_set_second_copperlist_skip
	ENDC
	MULUF.W cl2_extension3_size,d1,d2
	sub.l	d1,d0
	move.w	d0,cl2_extension2_entry+cl2_ext2_COP2LCL+WORD_SIZE(a0)
	swap	d0
	move.w	d0,cl2_extension2_entry+cl2_ext2_COP2LCH+WORD_SIZE(a0)
	rts


	CNOP 0,4
colors_fader_cross
	movem.l a4-a6,-(a7)
	tst.w	cfc_rgb8_active(a3)
	bne.s	colors_fader_cross_quit
	move.w	cfc_rgb8_fader_angle(a3),d2
	move.w	d2,d0
	ADDF.W	cfc_rgb8_fader_angle_speed,d0 ; nächster Winkel
	cmp.w	#sine_table_length/2,d0 ; Winkel <= 180 Grad ?
	ble.s	colors_fader_cross_skip
	MOVEF.W sine_table_length/2,d0	; 180 Grad
colors_fader_cross_skip
	move.w	d0,cfc_rgb8_fader_angle(a3)
	MOVEF.W cfc_rgb8_colors_number*3,d6 ; RGB-Zähler
	lea	sine_table,a0
	move.w	(a0,d2.w*2),d0		; sin(w)
	MULSF.W cfc_rgb8_fader_radius*2,d0,d1 ; y'=(yr*sin(w))/2^15
	swap	d0
	ADDF.W	cfc_rgb8_fader_center,d0
	lea	spr_rgb8_color_table+(cfc_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a0 ; Puffer für Farbwerte
	lea	cfc_rgb8_color_table+(cfc_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a1 ; Sollwerte
	move.w	cfc_rgb8_color_table_start(a3),d1
	MULUF.W LONGWORD_SIZE,d1	; * 32
	lea	(a1,d1.w*8),a1
	move.w	d0,a5			; Additions-/Subtraktionswert für Blau
	swap	d0
	clr.w	d0
	move.l	d0,a2			; Additions-/Subtraktionswert für Rot
	lsr.l	#8,d0
	move.l	d0,a4			; Additions-/Subtraktionswert für Grün
	MOVEF.W cfc_rgb8_colors_number-1,d7
	bsr	cfc_rgb8_fader_loop
	move.w	d6,cfc_rgb8_colors_counter(a3) ; Fading beendet ?
	bne.s	colors_fader_cross_quit
	move.w	#FALSE,cfc_rgb8_active(a3)
colors_fader_cross_quit
	movem.l (a7)+,a4-a6
	rts

	RGB8_COLOR_FADER cfc

	CNOP 0,4
cfc_rgb8_copy_color_table
	IFNE cl1_size2
		move.l	a4,-(a7)
	ENDC
	tst.w	cfc_rgb8_copy_colors_active(a3)
	bne.s	cfc_rgb8_copy_color_table_quit
	move.w	#RB_NIBBLES_MASK,d3
	IFGT cfc_rgb8_colors_number-32
		moveq	#cfc_rgb8_start_xolor*8,d4 ; Color-Bank Farbregisterzähler
	ENDC
	lea	spr_rgb8_color_table+(cfc_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a0 ; Puffer für Farbwerte
	move.l	cl1_display(a3),a1 
	ADDF.W	cl1_COLOR18_high1+WORD_SIZE,a1
	IFNE cl1_size1
		move.l	cl1_construction1(a3),a2
		ADDF.W	cl1_COLOR18_high1+WORD_SIZE,a2
	ENDC
	IFNE cl1_size2
		move.l	cl1_construction2(a3),a4
		ADDF.W	cl1_COLOR18_high1+WORD_SIZE,a4
	ENDC
	MOVEF.W cfc_rgb8_colors_number-1,d7
cfc_rgb8_copy_color_table_loop
	move.l	(a0)+,d0		; RGB8-Farbwert
	move.l	d0,d2		
	RGB8_TO_RGB4_HIGH d0,d1,d3
	move.w	d0,(a1)			; COLORxx High-Bits
	IFNE cl1_size1
		move.w	d0,(a2)		; COLORxx High-Bits
	ENDC
	IFNE cl1_size2
		move.w	d0,(a4)		; COLORxx High-Bits
	ENDC
	RGB8_TO_RGB4_LOW d2,d1,d3
	move.w	d2,cl1_COLOR18_low1-cl1_COLOR18_high1(a1) ; Low-Bits COLORxx
	addq.w	#LONGWORD_SIZE,a1	; nächstes Farbregister
	IFNE cl1_size1
		move.w	d2,cl1_COLOR18_low1-cl1_COLOR18_high1(a2) ; Low-Bits COLORxx
		addq.w	#LONGWORD_SIZE,a2 ; nächstes Farbregister
	ENDC
	IFNE cl1_size2
		move.w	d2,cl1_COLOR18_low1-cl1_COLOR18_high1(a4) ; Low-Bits COLORxx
		addq.w	#LONGWORD_SIZE,a4 ; nächstes Farbregister
	ENDC
	IFGT cfc_rgb8_colors_number-32
		addq.b	#1<<3,d4	; Farbregister-Zähler erhöhen
		bne.s	cfc_rgb8_copy_color_table_skip1
		addq.w	#LONGWORD_SIZE,a1 ; CMOVE BPLCON3 überspringen
		IFNE cl1_size1
			addq.w	#LONGWORD_SIZE,a2 ; CMOVE BPLCON3 überspringen
		ENDC
		IFNE cl1_size2
			addq.w	#LONGWORD_SIZE,a4 ; CMOVE BPLCON3überspringen
		ENDC
cfc_rgb8_copy_color_table_skip1
	ENDC
	dbf	d7,cfc_rgb8_copy_color_table_loop
	tst.w	cfc_rgb8_colors_counter(a3)
	bne.s	cfc_rgb8_copy_color_table_quit
	move.w	#FALSE,cfc_rgb8_copy_colors_active(a3) ; Kopieren beendet
	move.w	#cfc_rgb8_fader_delay,cfc_rgb8_fader_delay_counter(a3) ; Zähler zurücksetzen
	move.w	cfc_rgb8_color_table_start(a3),d0
	addq.w  #1,d0			; nächste Farbtabelle
	cmp.w	#cfc_rgb8_color_tables_number,d0 ; Ende der Farbtabelle ?
	blt.s   cfc_rgb8_copy_color_table_skip2
	moveq   #0,d0			; Neustart
cfc_rgb8_copy_color_table_skip2
	move.w	d0,cfc_rgb8_color_table_start(a3)
cfc_rgb8_copy_color_table_quit
	IFNE cl1_size2
		move.l  (a7)+,a4
	ENDC
	rts


	CNOP 0,4
control_counters
	move.w	mgv_morph_delay_counter(a3),d0
	bmi.s	control_counters_skip2
	subq.w	#1,d0
	bpl.s	control_counters_skip1
	clr.w	mgv_morph_active(a3)
control_counters_skip1
	move.w	d0,mgv_morph_delay_counter(a3) 
control_counters_skip2
	move.w	cfc_rgb8_fader_delay_counter(a3),d0
	bmi.s	control_counters_skip4
	subq.w	#1,d0
	bpl.s	control_counters_skip3
	move.w	#cfc_rgb8_colors_number*3,cfc_rgb8_colors_counter(a3)
	clr.w	cfc_rgb8_active(a3)
	move.w	#sine_table_length/4,cfc_rgb8_fader_angle(a3) ; 90 Grad
	clr.w	cfc_rgb8_copy_colors_active(a3)
control_counters_skip3
	move.w	d0,cfc_rgb8_fader_delay_counter(a3) 
control_counters_skip4
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
	beq.s	eh_start_colors_fader_cross
	subq.w	#1,d0
	beq.s	eh_start_vert_text_scroll
effects_handler_quit
	rts
	CNOP 0,4
eh_start_colors_fader_cross
	clr.w	cfc_rgb8_active(a3)
	move.w	#cfc_rgb8_colors_number*3,cfc_rgb8_colors_counter(a3)
	clr.w	cfc_rgb8_copy_colors_active(a3)
	rts
	CNOP 0,4
eh_start_vert_text_scroll
	move.w	#vts_vert_scroll_speed,vts_variable_vert_scroll_speed(a3)
	rts


	INCLUDE "int-autovectors-handlers.i"

; ** Level-7-Interrupt-Server **
	CNOP 0,4
NMI_int_server
	rts


	INCLUDE "help-routines.i"


	INCLUDE "sys-structures.i"


	CNOP 0,4
pf1_rgb8_color_table
	DC.L color00_bits,$f7e954

	CNOP 0,4
pf2_rgb8_color_table
	DC.L color00_bits,$000000

	CNOP 0,4
spr_rgb8_color_table
	REPT spr_colors_number
		DC.L color00_bits
	ENDR

	CNOP 0,4
spr_ptrs_construction
	DS.L spr_number

	CNOP 0,4
spr_ptrs_display
	DS.L spr_number

; **** Vert-Text-Scroll ****
vts_ascii
	DC.B "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.!?-'():\/#*+<> "
vts_ascii_end
	EVEN

	CNOP 0,2
vts_characters_offsets
	DS.W vts_ascii_end-vts_ascii

	CNOP 0,2
vts_characters_x_positions
	DS.W vts_text_characters_per_line

	CNOP 0,2
vts_characters_y_positions
	DS.W vts_text_characters_per_column

	CNOP 0,4
vts_characters_image_ptrs
	DS.L vts_text_characters_number

; **** Morph-Glenz-Vectors ****
	CNOP 0,2
mgv_object_coords
; * Zoom-In *
	DS.W mgv_object_edge_points_number*3

; ** Formen des Objekts **
; ** Form 1 **
	CNOP 0,2
mgv_object_shape1_coords
; ** Quader 1 **
	DC.W -(20*8),-(120*8),-(20*8)	; P0
	DC.W 20*8,-(120*8),-(20*8)	; P1
	DC.W 20*8,120*8,-(20*8)		; P2
	DC.W -(20*8),120*8,-(20*8)	; P3
	DC.W -(20*8),-(120*8),20*8	; P4
	DC.W 20*8,-(120*8),20*8		; P5
	DC.W 20*8,120*8,20*8		; P6
	DC.W -(20*8),120*8,20*8		; P7
	DC.W 0,0,-(20*8)		; P8
	DC.W 0,0,20*8			; P9
	DC.W -(20*8),0,0		; P10
	DC.W 20*8,0,0			; P11
	DC.W 0,-(120*8),0		; P12
	DC.W 0,120*8,0			; P13
; ** Form 2 **
	CNOP 0,2
mgv_object_shape2_coords
; ** Pyramide **
	DC.W -(10*8),-(20*8),-(10*8)	; P0
	DC.W 10*8,-(20*8),-(10*8)	; P1
	DC.W 20*8,120*8,-(20*8)		; P2
	DC.W -(20*8),120*8,-(20*8)	; P3
	DC.W -(10*8),-(20*8),10*8	; P4
	DC.W 10*8,-(20*8),10*8		; P5
	DC.W 20*8,120*8,20*8		; P6
	DC.W -(20*8),120*8,20*8		; P7
	DC.W 0,50*8,-(15*8)		; P8
	DC.W 0,50*8,15*8		; P9
	DC.W -(15*8),50*8,0		; P10
	DC.W 15*8,50*8,0		; P11
	DC.W 0,-(120*8),0		; P12
	DC.W 0,120*8,0			; P13
; ** Form 3 **
	CNOP 0,2
mgv_object_shape3_coords
; ** Keil 1 **
	DC.W -(20*8),-(80*8),-(20*8) 	; P0
	DC.W 20*8,-(80*8),-(20*8)	; P1
	DC.W 20*8,80*8,-(20*8)		; P2
	DC.W -(20*8),80*8,-(20*8)	; P3
	DC.W -(20*8),-(80*8),20*8	; P4
	DC.W 20*8,-(80*8),20*8		; P5
	DC.W 20*8,80*8,20*8		; P6
	DC.W -(20*8),80*8,20*8		; P7
	DC.W 0,0,-(20*8)		; P8
	DC.W 0,0,20*8			; P9
	DC.W -(20*8),0,0		; P10
	DC.W 20*8,0,0			; P11
	DC.W 0,-(120*8),0		; P12
	DC.W 0,120*8,0			; P13
; ** Form 4 **
	CNOP 0,2
mgv_object_shape4_coords
; ** Keil 2 **
	DC.W -(20*8),-(10*8),-(20*8) 	; P0
	DC.W 20*8,-(10*8),-(20*8)	; P1
	DC.W 20*8,10*8,-(20*8)		; P2
	DC.W -(20*8),10*8,-(20*8)	; P3
	DC.W -(20*8),-(10*8),20*8	; P4
	DC.W 20*8,-(10*8),20*8		; P5
	DC.W 20*8,10*8,20*8		; P6
	DC.W -(20*8),10*8,20*8		; P7
	DC.W 0,0,-(20*8)		; P8
	DC.W 0,0,20*8			; P9
	DC.W -(20*8),0,0		; P10
	DC.W 20*8,0,0			; P11
	DC.W 0,-(60*8),0		; P12
	DC.W 0,60*8,0			; P13
	IFNE mgv_morph_loop_enabled
; ** Form 5 **
		CNOP 0,2
mgv_object_shape5_coords
; * Zoom-Out *
		DS.W mgv_object_edge_points_number*3
	ENDC

	CNOP 0,4
mgv_object_info
; ** 1. Fläche **
	DC.L 0				; Zeiger auf Koords
	DC.W mgv_object_face1_color	; Farbe der Fläche
	DC.W mgv_object_face1_lines_number-1 ; Anzahl der Linien
; ** 2. Fläche **
	DC.L 0				; Zeiger auf Koords
	DC.W mgv_object_face2_color	; Farbe der Fläche
	DC.W mgv_object_face2_lines_number-1 ; Anzahl der Linien
; ** 3. Fläche **
	DC.L 0				; Zeiger auf Koords
	DC.W mgv_object_face3_color	; Farbe der Fläche
	DC.W mgv_object_face3_lines_number-1 ; Anzahl der Linien

; ** 4. Fläche **
	DC.L 0				; Zeiger auf Koords
	DC.W mgv_object_face4_color	; Farbe der Fläche
	DC.W mgv_object_face4_lines_number-1 ; Anzahl der Linien
; ** 5. Fläche **
	DC.L 0				; Zeiger auf Koords
	DC.W mgv_object_face5_color	; Farbe der Fläche
	DC.W mgv_object_face5_lines_number-1 ; Anzahl der Linien
; ** 6. Fläche **
	DC.L 0				; Zeiger auf Koords
	DC.W mgv_object_face6_color	; Farbe der Fläche
	DC.W mgv_object_face6_lines_number-1 ; Anzahl der Linien
; ** 7. Fläche **
	DC.L 0				; Zeiger auf Koords
	DC.W mgv_object_face7_color	; Farbe der Fläche
	DC.W mgv_object_face7_lines_number-1 ; Anzahl der Linien
; ** 8. Fläche **
	DC.L 0				; Zeiger auf Koords
	DC.W mgv_object_face8_color	; Farbe der Fläche
	DC.W mgv_object_face8_lines_number-1 ; Anzahl der Linien

; ** 9. Fläche **
	DC.L 0				; Zeiger auf Koords
	DC.W mgv_object_face9_color	; Farbe der Fläche
	DC.W mgv_object_face9_lines_number-1 ; Anzahl der Linien
; ** 10. Fläche **
	DC.L 0				; Zeiger auf Koords
	DC.W mgv_object_face10_color	; Farbe der Fläche
	DC.W mgv_object_face10_lines_number-1 ; Anzahl der Linien
; ** 11. Fläche **
	DC.L 0				; Zeiger auf Koords
	DC.W mgv_object_face11_color	; Farbe der Fläche
	DC.W mgv_object_face11_lines_number-1 ; Anzahl der Linien
; ** 12. Fläche **
	DC.L 0				; Zeiger auf Koords
	DC.W mgv_object_face12_color	; Farbe der Fläche
	DC.W mgv_object_face12_lines_number-1 ; Anzahl der Linien

; ** 13. Fläche **
	DC.L 0				; Zeiger auf Koords
	DC.W mgv_object_face13_color	; Farbe der Fläche
	DC.W mgv_object_face13_lines_number-1 ; Anzahl der Linien
; ** 14. Fläche **
	DC.L 0				; Zeiger auf Koords
	DC.W mgv_object_face14_color	; Farbe der Fläche
	DC.W mgv_object_face14_lines_number-1 ; Anzahl der Linien
; ** 15. Fläche **
	DC.L 0				; Zeiger auf Koords
	DC.W mgv_object_face15_color	; Farbe der Fläche
	DC.W mgv_object_face15_lines_number-1 ; Anzahl der Linien
; ** 16. Fläche **
	DC.L 0				; Zeiger auf Koords
	DC.W mgv_object_face16_color	; Farbe der Fläche
	DC.W mgv_object_face16_lines_number-1 ; Anzahl der Linien

; ** 17. Fläche **
	DC.L 0				; Zeiger auf Koords
	DC.W mgv_object_face17_color	; Farbe der Fläche
	DC.W mgv_object_face17_lines_number-1 ; Anzahl der Linien
; ** 18. Fläche **
	DC.L 0				; Zeiger auf Koords
	DC.W mgv_object_face18_color	; Farbe der Fläche
	DC.W mgv_object_face18_lines_number-1 ; Anzahl der Linien
; ** 19. Fläche **
	DC.L 0				; Zeiger auf Koords
	DC.W mgv_object_face19_color	; Farbe der Fläche
	DC.W mgv_object_face19_lines_number-1 ; Anzahl der Linien
; ** 20. Fläche **
	DC.L 0				; Zeiger auf Koords
	DC.W mgv_object_face20_color	; Farbe der Fläche
	DC.W mgv_object_face20_lines_number-1 ; Anzahl der Linien

; ** 21. Fläche **
	DC.L 0				; Zeiger auf Koords
	DC.W mgv_object_face21_color	; Farbe der Fläche
	DC.W mgv_object_face21_lines_number-1 ; Anzahl der Linien
; ** 22. Fläche **
	DC.L 0				; Zeiger auf Koords
	DC.W mgv_object_face22_color	; Farbe der Fläche
	DC.W mgv_object_face22_lines_number-1 ; Anzahl der Linien
; ** 23. Fläche **
	DC.L 0				; Zeiger auf Koords
	DC.W mgv_object_face23_color	; Farbe der Fläche
	DC.W mgv_object_face23_lines_number-1 ; Anzahl der Linien
; ** 24. Fläche **
	DC.L 0				; Zeiger auf Koords
	DC.W mgv_object_face24_color	; Farbe der Fläche
	DC.W mgv_object_face24_lines_number-1 ; Anzahl der Linien

	CNOP 0,2
mgv_object_edges
	DC.W 0*2,1*2,8*2,0*2		; Fläche vorne, Dreieck 12 Uhr
	DC.W 1*2,2*2,8*2,1*2		; Fläche vorne, Dreieck 3 Uhr
	DC.W 2*2,3*2,8*2,2*2		; Fläche vorne, Dreieck 6 Uhr
	DC.W 3*2,0*2,8*2,3*2		; Fläche vorne, Dreieck 9 Uhr

	DC.W 5*2,4*2,9*2,5*2		; Fläche hinten, Dreieck 12 Uhr
	DC.W 4*2,7*2,9*2,4*2		; Fläche hinten, Dreieck 3 Uhr
	DC.W 7*2,6*2,9*2,7*2		; Fläche hinten, Dreieck 6 Uhr
	DC.W 6*2,5*2,9*2,6*2		; Fläche hinten, Dreieck 9 Uhr

	DC.W 4*2,0*2,10*2,4*2		; Fläche links, Dreieck 12 Uhr
	DC.W 0*2,3*2,10*2,0*2		; Fläche links, Dreieck 3 Uhr
	DC.W 3*2,7*2,10*2,3*2		; Fläche links, Dreieck 6 Uhr
	DC.W 7*2,4*2,10*2,7*2		; Fläche links, Dreieck 9 Uhr

	DC.W 1*2,5*2,11*2,1*2		; Fläche rechts, Dreieck 12 Uhr
	DC.W 5*2,6*2,11*2,5*2		; Fläche rechts, Dreieck 3 Uhr
	DC.W 6*2,2*2,11*2,6*2		; Fläche rechts, Dreieck 6 Uhr
	DC.W 2*2,1*2,11*2,2*2		; Fläche rechts, Dreieck 9 Uhr

	DC.W 4*2,5*2,12*2,4*2		; Fläche oben, Dreieck 12 Uhr
	DC.W 5*2,1*2,12*2,5*2		; Fläche oben, Dreieck 3 Uhr
	DC.W 1*2,0*2,12*2,1*2		; Fläche oben, Dreieck 6 Uhr
	DC.W 0*2,4*2,12*2,0*2		; Fläche oben, Dreieck 9 Uhr

	DC.W 3*2,2*2,13*2,3*2		; Fläche unten, Dreieck 12 Uhr
	DC.W 2*2,6*2,13*2,2*2		; Fläche unten, Dreieck 3 Uhr
	DC.W 6*2,7*2,13*2,6*2		; Fläche unten, Dreieck 6 Uhr
	DC.W 7*2,3*2,13*2,7*2		; Fläche unten, Dreieck 9 Uhr

	CNOP 0,2
mgv_rot_xy_coords
	DS.W mgv_object_edge_points_number*2

	CNOP 0,4
mgv_morph_shapes_table
	DS.B morph_shape_size*mgv_morph_shapes_number

; **** Color-Fader-Cross ****
	CNOP 0,4
cfc_rgb8_color_table_fade_out
	REPT 8
		DC.L color00_bits
	ENDR

	CNOP 0,4
cfc_rgb8_color_table
	REPT 2
		DC.L color00_bits
	ENDR
	INCLUDE "Daten:Asm-Sources.AGA/projects/Superglenz/Colortables/1xGlenz-Colorgradient1.ct"
	REPT 2
		DC.L color00_bits
	ENDR

	REPT 2
		DC.L color00_bits
	ENDR
	INCLUDE "Daten:Asm-Sources.AGA/projects/Superglenz/Colortables/1xGlenz-Colorgradient5.ct"
	REPT 2
		DC.L color00_bits
	ENDR

	REPT 2
		DC.L color00_bits
	ENDR
	INCLUDE "Daten:Asm-Sources.AGA/projects/Superglenz/Colortables/1xGlenz-Colorgradient4.ct"
	REPT 2
		DC.L color00_bits
	ENDR


	INCLUDE "sys-variables.i"


	INCLUDE "sys-names.i"


	INCLUDE "error-texts.i"

; **** Vert-Textscroll ****
vts_text
	REPT vts_text_characters_per_column*vts_text_characters_per_line
		DC.B " "
	ENDR
	DC.B "# SUPERGLENZ #      "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "IS OUR CONTRICUTION "
	DC.B "                    "
	DC.B "TO NORDLICHT 2025   "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "CODING - DISSIDENT  "
	DC.B "                    "
	DC.B "GRAPHICS - NN       "
	DC.B "                    "
	DC.B "MUSIC - MAGNETIC FOX"
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "THE PARTS...        "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "--------------------"
	DC.B "                    "
	DC.B "# GLENZ 1 #         "
	DC.B "                    "
	DC.B "                    "
	DC.B "FACES:  20          "
	DC.B "                    "
	DC.B "SCREEN: 256 X 256   "
	DC.B "                    "
	DC.B "PLANES: 3           "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "--------------------"
	DC.B "                    "
	DC.B "# GLENZ 2 #         "
	DC.B "                    "
	DC.B "                    "
	DC.B "FACES:  36          "
	DC.B "                    "
	DC.B "SCREEN: 256 X 256   "
	DC.B "                    "
	DC.B "PLANES: 3           "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "--------------------"
	DC.B "                    "
	DC.B "# GLENZ 3 #         "
	DC.B "                    "
	DC.B "                    "
	DC.B "FACES:  40          "
	DC.B "                    "
	DC.B "SCREEN: 256 X 256   "
	DC.B "                    "
	DC.B "PLANES: 3           "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "--------------------"
	DC.B "                    "
	DC.B "# GLENZ 4 #         "
	DC.B "                    "
	DC.B "                    "
	DC.B "FACES:  48          "
	DC.B "                    "
	DC.B "SCREEN: 240 X 240   "
	DC.B "                    "
	DC.B "PLANES: 3           "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "--------------------"
	DC.B "                    "
	DC.B "# GLENZ 5 #         "
	DC.B "                    "
	DC.B "                    "
	DC.B "FACES:  128         "
	DC.B "                    "
	DC.B "SCREEN: 160 X 160   "
	DC.B "                    "
	DC.B "PLANES: 3           "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "--------------------"
	DC.B "                    "
	DC.B "# GLENZ 6 #         "
	DC.B "                    "
	DC.B "                    "
	DC.B "FACES:  2 X 24      "
	DC.B "                    "
	DC.B "SCREEN: 192 X 192   "
	DC.B "                    "
	DC.B "PLANES: 5           "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "--------------------"
	DC.B "                    "
	DC.B "# GLENZ 7 #         "
	DC.B "                    "
	DC.B "                    "
	DC.B "FACES:  3 X 20      "
	DC.B "                    "
	DC.B "SCREEN: 144 X 144   "
	DC.B "                    "
	DC.B "PLANES: 7           "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "ALL PARTS RUNNING   "
	DC.B "                    "
	DC.B "IN 50 FPS ON A      "
	DC.B "                    "
	DC.B "STOCK AMIGA 1200!   "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "#VANILLAMIGA RULEZ# "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "RESISTANCE IN 2025  "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B ASCII_CTRL_M
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B ASCII_CTRL_F
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B "                    "
	DC.B ASCII_CTRL_V
	DC.B "                    "
	EVEN


; ## Grafikdaten nachladen ##

; **** Vert-Text-Scroll ****
vts_image_data SECTION vts_gfx,DATA
	INCBIN "Daten:Asm-Sources.AGA/projects/Superglenz/fonts/8x7x2-Font.rawblit"
	DS.B vts_image_plane_width*vts_image_depth ; Leerzeile

	END
