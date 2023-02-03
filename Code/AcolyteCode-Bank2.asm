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
; $8000-$BFFF = General Purpose RAM
; $C000-$FFFF = ROM (8x banks)

; Writing to ROM produces output
; D0 = SPI-CLK
; D1 = SPI-MOSI
; D2 = SPI-EEPROM
; D3 = SPI-SDCARD
; D4 = BANK-A
; D5 = BANK-B
; D6 = BANK-C
; D7 = AUDIO-OUT

; Input is through interrupts and /SO
; /IRQ = KEY-CLK
; /NMI = KEY-CLK nor KEY-DATA
; /SO = SPI-MISO nor SO-TRIGGER (fixed rate)


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

key_write		.EQU $0300
key_read		.EQU $0301
key_data		.EQU $0302
key_counter		.EQU $0303
key_release		.EQU $0304
key_extended		.EQU $0305
key_shift		.EQU $0306
key_capslock		.EQU $0307
key_alt_control		.EQU $0308
key_bit			.EQU $0309 ; was key_code
key_speed		.EQU $030A ; was key_parity

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

; 48 bytes unused

game_score_low		.EQU $03D0
game_score_high		.EQU $03D1
game_piece		.EQU $03D2
game_piece_next		.EQU $03D3
game_location		.EQU $03D4
game_cycle		.EQU $03D5
game_speed		.EQU $03D6
game_overscan		.EQU $03D7

command_array		.EQU $03D8 ; 40 characters til end

game_field		.EQU $0400 ; shared with sdcard_memory

screen 			.EQU $0800

; unused space from $8000 to $87FF

basic_A			.EQU $8800
basic_B			.EQU $8900
basic_C			.EQU $8A00
basic_D			.EQU $8B00
basic_W			.EQU $8C00
basic_X			.EQU $8D00
basic_Y			.EQU $8E00
basic_Z			.EQU $8F00
basic_code		.EQU $9000
basic_code_end		.EQU $BEFF
basic_code_error	.EQU $BF00 ; one past

; unused I/O space from $BF00 to $BF7F

via			.EQU $BF80 ; for via expansion, duplicated for whole page
via_pb			.EQU via+$00
via_pa			.EQU via+$01
via_db			.EQU via+$02
via_da			.EQU via+$03
via_pcr			.EQU via+$0C
via_ifr			.EQU via+$0D
via_ier			.EQU via+$0E


; the start of code

	.ORG $C000

vector_reset
	SEI			; turn off interrupts from /IRQ
	CLD			; turn off decimal mode

	LDX #$00		; zeroing out a lot of variables
zero_loop
	STZ $0300,X
	INX
	BNE zero_loop

	LDA #$4C ; JMPa			; mini-jump tables for NMI and IRQ
	STA jump_vector_nmi+0		; so that it is easier to use those while programming
	LDA #<vector_nmi		; directly on this machine from the assembler/monitor
	STA jump_vector_nmi+1
	LDA #>vector_nmi
	STA jump_vector_nmi+2
	LDA #$4C ; JMPa
	STA jump_vector_irq+0
	LDA #<vector_irq
	STA jump_vector_irq+1
	LDA #>vector_irq
	STA jump_vector_irq+2

	STZ key_write		; reset key info
	STZ key_read
	STZ key_data
	LDA #$0A
	STA key_counter
	STZ key_bit
	STZ key_speed

;	LDA #%00001100		; set output pins
;	STA $C000

;	LDA #%01111111		; clears interrupt flags
;	STA via_ifr
;	STZ via_ier

;	LDA #%10001100		; set output pins
;	STA $C000

;	LDA #%01111111		; clears interrupt flags
;	STA via_ifr
;	STZ via_ier

	CLI

	LDA #%00001100		; set output pins
	STA output_byte
	STA $C000

	LDA #$FF
	STA command_data
	; comment this next line when simulating
	JMP main_initialize	

game_jump
	STA command_data
	AND #%00000001
	BEQ game_tetra
	JMP game_extra

game_tetra
	LDA #$00
	STA command_data
	JMP main_initialize

game_extra
	LDA #$01
	STA command_data

main_initialize
	LDA #$AD ; LDAa			; create sub_read, sub_write, sub_jump, and sub_index functions
	STA sub_read+0
	STZ sub_read+1
	STZ sub_read+2
	LDA #$60 ; RTS
	STA sub_read+3
	LDA #$8D ; STAa
	STA sub_write+0
	STZ sub_write+1
	STZ sub_write+2
	LDA #$60 ; RTS
	STA sub_write+3
	LDA #$20 ; JSRa
	STA sub_jump+0
	STZ sub_jump+1
	STZ sub_jump+2
	LDA #$60 ; RTS
	STA sub_jump+3
	LDA #$BD ; LDAax
	STA sub_index+0
	STZ sub_index+1
	STZ sub_index+2
	LDA #$60 ; RTS
	STA sub_index+3

	;LDA #$AD ; LDAa			; create basic_sub_random (should already be created)
	;STA basic_sub_random+$00		; it is not really random, but
	;LDA #<basic_sub_random_var		; works well enough.  A random
	;STA basic_sub_random+$01		; seed is started when waiting for
	;LDA #>basic_sub_random_var		; key presses.  It basically says
	;STA basic_sub_random+$02		; current = 5 * previous + 17
	;LDA #$2A ; ROLA
	;STA basic_sub_random+$03
	;LDA #$18 ; CLC
	;STA basic_sub_random+$04
	;LDA #$2A ; ROLA
	;STA basic_sub_random+$05
	;LDA #$18 ; CLC
	;STA basic_sub_random+$06
	;LDA #$6D ; ADCa
	;STA basic_sub_random+$07
	;LDA #<basic_sub_random_var
	;STA basic_sub_random+$08
	;LDA #>basic_sub_random_var
	;STA basic_sub_random+$09
	;LDA #$18 ; CLC
	;STA basic_sub_random+$0A
	;LDA #$69 ; ADC#
	;STA basic_sub_random+$0B
	;LDA #$11 ; 17
	;STA basic_sub_random+$0C
	;LDA #$8D ; STAa
	;STA basic_sub_random+$0D
	;LDA #<basic_sub_random_var
	;STA basic_sub_random+$0E
	;LDA #>basic_sub_random_var
	;STA basic_sub_random+$0F
	;LDA #$60 ; RTS
	;STA basic_sub_random+$10

	STZ sub_write+1				; clear out all system and screen RAM 
	LDA #$04
	STA sub_write+2
wipeout_loop
	LDA #$00 ; fill color
	JSR sub_write
	INC sub_write+1
	BNE wipeout_loop
	INC sub_write+2
	LDA sub_write+2
	CMP #$80
	BNE wipeout_loop

	STZ command_mode			; start in scratchpad mode
	STZ printchar_invert

	LDA command_data
	BEQ game_initialize
	BMI detect_start
	JMP extra

detect_start
	;JMP detect_splash ; uncomment when simulating the splash screen

	LDA #$FF
	LDX #$FF
	LDY #$10
detect_delay_loop
	DEC A
	BNE detect_delay_loop
	DEX
	BNE detect_delay_loop
	DEY
	BNE detect_delay_loop
detect_check_loop
	JSR inputchar
	CMP #$00
	BEQ detect_exit
	CMP #"V" ; keyboard self-test passed
	BEQ detect_splash
	JMP detect_check_loop
detect_exit
	LDA #$00 ; from reset
	JMP $FFE0 ; jump to other bank
detect_splash
	JSR splash
	LDA #$00 ; from reset
	JMP $FFE0 ; jump to other bank


game_initialize
	STZ sub_write+1
	LDA #$08
	STA sub_write+2
game_init_loop
	LDA #$AA ; fill color
	JSR sub_write
	INC sub_write+1
	LDA sub_write+1
	CMP #$38
	BEQ game_init_loop_inc1
	CMP #$B8
	BEQ game_init_loop_inc2
	JMP game_init_loop
game_init_loop_inc1
	LDA #$80
	STA sub_write+1
	JMP game_init_loop
game_init_loop_inc2
	STZ sub_write+1
	INC sub_write+2
	LDA sub_write+2
	CMP #$80
	BNE game_init_loop

game_random
	CLC
	JSR basic_sub_random
	AND #%00011100
	BEQ game_initialize
	STA game_piece_next
	STZ game_score_low
	STZ game_score_high
	STZ game_cycle
	LDA #$FF
	STA game_speed
	LDX #$00
game_field_loop
	STZ game_field,X
	INX
	BNE game_field_loop

game_start
	CLC
	JSR basic_sub_random
	AND #%00011100
	BEQ game_start
	PHA
	LDA game_piece_next
	STA game_piece
	PLA
	STA game_piece_next
	LDA #$06 
	STA game_location
	JSR game_display
	JSR game_clear
	JSR game_place
	JSR game_draw
	LDX #$00
game_loop
	INX
	BNE game_continue
	INC game_cycle
	LDA game_cycle
	CMP game_speed 
	BEQ game_down
	JMP game_loop
game_continue
	JSR inputchar
	CMP #$00 ; needed
	BEQ game_loop
	PHA
	CLC
	JSR basic_sub_random ; to add some randomization
	PLA
	CMP #$1F ; F4
	BNE game_next1
	LDA key_alt_control
	BEQ game_next1
	LDA #$80 ; from main_start
	JMP $FFE0 ; switch banks
game_next1
	CMP #$0C ; F5
	BNE game_next2
	LDA key_alt_control
	BEQ game_next2
	JMP game_initialize
game_next2
	CMP #"w" ; up
	BEQ game_up
	CMP #"W"
	BEQ game_up
	CMP #$11 ; arrow up
	BEQ game_up
	CMP #"8"
	BEQ game_up
	JMP game_controls1
game_up
	LDX #$00
	STZ game_cycle
	JMP game_controls11
game_controls1
	CMP #"s" ; down
	BEQ game_down
	CMP #"S"
	BEQ game_down
	CMP #$12 ; arrow down
	BEQ game_down
	CMP #"2"
	BEQ game_down
	JMP game_controls3
game_down
	LDX #$00
	STZ game_cycle
	LDA game_location
	CLC
	ADC #$10
	STA game_location
	JSR game_clear
	JSR game_place
	CMP #$FF ; error
	BEQ game_controls2
	JMP game_controls11
game_controls2
	LDA game_location
	SEC
	SBC #$10
	STA game_location
	JSR game_clear
	JSR game_place
	JSR game_solid
	JSR game_lines
	JSR game_display
	JSR game_draw
	JMP game_start
game_controls3
	CMP #"a" ; left
	BEQ game_left
	CMP #"A"
	BEQ game_left
	CMP #$13 ; arrow left
	BEQ game_left
	CMP #"4"
	BEQ game_left
	JMP game_controls5
game_left
	DEC game_location
	JSR game_clear
	JSR game_place
	CMP #$FF ; error
	BEQ game_controls4
	JMP game_controls11
game_controls4
	INC game_location
	JSR game_clear
	JSR game_place
	JMP game_controls11
game_controls5
	CMP #"d" ; right
	BEQ game_right
	CMP #"D"
	BEQ game_right
	CMP #$14 ; arrow right
	BEQ game_right
	CMP #"6"
	BEQ game_right
	JMP game_controls7
game_right
	INC game_location
	JSR game_clear
	JSR game_place
	CMP #$FF ; error
	BEQ game_controls6
	JMP game_controls11
game_controls6
	DEC game_location
	JSR game_clear
	JSR game_place
	JMP game_controls11
game_controls7
	CMP #"q" ; rotate ccw
	BEQ game_rotate_ccw
	CMP #"Q"
	BEQ game_rotate_ccw
	CMP #$20 ; space
	BEQ game_rotate_ccw
	CMP #"7"
	BEQ game_rotate_ccw
	JMP game_controls9
game_rotate_ccw
	LDA game_piece
	TAY
	PHA
	AND #%00011100
	STA game_piece
	PLA
	INC A
	AND #%00000011
	ORA game_piece
	STA game_piece
	JSR game_clear
	JSR game_place
	CMP #$FF ; error
	BEQ game_controls8
	JMP game_controls11
game_controls8
	STY game_piece
	JSR game_clear
	JSR game_place
	JMP game_controls11
game_controls9
	CMP #"e" ; rotate cw
	BEQ game_rotate_cw
	CMP #"E"
	BEQ game_rotate_cw
	CMP #"0" ; rotate cw
	BEQ game_rotate_cw
	CMP #"9"
	BEQ game_rotate_cw
	JMP game_controls11
game_rotate_cw
	LDA game_piece
	TAY
	PHA
	AND #%00011100
	STA game_piece
	PLA
	DEC A
	AND #%00000011
	ORA game_piece
	STA game_piece
	JSR game_clear
	JSR game_place
	CMP #$FF ; error
	BEQ game_controls10
	JMP game_controls11
game_controls10
	STY game_piece
	JSR game_clear
	JSR game_place
game_controls11
	JSR game_draw
	JMP game_loop


game_clear
	PHA
	PHX
	LDX #$00
game_clear_loop
	LDA game_field,X
	CMP #$FF
	BNE game_clear_increment
	STZ game_field,X
game_clear_increment
	INX
	BNE game_clear_loop
	PLX
	PLA
	RTS


game_place
	STZ game_overscan
	PHX
	PHY
	LDA game_piece
	AND #%00011111
	CLC
	ROL A
	ROL A
	ROL A
	ROL A
	TAX
	BCS game_place_second
	LDA #<game_piece_data_first
	STA sub_index+1
	LDA #>game_piece_data_first
	STA sub_index+2
	JMP game_place_ready
game_place_second
	LDA #<game_piece_data_second
	STA sub_index+1
	LDA #>game_piece_data_second
	STA sub_index+2
game_place_ready
	LDY game_location
	STZ command_addr1_high
	STZ command_addr1_low
game_place_loop
	JSR sub_index
	CMP #$00 ; needed
	BEQ game_place_skip
	LDA game_overscan
	BNE game_place_error
	TYA
	AND #%00001111
	CLC
	CMP #$03
	BCC game_place_error
	CLC
	CMP #$0D
	BCS game_place_error	
	LDA game_field,Y
	BEQ game_place_write
game_place_error
	PLY
	PLX
	LDA #$FF ; error
	RTS
game_place_write
	JSR sub_index
	STA game_field,Y
game_place_skip
	INX
	INY
	INC command_addr1_low
	LDA command_addr1_low
	CMP #$04
	BNE game_place_loop
	TYA
	CLC
	ADC #$0C
	ROL game_overscan
	TAY
	STZ command_addr1_low
	INC command_addr1_high
	LDA command_addr1_high
	CMP #$04
	BNE game_place_loop
	PLY
	PLX
	LDA #$00 ; good
	RTS


game_solid
	PHA
	PHX
	LDX #$00
game_solid_loop
	LDA game_field,X
	CMP #$FF
	BNE game_solid_increment
	LDA #$55 ; blue
	STA game_field,X
game_solid_increment
	INX
	BNE game_solid_loop
	LDA #$00 ; clear
	JSR easter_egg
	PLX
	PLA
	RTS


game_lines
	STZ command_data
	PHA
	PHX
	PHY
	LDX #$00
	LDY #$00
game_lines_loop
	LDA game_field,X
	CMP #$55 ; blue
	BNE game_lines_check
	INY
game_lines_check
	TXA
	AND #%00001111
	CMP #$0F
	BNE game_lines_increment
	CPY #$0A ; 10 columns
	BEQ game_lines_remove
	LDY #$00
	JMP game_lines_increment
game_lines_remove
	INC command_data
	INC game_score_low
	LDA game_score_low
	AND #%00001111
	BNE game_lines_remove_score
	LDA game_speed
	SEC
	SBC #$10
	STA game_speed
	INC game_score_high
game_lines_remove_score
	TXA
	AND #%11110000
	TAX
game_lines_remove_loop
	STZ game_field,X
	INX
	TXA
	AND #%00001111
	CMP #$0F
	BNE game_lines_remove_loop
	PHX
	TXA
	SEC
	SBC #$10
	TAY
game_lines_remove_shift
	LDA game_field,Y
	STA game_field,X
	DEX
	DEY
	BNE game_lines_remove_shift
	LDX #$00
game_lines_remove_clear
	STZ game_field,X
	INX
	TXA
	AND #%00001111
	CMP #$0F
	BNE game_lines_remove_clear
	PLX
	LDY #$00
game_lines_increment
	INX
	BNE game_lines_loop
	LDA command_data
	BEQ game_lines_exit
	CMP #$04
	BNE game_lines_exit
	LDA #$FF ; draw
	JSR easter_egg	
game_lines_exit
	PLY
	PLX
	PLA
	RTS


game_draw	
	PHA
	PHX
	PHY
	LDA #$08 ; start of playfield
	STA sub_write+1
	LDA #$08
	STA sub_write+2
	LDX #$00
	LDY #$00
game_draw_loop
	TXA
	AND #%00001111
	CLC	
	CMP #$03
	BCC game_draw_jump
	CLC	
	CMP #$0D
	BCS game_draw_jump
	JMP game_draw_continue
game_draw_jump
	JMP game_draw_increment
game_draw_continue
	LDA game_field,X
	CPY #$00
	BNE game_draw_corner1
	AND #%01010101
	JMP game_draw_corner2
game_draw_corner1
	AND #%01111111
game_draw_corner2
	JSR sub_write
	INC sub_write+1
	LDA game_field,X
	CPY #$00
	BNE game_draw_normal
	AND #%01010101
game_draw_normal
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
	LDA game_field,X
	AND #%01111111
	JSR sub_write
	INC sub_write+1
	LDA game_field,X
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
	BNE game_draw_loop
	LDY #$00
	LDA sub_write+2
	SEC
	SBC #$07
	STA sub_write+2
	LDA sub_write+1
	CLC
	ADC #$04
	STA sub_write+1
game_draw_increment
	INX
	BEQ game_draw_exit
	TXA
	AND #%00001111
	BEQ game_draw_shift
	JMP game_draw_loop
game_draw_shift
	LDA #$08 ; start of playfield
	STA sub_write+1
	LDA sub_write+2
	CLC
	ADC #$07 ; change this
	STA sub_write+2
	JMP game_draw_loop
game_draw_exit
	PLY
	PLX
	PLA
	RTS


game_display
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
	LDX game_score_high
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
	LDX game_score_low
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
	LDA game_piece_next
	AND #%00011100
	ROR A
	ROR A
	CMP #$01 ; I
	BNE game_display_next1
	LDA #"I"
	JMP game_display_exit
game_display_next1
	CMP #$02 ; J
	BNE game_display_next2
	LDA #"J"
	JMP game_display_exit
game_display_next2
	CMP #$03 ; L
	BNE game_display_next3
	LDA #"L"
	JMP game_display_exit
game_display_next3
	CMP #$04 ; O
	BNE game_display_next4
	LDA #"O"
	JMP game_display_exit
game_display_next4
	CMP #$05 ; S
	BNE game_display_next5
	LDA #"S"
	JMP game_display_exit
game_display_next5
	CMP #$06 ; T
	BNE game_display_next6
	LDA #"T"
	JMP game_display_exit
game_display_next6
	CMP #$07 ; Z
	BNE game_display_next7
	LDA #"Z"
	JMP game_display_exit
game_display_next7
	NOP
game_display_exit
	JSR printchar

	LDA #$3A
	STA printchar_x
	LDA #$68
	STA printchar_y
	LDA #"C"
	JSR printchar
	LDA #"t"
	JSR printchar
	LDA #"r"
	JSR printchar
	LDA #"l"
	JSR printchar
	LDA #"+"
	JSR printchar
	LDA #"F"
	JSR printchar
	LDA #"5"
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
	LDA #"C"
	JSR printchar
	LDA #"t"
	JSR printchar
	LDA #"r"
	JSR printchar
	LDA #"l"
	JSR printchar
	LDA #"+"
	JSR printchar
	LDA #"F"
	JSR printchar
	LDA #"4"
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


splash
	LDA #<splash_start
	STA sub_read+1
	LDA #>splash_start
	STA sub_read+2
	LDA #$10
	STA sub_write+1
	LDA #$2A ; was $28
	STA sub_write+2
splash_loop
	JSR sub_read
	JSR sub_write
	INC sub_read+1
	BNE splash_next
	INC sub_read+2
splash_next
	LDA sub_read+2
	CMP #>splash_end
	BNE splash_increment
	LDA sub_read+1
	CMP #<splash_end
	BNE splash_increment
	JMP splash_colors
splash_increment
	INC sub_write+1
	LDA sub_write+1
	CMP #$38
	BNE splash_check
	LDA #$90
	STA sub_write+1
	JMP splash_loop
splash_check
	CMP #$B8
	BNE splash_loop
	INC sub_write+2
	LDA #$10
	STA sub_write+1
	JMP splash_loop	

splash_colors
	LDX #$00
	LDY #$00
	STZ command_temp
	STZ sub_write+1
	LDA #$58
	STA sub_write+2
splash_clear					; this clears the screen, then displays the
	LDA sub_write+2				; splash image in the center of the screen
	CLC	
	CMP #$58
	BCS splash_ready
	JMP splash_black
splash_ready
	CLC
	CMP #$64
	BCC splash_detail
	CLC
	CMP #$6C
	BCS splash_detail
	LDA sub_write+1
	CLC
	CMP #$10
	BCC splash_black
	CLC
	CMP #$1C
	BEQ splash_left
	BCC splash_white
	CLC
	CMP #$2C
	BEQ splash_right
	BCC splash_orange
	CLC
	CMP #$38
	BCC splash_white
	CLC
	CMP #$90
	BCC splash_black
	CLC
	CMP #$9C
	BEQ splash_left
	BCC splash_white
	CLC
	CMP #$AC
	BEQ splash_right
	BCC splash_orange
	CLC
	CMP #$B8
	BCC splash_white
	JMP splash_black
splash_detail
	LDA sub_write+1	
	CLC	
	CMP #$10
	BCC splash_black
	CLC	
	CMP #$22
	BEQ splash_left
	BCC splash_white
	CLC
	CMP #$26
	BEQ splash_right
	BCC splash_orange
	CLC
	CMP #$38
	BCC splash_white
	CLC
	CMP #$90
	BCC splash_black
	CLC
	CMP #$A2
	BEQ splash_left
	BCC splash_white
	CLC
	CMP #$A6
	BEQ splash_right
	BCC splash_orange
	CLC
	CMP #$B8
	BCC splash_white
	JMP splash_black
splash_left
	LDA #$2A
	JMP splash_display
splash_right
	LDA #$3F
	JMP splash_display
splash_white
	LDA #$FF
	JMP splash_display
splash_orange
	LDA #$AA
	JMP splash_display
splash_black
	LDA #$00
splash_display
	JSR sub_write
	INC sub_write+1
	BEQ splash_add1
	JMP splash_clear
splash_add1
	INC sub_write+2
	LDA sub_write+2
	CMP #$80
	BEQ splash_add2
	JMP splash_clear
splash_add2
	NOP
splash_text
	LDA #$14
	STA printchar_x
	LDA #$14
	STA printchar_y
	LDX #$00				; display splash screen
	JMP splash_display_loop1
splash_display_text1
	.BYTE "Acolyte "
	.BYTE "Computer"
splash_display_loop1
	LDA splash_display_text1,X
	JSR printchar
	INX
	CPX #$10
	BNE splash_display_loop1
	LDA #$18
	STA printchar_x
	LDA #$1C
	STA printchar_y
	LDX #$00
	JMP splash_display_loop2
splash_display_text2
	.BYTE "ESC to S"
	.BYTE "tart"
splash_display_loop2
	LDA splash_display_text2,X
	JSR printchar
	INX
	CPX #$0C
	BNE splash_display_loop2
splash_wait
	NOP
splash_tune
	LDX #$00
splash_tune_loop
	LDA splash_music,X
	BEQ splash_tune
	JSR tune
	LDA #$00
	JSR tune
	INX						
	JSR inputchar				; this is the loop where we wait for a keypress on splash screen
	CMP #$00 ; needed!			; get keyboard state, exit only on Escape.
	BEQ splash_tune_loop
	CMP #$1B ; escape
	BEQ splash_exit
	CMP #$1F ; F4
	BEQ splash_easter_egg
	CMP #$15 ; F12
	BNE splash_tune_loop
	LDA #$A5
	JMP easter_egg 				; needs a JMP here, because we are not coming back
splash_easter_egg
	LDA #$FF
	JSR easter_egg
	JMP splash_tune_loop
splash_exit
	RTS



; this could be replaced with something else
; just remember to RTS at the end!

easter_egg
	CMP #$A5
	BNE easter_egg_continue
	JMP credits
easter_egg_continue
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

credits
	STZ sub_write+1				; clear out all system and screen RAM 
	LDA #$08
	STA sub_write+2
credits_clear_loop
	LDA #$00 ; fill color
	JSR sub_write
	INC sub_write+1
	BNE credits_clear_loop
	INC sub_write+2
	LDA sub_write+2
	CMP #$80
	BNE credits_clear_loop	
credits_display
	LDA #$04
	STA printchar_x
	LDA #$10
	STA printchar_y
	LDA #<credits_text
	STA command_addr3_low
	LDA #>credits_text
	STA command_addr3_high
credits_display_loop
	LDA command_addr3_low
	STA sub_read+1
	LDA command_addr3_high
	STA sub_read+2
	JSR sub_read
	CMP #$FF
	BEQ credits_display_wait
	CMP #$0D ; carriage return
	BNE credits_display_char
	LDA #$04
	STA printchar_x
	LDA printchar_y
	CLC
	ADC #$04
	STA printchar_y
	LDA #$00
credits_display_char
	JSR printchar
	INC command_addr3_low
	BNE credits_display_loop
	INC command_addr3_high
	JMP credits_display_loop
credits_display_wait
	JSR inputchar
	CMP #$00
	BEQ credits_display_wait
	CMP #$1B ; escape
	BEQ credits_display_exit
	JMP credits_display_wait	
credits_display_exit
	RTS

credits_text
	.BYTE "Acolyte "
	.BYTE "Computer"
	.BYTE ", 2022"
	.BYTE $0D,$0D
	.BYTE "Designer"
	.BYTE " & Progr"
	.BYTE "ammer",$3A,$0D
	.BYTE "Professo"
	.BYTE "r Steven"
	.BYTE " Chad Bu"
	.BYTE "rrow",$0D,$0D
	.BYTE "Garth Wi"
	.BYTE "lson's 6"
	.BYTE "502 Prim"
	.BYTE "er at",$0D
	.BYTE "wilsonmi"
	.BYTE "nesco.co"
	.BYTE "m",$0D,$0D
	.BYTE "Join the"
	.BYTE " Forum a"
	.BYTE "t",$0D
	.BYTE "6502.org"
	.BYTE $0D,$0D
	.BYTE "Thanks",$3A,$0D
	.BYTE "Rebecca,"
	.BYTE " Lizzie,"
	.BYTE " Nate, &"
	.BYTE " Ben",$0D
	.BYTE "Garth Wi"
	.BYTE "lson & B"
	.BYTE "ill Shen"
	.BYTE " (plasmo"
	.BYTE ")",$0D
	.BYTE "Dr Jefyl"
	.BYTE ", BDD, B"
	.BYTE "igEd, & "
	.BYTE "gfoot"
	.BYTE $0D
	.BYTE "D.Murray"
	.BYTE ", A.Blac"
	.BYTE "k, & B.E"
	.BYTE "ater",$0D
	.BYTE $0D,$0D
	.BYTE "John 3",$3A
	.BYTE "16",$0D
;	.BYTE "For God "
;	.BYTE "so loved"
;	.BYTE " the wor"
;	.BYTE "ld, that"
;	.BYTE $0D
;	.BYTE "He gave "
;	.BYTE "His only"
;	.BYTE " begotte"
;	.BYTE "n Son"
;	.BYTE $0D
;	.BYTE "[Jesus],"
;	.BYTE " that wh"
;	.BYTE "osoever "
;	.BYTE "believet"
;	.BYTE "h"
;	.BYTE $0D
;	.BYTE "in Him s"
;	.BYTE "hould no"
;	.BYTE "t perish"
;	.BYTE ", but"
;	.BYTE $0D
;	.BYTE "have eve"
;	.BYTE "rlasting"
;	.BYTE " life."
	.BYTE $FF

	
	.ORG $CFD0

	.BYTE "Professo"
	.BYTE "r Steven"
	.BYTE "Chad Bur"
	.BYTE "row 2023"
	.BYTE ", Public"
	.BYTE " Domain",$00

	.ORG $D000


; image in 4-colors with 160x100 resolution
; this will be centered on the screen upon (re)boot
splash_start
	.BYTE $00,$00,$00,$00,$00,$AA,$A0,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$0A,$AA,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$2A,$AA,$AA,$80
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $02,$AA,$AA,$A8,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$AA,$80,$2A,$A0
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $0A,$A8,$02,$AA,$00,$00,$00,$00
	.BYTE $00,$00,$00,$02,$A0,$00,$00,$A8
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $2A,$00,$00,$0A,$80,$00,$00,$00
	.BYTE $00,$00,$00,$0A,$80,$02,$00,$2A
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $A8,$00,$20,$02,$A0,$00,$00,$00
	.BYTE $00,$00,$00,$2A,$00,$02,$00,$0A
	.BYTE $80,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$02
	.BYTE $A0,$00,$20,$00,$A8,$00,$00,$00
	.BYTE $00,$00,$00,$28,$00,$0A,$00,$02
	.BYTE $80,$00,$00,$00,$00,$00,$0F,$FF
	.BYTE $FF,$FC,$00,$00,$00,$00,$15,$55
	.BYTE $00,$00,$00,$00,$00,$00,$00,$02
	.BYTE $80,$00,$A0,$00,$28,$00,$00,$00
	.BYTE $00,$00,$00,$A8,$00,$0A,$00,$02
	.BYTE $A0,$00,$00,$00,$00,$00,$FF,$FF
	.BYTE $FF,$FF,$FC,$00,$00,$3F,$15,$55
	.BYTE $50,$FC,$00,$00,$00,$00,$00,$0A
	.BYTE $80,$00,$A0,$00,$2A,$00,$00,$00
	.BYTE $00,$00,$00,$A0,$00,$0A,$00,$00
	.BYTE $A0,$00,$00,$00,$00,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$C0,$03,$FF,$C5,$55
	.BYTE $50,$FF,$F0,$00,$00,$00,$00,$0A
	.BYTE $00,$00,$A0,$00,$0A,$00,$00,$00
	.BYTE $00,$00,$02,$A0,$00,$0A,$80,$00
	.BYTE $A8,$00,$00,$0F,$FF,$FF,$F0,$00
	.BYTE $0F,$FF,$FF,$FC,$0F,$FF,$C1,$55
	.BYTE $54,$3F,$FF,$FF,$F0,$00,$00,$2A
	.BYTE $00,$00,$A8,$00,$0A,$80,$00,$00
	.BYTE $00,$00,$02,$80,$00,$2A,$A0,$00
	.BYTE $28,$00,$00,$3F,$FF,$FF,$F1,$55
	.BYTE $0F,$FF,$FF,$FC,$3F,$FF,$F0,$55
	.BYTE $54,$3F,$FF,$FF,$FC,$00,$00,$28
	.BYTE $00,$02,$AA,$00,$02,$80,$00,$00
	.BYTE $00,$00,$02,$80,$00,$AA,$A0,$00
	.BYTE $28,$00,$00,$3F,$FF,$FF,$C1,$55
	.BYTE $0F,$FF,$FF,$FC,$3F,$FF,$F0,$15
	.BYTE $55,$0F,$FF,$FF,$FC,$00,$00,$28
	.BYTE $00,$0A,$AA,$00,$02,$80,$00,$00
	.BYTE $00,$00,$02,$80,$00,$AA,$A0,$00
	.BYTE $28,$00,$00,$FF,$FF,$FF,$C1,$55
	.BYTE $3F,$FF,$FF,$FC,$3F,$FF,$FC,$15
	.BYTE $55,$4F,$FF,$FF,$FC,$00,$00,$28
	.BYTE $00,$0A,$AA,$00,$02,$80,$00,$00
	.BYTE $00,$00,$02,$80,$00,$AA,$A0,$00
	.BYTE $28,$00,$00,$FF,$FF,$FF,$05,$54
	.BYTE $3F,$FF,$FF,$FC,$3F,$FF,$FF,$05
	.BYTE $55,$43,$FF,$FF,$FF,$00,$00,$28
	.BYTE $00,$0A,$AA,$00,$02,$80,$00,$00
	.BYTE $00,$00,$02,$80,$00,$AA,$A0,$00
	.BYTE $28,$00,$00,$FF,$FF,$FF,$05,$54
	.BYTE $3F,$FF,$FF,$FC,$3F,$FF,$FF,$05
	.BYTE $55,$53,$FF,$FF,$FF,$00,$00,$28
	.BYTE $00,$0A,$AA,$00,$02,$80,$00,$00
	.BYTE $00,$00,$02,$80,$00,$AA,$A0,$00
	.BYTE $28,$00,$03,$FF,$F0,$00,$15,$54
	.BYTE $00,$03,$FF,$FC,$3F,$FF,$FF,$C1
	.BYTE $55,$53,$FF,$FF,$FF,$C0,$00,$28
	.BYTE $00,$0A,$AA,$00,$02,$80,$00,$00
	.BYTE $00,$00,$02,$A0,$00,$AA,$A0,$00
	.BYTE $A0,$00,$03,$FF,$C1,$55,$55,$55
	.BYTE $55,$53,$FF,$FC,$3F,$FF,$FF,$C1
	.BYTE $55,$53,$FF,$FF,$FF,$C0,$00,$2A
	.BYTE $00,$0A,$AA,$00,$0A,$80,$00,$00
	.BYTE $00,$00,$00,$A0,$00,$2A,$80,$00
	.BYTE $A0,$00,$03,$FF,$C5,$55,$55,$55
	.BYTE $55,$53,$FF,$FC,$3F,$FF,$FF,$F1
	.BYTE $55,$54,$FF,$FF,$FF,$C0,$00,$0A
	.BYTE $00,$02,$A8,$00,$0A,$00,$00,$00
	.BYTE $00,$00,$00,$A8,$00,$02,$00,$02
	.BYTE $A0,$00,$0F,$FF,$15,$55,$55,$55
	.BYTE $55,$4F,$FF,$FC,$3F,$FF,$FF,$F0
	.BYTE $55,$54,$FF,$FF,$FF,$F0,$00,$0A
	.BYTE $80,$00,$20,$00,$2A,$00,$00,$00
	.BYTE $00,$00,$00,$28,$00,$00,$00,$02
	.BYTE $80,$00,$0F,$FF,$15,$55,$55,$55
	.BYTE $55,$4F,$FF,$FC,$3F,$FF,$FF,$F0
	.BYTE $55,$54,$FF,$FF,$FF,$F0,$00,$02
	.BYTE $80,$00,$00,$00,$28,$00,$00,$00
	.BYTE $00,$00,$00,$2A,$00,$00,$00,$0A
	.BYTE $80,$00,$3F,$FF,$00,$00,$55,$40
	.BYTE $00,$0F,$FF,$FC,$3F,$FF,$FF,$F0
	.BYTE $55,$55,$3F,$FF,$FF,$FC,$00,$02
	.BYTE $A0,$00,$00,$00,$A8,$00,$00,$00
	.BYTE $00,$00,$00,$0A,$80,$00,$00,$2A
	.BYTE $00,$00,$3F,$FF,$FF,$F0,$55,$43
	.BYTE $FF,$FF,$FF,$FC,$3F,$FF,$FF,$FC
	.BYTE $15,$05,$0F,$FF,$FF,$FC,$00,$00
	.BYTE $A8,$00,$00,$02,$A0,$00,$00,$00
	.BYTE $00,$00,$00,$02,$A0,$00,$00,$A8
	.BYTE $00,$00,$3F,$FF,$FF,$F1,$55,$43
	.BYTE $FF,$FF,$FF,$FC,$3F,$FF,$FF,$FC
	.BYTE $14,$01,$4F,$FF,$FF,$FC,$00,$00
	.BYTE $2A,$00,$00,$0A,$80,$00,$00,$00
	.BYTE $00,$00,$00,$00,$A0,$FF,$C2,$A0
	.BYTE $00,$00,$FF,$FF,$FF,$F1,$55,$0F
	.BYTE $FF,$FF,$FF,$FC,$3F,$FF,$FF,$FC
	.BYTE $14,$F0,$03,$FF,$FF,$FF,$00,$00
	.BYTE $0A,$0F,$FC,$2A,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$20,$FF,$C2,$80
	.BYTE $00,$00,$FF,$FF,$FF,$C1,$55,$0F
	.BYTE $FF,$FF,$FF,$FC,$3F,$FF,$FF,$FF
	.BYTE $04,$FF,$03,$FF,$FF,$FF,$00,$00
	.BYTE $02,$0F,$FC,$28,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$FF,$C0,$00
	.BYTE $00,$03,$FF,$FF,$FF,$C1,$55,$0F
	.BYTE $FF,$FF,$FF,$FC,$3F,$FF,$FF,$FF
	.BYTE $00,$FF,$C0,$FF,$FF,$FF,$00,$00
	.BYTE $00,$0F,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$FF,$C0,$00
	.BYTE $00,$03,$FF,$FF,$FF,$C5,$55,$3F
	.BYTE $FF,$FF,$FF,$FC,$3F,$FF,$FF,$FF
	.BYTE $C0,$FF,$FC,$FF,$FF,$FF,$C0,$00
	.BYTE $00,$0F,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$FF,$C0,$00
	.BYTE $00,$03,$FF,$FF,$FF,$C5,$54,$3F
	.BYTE $FF,$FF,$FF,$FC,$3F,$FF,$FF,$FF
	.BYTE $F0,$FF,$FF,$FF,$FF,$FF,$F0,$00
	.BYTE $00,$0F,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$FF,$C0,$00
	.BYTE $00,$0F,$FF,$FF,$FF,$C5,$54,$3F
	.BYTE $FF,$FF,$FF,$FC,$3F,$FF,$FF,$FF
	.BYTE $FC,$FF,$FF,$FF,$FF,$FF,$F0,$00
	.BYTE $00,$0F,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$FF,$C0,$00
	.BYTE $00,$0F,$FF,$FF,$FF,$05,$54,$3F
	.BYTE $FF,$FF,$FF,$FC,$3F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$F0,$00
	.BYTE $00,$0F,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$FF,$C0,$00
	.BYTE $00,$0F,$FF,$00,$00,$00,$00,$3F
	.BYTE $FF,$FF,$FF,$FC,$3F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FC,$00
	.BYTE $00,$0F,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$FF,$C0,$00
	.BYTE $00,$3F,$C0,$00,$00,$00,$00,$0F
	.BYTE $FF,$FF,$FF,$FC,$3F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FC,$00
	.BYTE $00,$0F,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$FF,$C0,$00
	.BYTE $00,$3C,$00,$AA,$AA,$AA,$AA,$03
	.BYTE $FF,$FF,$FF,$FC,$3F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FC,$00
	.BYTE $00,$0F,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$FF,$C0,$FF
	.BYTE $FC,$FC,$0A,$AA,$AA,$AA,$AA,$83
	.BYTE $FF,$FF,$FF,$FC,$3F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$3F
	.BYTE $FC,$0F,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$FF,$C0,$FF
	.BYTE $F0,$FC,$0A,$AA,$AA,$AA,$AA,$03
	.BYTE $FF,$FF,$FF,$FC,$3F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$3F
	.BYTE $FF,$0F,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$FF,$C3,$FF
	.BYTE $F0,$FF,$00,$00,$00,$00,$00,$00
	.BYTE $3F,$FF,$FF,$FC,$3F,$FF,$FF,$FC
	.BYTE $00,$00,$3F,$FF,$FF,$FF,$FF,$CF
	.BYTE $FF,$0F,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$FF,$C3,$FF
	.BYTE $C3,$FF,$0A,$00,$00,$00,$02,$80
	.BYTE $00,$03,$FF,$FC,$3F,$FF,$C0,$00
	.BYTE $00,$00,$00,$0F,$FF,$FF,$FF,$CF
	.BYTE $FF,$0F,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$FF,$C3,$FF
	.BYTE $C0,$3F,$0A,$AA,$AA,$AA,$AA,$83
	.BYTE $FF,$00,$0F,$FC,$3F,$FC,$03,$FF
	.BYTE $FF,$FF,$F0,$00,$0F,$FF,$FC,$03
	.BYTE $FF,$0F,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$FF,$C3,$FF
	.BYTE $F0,$00,$0A,$AA,$AA,$AA,$AA,$83
	.BYTE $FF,$F0,$00,$3C,$3F,$00,$3F,$FF
	.BYTE $FF,$FF,$FF,$FF,$00,$00,$00,$0F
	.BYTE $FF,$0F,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$FF,$C3,$FF
	.BYTE $FC,$00,$0A,$AA,$AA,$AA,$AA,$83
	.BYTE $FF,$FF,$C0,$00,$00,$03,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$00,$00,$3F
	.BYTE $FF,$0F,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$FF,$C3,$FF
	.BYTE $FF,$00,$0A,$AA,$AA,$AA,$AA,$80
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$FF
	.BYTE $FF,$0F,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$FF,$C3,$FF
	.BYTE $FF,$00,$0A,$AA,$AA,$AA,$AA,$80
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$03,$FF
	.BYTE $FF,$0F,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$FF,$C3,$FF
	.BYTE $FC,$04,$0A,$AA,$AA,$AA,$AA,$80
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$0F,$FF
	.BYTE $FF,$0F,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$FF,$C3,$FF
	.BYTE $FC,$15,$0A,$AA,$AA,$AA,$AA,$80
	.BYTE $00,$00,$00,$00,$00,$00,$00,$AA
	.BYTE $AA,$AA,$00,$00,$00,$00,$4F,$FF
	.BYTE $FF,$0F,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$FF,$C3,$FF
	.BYTE $F0,$55,$82,$AA,$AA,$AA,$AA,$00
	.BYTE $00,$00,$00,$00,$00,$00,$2A,$AA
	.BYTE $AA,$AA,$A8,$00,$00,$01,$43,$FF
	.BYTE $FF,$0F,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$FF,$C3,$FF
	.BYTE $C0,$56,$82,$AA,$AA,$AA,$AA,$00
	.BYTE $00,$00,$00,$00,$00,$0A,$AA,$AA
	.BYTE $AA,$AA,$AA,$00,$00,$01,$50,$FF
	.BYTE $FF,$0F,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$FF,$C3,$FF
	.BYTE $C1,$56,$80,$AA,$AA,$AA,$A8,$00
	.BYTE $00,$00,$00,$00,$00,$AA,$AA,$A0
	.BYTE $00,$2A,$AA,$A0,$00,$0A,$54,$FF
	.BYTE $FF,$0F,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$FF,$C3,$FF
	.BYTE $05,$5A,$50,$2A,$AA,$AA,$A8,$15
	.BYTE $55,$55,$55,$54,$02,$AA,$AA,$0A
	.BYTE $AA,$AA,$AA,$A8,$1A,$5A,$95,$3F
	.BYTE $FF,$0F,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$FF,$C3,$FC
	.BYTE $05,$6A,$68,$0A,$AA,$AA,$A0,$55
	.BYTE $55,$55,$55,$54,$0A,$AA,$A8,$AA
	.BYTE $AA,$AA,$AA,$A8,$06,$96,$95,$0F
	.BYTE $FF,$0F,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$FF,$C3,$FC
	.BYTE $15,$69,$69,$02,$AA,$AA,$81,$55
	.BYTE $55,$55,$55,$50,$2A,$AA,$8A,$AA
	.BYTE $AA,$AA,$AA,$AA,$06,$A5,$A5,$43
	.BYTE $FF,$0F,$FC,$30,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$30,$FF,$C3,$F0
	.BYTE $55,$A5,$A5,$40,$AA,$A8,$15,$55
	.BYTE $55,$55,$55,$40,$AA,$AA,$2A,$AA
	.BYTE $AA,$AA,$AA,$AA,$01,$A5,$A9,$50
	.BYTE $FF,$0F,$FC,$3C,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$F0,$FF,$C0,$C0
	.BYTE $56,$A6,$A5,$54,$0A,$A0,$55,$55
	.BYTE $55,$55,$55,$42,$AA,$A8,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$81,$69,$6A,$54
	.BYTE $30,$0F,$FC,$0C,$00,$00,$00,$00
	.BYTE $00,$00,$00,$03,$00,$FF,$C0,$01
	.BYTE $56,$96,$95,$55,$0A,$81,$55,$55
	.BYTE $55,$55,$55,$02,$AA,$A2,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$A0,$5A,$5A,$55
	.BYTE $00,$0F,$FC,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$0C,$20,$3F,$C0,$A1
	.BYTE $5A,$5A,$55,$55,$0A,$81,$55,$55
	.BYTE $55,$55,$55,$0A,$AA,$0A,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$A0,$1A,$96,$95
	.BYTE $0A,$83,$FC,$2A,$00,$00,$00,$00
	.BYTE $00,$00,$00,$0C,$AA,$80,$0A,$A1
	.BYTE $6A,$6A,$55,$55,$0A,$81,$55,$55
	.BYTE $55,$55,$55,$0A,$AA,$2A,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$A8,$16,$A6,$A5
	.BYTE $4A,$A0,$02,$AA,$00,$00,$00,$00
	.BYTE $00,$00,$00,$3C,$2A,$AA,$AA,$01
	.BYTE $69,$69,$55,$55,$0A,$81,$55,$55
	.BYTE $55,$55,$54,$0A,$A8,$2A,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$A8,$15,$A5,$A9
	.BYTE $42,$AA,$AA,$A0,$30,$00,$00,$00
	.BYTE $00,$00,$00,$FF,$02,$AA,$A0,$05
	.BYTE $A5,$A5,$55,$55,$0A,$81,$55,$55
	.BYTE $55,$55,$54,$0A,$A0,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$A8,$15,$69,$69
	.BYTE $50,$2A,$AA,$80,$FC,$00,$00,$00
	.BYTE $00,$00,$00,$FF,$F0,$00,$00,$56
	.BYTE $A6,$A5,$55,$55,$0A,$80,$55,$55
	.BYTE $55,$55,$54,$0A,$A2,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$A8,$15,$6A,$5A
	.BYTE $54,$00,$00,$0F,$FF,$00,$00,$00
	.BYTE $00,$00,$03,$FF,$F0,$AA,$A1,$5A
	.BYTE $96,$95,$55,$55,$0A,$80,$55,$55
	.BYTE $55,$55,$55,$0A,$A2,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$A8,$15,$5A,$9A
	.BYTE $95,$0A,$AA,$3F,$FF,$00,$00,$00
	.BYTE $00,$00,$03,$FF,$FC,$AA,$A1,$5A
	.BYTE $5A,$55,$55,$55,$0A,$80,$55,$55
	.BYTE $55,$55,$55,$0A,$AA,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$A0,$55,$56,$96
	.BYTE $A5,$4A,$AA,$3F,$FF,$C0,$00,$00
	.BYTE $00,$00,$0F,$FF,$FC,$AA,$A0,$69
	.BYTE $6A,$55,$55,$55,$0A,$80,$15,$55
	.BYTE $55,$55,$55,$0A,$AA,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$01,$55,$55,$A5
	.BYTE $A5,$0A,$AA,$3F,$FF,$F0,$00,$00
	.BYTE $00,$00,$3F,$FF,$02,$AA,$A8,$29
	.BYTE $69,$55,$55,$40,$0A,$80,$05,$55
	.BYTE $55,$55,$55,$0A,$AA,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$A0,$05,$55,$55,$A9
	.BYTE $60,$2A,$AA,$03,$FF,$F0,$00,$00
	.BYTE $00,$00,$3F,$C0,$0A,$AA,$AA,$00
	.BYTE $25,$55,$50,$00,$AA,$AA,$00,$05
	.BYTE $55,$55,$55,$02,$AA,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$00,$15,$55,$55,$60
	.BYTE $02,$AA,$AA,$80,$03,$FC,$00,$00
	.BYTE $00,$00,$FC,$0A,$AA,$AA,$AA,$A8
	.BYTE $01,$55,$02,$AA,$AA,$AA,$AA,$80
	.BYTE $55,$55,$55,$40,$0A,$AA,$AA,$AA
	.BYTE $AA,$AA,$A0,$01,$55,$55,$55,$42
	.BYTE $AA,$AA,$AA,$AA,$A8,$3F,$00,$00
	.BYTE $00,$03,$FC,$0A,$AA,$AA,$AA,$A8
	.BYTE $01,$55,$00,$AA,$AA,$AA,$AA,$80
	.BYTE $55,$55,$55,$54,$00,$AA,$AA,$AA
	.BYTE $AA,$A8,$00,$15,$55,$55,$55,$42
	.BYTE $AA,$AA,$AA,$AA,$A8,$3F,$00,$00
	.BYTE $00,$03,$FF,$C0,$2A,$AA,$AA,$00
	.BYTE $15,$55,$50,$00,$AA,$AA,$00,$05
	.BYTE $55,$55,$55,$55,$40,$00,$00,$00
	.BYTE $00,$00,$05,$55,$55,$55,$55,$54
	.BYTE $02,$AA,$AA,$A0,$03,$FF,$C0,$00
	.BYTE $00,$0F,$FF,$FF,$C0,$00,$00,$0A
	.BYTE $55,$55,$55,$50,$00,$00,$05,$55
	.BYTE $55,$55,$55,$55,$55,$40,$00,$00
	.BYTE $00,$15,$55,$55,$55,$55,$55,$55
	.BYTE $A0,$00,$00,$00,$FF,$FF,$F0,$00
	.BYTE $00,$3F,$FF,$FF,$F0,$15,$A9,$69
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $69,$6A,$54,$0F,$FF,$FF,$F0,$00
	.BYTE $00,$3F,$FF,$FF,$C0,$55,$A5,$A5
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $5A,$5A,$95,$0F,$FF,$FF,$FC,$00
	.BYTE $00,$FF,$FF,$FF,$C1,$56,$96,$A5
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $56,$96,$95,$43,$FF,$FF,$FF,$00
	.BYTE $03,$FF,$FF,$FF,$05,$5A,$9A,$95
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $56,$A5,$A5,$40,$FF,$FF,$FF,$00
	.BYTE $03,$FF,$FF,$FC,$05,$5A,$5A,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$A5,$A9,$50,$3F,$FF,$FF,$C0
	.BYTE $0F,$FF,$FF,$FC,$15,$69,$69,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$69,$6A,$54,$3F,$FF,$FF,$F0
	.BYTE $3F,$FF,$FF,$F0,$55,$A5,$69,$54
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $55,$59,$5A,$55,$0F,$FF,$FF,$FC
	.BYTE $00,$00,$00,$00,$55,$A5,$A5,$50
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $55,$5A,$5A,$55,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$55,$A5,$A5,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$5A,$5A,$55,$00,$00,$00,$00
	.BYTE $FF,$FF,$FF,$C1,$55,$A5,$A5,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$5A,$5A,$55,$0F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$C1,$55,$A5,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
	.BYTE $AA,$AA,$5A,$55,$0F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$C1,$55,$A5,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
	.BYTE $AA,$AA,$5A,$55,$0F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$C1,$55,$A5,$55,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$55,$5A,$55,$0F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$C1,$55,$A5,$55,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$55,$5A,$55,$0F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$C1,$55,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$55,$0F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$C1,$55,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
	.BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
	.BYTE $AA,$AA,$A9,$55,$0F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$C1,$55,$55,$55,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$55,$55,$55,$0F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$C1,$55,$55,$55,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$55,$55,$55,$55,$55,$55,$55
	.BYTE $55,$55,$55,$55,$0F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$C0,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$0F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$C0,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$0F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$C1,$75,$F5,$D7,$5F
	.BYTE $5D,$75,$D7,$5D,$75,$F5,$D7,$5D
	.BYTE $75,$D7,$5D,$75,$D7,$D7,$5D,$75
	.BYTE $D7,$D7,$5D,$75,$D7,$5D,$75,$F5
	.BYTE $D7,$5D,$75,$DD,$0F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$C1,$75,$F5,$D7,$5F
	.BYTE $5D,$75,$D7,$5D,$75,$F5,$D7,$5D
	.BYTE $75,$D7,$5D,$75,$D7,$D7,$5D,$75
	.BYTE $D7,$D7,$5D,$75,$D7,$5D,$75,$F5
	.BYTE $D7,$5D,$75,$DD,$0F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$C1,$75,$F5,$D7,$5F
	.BYTE $5D,$75,$D7,$5D,$75,$F5,$D7,$5D
	.BYTE $75,$D7,$5D,$75,$D7,$D7,$5D,$75
	.BYTE $D7,$D7,$5D,$75,$D7,$5D,$75,$F5
	.BYTE $D7,$5D,$75,$DD,$0F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$C1,$75,$F5,$D7,$5F
	.BYTE $5D,$75,$D7,$5D,$75,$F5,$D7,$5D
	.BYTE $75,$D7,$5D,$75,$D7,$D7,$5D,$75
	.BYTE $D7,$D7,$5D,$75,$D7,$5D,$75,$F5
	.BYTE $D7,$5D,$75,$DD,$0F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$C1,$75,$F5,$D7,$5F
	.BYTE $5D,$75,$D7,$5D,$75,$F5,$D7,$5D
	.BYTE $75,$D7,$5D,$75,$D7,$D7,$5D,$75
	.BYTE $D7,$D7,$5D,$75,$D7,$5D,$75,$F5
	.BYTE $D7,$5D,$75,$DD,$0F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$C1,$75,$F5,$D7,$5F
	.BYTE $5D,$75,$D7,$5D,$75,$F5,$D7,$5D
	.BYTE $75,$D7,$5D,$75,$D7,$D7,$5D,$75
	.BYTE $D7,$D7,$5D,$75,$D7,$5D,$75,$F5
	.BYTE $D7,$5D,$75,$DD,$0F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$C1,$75,$F5,$D7,$5F
	.BYTE $5D,$75,$D7,$5D,$75,$F5,$D7,$5D
	.BYTE $75,$D7,$5D,$75,$D7,$D7,$5D,$75
	.BYTE $D7,$D7,$5D,$75,$D7,$5D,$75,$F5
	.BYTE $D7,$5D,$75,$DD,$0F,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
splash_end

	.ORG $DF00

; these lookup tables are to determine the frequency
; and the duration/period of any signal
; these only are for notes C3 through B6, and the first 4 are just $00
tune_freq_data
	.BYTE $00,$FF,$E3,$CA,$BE,$AA,$97,$87
	.BYTE $00,$7F,$71,$65,$5F,$55,$4B,$43
	.BYTE $00,$3F,$38,$32,$2F,$2A,$25,$21
	.BYTE $00,$1F,$1C,$19,$17,$15,$12,$10

tune_period_data
	.BYTE $00,$10,$12,$14,$15,$18,$1B,$1E
	.BYTE $00,$20,$24,$29,$2B,$31,$37,$3D
	.BYTE $00,$41,$49,$52,$57,$62,$6E,$7B
	.BYTE $00,$82,$92,$A4,$AE,$C4,$DC,$F7


;	D3, F3, G3, A3, D3, F3, E3, D3, R
;	2, 4, 2, 4, 2, 2, 4, 4, 2

;	A3, A3, B3, C4, F3, A3, G3, F3, R
;	2, 2, 2, 4, 2, 2, 4, 4, 2

;	C4, C4, C4, C4, A3, D4, D4, C4, R
;	2, 2, 2, 4, 2, 4, 2, 4, 2

;	A3, A3, G3, A3, F3, G3, E3, D3, R
;	2, 2, 2, 4, 2, 2, 4, 4, 2

;	R, R, R, 0
;	2, 2, 2, 0

splash_music
	.BYTE %00100010,%01100100,%00100101,%01100110
	.BYTE %00100010,%00100100,%01100011,%01100010
	.BYTE %00100000,%00100110,%00100110,%00100111
	.BYTE %01101001,%00100100,%00100110,%01100101
	.BYTE %01100100,%00100000,%00101001,%00101001
	.BYTE %00101001,%01101001,%00100110,%01101010
	.BYTE %00101010,%01101001,%00100000,%00100110
	.BYTE %00100110,%00100101,%01100110,%00100100
	.BYTE %00100101,%01100011,%01100010,%00100000
	.BYTE %00100000,%00100000,%00100000,%00000000

	
; A has tune to play
; this actually plays the tune, sending the signal to output bits
; there are lots of trickery going on with the bits
; bit0-bit4 are 32 bits, 7 notes in 4 octaves, 4 rests
; bit5-bit7 are durations, 000 for eighth note to 111 for whole note
tune	
	PHA
	PHX
	PHY				
	STA command_addr4_low			; holds original A value	
tune_next2
	AND #%11100000				; duration bits
	CLC
	ROR A					; shift them down
	ROR A
	ROR A
	ROR A
	ROR A
	INC A
	STA command_addr4_high			; they are now the duration of that note
tune_next3
	LDA command_addr4_low
	AND #%00011111				; note values
	TAX
	LDA tune_period_data,X			; go to lookup table for period value
	TAY					; store it in Y
	CPY #$00
	BNE tune_next4
	LDY #$10
tune_next4
	LDA output_byte
	AND #%01111111
	STA output_byte
	STA $C000				; writing to ROM will output bits
	LDA command_addr4_low
	AND #%00011111
	TAX
	LDA tune_freq_data,X			; lookup table for frequency
	TAX					; store in X
	CPX #$00
	BNE tune_next5
	LDX #$FF				; the default rest value (plays like a C3 note but without alternating PB7)
tune_next5

	LDA #$08 ; arbitrary
tune_nop1
	DEC A
	BNE tune_nop1
	
	DEX
	CPX #$FF
	BNE tune_next5
	LDA command_addr4_low
	AND #%00011111
	TAX
	LDA tune_freq_data,X			; check this lookup table (either will work) for rest values $00
	BEQ tune_next6				; if it is a rest, do not alternate PB7!
	LDA output_byte
	ORA #%10000000
	STA output_byte
	STA $C000
tune_next6
	LDA command_addr4_low
	AND #%00011111
	TAX
	LDA tune_freq_data,X			; again get frequency
	TAX					; store in X
	;CPX #$00				; removing to make the rests will be half as duration as their notes
	;BNE tune_next7
	;LDX #$FF
tune_next7
	
	LDA #$08 ; arbitrary
tune_nop2
	DEC A
	BNE tune_nop2

	DEX
	CPX #$FF
	BNE tune_next7
	DEY
	CPY #$FF
	BNE tune_next8
	DEC command_addr4_high
	LDA command_addr4_high
	BNE tune_next9				; repeat for the duration of the note (higher 3 bits)
	PLY
	PLX
	PLA
	RTS
tune_next8
	JMP tune_next4
tune_next9
	JMP tune_next3

	.ORG $E000

extra


	LDA #$02
	STA printchar_x
	LDA #$0C
	STA printchar_y
	LDA #"4"
	JSR printchar
	LDA #"K"
	JSR printchar
	LDA #"B"
	JSR printchar
	LDA #" "
	JSR printchar
	LDA #"E"
	JSR printchar
	LDA #"x"
	JSR printchar
	LDA #"t"
	JSR printchar
	LDA #"r"
	JSR printchar
	LDA #"a"
	JSR printchar
	
	LDA #$02
	STA printchar_x
	LDA #$10
	STA printchar_y
	LDA #"E"
	JSR printchar
	LDA #"S"
	JSR printchar
	LDA #"C"
	JSR printchar
	LDA #" "
	JSR printchar
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
	
extra_loop
	JSR inputchar
	CMP #$00
	BEQ extra_loop
	CMP #$1B
	BEQ extra_exit
	JMP extra_loop

extra_exit
	LDA #$80 ; from main_start
	JMP $FFE0 ; switch banks


	.ORG $F000

	
game_piece_data_first
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

game_piece_data_second
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

	
; these convert hex values into decimal values for printing
; converting user decimal values into hex is done with code
; leading zeros are omitted by printing $00 (which does nothing)
decimal_conversion_high
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,"1111"
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
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,"111111"
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
	.BYTE $00,$07,$0F,$0C,$1E,$1C,$1D,$15
	.BYTE $00,$16,$18,$0E,$1F,$09,$60,$00
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

	.BYTE $00,$07,$0F,$0C,$1E,$1C,$1D,$15
	.BYTE $00,$16,$00,$0E,$1F,$09,$7E,$00
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


	.ORG $FC00


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
	LDA key_array,X
	INC key_read
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


	.ORG $FF60


; 6502 running at 3.14 MHz,
; PS/2 keyboard running at 17 kHz
; That gives me 184 cycles between signals.


; /IRQ = Keyboard-Clock
; /NMI = Keyboard-Data NOR Keyboard-Clock


vector_irq			; 7
;	BIT via_ifr		; 4
;	BMI vector_irq_via	; 2
	PHA			; 3
	LDA key_bit		; 4
	ROR A			; 2
	ROR key_data		; 2
	LDA #$FF		; 2
	STA key_bit		; 4
	DEC key_counter		; 6
	BEQ vector_irq_store	; 2
	BMI vector_irq_reset	; 2
	LDA key_counter		; 4
	CMP #$09		; 2
	BEQ vector_irq_first	; 2
	LDA key_speed		; 4
	INC A			; 2
	INC A			; 2
	NOP			; 2
	JMP vector_irq_wait	; 3, sub-total = 61
vector_irq_reset		; 1, sub-total = 41
	LDA #$0A		; 2
	STA key_counter		; 4
	LDA key_speed		; 4
	STZ key_speed		; 4
	INC A			; 2
	INC A			; 2
	JMP vector_irq_wait	; 3, sub-total = 62
vector_irq_store		; 1, sub-total = 39
	PHX			; 3
	LDA key_data		; 4
	LDX key_write		; 4
	STA key_array,X		; 5
	INC key_write		; 6
	PLX			; 4
	LDA key_speed		; 4, sub-total = 72
vector_irq_wait
	DEC A			; 2x
	BNE vector_irq_wait	; 3x
	PLA			; 4
	RTI			; 6, store=, reset=, else=
vector_irq_first		; 1, sub-total = 49
	NOP			; 2
	NOP			; 2
	NOP			; 2
	NOP			; 2
	NOP			; 2
	LDA #$00		; 2, sub-total = 61
vector_irq_counter
	INC A			; 2x
	JMP vector_irq_counter	; 3x

;vector_irq_via			; clears interrupt flags
;	PHA			; acts as a 'dummy' handler
;	LDA #$7F		; in case VIA is attached and interrupts
;	STA via_ifr		; are enabled but code isn't updated.
;	PLA			; this could cause the keyboard to
;	RTI			; mess up, but it's better than nothing.

vector_nmi			; 7
	PHA			; 3
	LDA key_speed		; 4
	BEQ vector_nmi_first	; 2
	STZ key_bit		; 4
	PLA			; 4
	RTI			; 6, total = 30
vector_nmi_first		; 1
	PLA			; 4
	INC A			; 2
	STA key_speed		; 4
	PLA ; may need PLP	; 4
	PLA			; 4
	PLA			; 4
	STZ key_bit		; 4
	PLA			; 4
	RTI			; 6, total = 53


;vector_irq			; 7
;	PHA			; 3
;	LDA key_bit		; 4
;	ROR A			; 2
;	ROR key_data		; 2
;	LDA #$FF		; 2
;	STA key_bit		; 4
;	DEC key_counter		; 6
;	BEQ vector_irq_store	; 2
;	BMI vector_irq_reset	; 2
;	LDA #$10 ; wait time	; 2
;	NOP			; 2
;	JMP vector_irq_wait	; 3, sub-total = 41
;vector_irq_reset		; 1, sub-total = 35
;	LDA #$0A		; 2
;	STA key_counter		; 4
;	LDA #$10 ; wait time	; 2
;	JMP vector_irq_wait	; 3, sub-total = 46
;vector_irq_store		; 1, sub-total = 33
;	PHX			; 3
;	LDA key_data		; 4
;	LDX key_write		; 4
;	STA key_array,X		; 5
;	INC key_write		; 6
;	PLX			; 4
;	LDA #$0E ; wait time	; 2, sub-total = 61
;vector_irq_wait
;	DEC A			; 6x
;	BNE vector_irq_wait	; 3x
;	PLA			; 4
;	RTI			; 6, store=197, reset=200, else=195
;
;vector_nmi			; 7
;	STZ key_bit		; 4
;	RTI			; 6, total = 17


;vector_irq				; 7
;	PHA				; 3
;	STZ key_bit			; 4
;	DEC key_bit			; 6
;	LDA #$1A ; semi-arbitrary	; 2
;vector_irq_loop			; (1)
;	DEC A				; 6
;	BNE vector_irq_loop		; 2, sub-total = 100+
;	LDA key_bit			; 4
;	ROR A				; 2
;	ROR key_data			; 2
;	DEC key_counter			; 6
;	BEQ vector_irq_store		; 2
;	LDA key_counter			; 4
;	CMP #$FE			; 2
;	BNE vector_irq_exit		; 2
;	LDA #$09			; 2
;	STA key_counter			; 4
;vector_irq_exit			; 1
;	PLA				; 4
;	RTI				; 6
;vector_irq_store			; 1
;	PHX				; 3
;	LDA key_data			; 4
;	LDX key_write			; 4
;	STA key_array,X			; 5
;	INC key_write			; 6
;	PLX				; 4
;	PLA				; 4
;	RTI				; 6
;
;vector_nmi				; 7
;	STZ key_bit			; 4
;	RTI				; 6





; /NMI = Keyboard-Clock
; /IRQ = Keyboard-Data

;vector_nmi
;	PHA
;	LDA #$FF
;	CLI
;	NOP ; for safety
;	NOP
;vector_nmi_read	
;	DEC key_counter
;	BEQ vector_nmi_code
;	PHA
;	LDA key_counter
;	CMP #$FF
;	BEQ vector_nmi_parity
;	CMP #$FE
;	BEQ vector_nmi_stop
;	PLA
;	PHA
;	EOR key_parity
;	STA key_parity
;	PLA
;	ROR A
;	ROR key_data
;	PLA
;	RTI
;vector_nmi_code	
;	PHA
;	EOR key_parity
;	STA key_parity
;	PLA
;	ROR A
;	ROR key_data
;	LDA key_data
;	STA key_code
;	PLA
;	RTI
;vector_nmi_parity
;	PLA
;	CMP key_parity
;	BEQ vector_nmi_parity_error
;	PLA
;	RTI
;vector_nmi_parity_error
;	PHX
;	LDA #$00 ; null
;	LDX key_write
;	STA key_array,X
;	INC key_write
;	PLX
;	LDA #$09
;	STA key_counter
;	STZ key_parity
;	STZ key_data
;	PLA
;	RTI
;vector_nmi_stop
;	PLA
;	BEQ vector_nmi_stop_error
;	PHX
;	LDA key_code
;	LDX key_write
;	STA key_array,X
;	INC key_write
;	PLX
;	LDA #$09
;	STA key_counter
;	STZ key_parity
;	STZ key_data
;	PLA
;	RTI
;vector_nmi_stop_error
;	PHX
;	LDA #$00 ; null
;	LDX key_write
;	STA key_array,X
;	INC key_write
;	PLX
;	LDA #$08
;	STA key_counter
;	STZ key_parity
;	STZ key_data
;	PLA
;	RTI
;
;vector_irq
;	PLA
;	PLA
;	PLA
;	LDA #$00
;	JMP vector_nmi_read


;vector_nmi
;	PHA
;	LDA #$FF
;	CLI
;	NOP ; for safety
;vector_nmi_read	
;	ROR A
;	ROR key_data
;	DEC key_counter
;	BEQ vector_nmi_store
;	LDA key_counter
;	CMP #$FE
;	BEQ vector_nmi_check
;	PLA
;	RTI
;vector_nmi_check
;	BIT key_data
;	BMI vector_nmi_reset
;	PHX
;	LDX key_write
;	DEX
;	STZ key_array,X
;	PLX
;	LDA #$08
;	STA key_counter
;	PLA
;	RTI
;vector_nmi_reset
;	PHX
;	LDA key_code
;	LDX key_write
;	STA key_array,X
;	INC key_write
;	PLX
;	LDA #$09
;	STA key_counter
;	PLA
;	RTI
;vector_nmi_store
;	LDA key_data
;	STA key_code
;	PLA
;	RTI
;
;vector_irq
;	PLA
;	PLA
;	PLA
;	LDA #$00
;	JMP vector_nmi_read




; bank switching

	.ORG $FFE0 ; jump to Bank1

	ORA #%00011100
	BNE bank_switch

	.ORG $FFE5 ; back to top	

	JMP game_jump

	.ORG $FFE8 ; some other place?

	JMP bank_switch

	.ORG $FFF0

bank_switch
	STA $C000
	NOP ; just to be safe
	BMI $FFE5 ; needs to be kept short
	JMP vector_reset
	

	.ORG $FFFA

; reset/interrupt vectors
	.WORD jump_vector_nmi
	.WORD vector_reset
	.WORD jump_vector_irq


