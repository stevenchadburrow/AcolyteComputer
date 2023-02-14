; Acolyte Computer Code


; First, run
; ~/dev65/bin/as65 AcolyteCode-Bank1.asm

; Second, run
; ./Parser.o AcolyteCode-Bank1.lst AcolyteCode-Bank1.bin 32768 32768 32768 0

; Third (for second bank), run
; ~/dev65/bin/as65 AcolyteCode-Bank2.asm

; Fourth (for second bank), run
; ./Parser.o AcolyteCode-Bank1.lst AcolyteCode-Bank1.bin 32768 32768 32768 0

; Fifth, run
; ./Combiner.o VideoROM.bin AcolyteCode-Bank2.bin AcolyteCode-Bank1.bin AcolyteCode-128K.bin AcolyteCode-512K.bin

; Sixth, run
; minipro -p "SST39SF010" -w AcolyteCode-128K.bin



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
; Writing to ROM also writes to RAM if the RAM is fast enough.
; This is not a problem when using the 128KB RAM, but when using
; only 32KB of RAM, it would show anything written to ROM in 
; the RAM space given.  So, when writing to ROM for output,
; make sure to write to $FFFF which is off-screen and is not 
; expected to be used.

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

sdcard_memory		.EQU $0400 ; shared with game_field

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
basic_code_end		.EQU $BFFF
basic_code_error	.EQU $C000 ; one past



; the start of code

	.ORG $C000

vector_reset
	PHA			; used later
	SEI			; turn off interrupts from /IRQ
	CLD			; turn off decimal mode

	LDX #$00		; zeroing out a lot of variables
zero_loop
	STZ $0300,X
	INX
	BNE zero_loop

	LDA #$4C ; JMPa			; mini-jump tables for IRQ and NMI
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

;	LDA #%00011100		; set output pins
;	STA $FFFF

;	LDA #%01111111		; clears interrupt flags
;	STA via_ifr
;	STZ via_ier

;	LDA #%10011100		; set output pins
;	STA $FFFF

;	LDA #%01111111		; clears interrupt flags
;	STA via_ifr
;	STZ via_ier

	CLI

	LDA #%00011100		; set output pins
	STA output_byte
	STA $FFFF

	LDA #$4C ; JMPa			; mini-jump tables for printchar and inputchar
	STA jump_printchar+0		; so that it is easier to use those while programming
	LDA #<printchar			; directly on this machine from the assembler/monitor
	STA jump_printchar+1
	LDA #>printchar
	STA jump_printchar+2
	LDA #$4C ; JMPa
	STA jump_inputchar+0
	LDA #<inputchar
	STA jump_inputchar+1
	LDA #>inputchar
	STA jump_inputchar+2
	
	LDA #$4C ; JMPa			; mini-jump tables for spi_eeprom_write and spi_eeprom_read
	STA jump_spi_eeprom_write+0	; so that it is easier to use those while programming
	LDA #<spi_eeprom_write		; directly on this machine from the assembler/monitor
	STA jump_spi_eeprom_write+1
	LDA #>spi_eeprom_write
	STA jump_spi_eeprom_write+2
	LDA #$4C ; JMPa
	STA jump_spi_eeprom_read+0
	LDA #<spi_eeprom_read
	STA jump_spi_eeprom_read+1
	LDA #>spi_eeprom_read
	STA jump_spi_eeprom_read+2
	LDA #$4C ; JMPa			
	STA jump_spi_sdcard_init+0	
	LDA #<spi_sdcard_init	
	STA jump_spi_sdcard_init+1
	LDA #>spi_sdcard_init
	STA jump_spi_sdcard_init+2
	LDA #$4C ; JMPa
	STA jump_spi_sdcard_read+0
	LDA #<spi_sdcard_read
	STA jump_spi_sdcard_read+1
	LDA #>spi_sdcard_read
	STA jump_spi_sdcard_read+2

	LDA #$AD ; LDAa		; create sub_read, sub_write, sub_jump, and sub_index functions
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

	;LDA #$AD ; LDAa			; create basic_sub_random
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

	LDX #$10			; creates basic_sub_random	
random_loop
	LDA random_code,X
	STA basic_sub_random,X
	DEX
	CPX #$FF
	BNE random_loop

	JMP random_exit

random_code
	.BYTE $AD
	.WORD basic_sub_random_var
	.BYTE $2A,$18,$2A,$18,$6D
	.WORD basic_sub_random_var
	.BYTE $18,$69,$11,$8D
	.WORD basic_sub_random_var
	.BYTE $60

random_exit


main_screen

	PLA					; grab accumulator
	AND #%10000000				; only clear if told to
	BEQ main_clear
	JMP main_start

main_clear

	STZ sub_write+1				; clear out all expanded RAM
	LDA #$88
	STA sub_write+2
wipeout_loop2
	LDA #$00
	JSR sub_write
	INC sub_write+1
	BNE wipeout_loop2
	INC sub_write+2
	LDA sub_write+2
	CMP #$C0 
	BNE wipeout_loop2

	LDA output_byte				; change RAM bank (if connected such)
	EOR #%00100000
	STA output_byte
	STA $FFFF
	AND #%00100000
	BNE main_clear

main_start

	STZ sub_write+1				; clear out all system and screen RAM 
	LDA #$04
	STA sub_write+2
wipeout_loop1
	LDA #$55 ; border color
	JSR sub_write
	INC sub_write+1
	BNE wipeout_loop1
	INC sub_write+2
	LDA sub_write+2
	CMP #$80
	BNE wipeout_loop1

	STZ command_mode			; start in scratchpad mode
	STZ printchar_invert

	LDA key_alt_control
	PHA
	LDA #$FF
	STA key_alt_control
	LDA #$0C ; form feed
	JSR printchar
	PLA
	STA key_alt_control

	LDA #$00
	JSR sdcard ; load SDcard boot code

	LDX #$00
	JMP main_display_loop3
main_display_text3
	.BYTE "F12 for"
	.BYTE " Help",$0D
main_display_loop3
	LDA main_display_text3,X
	JSR printchar
	INX
	CPX #$0D
	BNE main_display_loop3
main_ready
	LDA #$05 ; enquire
	JSR printchar
main_loop			; wait for keyboard update, print what was typed
	CLC
	JSR basic_sub_random 	; helps randomize a bit better	
	JSR inputchar		
	CMP #$00 ; needed
	BEQ main_loop
main_loop_next
	LDA #$06 ; acknowledge
	JSR printchar
	LDA inputchar_value
	JSR printchar
	LDA #$05 ; enquire
	JSR printchar
	JMP main_loop
	
main_help
	LDA #$0D ; carriage return
	JSR printchar
	LDA #<main_help_text
	STA command_addr3_low
	LDA #>main_help_text
	STA command_addr3_high
main_help_loop
	JSR inputchar
	CMP #$00
	BEQ main_help_continue
	CMP #$1B ; escape
	BNE main_help_continue
	JMP main_help_exit
main_help_continue
	LDA command_addr3_low
	STA sub_read+1
	LDA command_addr3_high
	STA sub_read+2
	JSR sub_read
	CMP #$FF
	BEQ main_help_exit
	JSR printchar
	INC command_addr3_low
	BNE main_help_loop
	INC command_addr3_high
	JMP main_help_loop
main_help_exit
	LDA #$0D ; carriage return
	JSR printchar
	LDA #$05 ; enquire
	JSR printchar
	RTS

main_help_text
	.BYTE "Hold Ctr"
	.BYTE "l",$3A,$0D
	.BYTE "F1=Scrat"
	.BYTE "chpad   "
	.BYTE "F9=Tetra"
	.BYTE $0D
	.BYTE "F2=Monit"
	.BYTE "or      "
	.BYTE "F10=Intr"
	.BYTE "uders",$0D
	.BYTE "F3=BASIC"
	.BYTE "        "
	.BYTE "F11=SDca"
	.BYTE "rd",$0D
	.BYTE "F4=RAM B"
	.BYTE "ank     "
	.BYTE "F12=Help"
	.BYTE $0D
	.BYTE "F5=Clear"
	.BYTE " Text",$0D
	.BYTE "F6=Shift"
	.BYTE " Text   "
	.BYTE "3.14 MHz"
	.BYTE " 6502 CP"
	.BYTE "U"
	.BYTE $0D
	.BYTE "F7=Reset"
	.BYTE "        "
	.BYTE "64K RAM "
	.BYTE "& 32K RO"
	.BYTE "M"
	.BYTE $0D
	.BYTE "F8=Bell "
	.BYTE "        "
	.BYTE "VGA, PS/"
	.BYTE "2, & Aud"
	.BYTE "io"
	.BYTE $0D
	.BYTE $FF


monitor
	PHA
	PHX
	PHY
	STZ command_mode
	LDY #$00
	STZ command_place
	STZ command_function
monitor_loop
	LDA command_array,Y
	INY
	CPY #$28
	BNE monitor_continue1
	JMP monitor_function1
monitor_continue1
	CMP #"." ; start addr2 and memdump
	BNE monitor_continue2
	LDA #$04
	STA command_place
	LDA #$01
	STA command_function
	JMP monitor_loop
monitor_continue2
	CMP #"<" ; copy addr1 to addr3
	BNE monitor_continue3
	STZ command_place
	LDA command_addr1_low
	STA command_addr3_low
	LDA command_addr1_high
	STA command_addr3_high
	JMP monitor_loop
monitor_continue3
	CMP #">" ; copy addr1 to data
	BNE monitor_continue4
	LDA command_place
	AND #%00000010
	STZ command_place
	BNE monitor_copy
	LDA command_addr1_low
	STA command_data
	JMP monitor_loop
monitor_copy
	LDA command_addr1_high
	STA command_data
	JMP monitor_loop
monitor_continue4
	CMP #"," ; restart at addr1
	BNE monitor_continue5
	STZ command_place
	JMP monitor_loop
monitor_continue5
	CMP #$3A ; colon, memwrite
	BNE monitor_continue6
	LDA #$08
	STA command_place
	LDA #$02
	STA command_function
	LDA command_addr1_low
	STA command_addr3_low
	LDA command_addr1_high
	STA command_addr3_high
	JMP monitor_loop
monitor_continue6
	CMP #"L" ; memlist
	BNE monitor_continue7
	LDA #$03
	STA command_function
	JMP monitor_loop
monitor_continue7
	CMP #"M" ; memmove
	BNE monitor_continue8
	LDA #$04
	STA command_function
	JMP monitor_loop
monitor_continue8
	CMP #"V" ; memverify
	BNE monitor_continue9
	LDA #$05
	STA command_function
	JMP monitor_loop
monitor_continue9
	CMP #"P" ; mempack
	BNE monitor_continue10
	LDA #$06
	STA command_function
	JMP monitor_loop
monitor_continue10
	CMP #"S" ; memsearch
	BNE monitor_continue11
	LDA #$07
	STA command_function
	JMP monitor_loop
monitor_continue11
	CMP #"G" ; goto (JMP)
	BNE monitor_continue12
	LDA #$08
	STA command_function
	JMP monitor_loop
monitor_continue12
	CMP #"J" ; jump (JSR)
	BNE monitor_continue13
	LDA #$09
	STA command_function
	JMP monitor_loop
monitor_continue13
	CMP #"?" ; help
	BNE monitor_continue14
	LDA #$0A
	STA command_function
	JMP monitor_loop
monitor_continue14
	CMP #"W" ; write to EEPROM
	BNE monitor_continue15
	LDA #$0B
	STA command_function
	LDA #%11111011				; says we are trying to work with SPI-EEPROM, that is D2 is low, the rest are high
	STA spi_cs_enable
	JMP monitor_loop
monitor_continue15
	CMP #"R" ; read from EEPROM
	BNE monitor_continue16
	LDA #$0C
	STA command_function
	LDA #%11111011				; says we are trying to work with SPI-EEPROM, that is D2 is low, the rest are high
	STA spi_cs_enable
	JMP monitor_loop
monitor_continue16
	CMP #"@" ; assembly instruction
	BNE monitor_continue17
	LDA #$10
	STA command_function
	JMP monitor_function1
monitor_continue17
	NOP
monitor_setup1
	AND #%01111111
	TAX
	LDA command_place
	AND #%00000001
	BNE monitor_setup2
	LDA ascii_value_high,X
	JMP monitor_setup3
monitor_setup2
	LDA ascii_value_low,X
monitor_setup3
	CMP #$FF
	BNE monitor_setup4
	CPX #$27 ; single-quote
	BEQ monitor_setup5
	JMP monitor_loop
monitor_setup4
	STA command_temp
	LDA command_place
	BNE monitor_value1
	LDA command_addr1_high
	AND #%00001111
	ORA command_temp
	STA command_addr1_high
	INC command_place
	JMP monitor_loop
monitor_setup5
	LDA command_place
	CMP #$08
	BEQ monitor_setup6
	CMP #$09
	BEQ monitor_setup6
	JMP monitor_loop
monitor_setup6
	LDA command_array,Y
	INY
	CPY #$28
	BNE monitor_setup7
	JMP monitor_function1
monitor_setup7
	STZ command_temp
	STA command_data
	JMP monitor_byte
monitor_value1
	CMP #$01
	BNE monitor_value2
	LDA command_addr1_high
	AND #%11110000
	ORA command_temp
	STA command_addr1_high
	INC command_place
	JMP monitor_loop
monitor_value2
	CMP #$02
	BNE monitor_value3
	LDA command_addr1_low
	AND #%00001111
	ORA command_temp
	STA command_addr1_low
	INC command_place
	JMP monitor_loop
monitor_value3
	CMP #$03
	BNE monitor_value4
	LDA command_addr1_low
	AND #%11110000
	ORA command_temp
	STA command_addr1_low
	STZ command_place
	JMP monitor_loop
monitor_value4
	CMP #$04
	BNE monitor_value5
	LDA command_addr2_high
	AND #%00001111
	ORA command_temp
	STA command_addr2_high
	INC command_place
	JMP monitor_loop
monitor_value5
	CMP #$05
	BNE monitor_value6
	LDA command_addr2_high
	AND #%11110000
	ORA command_temp
	STA command_addr2_high
	INC command_place
	JMP monitor_loop
monitor_value6
	CMP #$06
	BNE monitor_value7
	LDA command_addr2_low
	AND #%00001111
	ORA command_temp
	STA command_addr2_low
	INC command_place
	JMP monitor_loop
monitor_value7
	CMP #$07
	BNE monitor_value8
	LDA command_addr2_low
	AND #%11110000
	ORA command_temp
	STA command_addr2_low
	LDA #$04
	STA command_place
	JMP monitor_loop
monitor_value8
	CMP #$08
	BNE monitor_value9
	LDA command_temp
	STA command_data
	INC command_place
	JMP monitor_loop
monitor_value9
	CMP #$09
	BNE monitor_value10
monitor_byte
	LDA command_data
	ORA command_temp
	STA command_data
	LDA command_addr1_low
	STA sub_write+1
	LDA command_addr1_high
	STA sub_write+2
	LDA command_data
	JSR sub_write
	INC command_addr1_low
	BNE monitor_next
	INC command_addr1_high
monitor_next
	LDA #$08
	STA command_place
	JMP monitor_loop
monitor_value10
	NOP
	JMP monitor_loop
monitor_function1
	LDA command_function
	BNE monitor_function2
	JSR monitor_memsingle
	JMP monitor_exit
monitor_function2
	CMP #$01 ; memdump
	BNE monitor_function3
	JSR monitor_memdump
	JMP monitor_exit
monitor_function3
	CMP #$02 ; memwrite
	BNE monitor_function4
	LDA command_addr1_low
	STA command_addr2_low
	PHA
	LDA command_addr1_high
	STA command_addr2_high
	PHA
	LDA command_addr3_low
	STA command_addr1_low
	LDA command_addr3_high
	STA command_addr1_high
	JSR monitor_memdump
	PLA
	STA command_addr1_high
	PLA
	STA command_addr1_low
	JMP monitor_exit
monitor_function4
	CMP #$03 ; memlist
	BNE monitor_function5
	JSR monitor_memlist
	JMP monitor_exit
monitor_function5
	CMP #$04 ; memmove
	BNE monitor_function6
	JSR monitor_memmove
	LDA command_addr3_low
	STA command_addr1_low
	LDA command_addr3_high
	STA command_addr1_high
	LDA command_addr4_low
	STA command_addr2_low
	LDA command_addr4_high
	STA command_addr2_high
	;JSR monitor_memdump	
	JMP monitor_exit
monitor_function6
	CMP #$05 ; memverify
	BNE monitor_function7
	JSR monitor_memverify
	JMP monitor_exit
monitor_function7
	CMP #$06 ; mempack
	BNE monitor_function8
	JSR monitor_mempack
	;JSR monitor_memdump
	JMP monitor_exit
monitor_function8
	CMP #$07 ; memsearch
	BNE monitor_function9
	JSR monitor_memsearch
	JMP monitor_exit
monitor_function9
	CMP #$08 ; goto (JMP)
	BNE monitor_function10
	JMP (command_addr1_low)
	JMP monitor_exit
monitor_function10
	CMP #$09 ; jump (JSR)
	BNE monitor_function11
	LDA command_addr1_low
	STA sub_jump+1
	LDA command_addr1_high
	STA sub_jump+2
	JSR sub_jump
	JMP monitor_exit
monitor_function11
	CMP #$0A ; help
	BNE monitor_function12
	JSR monitor_memhelp
	JMP monitor_exit
monitor_function12
	CMP #$0B ; write to EEPROM
	BNE monitor_function13
	JSR spi_eeprom_write
	JMP monitor_exit
monitor_function13
	CMP #$0C ; read from EEPROM
	BNE monitor_function14
	JSR spi_eeprom_read
	JMP monitor_exit
monitor_function14
	CMP #$10 ; assembly instruction
	BNE monitor_function15
	JSR monitor_memasm
	CMP #$FF ; error occured
	BEQ monitor_exit
	JMP monitor_exit_asm
monitor_function15
	NOP	
monitor_exit
	LDA #$01
	STA command_mode
	PLY
	PLX
	PLA
	RTS
monitor_exit_asm
	LDA #$02
	STA command_mode
	PLY
	PLX
	PLA
	RTS


monitor_memsingle
	LDA #$0D ; carriage return
	JSR printchar
	LDX command_addr1_high
	LDA ascii_key_high,X
	JSR printchar
	LDA ascii_key_low,X
	JSR printchar
	LDX command_addr1_low
	LDA ascii_key_high,X
	JSR printchar
	LDA ascii_key_low,X
	JSR printchar
	LDA #$3A ; colon
	JSR printchar
	LDA #" "
	JSR printchar
	LDA command_addr1_low
	STA sub_read+1
	LDA command_addr1_high
	STA sub_read+2
	JSR sub_read
	TAX
	LDA ascii_key_high,X
	JSR printchar
	LDA ascii_key_low,X
	JSR printchar
	RTS


monitor_memdump
	STZ command_temp
	LDA command_addr1_low
	AND #%11111000
	STA command_addr1_low
	LDA command_addr2_low
	AND #%11111000
	STA command_addr2_low
	LDA command_addr2_high
	CMP command_addr1_high
	BNE monitor_memdump_line
	LDA command_addr2_low
	CMP command_addr1_low
	BNE monitor_memdump_line
	INC command_temp
monitor_memdump_line
	JSR inputchar
	CMP #$1B ; escape
	BNE monitor_memdump_skip
	JMP monitor_memdump_exit
monitor_memdump_skip
	LDA #$0D ; carriage return
	JSR printchar
	LDX command_addr1_high
	LDA ascii_key_high,X
	JSR printchar
	LDA ascii_key_low,X
	JSR printchar
	LDX command_addr1_low
	LDA ascii_key_high,X
	JSR printchar
	LDA ascii_key_low,X
	JSR printchar
	LDA #$3A ; colon
	JSR printchar
	LDA #" "
	JSR printchar
monitor_memdump_byte
	LDA command_addr1_low
	STA sub_read+1
	LDA command_addr1_high
	STA sub_read+2
	JSR sub_read
	TAX
	LDA ascii_key_high,X
	JSR printchar
	LDA ascii_key_low,X
	JSR printchar
	LDA #" "
	JSR printchar
	INC command_addr1_low
	LDA command_addr1_low
	AND #%00000111
	BEQ monitor_memdump_equivalent
	JMP monitor_memdump_byte
monitor_memdump_equivalent
	;LDA #" "
	;JSR printchar
	LDA command_addr1_low
	SEC
	SBC #$08
	STA command_addr1_low
	LDY #$08
monitor_memdump_char
	LDA command_addr1_low
	STA sub_read+1
	LDA command_addr1_high
	STA sub_read+2
	JSR sub_read
	AND #%01111111
	CLC
	CMP #$20
	BCC monitor_memdump_strange
	CMP #$7F
	BEQ monitor_memdump_strange
	CMP #$FF
	BEQ monitor_memdump_strange
	JMP monitor_memdump_typical
monitor_memdump_strange
	LDA #"_"
monitor_memdump_typical
	JSR printchar
	INC command_addr1_low
	DEY
	BNE monitor_memdump_char
	LDA command_addr1_low
	BNE monitor_memdump_next
	INC command_addr1_high
monitor_memdump_next
	LDA command_temp
	BNE monitor_memdump_exit
	LDA command_addr1_high
	CMP command_addr2_high
	BNE monitor_memdump_continue
	LDA command_addr1_low
	CMP command_addr2_low
	BNE monitor_memdump_continue
	INC command_temp
monitor_memdump_continue
	JMP monitor_memdump_line
monitor_memdump_exit
	RTS


monitor_memmove
	LDA command_addr1_low
	STA sub_read+1
	LDA command_addr1_high
	STA sub_read+2
	LDA command_addr3_low
	STA sub_write+1
	LDA command_addr3_high
	STA sub_write+2
monitor_memmove_loop
	JSR inputchar
	CMP #$1B ; escape
	BNE monitor_memmove_skip
	RTS
monitor_memmove_skip
	JSR sub_read
	JSR sub_write
	INC sub_write+1
	BNE monitor_memmove_check1
	INC sub_write+2
monitor_memmove_check1
	INC sub_read+1
	BNE monitor_memmove_check2
	INC sub_read+2
monitor_memmove_check2
	LDA sub_read+2
	CMP command_addr2_high
	BNE monitor_memmove_loop
	LDA sub_read+1
	CMP command_addr2_low
	BNE monitor_memmove_loop
	JSR sub_read
	JSR sub_write
	LDA sub_write+1
	STA command_addr4_low
	LDA sub_write+2
	STA command_addr4_high
	RTS


monitor_memverify
	STZ command_temp
monitor_memverify_start
	JSR inputchar
	CMP #$1B ; escape
	BNE monitor_memverify_skip
	RTS
monitor_memverify_skip
	LDA command_addr1_low
	STA sub_read+1
	LDA command_addr1_high
	STA sub_read+2
	JSR sub_read
	STA command_data
	LDA command_addr3_low
	STA sub_read+1
	LDA command_addr3_high
	STA sub_read+2
	JSR sub_read
	CMP command_data
	BNE monitor_memverify_found
	JMP monitor_memverify_repeat1
monitor_memverify_found
	LDA #$0D
	JSR printchar
	LDX command_addr1_high
	LDA ascii_key_high,X
	JSR printchar
	LDA ascii_key_low,X
	JSR printchar
	LDX command_addr1_low
	LDA ascii_key_high,X
	JSR printchar
	LDA ascii_key_low,X
	JSR printchar
	LDA #$3A ; colon
	JSR printchar
	LDA #" "
	JSR printchar
	LDX command_data
	LDA ascii_key_high,X
	JSR printchar
	LDA ascii_key_low,X
	JSR printchar
	LDA #" "
	JSR printchar
	LDA #$7C ; vertical bar
	JSR printchar
	LDA #" "
	JSR printchar
	LDX command_addr3_high
	LDA ascii_key_high,X
	JSR printchar
	LDA ascii_key_low,X
	JSR printchar
	LDX command_addr3_low
	LDA ascii_key_high,X
	JSR printchar
	LDA ascii_key_low,X
	JSR printchar
	LDA #$3A ; colon
	JSR printchar
	LDA #" "
	JSR printchar
	LDA command_addr3_low
	STA sub_read+1
	LDA command_addr3_high
	STA sub_read+2
	JSR sub_read
	TAX
	LDA ascii_key_high,X
	JSR printchar
	LDA ascii_key_low,X
	JSR printchar
monitor_memverify_repeat1
	LDA command_temp
	BEQ monitor_memverify_repeat2
	RTS
monitor_memverify_repeat2
	INC command_addr1_low
	BNE monitor_memverify_repeat3
	INC command_addr1_high
monitor_memverify_repeat3
	INC command_addr3_low
	BNE monitor_memverify_repeat4
	INC command_addr3_high
monitor_memverify_repeat4
	LDA command_addr1_high
	CMP command_addr2_high
	BNE monitor_memverify_repeat5
	LDA command_addr1_low
	CMP command_addr2_low
	BNE monitor_memverify_repeat5
	INC command_temp
monitor_memverify_repeat5
	JMP monitor_memverify_start


monitor_mempack
	LDA command_addr1_low
	STA sub_write+1
	LDA command_addr1_high
	STA sub_write+2
monitor_mempack_loop
	JSR inputchar
	CMP #$1B ; escape
	BNE monitor_mempack_skip
	RTS
monitor_mempack_skip
	LDA command_data
	JSR sub_write
	INC sub_write+1
	BNE monitor_mempack_check
	INC sub_write+2
monitor_mempack_check
	LDA sub_write+2
	CMP command_addr2_high
	BNE monitor_mempack_loop
	LDA sub_write+1
	CMP command_addr2_low
	BNE monitor_mempack_loop
	LDA command_data
	JSR sub_write
	RTS


monitor_memsearch
	STZ command_temp
monitor_memsearch_start
	JSR inputchar
	CMP #$1B ; escape
	BNE monitor_memsearch_skip
	RTS
monitor_memsearch_skip
	LDA command_addr1_low
	STA sub_read+1
	LDA command_addr1_high
	STA sub_read+2
	JSR sub_read
	CMP command_data
	BNE monitor_memsearch_repeat1
	LDA #$0D
	JSR printchar
	LDX command_addr1_high
	LDA ascii_key_high,X
	JSR printchar
	LDA ascii_key_low,X
	JSR printchar
	LDX command_addr1_low
	LDA ascii_key_high,X
	JSR printchar
	LDA ascii_key_low,X
	JSR printchar
	LDA #$3A ; colon
	JSR printchar
	LDA #" "
	JSR printchar
	LDX command_data
	LDA ascii_key_high,X
	JSR printchar
	LDA ascii_key_low,X
	JSR printchar
monitor_memsearch_repeat1
	LDA command_temp
	BEQ monitor_memsearch_repeat2
	RTS
monitor_memsearch_repeat2
	INC command_addr1_low
	BNE monitor_memsearch_repeat3
	INC command_addr1_high
monitor_memsearch_repeat3
	LDA command_addr1_high
	CMP command_addr2_high
	BNE monitor_memsearch_repeat4
	LDA command_addr1_low
	CMP command_addr2_low
	BNE monitor_memsearch_repeat4
	INC command_temp
monitor_memsearch_repeat4
	JMP monitor_memsearch_start


monitor_memlist
	LDA #$0D ; carriage return
	JSR printchar
	STZ command_temp
	LDA command_addr1_high
	CMP command_addr2_high
	BNE monitor_memlist_start
	LDA command_addr1_low
	CMP command_addr2_low
	BNE monitor_memlist_start
	INC command_temp
monitor_memlist_start
	JSR inputchar
	CMP #$1B ; escape
	BNE monitor_memlist_skip
	RTS
monitor_memlist_skip
	LDX command_addr1_high
	LDA ascii_key_high,X
	JSR printchar
	LDA ascii_key_low,X
	JSR printchar
	LDX command_addr1_low
	LDA ascii_key_high,X
	JSR printchar
	LDA ascii_key_low,X
	JSR printchar
	LDA #$3A ; colon
	JSR printchar
	LDA #" "
	JSR printchar
	LDA command_addr1_low
	STA sub_read+1
	LDA command_addr1_high
	STA sub_read+2
	JSR sub_read
	STA command_byte1
	TAY
	LDA #<opcode_lookup
	STA command_addr3_low
	LDA #>opcode_lookup
	STA command_addr3_high
monitor_memlist_count1
	CPY #$00
	BEQ monitor_memlist_bytes1
	DEY
	LDA command_addr3_low
	CLC
	ADC #$08
	STA command_addr3_low
	BCC monitor_memlist_count2
	INC command_addr3_high
monitor_memlist_count2
	JMP monitor_memlist_count1
monitor_memlist_bytes1
	LDX command_byte1
	LDA opcode_bytes,X
	BNE monitor_memlist_bytes2
	JMP monitor_memlist_bytes6
monitor_memlist_bytes2
	CMP #$01
	BNE monitor_memlist_bytes3
	JMP monitor_memlist_bytes7
monitor_memlist_bytes3
	INC command_addr1_low
	BNE monitor_memlist_bytes4
	INC command_addr1_high
monitor_memlist_bytes4
	LDA command_addr1_low
	STA sub_read+1
	LDA command_addr1_high
	STA sub_read+2
	JSR sub_read
	STA command_byte2
	INC command_addr1_low
	BNE monitor_memlist_bytes5
	INC command_addr1_high
monitor_memlist_bytes5
	LDA command_addr1_low
	STA sub_read+1
	LDA command_addr1_high
	STA sub_read+2
	JSR sub_read
	STA command_byte3
	LDX command_byte1
	LDA ascii_key_high,X
	JSR printchar
	LDA ascii_key_low,X
	JSR printchar
	LDA #" "
	JSR printchar
	LDX command_byte2
	LDA ascii_key_high,X
	JSR printchar
	LDA ascii_key_low,X
	JSR printchar
	LDA #" "
	JSR printchar
	LDX command_byte3
	LDA ascii_key_high,X
	JSR printchar
	LDA ascii_key_low,X
	JSR printchar
	LDA #" "
	JSR printchar
	JSR printchar
	JMP monitor_memlist_name1
monitor_memlist_bytes6
	LDX command_byte1
	LDA ascii_key_high,X
	JSR printchar
	LDA ascii_key_low,X
	JSR printchar
	LDA #" "
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JMP monitor_memlist_name1
monitor_memlist_bytes7
	INC command_addr1_low
	BNE monitor_memlist_bytes8
	INC command_addr1_high
monitor_memlist_bytes8
	LDA command_addr1_low
	STA sub_read+1
	LDA command_addr1_high
	STA sub_read+2
	JSR sub_read
	STA command_byte2
	LDX command_byte1
	LDA ascii_key_high,X
	JSR printchar
	LDA ascii_key_low,X
	JSR printchar
	LDA #" "
	JSR printchar
	LDX command_byte2
	LDA ascii_key_high,X
	JSR printchar
	LDA ascii_key_low,X
	JSR printchar
	LDA #" "
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
monitor_memlist_name1
	INC command_addr1_low
	BNE monitor_memlist_name2
	INC command_addr1_high
monitor_memlist_name2
	LDY #$05
monitor_memlist_name3
	LDA command_addr3_low
	STA sub_read+1
	LDA command_addr3_high
	STA sub_read+2
	JSR sub_read
	JSR printchar
	INC command_addr3_low
	DEY
	CPY #$02
	BNE monitor_memlist_name4
	LDA #" "
	JSR printchar
monitor_memlist_name4
	CPY #$00
	BNE monitor_memlist_name3
	LDX command_byte1
	LDA opcode_bytes,X
	BEQ monitor_memlist_ending1
	CMP #$01
	BEQ monitor_memlist_name5
	LDX command_byte3
	LDA ascii_key_high,X
	JSR printchar
	LDA ascii_key_low,X
	JSR printchar
	LDX command_byte2
	LDA ascii_key_high,X
	JSR printchar
	LDA ascii_key_low,X
	JSR printchar
	JMP monitor_memlist_ending1
monitor_memlist_name5
	LDX command_byte2
	LDA ascii_key_high,X
	JSR printchar
	LDA ascii_key_low,X
	JSR printchar
monitor_memlist_ending1
	LDY #$03
monitor_memlist_ending2
	LDA command_addr3_low
	STA sub_read+1
	LDA command_addr3_high
	STA sub_read+2
	JSR sub_read
	JSR printchar
	INC command_addr3_low
	DEY
	BNE monitor_memlist_ending2
	LDA command_temp
	BEQ monitor_memlist_ending3
	RTS
monitor_memlist_ending3
	LDA command_addr1_high
	CLC
	CMP command_addr2_high
	BCC monitor_memlist_repeat
	LDA command_addr1_low
	CLC
	CMP command_addr2_low
	BEQ monitor_memlist_repeat
	BCC monitor_memlist_repeat
	RTS
monitor_memlist_repeat
	LDA #$0D ; carriage return
	JSR printchar
	JMP monitor_memlist_start
	

monitor_memhelp
	LDA #$0D ; carriage return
	JSR printchar
	LDA #<monitor_memhelp_text
	STA command_addr3_low
	LDA #>monitor_memhelp_text
	STA command_addr3_high
monitor_memhelp_loop
	JSR inputchar
	CMP #$00
	BEQ monitor_memhelp_skip
	CMP #$1B ; escape
	BNE monitor_memhelp_skip
	JMP monitor_memhelp_exit
monitor_memhelp_skip
	LDA command_addr3_low
	STA sub_read+1
	LDA command_addr3_high
	STA sub_read+2
	JSR sub_read
	CMP #$FF
	BEQ monitor_memhelp_exit
	JSR printchar
monitor_memhelp_continue
	INC command_addr3_low
	BNE monitor_memhelp_loop
	INC command_addr3_high
	JMP monitor_memhelp_loop
monitor_memhelp_exit
	LDA #$0D ; carriage return
	JSR printchar
	RTS


monitor_memasm
	LDA command_addr1_low
	STA command_addr3_low
	LDA command_addr1_high
	STA command_addr3_high
monitor_memasm_start
	LDA command_array
	CMP #"@"
	BEQ monitor_memasm_clear
	LDX #$01
	LDY #$00
monitor_memasm_shift
	LDA command_array,X
	STA command_array,Y
	INX
	INY
	CPX #$27
	BNE monitor_memasm_shift
	STZ command_array,X ; make any new values $00
	JMP monitor_memasm_start
monitor_memasm_clear
	LDX #$01
	LDY #$00
monitor_memasm_replace
	LDA command_array,X
	INX
	INY
	CMP #" " ; remove all spaces, deletes, and command prompts
	BEQ monitor_memasm_shift
	CMP #$7F
	BEQ monitor_memasm_shift
	CMP #$FF
	BEQ monitor_memasm_shift
	CMP #$5C
	BEQ monitor_memasm_shift
	CPX #$27
	BNE monitor_memasm_replace
	LDX #$00
monitor_memasm_space
	INX
	CPX #$27
	BEQ monitor_memasm_fresh
	LDA command_array,X
	CMP #$00
	BNE monitor_memasm_space
	LDA #" " ; replace all $00's with spaces	
	STA command_array,X
	JMP monitor_memasm_space
monitor_memasm_fresh
	LDA #<opcode_lookup
	STA sub_index+1
	LDA #>opcode_lookup
	STA sub_index+2
monitor_memasm_loop
	LDY #$01
	LDX #$00
monitor_memasm_continue
	JSR sub_index
	CMP #" "
	BNE monitor_memasm_check
	INX
	CPX #$05
	BNE monitor_memasm_continue
	JMP monitor_memasm_complete
monitor_memasm_check
	CMP command_array,Y
	BEQ monitor_memasm_found
	LDA sub_index+1
	CLC
	ADC #$08
	STA sub_index+1
	BNE monitor_memasm_loop
	INC sub_index+2
	LDA #>opcode_lookup
	CLC
	ADC #$08
	CMP sub_index+2
	BNE monitor_memasm_loop
	JMP monitor_memasm_error
monitor_memasm_found 
	INY
	INX
	CPX #$05
	BNE monitor_memasm_continue
monitor_memasm_complete
	PHY
	LDA sub_index+2
	AND #%00000111
	CLC
	ROR A
	ROR A
	ROR A
	ROR A
	STA command_data
	LDA sub_index+1
	AND #%11111000
	CLC
	ROR A
	ROR A
	ROR A	
	ADC command_data
	STA command_byte1
	JMP monitor_memasm_read
monitor_memasm_error
	LDA #"?"
	JSR printchar
	LDA #$FF ; error
	RTS
monitor_memasm_read
	TAX
	LDA opcode_bytes,X
	BEQ monitor_memasm_zero
	CMP #$01
	BEQ monitor_memasm_one
	PLY
	LDX command_array,Y
	LDA ascii_value_high,X
	CMP #$FF
	BEQ monitor_memasm_error
	STA command_byte3
	INY
	LDX command_array,Y
	LDA ascii_value_low,X
	CMP #$FF
	BEQ monitor_memasm_error
	CLC
	ADC command_byte3
	STA command_byte3
	INY
	LDX command_array,Y
	LDA ascii_value_high,X
	CMP #$FF
	BEQ monitor_memasm_error
	STA command_byte2
	INY
	LDX command_array,Y
	LDA ascii_value_low,X
	CMP $#FF
	BEQ monitor_memasm_error
	CLC
	ADC command_byte2
	STA command_byte2
	INY
	JMP monitor_memasm_backend
monitor_memasm_zero
	PLY
	JMP monitor_memasm_backend
monitor_memasm_one
	PLY
	LDX command_array,Y
	LDA ascii_value_high,X
	STA command_byte2
	INY
	LDX command_array,Y
	LDA ascii_value_low,X
	CMP #$FF
	BEQ monitor_memasm_error
	CLC
	ADC command_byte2
	STA command_byte2
	INY
monitor_memasm_backend
	LDX #$05
monitor_memasm_compare
	JSR sub_index
	CMP command_array,Y
	BEQ monitor_memasm_same
	LDA sub_index+1
	CLC
	ADC #$08
	STA sub_index+1
	BNE monitor_memasm_return
	INC sub_index+2
monitor_memasm_return
	JMP monitor_memasm_loop
monitor_memasm_same
	INX
	INY
	CPX #$08
	BNE monitor_memasm_compare
monitor_memasm_last
	LDA command_addr3_low
	STA sub_write+1
	LDA command_addr3_high
	STA sub_write+2
	LDX command_byte1
	LDA opcode_bytes,X
	BNE monitor_memasm_more
	JMP monitor_memasm_single1
monitor_memasm_more
	CMP #$01
	BNE monitor_memasm_triple1
monitor_memasm_double1
	LDA command_byte1
	JSR sub_write
	INC sub_write+1
	BNE monitor_memasm_double2
	INC sub_write+1
monitor_memasm_double2
	LDA command_byte2
	JSR sub_write
	INC sub_write+1
	BNE monitor_memasm_double3
	INC sub_write+1
monitor_memasm_double3
	JMP monitor_memasm_print
monitor_memasm_triple1
	LDA command_byte1
	JSR sub_write
	INC sub_write+1
	BNE monitor_memasm_triple2
	INC sub_write+1
monitor_memasm_triple2
	LDA command_byte2
	JSR sub_write
	INC sub_write+1
	BNE monitor_memasm_triple3
	INC sub_write+1
monitor_memasm_triple3
	LDA command_byte3
	JSR sub_write
	INC sub_write+1
	BNE monitor_memasm_triple4
	INC sub_write+1
monitor_memasm_triple4
	JMP monitor_memasm_print
monitor_memasm_single1
	LDA command_byte1
	JSR sub_write
	INC sub_write+1
	BNE monitor_memasm_single2
	INC sub_write+1
monitor_memasm_single2
monitor_memasm_print
	LDA sub_write+1
	STA command_addr3_low
	LDA sub_write+2
	STA command_addr3_high
	DEC printchar_y
	DEC printchar_y
	DEC printchar_y
	DEC printchar_y
	LDA command_addr1_low
	STA command_addr2_low
	LDA command_addr1_high
	STA command_addr2_high
	LDA command_addr3_low
	PHA
	LDA command_addr3_high
	PHA
	JSR monitor_memlist
	PLA
	STA command_addr1_high
	PLA
	STA command_addr1_low
	LDA #$00 ; not error
	RTS


monitor_memhelp_text
	.BYTE "Acolyte "
	.BYTE "Monitor "
	.BYTE "        "
	.BYTE "ESC to B"
	.BYTE "reak",$0D,$0D
	.BYTE "Display",$0D
	.BYTE "  AAAA.B"
	.BYTE "BBB [L]",$0D
	.BYTE "Modify",$0D
	.BYTE "  AAAA",$3A,"B"
	.BYTE "B 'C",$0D
	.BYTE "Move/Ver"
	.BYTE "ify/Writ"
	.BYTE "e/Read",$0D
	.BYTE "  AAAA<B"
	.BYTE "BBB.CCCC"
	.BYTE " MVWR",$0D
	.BYTE "Pack/Sea"
	.BYTE "rch",$0D
	.BYTE "  AA>BBB"
	.BYTE "B.CCCC P"
	.BYTE "S",$0D
	.BYTE "Go/Jump",$0D
	.BYTE "  AAAA G"
	.BYTE "J"
	.BYTE $0D
	.BYTE "@ for A"
	.BYTE "ssembly"
	.BYTE $FF





; spi_base_delay sub-routine
; short delay for spi stuff
; I could delay in other ways, but hey, this works
spi_base_delay
	PHA
	PHX
	LDA #$FF
	LDX #$08				; arbitrary values to make it shorter or longer
spi_base_delay_loop
	DEC A
	BNE spi_base_delay_loop
	DEX
	BNE spi_base_delay_loop
	PLX
	PLA
	RTS

; spi_base_delay sub-routine
; long delay for spi stuff
; I could delay in other ways, but hey, this works
spi_base_longdelay
	PHA
	PHX
	PHY
	LDA #$FF
	LDX #$80
	LDY #$01				; arbitrary values to make it shorter or longer
spi_base_longdelay_loop
	DEC A
	BNE spi_base_longdelay_loop
	DEX
	BNE spi_base_longdelay_loop
	DEY
	BNE spi_base_longdelay_loop
	PLY
	PLX
	PLA
	RTS

spi_base_enable
	PHA
	LDA output_byte
	AND spi_cs_enable			; this enables only whatever CS lines were designated in spi_cs_enable
	STA output_byte
	STA $FFFF ; write to ROM sends to output
	PLA
	RTS

spi_base_disable
	PHA

	LDA spi_cs_enable
	EOR #$FF
	STA spi_cs_enable
	LDA output_byte
	ORA spi_cs_enable
	STA output_byte
	STA $FFFF
	LDA spi_cs_enable
	EOR #$FF
	STA spi_cs_enable

	;LDA output_byte
	;ORA #%10001100				; this disables ALL SPI modules
	;STA output_byte
	;STA $FFFF ; write to ROM sends to output

	PLA
	RTS

spi_base_send_zero
	LDA output_byte
	AND spi_cs_enable
	AND #%11111100				; already enabled, send zero on MOSI
	STA output_byte
	STA $FFFF ; write to ROM sends to output
	INC A					; INC/DEC to trigger the clock
	STA $FFFF
	DEC A
	STA $FFFF
	RTS

spi_base_send_one
	LDA output_byte
	AND spi_cs_enable
	AND #%11111100				; already enabled, send one on MOSI
	ORA #%00000010
	STA output_byte
	STA $FFFF ; write to ROM sends to output
	INC A					; INC/DEC to trigger the clock
	STA $FFFF
	DEC A
	STA $FFFF
	RTS

spi_base_send_byte
	PHX
	LDX #$08				; 8 bits in a byte
spi_base_send_loop
	ROL A
	BCC spi_base_send_jump
	PHA
	JSR spi_base_send_one			; send a 1 bit
	PLA
	JMP spi_base_send_done
spi_base_send_jump
	PHA
	JSR spi_base_send_zero			; send a 0 bit
	PLA
spi_base_send_done
	DEX
	CPX #$00
	BNE spi_base_send_loop			; repeat until all 8 bits have been transferred
	PLX
	RTS

spi_base_receive_bit
	CLV					; clear overflow flag
	NOP					; wait a few cycles (shouldn't need more than one of these honestly)
	NOP
	NOP
	NOP
	BVC spi_base_receive_bit_jump		; if the overflow flag is still clear, it's a high
	LDA #%00000000				; else, it is a low
	JMP spi_base_receive_bit_clock
spi_base_receive_bit_jump	
	LDA #%11111111
spi_base_receive_bit_clock
	PHA
	LDA output_byte
	INC A					; INC/DEC to trigger the clock
	STA $FFFF
	DEC A
	STA $FFFF
	PLA
	RTS

spi_base_receive_byte
	PHX
	LDA #$00
	LDX #$08				; 8 bits in a byte
spi_base_receive_loop
	CLC
	ROL A					; shift them in one by one
	PHA
	JSR spi_base_receive_bit
	CMP #%11111111				; compare with a 1 bit
	BEQ spi_base_receive_jump
	PLA
	JMP spi_base_receive_done
spi_base_receive_jump
	PLA
	INC A					; this is what a 1 bit looks like, a 0 just does nothing
spi_base_receive_done
	DEX
	CPX #$00
	BNE spi_base_receive_loop		; repeat until all 8 bits have been received
	PLX
	RTS

; waitresult sub-routine
; this has been changed recently, so that $FF is read
; for too long, it will automatically exit with an error
; in the past, it would literally wait until it had a non-$FF value,
; forever!
spi_base_waitresult				; will keep reading bytes as long as $FF,
	PHX
	PHY
	LDX #$FF
	LDY #$08				; arbitrary value to wait shorter or longer
spi_base_waitresult_loop
	DEX
	BNE spi_base_waitresult_continue	; will exit early with $FF if waiting too long, controls should handle it as error
	DEY
	BEQ spi_base_waitresult_exit
spi_base_waitresult_continue
	JSR spi_base_receive_byte		; then will exit with value in accumulator
	CMP #$FF
	BEQ spi_base_waitresult_loop
spi_base_waitresult_exit
	PLY
	PLX
	RTS

; I was told that pumping the SD card is not good procedure,
; but it works, so I do it.
spi_base_pump					; this pumps the clock a lot while everything is disabled
	PHA
	PHX
	LDA output_byte				; both CS and MOSI must be high to work!!!
	ORA #%00001110
	STA output_byte
	STA $FFFF ; write to ROM sends to output				
	JSR spi_base_longdelay			; delay
	LDX #$50
spi_base_pump_loop				; pump sclk 80 times while sdcard is disabled
	LDA output_byte
	INC A
	STA $FFFF
	DEC A
	STA $FFFF
	DEX
	BNE spi_base_pump_loop
	PLX
	PLA
	RTS

	.ORG $CFD0

	.BYTE "Professo"
	.BYTE "r Steven"
	.BYTE "Chad Bur"
	.BYTE "row 2023"
	.BYTE ", Public"
	.BYTE " Domain",$00

	.ORG $D000

; BASIC code below!
; this form of Basic is very... basic.
; it has only 255 line numbers possible, 1-255
; it also only has 8 variables, ABCDWXYZ, but
; each variable is actually an array of 256 values, accessed with ( ).
; each value is only a byte in length, so values of 0-255 are possible.
; the keywords can be simplified down to 1 or 2 letters, and spaces
; are completely optional.  There is no tokenization, so this
; 'data compress' can help fit more code into the limit space in RAM.
; code RAM starts at $9800 and can go until $BEFF, which is HUGE compared
; to what this style of Basic can do, TONS of room!
; again, I will not comment much here, but it all extremely fragile.
; Other things, 
; Using a underscore in PRINT will cause a carriage return,
; as PRINT itself will not do that automatically.
; Hitting Escape while a Basic program is running will stop it on next
; command reached.  This is very handy!
; No errors are ever produced, it will do what is expected, very similar
; to the monitor (but the monitor DOES have some error checking at least!)


basic
	STZ command_mode	
	STZ basic_counter
	LDX #$00
basic_line_number_search
	LDA command_array,X
	INX
	CPX #$28
	BNE basic_line_number_search_ready
	JMP basic_exit
basic_line_number_search_ready
	CMP #"]" ; basic prompt
	BNE basic_line_number_search
basic_line_number_search_found
	LDA command_array,X
	CMP #"?"
	BNE basic_line_number_prompt
	JMP basic_help
basic_line_number_prompt
	; start of inserted text for expanded RAM
	PHA
	STZ $3EFF ; off screen (overscan)
	STZ $BEFF ; bottom of expanded RAM
	LDA #$FF ; load non-zero value
	STA $BEFF ; store in expanded RAM
	LDA $3EFF ; check screen RAM
	BEQ basic_memory_expansion ; if it's still zero, we have expanded RAM for basic
	PLA
	JMP basic_exit ; else, do not run any basic commands
basic_memory_expansion
	PLA
	; end of inserted text for expanded RAM
	CLC
	CMP #$20 ; control characters
	BCS basic_line_number_loop
	INX
	CPX #$28
	BNE basic_line_number_search_found
	JMP basic_exit
basic_line_number_loop
	LDA command_array,X
	CLC
	CMP #$21 ; space + 1
	BCS basic_line_number_loop_ready
	INX
	CPX #$28
	BNE basic_line_number_loop
	JMP basic_exit
basic_line_number_loop_ready
	CLC	
	CMP #"0"
	BCC basic_line_number_exit
	CLC
	CMP #$3A ; colon, one more than '9'
	BCS basic_line_number_exit
	SEC
	SBC #"0"
	PHA
	LDA basic_counter
	CLC
	ROL A
	STA basic_data
	CLC
	ADC basic_data
	CLC
	ADC basic_data
	CLC
	ADC basic_data
	CLC
	ADC basic_data	
	STA basic_counter
	PLA
	CLC
	ADC basic_counter
	STA basic_counter
	INX
	CPX #$28
	BNE basic_line_number_loop
	JMP basic_exit
basic_line_number_exit
	STX basic_first
	LDA basic_counter
	BNE basic_line_number_store
	JMP basic_execute
basic_line_number_store
	LDA #<basic_code
	STA sub_read+1
	LDA #>basic_code
	STA sub_read+2
basic_line_number_store_loop
	JSR sub_read
	CMP #$00 ; break between codes
	BNE basic_line_number_store_increment
	INC sub_read+1
	BNE basic_line_number_store_next
	INC sub_read+2
	LDA sub_read+2
	CMP #>basic_code_error
	BNE basic_line_number_store_next
	JMP basic_exit	
basic_line_number_store_next
	JSR sub_read
	BEQ basic_line_number_insert
	CLC	
	CMP basic_counter
	BCC basic_line_number_store_loop
	BNE basic_line_number_insert
	LDA sub_read+1
	STA basic_addr_low
	LDA sub_read+2
	STA basic_addr_high
	JMP basic_delete_loop
basic_line_number_insert
	LDA sub_read+1
	STA basic_addr_low
	LDA sub_read+2
	STA basic_addr_high
	JMP basic_insert
basic_line_number_store_increment
	INC sub_read+1
	BNE basic_line_number_store_loop
	INC sub_read+2
	LDA sub_read+2
	CMP #>basic_code_error
	BNE basic_line_number_store_loop
	JMP basic_exit

basic_delete_loop
	JSR sub_read
	CMP #$00 ; break between codes
	BEQ basic_delete_ready
	INC sub_read+1
	BNE basic_delete_loop
	INC sub_read+2
	LDA sub_read+2
	CMP #>basic_code_error
	BNE basic_delete_loop
	JMP basic_exit
basic_delete_ready
	LDA basic_addr_low
	STA sub_write+1
	LDA basic_addr_high
	STA sub_write+2
	DEC sub_write+1
	LDA sub_write+1
	CMP #$FF
	BNE basic_delete_new_loop
	DEC sub_write+2
basic_delete_new_loop
	JSR sub_read
	JSR sub_write
	INC sub_read+1
	BNE basic_delete_new_loop_next
	INC sub_read+2
basic_delete_new_loop_next
	INC sub_write+1
	BNE basic_delete_new_loop
	INC sub_write+2
	LDA sub_write+2
	CMP #>basic_code_error
	BNE basic_delete_new_loop
basic_insert
	LDX basic_first
	STZ basic_bytes
basic_insert_loop
	LDA command_array,X
	BEQ basic_insert_increment
	INC basic_bytes
basic_insert_increment
	INX
	CPX #$28
	BNE basic_insert_loop
	LDA basic_bytes
	BNE basic_insert_full
	JMP basic_exit
basic_insert_full 
	INC A
	INC A
	STA basic_bytes
	LDA basic_addr_high
	STA command_addr3_high
	LDA basic_addr_low
	CLC
	ADC basic_bytes
	STA command_addr3_low
	BCC basic_insert_ready
	INC command_addr3_high
	LDA command_addr3_high
	CMP #>basic_code_error
	BNE basic_insert_ready
	JMP basic_exit
basic_insert_ready
	LDA #<basic_code_end
	STA sub_write+1
	STA sub_read+1
	LDA #>basic_code_end
	STA sub_write+2
	STA sub_read+2
	LDA sub_read+1
	SEC
	SBC basic_bytes
	STA sub_read+1
	BCS basic_insert_copy
	DEC sub_read+2
basic_insert_copy
	JSR sub_read
	JSR sub_write
	LDA sub_read+2
	CMP basic_addr_high
	BNE basic_insert_copy_increment
	LDA sub_read+1
	CMP basic_addr_low
	BNE basic_insert_copy_increment
	JMP basic_insert_moved
basic_insert_copy_increment
	DEC sub_read+1
	LDA sub_read+1
	CMP #$FF
	BNE basic_insert_copy_next
	DEC sub_read+2
basic_insert_copy_next
	DEC sub_write+1
	LDA sub_write+1
	CMP #$FF
	BNE basic_insert_copy
	DEC sub_write+2
	JMP basic_insert_copy
basic_insert_moved
	LDX basic_first
	LDA basic_addr_low
	STA sub_write+1
	LDA basic_addr_high
	STA sub_write+2
	LDA basic_counter
	JSR sub_write
	INC sub_write+1
	BNE basic_insert_moved_loop
	INC sub_write+2
basic_insert_moved_loop
	LDA command_array,X
	INX
	CPX #$28
	BNE basic_insert_moved_going
	JMP basic_insert_exit
basic_insert_moved_going
	CMP #$00 ; needed!
	BEQ basic_insert_moved_loop
	JSR sub_write
	INC sub_write+1
	BNE basic_insert_moved_loop
	INC sub_write+2
	JMP basic_insert_moved_loop
basic_insert_exit
	LDA #$00
	JSR sub_write
	JMP basic_exit

basic_help
	LDA #$0D ; carriage return
	JSR printchar
	LDA #<basic_help_text
	STA command_addr3_low
	LDA #>basic_help_text
	STA command_addr3_high
basic_help_loop
	JSR inputchar
	CMP #$00
	BEQ basic_help_skip
	CMP #$1B ; escape
	BNE basic_help_skip
	JMP basic_help_exit
basic_help_skip
	LDA command_addr3_low
	STA sub_read+1
	LDA command_addr3_high
	STA sub_read+2
	JSR sub_read
	CMP #$FF
	BEQ basic_help_exit
	JSR printchar
	INC command_addr3_low
	BNE basic_help_loop
	INC command_addr3_high
	JMP basic_help_loop
basic_help_exit
	LDA #$0D ; carriage return
	JSR printchar
	JMP basic_exit

basic_help_text
	.BYTE "Acolyte "
	.BYTE "BASIC   "
	.BYTE "        "
	.BYTE "ESC to B"
	.BYTE "reak",$0D,$0D
	.BYTE "Line num"
	.BYTE "bers fro"
	.BYTE "m 1 to 2"
	.BYTE "55.",$0D
	.BYTE "Variable"
	.BYTE " arrays",$3A
	.BYTE " ABCDWXY"
	.BYTE "Z! with "
	.BYTE "()",$0D
	.BYTE "Math ope"
	.BYTE "rators",$3A
	.BYTE " +-*/%",$0D
	.BYTE "Compar"
	.BYTE "ator ope"
	.BYTE "rators",$3A
	.BYTE " =#<>",$0D
	.BYTE "Keywords"
	.BYTE " are",$3A
	.BYTE " PRINT, "
	.BYTE "INPUT,",$0D
	.BYTE "    IF.."
	.BYTE "THEN, & "
	.BYTE "GOTO.",$0D
	.BYTE "Commands"
	.BYTE " are",$3A
	.BYTE " LIST & "
	.BYTE "RUN",$0D,$0D
	.BYTE "Example "
	.BYTE "primes p"
	.BYTE "rogram",$3A,$0D
	.BYTE "1 PRINT"
	.BYTE " ",$22
	.BYTE "INPUT NU"
	.BYTE "M ",$22
	.BYTE " ",$3A
	.BYTE " INPUT X"
	.BYTE $0D
	.BYTE "2 A = 2"
	.BYTE $0D
	.BYTE "3 PRINT"
	.BYTE " A ",$3A
	.BYTE " PRINT "
	.BYTE $22,"_",$22,$0D
	.BYTE "4 A = A"
	.BYTE " + 1 ",$3A
	.BYTE " IF A > "
	.BYTE "X THEN G"
	.BYTE "OTO 255",$0D
	.BYTE "5 C = A"
	.BYTE " - 1",$0D
	.BYTE "6 IF A "
	.BYTE "% C = 0 "
	.BYTE "THEN GOT"
	.BYTE "O 4",$0D
	.BYTE "7 C = C"
	.BYTE " - 1",$0D
	.BYTE "8 IF C "
	.BYTE "= 1 THEN"
	.BYTE " GOTO 3"
	.BYTE $0D
	.BYTE "9 GOTO "
	.BYTE "6",$0D
	.BYTE "LIST",$0D
	.BYTE "RUN"
	.BYTE $FF

basic_execute
	LDX basic_first
basic_execute_loop
	LDA command_array,X
	INX
	CPX #$28
	BNE basic_execute_loop_ready
	JMP basic_exit
basic_execute_loop_ready
	CMP #" "
	BEQ basic_execute_loop
	CMP #"L" ; list
	BNE basic_execute_loop_next
	STX basic_first
	JMP basic_list
basic_execute_loop_next
	CMP #"R" ; run
	BNE basic_execute_loop
	STX basic_first
	JMP basic_run


basic_list
	STZ basic_counter
	STZ basic_data
	LDX #$00
basic_list_number_loop
	LDA command_array,X
	CMP #","
	BNE basic_list_number_ready
	JMP basic_list_second
basic_list_number_ready
	CLC	
	CMP #"0"
	BCC basic_list_number_increment
	CLC
	CMP #$3A ; colon, one more than '9'
	BCS basic_list_number_increment
	SEC
	SBC #"0"
	PHA
	LDA basic_counter
	CLC
	ROL A
	STA basic_data
	CLC
	ADC basic_data
	CLC
	ADC basic_data
	CLC
	ADC basic_data
	CLC
	ADC basic_data	
	STA basic_counter
	PLA
	CLC
	ADC basic_counter
	STA basic_counter
basic_list_number_increment	
	INX
	CPX #$28
	BNE basic_list_number_loop
	LDA basic_counter
	BNE basic_list_number_whole
	LDA #$FF
	STA basic_data
	JMP basic_list_start
basic_list_number_whole
	STA basic_data
	JMP basic_list_start
basic_list_second
	LDA basic_counter
	STA basic_first
	STZ basic_counter
	STZ basic_data
basic_list_second_loop
	LDA command_array,X
	CLC	
	CMP #"0"
	BCC basic_list_second_increment
	CLC
	CMP #$3A ; colon, one more than '9'
	BCS basic_list_second_increment
	SEC
	SBC #"0"
	PHA
	LDA basic_counter
	CLC
	ROL A
	STA basic_data
	CLC
	ADC basic_data
	CLC
	ADC basic_data
	CLC
	ADC basic_data
	CLC
	ADC basic_data	
	STA basic_counter
	PLA
	CLC
	ADC basic_counter
	STA basic_counter
basic_list_second_increment	
	INX
	CPX #$28
	BNE basic_list_second_loop
	LDA basic_counter
	STA basic_data
	LDA basic_first
	STA basic_counter
	LDA basic_data
	BNE basic_list_start
	LDA #$FF
	STA basic_data
basic_list_start
	LDA #<basic_code
	STA sub_read+1
	LDA #>basic_code
	STA sub_read+2
basic_list_loop
	JSR inputchar
	CMP #$1B ; escape
	BNE basic_list_okay
	;LDA #$0D ; carriage return
	;JSR printchar
	JMP basic_exit
basic_list_okay
	JSR sub_read
	BEQ basic_list_loop_found
	JMP basic_list_loop_increment
basic_list_loop_found
	INC sub_read+1
	BNE basic_list_loop_ready
	INC sub_read+2
basic_list_loop_ready
	JSR sub_read
	BNE basic_list_loop_blank
	JMP basic_exit
basic_list_loop_blank
	CLC
	CMP basic_counter
	BCC basic_list_loop_increment
	CLC
	CMP basic_data
	BEQ basic_list_loop_print
	BCS basic_list_loop_increment
basic_list_loop_print
	PHA
	LDA sub_read+1
	STA basic_addr_low
	LDA sub_read+2
	STA basic_addr_high
	LDA #$0D ; carriage return
	JSR printchar
	PLX
	LDA decimal_conversion_high,X
	JSR printchar
	LDA decimal_conversion_middle,X
	JSR printchar
	LDA decimal_conversion_low,X
	JSR printchar
	LDA #" "
	JSR printchar
basic_list_loop_print_inc
	INC basic_addr_low
	BNE basic_list_loop_print_chars
	INC basic_addr_high
	LDA basic_addr_high
	CMP #>basic_code_error
	BNE basic_list_loop_print_chars
	JMP basic_exit
basic_list_loop_print_chars
	LDA basic_addr_low
	STA sub_read+1
	LDA basic_addr_high
	STA sub_read+2
	JSR sub_read
	BEQ basic_list_loop_complete
	JSR printchar
	JMP basic_list_loop_print_inc
basic_list_loop_complete
	LDA basic_addr_low
	STA sub_read+1
	LDA basic_addr_high
	STA sub_read+2
	JMP basic_list_loop_continue
basic_list_loop_increment
	INC sub_read+1
	BNE basic_list_loop_continue
	INC sub_read+2
	LDA sub_read+2
	CMP #>basic_code_error
	BNE basic_list_loop_continue
	JMP basic_exit
basic_list_loop_continue
	JMP basic_list_loop

basic_run
	LDA #$0D ; carriage return
	JSR printchar
	STZ basic_counter
	STZ basic_data
	STZ basic_colon
	STZ basic_counter_change
	LDX #$00
basic_run_number_loop
	LDA command_array,X
	CLC	
	CMP #"0"
	BCC basic_run_number_increment
	CLC
	CMP #$3A ; colon, one more than '9'
	BCS basic_run_number_increment
	SEC
	SBC #"0"
	PHA
	LDA basic_counter
	CLC
	ROL A
	STA basic_data
	CLC
	ADC basic_data
	CLC
	ADC basic_data
	CLC
	ADC basic_data
	CLC
	ADC basic_data	
	STA basic_counter
	PLA
	CLC
	ADC basic_counter
	STA basic_counter
basic_run_number_increment	
	INX
	CPX #$28
	BNE basic_run_number_loop
basic_run_start
	LDA basic_counter
	BNE basic_run_addresses
	INC basic_counter
basic_run_addresses
	LDA #<basic_code
	STA sub_read+1
	LDA #>basic_code
	STA sub_read+2
basic_run_loop
	JSR inputchar
	CMP #$1B ; escape
	BNE basic_run_okay1
	;LDA #$0D ; carriage return
	;JSR printchar
	JMP basic_exit
basic_run_okay1
	JSR sub_read
	CMP #$00 ; delimiter
	BNE basic_run_increment
	INC sub_read+1
	BNE basic_run_loop_ready
	INC sub_read+2
	LDA sub_read+2
	CMP #>basic_code_error
	BNE basic_run_loop_ready
	INC basic_counter
	BNE basic_run_start
	JMP basic_exit
basic_run_loop_ready
	JSR sub_read
	CMP basic_counter
	BNE basic_run_increment
basic_run_interpret
	LDX sub_read+1
	PHX
	LDY sub_read+2
	PHY
	JSR basic_interpret
	PLY
	STY sub_read+2
	PLX
	STX sub_read+1
	LDA inputchar_value
	CMP #$1B ; escape
	BNE basic_run_okay2
	;LDA #$0D ; carriage return
	;JSR printchar
	JMP basic_exit
basic_run_okay2
	LDA basic_colon
	BEQ basic_run_colon
	STZ basic_colon
	JMP basic_run_interpret
basic_run_colon
	LDA basic_counter_change
	BEQ basic_run_change
	STA basic_counter
	STZ basic_counter_change
	JMP basic_run_start
basic_run_change
	INC basic_counter
	BNE basic_run_increment
	JMP basic_exit
basic_run_increment
	INC sub_read+1
	BEQ basic_run_back1
	JMP basic_run_loop
basic_run_back1
	INC sub_read+2
	LDA sub_read+2
	CMP #>basic_code_error
	BEQ basic_run_back2
	JMP basic_run_loop
basic_run_back2
	INC basic_counter
	BEQ basic_run_leave
	JMP basic_run_start
basic_run_leave
	JMP basic_exit


basic_interpret
	STX sub_index+1
	STY sub_index+2
	LDX #$01
basic_interpret_loop
	JSR sub_index
	CMP #$00 ; delimiter
	BNE basic_interpret_ready
	JMP basic_interpret_exit
basic_interpret_ready
	CMP #"A"
	BNE basic_interpret_next1
	JMP basic_set
basic_interpret_next1
	CMP #"B"
	BNE basic_interpret_next2
	JMP basic_set
basic_interpret_next2
	CMP #"C"
	BNE basic_interpret_next3
	JMP basic_set
basic_interpret_next3
	CMP #"D"
	BNE basic_interpret_next4
	JMP basic_set
basic_interpret_next4
	CMP #"W"
	BNE basic_interpret_next5
	JMP basic_set
basic_interpret_next5
	CMP #"X"
	BNE basic_interpret_next6
	JMP basic_set
basic_interpret_next6
	CMP #"Y"
	BNE basic_interpret_next7
	JMP basic_set
basic_interpret_next7
	CMP #"Z"
	BNE basic_interpret_next8
	JMP basic_set
basic_interpret_next8
	CMP #"I"
	BNE basic_interpret_next10
	INX
	CPX #$FF
	BEQ basic_interpret_exit
	JSR sub_index
	CMP #"F" ; if statement
	BNE basic_interpret_next9
	JMP basic_if
basic_interpret_next9
	CMP #"N" ; input statement
	BNE basic_interpret_loop
	JMP basic_input
basic_interpret_next10
	CMP #"G" ; goto statement
	BNE basic_interpret_next11
	JMP basic_goto
basic_interpret_next11
	CMP #"P" ; print statement
	BNE basic_interpret_next12
	JMP basic_print
basic_interpret_next12
	; put more commands here!
	INX
	CPX #$FF
	BNE basic_interpret_loop
basic_interpret_exit
	RTS


basic_set
	STZ basic_data
	STZ basic_addr_low
	STA basic_addr_high
	INX
basic_set_loop
	JSR sub_index
	CMP #$00 ; delimiter
	BNE basic_set_ready
	JMP basic_set_expected_exit
basic_set_ready
	CMP #"("
	BEQ basic_set_array_loop
	CMP #"="
	BNE basic_set_equals
	JMP basic_set_expected_value
basic_set_equals
	INX
	CPX #$FF
	BNE basic_set_loop
	JMP basic_set_expected_exit
basic_set_array_loop
	JSR sub_index
	CMP #$00 ; delimiter
	BNE basic_set_array_ready
	JMP basic_set_expected_exit
basic_set_array_ready
	CMP #")"
	BEQ basic_set_loop
	CMP #"A"
	BEQ basic_set_array_variable
	CMP #"B"
	BEQ basic_set_array_variable
	CMP #"C"
	BEQ basic_set_array_variable
	CMP #"D"
	BEQ basic_set_array_variable
	CMP #"W"
	BEQ basic_set_array_variable
	CMP #"X"
	BEQ basic_set_array_variable
	CMP #"Y"
	BEQ basic_set_array_variable
	CMP #"Z"
	BEQ basic_set_array_variable
	CLC	
	CMP #"0"
	BCC basic_set_array_increment
	CLC
	CMP #$3A ; colon, one more than '9'
	BCS basic_set_array_increment
	SEC
	SBC #"0"
	PHA
	LDA basic_addr_low
	CLC
	ROL A
	STA basic_bytes
	CLC
	ADC basic_bytes
	CLC
	ADC basic_bytes
	CLC
	ADC basic_bytes
	CLC
	ADC basic_bytes	
	STA basic_addr_low
	PLA
	CLC
	ADC basic_addr_low
	STA basic_addr_low
basic_set_array_increment
	INX
	CPX #$FF
	BNE basic_set_array_loop	
	JMP basic_set_expected_exit
basic_set_array_variable
	STZ sub_read+1
	CMP #"A"
	BNE basic_set_array_next1
	LDA #>basic_A
	STA sub_read+2
	JMP basic_set_array_value
basic_set_array_next1
	CMP #"B"
	BNE basic_set_array_next2
	LDA #>basic_B
	STA sub_read+2
	JMP basic_set_array_value
basic_set_array_next2
	CMP #"C"
	BNE basic_set_array_next3
	LDA #>basic_C
	STA sub_read+2
	JMP basic_set_array_value
basic_set_array_next3
	CMP #"D"
	BNE basic_set_array_next4
	LDA #>basic_D
	STA sub_read+2
	JMP basic_set_array_value
basic_set_array_next4
	CMP #"W"
	BNE basic_set_array_next5
	LDA #>basic_W
	STA sub_read+2
	JMP basic_set_array_value
basic_set_array_next5
	CMP #"X"
	BNE basic_set_array_next6
	LDA #>basic_X
	STA sub_read+2
	JMP basic_set_array_value
basic_set_array_next6
	CMP #"Y"
	BNE basic_set_array_next7
	LDA #>basic_Y
	STA sub_read+2
	JMP basic_set_array_value
basic_set_array_next7
	CMP #"Z"
	BNE basic_set_array_value
	LDA #>basic_Z
	STA sub_read+2
basic_set_array_value
	JSR sub_read
	STA basic_addr_low
	JMP basic_set_array_increment
basic_set_expected_value
	INX
	CPX #$FF
	BEQ basic_set_expected_exit
	JSR basic_expect
basic_set_expected_exit
	LDA basic_addr_low
	STA sub_write+1
	LDA basic_addr_high
	CMP #"A"
	BNE basic_set_exit_next1
	LDA #>basic_A
	STA sub_write+2
	JMP basic_set_final
basic_set_exit_next1
	CMP #"B"
	BNE basic_set_exit_next2
	LDA #>basic_B
	STA sub_write+2
	JMP basic_set_final
basic_set_exit_next2
	CMP #"C"
	BNE basic_set_exit_next3
	LDA #>basic_C
	STA sub_write+2
	JMP basic_set_final
basic_set_exit_next3
	CMP #"D"
	BNE basic_set_exit_next4
	LDA #>basic_D
	STA sub_write+2
	JMP basic_set_final
basic_set_exit_next4
	CMP #"W"
	BNE basic_set_exit_next5
	LDA #>basic_W
	STA sub_write+2
	JMP basic_set_final
basic_set_exit_next5
	CMP #"X"
	BNE basic_set_exit_next6
	LDA #>basic_X
	STA sub_write+2
	JMP basic_set_final
basic_set_exit_next6
	CMP #"Y"
	BNE basic_set_exit_next7
	LDA #>basic_Y
	STA sub_write+2
	JMP basic_set_final
basic_set_exit_next7
	CMP #"Z"
	BNE basic_set_exit_next8
	LDA #>basic_Z
	STA sub_write+2
	JMP basic_set_final
basic_set_exit_next8
	RTS
basic_set_final
	LDA basic_data
	JSR sub_write
	RTS


basic_expect
	STZ basic_data
	STZ basic_first
	STZ basic_bytes
	STZ basic_var_low
	STZ basic_var_high
	STZ basic_nested
	LDA #"+"
	STA basic_operator
	LDA #"+"
	STA basic_next
basic_expect_loop
	JSR sub_index
	CMP #$00 ; delimiter
	BNE basic_expect_check
	JMP basic_expect_exit
basic_expect_check
	CMP #$3A ; colon
	BNE basic_expect_colon
	INC basic_colon
	PLA
	STA basic_rts_low1
	PLA
	STA basic_rts_high1
	PLA
	STA basic_rts_low2
	PLA
	STA basic_rts_high2
	PLA
	PLA
	TXA
	CLC
	ADC sub_index+1
	BCC basic_expect_shift
	PHA
	LDA sub_index+2
	INC A
	PHA
	LDA basic_rts_high2
	PHA
	LDA basic_rts_low2
	PHA
	LDA basic_rts_high1
	PHA
	LDA basic_rts_low1
	PHA
	JMP basic_expect_exit
basic_expect_shift
	PHA
	LDA sub_index+2
	PHA
	LDA basic_rts_high2
	PHA
	LDA basic_rts_low2
	PHA
	LDA basic_rts_high1
	PHA
	LDA basic_rts_low1
	PHA
	JMP basic_expect_exit
basic_expect_colon
	CMP #"="
	BEQ basic_expect_exit_jump
	CMP #"#"
	BEQ basic_expect_exit_jump
	CMP #"<"
	BEQ basic_expect_exit_jump
	CMP #">"
	BEQ basic_expect_exit_jump
	CMP #"T"
	BEQ basic_expect_exit_jump
	CMP #$22 ; double quotes
	BEQ basic_expect_quotes
	CMP #"("
	BNE basic_expect_ready1
	INC basic_nested
	JMP basic_expect_increment
basic_expect_exit_jump
	JMP basic_expect_exit
basic_expect_quotes
	INC basic_quotes
	JMP basic_expect_increment
basic_expect_ready1
	CMP #")"
	BNE basic_expect_ready2
	DEC basic_nested
	JMP basic_expect_increment
basic_expect_ready2
	CMP #"+"
	BNE basic_expect_ready3
	STA basic_next
	JMP basic_expect_operator
basic_expect_ready3
	CMP #"-"
	BNE basic_expect_ready4
	STA basic_next
	JMP basic_expect_operator
basic_expect_ready4
	CMP #"*"
	BNE basic_expect_ready5
	STA basic_next
	JMP basic_expect_operator
basic_expect_ready5
	CMP #"/"
	BNE basic_expect_ready6
	STA basic_next
	JMP basic_expect_operator
basic_expect_ready6
	CMP #"%"
	BNE basic_expect_ready7
	STA basic_next
	JMP basic_expect_operator
basic_expect_ready7
	CMP #" " ; ignore spaces?
	BNE basic_expect_ready8
	JMP basic_expect_increment
basic_expect_ready8
	CMP #"!" ; random number
	BNE basic_expect_var_letters
	LDA basic_nested
	BNE basic_expect_ready9
	CLC
	JSR basic_sub_random
	STA basic_data
	JMP basic_expect_increment
basic_expect_ready9
	CLC
	JSR basic_sub_random
	STA basic_var_low
	JMP basic_expect_increment
basic_expect_var_letters
	CMP #"A"
	BEQ basic_expect_var_jump
	CMP #"B"
	BEQ basic_expect_var_jump
	CMP #"C"
	BEQ basic_expect_var_jump
	CMP #"D"
	BEQ basic_expect_var_jump
	CMP #"W"
	BEQ basic_expect_var_jump
	CMP #"X"
	BEQ basic_expect_var_jump
	CMP #"Y"
	BEQ basic_expect_var_jump
	CMP #"Z"
	BEQ basic_expect_var_jump
	JMP basic_expect_step
basic_expect_var_jump
	JMP basic_expect_variable
basic_expect_step
	CLC	
	CMP #"0"
	BCS basic_expect_continue1
	JMP basic_expect_increment
basic_expect_continue1
	CLC
	CMP #$3A ; colon, one more than '9'
	BCC basic_expect_continue2
	JMP basic_expect_increment
basic_expect_continue2
	SEC
	SBC #"0"
	PHA
	LDA basic_nested
	BNE basic_expect_continue3
	LDA basic_data
	JMP basic_expect_continue4
basic_expect_continue3
	LDA basic_var_low
basic_expect_continue4
	CLC
	ROL A
	STA basic_bytes
	CLC
	ADC basic_bytes
	CLC
	ADC basic_bytes
	CLC
	ADC basic_bytes
	CLC
	ADC basic_bytes
	STA basic_bytes
	PLA
	CLC
	ADC basic_bytes
	STA basic_bytes
	LDA basic_nested
	BNE basic_expect_continue5
	LDA basic_bytes
	STA basic_data
	JMP basic_expect_increment
basic_expect_continue5
	LDA basic_bytes
	STA basic_var_low
basic_expect_increment
	INX
	CPX #$FF
	BEQ basic_expect_exit
	JMP basic_expect_loop
basic_expect_exit
	LDA basic_var_high
	BEQ basic_expect_math	
	STA sub_read+2
	LDA basic_var_low
	STA sub_read+1
	JSR sub_read
	STA basic_data
basic_expect_math
	LDA basic_operator
	CMP #"+"
	BNE basic_expect_final_next1
	LDA basic_first
	CLC
	ADC basic_data
	STA basic_data
	JMP basic_expect_return
basic_expect_final_next1
	CMP #"-"
	BNE basic_expect_final_next2
	LDA basic_first
	SEC
	SBC basic_data
	STA basic_data
	JMP basic_expect_return
basic_expect_final_next2
	CMP #"*"
	BNE basic_expect_final_next3
	JSR basic_multiply
	JMP basic_expect_return
basic_expect_final_next3
	CMP #"/"
	BNE basic_expect_final_next4
	JSR basic_divide
	JMP basic_expect_return
basic_expect_final_next4
	CMP #"%"
	BNE basic_expect_return
	JSR basic_modulus
	JMP basic_expect_return
basic_expect_return
	RTS
basic_expect_variable
	PHA
	LDA basic_nested
	BNE basic_expect_array
	PLA
	CMP #"A"
	BNE basic_expect_variable_next1
	LDA #>basic_A
	STA basic_var_high
	JMP basic_expect_increment
basic_expect_variable_next1
	CMP #"B"
	BNE basic_expect_variable_next2
	LDA #>basic_B
	STA basic_var_high
	JMP basic_expect_increment
basic_expect_variable_next2
	CMP #"C"
	BNE basic_expect_variable_next3
	LDA #>basic_C
	STA basic_var_high
	JMP basic_expect_increment
basic_expect_variable_next3
	CMP #"D"
	BNE basic_expect_variable_next4
	LDA #>basic_D
	STA basic_var_high
	JMP basic_expect_increment
basic_expect_variable_next4
	CMP #"W"
	BNE basic_expect_variable_next5
	LDA #>basic_W
	STA basic_var_high
	JMP basic_expect_increment
basic_expect_variable_next5
	CMP #"X"
	BNE basic_expect_variable_next6
	LDA #>basic_X
	STA basic_var_high
	JMP basic_expect_increment
basic_expect_variable_next6
	CMP #"Y"
	BNE basic_expect_variable_next7
	LDA #>basic_Y
	STA basic_var_high
	JMP basic_expect_increment
basic_expect_variable_next7
	CMP #"Z"
	BNE basic_expect_variable_next8
	LDA #>basic_Z
	STA basic_var_high
basic_expect_variable_next8
	JMP basic_expect_increment
basic_expect_array
	PLA
	CMP #"A"
	BNE basic_expect_array_next1
	STZ sub_read+1
	LDA #>basic_A
	STA sub_read+2
	JSR sub_read
	STA basic_var_low
	JMP basic_expect_increment
basic_expect_array_next1
	CMP #"B"
	BNE basic_expect_array_next2
	STZ sub_read+1
	LDA #>basic_B
	STA sub_read+2
	JSR sub_read
	STA basic_var_low
	JMP basic_expect_increment
basic_expect_array_next2
	CMP #"C"
	BNE basic_expect_array_next3
	STZ sub_read+1
	LDA #>basic_C
	STA sub_read+2
	JSR sub_read
	STA basic_var_low
	JMP basic_expect_increment
basic_expect_array_next3
	CMP #"D"
	BNE basic_expect_array_next4
	STZ sub_read+1
	LDA #>basic_D
	STA sub_read+2
	JSR sub_read
	STA basic_var_low
	JMP basic_expect_increment
basic_expect_array_next4
	CMP #"W"
	BNE basic_expect_array_next5
	STZ sub_read+1
	LDA #>basic_W
	STA sub_read+2
	JSR sub_read
	STA basic_var_low
	JMP basic_expect_increment
basic_expect_array_next5
	CMP #"X"
	BNE basic_expect_array_next6
	STZ sub_read+1
	LDA #>basic_X
	STA sub_read+2
	JSR sub_read
	STA basic_var_low
	JMP basic_expect_increment
basic_expect_array_next6
	CMP #"Y"
	BNE basic_expect_array_next7
	STZ sub_read+1
	LDA #>basic_Y
	STA sub_read+2
	JSR sub_read
	STA basic_var_low
	JMP basic_expect_increment
basic_expect_array_next7
	CMP #"Z"
	BNE basic_expect_array_next8
	STZ sub_read+1
	LDA #>basic_Z
	STA sub_read+2
	JSR sub_read
	STA basic_var_low
basic_expect_array_next8
	JMP basic_expect_increment
basic_expect_operator
	LDA basic_var_high
	BEQ basic_expect_operator_skip
	STA sub_read+2
	LDA basic_var_low
	STA sub_read+1
	JSR sub_read
	STA basic_data
basic_expect_operator_skip
	LDA basic_operator
	CMP #"+"
	BNE basic_expect_operator_next1
	LDA basic_first
	CLC
	ADC basic_data
	STA basic_data
	JMP basic_expect_operator_last
basic_expect_operator_next1
	CMP #"-"
	BNE basic_expect_operator_next2
	LDA basic_first
	SEC
	SBC basic_data
	STA basic_data
	JMP basic_expect_operator_last
basic_expect_operator_next2
	CMP #"*"
	BNE basic_expect_operator_next3
	JSR basic_multiply
	JMP basic_expect_return
basic_expect_operator_next3
	CMP #"/"
	BNE basic_expect_operator_next4
	JSR basic_divide
	JMP basic_expect_return
basic_expect_operator_next4
	CMP #"%"
	BNE basic_expect_operator_last
	JSR basic_modulus
	JMP basic_expect_return
basic_expect_operator_last
	LDA basic_next
	STA basic_operator
	STZ basic_var_high	
	STZ basic_var_low
	LDA basic_data
	STA basic_first
	STZ basic_data
	JMP basic_expect_increment

basic_multiply
	LDY basic_first
	BEQ basic_multiply_zero
	DEY
	LDA basic_data
	STA basic_bytes
basic_multiply_loop
	CPY #$00
	BEQ basic_multiply_exit	
	DEY
	LDA basic_bytes
	CLC
	ADC basic_data
	STA basic_bytes
	JMP basic_multiply_loop
basic_multiply_zero
	STZ basic_bytes
basic_multiply_exit
	LDA basic_bytes
	STA basic_data
	RTS

basic_divide
	STZ basic_bytes
	LDA basic_data
	BEQ basic_divide_zero
basic_divide_loop
	LDA basic_first
	SEC
	SBC basic_data
	STA basic_first
	BCC basic_divide_exit
	INC basic_bytes
	JMP basic_divide_loop
basic_divide_zero
	LDA #$FF
	STA basic_bytes ; should be infinity
basic_divide_exit
	LDA basic_bytes
	STA basic_data
	RTS

basic_modulus
	LDA basic_data
	BEQ basic_modulus_zero
basic_modulus_loop
	LDA basic_first
	STA basic_bytes
	SEC
	SBC basic_data
	STA basic_first
	BCC basic_modulus_exit
	JMP basic_modulus_loop
basic_modulus_zero
	LDA #$FF
	STA basic_bytes ; should be infinity
basic_modulus_exit
	LDA basic_bytes
	STA basic_data
	RTS
	RTS


basic_if
	STZ basic_data
	STZ basic_compare_first
	STZ basic_compare_second
	LDA #"="
	STA basic_compare_operator
	INX
	CPX #$FF
	BNE basic_if_continue1
	JMP basic_if_exit
basic_if_continue1
	JSR basic_expect
	LDA basic_data
	STA basic_compare_first
	JSR sub_index
	STA basic_compare_operator
	INX
	CPX #$FF
	BNE basic_if_continue2
	JMP basic_if_exit
basic_if_continue2
	JSR basic_expect
	LDA basic_data
	STA basic_compare_second
	LDA basic_compare_operator
	CMP #"="
	BNE basic_if_next1
	LDA basic_compare_first
	CMP basic_compare_second
	BNE basic_if_exit
	JMP basic_if_counter
basic_if_next1
	CMP #"#"
	BNE basic_if_next2
	LDA basic_compare_first
	CMP basic_compare_second
	BEQ basic_if_exit
	JMP basic_if_counter
basic_if_next2
	CMP #"<"
	BNE basic_if_next3
	LDA basic_compare_first
	CLC
	CMP basic_compare_second
	BCS basic_if_exit
	JMP basic_if_counter
basic_if_next3
	CMP #">"
	BNE basic_if_exit
	LDA basic_compare_second
	CLC
	CMP basic_compare_first
	BCS basic_if_exit
basic_if_counter
	INC basic_colon
	PLA
	STA basic_rts_low2
	PLA
	STA basic_rts_high2
	PLA
	PLA
	TXA
	CLC
	ADC sub_index+1
	BCC basic_if_shift
	PHA
	LDA sub_index+2
	INC A
	PHA
	LDA basic_rts_high2
	PHA
	LDA basic_rts_low2
	PHA
	JMP basic_if_exit
basic_if_shift
	PHA
	LDA sub_index+2
	PHA
	LDA basic_rts_high2
	PHA
	LDA basic_rts_low2
	PHA
basic_if_exit	
	RTS


basic_goto
	STZ basic_data
	INX
	CPX #$FF
	BEQ basic_goto_exit
	JSR basic_expect
	JSR sub_index
	CMP #"T"
	BNE basic_goto_complete
	INX
	CPX #$FF
	BEQ basic_goto_exit
	JSR basic_expect
basic_goto_complete
	LDA basic_data
	STA basic_counter_change
basic_goto_exit
	RTS


basic_input
	LDA #$04 ; unused mode?
	STA command_mode
	LDA #$0D ; carriage return
	JSR printchar
	LDA #"?"
	JSR printchar
	STZ basic_addr_low
	STZ basic_addr_high
	STZ basic_data
	STZ basic_bytes
	LDY #$07
basic_input_clear
	LDA #$00
	STA basic_user_array,Y
	CPY #$00
	BEQ basic_input_loop
	DEY
	JMP basic_input_clear
basic_input_loop
	INX
	CPX #$FF
	BNE basic_input_continue
	JMP basic_input_exit
basic_input_continue
	JSR sub_index
	CMP #"A"
	BNE basic_input_next1
	LDA #>basic_A
	STA basic_addr_high
	JMP basic_input_set
basic_input_next1
	CMP #"B"
	BNE basic_input_next2
	LDA #>basic_B
	STA basic_addr_high
	JMP basic_input_set
basic_input_next2
	CMP #"C"
	BNE basic_input_next3
	LDA #>basic_C
	STA basic_addr_high
	JMP basic_input_set
basic_input_next3
	CMP #"D"
	BNE basic_input_next4
	LDA #>basic_D
	STA basic_addr_high
	JMP basic_input_set
basic_input_next4
	CMP #"W"
	BNE basic_input_next5
	LDA #>basic_W
	STA basic_addr_high
	JMP basic_input_set
basic_input_next5
	CMP #"X"
	BNE basic_input_next6
	LDA #>basic_X
	STA basic_addr_high
	JMP basic_input_set
basic_input_next6
	CMP #"Y"
	BNE basic_input_next7
	LDA #>basic_Y
	STA basic_addr_high
	JMP basic_input_set
basic_input_next7
	CMP #"Z"
	BNE basic_input_next8
	LDA #>basic_Z
	STA basic_addr_high
	JMP basic_input_set
basic_input_next8
	JMP basic_input_loop
basic_input_set
	INX
basic_input_extra_loop
	JSR sub_index
	CMP #$00 ; delimiter
	BNE basic_input_extra_ready
	JMP basic_input_extra_expected_exit
basic_input_extra_ready
	CMP #"("
	BEQ basic_input_extra_array_loop
	INX
	CPX #$FF
	BNE basic_input_extra_loop
	JMP basic_input_extra_expected_exit
basic_input_extra_array_loop
	JSR sub_index
	CMP #$00 ; delimiter
	BNE basic_input_extra_array_ready
	JMP basic_input_extra_expected_exit
basic_input_extra_array_ready
	CMP #")"
	BEQ basic_input_extra_loop
	CMP #"A"
	BEQ basic_input_extra_array_variable
	CMP #"B"
	BEQ basic_input_extra_array_variable
	CMP #"C"
	BEQ basic_input_extra_array_variable
	CMP #"D"
	BEQ basic_input_extra_array_variable
	CMP #"W"
	BEQ basic_input_extra_array_variable
	CMP #"X"
	BEQ basic_input_extra_array_variable
	CMP #"Y"
	BEQ basic_input_extra_array_variable
	CMP #"Z"
	BEQ basic_input_extra_array_variable
	CLC	
	CMP #"0"
	BCC basic_input_extra_array_increment
	CLC
	CMP #$3A ; colon, one more than '9'
	BCS basic_input_extra_array_increment
	SEC
	SBC #"0"
	PHA
	LDA basic_addr_low
	CLC
	ROL A
	STA basic_bytes
	CLC
	ADC basic_bytes
	CLC
	ADC basic_bytes
	CLC
	ADC basic_bytes
	CLC
	ADC basic_bytes	
	STA basic_addr_low
	PLA
	CLC
	ADC basic_addr_low
	STA basic_addr_low
basic_input_extra_array_increment
	INX
	CPX #$FF
	BNE basic_input_extra_array_loop	
	JMP basic_input_extra_expected_exit
basic_input_extra_array_variable
	STZ sub_read+1
	CMP #"A"
	BNE basic_input_extra_array_next1
	LDA #>basic_A
	STA sub_read+2
	JMP basic_input_extra_array_value
basic_input_extra_array_next1
	CMP #"B"
	BNE basic_input_extra_array_next2
	LDA #>basic_B
	STA sub_read+2
	JMP basic_input_extra_array_value
basic_input_extra_array_next2
	CMP #"C"
	BNE basic_input_extra_array_next3
	LDA #>basic_C
	STA sub_read+2
	JMP basic_input_extra_array_value
basic_input_extra_array_next3
	CMP #"D"
	BNE basic_input_extra_array_next4
	LDA #>basic_D
	STA sub_read+2
	JMP basic_input_extra_array_value
basic_input_extra_array_next4
	CMP #"W"
	BNE basic_input_extra_array_next5
	LDA #>basic_W
	STA sub_read+2
	JMP basic_input_extra_array_value
basic_input_extra_array_next5
	CMP #"X"
	BNE basic_input_extra_array_next6
	LDA #>basic_X
	STA sub_read+2
	JMP basic_input_extra_array_value
basic_input_extra_array_next6
	CMP #"Y"
	BNE basic_input_extra_array_next7
	LDA #>basic_Y
	STA sub_read+2
	JMP basic_input_extra_array_value
basic_input_extra_array_next7
	CMP #"Z"
	BNE basic_input_extra_array_value
	LDA #>basic_Z
	STA sub_read+2
basic_input_extra_array_value
	JSR sub_read
	STA basic_addr_low
	JMP basic_input_extra_array_increment
basic_input_extra_expected_exit
basic_input_user
	LDA #$05 ; enquire
	JSR printchar
	JSR inputchar
	CMP #$1B ; escape
	BNE basic_input_escape
	LDA #$06 ; acknowledge
	JSR printchar
	LDA #$0D ; carriage return
	JSR printchar
	LDA #$1B
	STA inputchar_value
	JMP basic_input_exit
basic_input_escape
	CMP #$00 ; needed
	BEQ basic_input_user
	PHA
	LDA #$06 ; acknowledge
	JSR printchar
	LDA printchar_x
	SEC
	SBC #$04
	CLC
	ROR A
	TAY
	PLA
	CMP #$0D ; carriage return
	BEQ basic_input_finalize
	CMP #$08 ; backspace
	BEQ basic_input_print
	CMP #$09 ; tab
	BEQ basic_input_print
	CLC
	CMP #$20 ; control chars
	BCS basic_input_store
	JMP basic_input_user
basic_input_store
	STA basic_user_array,Y
basic_input_print
	JSR printchar
	LDA printchar_x
	CMP #$14
	BCC basic_input_user
	LDA #$12
	STA printchar_x
	JMP basic_input_user


basic_input_finalize
	JSR printchar
	LDY #$00
basic_input_finalize_loop
	LDA basic_user_array,Y
	CLC
	CMP #"0"
	BCC basic_input_increment
	CLC
	CMP #$3A ; colon, one more than '9'
	BCS basic_input_increment
	SEC
	SBC #"0"
	PHA
	LDA basic_data
	CLC
	ROL A
	STA basic_bytes
	CLC
	ADC basic_bytes
	CLC
	ADC basic_bytes
	CLC
	ADC basic_bytes
	CLC
	ADC basic_bytes	
	STA basic_data
	PLA
	CLC
	ADC basic_data
	STA basic_data
basic_input_increment
	INY
	CPY #$08
	BNE basic_input_finalize_loop
basic_input_write
	LDA basic_addr_low
	STA sub_write+1
	LDA basic_addr_high
	STA sub_write+2
	LDA basic_data
	JSR sub_write
basic_input_exit
	STZ command_mode
	RTS


basic_print
	STZ basic_data
	STZ basic_quotes
	STX basic_compare_operator
	INX
	CPX #$FF
	BEQ basic_print_exit
	JSR basic_expect
	JSR sub_index
	CMP #"T"
	BNE basic_print_complete
	INX
	CPX #$FF
	BEQ basic_print_exit
	JSR basic_expect
basic_print_complete
	LDA basic_quotes
	BEQ basic_print_variable
	LDX basic_compare_operator
	STZ basic_quotes
basic_print_loop
	INX
	CPX #$FF
	BEQ basic_print_exit
	JSR sub_index
	CMP #$22 ; double quotes
	BNE basic_print_quotes
	INC basic_quotes
	LDA basic_quotes
	CLC	
	CMP #$02
	BCC basic_print_quotes
	JMP basic_print_exit
basic_print_quotes
	CMP #"_"
	BEQ basic_print_newline
	STA basic_compare_operator
	LDA basic_quotes
	BEQ basic_print_loop
	LDA basic_compare_operator
	JSR printchar
	JMP basic_print_loop
basic_print_newline
	LDA #$0D ; carriage return
	JSR printchar
	JMP basic_print_loop
basic_print_variable
	LDY basic_data
	LDA decimal_conversion_high,Y
	JSR printchar
	LDA decimal_conversion_middle,Y
	JSR printchar
	LDA decimal_conversion_low,Y
	JSR printchar
basic_print_exit
	INC basic_colon
	PLA
	STA basic_rts_low2
	PLA
	STA basic_rts_high2
	PLA
	PLA
	TXA
	CLC
	ADC sub_index+1
	BCC basic_print_shift
	PHA
	LDA sub_index+2
	INC A
	PHA
	LDA basic_rts_high2
	PHA
	LDA basic_rts_low2
	PHA
	RTS
basic_print_shift
	PHA
	LDA sub_index+2
	PHA
	LDA basic_rts_high2
	PHA
	LDA basic_rts_low2
	PHA
	RTS


basic_exit
	LDA #$03
	STA command_mode
	RTS


; tables and raw data

	.ORG $E000

; this is the opcode lookup table for monitor_memasm,
; must start at $X000 memory location to actually work right!
; illegal opcodes are labeled as ILLXX
opcode_lookup ; must start on a $X000 value
	.BYTE "BRK     "
	.BYTE "ORA($,X)"
	.BYTE "ILL02   "
	.BYTE "ILL03   "
	.BYTE "TSB $   "
	.BYTE "ORA $   "
	.BYTE "ASL $   "
	.BYTE "RMB0$   "
	.BYTE "PHP     "
	.BYTE "ORA#$   "
	.BYTE "ASL A   "
	.BYTE "ILL0B   "
	.BYTE "TSB $   "
	.BYTE "ORA $   "
	.BYTE "ASL $   "
	.BYTE "BBR0$   "

	.BYTE "BPL $   "
	.BYTE "ORA($),Y"
	.BYTE "ORA($)  "
	.BYTE "ILL13   "
	.BYTE "TRB $   "
	.BYTE "ORA $,X "
	.BYTE "ASL $,X "
	.BYTE "RMB1$   "
	.BYTE "CLC     "
	.BYTE "ORA $,Y "
	.BYTE "INC A   "
	.BYTE "ILL1B   "
	.BYTE "TRB $   "
	.BYTE "ORA $,X "
	.BYTE "ASL $,X "
	.BYTE "BBR1$   "

	.BYTE "JSR $   "
	.BYTE "AND($,X)"
	.BYTE "ILL22   "
	.BYTE "ILL23   "
	.BYTE "BIT $   "
	.BYTE "AND $   "
	.BYTE "ROL $   "
	.BYTE "RMB2$   "
	.BYTE "PLP     "
	.BYTE "AND#$   "
	.BYTE "ROL A   "
	.BYTE "ILL2B   "
	.BYTE "BIT $   "
	.BYTE "AND $   "
	.BYTE "ROL $   "
	.BYTE "BBR2$   "

	.BYTE "BMI $   "
	.BYTE "AND($),Y"
	.BYTE "AND($)  "
	.BYTE "ILL33   "
	.BYTE "BIT $,X "
	.BYTE "AND $,X "
	.BYTE "ROL $,X "
	.BYTE "RMB3$   "
	.BYTE "SEC     "
	.BYTE "AND $,Y "
	.BYTE "DEC A   "
	.BYTE "ILL3B   "
	.BYTE "BIT $,X "
	.BYTE "AND $,X "
	.BYTE "ROL $,X "
	.BYTE "BBR3$   "

	.BYTE "RTI     "
	.BYTE "EOR($,X)"
	.BYTE "ILL42   "
	.BYTE "ILL43   "
	.BYTE "ILL44   "
	.BYTE "EOR $   "
	.BYTE "LSR $   "
	.BYTE "RMB4$   "
	.BYTE "PHA     "
	.BYTE "EOR#$   "
	.BYTE "LSR A   "
	.BYTE "ILL4B   "
	.BYTE "JMP $   "
	.BYTE "EOR $   "
	.BYTE "LSR $   "
	.BYTE "BBR4$   "

	.BYTE "BVC $   "
	.BYTE "EOR($),Y"
	.BYTE "EOR($)  "
	.BYTE "ILL53   "
	.BYTE "ILL54   "
	.BYTE "EOR $,X "
	.BYTE "LSR $,X "
	.BYTE "RMB5$   "
	.BYTE "CLI     "
	.BYTE "EOR $,Y "
	.BYTE "PHY     "
	.BYTE "ILL5B   "
	.BYTE "ILL5C   "
	.BYTE "EOR $,X "
	.BYTE "LSR $,X "
	.BYTE "BBR5$   "

	.BYTE "RTS     "
	.BYTE "ADC($,X)"
	.BYTE "ILL62   "
	.BYTE "ILL63   "
	.BYTE "STZ $   "
	.BYTE "ADC $   "
	.BYTE "ROR $   "
	.BYTE "RMB6$   "
	.BYTE "PLA     "
	.BYTE "ADC#$   "
	.BYTE "ROR A   "
	.BYTE "ILL6B   "
	.BYTE "JMP($)  "
	.BYTE "ADC $   "
	.BYTE "ROR $   "
	.BYTE "BBR6$   "

	.BYTE "BVS $   "
	.BYTE "ADC($),Y"
	.BYTE "ADC($)  "
	.BYTE "ILL73   "
	.BYTE "STZ $,X "
	.BYTE "ADC $,X "
	.BYTE "ROR $,X "
	.BYTE "RMB7$   "
	.BYTE "SEI     "
	.BYTE "ADC $,Y "
	.BYTE "PLY     "
	.BYTE "ILL7B   "
	.BYTE "JMP($,X)"
	.BYTE "ADC $,X "
	.BYTE "ROR $,X "
	.BYTE "BBR7$   "
 
	.BYTE "BRA $   "
	.BYTE "STA($,X)"
	.BYTE "ILL82   "
	.BYTE "ILL83   "
	.BYTE "STY $   "
	.BYTE "STA $   "
	.BYTE "STX $   "
	.BYTE "SMB0$   "
	.BYTE "DEY     "
	.BYTE "BIT#$   "
	.BYTE "TXA     "
	.BYTE "ILL8B   "
	.BYTE "STY $   "
	.BYTE "STA $   "
	.BYTE "STX $   "
	.BYTE "BBS0$   "

	.BYTE "BBC $   "
	.BYTE "STA($),Y"
	.BYTE "STA($)  "
	.BYTE "ILL93   "
	.BYTE "STY $,X "
	.BYTE "STA $,X "
	.BYTE "STX $,Y "
	.BYTE "SMB1$   "
	.BYTE "TYA     "
	.BYTE "STA $,Y "
	.BYTE "TXS     "
	.BYTE "ILL9B   "
	.BYTE "STZ $   "
	.BYTE "STA $,X "
	.BYTE "STZ $,X "
	.BYTE "BBS1$   "
 
	.BYTE "LDY#$   "
	.BYTE "LDA($,X)"
	.BYTE "LDX#$   "
	.BYTE "ILLA3   "
	.BYTE "LDY $   "
	.BYTE "LDA $   "
	.BYTE "LDX $   "
	.BYTE "SMB2$   "
	.BYTE "TAY     "
	.BYTE "LDA#$   "
	.BYTE "TAX     "
	.BYTE "ILLAB   "
	.BYTE "LDY $   "
	.BYTE "LDA $   "
	.BYTE "LDX $   "
	.BYTE "BBS2$   "

	.BYTE "BCS $   "
	.BYTE "LDA($),Y"
	.BYTE "LDA($)  "
	.BYTE "ILLB3   "
	.BYTE "LDY $,X "
	.BYTE "LDA $,X "
	.BYTE "LDX $,Y "
	.BYTE "SMB3$   "
	.BYTE "CLV     "
	.BYTE "LDA $,Y "
	.BYTE "TSX     "
	.BYTE "ILLBB   "
	.BYTE "LDY $,X "
	.BYTE "LDA $,X "
	.BYTE "LDX $,Y "
	.BYTE "BBS3$   "

	.BYTE "CPY#$   "
	.BYTE "CMP($,X)"
	.BYTE "ILLC2   "
	.BYTE "ILLC3   "
	.BYTE "CPY $   "
	.BYTE "CMP $   "
	.BYTE "DEC $   "
	.BYTE "SMB4$   "
	.BYTE "INY     "
	.BYTE "CMP#$   "
	.BYTE "DEX     "
	.BYTE "WAI     "
	.BYTE "CPY $   "
	.BYTE "CMP $   "
	.BYTE "DEC $   "
	.BYTE "BBS4$   "

	.BYTE "BNE $   "
	.BYTE "CMP($),Y"
	.BYTE "CMP($)  "
	.BYTE "ILLD3   "
	.BYTE "ILLD4   "
	.BYTE "CMP $,X "
	.BYTE "DEC $,X "
	.BYTE "SMB5$   "
	.BYTE "CLD     "
	.BYTE "CMP $,Y "
	.BYTE "PHX     "
	.BYTE "STP     "
	.BYTE "ILLDC   "
	.BYTE "CMP $,X "
	.BYTE "DEC $,X "
	.BYTE "BBS5$   "

	.BYTE "CPX#$   "
	.BYTE "SBC($,X)"
	.BYTE "ILLE2   "
	.BYTE "ILLE3   "
	.BYTE "CPX $   "
	.BYTE "SBC $   "
	.BYTE "INC $   "
	.BYTE "SMB6$   "
	.BYTE "INX     "
	.BYTE "SBC#$   "
	.BYTE "NOP     "
	.BYTE "ILLEB   "
	.BYTE "CPX $   "
	.BYTE "SBC $   "
	.BYTE "INC $   "
	.BYTE "BBS6$   "

	.BYTE "BEQ $   "
	.BYTE "SBC($),Y"
	.BYTE "SBC($)  "
	.BYTE "ILLF3   "
	.BYTE "ILLF4   "
	.BYTE "SBC $,X "
	.BYTE "INC $,X "
	.BYTE "SMB7$   "
	.BYTE "SED     "
	.BYTE "SBC $,Y "
	.BYTE "PLX     "
	.BYTE "ILLFB   "
	.BYTE "ILLFC   "
	.BYTE "SBC $,X "
	.BYTE "INC $,X "
	.BYTE "BBS7$   "


; this is how many operand bytes an opcode needs.
; for example, 
; CLC needs zero extra bytes
; LDA #$FF needs one extra byte
; STA $FFFF needs two extra bytes
opcode_bytes
	.BYTE $00,$01,$00,$00,$01,$01,$01,$01
	.BYTE $00,$01,$00,$00,$02,$02,$02,$01
	.BYTE $01,$01,$01,$00,$01,$01,$01,$01
	.BYTE $00,$02,$00,$00,$02,$02,$02,$01
	.BYTE $02,$01,$00,$00,$01,$01,$01,$01
	.BYTE $00,$01,$00,$00,$02,$02,$02,$01
	.BYTE $01,$01,$01,$00,$01,$01,$01,$01
	.BYTE $00,$02,$00,$00,$02,$02,$02,$01
	.BYTE $00,$01,$00,$00,$00,$01,$01,$01
	.BYTE $00,$01,$00,$00,$02,$02,$02,$01
	.BYTE $01,$01,$01,$00,$00,$01,$01,$01
	.BYTE $00,$02,$00,$00,$00,$02,$02,$01
	.BYTE $00,$01,$00,$00,$01,$01,$01,$01
	.BYTE $00,$01,$00,$00,$02,$02,$02,$01
	.BYTE $01,$01,$00,$00,$01,$01,$01,$01
	.BYTE $00,$01,$00,$00,$02,$02,$02,$01
	.BYTE $01,$01,$00,$00,$01,$01,$01,$01
	.BYTE $00,$01,$00,$00,$02,$02,$02,$01
	.BYTE $01,$01,$01,$00,$01,$01,$01,$01
	.BYTE $00,$02,$00,$00,$02,$02,$02,$01
	.BYTE $01,$01,$01,$00,$01,$01,$01,$01
	.BYTE $00,$01,$00,$00,$02,$02,$02,$01
	.BYTE $01,$01,$01,$00,$01,$01,$01,$01
	.BYTE $00,$02,$00,$00,$02,$02,$02,$01
	.BYTE $01,$01,$00,$00,$01,$01,$01,$01
	.BYTE $00,$01,$00,$00,$02,$02,$02,$01
	.BYTE $01,$01,$01,$00,$00,$01,$01,$01
	.BYTE $00,$02,$00,$00,$00,$02,$02,$01
	.BYTE $01,$01,$00,$00,$01,$01,$01,$01
	.BYTE $00,$01,$00,$00,$02,$02,$02,$01
	.BYTE $01,$01,$01,$00,$00,$01,$01,$01
	.BYTE $00,$02,$00,$00,$00,$02,$02,$01


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


; 128 byte value table
; converts ascii into hex numeric value
; these are low nibble values,
; add to high nibble values for full byte value
; $FF is the 'error' value here
ascii_value_low
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $00,$01,$02,$03,$04,$05,$06,$07
	.BYTE $08,$09,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$0A,$0B,$0C,$0D,$0E,$0F,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$0A,$0B,$0C,$0D,$0E,$0F,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF

; 128 byte value table
; converts ascii into hex numeric value
; these are high nibble values,
; add to low nibble values for full byte value
; $FF is the 'error' value here
ascii_value_high
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $00,$10,$20,$30,$40,$50,$60,$70
	.BYTE $80,$90,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$A0,$B0,$C0,$D0,$E0,$F0,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$A0,$B0,$C0,$D0,$E0,$F0,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF


; universal code and tables below this point

	.ORG $ED00


; 256 byte key table
; converts hex numeric values into ascii
; these are the low nibble value
ascii_key_low
	.BYTE $30,$31,$32,$33,$34,$35,$36,$37
	.BYTE $38,$39,$41,$42,$43,$44,$45,$46
	.BYTE $30,$31,$32,$33,$34,$35,$36,$37
	.BYTE $38,$39,$41,$42,$43,$44,$45,$46
	.BYTE $30,$31,$32,$33,$34,$35,$36,$37
	.BYTE $38,$39,$41,$42,$43,$44,$45,$46
	.BYTE $30,$31,$32,$33,$34,$35,$36,$37
	.BYTE $38,$39,$41,$42,$43,$44,$45,$46
	.BYTE $30,$31,$32,$33,$34,$35,$36,$37
	.BYTE $38,$39,$41,$42,$43,$44,$45,$46
	.BYTE $30,$31,$32,$33,$34,$35,$36,$37
	.BYTE $38,$39,$41,$42,$43,$44,$45,$46
	.BYTE $30,$31,$32,$33,$34,$35,$36,$37
	.BYTE $38,$39,$41,$42,$43,$44,$45,$46
	.BYTE $30,$31,$32,$33,$34,$35,$36,$37
	.BYTE $38,$39,$41,$42,$43,$44,$45,$46
	.BYTE $30,$31,$32,$33,$34,$35,$36,$37
	.BYTE $38,$39,$41,$42,$43,$44,$45,$46
	.BYTE $30,$31,$32,$33,$34,$35,$36,$37
	.BYTE $38,$39,$41,$42,$43,$44,$45,$46
	.BYTE $30,$31,$32,$33,$34,$35,$36,$37
	.BYTE $38,$39,$41,$42,$43,$44,$45,$46
	.BYTE $30,$31,$32,$33,$34,$35,$36,$37
	.BYTE $38,$39,$41,$42,$43,$44,$45,$46
	.BYTE $30,$31,$32,$33,$34,$35,$36,$37
	.BYTE $38,$39,$41,$42,$43,$44,$45,$46
	.BYTE $30,$31,$32,$33,$34,$35,$36,$37
	.BYTE $38,$39,$41,$42,$43,$44,$45,$46
	.BYTE $30,$31,$32,$33,$34,$35,$36,$37
	.BYTE $38,$39,$41,$42,$43,$44,$45,$46
	.BYTE $30,$31,$32,$33,$34,$35,$36,$37
	.BYTE $38,$39,$41,$42,$43,$44,$45,$46

; 256 byte key table
; converts hex numeric values into ascii
; these are the high nibble value
ascii_key_high
	.BYTE $30,$30,$30,$30,$30,$30,$30,$30
	.BYTE $30,$30,$30,$30,$30,$30,$30,$30
	.BYTE $31,$31,$31,$31,$31,$31,$31,$31
	.BYTE $31,$31,$31,$31,$31,$31,$31,$31
	.BYTE $32,$32,$32,$32,$32,$32,$32,$32
	.BYTE $32,$32,$32,$32,$32,$32,$32,$32
	.BYTE $33,$33,$33,$33,$33,$33,$33,$33
	.BYTE $33,$33,$33,$33,$33,$33,$33,$33
	.BYTE $34,$34,$34,$34,$34,$34,$34,$34
	.BYTE $34,$34,$34,$34,$34,$34,$34,$34
	.BYTE $35,$35,$35,$35,$35,$35,$35,$35
	.BYTE $35,$35,$35,$35,$35,$35,$35,$35
	.BYTE $36,$36,$36,$36,$36,$36,$36,$36
	.BYTE $36,$36,$36,$36,$36,$36,$36,$36
	.BYTE $37,$37,$37,$37,$37,$37,$37,$37
	.BYTE $37,$37,$37,$37,$37,$37,$37,$37
	.BYTE $38,$38,$38,$38,$38,$38,$38,$38
	.BYTE $38,$38,$38,$38,$38,$38,$38,$38
	.BYTE $39,$39,$39,$39,$39,$39,$39,$39
	.BYTE $39,$39,$39,$39,$39,$39,$39,$39
	.BYTE $41,$41,$41,$41,$41,$41,$41,$41
	.BYTE $41,$41,$41,$41,$41,$41,$41,$41
	.BYTE $42,$42,$42,$42,$42,$42,$42,$42
	.BYTE $42,$42,$42,$42,$42,$42,$42,$42
	.BYTE $43,$43,$43,$43,$43,$43,$43,$43
	.BYTE $43,$43,$43,$43,$43,$43,$43,$43
	.BYTE $44,$44,$44,$44,$44,$44,$44,$44
	.BYTE $44,$44,$44,$44,$44,$44,$44,$44
	.BYTE $45,$45,$45,$45,$45,$45,$45,$45
	.BYTE $45,$45,$45,$45,$45,$45,$45,$45
	.BYTE $46,$46,$46,$46,$46,$46,$46,$46
	.BYTE $46,$46,$46,$46,$46,$46,$46,$46		

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

	
	.ORG $F000


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

	
	.ORG $F600

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
	CMP #$05 ; enquire (draw cursor)
	BNE printchar_continue2
	LDA sub_write+1
	CLC
	ADC #$80
	STA sub_write+1
	INC sub_write+2
	INC sub_write+2
	INC sub_write+2
	LDA printchar_invert
	EOR #$FF
	JSR sub_write
	INC sub_write+1
	JSR sub_write
	JMP printchar_exit
printchar_continue2
	CMP #$06 ; acknowledge (erase cursor)
	BNE printchar_continue3
	LDA sub_write+1
	CLC
	ADC #$80
	STA sub_write+1
	INC sub_write+2
	INC sub_write+2
	INC sub_write+2
	LDA printchar_invert
	JSR sub_write
	INC sub_write+1
	JSR sub_write
	JMP printchar_exit
printchar_continue3
	CMP #$07 ; bell (F7)
	BNE printchar_continue4
	LDA key_alt_control
	BEQ printchar_continue4
	JSR bell
	JMP printchar_exit
printchar_continue4
	CMP #$08 ; backspace
	BNE printchar_continue5
printchar_backspace
	DEC printchar_x
	DEC printchar_x
	LDA command_mode
	BEQ printchar_backspace_scratch
	LDA printchar_x
	DEC A
	DEC A
	DEC A
	DEC A
	BPL printchar_backspace_exit
	LDA #$04
	STA printchar_x
printchar_backspace_scratch
	LDA printchar_x
	DEC A
	DEC A
	BPL printchar_backspace_exit
	LDA #$02
	STA printchar_x
printchar_backspace_exit
	JMP printchar_exit
printchar_continue5
	CMP #$09 ; tab
	BNE printchar_continue6
printchar_tab
	INC printchar_x
	INC printchar_x
	LDA printchar_x
	CLC	
	CMP #$4E
	BCC printchar_tab_exit
	LDA #$4C
	STA printchar_x
printchar_tab_exit
	JMP printchar_exit
printchar_continue6
	CMP #$0A ; line feed
	BEQ printchar_linefeed_start
	JMP printchar_continue7
printchar_linefeed_start
	STZ sub_write+1
	STZ sub_read+1
	LDA #$0C
	STA sub_write+2
	LDA #$10
	STA sub_read+2
printchar_linefeed_loop
	JSR sub_read
	JSR sub_write
	INC sub_write+1
	INC sub_read+1
	LDA sub_read+1
	CMP #$4E
	BEQ printchar_linefeed_skip
	CMP #$CE
	BEQ printchar_linefeed_skip
	JMP printchar_linefeed_loop
printchar_linefeed_skip
	CLC
	ADC #$34
	STA sub_write+1
	STA sub_read+1
	CMP #$02
	BNE printchar_linefeed_loop
	INC sub_write+2
	INC sub_read+2
	LDA sub_read+2
	CMP #$7C
	BNE printchar_linefeed_loop
printchar_linefeed_blank
	LDA printchar_invert
	JSR sub_write
	INC sub_write+1
	LDA sub_write+1
	CMP #$4E
	BEQ printchar_linefeed_increment
	CMP #$CE
	BEQ printchar_linefeed_increment
	JMP printchar_linefeed_blank
printchar_linefeed_increment
	CLC
	ADC #$34
	STA sub_write+1
	CMP #$02
	BNE printchar_linefeed_blank
	INC sub_write+2
	LDA sub_write+2
	CMP #$7C
	BNE printchar_linefeed_blank
	LDX #$00
printchar_linefeed_array
	STZ command_array,X
	INX
	CPX #$28 
	BNE printchar_linefeed_array
	JMP printchar_prompt
printchar_continue7
	CMP #$0C ; form feed (F5)
	BNE printchar_continue8
	LDA key_alt_control
	BEQ printchar_continue8
	LDA #$02
	STA sub_write+1
	LDA #$0C
	STA sub_write+2
printchar_formfeed_loop
	LDA printchar_invert
	JSR sub_write
	INC sub_write+1
	LDA sub_write+1
	CMP #$4E
	BEQ printchar_formfeed_step
	CMP #$CE
	BEQ printchar_formfeed_increment
	JMP printchar_formfeed_loop
printchar_formfeed_step
	LDA #$82
	STA sub_write+1
	JMP printchar_formfeed_loop
printchar_formfeed_increment
	LDA #$02
	STA sub_write+1
	INC sub_write+2
	LDA sub_write+2
	CMP #$7C
	BNE printchar_formfeed_loop
	LDA #$02	
	STA printchar_x
	LDA #$0C
	STA printchar_y
	LDX #$00
printchar_formfeed_array
	STZ command_array,X
	INX 
	CPX #$28 
	BNE printchar_formfeed_array
	JMP printchar_prompt
printchar_continue8
	CMP #$0D ; carriage return
	BEQ printchar_return_start
	JMP printchar_continue9
printchar_return_start
	LDA command_mode
	BEQ printchar_return_next
	CMP #$01
	BEQ printchar_return_monitor_command
	CMP #$02
	BEQ printchar_return_assembler_command
	CMP #$03
	BEQ printchar_return_basic_command
	JMP printchar_return_next
printchar_return_monitor_command
	LDA #$01
	STA command_mode
	JSR monitor
	JMP printchar_return_next
printchar_return_assembler_command
	JSR monitor
	JMP printchar_return_next
printchar_return_basic_command
	JSR basic
	JMP printchar_return_next
printchar_return_next
	LDA #$02
	STA printchar_x
	LDA printchar_y
	CLC
	ADC #$04
	STA printchar_y
	CLC	
	CMP #$7C
	BCS printchar_return_shift
	LDX #$00
printchar_return_array
	STZ command_array,X
	INX 
	CPX #$28 
	BNE printchar_return_array
	JMP printchar_prompt
printchar_return_shift
	LDA #$02
	STA printchar_x
	LDA #$78
	STA printchar_y
	JMP printchar_linefeed_start
printchar_continue9
	CMP #$1F ; (F4), now for RAM bank
	BNE printchar_continue10
	LDA key_alt_control
	BEQ printchar_continue10
;	LDA printchar_invert
;	BEQ printchar_shiftin_next
;	JMP printchar_exit
;printchar_shiftin_next
;	JMP printchar_shift_screen
	LDA output_byte
	EOR #%00100000 ; change RAM bank
	STA output_byte
	STA $FFFF
	LDX #$FF
	LDY #$FF
printchar_ram_delay ; this adds an artificial delay
	DEX
	BNE printchar_ram_delay
	DEY
	BNE printchar_ram_delay
	JMP printchar_exit
printchar_continue10
	CMP #$0E ; shift in (F6), always shifts
	BNE printchar_continue11
	LDA key_alt_control
	BEQ printchar_continue11
;	LDA printchar_invert
;	BNE printchar_shiftout_next
;	JMP printchar_exit
;printchar_shiftout_next
;	JMP printchar_shift_screen
printchar_shift_screen
	LDA printchar_invert
	EOR #$FF
	STA printchar_invert
	STZ sub_read+1
	STZ sub_write+1
	LDA #$08
	STA sub_read+2
	STA sub_write+2
printchar_shift_loop
	JSR sub_read
	EOR #$FF
	JSR sub_write
	INC sub_read+1
	INC sub_write+1
	BNE printchar_shift_loop
	INC sub_read+2
	INC sub_write+2
	LDA sub_write+2
	CMP #$80
	BNE printchar_shift_loop
	JMP printchar_exit
printchar_continue11
	CMP #$11 ; DC1 (arrow up)
	BNE printchar_continue12
	LDA command_mode
	BNE printchar_continue12
	LDA printchar_y
	SEC
	SBC #$04
	STA printchar_y
	CMP #$0C
	BCS printchar_dc1_exit
	LDA #$0C
	STA printchar_y
printchar_dc1_exit
	JMP printchar_exit
printchar_continue12
	CMP #$12 ; DC2 (arrow down)
	BNE printchar_continue13
	LDA command_mode
	BNE printchar_continue13
	LDA printchar_y
	CLC
	ADC #$04
	STA printchar_y
	CLC	
	CMP #$7C
	BCC printchar_dc2_exit
	LDA #$78
	STA printchar_y
printchar_dc2_exit
	JMP printchar_exit
printchar_continue13
	CMP #$13 ; DC3 (arrow left)
	BNE printchar_continue14
	LDA command_mode
	BNE printchar_continue14
	JMP printchar_backspace
printchar_continue14
	CMP #$14 ; DC4 (arrow right)
	BNE printchar_continue15
	LDA command_mode
	BNE printchar_continue15
	JMP printchar_tab
printchar_continue15
	CMP #$18 ; other game (F10)
	BNE printchar_continue16
	LDA key_alt_control
	BEQ printchar_continue16
	JMP $FFE8 ; location to switch to other game
printchar_continue16
	CMP #$0F ;  shift out, soft reset (F9)
	BNE printchar_continue17
	LDA key_alt_control
	BEQ printchar_continue17
	;LDA #$F0
	LDA #<vector_reset
	STA command_addr4_low
	;LDA #$FF
	LDA #>vector_reset
	STA command_addr4_high
	LDA #$0F
	JSR soft_jump ; jump to 'vector_reset'
	JMP printchar_exit
printchar_continue17
	CMP #$15 ; help menu (F12)
	BNE printchar_continue18
	LDA #$06 ; acknowledge
	JSR printchar
	LDA command_mode
	BEQ printchar_help_scratchpad
	CLC
	CMP #$04
	BCC printchar_help_other
	JMP printchar_exit
printchar_help_scratchpad
	JSR main_help
	JMP printchar_exit
printchar_help_other
	LDA #"?"
	JSR printchar
	LDA #$0D
	JSR printchar
	JMP printchar_exit
printchar_continue18
	CMP #$1C ; file sep (F1, load scratchpad)
	BNE printchar_continue19
	LDA key_alt_control
	BEQ printchar_continue19
	STZ command_mode ; scratchpad mode
	LDA #$0D ; carriage return
	JSR printchar
	JMP printchar_exit
printchar_continue19
	CMP #$1D ; group sep (F2, load monitor)
	BNE printchar_continue20
	LDA key_alt_control
	BEQ printchar_continue20
	LDA #$01 ; monitor mode
	STA command_mode
	LDX #$00
printchar_monitor_array
	STZ command_array,X
	INX 
	CPX #$28 
	BNE printchar_monitor_array
	LDA #$0D
	JSR printchar
	JMP printchar_exit
printchar_continue20
	CMP #$1E ; record sep (F3, load basic)
	BNE printchar_continue21
	LDA key_alt_control
	BEQ printchar_continue21
	LDA #$03 ; basic mode
	STA command_mode
	LDX #$00
printchar_basic_array
	STZ command_array,X
	INX 
	CPX #$28 
	BNE printchar_basic_array
	LDA #$0D
	JSR printchar
	JMP printchar_exit
printchar_continue21
	CMP #$16 ; unit sep (F9, game)
	BNE printchar_continue22
	LDA key_alt_control
	BEQ printchar_continue22
	JMP $FFE0 ; location to switch to game
printchar_continue22
	CMP #$19 ; cancel (F11, load SDcard)
	BNE printchar_continue23
	LDA key_alt_control
	BEQ printchar_continue23
	LDA #<sdcard
	STA command_addr4_low
	LDA #>sdcard
	STA command_addr4_high
	LDA #$19
	JSR soft_jump
	JMP printchar_exit
printchar_continue23
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
printchar_prompt
	LDA command_mode
	BEQ printchar_exit
	CMP #$01
	BEQ printchar_prompt_monitor
	CMP #$02
	BEQ printchar_prompt_assembler
	CMP #$03
	BEQ printchar_prompt_basic
	JMP printchar_exit
printchar_prompt_monitor
	LDA #$5C
	JSR printchar
	JMP printchar_exit
printchar_prompt_assembler
	LDA #$5C
	JSR printchar
	LDA #"@"
	JSR printchar
	JMP printchar_exit
printchar_prompt_basic
	LDA #"]"
	JSR printchar
	JMP printchar_exit


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



; spi_eeprom_read sub-routine
; reads selected data from the EEPROM, and writes it into RAM
; there is a specific configuration and commands needed for this particular EEPROM
; This one is a 25LC64 8K EEPROM, but I'm sure larger ones will act the same
; This is just like the 'write' function
spi_eeprom_read
	PHA
	PHX
	PHY
	LDA command_addr1_low
	PHA
	LDA command_addr1_high
	PHA
	LDA command_addr3_low
	PHA
	LDA command_addr3_high
	PHA
	JSR spi_base_disable			; disable
	JSR spi_base_delay			; delay
spi_eeprom_read_loop				; loop until done
	JSR spi_base_enable			; enable
	LDA #%00000011 ; read command		; read command
	JSR spi_base_send_byte
	LDA command_addr1_high ; high addr	; send high address
	JSR spi_base_send_byte
	LDA command_addr1_low ; low addr	; send low address
	JSR spi_base_send_byte
	JSR spi_base_receive_byte ; data	; receive data byte
	PHA
	JSR spi_base_disable			; disable
	JSR spi_base_delay			; delay
	LDA command_addr3_low
	STA sub_write+1
	LDA command_addr3_high
	STA sub_write+2
	PLA
	JSR sub_write				; write data byte into memory with sub_write
	LDA command_addr1_high
	CMP command_addr2_high
	BNE spi_eeprom_read_increment
	LDA command_addr1_low
	CMP command_addr2_low
	BNE spi_eeprom_read_increment		; increment until the end, then exit
	JMP spi_eeprom_read_exit
spi_eeprom_read_increment
	INC command_addr3_low
	BNE spi_eeprom_read_next
	INC command_addr3_high
spi_eeprom_read_next
	INC command_addr1_low
	BNE spi_eeprom_read_loop
	INC command_addr1_high
	JMP spi_eeprom_read_loop
spi_eeprom_read_exit
	PLA
	STA command_addr3_high
	PLA
	STA command_addr3_low
	PLA
	STA command_addr1_high
	PLA
	STA command_addr1_low
	PLY
	PLX
	PLA
	RTS


; spi_eeprom_write sub-routine
; reads selected data from RAM, and writes that selected data into the EEPROM
; there is a specific configuration and commands needed for this particular EEPROM
; This one is a 25LC64 8K EEPROM, but I'm sure larger ones will act the same
; one thing I found out is that because it's only 8K, you can save $2000-$3FFF perfectly fine
; but you can also 'save' $2000-$5FFF, but it just duplicates twice over,  so really only $4000-$5FFF was saved
; same thing with 'load'
spi_eeprom_write
	PHA
	PHX
	PHY
	LDA command_addr1_low
	PHA
	LDA command_addr1_high
	PHA
	LDA command_addr3_low
	PHA
	LDA command_addr3_high
	PHA
	JSR spi_base_disable			; disable
	JSR spi_base_delay			; delay
	JSR spi_base_enable			; enable
	LDA #%00000001 ; status			; send status byte
	JSR spi_base_send_byte
	LDA #%00000000 ; enable writing		; this enables writing, something to do with the status flags
	JSR spi_base_send_byte
	JSR spi_base_disable			; disable
	JSR spi_base_delay
spi_eeprom_write_loop				; loop until done
	JSR spi_base_enable			; enable
	LDA #%00000110 ; initialize writing	; initalize writing byte
	JSR spi_base_send_byte
	JSR spi_base_disable			; disable
	JSR spi_base_delay			; delay
	JSR spi_base_enable			; enable
	LDA #%00000010 ; write command		; write command
	JSR spi_base_send_byte
	LDA command_addr3_high ; high addr	; send high address
	JSR spi_base_send_byte
	LDA command_addr3_low ; low addr	; send low address
	JSR spi_base_send_byte
	LDA command_addr1_low
	STA sub_read+1
	LDA command_addr1_high
	STA sub_read+2
	JSR sub_read ; data			; read data using sub_read
	JSR spi_base_send_byte			; send data byte
	JSR spi_base_disable			; disable
	JSR spi_base_delay			; delay
	LDA command_addr1_high
	CMP command_addr2_high
	BNE spi_eeprom_write_increment
	LDA command_addr1_low
	CMP command_addr2_low
	BNE spi_eeprom_write_increment		; increment until the end, then exit
	JMP spi_eeprom_write_exit
spi_eeprom_write_increment
	INC command_addr3_low
	BNE spi_eeprom_write_next
	INC command_addr3_high
spi_eeprom_write_next
	INC command_addr1_low
	BNE spi_eeprom_write_loop
	INC command_addr1_high
	JMP spi_eeprom_write_loop
spi_eeprom_write_exit
	PLA
	STA command_addr3_high
	PLA
	STA command_addr3_low
	PLA
	STA command_addr1_high
	PLA
	STA command_addr1_low
	PLY
	PLX
	PLA
	RTS


; A will be the starting location in the SDcard
sdcard
	PHA
	STZ command_mode

	LDA #$FF
	STA key_alt_control
	LDA #$0C ; form feed
	JSR printchar
	STZ key_alt_control

	LDX #$00
	JMP sdcard_display_loop
sdcard_display_text
	.BYTE "Loading"
	.BYTE " SDcard"
	.BYTE "..."
	.BYTE $0D
sdcard_display_loop
	LDA sdcard_display_text,X
	JSR printchar
	INX
	CPX #$12
	BNE sdcard_display_loop

	PLX ; was A, where we start on SDcard
	LDA #$00
	JSR spi_sdcard_init
	CMP #$00 ; needed
	BNE sdcard_error
	LDA #>sdcard_memory
	;LDX #$00
	LDY #$00
	JSR spi_sdcard_read
	CMP #>sdcard_memory
	BNE sdcard_error
	INC A
	INC A
	INX
	INX
	LDY #$00
	JSR spi_sdcard_read
	DEC A
	DEC A
	CMP #>sdcard_memory
	BNE sdcard_error
	;RTS ; if you want to just exit instead of running that code
	JMP sdcard_memory
sdcard_error
	LDA #$0D ; carriage return
	JSR printchar
;	LDA #"E"
;	JSR printchar
;	LDA #"S"
;	JSR printchar
;	LDA #"C"
;	JSR printchar
;	LDA #$0D ; carriage return
;	JSR printchar
;sdcard_error_loop
;	JSR inputchar
;	CMP #$00
;	BEQ sdcard_error_loop
;	CMP #$1B ; escape
;	BNE sdcard_error_loop
	;JMP vector_reset ; if you want to reset the computer after an error
	RTS


; spi_sdcard_init sub-routine
; initializes sdcard
; there is a whole system behind this, sending specific
; bytes and specific locations, waiting, etc.
; It will display "?XX" upon error, and exit.
spi_sdcard_init
	PHA
	PHX
	PHY
	LDA #%11110111				; says we are trying to work with SPI SD CARD, that is D3 is low, the rest are high
	STA spi_cs_enable
	JSR spi_base_pump			; pump clock 80 times
	JSR spi_base_longdelay			; delay
	JSR spi_base_enable			; enable sdcard
	LDA #$40				; send CMD0
	JSR spi_base_send_byte
	LDA #$00
	JSR spi_base_send_byte
	LDA #$00
	JSR spi_base_send_byte
	LDA #$00
	JSR spi_base_send_byte
	LDA #$00
	JSR spi_base_send_byte
	LDA #$95
	JSR spi_base_send_byte
	JSR spi_base_waitresult			; wait until non-$FF result is read
	CMP #$FF
	BNE spi_sdcard_init_continue1
	JMP spi_sdcard_init_error
spi_sdcard_init_continue1
	JSR spi_base_disable			; disable sdcard
	CMP #$01				; expecting $01, not initialized
	BEQ spi_sdcard_init_continue2
	JMP spi_sdcard_init_error		; else, error!
spi_sdcard_init_continue2
	JSR spi_base_longdelay			; delay
	JSR spi_base_pump			; pump clock 80 times
	JSR spi_base_enable			; enable sdcard
	LDA #$48				; send CMD8
	JSR spi_base_send_byte
	LDA #$00
	JSR spi_base_send_byte
	LDA #$00
	JSR spi_base_send_byte
	LDA #$01
	JSR spi_base_send_byte
	LDA #$AA
	JSR spi_base_send_byte
	LDA #$87
	JSR spi_base_send_byte
	JSR spi_base_waitresult			; wait until non-$FF result is read
	CMP #$FF
	BNE spi_sdcard_init_continue3
	JMP spi_sdcard_init_error
spi_sdcard_init_continue3
	JSR spi_base_disable			; disable sdcard
	CMP #$01				; expecting $01, not initialized
	BEQ spi_sdcard_init_continue4
	JMP spi_sdcard_init_error		; else, error!
spi_sdcard_init_continue4
	JSR spi_base_enable			; enable
	JSR spi_base_receive_byte		; 32-bit return value, ignored
	JSR spi_base_receive_byte
	JSR spi_base_receive_byte
	JSR spi_base_receive_byte
	JSR spi_base_disable
spi_sdcard_init_acmd41				; this is the ACMD41 loop
	JSR spi_base_pump			; pump clock 80 times
	JSR spi_base_longdelay			; delay
	JSR spi_base_enable			; enable sdcard
	LDA #$77				; send CMD55
	JSR spi_base_send_byte
	LDA #$00
	JSR spi_base_send_byte
	LDA #$00
	JSR spi_base_send_byte
	LDA #$00
	JSR spi_base_send_byte
	LDA #$00
	JSR spi_base_send_byte
	LDA #$01
	JSR spi_base_send_byte
	JSR spi_base_waitresult			; wait until non-$FF result is read
	CMP #$FF
	BNE spi_sdcard_init_continue5
	JMP spi_sdcard_init_error
spi_sdcard_init_continue5
	JSR spi_base_disable			; disable sdcard
	CMP #$01				; expecting $01, not initialized
	BEQ spi_sdcard_init_continue6
	JMP spi_sdcard_init_error		; else, error!
spi_sdcard_init_continue6
	JSR spi_base_pump			; pump clock 80 times
	JSR spi_base_longdelay			; delay
	JSR spi_base_enable			; enable sdcard
	LDA #$69				; send CMD41
	JSR spi_base_send_byte
	LDA #$40
	JSR spi_base_send_byte
	LDA #$00
	JSR spi_base_send_byte
	LDA #$00
	JSR spi_base_send_byte
	LDA #$00
	JSR spi_base_send_byte
	LDA #$01
	JSR spi_base_send_byte
	JSR spi_base_waitresult			; wait until non-$FF result is read
	CMP #$FF
	BNE spi_sdcard_init_continue7
	JMP spi_sdcard_init_error
spi_sdcard_init_continue7
	JSR spi_base_disable			; disable sdcard
	CMP #$00				; $00 is initialized finally
	BEQ spi_sdcard_init_continue9
	CMP #$01				; $01 is still not initialized, back to loop
	BEQ spi_sdcard_init_continue8
	JMP spi_sdcard_init_error		; else, error!
spi_sdcard_init_continue8
	JSR spi_base_longdelay
	JMP spi_sdcard_init_acmd41
spi_sdcard_init_continue9
	JSR spi_base_longdelay			; delay
	JMP spi_sdcard_init_exit		; at this point, it is initialized, good!
spi_sdcard_init_error
	PHA
	LDA #"?"				; if errors, print exclamation mark where cursor used to be
	JSR printchar				; and also print what was in the accumlator
	PLX
	LDA ascii_key_high,X
	JSR printchar
	LDA ascii_key_low,X
	JSR printchar
	PLY
	PLX
	PLA
	EOR #$FF				; just make A not equal to what it started with
	RTS					; to indicate an error occured
spi_sdcard_init_exit
	PLY
	PLX
	PLA
	RTS


; spi_sdcard_read sub-routine
; reads 512 bytes from sdcard
; it reads from X (low) and Y (high) on the SD card (being blocks of 256 bytes, not just byte addresses), 
; and puts them into page A and A+1 in the computer's memory (being actual byte memory addresses)
; just like the last function, it will display a period for each 'milestone' but "ErrXX" for errors, and then exit
; this sub-routine can be used by the bootloader program as well, typically to fill banked RAM from $4000-$7FFF
spi_sdcard_read
	PHA
	PHX
	PHY
	LDA #%11110111				; says we are trying to work with SPI SD CARD, that is D3 is low, the rest are high
	STA spi_cs_enable
	JSR spi_base_pump			; pump clock 80 times
	JSR spi_base_longdelay			; delay
	JSR spi_base_enable			; enable sdcard
	LDA #$51				; send CMD17 (read block)
	JSR spi_base_send_byte
	LDA #$00
	JSR spi_base_send_byte
	PLY
	PLX
	PLA
	PHA
	PHX
	PHY
	TYA
	JSR spi_base_send_byte
	PLY
	PLX
	PLA
	PHA
	PHX
	PHY
	TXA
	AND #%11111110
	JSR spi_base_send_byte
	LDA #$00
	JSR spi_base_send_byte
	LDA #$01
	JSR spi_base_send_byte
	JSR spi_base_waitresult			; wait until non-$FF result is read
	CMP #$FF
	BNE spi_sdcard_read_continue1
	JMP spi_sdcard_read_error
spi_sdcard_read_continue1
	CMP #$00				; expecting $00, success
	BEQ spi_sdcard_read_continue2
	JMP spi_sdcard_read_error		; else, error!
spi_sdcard_read_continue2
	JSR spi_base_waitresult			; wait until non-$FF result is read
	CMP #$FF
	BNE spi_sdcard_read_continue3
	JMP spi_sdcard_read_error
spi_sdcard_read_continue3
	CMP #$FE				; expecting $FE, success
	BEQ spi_sdcard_read_continue4
	JMP spi_sdcard_read_error		; else, error!
spi_sdcard_read_continue4
	STZ sub_write+1
	PLY
	PLX
	PLA
	PHA
	PHX
	PHY
	STA sub_write+2
	LDX #$00
spi_sdcard_read_loop1				; read 512 bytes, 2 x 256 here
	JSR spi_base_receive_byte		; the last two bytes should be $55 then $AA
	JSR sub_write
	INC sub_write+1				; increment sub_write location
	LDA sub_write+1
	BNE spi_sdcard_read_loop1_inc
	INC sub_write+2
spi_sdcard_read_loop1_inc
	INX
	CPX #$00
	BNE spi_sdcard_read_loop1		; return to loop
spi_sdcard_read_loop2
	JSR spi_base_receive_byte		; repeat for the next 256 bytes
	JSR sub_write
	INC sub_write+1
	LDA sub_write+1
	BNE spi_sdcard_read_loop2_inc
	INC sub_write+2
spi_sdcard_read_loop2_inc
	INX
	CPX #$00
	BNE spi_sdcard_read_loop2		; return to loop
	JSR spi_base_receive_byte		; I *think* we read two more bytes, but ignore?
	JSR spi_base_receive_byte		
	JSR spi_base_disable			; disable
	JMP spi_sdcard_read_exit		; exit cleanly
spi_sdcard_read_error
	PHA
	LDA #"?"				; if errors, print exclamation mark where cursor used to be
	JSR printchar				; and also print what was in the accumlator
	PLX
	LDA ascii_key_high,X
	JSR printchar
	LDA ascii_key_low,X
	JSR printchar
	PLY
	PLX
	PLA
	EOR #$FF				; just make A not equal to what it started with
	RTS					; to indicate an error occured
spi_sdcard_read_exit
	PLY
	PLX
	PLA
	RTS



soft_jump
	PHA
	LDA #"~"
	JSR printchar
soft_jump_loop
	JSR inputchar
	CMP #$00
	BEQ soft_jump_loop
	PLA
	CMP inputchar_value
	BNE soft_jump_exit
	LDA key_alt_control
	BEQ soft_jump_exit
	LDA inputchar_value
	CMP #$19 ; SDcard
	BEQ soft_jump_sdcard
	CMP #$0F ; reset
	BEQ soft_jump_reset
	LDA #%00001110 ; used for reset???
	JMP (command_addr4_low) ; $FFF0 to bank switch, others possible now
soft_jump_sdcard
	LDA #$04 ; used with SDcard
	JMP (command_addr4_low) ; already JSR'd to get here
soft_jump_reset
	LDA #%10001110 ; used for reset???
	JMP (command_addr4_low) ; should to go 'vector_reset', others possible now
soft_jump_exit
	RTS


bell
	PHA
	PHX
	PHY
	LDA output_byte
	PHA
	LDX #$FF
	LDY #$FF
bell_loop
	DEX
	BNE bell_loop
	LDA output_byte
	EOR #%10000000
	STA output_byte
	STA $FFFF ; write to ROM for output
	DEY
	BNE bell_loop
	PLA
	EOR #%10000000 ; bell actually changes RAM banks (if connected such)
	STA output_byte
	STA $FFFF
	PLY
	PLX
	PLA
	RTS



	.ORG $FF60

; 6502 running at 3.14 MHz,
; PS/2 keyboard running at 17 kHz
; That gives me 184 to 314 cycles between signals.
; Half of each would be 92 or 157 cycles for low /IRQ.


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

	.ORG $FFE0 ; tetra game
	
	LDA #%10000000
	BNE bank_switch

	.ORG $FFE8 ; extra

	LDA #%10000001
	BNE bank_switch

	.ORG $FFF0

bank_switch
	STA $FFFF
	NOP ; just to be safe
	JMP vector_reset


	.ORG $FFFA

; reset/interrupt vectors
	.WORD jump_vector_nmi
	.WORD vector_reset
	.WORD jump_vector_irq


