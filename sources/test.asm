; Includedatei: "normsource-includes/equals.i"
; Datum:        19.02.2023
; Version:      5.6

  MC68020

; ** Konstanten **
; ----------------

; **** Main ****
TRUE                                EQU 0
FALSE                               EQU -1
FALSE_BYTE                              EQU $ff
FALSE_WORD                              EQU $ffff
FALSE_LONGWORD                              EQU $ffffffff

BYTE_SIZE                            EQU 1
WORD_SIZE                            EQU 2
LONGWORD_SIZE                        EQU 4
QUADWORD_SIZE                        EQU 8

NIBBLE_SHIFT_BITS                    EQU 4
NIBBLE_SHIFT                         EQU 16
NIBBLE_MASK_LOW                        EQU $0f
NIBBLE_MASK_HIGH                        EQU $f0
NIBBLE_SIGN_MASK                      EQU $8
NIBBLE_SIGN_BIT                       EQU 3

BYTE_SHIFT_BITS                      EQU 8
BYTE_MASK                            EQU $ff
BYTE_SIGN_MASK                        EQU $80
BYTE_SIGN_BIT                         EQU 7

WORD_MASK                            EQU $ffff
WORD_SIGN_MASK                        EQU $8000
WORD_SIGN_BIT                         EQU 15

ALIGN_64KB                           EQU $ffff

PAL_FPS                              EQU 50
NTSC_FPS                             EQU 60
                                      
PAL_CLOCK_CONSTANT                    EQU 3524210
NTSC_CLOCK_CONSTANT                   EQU 3492064

exec_base                           EQU $0004

; **** Display ****
COLOR_CLOCK_SPEED                   EQU 280
LORES_PIXEL_SPEED                   EQU 140
HIRES_PIXEL_SPEED                   EQU 70
SHIRES_PIXEL_SPEED                  EQU 35
PIXEL_PER_LINE_MIN                  EQU 64
DMA_SLOT_PERIOD                     EQU COLOR_CLOCK_SPEED/LORES_PIXEL_SPEED
CMOVE_SLOT_PERIOD                   EQU DMA_SLOT_PERIOD*4
CWAIT_SLOT_PERIOD                   EQU DMA_SLOT_PERIOD*6
CL_X_WRAP                           EQU $1c0
CL_X_WRAP_6_BITPLANES_1X            EQU $1be
CL_X_WRAP_7_BITPLANES_1X            EQU $1b6
CL_X_WRAP_7_BITPLANES_2X            EQU $1b6
CL_Y_WRAP                           EQU $ff

HSTART_128_PIXEL_RIGHT_ALIGNED      EQU $141
HSTART_128_PIXEL                    EQU $e1
HSTART_144_PIXEL_RIGHT_ALIGNED      EQU $111
HSTART_144_PIXEL                    EQU $d9
HSTART_160_PIXEL_RIGHT_ALIGNED      EQU $121
HSTART_160_PIXEL                    EQU $d1
HSTART_176_PIXEL_RIGHT_ALIGNED      EQU $111
HSTART_176_PIXEL                    EQU $c9
HSTART_192_PIXEL_RIGHT_ALIGNED      EQU $101
HSTART_192_PIXEL                    EQU $c1
HSTART_224_PIXEL_RIGHT_ALIGNED      EQU $e1
HSTART_224_PIXEL                    EQU $b1
HSTART_240_PIXEL_RIGHT_ALIGNED      EQU $d1
HSTART_240_PIXEL                    EQU $a9
HSTART_256_PIXEL_RIGHT_ALIGNED      EQU $c1
HSTART_256_PIXEL                    EQU $a1
HSTART_320_PIXEL                    EQU $81
HSTART_352_PIXEL                    EQU $71
HSTART_OVERSCAN                     EQU $5b
HSTART_40_CHUNKY_PIXEL              EQU $81
HSTART_44_CHUNKY_PIXEL              EQU $67
HSTART_46_CHUNKY_PIXEL              EQU $5b
HSTART_47_CHUNKY_PIXEL              EQU $5b

HSTOP_64_PIXEL_LEFT_ALIGNED         EQU $c1
HSTOP_128_PIXEL_LEFT_ALIGNED        EQU $101
HSTOP_128_PIXEL                     EQU $161
HSTOP_144_PIXEL_LEFT_ALIGNED        EQU $111
HSTOP_144_PIXEL                     EQU $169
HSTOP_160_PIXEL_LEFT_ALIGNED        EQU $121
HSTOP_160_PIXEL                     EQU $171
HSTOP_176_PIXEL_LEFT_ALIGNED        EQU $131
HSTOP_176_PIXEL                     EQU $179
HSTOP_192_PIXEL_LEFT_ALIGNED        EQU $141
HSTOP_192_PIXEL                     EQU $181
HSTOP_224_PIXEL_LEFT_ALIGNED        EQU $161
HSTOP_224_PIXEL                     EQU $191
HSTOP_240_PIXEL_LEFT_ALIGNED        EQU $171
HSTOP_240_PIXEL                     EQU $1b9
HSTOP_256_PIXEL_LEFT_ALIGNED        EQU $181
HSTOP_256_PIXEL                     EQU $1a1
HSTOP_320_PIXEL                     EQU $1c1
HSTOP_352_PIXEL                     EQU $1d1
HSTOP_OVERSCAN                      EQU $1d3
HSTOP_40_CHUNKY_PIXEL               EQU $1c1
HSTOP_44_CHUNKY_PIXEL               EQU $1c7
HSTOP_46_CHUNKY_PIXEL               EQU $1c7
HSTOP_47_CHUNKY_PIXEL               EQU $1d3

VSTART_64_LINES                     EQU $8c
VSTART_80_LINES                     EQU $84
VSTART_128_LINES                    EQU $6c
VSTART_144_LINES                    EQU $64
VSTART_160_LINES                    EQU $5c
VSTART_176_LINES                    EQU $54
VSTART_192_LINES                    EQU $4c
VSTART_200_LINES                    EQU $48
VSTART_208_LINES                    EQU $44
VSTART_224_LINES                    EQU $3c
VSTART_240_LINES                    EQU $34
VSTART_256_LINES                    EQU $2c
VSTART_272_LINES                    EQU $24
VSTART_OVERSCAN_PAL                 EQU $1d
VSTART_OVERSCAN_NTSC                EQU $15

VSTOP_64_LINES                      EQU $cc
VSTOP_80_LINES                      EQU $d4
VSTOP_128_LINES                     EQU $ec
VSTOP_144_LINES                     EQU $f4
VSTOP_160_LINES                     EQU $fc
VSTOP_176_LINES                     EQU $104
VSTOP_192_LINES                     EQU $10c
VSTOP_NTSC                          EQU $f4
VSTOP_200_LINES                     EQU $110
VSTOP_208_LINES                     EQU $114
VSTOP_OVERSCAN_NTSC                 EQU $106
VSTOP_224_LINES                     EQU $11c
VSTOP_240_LINES                     EQU $124
VSTOP_256_LINES                     EQU $12c
VSTOP_272_LINES                     EQU $134
VSTOP_OVERSCAN_PAL                  EQU $138

HTOTAL_LORES_15K                    EQU 320
HTOTAL_OVERSCAN_LORES_15K           EQU 368
HTOTAL_HIRES_15K                    EQU 640
HTOTAL_OVERSCAN_HIRES_15K           EQU 736

VTOTAL_PAL                          EQU 256
VTOTAL_OVERSCAN_PAL                 EQU 283
VTOTAL_NTSC                         EQU 200
VTOTAL_OVERSCAN_NTSC                EQU 216

DDFSTART_32_PIXEL_RIGHT_ALIGNED_2X  EQU $c8
DDFSTART_64_PIXEL_RIGHT_ALIGNED_4X  EQU $b8
DDFSTART_128_PIXEL_RIGHT_ALIGNED    EQU $98
DDFSTART_128_PIXEL_1X               EQU $68
DDFSTART_128_PIXEL_2X               EQU $58
DDFSTART_144_PIXEL_RIGHT_ALIGNED_1X EQU $90
DDFSTART_160_PIXEL_1X               EQU $60
DDFSTART_160_PIXEL_2X               EQU $58
DDFSTART_192_PIXEL_RIGHT_ALIGNED    EQU $70
DDFSTART_192_PIXEL_1X               EQU $58
DDFSTART_192_PIXEL_2X               EQU $58
DDFSTART_192_PIXEL_4X               EQU $58
DDFSTART_224_PIXEL_1X               EQU $48
DDFSTART_224_PIXEL_2X               EQU $48
DDFSTART_256_PIXEL_RIGHT_ALIGNED    EQU $58
DDFSTART_256_PIXEL_1X               EQU $48
DDFSTART_256_PIXEL_2X               EQU $48
DDFSTART_512_PIXEL_RIGHT_ALIGNED    EQU $58
DDFSTART_512_PIXEL_4X               EQU $48
DDFSTART_320_PIXEL                  EQU $38
DDFSTART_640_PIXEL_1X               EQU $3c
DDFSTART_640_PIXEL_2X               EQU $3c
DDFSTART_640_PIXEL_4X               EQU $38
DDFSTART_1280_PIXEL_4X              EQU $38
DDFSTART_OVERSCAN_16_PIXEL          EQU $30
DDFSTART_OVERSCAN_32_PIXEL          EQU $28
DDFSTART_OVERSCAN_48_PIXEL          EQU $20
DDFSTART_OVERSCAN_64_PIXEL          EQU $18

DDFSTOP_STANDARD_MIN                EQU $40
DDFSTOP_32_PIXEL_LEFT_ALIGNED_2X    EQU $40
DDFSTOP_64_PIXEL_LEFT_ALIGNED_4X    EQU $40
DDFSTOP_128_PIXEL_LEFT_ALIGNED_1X   EQU $70
DDFSTOP_128_PIXEL_LEFT_ALIGNED_2X   EQU $58
DDFSTOP_128_PIXEL_LEFT_ALIGNED_4X   EQU $40
DDFSTOP_128_PIXEL_1X                EQU $90
DDFSTOP_128_PIXEL_2X                EQU $80
DDFSTOP_144_PIXEL_LEFT_ALIGNED_1X   EQU $78
DDFSTOP_160_PIXEL_1X                EQU $a8
DDFSTOP_160_PIXEL_2X                EQU $90
DDFSTOP_176_PIXEL_LEFT_ALIGNED_1X   EQU $88
DDFSTOP_192_PIXEL_LEFT_ALIGNED_1X   EQU $90
DDFSTOP_192_PIXEL_LEFT_ALIGNED_2X   EQU $88
DDFSTOP_192_PIXEL_LEFT_ALIGNED_4X   EQU $60
DDFSTOP_192_PIXEL_1X                EQU $b0
DDFSTOP_192_PIXEL_2X                EQU $a0
DDFSTOP_192_PIXEL_4X                EQU $80
DDFSTOP_224_PIXEL_1X                EQU $b8
DDFSTOP_224_PIXEL_2X                EQU $b8
DDFSTOP_256_PIXEL_LEFT_ALIGNED_1X   EQU $b0
DDFSTOP_256_PIXEL_LEFT_ALIGNED_2X   EQU $a0
DDFSTOP_256_PIXEL_LEFT_ALIGNED_4X   EQU $80
DDFSTOP_256_PIXEL_1X                EQU $c0
DDFSTOP_256_PIXEL_2X                EQU $a0
DDFSTOP_320_PIXEL_1X                EQU $d0
DDFSTOP_320_PIXEL_2X                EQU $c0
DDFSTOP_320_PIXEL_4X                EQU $a0
DDFSTOP_512_PIXEL_LEFT_ALIGNED_1X   EQU $b0
DDFSTOP_512_PIXEL_LEFT_ALIGNED_2X   EQU $a8
DDFSTOP_512_PIXEL_LEFT_ALIGNED_4X   EQU $a0
DDFSTOP_640_PIXEL_1X                EQU $d4
DDFSTOP_640_PIXEL_2X                EQU $d0
DDFSTOP_640_PIXEL_4X                EQU $c0
DDFSTOP_1280_PIXEL_4X               EQU $d0
DDFSTOP_OVERSCAN_16_PIXEL           EQU $d8
DDFSTOP_OVERSCAN_32_PIXEL           EQU $c8
DDFSTOP_OVERSCAN_64_PIXEL           EQU $c0
DDFSTOP_OVERSCAN_16_PIXEL_MIN       EQU $38
DDFSTOP_OVERSCAN_32_PIXEL_MIN       EQU $30
DDFSTOP_OVERSCAN_48_PIXEL_MIN       EQU $28
DDFSTOP_OVERSCAN_64_PIXEL_MIN       EQU $20
; ---------------------

pixel_per_line                      EQU 192
visible_pixels_number               EQU 192
visible_lines_number                EQU 192
MINROW                              EQU VSTOP_OVERSCAN_PAL

sine_table_length                   EQU 512

; **** Scroll-Playfield-Buttom ****
spb_min_vstart                      EQU VSTART_192_LINES
spb_max_vstop                       EQU VSTOP_OVERSCAN_PAL
spb_max_visible_lines_number        EQU 283
spb_y_radius                        EQU visible_lines_number+(spb_max_visible_lines_number-visible_lines_number)
spb_y_centre                        EQU visible_lines_number+(spb_max_visible_lines_number-visible_lines_number)

spbi_y_angle_speed                  EQU 2

spbo_y_angle_speed                  EQU 5


; **** Scroll-Playfield-Buttom ****
  RSRESET

spbi_active                           RS.W 1
spbi_y_angle                          RS.W 1

spbo_active                           RS.W 1
spbo_y_angle                          RS.W 1

variables_SIZE                        RS.B 0


; **** Scroll-Playfield-Buttom ****
start
  lea     variables(pc),a3
  moveq   #0,d0
  move.w  d0,spbi_active(a3)
  move.w  d0,spbi_y_angle(a3)

  moveq   #FALSE,d1
  move.w  d1,spbo_active(a3)
  move.w  #sine_table_length/4,spbo_y_angle(a3)

  lea     $140000,a4
loop
  bsr.s   scroll_playfield_buttom_in
  tst.w   spbi_active(a3)    ;Scroll-Playfield-Buttom-In an ?
  beq.s   loop
  rts

; ** Playfield von unten einscrollen **
; -------------------------------------
  CNOP 0,4
scroll_playfield_buttom_in
  tst.w   spbi_active(a3)    ;Scroll-Playfield-Buttom-In an ?
  bne.s   no_scroll_playfield_buttom_in ;Nein -> verzweige
  move.w  spbi_y_angle(a3),d2 ;Y-Winkel
  cmp.w   #sine_table_length/4,d2 ;90 Grad ?
  bge.s   spbi_finished      ;Ja -> verzweige
  lea     sine_table(pc),a0  
  move.w  (a0,d2.w*2),d0     ;sin(w)
  muls.w  #spb_y_radius*2,d0 ;y'=(sin(w)*yr)/2^15
  swap    d0
  add.w   #spb_y_centre,d0 ;y' + Y-Mittelpunkt
  addq.w  #spbi_y_angle_speed,d2 ;nächster Y-Winkel
  move.w  d2,spbi_y_angle(a3) 
  move.w  #spb_max_VSTOP,d3
  bsr.s   spb_set_display_window
no_scroll_playfield_buttom_in
  rts
  CNOP 0,4
spbi_finished
  moveq   #FALSE,d0
  move.w  d0,spbi_active(a3) ;Scroll-Playfield-Buttom-In aus
  rts


; ** Playfield nach unten ausscrollen **
; --------------------------------------
  CNOP 0,4
scroll_playfield_buttom_out
  tst.w   spbo_active(a3)    ;Vert-Scroll-Playfild-Out an ?
  bne.s   no_scroll_playfield_buttom_out ;Nein -> verzweige
  move.w  spbo_y_angle(a3),d2 ;Y-Winkel
  cmp.w   #sine_table_length/2,d2 ;180 Grad ?
  bge.s   spbo_finished      ;Ja -> verzweige
  lea     sine_table(pc),a0  
  move.w  (a0,d2.w*2),d0     ;cos(w)
  muls.w  #spb_y_radius*2,d0 ;y'=(cos(w)*yr)/2^15
  swap    d0
  add.w   #spb_y_centre,d0 ;y' + Y-Mittelpunkt
  addq.w  #spbo_y_angle_speed,d2 ;nächster Y-Winkel
  move.w  d2,spbo_y_angle(a3) 
  move.w  #spb_max_VSTOP,d3
  bsr.s   spb_set_display_window
no_scroll_playfield_buttom_out
  rts
  CNOP 0,4
spbo_finished
;  clr.w   fx_active(a3)      ;Effekte beendet
  moveq   #FALSE,d0
  move.w  d0,spbo_active(a3) ;Scroll-Playfield-Buttom-Out aus
  rts

  CNOP 0,4
spb_set_display_window
  moveq   #spb_min_VSTART,d1
  add.w   d0,d1              ;+ Y-Offset
  cmp.w   d3,d1              ;VSTOP-Maximum erreicht ?
  ble.s   spb_no_max_VSTOP1  ;Nein -> verzweige
  move.w  d3,d1              ;VSTOP korrigieren
spb_no_max_VSTOP1
;  move.l  cl2_display(a3),a1 
;  move.b  d1,cl2_DIWSTRT+2(a1) ;VSTART V7-V0
  move.w  d1,(a4)+
  move.w  #visible_lines_number,d2
  add.w   d1,d2              ;+ Höhe des Displays = VSTOP
  cmp.w   d3,d2              ;VSTOP-Maximum erreicht ?
  ble.s   spb_no_max_VSTOP2 ;Nein -> verzweige
  move.w  d3,d2              ;VSTOP korrigieren
spb_no_max_VSTOP2
  move.w  d2,(a4)+
;  move.b  d2,cl2_DIWSTOP+2(a1) ;VSTOP V7-V0
  lsr.w   #8,d1              ;VSTART V8-Bit in richtige Position bringen
;  move.w  cl2_DIWHIGH+2(a1),d0
;  and.w   #~(DIWHIGHF_VSTART8+DIWHIGHF_VSTOP8),d0 ;VSTART&VSTOP V8-Bit ggf. ausmaskieren
  move.b  d1,d2              ;V8-Bits
  move.w  d2,(a4)+
  or.w    d2,d0              ;VSTART V8 / VSTOP V8 ggf. setzen
;  move.w  d0,cl2_DIWHIGH+2(a1) ;setzen
  rts

sine_table
  DC.W $0000,$FE6E,$FCDC,$FB4A,$F9B9,$F827,$F696,$F505,$F375,$F1E5
  DC.W $F055,$EEC7,$ED39,$EBAB,$EA1F,$E893,$E708,$E57E,$E3F5,$E26D
  DC.W $E0E7,$DF61,$DDDD,$DC5A,$DAD9,$D959,$D7DA,$D65D,$D4E2,$D368
  DC.W $D1F0,$D07A,$CF05,$CD93,$CC22,$CAB3,$C947,$C7DC,$C674,$C50E
  DC.W $C3AA,$C249,$C0EA,$BF8D,$BE33,$BCDB,$BB86,$BA34,$B8E4,$B797
  DC.W $B64D,$B506,$B3C1,$B280,$B141,$B006,$AECD,$AD98,$AC66,$AB37
  DC.W $AA0C,$A8E3,$A7BE,$A69D,$A57F,$A464,$A34D,$A23A,$A12A,$A01E
  DC.W $9F15,$9E10,$9D0F,$9C12,$9B19,$9A23,$9932,$9844,$975B,$9675
  DC.W $9594,$94B6,$93DD,$9308,$9237,$916B,$90A2,$8FDE,$8F1F,$8E63
  DC.W $8DAC,$8CFA,$8C4B,$8BA2,$8AFD,$8A5C,$89C0,$8928,$8895,$8807
  DC.W $877D,$86F8,$8677,$85FC,$8584,$8512,$84A4,$843C,$83D7,$8378
  DC.W $831E,$82C8,$8277,$822B,$81E4,$81A2,$8164,$812C,$80F8,$80C9
  DC.W $809F,$807A,$805A,$803F,$8029,$8018,$800B,$8004,$8001,$8004
  DC.W $800B,$8018,$8029,$803F,$805A,$807A,$809F,$80C9,$80F8,$812C
  DC.W $8164,$81A2,$81E4,$822B,$8277,$82C8,$831E,$8378,$83D7,$843C
  DC.W $84A4,$8512,$8584,$85FC,$8677,$86F8,$877D,$8807,$8895,$8928
  DC.W $89C0,$8A5C,$8AFD,$8BA2,$8C4C,$8CFA,$8DAC,$8E63,$8F1F,$8FDE
  DC.W $90A2,$916B,$9237,$9308,$93DD,$94B6,$9594,$9675,$975B,$9844
  DC.W $9932,$9A23,$9B19,$9C12,$9D0F,$9E10,$9F15,$A01E,$A12A,$A23A
  DC.W $A34D,$A464,$A57F,$A69D,$A7BE,$A8E3,$AA0C,$AB37,$AC66,$AD98
  DC.W $AECD,$B006,$B141,$B280,$B3C1,$B506,$B64D,$B797,$B8E4,$BA34
  DC.W $BB86,$BCDB,$BE33,$BF8D,$C0EA,$C249,$C3AA,$C50E,$C674,$C7DC
  DC.W $C947,$CAB3,$CC22,$CD93,$CF05,$D07A,$D1F0,$D368,$D4E2,$D65D
  DC.W $D7DA,$D959,$DAD9,$DC5A,$DDDD,$DF61,$E0E7,$E26E,$E3F5,$E57E
  DC.W $E708,$E893,$EA1F,$EBAB,$ED39,$EEC7,$F056,$F1E5,$F375,$F505
  DC.W $F696,$F827,$F9B9,$FB4B,$FCDD,$FE6F,$0000,$0192,$0324,$04B6
  DC.W $0647,$07D9,$096A,$0AFB,$0C8B,$0E1B,$0FAB,$1139,$12C8,$1455
  DC.W $15E2,$176D,$18F8,$1A82,$1C0B,$1D93,$1F19,$209F,$2223,$23A6
  DC.W $2527,$26A8,$2826,$29A3,$2B1F,$2C98,$2E10,$2F87,$30FB,$326E
  DC.W $33DE,$354D,$36B9,$3824,$398C,$3AF2,$3C56,$3DB7,$3F16,$4073
  DC.W $41CD,$4325,$447A,$45CC,$471C,$4869,$49B3,$4AFB,$4C3F,$4D80
  DC.W $4EBF,$4FFA,$5133,$5268,$539A,$54C9,$55F5,$571D,$5842,$5963
  DC.W $5A81,$5B9C,$5CB3,$5DC7,$5ED6,$5FE3,$60EB,$61F0,$62F1,$63EE
  DC.W $64E7,$65DD,$66CE,$67BC,$68A5,$698B,$6A6C,$6B4A,$6C23,$6CF8
  DC.W $6DC9,$6E95,$6F5E,$7022,$70E2,$719D,$7254,$7306,$73B5,$745E
  DC.W $7504,$75A4,$7640,$76D8,$776B,$77F9,$7883,$7908,$7989,$7A05
  DC.W $7A7C,$7AEE,$7B5C,$7BC4,$7C29,$7C88,$7CE2,$7D38,$7D89,$7DD5
  DC.W $7E1C,$7E5E,$7E9C,$7ED4,$7F08,$7F37,$7F61,$7F86,$7FA6,$7FC1
  DC.W $7FD7,$7FE8,$7FF5,$7FFC,$7FFF,$7FFC,$7FF5,$7FE8,$7FD7,$7FC1
  DC.W $7FA6,$7F86,$7F61,$7F37,$7F08,$7ED4,$7E9C,$7E5E,$7E1C,$7DD5
  DC.W $7D89,$7D38,$7CE2,$7C88,$7C28,$7BC4,$7B5B,$7AEE,$7A7B,$7A04
  DC.W $7989,$7908,$7883,$77F9,$776B,$76D8,$7640,$75A4,$7503,$745E
  DC.W $73B4,$7306,$7254,$719D,$70E1,$7022,$6F5D,$6E95,$6DC9,$6CF8
  DC.W $6C23,$6B49,$6A6C,$698B,$68A5,$67BC,$66CE,$65DC,$64E7,$63EE
  DC.W $62F0,$61EF,$60EB,$5FE2,$5ED6,$5DC6,$5CB3,$5B9C,$5A81,$5963
  DC.W $5841,$571C,$55F4,$54C9,$539A,$5268,$5132,$4FFA,$4EBE,$4D80
  DC.W $4C3E,$4AFA,$49B3,$4869,$471C,$45CC,$4479,$4324,$41CD,$4073
  DC.W $3F16,$3DB7,$3C55,$3AF2,$398C,$3823,$36B9,$354C,$33DE,$326D
  DC.W $30FA,$2F86,$2E10,$2C98,$2B1E,$29A3,$2826,$26A7,$2527,$23A5
  DC.W $2222,$209E,$1F19,$1D92,$1C0A,$1A81,$18F8,$176D,$15E1,$1454
  DC.W $12C7,$1139,$0FAA,$0E1B,$0C8B,$0AFA,$096A,$07D8,$0647,$04B5
  DC.W $0323,$0191

variables DS.B variables_SIZE

  END
