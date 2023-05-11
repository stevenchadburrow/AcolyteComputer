; Acolyte Computer

; Running a W65C02 at 3.14 MHz

; VGA display at
; 320x240 4-color

; Support for
; PS/2 Keyboard
; SPI SDcard
; SPI EEPROM
; Square Wave Audio

; Memory Map
; $0000-$01FF = Zero Page / Stack
; $0200-$07FF = System RAM
; $0800-$7FFF = Video RAM
; $8000-$AFFF = General Purpose Banked RAM
; $B000-$BFFF = I/O Space (or RAM)
; $C000-$FFFF = ROM (2x banks)

; Writing to ROM produces output
; D0 = SPI-CLK
; D1 = SPI-MOSI
; D2 = SPI-EEPROM
; D3 = SPI-SDCARD
; D4 = MEM-BANK (both RAM and ROM)
; D5 = IO-ENABLE
; D6 = NMI-ENABLE
; D7 = AUDIO-OUT

; Writing to ROM also writes to RAM if the RAM is fast enough.
; This is not a problem when using the 128KB RAM, but when using
; only 32KB of RAM, it would show anything written to ROM in 
; the RAM space given.  So, when writing to ROM for output,
; make sure to write to $FFFF which is off-screen and is not 
; expected to be used.

; Input is through interrupts and /SO
; /NMI = KEY-CLK (can be disabled)
; /IRQ = KEY-DATA (and other interrupt sources)
; /SO = toggles when SPI-MISO is low


	.65C02


; PS/2 Keyboard Keycodes
ps2_return		.EQU $5A
ps2_backspace		.EQU $66
ps2_escape		.EQU $76
ps2_shift_left		.EQU $12
ps2_shift_right		.EQU $59
ps2_capslock		.EQU $58
ps2_numlock		.EQU $77
ps2_scrolllock		.EQU $7E
ps2_control		.EQU $14
ps2_alt			.EQU $11
ps2_tab			.EQU $0D
ps2_page_up		.EQU $7D
ps2_page_down		.EQU $7A
ps2_arrow_up		.EQU $75
ps2_arrow_down		.EQU $72
ps2_arrow_left		.EQU $6B
ps2_arrow_right		.EQU $74
ps2_insert		.EQU $70
ps2_delete		.EQU $71
ps2_home		.EQU $6C
ps2_end			.EQU $69
ps2_slash		.EQU $4A
ps2_space		.EQU $29
ps2_f1			.EQU $05
ps2_f2			.EQU $06
ps2_f3			.EQU $04
ps2_f4			.EQU $0C
ps2_f5			.EQU $03
ps2_f6			.EQU $0B
ps2_f7			.EQU $83
ps2_f8			.EQU $0A
ps2_f9			.EQU $01
ps2_f10			.EQU $09
ps2_f11			.EQU $78
ps2_f12			.EQU $07


; System RAM locations


key_array		.EQU $0200
key_error		.EQU $0280

key_write		.EQU $0300
key_read		.EQU $0301
key_data		.EQU $0302
key_counter		.EQU $0303
key_release		.EQU $0304
key_extended		.EQU $0305
key_shift		.EQU $0306
key_capslock		.EQU $0307
key_alt_control		.EQU $0308
key_code		.EQU $0309
key_status		.EQU $030A ; unused

printchar_x		.EQU $030B
printchar_y		.EQU $030C
printchar_invert	.EQU $030D

inputchar_value		.EQU $030E

spi_cs_enable		.EQU $030F

sub_read		.EQU $0310
sub_write		.EQU $0314
sub_jump		.EQU $0318
sub_index		.EQU $031C

command_mode		.EQU $0320
command_addr1_low	.EQU $0321
command_addr1_high	.EQU $0322
command_addr2_low	.EQU $0323
command_addr2_high	.EQU $0324
command_addr3_low	.EQU $0325
command_addr3_high	.EQU $0326
command_addr4_low	.EQU $0327
command_addr4_high	.EQU $0328
command_data		.EQU $0329
command_byte1		.EQU $032A
command_byte2		.EQU $032B
command_byte3		.EQU $032C
command_place		.EQU $032D
command_function	.EQU $032E
command_temp		.EQU $032F

basic_counter		.EQU $0330
basic_addr_low		.EQU $0331
basic_addr_high		.EQU $0332
basic_data		.EQU $0333
basic_first		.EQU $0334
basic_bytes		.EQU $0335
basic_var_low		.EQU $0336
basic_var_high		.EQU $0337
basic_nested		.EQU $0338
basic_operator		.EQU $0339
basic_next		.EQU $033A
basic_compare_first	.EQU $033B
basic_compare_second	.EQU $033C
basic_compare_operator	.EQU $033D
basic_colon		.EQU $033E
basic_quotes		.EQU $033F
basic_counter_change	.EQU $0340
basic_rts_low1		.EQU $0341
basic_rts_high1		.EQU $0342
basic_rts_low2		.EQU $0343
basic_rts_high2		.EQU $0344
basic_sub_random	.EQU $0345
basic_sub_random_var	.EQU $0356

output_byte		.EQU $0357

basic_user_array	.EQU $0358 ; 8 bytes long

jump_printchar		.EQU $0360 ; jump sub-routines for ease of programming
jump_inputchar		.EQU $0368
jump_spi_eeprom_write	.EQU $0370
jump_spi_eeprom_read	.EQU $0378
jump_spi_sdcard_init	.EQU $0380
jump_spi_sdcard_read	.EQU $0388

jump_vector_nmi		.EQU $0390
jump_vector_irq		.EQU $0398
jump_vector_irq_extra	.EQU $03A0 ; 16 bytes available

command_array_prev	.EQU $03B0
command_array		.EQU $03D8 ; 40 characters til end

sdcard_memory		.EQU $0400 ; shared with game_field

screen 			.EQU $0800

basic_A			.EQU $8000
basic_B			.EQU $8100
basic_C			.EQU $8200
basic_D			.EQU $8300
basic_W			.EQU $8400
basic_X			.EQU $8500
basic_Y			.EQU $8600
basic_Z			.EQU $8700
basic_code		.EQU $8800
basic_code_end		.EQU $AFFF
basic_code_error	.EQU $B000 ; one past



; the start of code

	.ORG $C000

vector_reset

tetra_field		.EQU $0400

tetra_score_low		.EQU $0500
tetra_score_high	.EQU $0501
tetra_piece		.EQU $0502
tetra_piece_next	.EQU $0503
tetra_location		.EQU $0504
tetra_cycle		.EQU $0505
tetra_speed		.EQU $0506
tetra_overscan		.EQU $0507
	
tetra
	STZ sub_write+1				; clear out all screen RAM 
	LDA #$08
	STA sub_write+2
tetra_screen_loop
	LDA #$00 ; black
	JSR sub_write
	INC sub_write+1
	BNE tetra_screen_loop
	INC sub_write+2
	LDA sub_write+2
	CMP #$80
	BNE tetra_screen_loop
	STZ sub_write+1
	LDA #$08
	STA sub_write+2
tetra_init_loop
	LDA #$AA ; fill color
	JSR sub_write
	INC sub_write+1
	LDA sub_write+1
	CMP #$38
	BEQ tetra_init_loop_inc1
	CMP #$B8
	BEQ tetra_init_loop_inc2
	JMP tetra_init_loop
tetra_init_loop_inc1
	LDA #$80
	STA sub_write+1
	JMP tetra_init_loop
tetra_init_loop_inc2
	STZ sub_write+1
	INC sub_write+2
	LDA sub_write+2
	CMP #$80
	BNE tetra_init_loop

tetra_random
	CLC
	JSR basic_sub_random
	AND #%00011100
	BEQ tetra
	STA tetra_piece_next
	STZ tetra_score_low
	STZ tetra_score_high
	STZ tetra_cycle
	LDA #$FF
	STA tetra_speed
	LDX #$00
tetra_field_loop
	STZ tetra_field,X
	INX
	BNE tetra_field_loop

tetra_start
	CLC
	JSR basic_sub_random
	AND #%00011100
	BEQ tetra_start
	PHA
	LDA tetra_piece_next
	STA tetra_piece
	PLA
	STA tetra_piece_next
	LDA #$06 
	STA tetra_location
	JSR tetra_display
	JSR tetra_clear
	JSR tetra_place
	JSR tetra_draw
	LDX #$00
tetra_loop
	INX
	BNE tetra_continue
	INC tetra_cycle
	LDA tetra_cycle
	CMP tetra_speed 
	BEQ tetra_down
	JMP tetra_loop
tetra_continue
	JSR inputchar
	CMP #$00 ; needed
	BEQ tetra_loop
	PHA
	CLC
	JSR basic_sub_random ; to add some randomization
	PLA
	CMP #$1B ; escape
	BNE tetra_next1
	;LDA key_alt_control
	;BEQ tetra_next1
	LDY #$C0 ; reset	
	LDX #$00
	JMP switch_banks
tetra_next1
	CMP #$15 ; F12
	BNE tetra_next2
	;LDA key_alt_control
	;BEQ tetra_next2
	JMP tetra
tetra_next2
	CMP #"w" ; up
	BEQ tetra_up
	CMP #"W"
	BEQ tetra_up
	CMP #$11 ; arrow up
	BEQ tetra_up
	CMP #"8"
	BEQ tetra_up
	JMP tetra_controls1
tetra_up
	LDX #$00
	STZ tetra_cycle
	JMP tetra_controls11
tetra_controls1
	CMP #"s" ; down
	BEQ tetra_down
	CMP #"S"
	BEQ tetra_down
	CMP #$12 ; arrow down
	BEQ tetra_down
	CMP #"2"
	BEQ tetra_down
	JMP tetra_controls3
tetra_down
	LDX #$00
	STZ tetra_cycle
	LDA tetra_location
	CLC
	ADC #$10
	STA tetra_location
	JSR tetra_clear
	JSR tetra_place
	CMP #$FF ; error
	BEQ tetra_controls2
	JMP tetra_controls11
tetra_controls2
	LDA tetra_location
	SEC
	SBC #$10
	STA tetra_location
	JSR tetra_clear
	JSR tetra_place
	JSR tetra_solid
	JSR tetra_lines
	JSR tetra_display
	JSR tetra_draw
	JMP tetra_start
tetra_controls3
	CMP #"a" ; left
	BEQ tetra_left
	CMP #"A"
	BEQ tetra_left
	CMP #$13 ; arrow left
	BEQ tetra_left
	CMP #"4"
	BEQ tetra_left
	JMP tetra_controls5
tetra_left
	DEC tetra_location
	JSR tetra_clear
	JSR tetra_place
	CMP #$FF ; error
	BEQ tetra_controls4
	JMP tetra_controls11
tetra_controls4
	INC tetra_location
	JSR tetra_clear
	JSR tetra_place
	JMP tetra_controls11
tetra_controls5
	CMP #"d" ; right
	BEQ tetra_right
	CMP #"D"
	BEQ tetra_right
	CMP #$14 ; arrow right
	BEQ tetra_right
	CMP #"6"
	BEQ tetra_right
	JMP tetra_controls7
tetra_right
	INC tetra_location
	JSR tetra_clear
	JSR tetra_place
	CMP #$FF ; error
	BEQ tetra_controls6
	JMP tetra_controls11
tetra_controls6
	DEC tetra_location
	JSR tetra_clear
	JSR tetra_place
	JMP tetra_controls11
tetra_controls7
	CMP #"q" ; rotate ccw
	BEQ tetra_rotate_ccw
	CMP #"Q"
	BEQ tetra_rotate_ccw
	CMP #$20 ; space
	BEQ tetra_rotate_ccw
	CMP #"7"
	BEQ tetra_rotate_ccw
	JMP tetra_controls9
tetra_rotate_ccw
	LDA tetra_piece
	TAY
	PHA
	AND #%00011100
	STA tetra_piece
	PLA
	INC A
	AND #%00000011
	ORA tetra_piece
	STA tetra_piece
	JSR tetra_clear
	JSR tetra_place
	CMP #$FF ; error
	BEQ tetra_controls8
	JMP tetra_controls11
tetra_controls8
	STY tetra_piece
	JSR tetra_clear
	JSR tetra_place
	JMP tetra_controls11
tetra_controls9
	CMP #"e" ; rotate cw
	BEQ tetra_rotate_cw
	CMP #"E"
	BEQ tetra_rotate_cw
	CMP #"0" ; rotate cw
	BEQ tetra_rotate_cw
	CMP #"9"
	BEQ tetra_rotate_cw
	JMP tetra_controls11
tetra_rotate_cw
	LDA tetra_piece
	TAY
	PHA
	AND #%00011100
	STA tetra_piece
	PLA
	DEC A
	AND #%00000011
	ORA tetra_piece
	STA tetra_piece
	JSR tetra_clear
	JSR tetra_place
	CMP #$FF ; error
	BEQ tetra_controls10
	JMP tetra_controls11
tetra_controls10
	STY tetra_piece
	JSR tetra_clear
	JSR tetra_place
tetra_controls11
	JSR tetra_draw
	JMP tetra_loop


tetra_clear
	PHA
	PHX
	LDX #$00
tetra_clear_loop
	LDA tetra_field,X
	CMP #$FF
	BNE tetra_clear_increment
	STZ tetra_field,X
tetra_clear_increment
	INX
	BNE tetra_clear_loop
	PLX
	PLA
	RTS


tetra_place
	STZ tetra_overscan
	PHX
	PHY
	LDA tetra_piece
	AND #%00011111
	CLC
	ROL A
	ROL A
	ROL A
	ROL A
	TAX
	BCS tetra_place_second
	LDA #<tetra_piece_data_first
	STA sub_index+1
	LDA #>tetra_piece_data_first
	STA sub_index+2
	JMP tetra_place_ready
tetra_place_second
	LDA #<tetra_piece_data_second
	STA sub_index+1
	LDA #>tetra_piece_data_second
	STA sub_index+2
tetra_place_ready
	LDY tetra_location
	STZ command_addr1_high
	STZ command_addr1_low
tetra_place_loop
	JSR sub_index
	CMP #$00 ; needed
	BEQ tetra_place_skip
	LDA tetra_overscan
	BNE tetra_place_error
	TYA
	AND #%00001111
	CLC
	CMP #$03
	BCC tetra_place_error
	CLC
	CMP #$0D
	BCS tetra_place_error	
	LDA tetra_field,Y
	BEQ tetra_place_write
tetra_place_error
	PLY
	PLX
	LDA #$FF ; error
	RTS
tetra_place_write
	JSR sub_index
	STA tetra_field,Y
tetra_place_skip
	INX
	INY
	INC command_addr1_low
	LDA command_addr1_low
	CMP #$04
	BNE tetra_place_loop
	TYA
	CLC
	ADC #$0C
	ROL tetra_overscan
	TAY
	STZ command_addr1_low
	INC command_addr1_high
	LDA command_addr1_high
	CMP #$04
	BNE tetra_place_loop
	PLY
	PLX
	LDA #$00 ; good
	RTS


tetra_solid
	PHA
	PHX
	LDX #$00
tetra_solid_loop
	LDA tetra_field,X
	CMP #$FF
	BNE tetra_solid_increment
	LDA #$55 ; blue
	STA tetra_field,X
tetra_solid_increment
	INX
	BNE tetra_solid_loop
	LDA #$00 ; clear
	JSR easter_egg
	PLX
	PLA
	RTS


tetra_lines
	STZ command_data
	PHA
	PHX
	PHY
	LDX #$00
	LDY #$00
tetra_lines_loop
	LDA tetra_field,X
	CMP #$55 ; blue
	BNE tetra_lines_check
	INY
tetra_lines_check
	TXA
	AND #%00001111
	CMP #$0F
	BNE tetra_lines_increment
	CPY #$0A ; 10 columns
	BEQ tetra_lines_remove
	LDY #$00
	JMP tetra_lines_increment
tetra_lines_remove
	INC command_data
	INC tetra_score_low
	LDA tetra_score_low
	AND #%00001111
	BNE tetra_lines_remove_score
	LDA tetra_speed
	SEC
	SBC #$10
	STA tetra_speed
	INC tetra_score_high
tetra_lines_remove_score
	TXA
	AND #%11110000
	TAX
tetra_lines_remove_loop
	STZ tetra_field,X
	INX
	TXA
	AND #%00001111
	CMP #$0F
	BNE tetra_lines_remove_loop
	PHX
	TXA
	SEC
	SBC #$10
	TAY
tetra_lines_remove_shift
	LDA tetra_field,Y
	STA tetra_field,X
	DEX
	DEY
	BNE tetra_lines_remove_shift
	LDX #$00
tetra_lines_remove_clear
	STZ tetra_field,X
	INX
	TXA
	AND #%00001111
	CMP #$0F
	BNE tetra_lines_remove_clear
	PLX
	LDY #$00
tetra_lines_increment
	INX
	BNE tetra_lines_loop
	LDA command_data
	BEQ tetra_lines_exit
	CMP #$04
	BNE tetra_lines_exit
	LDA #$FF ; draw
	JSR easter_egg	
tetra_lines_exit
	PLY
	PLX
	PLA
	RTS


tetra_draw	
	PHA
	PHX
	PHY
	LDA #$08 ; start of playfield
	STA sub_write+1
	LDA #$08
	STA sub_write+2
	LDX #$00
	LDY #$00
tetra_draw_loop
	TXA
	AND #%00001111
	CLC	
	CMP #$03
	BCC tetra_draw_jump
	CLC	
	CMP #$0D
	BCS tetra_draw_jump
	JMP tetra_draw_continue
tetra_draw_jump
	JMP tetra_draw_increment
tetra_draw_continue
	LDA tetra_field,X
	CPY #$00
	BNE tetra_draw_corner1
	AND #%01010101
	JMP tetra_draw_corner2
tetra_draw_corner1
	AND #%01111111
tetra_draw_corner2
	JSR sub_write
	INC sub_write+1
	LDA tetra_field,X
	CPY #$00
	BNE tetra_draw_normal
	AND #%01010101
tetra_draw_normal
	JSR sub_write
	INC sub_write+1
	JSR sub_write
	INC sub_write+1
	JSR sub_write
	INC sub_write+1
	LDA sub_write+1
	CLC
	ADC #$7C
	STA sub_write+1
	LDA tetra_field,X
	AND #%01111111
	JSR sub_write
	INC sub_write+1
	LDA tetra_field,X
	JSR sub_write
	INC sub_write+1
	JSR sub_write
	INC sub_write+1
	JSR sub_write
	INC sub_write+1
	LDA sub_write+1
	CLC
	ADC #$7C
	STA sub_write+1
	INC sub_write+2
	INY
	CPY #$07
	BNE tetra_draw_loop
	LDY #$00
	LDA sub_write+2
	SEC
	SBC #$07
	STA sub_write+2
	LDA sub_write+1
	CLC
	ADC #$04
	STA sub_write+1
tetra_draw_increment
	INX
	BEQ tetra_draw_exit
	TXA
	AND #%00001111
	BEQ tetra_draw_shift
	JMP tetra_draw_loop
tetra_draw_shift
	LDA #$08 ; start of playfield
	STA sub_write+1
	LDA sub_write+2
	CLC
	ADC #$07 ; change this
	STA sub_write+2
	JMP tetra_draw_loop
tetra_draw_exit
	PLY
	PLX
	PLA
	RTS


tetra_display
	PHA
	PHX

	LDA #$3A
	STA printchar_x
	LDA #$10
	STA printchar_y
	LDA #"T"
	JSR printchar
	LDA #"e"
	JSR printchar
	LDA #"t"
	JSR printchar
	LDA #"r"
	JSR printchar
	LDA #"a"
	JSR printchar

	LDA #$3A
	STA printchar_x
	LDA #$18
	STA printchar_y
	LDA #"L"
	JSR printchar
	LDA #"e"
	JSR printchar
	LDA #"v"
	JSR printchar
	LDA #"e"
	JSR printchar
	LDA #"l"
	JSR printchar
	LDA #" "
	JSR printchar
	LDX tetra_score_high
	LDA decimal_conversion_high,X
	JSR printchar
	LDA decimal_conversion_middle,X
	JSR printchar
	LDA decimal_conversion_low,X
	JSR printchar
	LDA #" "
	JSR printchar
	JSR printchar

	LDA #$3A
	STA printchar_x
	LDA #$20
	STA printchar_y
	LDA #"L"
	JSR printchar
	LDA #"i"
	JSR printchar
	LDA #"n"
	JSR printchar
	LDA #"e"
	JSR printchar
	LDA #"s"
	JSR printchar
	LDA #" "
	JSR printchar
	LDX tetra_score_low
	LDA decimal_conversion_high,X
	JSR printchar
	LDA decimal_conversion_middle,X
	JSR printchar
	LDA decimal_conversion_low,X
	JSR printchar
	LDA #" "
	JSR printchar
	JSR printchar

	LDA #$3A
	STA printchar_x
	LDA #$28
	STA printchar_y
	LDA #"N"
	JSR printchar
	LDA #"e"
	JSR printchar
	LDA #"x"
	JSR printchar
	LDA #"t"
	JSR printchar
	LDA #" "
	JSR printchar
	LDA tetra_piece_next
	AND #%00011100
	ROR A
	ROR A
	CMP #$01 ; I
	BNE tetra_display_next1
	LDA #"I"
	JMP tetra_display_exit
tetra_display_next1
	CMP #$02 ; J
	BNE tetra_display_next2
	LDA #"J"
	JMP tetra_display_exit
tetra_display_next2
	CMP #$03 ; L
	BNE tetra_display_next3
	LDA #"L"
	JMP tetra_display_exit
tetra_display_next3
	CMP #$04 ; O
	BNE tetra_display_next4
	LDA #"O"
	JMP tetra_display_exit
tetra_display_next4
	CMP #$05 ; S
	BNE tetra_display_next5
	LDA #"S"
	JMP tetra_display_exit
tetra_display_next5
	CMP #$06 ; T
	BNE tetra_display_next6
	LDA #"T"
	JMP tetra_display_exit
tetra_display_next6
	CMP #$07 ; Z
	BNE tetra_display_next7
	LDA #"Z"
	JMP tetra_display_exit
tetra_display_next7
	NOP
tetra_display_exit
	JSR printchar

	LDA #$3A
	STA printchar_x
	LDA #$68
	STA printchar_y
	LDA #"F"
	JSR printchar
	LDA #"1"
	JSR printchar
	LDA #"2"
	JSR printchar
	LDA #$3A
	STA printchar_x
	LDA #$6C
	STA printchar_y
	LDA #"t"
	JSR printchar
	LDA #"o"
	JSR printchar
	LDA #" "
	JSR printchar
	LDA #"R"
	JSR printchar
	LDA #"e"
	JSR printchar
	LDA #"s"
	JSR printchar
	LDA #"e"
	JSR printchar
	LDA #"t"
	JSR printchar
		
	LDA #$3A
	STA printchar_x
	LDA #$70
	STA printchar_y
	LDA #"E"
	JSR printchar
	LDA #"S"
	JSR printchar
	LDA #"C"
	JSR printchar
	LDA #$3A
	STA printchar_x
	LDA #$74
	STA printchar_y
	LDA #"t"
	JSR printchar
	LDA #"o"
	JSR printchar
	LDA #" "
	JSR printchar
	LDA #"E"
	JSR printchar
	LDA #"x"
	JSR printchar
	LDA #"i"
	JSR printchar
	LDA #"t"
	JSR printchar

	PLX
	PLA
	RTS


tetra_piece_data_first
	.BYTE $00,$00,$00,$00
	.BYTE $00,$00,$00,$00
	.BYTE $00,$00,$00,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $00,$00,$00,$00
	.BYTE $00,$00,$00,$00
	.BYTE $00,$00,$00,$00
	
	.BYTE $00,$00,$00,$00
	.BYTE $00,$00,$00,$00
	.BYTE $00,$00,$00,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $00,$00,$00,$00
	.BYTE $00,$00,$00,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $FF,$FF,$FF,$FF
	.BYTE $00,$00,$00,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$FF,$00,$00
	.BYTE $00,$FF,$00,$00
	.BYTE $00,$FF,$00,$00
	.BYTE $00,$FF,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $FF,$FF,$FF,$FF
	.BYTE $00,$00,$00,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$FF,$00,$00
	.BYTE $00,$FF,$00,$00
	.BYTE $00,$FF,$00,$00
	.BYTE $00,$FF,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $00,$FF,$00,$00
	.BYTE $00,$FF,$FF,$FF
	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$FF,$00
	.BYTE $00,$00,$FF,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $FF,$FF,$FF,$00
	.BYTE $00,$00,$FF,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$FF,$00,$00
	.BYTE $00,$FF,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $00,$FF,$FF,$FF
	.BYTE $00,$FF,$00,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$FF,$00,$00
	.BYTE $00,$FF,$00,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $00,$00,$FF,$00
	.BYTE $FF,$FF,$FF,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$00,$FF,$00
	.BYTE $00,$00,$FF,$00

tetra_piece_data_second
	.BYTE $00,$00,$00,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $FF,$FF,$00,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$FF,$00,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$00,$FF,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $FF,$FF,$00,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$FF,$00,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$00,$FF,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$FF,$00,$00
	.BYTE $FF,$FF,$FF,$00
	.BYTE $00,$00,$00,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$FF,$00,$00
	.BYTE $FF,$FF,$00,$00
	.BYTE $00,$FF,$00,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $FF,$FF,$FF,$00
	.BYTE $00,$FF,$00,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$FF,$00,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$FF,$00,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $FF,$FF,$00,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$FF,$00,$00
	.BYTE $FF,$FF,$00,$00
	.BYTE $FF,$00,$00,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$00,$00,$00
	.BYTE $FF,$FF,$00,$00
	.BYTE $00,$FF,$FF,$00
	.BYTE $00,$00,$00,$00

	.BYTE $00,$FF,$00,$00
	.BYTE $FF,$FF,$00,$00
	.BYTE $FF,$00,$00,$00
	.BYTE $00,$00,$00,$00



; this could be replaced with something else
; just remember to RTS at the end!

easter_egg
	PHA
	STA command_data
	LDA #<easter_egg_start
	STA sub_read+1
	LDA #>easter_egg_start
	STA sub_read+2
	LDA #$3A
	STA sub_write+1
	LDA #>screen
	CLC
	ADC #$2A
	STA sub_write+2
easter_egg_loop
	JSR sub_read
	AND command_data
	JSR sub_write
	INC sub_read+1
	BNE easter_egg_next
	INC sub_read+2
easter_egg_next
	LDA sub_read+2
	CMP #>easter_egg_end
	BNE easter_egg_increment
	LDA sub_read+1
	CMP #<easter_egg_end
	BNE easter_egg_increment
	JMP easter_egg_exit
easter_egg_increment
	INC sub_write+1
	LDA sub_write+1
	CMP #$4A
	BNE easter_egg_check
	LDA #$BA
	STA sub_write+1
	JMP easter_egg_loop
easter_egg_check
	CMP #$CA
	BNE easter_egg_loop
	INC sub_write+2
	LDA #$3A
	STA sub_write+1
	JMP easter_egg_loop
easter_egg_exit
	LDA #$3C
	STA printchar_x
	LDA #$5C
	STA printchar_y
	LDA command_data
	BEQ easter_egg_clear
	LDA #"T"
	JSR printchar
	LDA #"e"
	JSR printchar
	LDA #"t"
	JSR printchar
	LDA #"r"
	JSR printchar
	LDA #"a"
	JSR printchar
	LDA #"!"
	JSR printchar
	LDA #"!"
	JSR printchar
	PLA
	RTS
easter_egg_clear
	LDA #" "
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	PLA
	RTS	

easter_egg_start
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $A8,$AA,$A8,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$AA
	.BYTE $AA,$AA,$AA,$80,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$2A,$AA
	.BYTE $AA,$AA,$AA,$A8,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$0A,$AA,$AA
	.BYTE $AA,$AA,$AA,$8A,$80,$00,$00,$00
	.BYTE $00,$00,$00,$00,$02,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$A2,$AA,$80,$00,$00
	.BYTE $00,$00,$00,$00,$0A,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$A8,$AA,$A8,$00,$00
	.BYTE $00,$00,$00,$00,$AA,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$8A,$80,$00,$00
	.BYTE $00,$00,$00,$02,$AA,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$A8,$00,$00,$00
	.BYTE $00,$00,$00,$0A,$AA,$AA,$AA,$2A
	.BYTE $AA,$AA,$AA,$AA,$AA,$00,$00,$00
	.BYTE $00,$00,$00,$2A,$AA,$AA,$AA,$2A
	.BYTE $AA,$AA,$AA,$AA,$AA,$80,$00,$00
	.BYTE $00,$00,$00,$2A,$AA,$AA,$A8,$AA
	.BYTE $AA,$AA,$AA,$AA,$AA,$A0,$00,$00
	.BYTE $00,$00,$00,$AA,$AA,$AA,$A8,$AA
	.BYTE $AA,$AA,$AA,$AA,$AA,$A0,$00,$00
	.BYTE $00,$00,$00,$AA,$AA,$AA,$A8,$AA
	.BYTE $AA,$AA,$AA,$AA,$AA,$A8,$00,$00
	.BYTE $00,$00,$02,$AA,$AA,$2A,$AF,$AA
	.BYTE $AA,$AA,$AA,$AA,$AA,$AA,$00,$00
	.BYTE $00,$00,$02,$AA,$A8,$AA,$BF,$EA
	.BYTE $AA,$A2,$AA,$AA,$AA,$AA,$00,$00
	.BYTE $00,$00,$02,$AA,$A8,$AA,$FF,$FE
	.BYTE $AA,$A8,$AA,$AA,$AA,$AA,$00,$00
	.BYTE $00,$00,$02,$AA,$A2,$AB,$FF,$FF
	.BYTE $EA,$A8,$AA,$AA,$AA,$AA,$80,$00
	.BYTE $00,$00,$02,$AA,$A2,$AF,$FF,$FF
	.BYTE $FF,$EA,$2A,$AA,$AA,$AA,$80,$00
	.BYTE $00,$00,$0A,$AA,$A2,$BF,$FF,$FF
	.BYTE $FF,$FA,$2A,$AA,$AA,$AA,$80,$00
	.BYTE $00,$00,$0A,$AA,$A2,$BF,$FF,$FF
	.BYTE $FF,$FE,$BA,$AA,$AA,$AA,$A0,$00
	.BYTE $00,$00,$2A,$A2,$AE,$BF,$FF,$FF
	.BYTE $FF,$FF,$BF,$F8,$AA,$AA,$A0,$00
	.BYTE $00,$00,$8A,$A2,$AF,$BF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FA,$2A,$AA,$A0,$00
	.BYTE $00,$00,$2A,$A8,$AF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FE,$2A,$AA,$A0,$00
	.BYTE $00,$00,$AA,$A8,$AA,$AA,$BF,$FF
	.BYTE $FF,$FF,$EA,$AA,$28,$AA,$A0,$00
	.BYTE $00,$02,$AA,$A8,$EB,$FF,$AB,$FF
	.BYTE $FF,$FE,$AF,$FE,$2A,$2A,$A8,$00
	.BYTE $00,$0A,$A8,$AA,$FB,$FF,$FA,$FF
	.BYTE $FF,$EA,$FF,$FE,$EA,$2A,$A8,$00
	.BYTE $00,$0A,$AA,$2A,$FF,$FF,$FE,$BF
	.BYTE $FF,$AF,$FF,$FF,$FA,$FE,$AA,$00
	.BYTE $00,$2A,$AF,$EA,$BF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FE,$FE,$AA,$80
	.BYTE $00,$2A,$AF,$0A,$FF,$00,$0F,$FF
	.BYTE $FF,$FF,$00,$0F,$FE,$0F,$AA,$80
	.BYTE $00,$AA,$AF,$3A,$FC,$00,$00,$FF
	.BYTE $FF,$F0,$00,$03,$FE,$CF,$AA,$80
	.BYTE $00,$AA,$AF,$3E,$F0,$50,$14,$FF
	.BYTE $FF,$F1,$40,$50,$FF,$CF,$AA,$A0
	.BYTE $00,$AA,$AF,$3F,$FF,$43,$D7,$FF
	.BYTE $FF,$FD,$0F,$5F,$FF,$CF,$AA,$A0
	.BYTE $02,$AA,$AF,$3F,$FF,$53,$57,$FF
	.BYTE $FF,$FD,$4D,$5F,$FF,$0E,$AA,$A0
	.BYTE $02,$AA,$AB,$0F,$FF,$55,$5F,$FF
	.BYTE $FF,$FD,$55,$5F,$FC,$3E,$AA,$A0
	.BYTE $02,$AA,$AB,$C3,$FC,$D5,$5C,$FF
	.BYTE $FF,$F3,$55,$73,$F0,$FA,$AA,$A0
	.BYTE $02,$AA,$AA,$FC,$FF,$00,$03,$FF
	.BYTE $FF,$FC,$00,$0F,$F3,$FA,$AA,$A0
	.BYTE $02,$AA,$AA,$BC,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$F3,$EA,$AA,$A0
	.BYTE $00,$AA,$AA,$BC,$3F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$C3,$AA,$AA,$A0
	.BYTE $00,$2A,$AA,$AF,$3F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$CF,$AA,$AA,$80
	.BYTE $00,$2A,$AA,$AF,$3F,$FF,$FF,$FC
	.BYTE $C3,$FF,$FF,$FF,$CF,$AA,$AA,$80
	.BYTE $00,$0A,$AA,$AA,$BF,$FF,$FF,$FF
	.BYTE $3F,$FF,$FF,$FF,$EA,$AA,$AA,$00
	.BYTE $00,$0A,$AA,$AA,$BF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$AA,$AA,$AA,$00
	.BYTE $00,$02,$AA,$AA,$BF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$AA,$AA,$A8,$00
	.BYTE $00,$02,$AA,$AA,$AF,$FF,$FF,$FE
	.BYTE $AA,$FF,$FF,$FF,$AA,$AA,$A8,$00
	.BYTE $00,$00,$AA,$AA,$AB,$FF,$FF,$AA
	.BYTE $AA,$AB,$FF,$FE,$AA,$AA,$A0,$00
	.BYTE $00,$00,$2A,$AA,$AB,$FF,$FF,$EA
	.BYTE $AA,$AF,$FF,$FA,$AA,$AA,$80,$00
	.BYTE $00,$00,$2A,$AA,$AA,$FF,$FF,$FA
	.BYTE $AA,$FF,$FF,$FA,$AA,$AA,$00,$00
	.BYTE $00,$00,$0A,$AA,$AA,$BF,$FF,$FF
	.BYTE $FF,$FF,$FF,$EA,$AA,$AA,$00,$00
	.BYTE $00,$00,$02,$AA,$AA,$AF,$FF,$FF
	.BYTE $FF,$FF,$FF,$AA,$AA,$80,$00,$00
	.BYTE $00,$00,$00,$AA,$AA,$AB,$FF,$FF
	.BYTE $FF,$FF,$FE,$AA,$AA,$00,$00,$00
	.BYTE $00,$00,$00,$2A,$AA,$AA,$FF,$FF
	.BYTE $FF,$FF,$FE,$AA,$80,$00,$00,$00
	.BYTE $00,$00,$00,$0A,$AA,$AA,$8F,$FF
	.BYTE $FF,$FF,$FA,$A8,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$A2,$AB,$F0,$FF
	.BYTE $FF,$FF,$0A,$20,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$2F,$FF,$3F
	.BYTE $FF,$C0,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$0F,$FF,$C3
	.BYTE $FC,$3F,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$0F,$FF,$FC
	.BYTE $03,$FF,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$0F,$FF,$FF
	.BYTE $FF,$FF,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$0F,$FF,$FF
	.BYTE $FF,$FF,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$0F,$FF,$FF
	.BYTE $FF,$FF,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$0F,$FF,$FF
	.BYTE $FF,$FF,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$0F,$FF,$FF
	.BYTE $FF,$FF,$FF,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$3F,$FF,$FF
	.BYTE $FF,$FF,$FF,$C0,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$03,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$CF,$C0,$00,$00,$00
	.BYTE $00,$00,$00,$03,$F3,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$3D,$54,$00,$00,$00
	.BYTE $00,$00,$01,$55,$FC,$FF,$FF,$FF
	.BYTE $FF,$FF,$F0,$F5,$55,$40,$00,$00
	.BYTE $00,$00,$15,$55,$7F,$0F,$FF,$FF
	.BYTE $FF,$FF,$CF,$D5,$55,$54,$00,$00
	.BYTE $00,$01,$55,$55,$5F,$F3,$FF,$FF
	.BYTE $FF,$FF,$3F,$55,$55,$55,$40,$00
	.BYTE $00,$15,$55,$55,$55,$FC,$FF,$FF
	.BYTE $FF,$FC,$F5,$55,$55,$55,$54,$00
	.BYTE $01,$55,$55,$55,$55,$7F,$3F,$FF
	.BYTE $FF,$F3,$D5,$55,$55,$55,$55,$00
	.BYTE $05,$55,$55,$55,$55,$5F,$CF,$FF
	.BYTE $FF,$CF,$55,$55,$55,$55,$55,$40
	.BYTE $15,$55,$55,$55,$55,$55,$F3,$FF
	.BYTE $FF,$3D,$55,$55,$55,$55,$55,$50
	.BYTE $15,$55,$55,$55,$55,$55,$7C,$FF
	.BYTE $FC,$F5,$55,$55,$55,$55,$55,$54
	.BYTE $05,$55,$55,$55,$55,$55,$5F,$3F
	.BYTE $F3,$D5,$55,$55,$55,$55,$55,$50
	.BYTE $01,$55,$55,$55,$55,$55,$57,$CF
	.BYTE $CF,$55,$55,$55,$55,$55,$55,$00
	.BYTE $00,$15,$55,$55,$55,$55,$55,$F3
	.BYTE $3D,$55,$55,$55,$55,$55,$54,$00
	.BYTE $00,$05,$55,$55,$55,$55,$55,$7C
	.BYTE $F5,$55,$55,$55,$55,$55,$00,$00
	.BYTE $00,$00,$55,$55,$55,$55,$55,$5F
	.BYTE $D5,$55,$55,$55,$55,$40,$00,$00
	.BYTE $00,$00,$05,$55,$55,$55,$55,$57
	.BYTE $55,$55,$55,$55,$55,$00,$00,$00
	.BYTE $00,$00,$00,$15,$55,$55,$55,$55
	.BYTE $55,$55,$55,$55,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$15,$55,$55
	.BYTE $55,$55,$55,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$05,$55
	.BYTE $55,$40,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
easter_egg_end


; printchar sub-routine
; this prints a character on the screen at the location
; determined by printchar_x and printchar_y
; special control characters also perform operations
printchar
	PHA
	PHX
	PHA
	LDA printchar_x
	STA sub_write+1
	LDA printchar_y
	STA sub_write+2
	LDA #<ascii_charrom
	STA sub_read+1
	LDA #>ascii_charrom
	STA sub_read+2
	PLA
	CMP #$00
	BNE printchar_continue1
	JMP printchar_exit
printchar_continue1
	CLC
	CMP #$20 ; control characters below
	BCS printchar_check
	JMP printchar_exit
printchar_check
	AND #%01111111 ; only 128 characters
	PHA
	LDA command_mode
	BEQ printchar_retain
	PLA
	PHA
	CLC
	CMP #$60
	BCC printchar_retain
	CLC
	CMP #$7B
	BCS printchar_retain
	PLA
	SEC
	SBC #$20
	PHA
	SEC
	SBC #$20 ; remove control characters to shorten charrom
	BEQ printchar_found
	JMP printchar_search
printchar_retain
	PLA
	PHA
	SEC
	SBC #$20 ; remove control characters to shorten charrom
	BEQ printchar_found
printchar_search
	PHA
	LDA sub_read+1
	CLC
	ADC #$10
	STA sub_read+1
	BNE printchar_skip
	INC sub_read+2
printchar_skip
	PLA
printchar_next
	DEC A
	BNE printchar_search
printchar_found
	LDX #$07
printchar_loop
	JSR sub_read
	EOR printchar_invert
	JSR sub_write
	INC sub_read+1
	INC sub_write+1
	JSR sub_read
	EOR printchar_invert
	JSR sub_write
	DEX
	BEQ printchar_increment
	INC sub_read+1
	LDA sub_write+1
	DEC A
	CLC
	ADC #$80
	STA sub_write+1
	BCC printchar_loop
	INC sub_write+2
	JMP printchar_loop
printchar_increment
	LDA printchar_x
	CLC
	ROR A
	TAX
	PLA
	STA command_array,X
	CMP #$7F ; delete
	BEQ printchar_exit
	CMP #$FF ; delete (extended)
	BEQ printchar_exit
	INC printchar_x
	INC printchar_x
	LDA printchar_x
	CLC	
	CMP #$4E ; 80 columns (in mono)
	BCC printchar_exit
	LDA #$4C
	STA printchar_x
printchar_exit
	PLX
	PLA
	RTS


; inputchar sub-routine
; reads from the key_array if a new character has inputed
; from the keyboard, if no new character it returns $00
; the character code is converted to ASCII
; extended and release keycodes change behavior accordingly
inputchar
	PHX
	LDX key_read
	CPX key_write
	BNE inputchar_next
	LDA #$00
	STA inputchar_value
	JMP inputchar_exit
inputchar_next
	LDA key_error,X
	AND #%00100000 ; check start bit = 0
	BNE inputchar_error
	LDA key_error,X
	AND #%10000000 ; check stop bit = 1
	BEQ inputchar_error
	LDA key_error,X
	STZ key_error,X
	AND #%01000000 ; check odd parity bit
	BEQ inputchar_zero
	INC key_error,X
inputchar_zero	
	LDA key_array,X
	PHY
	LDY #$09
inputchar_loop
	DEY
	BEQ inputchar_parity
	ROL A
	BCC inputchar_loop
	INC key_error,X
	JMP inputchar_loop
inputchar_parity
	PLY
	LDA key_error,X
	AND #%00000001
	BNE inputchar_correct
inputchar_error
	STZ key_write
	STZ key_read
	STZ key_data
	LDA #$09
	STA key_counter
	STZ key_code
	LDA #$01
	STA key_status
	JMP inputchar_exit
inputchar_correct
	LDA key_array,X
	INC key_read
	BPL inputchar_positive
	STZ key_read
inputchar_positive
	CMP #$F0 ; release
	BNE inputchar_continue1
	LDA #$FF
	STA key_release
	LDA #$00
	STA inputchar_value
	JMP inputchar_exit
inputchar_continue1
	CMP #$E0 ; extended
	BNE inputchar_continue2
	LDA #$FF
	STA key_extended
	LDA #$00
	STA inputchar_value
	JMP inputchar_exit
inputchar_continue2
	CMP #ps2_shift_left
	BEQ inputchar_shift
	CMP #ps2_shift_right
	BEQ inputchar_shift
	JMP inputchar_continue3
inputchar_shift
	LDA key_release
	EOR #$FF
	STA key_shift
	LDA #$00
	STA inputchar_value
	STZ key_release
	STZ key_extended
	JMP inputchar_exit
inputchar_continue3
	CMP #ps2_control
	BNE inputchar_continue4
	LDA key_release
	EOR #$FF
	STA key_alt_control
	LDA #$00
	STA inputchar_value
	STZ key_release
	STZ key_extended
	JMP inputchar_exit
inputchar_continue4
	CMP #ps2_alt
	BNE inputchar_continue5
	LDA key_release
	EOR #$FF
	STA key_alt_control
	LDA #$00
	STA inputchar_value
	STZ key_release
	STZ key_extended
	JMP inputchar_exit
inputchar_continue5
	CMP #ps2_capslock
	BNE inputchar_continue6
	LDA key_release
	BNE inputchar_capslock_exit
	LDA key_capslock
	EOR #$FF
	STA key_capslock
inputchar_capslock_exit
	LDA #$00
	STA inputchar_value
	STZ key_release
	STZ key_extended
	JMP inputchar_exit
inputchar_continue6
	CMP #ps2_numlock ; ignored
	BNE inputchar_continue7
	LDA #$00
	STA inputchar_value
	STZ key_release
	STZ key_extended
	JMP inputchar_exit
inputchar_continue7
	CMP #ps2_scrolllock ; ignored
	BNE inputchar_continue8
	LDA #$00
	STA inputchar_value
	STZ key_release
	STZ key_extended
	JMP inputchar_exit
inputchar_continue8
	CMP #ps2_f7
	BNE inputchar_continue9
	LDA #$02 ; replacement for F7 value
inputchar_continue9
	NOP
inputchar_regular
	TAX
	LDA key_release
	BNE inputchar_ignore
	LDA key_extended
	BNE inputchar_extended
	LDA key_shift
	EOR key_capslock
	BNE inputchar_shifted
	LDA ascii_lookup,X
	STA inputchar_value
	STZ key_release
	STZ key_extended
	JMP inputchar_exit
inputchar_ignore
	LDA #$00
	STA inputchar_value
	STZ key_release
	STZ key_extended
	JMP inputchar_exit
inputchar_extended
	TXA
	CMP #$4A ; extended slash
	BEQ inputchar_extended_skip
	ORA #%10000000
inputchar_extended_skip
	TAX
	LDA ascii_lookup,X
	STA inputchar_value
	STZ key_release
	STZ key_extended
	JMP inputchar_exit
inputchar_shifted
	TXA
	ORA #%10000000
	TAX
	LDA ascii_lookup,X
	STA inputchar_value
	STZ key_release
	STZ key_extended
	JMP inputchar_exit
inputchar_exit
	PLX
	RTS



	.ORG $D000

intruder_player_pos		.EQU $0400 ; reusing memory location
intruder_player_lives		.EQU $0401
intruder_missile_pos_x		.EQU $0402
intruder_missile_pos_y		.EQU $0403
intruder_enemy_fall		.EQU $0404
intruder_enemy_pos_x		.EQU $0405
intruder_enemy_pos_y		.EQU $0406
intruder_enemy_dir_x		.EQU $0407
intruder_enemy_speed		.EQU $0408
intruder_enemy_missile_s	.EQU $0409
intruder_enemy_missile_x	.EQU $040A
intruder_enemy_missile_y	.EQU $040B
intruder_delay_timer		.EQU $040C
intruder_button_left		.EQU $040D
intruder_button_right		.EQU $040E
intruder_button_fire		.EQU $040F
intruder_mystery_pos		.EQU $0410
intruder_mystery_speed		.EQU $0411
intruder_points_low		.EQU $0412
intruder_points_high		.EQU $0413
intruder_level			.EQU $0414
intruder_overall_delay		.EQU $0415
intruder_mystery_bank		.EQU $0416
; unused
intruder_enemy_visible		.EQU $0420

intruder_max_enemies		.EQU $2F ; $2F, a constant

intruder
	JMP intruder_init

intruder_level_enemy_fall
	.BYTE $10,$10,$30,$30,$50,$50,$70,$70
intruder_level_enemy_speed
	.BYTE $20,$40,$40,$60,$60,$80,$80,$A0
intruder_level_enemy_missile_speed
	.BYTE $02,$02,$03,$03,$04,$04,$04,$04
intruder_level_overall_delay
	.BYTE $80,$70,$60,$50,$40,$20,$10,$08

intruder_init
	LDA #$03
	STA intruder_player_lives
	STZ intruder_level
	STZ intruder_points_low
	STZ intruder_points_high
	
intruder_init_level
	LDA intruder_level
	AND #%00000111
	TAX
	LDA #$24
	STA intruder_player_pos
	STZ intruder_button_left
	STZ intruder_button_right
	STZ intruder_button_fire
	STZ intruder_missile_pos_y
	STZ intruder_delay_timer
	LDA intruder_level_enemy_fall,X
	STA intruder_enemy_fall
	LDA #$08
	STA intruder_enemy_pos_x
	LDA #$18
	STA intruder_enemy_pos_y
	LDA intruder_level_enemy_speed,X
	STA intruder_enemy_speed
	LDA intruder_level_enemy_missile_speed,X
	STA intruder_enemy_missile_s
	LDA #$28
	STA intruder_enemy_missile_x
	STZ intruder_enemy_missile_y
	LDA #$00
	STA intruder_mystery_pos
	LDA #$01
	STA intruder_mystery_speed
	LDA intruder_level_overall_delay,X
	STA intruder_overall_delay
	LDA #$FA ; 250 in decimal
	STA intruder_mystery_bank ; total points you can get from the mystery ship each round

intruder_init_start
	STZ sub_write+1				; clear out screen RAM
	LDA #$08
	STA sub_write+2
intruder_init_wipeout
	LDA #$00 ; fill color
	JSR sub_write
	INC sub_write+1
	BNE intruder_init_wipeout
	INC sub_write+2
	LDA sub_write+2
	CMP #$80
	BNE intruder_init_wipeout

	JSR intruder_draw_menu

	LDX #intruder_max_enemies
	LDA #$FF
intruder_init_visible_loop
	STA intruder_enemy_visible,X
	DEX
	CPX #$FF
	BNE intruder_init_visible_loop

	LDA #$0C
	JSR intruder_init_shield
	LDA #$18
	JSR intruder_init_shield
	LDA #$24
	JSR intruder_init_shield
	LDA #$30
	JSR intruder_init_shield
	LDA #$3C
	JSR intruder_init_shield

	LDY #$00
	JMP intruder_draw_mystery	

intruder_input
	LDX key_read
	CPX key_write
	BNE intruder_input_next
	JMP intruder_input_check
intruder_input_next
	LDA key_error,X
	AND #%00100000 ; check start bit = 0
	BNE intruder_input_error
	LDA key_error,X
	AND #%10000000 ; check stop bit = 1
	BEQ intruder_input_error
	LDA key_error,X
	STZ key_error,X
	AND #%01000000 ; check odd parity bit
	BEQ intruder_input_zero
	INC key_error,X
intruder_input_zero	
	LDA key_array,X
	PHY
	LDY #$09
intruder_input_loop
	DEY
	BEQ intruder_input_parity
	ROL A
	BCC intruder_input_loop
	INC key_error,X
	JMP intruder_input_loop
intruder_input_parity
	PLY
	LDA key_error,X
	AND #%00000001
	BNE intruder_input_correct
intruder_input_error
	STZ key_write
	STZ key_read
	STZ key_data
	LDA #$09
	STA key_counter
	STZ key_code
	LDA #$01
	STA key_status
	JMP intruder_input
intruder_input_correct
	JSR basic_sub_random ; just to add randomness
	LDA key_array,X ; needs error checking!!!
	INC key_read
	BPL intruder_input_positive
	STZ key_read
intruder_input_positive
	CMP #$F0
	BEQ intruder_input_release
	STA inputchar_value
	LDA key_release
	STZ key_release
	BEQ intruder_input_down
	LDA inputchar_value
	CMP #ps2_escape
	BEQ intruder_input_escape
	CMP #ps2_f12
	BEQ intruder_input_f12
	CMP #ps2_arrow_left
	BEQ intruder_input_left_up
	CMP #$1C ; A
	BEQ intruder_input_left_up
	CMP #ps2_arrow_right
	BEQ intruder_input_right_up
	CMP #$23 ; D
	BEq intruder_input_right_up
	CMP #ps2_space
	BEQ intruder_input_fire_up
	CMP #ps2_arrow_up
	BEQ intruder_input_fire_up
	CMP #$1D ; W
	BEQ intruder_input_fire_up
	JMP intruder_input_check
intruder_input_escape
	LDY #$C0 ; reset
	LDX #$00
	JMP switch_banks
intruder_input_f12
	JMP intruder
intruder_input_release
	STA key_release
	JMP intruder_input_check
intruder_input_down
	LDA inputchar_value
	CMP #ps2_arrow_left
	BEQ intruder_input_left_down
	CMP #$1C ; A
	BEQ intruder_input_left_down
	CMP #ps2_arrow_right
	BEQ intruder_input_right_down
	CMP #$23 ; D
	BEQ intruder_input_right_down
	CMP #ps2_space
	BEQ intruder_input_fire_down
	CMP #ps2_arrow_up
	BEQ intruder_input_fire_down
	CMP #$1D ; W
	BEq intruder_input_fire_down
	JMP intruder_input_check
intruder_input_left_up
	STZ intruder_button_left
	JMP intruder_input_check
intruder_input_right_up
	STZ intruder_button_right
	JMP intruder_input_check
intruder_input_fire_up
	STZ intruder_button_fire
	JMP intruder_input_check
intruder_input_left_down
	STA intruder_button_left
	JMP intruder_input_check
intruder_input_right_down	
	STA intruder_button_right
	JMP intruder_input_check
intruder_input_fire_down	
	STA intruder_button_fire
	JMP intruder_input_check
intruder_input_check	
	INY
	CPY intruder_overall_delay
	BEQ intruder_input_check_next
	JMP intruder_input
intruder_input_check_next
	LDY #$00
	DEC intruder_delay_timer
	LDA intruder_delay_timer
	AND #%00001111
	BEQ intruder_reaction
	JMP intruder_input
intruder_reaction
	LDA intruder_button_left
	BEQ intruder_reaction_next1
	LDA intruder_player_pos
	SEC
	SBC #$02
	CLC
	CMP #$08
	BCC intruder_reaction_next1
	STA intruder_player_pos
intruder_reaction_next1
	LDA intruder_button_right
	BEQ intruder_reaction_next2
	LDA intruder_player_pos
	CLC
	ADC #$02
	CLC
	CMP #$42
	BCS intruder_reaction_next2
	STA intruder_player_pos
intruder_reaction_next2
	LDA intruder_button_fire
	BEQ intruder_reaction_next3
	STZ intruder_button_fire
	LDA intruder_missile_pos_y
	BNE intruder_reaction_next3
	LDA intruder_player_pos
	CLC
	ADC #$03
	STA intruder_missile_pos_x
	LDA #$72
	STA intruder_missile_pos_y
intruder_reaction_next3
	NOP


intruder_draw_mystery
	LDA intruder_mystery_pos
	CMP #$FF
	BEQ intruder_draw_player
	CLC	
	ADC intruder_mystery_speed
	BMI intruder_draw_mystery_offscreen
	CLC	
	CMP #$50
	BCS intruder_draw_mystery_offscreen
	JMP intruder_draw_mystery_onscreen
intruder_draw_mystery_offscreen
	LDA #$FF
	STA intruder_mystery_pos
	JSR intruder_mystery_clear
	JMP intruder_draw_player
intruder_draw_mystery_onscreen
	STA intruder_mystery_pos
	STA sub_write+1
	LDA #$10
	STA sub_write+2
	LDA #<intruder_mystery_data
	STA sub_index+1
	LDA #>intruder_mystery_data
	STA sub_index+2
	LDX #$00
	LDY #$00
intruder_draw_mystery_loop
	JSR sub_index
	JSR sub_write
	INC sub_write+1
	INX
	INY
	CPY #$08
	BNE intruder_draw_mystery_loop
	LDY #$00
	LDA sub_write+1
	CLC
	ADC #$78
	STA sub_write+1
	BCC intruder_draw_mystery_loop
	INC sub_write+2
	LDA sub_write+2
	CMP #$14
	BCC intruder_draw_mystery_loop


intruder_draw_player
	LDA intruder_player_pos
	STA sub_write+1
	LDA #$76
	STA sub_write+2
	LDA #<intruder_player_data
	STA sub_index+1
	LDA #>intruder_player_data
	STA sub_index+2
	LDX #$00
	LDY #$00
intruder_draw_player_loop
	JSR sub_index
	JSR sub_write
	INC sub_write+1
	INX
	INY
	CPY #$08
	BNE intruder_draw_player_loop
	LDY #$00
	LDA sub_write+1
	CLC
	ADC #$78
	STA sub_write+1
	BCC intruder_draw_player_loop
	INC sub_write+2
	LDA sub_write+2
	CMP #$7A
	BCC intruder_draw_player_loop
	LDA intruder_missile_pos_y
	BNE intruder_draw_missile
	
	LDX #$FF
	LDY #$18
intruder_draw_no_missile
	NOP
	DEX
	BNE intruder_draw_no_missile
	DEY
	BNE intruder_draw_no_missile

	JMP intruder_draw_enemy_missile
intruder_draw_missile
	LDA intruder_missile_pos_x
	STA sub_write+1
	LDA intruder_missile_pos_y
	STA sub_write+2
	JSR intruder_draw_missile_particle_clear
	LDA intruder_missile_pos_y
	SEC
	SBC #$04
	CLC	
	CMP #$08
	BCS intruder_draw_missile_normal
	JMP intruder_draw_missile_reset
intruder_draw_missile_normal
	STA intruder_missile_pos_y


	LDA intruder_missile_pos_y
	CLC	
	CMP #$10
	BCC intruder_draw_missile_mystery_skip
	CLC
	CMP #$14
	BCS intruder_draw_missile_mystery_skip
	LDA intruder_missile_pos_x
	CLC
	CMP intruder_mystery_pos
	BCC intruder_draw_missile_mystery_skip
	SEC
	SBC #$08
	CMP intruder_mystery_pos
	BCS intruder_draw_missile_mystery_skip
	LDA #$FF
	STA intruder_mystery_pos ; hit the mystery ship!
	JSR intruder_mystery_clear

	LDA #$41
	STA printchar_x
	LDA #$0C
	STA printchar_y
	LDA #" "
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	LDA intruder_mystery_bank ; only 250 points available each level
	BEQ intruder_draw_missile_mystery_skip
	SEC
	SBC #$32
	STA intruder_mystery_bank
	LDA #$32 ; 50 in decimal
	CLC
	ADC intruder_points_low
	STA intruder_points_low ; increment points
	CLC
	CMP #$64 ; 100 in decimal
	BCC intruder_draw_missile_mystery_skip
	SEC
	SBC #$64
	STA intruder_points_low
	INC intruder_points_high
	LDA intruder_points_high
	AND #%00000011 ; every 400 points is new life
	BNE intruder_draw_missile_mystery_skip
	LDA intruder_player_lives
	AND #%00001111
	CLC
	CMP #$09
	BCS intruder_draw_missile_mystery_skip
	INC intruder_player_lives
intruder_draw_missile_mystery_skip
	JSR intruder_draw_menu

	LDX #intruder_max_enemies
intruder_draw_missile_array
	LDA intruder_enemy_visible,X
	BNE intruder_draw_missile_check
	JMP intruder_draw_missile_loop
intruder_draw_missile_check
	TXA
	AND #%11111000
	EOR #$FF
	INC A
	ADC intruder_missile_pos_y
	CLC
	CMP intruder_enemy_pos_y
	BCS intruder_draw_missile_check_next1
	JMP intruder_draw_missile_loop
intruder_draw_missile_check_next1
	SEC
	SBC #$04
	CLC
	CMP intruder_enemy_pos_y
	BCC intruder_draw_missile_check_next2
	JMP intruder_draw_missile_loop
intruder_draw_missile_check_next2
	TXA
	AND #%00000111
	CLC
	ROL A
	ROL A
	ROL A
	EOR #$FF
	INC A
	ADC intruder_missile_pos_x
	CLC
	CMP intruder_enemy_pos_x
	BCS intruder_draw_missile_check_next3
	JMP intruder_draw_missile_loop
intruder_draw_missile_check_next3
	SEC
	SBC #$05
	CLC
	CMP intruder_enemy_pos_x
	BCC intruder_draw_missile_check_next4
	JMP intruder_draw_missile_loop
intruder_draw_missile_check_next4
	LDA #$80	
	STA intruder_enemy_visible,X ; hit enemy
	STZ intruder_missile_pos_y

	LDA #$41
	STA printchar_x
	LDA #$0C
	STA printchar_y
	LDA #" "
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	TXA
	AND #%11111000
	CLC
	ROR A
	ROR A
	ROR A
	EOR #$FF
	DEC A
	AND #%00000111
	CLC
	ADC intruder_points_low
	STA intruder_points_low ; increment points
	CLC
	CMP #$64 ; 100 in decimal
	BCC intruder_draw_missile_points
	SEC
	SBC #$64
	STA intruder_points_low
	INC intruder_points_high
	LDA intruder_points_high
	AND #%00000011 ; every 400 points is new life
	BNE intruder_draw_missile_points
	LDA intruder_player_lives
	AND #%00001111
	CLC
	CMP #$09
	BCS intruder_draw_missile_points
	INC intruder_player_lives
intruder_draw_missile_points
	JSR intruder_draw_menu

	PHX
	LDX #intruder_max_enemies
intruder_draw_missile_win_loop
	LDA intruder_enemy_visible,X
	AND #%01111111
	BNE intruder_draw_missile_win_fail
	DEX
	CPX #$FF
	BNE intruder_draw_missile_win_loop
	PLX
	JMP intruder_nextlevel ; won the game!
intruder_draw_missile_win_fail
	PLX
intruder_draw_missile_loop
	DEX
	CPX #$FF
	BEQ intruder_draw_missile_flying
	JMP intruder_draw_missile_array
intruder_draw_missile_flying
	LDA intruder_missile_pos_y
	BNE intruder_draw_missile_flying_next1
	JMP intruder_draw_enemy_missile
intruder_draw_missile_flying_next1
	LDA intruder_missile_pos_x
	STA sub_write+1
	LDA intruder_missile_pos_y
	STA sub_write+2
	PHY
	LDY #$FF
	JSR intruder_draw_missile_particle_color
	PLY
	CPX #$00
	BNE intruder_draw_missile_flying_next2
	JMP intruder_draw_enemy_missile
intruder_draw_missile_flying_next2
	LDA intruder_missile_pos_x
	STA sub_write+1
	LDA intruder_missile_pos_y
	STA sub_write+2
	JSR intruder_draw_missile_particle_clear
intruder_draw_missile_reset
	STZ intruder_missile_pos_y

	JSR intruder_draw_menu

intruder_draw_enemy_missile
	LDA intruder_enemy_missile_y
	BEQ intruder_draw_enemy_missile_skip
	LDA intruder_enemy_missile_x
	STA sub_write+1
	LDA intruder_enemy_missile_y
	STA sub_write+2
	JSR intruder_draw_missile_particle_clear
	LDA intruder_enemy_missile_y
	BEQ intruder_draw_enemy_missile_skip
	JMP intruder_draw_enemy_missile_ready
intruder_draw_enemy_missile_skip
	LDA intruder_delay_timer
	CLC
	CMP intruder_enemy_speed 
	BCC intruder_draw_enemy_missile_timed
	JMP intruder_draw_enemy
intruder_draw_enemy_missile_timed
	LDA intruder_enemy_fall
	EOR #$FF
	STA intruder_enemy_fall
	CLC
	JSR basic_sub_random
	AND intruder_enemy_speed
	AND #%11110000
	PHA
	LDA intruder_enemy_fall
	EOR #$FF
	STA intruder_enemy_fall
	PLA
	BEQ intruder_draw_enemy_missile_search
	JMP intruder_draw_enemy
intruder_draw_enemy_missile_search


	LDA intruder_mystery_pos
	CMP #$FF
	BNE intruder_draw_mystery_skip
	CLC
	JSR basic_sub_random
	AND #%00001111
	BNE intruder_draw_mystery_skip
	STZ intruder_mystery_pos
	LDA #$01
	STA intruder_mystery_speed
	LDA intruder_level
	CLC
	CMP #$04
	BCC intruder_draw_mystery_next
	LDA #$02
	STA intruder_mystery_speed
intruder_draw_mystery_next
	CLC
	JSR basic_sub_random
	AND #%10000000
	BEQ intruder_draw_mystery_skip
	LDA #$4F
	STA intruder_mystery_pos
	LDA #$FF
	STA intruder_mystery_speed
	LDA intruder_level
	CLC
	CMP #$04
	BCC intruder_draw_mystery_skip
	LDA #$FE
	STA intruder_mystery_speed
intruder_draw_mystery_skip


	CLC
	JSR basic_sub_random
	AND #%11111100
	CLC
	ROR A
	ROR A
	CLC
	CMP #$30
	BCS intruder_draw_enemy_missile_search
	TAX
	LDA intruder_enemy_visible,X
	BEQ intruder_draw_enemy_missile_search	
	TXA
	AND #%00000111
	CLC
	ROL A
	ROL A
	ROL A
	ADC intruder_enemy_pos_x
	ADC #$02
	STA intruder_enemy_missile_x
	TXA
	AND #%11111000
	ADC intruder_enemy_pos_y
	CLC
	ADC #$04
	STA intruder_enemy_missile_y
intruder_draw_enemy_missile_ready
	LDA intruder_enemy_missile_s
	CLC
	ADC intruder_enemy_missile_y
	CLC
	CMP #$80
	BCS intruder_draw_enemy_missile_miss
	STA intruder_enemy_missile_y
	CLC
	CMP #$76
	BCC intruder_draw_enemy_missile_normal	
	LDA intruder_enemy_missile_x
	SEC
	SBC #$01
	CLC
	CMP intruder_player_pos
	BCC intruder_draw_enemy_missile_normal
	SEC
	SBC #$05
	CMP intruder_player_pos
	BCS intruder_draw_enemy_missile_normal
	DEC intruder_player_lives ; got hit!

	JSR intruder_draw_menu

	LDA intruder_player_lives
	AND #%00001111
	BNE intruder_draw_enemy_missile_miss
	JMP intruder_gameover
intruder_draw_enemy_missile_normal
	LDA intruder_enemy_missile_x
	STA sub_write+1
	LDA intruder_enemy_missile_y
	STA sub_write+2
	PHY
	LDY #$55
	JSR intruder_draw_missile_particle_color
	PLY
	CPX #$00
	BEQ intruder_draw_enemy
	LDA intruder_enemy_missile_x
	STA sub_write+1
	LDA intruder_enemy_missile_y
	STA sub_write+2
	JSR intruder_draw_missile_particle_clear
intruder_draw_enemy_missile_miss
	STZ intruder_enemy_missile_y
intruder_draw_enemy
	LDX #intruder_max_enemies
intruder_draw_enemy_array
	LDA intruder_enemy_visible,X
	BNE intruder_draw_enemy_visible
	JMP intruder_draw_enemy_loop
intruder_draw_enemy_visible
	CMP #$80
	BNE intruder_draw_enemy_full
	JSR intruder_draw_enemy_clear
	STZ intruder_enemy_visible,X
	JMP intruder_draw_enemy_loop
intruder_draw_enemy_full
	PHX
	TXA
	AND #%00000111
	CLC
	ROL A
	ROL A
	ROL A
	ADC intruder_enemy_pos_x
	STA sub_write+1
	TXA
	AND #%11111000
	ADC intruder_enemy_pos_y
	STA sub_write+2
	LDA intruder_level
	AND #%00000001
	BEQ intruder_draw_enemy_pic2
	LDA intruder_enemy_pos_x
	AND #%00000001
	BEQ intruder_draw_enemy_pic1
	LDA #<intruder_enemy_data1
	STA sub_index+1
	LDA #>intruder_enemy_data1
	STA sub_index+2
	JMP intruder_draw_enemy_pic_done
intruder_draw_enemy_pic1
	LDA #<intruder_enemy_data2
	STA sub_index+1
	LDA #>intruder_enemy_data2
	STA sub_index+2
	JMP intruder_draw_enemy_pic_done
intruder_draw_enemy_pic2
	LDA intruder_enemy_pos_x
	AND #%00000001
	BEQ intruder_draw_enemy_pic3
	LDA #<intruder_enemy_data3
	STA sub_index+1
	LDA #>intruder_enemy_data3
	STA sub_index+2
	JMP intruder_draw_enemy_pic_done
intruder_draw_enemy_pic3
	LDA #<intruder_enemy_data4
	STA sub_index+1
	LDA #>intruder_enemy_data4
	STA sub_index+2
intruder_draw_enemy_pic_done
	LDX #$00
	LDY #$00
	PHY
intruder_draw_enemy_visible_loop
	JSR sub_index
	JSR sub_write
	INC sub_write+1
	INX
	INY
	CPY #$06
	BNE intruder_draw_enemy_visible_loop
	LDY #$00
	LDA sub_write+1
	CLC
	ADC #$7A
	STA sub_write+1
	BCC intruder_draw_enemy_visible_loop
	INC sub_write+2
	LDA sub_write+2
	CLC
	CMP #$72
	BCC intruder_draw_enemy_visible_continue ; too far down!
	JMP intruder_gameover
intruder_draw_enemy_visible_continue
	PLA
	INC A
	CMP #$03
	PHA
	BNE intruder_draw_enemy_visible_loop
	PLA
	PLX
intruder_draw_enemy_loop
	DEX
	CPX #$FF
	BEQ intruder_draw_enemy_move
	JMP intruder_draw_enemy_array
intruder_draw_enemy_move
	LDA intruder_delay_timer
	CLC
	CMP intruder_enemy_speed 
	BCC intruder_draw_enemy_ready
	JMP intruder_loop
intruder_draw_enemy_ready
	STZ intruder_delay_timer
	LDA intruder_enemy_pos_y
	AND #%00000001
	BEQ intruder_draw_enemy_back
	LDA #$01
	JMP intruder_draw_enemy_shift
intruder_draw_enemy_back
	LDA #$FF
intruder_draw_enemy_shift
	CLC
	ADC intruder_enemy_pos_x
	STA intruder_enemy_pos_x
	CLC
	CMP #$0E
	BCS intruder_draw_enemy_down
	CLC
	CMP #$04
	BCC intruder_draw_enemy_down
	JMP intruder_loop
intruder_draw_enemy_down
	LDX #intruder_max_enemies
intruder_draw_enemy_down_clear
	LDA intruder_enemy_visible,X
	BEQ intruder_draw_enemy_down_skip
	JSR intruder_draw_enemy_clear
intruder_draw_enemy_down_skip
	DEX
	CPX #$FF
	BNE intruder_draw_enemy_down_clear
	LDA intruder_enemy_fall
	CLC
	ROR A
	ROR A
	ROR A
	ROR A 
	CLC
	ADC intruder_enemy_pos_y
	STA intruder_enemy_pos_y
intruder_loop
	JMP intruder_input


intruder_draw_menu
	LDA #$04
	STA printchar_x
	LDA #$0C
	STA printchar_y
	LDA intruder_player_lives
	AND #%00001111
	CLC
	ADC #"0"
	JSR printchar
	LDA #$1E
	STA printchar_x
	LDA #$0C
	STA printchar_y

	LDX #$00
intruder_title_loop
	LDA intruder_title_text,X
	JSR printchar
	INX
	CPX #$09
	BNE intruder_title_loop
	JMP intruder_title_end

intruder_title_text
	.BYTE "Intruder"
	.BYTE "s"
intruder_title_end

;	LDA #"I"
;	JSR printchar
;	LDA #"n"
;	JSR printchar
;	LDA #"t"
;	JSR printchar
;	LDA #"r"
;	JSR printchar
;	LDA #"u"
;	JSR printchar
;	LDA #"d"
;	JSR printchar
;	LDA #"e"
;	JSR printchar
;	LDA #"r"
;	JSR printchar
;	LDA #"s"
;	JSR printchar

	LDA #$41
	STA printchar_x
	LDA #$0C
	STA printchar_y
	LDX intruder_points_high
	LDA decimal_conversion_high,X
	JSR printchar
	LDA decimal_conversion_middle,X
	JSR printchar
	LDA decimal_conversion_low,X
	JSR printchar
	LDX intruder_points_low
	LDA decimal_conversion_middle,X
	JSR printchar
	LDA decimal_conversion_low,X
	JSR printchar
	RTS


intruder_gameover
	LDA #$1E
	STA printchar_x
	LDA #$0C
	STA printchar_y
	LDA #"E"
	JSR printchar
	LDA #"S"
	JSR printchar
	LDA #"C"
	JSR printchar
	LDA #" "
	JSR printchar
	LDA #"o"
	JSR printchar
	LDA #"r"
	JSR printchar
	LDA #" "
	JSR printchar
	LDA #"F"
	JSR printchar
	LDA #"1"
	JSR printchar
	LDA #"2"
	JSR printchar
intruder_gameover_loop
	JSR inputchar
	CMP #$00
	BEQ intruder_gameover_loop
	CMP #$1B ; escape
	BEQ intruder_gameover_exit
	CMP #$15 ; F12
	BNE intruder_gameover_loop
	JMP intruder
intruder_gameover_exit
	LDY #$C0 ; reset
	LDX #$00
	JMP switch_banks

intruder_nextlevel
	LDA #$1E
	STA printchar_x
	LDA #$0C
	STA printchar_y
	LDA #"P"
	JSR printchar
	LDA #"r"
	JSR printchar
	LDA #"e"
	JSR printchar
	LDA #"s"
	JSR printchar
	LDA #"s"
	JSR printchar
	LDA #" "
	JSR printchar
	LDA #"E"
	JSR printchar
	LDA #"n"
	JSR printchar
	LDA #"t"
	JSR printchar
	LDA #"e"
	JSR printchar
	LDA #"r"
	JSR printchar
intruder_nextlevel_loop
	JSR inputchar
	CMP #$0D ; enter
	BNE intruder_nextlevel_loop
	INC intruder_level
	JMP intruder_init_level
	

intruder_mystery_clear
	LDX #$00
intruder_draw_mystery_clear1
	STZ $1000,X
	INX
	BNE intruder_draw_mystery_clear1
intruder_draw_mystery_clear2
	STZ $1100,X
	INX
	BNE intruder_draw_mystery_clear2
intruder_draw_mystery_clear3
	STZ $1200,X
	INX
	BNE intruder_draw_mystery_clear3
intruder_draw_mystery_clear4
	STZ $1300,X
	INX
	BNE intruder_draw_mystery_clear4
	RTS

intruder_draw_missile_particle_clear ; sub_write already populated!
	LDA sub_write+1
	PHA
	LDA #$00
	JSR intruder_draw_missile_particle_write
	LDA sub_write+1
	CLC
	ADC #$7F
	STA sub_write+1
	LDA #$00
	JSR intruder_draw_missile_particle_write
	PLA
	PHA
	STA sub_write+1
	INC sub_write+2
	LDA #$00
	JSR intruder_draw_missile_particle_write
	LDA sub_write+1
	CLC
	ADC #$7F
	STA sub_write+1
	LDA #$00
	JSR intruder_draw_missile_particle_write
	PLA
	PHA
	STA sub_write+1
	INC sub_write+2
	LDA #$00
	JSR intruder_draw_missile_particle_write
	LDA sub_write+1
	CLC
	ADC #$7F
	STA sub_write+1
	LDA #$00
	JSR intruder_draw_missile_particle_write
	PLA
	PHA
	STA sub_write+1
	INC sub_write+2
	LDA #$00
	JSR intruder_draw_missile_particle_write
	LDA sub_write+1
	CLC
	ADC #$7F
	STA sub_write+1
	LDA #$00
	JSR intruder_draw_missile_particle_write
	PLA
	RTS

intruder_draw_missile_particle_write
	JSR sub_write
	INC sub_write+1
	JSR sub_write
	RTS

intruder_draw_missile_particle_color ; sub_write already populated! Y has color	
	LDX #$00
	LDA sub_write+1
	PHA
	STA sub_read+1
	LDA sub_write+2
	STA sub_read+2
	JSR sub_read
	AND #%10101010
	BEQ intruder_draw_missile_particle_color_next1
	JSR sub_read
	AND #%01010101
	BNE intruder_draw_missile_particle_color_next1
	INX
intruder_draw_missile_particle_color_next1
	TYA
	AND #%00000011
	JSR sub_write
	INC sub_write+1
	INC sub_read+1
	JSR sub_read
	AND #%10101010
	BEQ intruder_draw_missile_particle_color_next2
	JSR sub_read
	AND #%01010101
	BNE intruder_draw_missile_particle_color_next2
	INX
intruder_draw_missile_particle_color_next2
	TYA
	AND #%11000000
	JSR sub_write
	LDA sub_write+1
	CLC
	ADC #$7F
	STA sub_write+1
	STA sub_read+1
	JSR sub_read
	AND #%10101010
	BEQ intruder_draw_missile_particle_color_next3
	JSR sub_read
	AND #%01010101
	BNE intruder_draw_missile_particle_color_next3
	INX
intruder_draw_missile_particle_color_next3
	TYA
	AND #%00000011
	JSR sub_write
	INC sub_write+1
	INC sub_read+1
	JSR sub_read
	AND #%10101010
	BEQ intruder_draw_missile_particle_color_next4
	JSR sub_read
	AND #%01010101
	BNE intruder_draw_missile_particle_color_next4
	INX
intruder_draw_missile_particle_color_next4
	TYA
	AND #%11000000
	JSR sub_write
	PLA
	PHA
	STA sub_write+1
	STA sub_read+1
	INC sub_write+2
	INC sub_read+2
	JSR sub_read
	AND #%10101010
	BEQ intruder_draw_missile_particle_color_next5
	JSR sub_read
	AND #%01010101
	BNE intruder_draw_missile_particle_color_next5
	INX
intruder_draw_missile_particle_color_next5
	TYA
	AND #%00000011
	JSR sub_write
	INC sub_write+1
	INC sub_read+1
	JSR sub_read
	AND #%10101010
	BEQ intruder_draw_missile_particle_color_next6
	JSR sub_read
	AND #%01010101
	BNE intruder_draw_missile_particle_color_next6
	INX
intruder_draw_missile_particle_color_next6
	TYA
	AND #%11000000
	JSR sub_write
	LDA sub_write+1
	CLC
	ADC #$7F
	STA sub_write+1
	STA sub_read+1
	JSR sub_read
	AND #%10101010
	BEQ intruder_draw_missile_particle_color_next7
	JSR sub_read
	AND #%01010101
	BNE intruder_draw_missile_particle_color_next7
	INX
intruder_draw_missile_particle_color_next7
	TYA
	AND #%00000011
	JSR sub_write
	INC sub_write+1
	INC sub_read+1
	JSR sub_read
	AND #%10101010
	BEQ intruder_draw_missile_particle_color_next8
	JSR sub_read
	AND #%01010101
	BNE intruder_draw_missile_particle_color_next8
	INX
intruder_draw_missile_particle_color_next8
	TYA
	AND #%11000000
	JSR sub_write
	PLA
	PHA
	STA sub_write+1
	STA sub_read+1
	INC sub_write+2
	INC sub_read+2
	JSR sub_read
	AND #%10101010
	BEQ intruder_draw_missile_particle_color_next9
	JSR sub_read
	AND #%01010101
	BNE intruder_draw_missile_particle_color_next9
	INX
intruder_draw_missile_particle_color_next9
	TYA
	AND #%00000011
	JSR sub_write
	INC sub_write+1
	INC sub_read+1
	JSR sub_read
	AND #%10101010
	BEQ intruder_draw_missile_particle_color_next10
	JSR sub_read
	AND #%01010101
	BNE intruder_draw_missile_particle_color_next10
	INX
intruder_draw_missile_particle_color_next10
	TYA
	AND #%11000000
	JSR sub_write
	LDA sub_write+1
	CLC
	ADC #$7F
	STA sub_write+1
	STA sub_read+1
	JSR sub_read
	AND #%10101010
	BEQ intruder_draw_missile_particle_color_next11
	JSR sub_read
	AND #%01010101
	BNE intruder_draw_missile_particle_color_next11
	INX
intruder_draw_missile_particle_color_next11
	TYA
	AND #%00000011
	JSR sub_write
	INC sub_write+1
	INC sub_read+1
	JSR sub_read
	AND #%10101010
	BEQ intruder_draw_missile_particle_color_next12
	JSR sub_read
	AND #%01010101
	BNE intruder_draw_missile_particle_color_next12
	INX
intruder_draw_missile_particle_color_next12
	TYA
	AND #%11000000
	JSR sub_write
	PLA
	PHA
	STA sub_write+1
	STA sub_read+1
	INC sub_write+2
	INC sub_read+2
	JSR sub_read
	AND #%10101010
	BEQ intruder_draw_missile_particle_color_next13
	JSR sub_read
	AND #%01010101
	BNE intruder_draw_missile_particle_color_next13
	INX
intruder_draw_missile_particle_color_next13
	TYA
	AND #%00000011
	JSR sub_write
	INC sub_write+1
	INC sub_read+1
	JSR sub_read
	AND #%10101010
	BEQ intruder_draw_missile_particle_color_next14
	JSR sub_read
	AND #%01010101
	BNE intruder_draw_missile_particle_color_next14
	INX
intruder_draw_missile_particle_color_next14
	TYA
	AND #%11000000
	JSR sub_write
	LDA sub_write+1
	CLC
	ADC #$7F
	STA sub_write+1
	STA sub_read+1
	JSR sub_read
	AND #%10101010
	BEQ intruder_draw_missile_particle_color_next15
	JSR sub_read
	AND #%01010101
	BNE intruder_draw_missile_particle_color_next15
	INX
intruder_draw_missile_particle_color_next15
	TYA
	AND #%00000011
	JSR sub_write
	INC sub_write+1
	INC sub_read+1
	JSR sub_read
	AND #%10101010
	BEQ intruder_draw_missile_particle_color_next16
	JSR sub_read
	AND #%01010101
	BNE intruder_draw_missile_particle_color_next16
	INX
intruder_draw_missile_particle_color_next16
	TYA
	AND #%11000000
	JSR sub_write
	PLA
	RTS

intruder_draw_enemy_clear ; X already populated
	PHX
	TXA
	AND #%00000111
	CLC
	ROL A
	ROL A
	ROL A
	ADC intruder_enemy_pos_x
	STA sub_write+1
	TXA
	AND #%11111000
	ADC intruder_enemy_pos_y
	STA sub_write+2
	LDX #$00
	LDY #$00
	PHY
intruder_draw_enemy_clear_loop
	LDA #$00
	JSR sub_write
	INC sub_write+1
	INX
	INY
	CPY #$06
	BNE intruder_draw_enemy_clear_loop
	LDY #$00
	LDA sub_write+1
	CLC
	ADC #$7A
	STA sub_write+1
	BCC intruder_draw_enemy_clear_loop
	INC sub_write+2
	PLA
	INC A
	CMP #$03
	PHA
	BNE intruder_draw_enemy_clear_loop
	PLA
	PLX
	RTS

intruder_init_shield ; A has horizontal position
	STA sub_write+1
	LDA #$6C
	STA sub_write+2
	LDA #<intruder_shield_data
	STA sub_index+1
	LDA #>intruder_shield_data
	STA sub_index+2
	LDX #$00
	LDY #$00
intruder_init_shield_loop
	JSR sub_index
	JSR sub_write
	INC sub_write+1
	INX
	INY
	CPY #$08
	BNE intruder_init_shield_loop
	LDY #$00
	LDA sub_write+1
	CLC
	ADC #$78
	STA sub_write+1
	BCC intruder_init_shield_loop
	INC sub_write+2
	LDA sub_write+2
	CMP #$72
	BCC intruder_init_shield_loop
	RTS

intruder_player_data
	.BYTE $00,$00,$00,$03,$C0,$00,$00,$00
	.BYTE $00,$00,$00,$0F,$F0,$00,$00,$00
	.BYTE $00,$00,$03,$FF,$FF,$C0,$00,$00
	.BYTE $00,$00,$3F,$FF,$FF,$FC,$00,$00
	.BYTE $00,$00,$FF,$FF,$FF,$FF,$00,$00
	.BYTE $00,$00,$FF,$FF,$FF,$FF,$00,$00
	.BYTE $00,$00,$FF,$FF,$FF,$FF,$00,$00
	.BYTE $00,$00,$FF,$FF,$FF,$FF,$00,$00

intruder_shield_data
	.BYTE $00,$00,$AA,$AA,$AA,$AA,$00,$00
	.BYTE $00,$AA,$AA,$AA,$AA,$AA,$AA,$00
	.BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$00,$00,$AA,$AA,$AA

intruder_mystery_data
	.BYTE $00,$00,$FF,$00,$00,$FF,$00,$00
	.BYTE $00,$00,$03,$C0,$03,$C0,$00,$00
	.BYTE $00,$00,$00,$FF,$FF,$00,$00,$00
	.BYTE $00,$00,$3F,$FF,$FF,$FC,$00,$00
	.BYTE $00,$00,$FF,$3F,$FC,$FF,$00,$00
	.BYTE $00,$00,$FF,$FF,$FF,$FF,$00,$00
	.BYTE $00,$00,$3F,$FF,$FF,$FC,$00,$00
	.BYTE $00,$00,$00,$FF,$FF,$00,$00,$00

intruder_enemy_data1
	.BYTE $00,$00,$55,$55,$00,$00
	.BYTE $00,$05,$55,$55,$50,$00
	.BYTE $00,$55,$00,$00,$55,$00
	.BYTE $00,$05,$55,$55,$50,$00
	.BYTE $00,$00,$50,$05,$00,$00
	.BYTE $00,$55,$50,$05,$55,$00

intruder_enemy_data2
	.BYTE $00,$05,$55,$55,$50,$00
	.BYTE $00,$55,$00,$00,$55,$00
	.BYTE $00,$05,$55,$55,$50,$00
	.BYTE $00,$00,$55,$55,$00,$00
	.BYTE $00,$00,$50,$05,$00,$00
	.BYTE $00,$05,$50,$05,$50,$00

intruder_enemy_data3
	.BYTE $00,$05,$50,$05,$50,$00
	.BYTE $00,$50,$55,$55,$05,$00
	.BYTE $00,$00,$50,$05,$00,$00
	.BYTE $00,$55,$55,$55,$55,$00
	.BYTE $00,$55,$50,$05,$55,$00
	.BYTE $00,$50,$00,$00,$05,$00

intruder_enemy_data4
	.BYTE $00,$55,$50,$05,$55,$00
	.BYTE $00,$00,$55,$55,$00,$00
	.BYTE $00,$00,$50,$05,$00,$00
	.BYTE $00,$05,$55,$55,$50,$00
	.BYTE $00,$55,$50,$05,$55,$00
	.BYTE $00,$05,$50,$05,$50,$00


	.ORG $DC00

; these convert hex values into decimal values for printing
; converting user decimal values into hex is done with code
; leading zeros are NOT omitted
decimal_conversion_high
	.BYTE "00000000"
	.BYTE "00000000"
	.BYTE "00000000"
	.BYTE "00000000"
	.BYTE "00000000"
	.BYTE "00000000"
	.BYTE "00000000"
	.BYTE "00000000"
	.BYTE "00000000"
	.BYTE "00000000"
	.BYTE "00000000"
	.BYTE "00000000"
	.BYTE "00001111"
	.BYTE "11111111"
	.BYTE "11111111"
	.BYTE "11111111"
	.BYTE "11111111"
	.BYTE "11111111"
	.BYTE "11111111"
	.BYTE "11111111"
	.BYTE "11111111"
	.BYTE "11111111"
	.BYTE "11111111"
	.BYTE "11111111"
	.BYTE "11111111"
	.BYTE "22222222"
	.BYTE "22222222"
	.BYTE "22222222"
	.BYTE "22222222"
	.BYTE "22222222"
	.BYTE "22222222"
	.BYTE "22222222"

decimal_conversion_middle
	.BYTE "00000000"
	.BYTE "00111111"
	.BYTE "11112222"
	.BYTE "22222233"
	.BYTE "33333333"
	.BYTE "44444444"
	.BYTE "44555555"
	.BYTE "55556666"
	.BYTE "66666677"
	.BYTE "77777777"
	.BYTE "88888888"
	.BYTE "88999999"
	.BYTE "99990000"
	.BYTE "00000011"
	.BYTE "11111111"
	.BYTE "22222222"
	.BYTE "22333333"
	.BYTE "33334444"
	.BYTE "44444455"
	.BYTE "55555555"
	.BYTE "66666666"
	.BYTE "66777777"
	.BYTE "77778888"
	.BYTE "88888899"
	.BYTE "99999999"
	.BYTE "00000000"
	.BYTE "00111111"
	.BYTE "11112222"
	.BYTE "22222233"
	.BYTE "33333333"
	.BYTE "44444444"
	.BYTE "44555555"

decimal_conversion_low
	.BYTE "01234567"
	.BYTE "89012345"
	.BYTE "67890123"
	.BYTE "45678901"
	.BYTE "23456789"
	.BYTE "01234567"
	.BYTE "89012345"
	.BYTE "67890123"
	.BYTE "45678901"
	.BYTE "23456789"
	.BYTE "01234567"
	.BYTE "89012345"
	.BYTE "67890123"
	.BYTE "45678901"
	.BYTE "23456789"
	.BYTE "01234567"
	.BYTE "89012345"
	.BYTE "67890123"
	.BYTE "45678901"
	.BYTE "23456789"
	.BYTE "01234567"
	.BYTE "89012345"
	.BYTE "67890123"
	.BYTE "45678901"
	.BYTE "23456789"
	.BYTE "01234567"
	.BYTE "89012345"
	.BYTE "67890123"
	.BYTE "45678901"
	.BYTE "23456789"
	.BYTE "01234567"
	.BYTE "89012345"


; universal code and tables below this point
	

; 256 byte lookup table
; converts ps2 keyboard hex into ascii values
; the first 128 bytes are without shift/extended
; the second 128 bytes are with shift/extended
ascii_lookup
	.BYTE $00,$16,$0F,$0C,$1E,$1C,$1D,$15
	.BYTE $00,$18,$07,$0E,$1F,$09,$60,$00
	.BYTE $00,$00,$00,$00,$00,$71,$31,$00
	.BYTE $00,$00,$7A,$73,$61,$77,$32,$00
	.BYTE $00,$63,$78,$64,$65,$34,$33,$00
	.BYTE $00,$20,$76,$66,$74,$72,$35,$00
	.BYTE $00,$6E,$62,$68,$67,$79,$36,$00
	.BYTE $00,$00,$6D,$6A,$75,$37,$38,$00
	.BYTE $00,$2C,$6B,$69,$6F,$30,$39,$00
	.BYTE $00,$2E,$2F,$6C,$3B,$70,$2D,$00
	.BYTE $00,$00,$27,$00,$5B,$3D,$00,$00
	.BYTE $00,$00,$0D,$5D,$00,$5C,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$08,$00
	.BYTE $00,$31,$00,$34,$37,$00,$00,$00
	.BYTE $30,$2E,$32,$35,$36,$38,$1B,$00
	.BYTE $19,$2B,$33,$2D,$2A,$39,$00,$00

	.BYTE $00,$16,$0F,$0C,$1E,$1C,$1D,$15
	.BYTE $00,$18,$07,$0E,$1F,$09,$7E,$00
	.BYTE $00,$00,$00,$00,$00,$51,$21,$00
	.BYTE $00,$00,$5A,$53,$41,$57,$40,$00
	.BYTE $00,$43,$58,$44,$45,$24,$23,$00
	.BYTE $00,$20,$56,$46,$54,$52,$25,$00
	.BYTE $00,$4E,$42,$48,$47,$59,$5E,$00
	.BYTE $00,$00,$4D,$4A,$55,$26,$2A,$00
	.BYTE $00,$3C,$4B,$49,$4F,$29,$28,$00
	.BYTE $00,$3E,$3F,$4C,$3A,$50,$5F,$00
	.BYTE $00,$00,$22,$00,$7B,$2B,$00,$00
	.BYTE $00,$00,$0D,$7D,$00,$7C,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$08,$00
	.BYTE $00,$03,$00,$13,$02,$00,$00,$00
	.BYTE $1A,$7F,$12,$35,$14,$11,$1B,$00
	.BYTE $19,$2B,$04,$2D,$2A,$01,$00,$00


	.ORG $E000

; unused space here

	.ORG $F800

; ~2K version for 40-columns
ascii_charrom
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $0F,$00,$3F,$C0,$3F,$C0,$3F,$C0
	.BYTE $0F,$00,$00,$00,$0F,$00,$00,$00
	.BYTE $0C,$30,$30,$C0,$3C,$F0,$3C,$F0
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $3C,$F0,$FF,$FC,$3C,$F0,$3C,$F0
	.BYTE $3C,$F0,$FF,$FC,$3C,$F0,$00,$00
	.BYTE $03,$00,$3F,$FC,$F3,$00,$3F,$F0
	.BYTE $03,$3C,$FF,$F0,$03,$00,$00,$00
	.BYTE $30,$0C,$CC,$3C,$30,$F0,$03,$C0
	.BYTE $0F,$30,$3C,$CC,$F0,$30,$00,$00
	.BYTE $3F,$00,$F3,$C0,$3F,$00,$F3,$CC
	.BYTE $F0,$FC,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $0F,$00,$0F,$00,$03,$00,$0C,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $03,$F0,$0F,$00,$3C,$00,$3C,$00
	.BYTE $3C,$00,$0F,$00,$03,$F0,$00,$00
	.BYTE $3F,$00,$03,$C0,$00,$F0,$00,$F0
	.BYTE $00,$F0,$03,$C0,$3F,$00,$00,$00
	.BYTE $00,$00,$00,$00,$3C,$F0,$0F,$C0
	.BYTE $3C,$F0,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$03,$00,$03,$00
	.BYTE $3F,$F0,$03,$00,$03,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$0F,$00
	.BYTE $0F,$00,$03,$00,$0C,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $3F,$F0,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$0F,$00,$0F,$00,$00,$00
	.BYTE $00,$30,$00,$F0,$03,$C0,$0F,$00
	.BYTE $3C,$00,$F0,$00,$C0,$00,$00,$00
	.BYTE $3F,$F0,$F0,$3C,$F0,$FC,$F3,$3C
	.BYTE $FC,$3C,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $FF,$C0,$0F,$C0,$0F,$C0,$0F,$C0
	.BYTE $0F,$C0,$0F,$C0,$FF,$FC,$00,$00
	.BYTE $3F,$F0,$F0,$3C,$00,$F0,$0F,$C0
	.BYTE $3C,$00,$F0,$00,$FF,$FC,$00,$00
	.BYTE $3F,$F0,$F0,$3C,$00,$3C,$0F,$F0
	.BYTE $00,$3C,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $03,$FC,$0F,$3C,$3C,$3C,$F0,$3C
	.BYTE $FF,$FC,$00,$3C,$00,$3C,$00,$00
	.BYTE $FF,$FC,$F0,$00,$FF,$F0,$00,$3C
	.BYTE $00,$3C,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $3F,$F0,$F0,$3C,$F0,$00,$FF,$F0
	.BYTE $F0,$3C,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $FF,$FC,$F0,$3C,$00,$F0,$03,$C0
	.BYTE $0F,$00,$3C,$00,$F0,$00,$00,$00
	.BYTE $3F,$F0,$F0,$3C,$F0,$3C,$3F,$F0
	.BYTE $F0,$3C,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $3F,$F0,$F0,$3C,$F0,$3C,$3F,$FC
	.BYTE $00,$3C,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $00,$00,$0F,$00,$00,$00,$00,$00
	.BYTE $00,$00,$0F,$00,$00,$00,$00,$00
	.BYTE $00,$00,$0F,$00,$00,$00,$00,$00
	.BYTE $0F,$00,$0F,$00,$3C,$00,$00,$00
	.BYTE $00,$00,$00,$00,$03,$F0,$0F,$C0
	.BYTE $3F,$00,$0F,$C0,$03,$F0,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$3F,$F0
	.BYTE $00,$00,$3F,$F0,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$3F,$00,$0F,$C0
	.BYTE $03,$F0,$0F,$C0,$3F,$00,$00,$00
	.BYTE $3F,$F0,$F0,$3C,$00,$3C,$0F,$F0
	.BYTE $0F,$00,$00,$00,$0F,$00,$00,$00
	.BYTE $3F,$F0,$F0,$3C,$F3,$3C,$F3,$3C
	.BYTE $F3,$F0,$F0,$00,$3F,$F0,$00,$00
	.BYTE $0F,$C0,$3C,$F0,$F0,$3C,$F0,$3C
	.BYTE $FF,$FC,$F0,$3C,$F0,$3C,$00,$00
	.BYTE $FF,$F0,$F0,$3C,$F0,$3C,$FF,$F0
	.BYTE $F0,$3C,$F0,$3C,$FF,$F0,$00,$00
	.BYTE $3F,$F0,$F0,$3C,$F0,$00,$F0,$00
	.BYTE $F0,$00,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $FF,$C0,$F0,$F0,$F0,$3C,$F0,$3C
	.BYTE $F0,$3C,$F0,$F0,$FF,$C0,$00,$00
	.BYTE $FF,$FC,$F0,$00,$F0,$00,$FF,$C0
	.BYTE $F0,$00,$F0,$00,$FF,$FC,$00,$00
	.BYTE $FF,$FC,$F0,$00,$F0,$00,$FF,$C0
	.BYTE $F0,$00,$F0,$00,$F0,$00,$00,$00
	.BYTE $3F,$FC,$F0,$00,$F0,$00,$F3,$FC
	.BYTE $F0,$3C,$F0,$3C,$3F,$FC,$00,$00
	.BYTE $F0,$3C,$F0,$3C,$F0,$3C,$FF,$FC
	.BYTE $F0,$3C,$F0,$3C,$F0,$3C,$00,$00
	.BYTE $FF,$FC,$0F,$C0,$0F,$C0,$0F,$C0
	.BYTE $0F,$C0,$0F,$C0,$FF,$FC,$00,$00
	.BYTE $03,$FC,$00,$3C,$00,$3C,$00,$3C
	.BYTE $F0,$3C,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $F0,$3C,$F0,$F0,$F3,$C0,$FF,$00
	.BYTE $F3,$C0,$F0,$F0,$F0,$3C,$00,$00
	.BYTE $F0,$00,$F0,$00,$F0,$00,$F0,$00
	.BYTE $F0,$00,$F0,$00,$FF,$FC,$00,$00
	.BYTE $F0,$3C,$FC,$FC,$FF,$FC,$F3,$3C
	.BYTE $F0,$3C,$F0,$3C,$F0,$3C,$00,$00
	.BYTE $F0,$3C,$FC,$3C,$FF,$3C,$F3,$FC
	.BYTE $F0,$FC,$F0,$3C,$F0,$3C,$00,$00
	.BYTE $3F,$F0,$F0,$3C,$F0,$3C,$F0,$3C
	.BYTE $F0,$3C,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $FF,$F0,$F0,$3C,$F0,$3C,$FF,$F0
	.BYTE $F0,$00,$F0,$00,$F0,$00,$00,$00
	.BYTE $3F,$F0,$F0,$3C,$F0,$3C,$F0,$3C
	.BYTE $F3,$FC,$F0,$F0,$3F,$CC,$00,$00
	.BYTE $FF,$F0,$F0,$3C,$F0,$3C,$FF,$F0
	.BYTE $F3,$C0,$F0,$F0,$F0,$3C,$00,$00
	.BYTE $3F,$F0,$F0,$3C,$F0,$00,$3F,$F0
	.BYTE $00,$3C,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $FF,$FC,$0F,$C0,$0F,$C0,$0F,$C0
	.BYTE $0F,$C0,$0F,$C0,$0F,$C0,$00,$00
	.BYTE $F0,$3C,$F0,$3C,$F0,$3C,$F0,$3C
	.BYTE $F0,$3C,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $F0,$3C,$F0,$3C,$F0,$3C,$F0,$3C
	.BYTE $3C,$F0,$0F,$C0,$03,$00,$00,$00
	.BYTE $F0,$3C,$F0,$3C,$F3,$3C,$FF,$FC
	.BYTE $FC,$FC,$F0,$3C,$F0,$3C,$00,$00
	.BYTE $F0,$3C,$FC,$FC,$3F,$F0,$0F,$C0
	.BYTE $3F,$F0,$FC,$FC,$F0,$3C,$00,$00
	.BYTE $F0,$3C,$F0,$3C,$F0,$3C,$3F,$F0
	.BYTE $0F,$C0,$0F,$C0,$0F,$C0,$00,$00
	.BYTE $FF,$FC,$00,$FC,$03,$F0,$0F,$C0
	.BYTE $3F,$00,$FC,$00,$FF,$FC,$00,$00
	.BYTE $3F,$F0,$3C,$00,$3C,$00,$3C,$00
	.BYTE $3C,$00,$3C,$00,$3F,$F0,$00,$00
	.BYTE $30,$00,$3C,$00,$0F,$00,$03,$C0
	.BYTE $00,$F0,$00,$3C,$00,$0C,$00,$00
	.BYTE $3F,$F0,$00,$F0,$00,$F0,$00,$F0
	.BYTE $00,$F0,$00,$F0,$3F,$F0,$00,$00
	.BYTE $03,$00,$0F,$C0,$3C,$F0,$F0,$3C
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$FF,$FC,$00,$00
	.BYTE $0C,$00,$03,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$3F,$F0,$00,$3C
	.BYTE $3F,$FC,$F0,$3C,$3F,$FC,$00,$00
	.BYTE $F0,$00,$F0,$00,$FF,$F0,$F0,$3C
	.BYTE $F0,$3C,$F0,$3C,$FF,$F0,$00,$00
	.BYTE $00,$00,$00,$00,$3F,$F0,$F0,$3C
	.BYTE $F0,$00,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $00,$3C,$00,$3C,$3F,$FC,$F0,$3C
	.BYTE $F0,$3C,$F0,$3C,$3F,$FC,$00,$00
	.BYTE $00,$00,$00,$00,$3F,$F0,$F0,$3C
	.BYTE $FF,$FC,$F0,$00,$3F,$F0,$00,$00
	.BYTE $0F,$F0,$0F,$00,$FF,$FC,$0F,$00
	.BYTE $0F,$00,$0F,$00,$0F,$00,$00,$00
	.BYTE $00,$00,$00,$00,$3F,$FC,$F0,$3C
	.BYTE $3F,$FC,$00,$3C,$3F,$F0,$00,$00
	.BYTE $F0,$00,$F0,$00,$FF,$F0,$F0,$3C
	.BYTE $F0,$3C,$F0,$3C,$F0,$3C,$00,$00
	.BYTE $03,$C0,$00,$00,$3F,$C0,$03,$C0
	.BYTE $03,$C0,$03,$C0,$FF,$FC,$00,$00
	.BYTE $00,$3C,$00,$00,$00,$3C,$00,$3C
	.BYTE $00,$3C,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $F0,$00,$F0,$00,$F0,$3C,$F0,$F0
	.BYTE $FF,$C0,$F0,$F0,$F0,$3C,$00,$00
	.BYTE $F0,$00,$F0,$00,$F0,$00,$F0,$00
	.BYTE $F0,$00,$3F,$00,$03,$FC,$00,$00
	.BYTE $00,$00,$00,$00,$FF,$F0,$F3,$3C
	.BYTE $F3,$3C,$F3,$3C,$F3,$3C,$00,$00
	.BYTE $00,$00,$00,$00,$FF,$F0,$F0,$3C
	.BYTE $F0,$3C,$F0,$3C,$F0,$3C,$00,$00
	.BYTE $00,$00,$00,$00,$3F,$F0,$F0,$3C
	.BYTE $F0,$3C,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $00,$00,$00,$00,$FF,$F0,$F0,$3C
	.BYTE $FF,$F0,$F0,$00,$F0,$00,$00,$00
	.BYTE $00,$00,$00,$00,$3F,$FC,$F0,$3C
	.BYTE $3F,$FC,$00,$3C,$00,$3C,$00,$00
	.BYTE $00,$00,$00,$00,$F3,$F0,$FC,$3C
	.BYTE $F0,$00,$F0,$00,$F0,$00,$00,$00
	.BYTE $00,$00,$00,$00,$3F,$FC,$F0,$00
	.BYTE $FF,$FC,$00,$3C,$FF,$F0,$00,$00
	.BYTE $0F,$00,$0F,$00,$FF,$FC,$0F,$00
	.BYTE $0F,$00,$0F,$00,$0F,$FC,$00,$00
	.BYTE $00,$00,$00,$00,$F0,$3C,$F0,$3C
	.BYTE $F0,$3C,$F0,$3C,$3F,$F0,$00,$00
	.BYTE $00,$00,$00,$00,$F0,$3C,$F0,$3C
	.BYTE $3C,$F0,$0F,$C0,$03,$00,$00,$00
	.BYTE $00,$00,$00,$00,$F0,$3C,$F3,$3C
	.BYTE $F3,$3C,$FF,$FC,$3C,$F0,$00,$00
	.BYTE $00,$00,$00,$00,$FC,$FC,$3F,$F0
	.BYTE $0F,$C0,$3F,$F0,$FC,$FC,$00,$00
	.BYTE $00,$00,$00,$00,$F0,$3C,$F0,$3C
	.BYTE $3C,$F0,$0F,$C0,$FF,$00,$00,$00
	.BYTE $00,$00,$00,$00,$FF,$FC,$03,$F0
	.BYTE $0F,$C0,$3F,$00,$FF,$FC,$00,$00
	.BYTE $03,$F0,$0F,$00,$0F,$00,$3F,$00
	.BYTE $0F,$00,$0F,$00,$03,$F0,$00,$00
	.BYTE $0F,$00,$0F,$00,$0F,$00,$0F,$00
	.BYTE $0F,$00,$0F,$00,$0F,$00,$00,$00
	.BYTE $3F,$00,$03,$C0,$03,$C0,$03,$F0
	.BYTE $03,$C0,$03,$C0,$3F,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$3F,$3C
	.BYTE $F3,$3C,$F3,$F0,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00


; some unused space here


	.ORG $FF60

; 6502 running at 3.14 MHz,
; PS/2 keyboard running at around 17 kHz
; /NMI = Keyboard-Clock
; /IRQ = Keyboard-Data

vector_nmi
	PHA
	LDA output_byte
	AND #%01000000
	BNE vector_nmi_ready
	PLA
	RTI ; exit
vector_nmi_ready
	LDA #$FF
	CLI
	NOP ; for safety
vector_nmi_read	
	ROR A
	ROR key_data
	DEC key_counter
	BEQ vector_nmi_store
	LDA key_counter
	CLC
	CMP #$08
	BCS vector_nmi_check
	PLA
	RTI ; exit
vector_nmi_check
	PHX
	LDX key_write
	ROL key_data
	ROR key_error,X
	CMP #$FE
	BEQ vector_nmi_reset
	PLX
	PLA
	RTI ; exit
vector_nmi_reset
	LDA key_code
	STA key_array,X
	INC key_write
	BPL vector_nmi_positive
	STZ key_write
vector_nmi_positive
	LDA #$09
	STA key_counter
	PLX
	PLA
	RTI ; exit
vector_nmi_store
	LDA key_data
	STA key_code
	PLA
	RTI ; exit

vector_irq
	PHA
	LDA output_byte
	AND #%01000000
	BNE vector_irq_ready
	PLA
	JMP jump_vector_irq_extra ; jump to other interrupts
vector_irq_ready
	PLA
	PLA
	PLA
	PLA
	LDA #$00
	JMP vector_nmi_read



	.ORG $FFE0


switch_banks	
	LDA output_byte
	AND #%11101111
	STA output_byte
	STA $FFFF
	NOP
	STX sub_jump+1
	STY sub_jump+2
	JMP (sub_jump+1)


	.ORG $FFFA

; reset/interrupt vectors
	.WORD jump_vector_nmi
	.WORD vector_reset
	.WORD jump_vector_irq


