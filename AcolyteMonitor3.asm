; Monitor3 Program for Acolyte 6502 Computer

; This adds SD card support.  Well, hopefully.

; DO NOT USE COLONS ANYWHERE!!!
; If you use colons anywhere here, it will not be able to be used with the Parser.o
; To assemble and burn.
; ~/dev65/bin/as65 AcolyteMonitor2.asm ; ~/dev65/bin/Parser.o AcolyteMonitor2.lst AcolyteMonitor2.bin 32768 0 98304 ; minipro -p sst39sf010 -w AcolyteMonitor2.bin

; INTRODUCTION

; This 'monitor' is nearly an operating system, a replacement for BASIC.
; It contains functions to read/write/modify data/code, and then also save/load data.
; I would not say it is 'complete', but most of the basic functions are there.

; COMMANDS

; CODE $XXXX = Start Assembly code at address $XXXX.
; PAGE $XXXX = View memory dump at $XXXX, high byte is page, low byte is cursor.
; MOVE $XXXX,$YYYY,$ZZZZ = Move data from $XXXX to $YYYY into $ZZZZ and beyond.
; FILL $XXXX,$YYYY,$ZZ = Fill data from $XXXX to $YYYY with $ZZ.
; GOTO $XXXX = Goto address $XXXX and run.
; TAPE $XXXX,$YYYY = Populate audio tape input from $XXXX to $YYYY.
; SAVE $XXXX,$YYYY = Save data from $XXXX to $YYYY into SPI EEPROM A.
; LOAD $XXXX,$YYYY = Load data from $XXXX to $YYYY with SPI EEPROM A.
; BYTE $XX = Write single byte $XX to current cursor location.
; FIND $XX = Find and highlight any occurence of byte $XX in memory dump.
; HELP = Display help menu.

; ASSEMBLER COMMANDS

; ! $XX $YY ... = Hex data sequence
; 'ABCDEF ... = String data sequence
; ^ = Realign top of code
; Assembler accepts all normal code.
; Examples included below.
; NOP
; INC A
; LDA #$44
; ADC $4444
; STA $4444,X
; JMP ($4444)

; Arrow keys move the cursor in the memory dump.
; Page Up/Down moves the page in the memory dump.
; Escape key clears the command line and returns to memory dump.

; HARDWARE

; Memory Map
; $0000 - $00FF = Zero Page
; $0100 - $01FF = Stack
; $0200 - $023F = VIA (duplicated 16 bytes 4 times)
; $0240 - $02FF = Unused I/O
; $0300 - $03FF = Unused I/O Expansion Page
; $0400 - $3FFF = General Purpose RAM
; $4000 - $7FFF = Banked RAM (4 banks of 16K each)
; $8000 - $FFFF = ROM (read) and Video RAM (write)

; VIA Map
; PB0 = SPI_SCLK
; PB1 = SPI_MOSI
; PB2 = SPI_MEMA_CS
; PB3 = SPI_MEMB_CS
; PB4 = SPI_SD_CS
; PB5 = SPI_10A_CS
; PB6 = SPI_10B_CS
; PB7 = SPI_MISO
; CB1 = UNUSED
; CB2 = UNUSED
; PA0 = VIDEO_MODE1
; PA1 = VIDEO_MODE2
; PA2 = ROM_BANK1
; PA3 = ROM_BANK2
; PA4 = RAM_BANK1
; PA5 = RAM_BANK2
; PA6 = AUDIO_IN
; PA7 = KEY_DATA
; CA1 = KEY_CLK (interrupt on falling edge)
; CA2 = SPI_AUX

	.65C02
	.ORG $8000


; 1K bytes monochrome character rom
; this is for only 128 characters, a lot of them are blank anyways
; linked with PS/2 keyboard hex output
charrom
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
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$20,$10,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$7C,$C6,$C6,$C6,$DE,$CC,$7A
	.BYTE $00,$30,$78,$78,$78,$30,$00,$30
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$FE,$0E,$1C,$38,$70,$E0,$FE
	.BYTE $00,$7C,$C6,$C0,$7C,$06,$C6,$7C
	.BYTE $00,$38,$6C,$C6,$C6,$FE,$C6,$C6
	.BYTE $00,$C6,$C6,$D6,$FE,$EE,$C6,$C6
	.BYTE $00,$7C,$C6,$D6,$D6,$DC,$C0,$7C
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$7C,$C6,$C0,$C0,$C0,$C6,$7C
	.BYTE $00,$C6,$EE,$7C,$38,$7C,$EE,$C6
	.BYTE $00,$F8,$CC,$C6,$C6,$C6,$CC,$F8
	.BYTE $00,$FE,$C0,$C0,$F8,$C0,$C0,$FE
	.BYTE $00,$10,$7E,$D0,$7C,$16,$FC,$10
	.BYTE $00,$6C,$FE,$6C,$6C,$6C,$FE,$6C
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$C6,$C6,$C6,$C6,$6C,$38,$10
	.BYTE $00,$FE,$C0,$C0,$F8,$C0,$C0,$C0
	.BYTE $00,$FE,$38,$38,$38,$38,$38,$38
	.BYTE $00,$FC,$C6,$C6,$FC,$D8,$CC,$C6
	.BYTE $00,$42,$A6,$4C,$18,$34,$6A,$C4
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$C6,$E6,$F6,$DE,$CE,$C6,$C6
	.BYTE $00,$FC,$C6,$C6,$FC,$C6,$C6,$FC
	.BYTE $00,$C6,$C6,$C6,$FE,$C6,$C6,$C6
	.BYTE $00,$7E,$C0,$C0,$DE,$C6,$C6,$7E
	.BYTE $00,$C6,$C6,$C6,$7C,$38,$38,$38
	.BYTE $00,$10,$38,$6C,$C6,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$C6,$EE,$FE,$D6,$C6,$C6,$C6
	.BYTE $00,$1E,$06,$06,$06,$C6,$C6,$7C
	.BYTE $00,$C6,$C6,$C6,$C6,$C6,$C6,$7C
	.BYTE $00,$70,$D8,$70,$DA,$CE,$C6,$7C
	.BYTE $00,$6C,$38,$6C,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$30,$30,$10,$20
	.BYTE $00,$C6,$CC,$D8,$F0,$D8,$CC,$C6
	.BYTE $00,$FE,$38,$38,$38,$38,$38,$FE
	.BYTE $00,$7C,$C6,$C6,$C6,$C6,$C6,$7C
	.BYTE $00,$70,$18,$0C,$0C,$0C,$18,$70
	.BYTE $00,$1C,$30,$60,$60,$60,$30,$1C
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$30,$30
	.BYTE $00,$7C,$C6,$06,$3C,$30,$00,$30
	.BYTE $00,$C0,$C0,$C0,$C0,$C0,$C0,$FE
	.BYTE $00,$00,$00,$30,$00,$00,$00,$30
	.BYTE $00,$FC,$C6,$C6,$FC,$C0,$C0,$C0
	.BYTE $00,$00,$00,$00,$00,$00,$00,$FE
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$30,$30,$10,$20,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$7C,$60,$60,$60,$60,$60,$7C
	.BYTE $00,$00,$00,$00,$7C,$00,$7C,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$7C,$0C,$0C,$0C,$0C,$0C,$7C
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$40,$60,$30,$18,$0C,$06,$02
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
	.BYTE $00,$F8,$38,$38,$38,$38,$38,$FE
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$1E,$36,$66,$C6,$FE,$06,$06
	.BYTE $00,$FE,$C6,$0C,$18,$30,$60,$C0
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$7C,$CE,$C6,$C6,$C6,$E6,$7C
	.BYTE $00,$00,$00,$00,$00,$00,$30,$30
	.BYTE $00,$7C,$C6,$0C,$38,$60,$C0,$FE
	.BYTE $00,$FE,$C0,$FC,$06,$06,$C6,$7C
	.BYTE $00,$7C,$C6,$C0,$FC,$C6,$C6,$7C
	.BYTE $00,$7C,$C6,$C6,$7C,$C6,$C6,$7C
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$10,$10,$7C,$10,$10
	.BYTE $00,$7C,$C6,$06,$3C,$06,$C6,$7C
	.BYTE $00,$00,$00,$00,$00,$7C,$00,$00
	.BYTE $00,$6C,$38,$6C,$00,$00,$00,$00
	.BYTE $00,$7C,$C6,$C6,$7E,$06,$C6,$7C
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00


; 256 bytes for high character
; store X as the byte desired, then LDAax to find
; the PS/2 hex character for the high nibble
printchar_key_high
	.BYTE $70,$70,$70,$70,$70,$70,$70,$70
	.BYTE $70,$70,$70,$70,$70,$70,$70,$70
	.BYTE $69,$69,$69,$69,$69,$69,$69,$69
	.BYTE $69,$69,$69,$69,$69,$69,$69,$69
	.BYTE $72,$72,$72,$72,$72,$72,$72,$72
	.BYTE $72,$72,$72,$72,$72,$72,$72,$72
	.BYTE $7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A
	.BYTE $7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A
	.BYTE $6B,$6B,$6B,$6B,$6B,$6B,$6B,$6B
	.BYTE $6B,$6B,$6B,$6B,$6B,$6B,$6B,$6B
	.BYTE $73,$73,$73,$73,$73,$73,$73,$73
	.BYTE $73,$73,$73,$73,$73,$73,$73,$73
	.BYTE $74,$74,$74,$74,$74,$74,$74,$74
	.BYTE $74,$74,$74,$74,$74,$74,$74,$74
	.BYTE $6C,$6C,$6C,$6C,$6C,$6C,$6C,$6C
	.BYTE $6C,$6C,$6C,$6C,$6C,$6C,$6C,$6C
	.BYTE $75,$75,$75,$75,$75,$75,$75,$75
	.BYTE $75,$75,$75,$75,$75,$75,$75,$75
	.BYTE $7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D
	.BYTE $7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D
	.BYTE $1C,$1C,$1C,$1C,$1C,$1C,$1C,$1C
	.BYTE $1C,$1C,$1C,$1C,$1C,$1C,$1C,$1C
	.BYTE $32,$32,$32,$32,$32,$32,$32,$32
	.BYTE $32,$32,$32,$32,$32,$32,$32,$32
	.BYTE $21,$21,$21,$21,$21,$21,$21,$21
	.BYTE $21,$21,$21,$21,$21,$21,$21,$21
	.BYTE $23,$23,$23,$23,$23,$23,$23,$23
	.BYTE $23,$23,$23,$23,$23,$23,$23,$23
	.BYTE $24,$24,$24,$24,$24,$24,$24,$24
	.BYTE $24,$24,$24,$24,$24,$24,$24,$24
	.BYTE $2B,$2B,$2B,$2B,$2B,$2B,$2B,$2B
	.BYTE $2B,$2B,$2B,$2B,$2B,$2B,$2B,$2B

; 256 bytes for low character
; store X as the byte desired, then LDAax to find
; the PS/2 hex character for the low nibble
printchar_key_low
	.BYTE $70,$69,$72,$7A,$6B,$73,$74,$6C
	.BYTE $75,$7D,$1C,$32,$21,$23,$24,$2B
	.BYTE $70,$69,$72,$7A,$6B,$73,$74,$6C
	.BYTE $75,$7D,$1C,$32,$21,$23,$24,$2B
	.BYTE $70,$69,$72,$7A,$6B,$73,$74,$6C
	.BYTE $75,$7D,$1C,$32,$21,$23,$24,$2B
	.BYTE $70,$69,$72,$7A,$6B,$73,$74,$6C
	.BYTE $75,$7D,$1C,$32,$21,$23,$24,$2B
	.BYTE $70,$69,$72,$7A,$6B,$73,$74,$6C
	.BYTE $75,$7D,$1C,$32,$21,$23,$24,$2B
	.BYTE $70,$69,$72,$7A,$6B,$73,$74,$6C
	.BYTE $75,$7D,$1C,$32,$21,$23,$24,$2B
	.BYTE $70,$69,$72,$7A,$6B,$73,$74,$6C
	.BYTE $75,$7D,$1C,$32,$21,$23,$24,$2B
	.BYTE $70,$69,$72,$7A,$6B,$73,$74,$6C
	.BYTE $75,$7D,$1C,$32,$21,$23,$24,$2B
	.BYTE $70,$69,$72,$7A,$6B,$73,$74,$6C
	.BYTE $75,$7D,$1C,$32,$21,$23,$24,$2B
	.BYTE $70,$69,$72,$7A,$6B,$73,$74,$6C
	.BYTE $75,$7D,$1C,$32,$21,$23,$24,$2B
	.BYTE $70,$69,$72,$7A,$6B,$73,$74,$6C
	.BYTE $75,$7D,$1C,$32,$21,$23,$24,$2B
	.BYTE $70,$69,$72,$7A,$6B,$73,$74,$6C
	.BYTE $75,$7D,$1C,$32,$21,$23,$24,$2B
	.BYTE $70,$69,$72,$7A,$6B,$73,$74,$6C
	.BYTE $75,$7D,$1C,$32,$21,$23,$24,$2B
	.BYTE $70,$69,$72,$7A,$6B,$73,$74,$6C
	.BYTE $75,$7D,$1C,$32,$21,$23,$24,$2B
	.BYTE $70,$69,$72,$7A,$6B,$73,$74,$6C
	.BYTE $75,$7D,$1C,$32,$21,$23,$24,$2B
	.BYTE $70,$69,$72,$7A,$6B,$73,$74,$6C
	.BYTE $75,$7D,$1C,$32,$21,$23,$24,$2B

; 256 bytes for return value
; set X as the PS/2 hex value, then LDAax to find
; the numeric hex value.
; most of the values here are $FF, which means
; that it is not a hex character 0-9,A-F.
printchar_value
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$0A,$FF,$FF,$FF
	.BYTE $FF,$0C,$FF,$0D,$0E,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$0F,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$0B,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$01,$FF,$04,$07,$FF,$FF,$FF
	.BYTE $00,$FF,$02,$05,$06,$08,$FF,$FF
	.BYTE $FF,$FF,$03,$FF,$FF,$09,$FF,$FF
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
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF


; assembler code look up table
; make sure to ignore spaces, colons, commas, right parenthesis, and dollar signs in the command line, at least
; $00 and $01 is actually two hex characters, low and high respectively, $FF is end of command
; the last byte is the instruction value.
; this does not include any zero page code.
assembler_lookup
	.BYTE $1C,$23,$21,$26,$00,$FF,$FF,$69 ; ADC #$44
	.BYTE $1C,$23,$21,$01,$00,$22,$FF,$7D ; ADC $4444,X
	.BYTE $1C,$23,$21,$01,$00,$35,$FF,$79 ; ADC $4444,Y
	.BYTE $1C,$23,$21,$01,$00,$FF,$FF,$6D ; ADC $4444
	.BYTE $1C,$31,$23,$26,$00,$FF,$FF,$29 ; AND #$44
	.BYTE $1C,$31,$23,$01,$00,$22,$FF,$3D ; AND $4444,X
	.BYTE $1C,$31,$23,$01,$00,$35,$FF,$39 ; AND $4444,Y
	.BYTE $1C,$31,$23,$01,$00,$FF,$FF,$2D ; AND $4444
	.BYTE $1C,$1B,$4B,$1C,$FF,$FF,$FF,$0A ; ASL A
	.BYTE $1C,$1B,$4B,$01,$00,$22,$FF,$1E ; ASL $4444,X
	.BYTE $1C,$1B,$4B,$01,$00,$FF,$FF,$0E ; ASL $4444
	.BYTE $32,$43,$2C,$26,$00,$FF,$FF,$89 ; BIT #$44
	.BYTE $32,$43,$2C,$01,$00,$22,$FF,$3C ; BIT $4444,X
	.BYTE $32,$43,$2C,$01,$00,$FF,$FF,$2C ; BIT $4444
	.BYTE $32,$4D,$4B,$00,$FF,$FF,$FF,$10 ; BPL $44
	.BYTE $32,$3A,$43,$00,$FF,$FF,$FF,$30 ; BMI $44
	.BYTE $32,$2A,$21,$00,$FF,$FF,$FF,$50 ; BVC $44
	.BYTE $32,$2A,$1B,$00,$FF,$FF,$FF,$70 ; BVS $44
	.BYTE $32,$21,$21,$00,$FF,$FF,$FF,$90 ; BCC $44
	.BYTE $32,$21,$1B,$00,$FF,$FF,$FF,$B0 ; BCS $44
	.BYTE $32,$31,$24,$00,$FF,$FF,$FF,$D0 ; BNE $44
	.BYTE $32,$24,$15,$00,$FF,$FF,$FF,$F0 ; BEQ $44
	.BYTE $32,$2D,$1C,$FF,$FF,$FF,$FF,$80 ; BRA
	.BYTE $32,$2D,$42,$FF,$FF,$FF,$FF,$00 ; BRK
	.BYTE $21,$3A,$4D,$26,$00,$FF,$FF,$C9 ; CMP #$44
	.BYTE $21,$3A,$4D,$01,$00,$22,$FF,$DD ; CMP $4444,X
	.BYTE $21,$3A,$4D,$01,$00,$35,$FF,$D9 ; CMP $4444,Y
	.BYTE $21,$3A,$4D,$01,$00,$FF,$FF,$CD ; CMP $4444
	.BYTE $21,$4D,$22,$26,$00,$FF,$FF,$E0 ; CPX #$44
	.BYTE $21,$4D,$22,$01,$00,$FF,$FF,$EC ; CPX $4444
	.BYTE $21,$4D,$35,$26,$00,$FF,$FF,$C0 ; CPY #$44
	.BYTE $21,$4D,$35,$01,$00,$FF,$FF,$CC ; CPY $4444
	.BYTE $23,$24,$21,$1C,$FF,$FF,$FF,$3A ; DEC A
	.BYTE $23,$24,$21,$01,$00,$22,$FF,$DE ; DEC $4444,X
	.BYTE $23,$24,$21,$01,$00,$FF,$FF,$CE ; DEC $4444
	.BYTE $23,$24,$22,$FF,$FF,$FF,$FF,$CA ; DEX
	.BYTE $23,$24,$35,$FF,$FF,$FF,$FF,$88 ; DEY
	.BYTE $24,$44,$2D,$26,$00,$FF,$FF,$49 ; EOR #$44
	.BYTE $24,$44,$2D,$01,$00,$22,$FF,$5D ; EOR $4444,X
	.BYTE $24,$44,$2D,$01,$00,$35,$FF,$59 ; EOR $4444,Y
	.BYTE $24,$44,$2D,$01,$00,$FF,$FF,$4D ; EOR $4444
	.BYTE $21,$4B,$21,$FF,$FF,$FF,$FF,$18 ; CLC
	.BYTE $1B,$24,$21,$FF,$FF,$FF,$FF,$38 ; SEC
	.BYTE $21,$4B,$43,$FF,$FF,$FF,$FF,$58 ; CLI
	.BYTE $1B,$24,$43,$FF,$FF,$FF,$FF,$78 ; SEI
	.BYTE $21,$4B,$2A,$FF,$FF,$FF,$FF,$B8 ; CLV
	.BYTE $21,$4B,$23,$FF,$FF,$FF,$FF,$D8 ; CLD
	.BYTE $1B,$24,$23,$FF,$FF,$FF,$FF,$F8 ; SED
	.BYTE $43,$31,$21,$1C,$FF,$FF,$FF,$1A ; INC A
	.BYTE $43,$31,$21,$01,$00,$22,$FF,$FE ; INC $4444,X
	.BYTE $43,$31,$21,$01,$00,$FF,$FF,$EE ; INC $4444
	.BYTE $43,$31,$22,$FF,$FF,$FF,$FF,$E8 ; INX
	.BYTE $43,$31,$35,$FF,$FF,$FF,$FF,$C8 ; INY
	; This is where JMP ($4444,X) would go
	.BYTE $3B,$3A,$4D,$46,$01,$00,$FF,$6C ; JMP ($4444)
	.BYTE $3B,$3A,$4D,$01,$00,$FF,$FF,$4C ; JMP $4444	
	.BYTE $3B,$1B,$2D,$01,$00,$FF,$FF,$20 ; JSR $4444
	.BYTE $4B,$23,$1C,$26,$00,$FF,$FF,$A9 ; LDA #$44
	.BYTE $4B,$23,$1C,$01,$00,$22,$FF,$BD ; LDA $4444,X
	.BYTE $4B,$23,$1C,$01,$00,$35,$FF,$B9 ; LDA $4444,Y
	.BYTE $4B,$23,$1C,$01,$00,$FF,$FF,$AD ; LDA $4444
	.BYTE $4B,$23,$22,$26,$00,$FF,$FF,$A2 ; LDX #$44
        .BYTE $4B,$23,$22,$01,$00,$35,$FF,$BE ; LDX $4444,Y
        .BYTE $4B,$23,$22,$01,$00,$FF,$FF,$AE ; LDX $4444
	.BYTE $4B,$23,$35,$26,$00,$FF,$FF,$A0 ; LDY #$44
        .BYTE $4B,$23,$35,$01,$00,$22,$FF,$BC ; LDY $4444,X
        .BYTE $4B,$23,$35,$01,$00,$FF,$FF,$AC ; LDY $4444
	.BYTE $4B,$1B,$2D,$1C,$FF,$FF,$FF,$4A ; LSR A
	.BYTE $4B,$1B,$2D,$01,$00,$22,$FF,$5E ; LSR $4444,X
	.BYTE $4B,$1B,$2D,$01,$00,$FF,$FF,$4E ; LSR $4444
	.BYTE $31,$44,$4D,$FF,$FF,$FF,$FF,$EA ; NOP
	.BYTE $44,$2D,$1C,$26,$00,$FF,$FF,$09 ; ORA #$44
	.BYTE $44,$2D,$1C,$01,$00,$22,$FF,$1D ; ORA $4444,X
	.BYTE $44,$2D,$1C,$01,$00,$35,$FF,$19 ; ORA $4444,Y
	.BYTE $44,$2D,$1C,$01,$00,$FF,$FF,$0D ; ORA $4444
	.BYTE $2C,$1C,$22,$FF,$FF,$FF,$FF,$AA ; TAX
	.BYTE $2C,$22,$1C,$FF,$FF,$FF,$FF,$8A ; TXA
	.BYTE $2C,$1C,$35,$FF,$FF,$FF,$FF,$A8 ; TAY
	.BYTE $2C,$35,$1C,$FF,$FF,$FF,$FF,$98 ; TYA
	.BYTE $2D,$44,$4B,$1C,$FF,$FF,$FF,$2A ; ROL A
	.BYTE $2D,$44,$4B,$01,$00,$22,$FF,$3E ; ROL $4444,X
	.BYTE $2D,$44,$4B,$01,$00,$FF,$FF,$2E ; ROL $4444
	.BYTE $2D,$44,$2D,$1C,$FF,$FF,$FF,$6A ; ROR A
	.BYTE $2D,$44,$2D,$01,$00,$22,$FF,$7E ; ROR $4444,X
	.BYTE $2D,$44,$2D,$01,$00,$FF,$FF,$6E ; ROR $4444
	.BYTE $2D,$2C,$43,$FF,$FF,$FF,$FF,$40 ; RTI
	.BYTE $2D,$2C,$1B,$FF,$FF,$FF,$FF,$60 ; RTS
	.BYTE $1B,$32,$21,$26,$00,$FF,$FF,$E9 ; SBC #$44
	.BYTE $1B,$32,$21,$01,$00,$22,$FF,$FD ; SBC $4444,X
	.BYTE $1B,$32,$21,$01,$00,$35,$FF,$F9 ; SBC $4444,Y
	.BYTE $1B,$32,$21,$01,$00,$FF,$FF,$ED ; SBC $4444
	.BYTE $1B,$2C,$1C,$01,$00,$22,$FF,$9D ; STA $4444,X
	.BYTE $1B,$2C,$1C,$01,$00,$35,$FF,$99 ; STA $4444,Y
	.BYTE $1B,$2C,$1C,$01,$00,$FF,$FF,$8D ; STA $4444
        .BYTE $1B,$2C,$22,$01,$00,$FF,$FF,$8E ; STX $4444
        .BYTE $1B,$2C,$35,$01,$00,$FF,$FF,$8C ; STY $4444
	.BYTE $1B,$2C,$1A,$01,$00,$22,$FF,$9E ; STZ $4444,X
	.BYTE $1B,$2C,$1A,$01,$00,$FF,$FF,$9C ; STZ $4444
	.BYTE $1B,$2C,$4D,$FF,$FF,$FF,$FF,$DB ; STP
	.BYTE $1D,$1C,$43,$FF,$FF,$FF,$FF,$CB ; WAI
	.BYTE $2C,$22,$1B,$FF,$FF,$FF,$FF,$9A ; TXS
	.BYTE $2C,$1B,$22,$FF,$FF,$FF,$FF,$BA ; TSX
	.BYTE $4D,$33,$1C,$FF,$FF,$FF,$FF,$48 ; PHA
	.BYTE $4D,$4B,$1C,$FF,$FF,$FF,$FF,$68 ; PLA
	.BYTE $4D,$33,$22,$FF,$FF,$FF,$FF,$DA ; PHX
	.BYTE $4D,$4B,$22,$FF,$FF,$FF,$FF,$FA ; PLX
	.BYTE $4D,$33,$35,$FF,$FF,$FF,$FF,$5A ; PHY
	.BYTE $4D,$4B,$35,$FF,$FF,$FF,$FF,$7A ; PLY
	.BYTE $4D,$33,$4D,$FF,$FF,$FF,$FF,$08 ; PHP
	.BYTE $4D,$4B,$4D,$FF,$FF,$FF,$FF,$28 ; PLP

; ascii/ps2 characters for help menu text
; $5A is newline, the rest should output as normal
; $FF to end.
help_text
	.BYTE $1C,$21,$44,$4B,$35,$2C,$24,$29
	.BYTE $74,$73,$70,$72,$29,$21,$44,$3A
	.BYTE $4D,$3C,$2C,$24,$2D,$29,$7B,$29
	.BYTE $33,$24,$4B,$4D,$29,$3A,$24,$31
	.BYTE $3C,$5A,$5A,$21,$44,$3A,$3A,$1C
	.BYTE $31,$23,$1B,$4C,$5A,$21,$44,$23
	.BYTE $24,$29,$25,$22,$22,$22,$22,$29
	.BYTE $29,$29,$29,$29,$29,$29,$29,$29
	.BYTE $29,$29,$29,$29,$55,$29,$1B,$2C
	.BYTE $1C,$2D,$2C,$29,$1C,$1B,$1B,$24
	.BYTE $3A,$32,$4B,$35,$29,$21,$44,$23
	.BYTE $24,$29,$1B,$3C,$32,$2D,$44,$3C
	.BYTE $2C,$43,$31,$24,$29,$1C,$2C,$29
	.BYTE $22,$5A,$4D,$1C,$34,$24,$29,$25
	.BYTE $22,$22,$22,$22,$29,$29,$29,$29
	.BYTE $29,$29,$29,$29,$29,$29,$29,$29
	.BYTE $29,$55,$29,$23,$43,$1B,$4D,$4B
	.BYTE $1C,$35,$29,$4D,$1C,$34,$24,$29
	.BYTE $44,$2B,$29,$1B,$24,$4B,$24,$21
	.BYTE $2C,$29,$4B,$44,$21,$1C,$2C,$43
	.BYTE $44,$31,$29,$22,$29,$43,$31,$29
	.BYTE $3A,$24,$3A,$44,$2D,$35,$5A,$32
	.BYTE $35,$2C,$24,$29,$25,$22,$22,$29
	.BYTE $29,$29,$29,$29,$29,$29,$29,$29
	.BYTE $29,$29,$29,$29,$29,$29,$55,$29
	.BYTE $1D,$2D,$43,$2C,$24,$29,$1B,$43
	.BYTE $31,$34,$4B,$24,$29,$32,$35,$2C
	.BYTE $24,$29,$22,$29,$43,$31,$2C,$44
	.BYTE $29,$1B,$24,$4B,$24,$21,$2C,$29
	.BYTE $4B,$44,$21,$1C,$2C,$43,$44,$31
	.BYTE $5A,$2B,$43,$31,$23,$29,$25,$22
	.BYTE $22,$29,$29,$29,$29,$29,$29,$29
	.BYTE $29,$29,$29,$29,$29,$29,$29,$29
	.BYTE $55,$29,$2B,$43,$31,$23,$29,$32
	.BYTE $35,$2C,$24,$29,$22,$29,$43,$31
	.BYTE $29,$3A,$24,$3A,$44,$2D,$35,$29
	.BYTE $1C,$31,$23,$29,$33,$43,$34,$33
	.BYTE $4B,$43,$34,$33,$2C,$5A,$3A,$44
	.BYTE $2A,$24,$29,$25,$22,$22,$22,$22
	.BYTE $41,$25,$35,$35,$35,$35,$41,$25
	.BYTE $1A,$1A,$1A,$1A,$29,$55,$29,$3A
	.BYTE $44,$2A,$24,$29,$3A,$24,$3A,$44
	.BYTE $2D,$35,$29,$2B,$2D,$44,$3A,$29
	.BYTE $22,$29,$2C,$44,$29,$35,$29,$43
	.BYTE $31,$2C,$44,$29,$1A,$5A,$2B,$43
	.BYTE $4B,$4B,$29,$25,$22,$22,$22,$22
	.BYTE $41,$25,$35,$35,$35,$35,$41,$25
	.BYTE $1A,$1A,$29,$29,$29,$55,$29,$2B
	.BYTE $43,$4B,$4B,$29,$3A,$24,$3A,$44
	.BYTE $2D,$35,$29,$2B,$2D,$44,$3A,$29
	.BYTE $22,$29,$2C,$44,$29,$35,$29,$1D
	.BYTE $43,$2C,$33,$29,$1A,$5A,$34,$44
	.BYTE $2C,$44,$29,$25,$22,$22,$22,$22
	.BYTE $29,$29,$29,$29,$29,$29,$29,$29
	.BYTE $29,$29,$29,$29,$29,$55,$29,$34
	.BYTE $44,$2C,$44,$29,$4B,$44,$21,$1C
	.BYTE $2C,$43,$44,$31,$29,$22,$29,$1C
	.BYTE $31,$23,$29,$2D,$3C,$31,$5A,$2C
	.BYTE $1C,$4D,$24,$29,$25,$22,$22,$22
	.BYTE $22,$41,$25,$35,$35,$35,$35,$29
	.BYTE $29,$29,$29,$29,$29,$29,$55,$29
	.BYTE $1C,$3C,$23,$43,$44,$29,$2C,$1C
	.BYTE $4D,$24,$29,$23,$1C,$2C,$1C,$29
	.BYTE $2C,$44,$29,$4D,$44,$4D,$3C,$4B
	.BYTE $1C,$2C,$24,$29,$2B,$2D,$44,$3A
	.BYTE $29,$22,$29,$2C,$44,$29,$35,$5A
	.BYTE $1B,$1C,$2A,$24,$29,$25,$22,$22
	.BYTE $22,$22,$41,$25,$35,$35,$35,$35
	.BYTE $29,$29,$29,$29,$29,$29,$29,$55
	.BYTE $29,$1B,$1C,$2A,$24,$29,$3A,$24
	.BYTE $3A,$44,$2D,$35,$29,$2B,$2D,$44
	.BYTE $3A,$29,$22,$29,$2C,$44,$29,$35
	.BYTE $29,$43,$31,$2C,$44,$29,$1B,$4D
	.BYTE $43,$29,$24,$24,$4D,$2D,$44,$3A
	.BYTE $29,$1C,$5A,$4B,$44,$1C,$23,$29
	.BYTE $25,$22,$22,$22,$22,$41,$25,$35
	.BYTE $35,$35,$35,$29,$29,$29,$29,$29
	.BYTE $29,$29,$55,$29,$4B,$44,$1C,$23
	.BYTE $29,$3A,$24,$3A,$44,$2D,$35,$29
	.BYTE $2B,$2D,$44,$3A,$29,$22,$29,$2C
	.BYTE $44,$29,$35,$29,$1D,$43,$2C,$33
	.BYTE $29,$1B,$4D,$43,$29,$24,$24,$4D
	.BYTE $2D,$44,$3A,$29,$1C,$5A,$21,$1C
	.BYTE $2D,$23,$29,$25,$22,$22,$22,$22
	.BYTE $41,$25,$35,$35,$35,$35,$41,$25
	.BYTE $1A,$1A,$1A,$1A,$29,$55,$29,$2D
	.BYTE $24,$1C,$23,$29,$1B,$23,$29,$21
	.BYTE $1C,$2D,$23,$29,$32,$4B,$44,$21
	.BYTE $42,$1B,$29,$22,$29,$2C,$44,$29
	.BYTE $35,$29,$1C,$31,$23,$29,$1B,$2C
	.BYTE $44,$2D,$24,$29,$1C,$2C,$29,$1A
	.BYTE $5A,$33,$24,$4B,$4D,$29,$29,$29
	.BYTE $29,$29,$29,$29,$29,$29,$29,$29
	.BYTE $29,$29,$29,$29,$29,$29,$29,$29
	.BYTE $55,$29,$1B,$33,$44,$1D,$29,$2C
	.BYTE $33,$43,$1B,$29,$33,$24,$4B,$4D
	.BYTE $29,$3A,$24,$31,$3C,$5A,$5A,$1C
	.BYTE $1B,$1B,$24,$3A,$32,$4B,$35,$29
	.BYTE $21,$44,$3A,$3A,$1C,$31,$23,$1B
	.BYTE $4C,$5A,$16,$29,$25,$22,$22,$29
	.BYTE $25,$35,$35,$29,$49,$49,$49,$29
	.BYTE $55,$29,$33,$24,$22,$29,$23,$1C
	.BYTE $2C,$1C,$29,$1B,$24,$15,$3C,$24
	.BYTE $31,$21,$24,$5A,$52,$1C,$32,$21
	.BYTE $23,$24,$2B,$29,$49,$49,$49,$29
	.BYTE $29,$29,$55,$29,$1B,$2C,$2D,$43
	.BYTE $31,$34,$29,$23,$1C,$2C,$1C,$29
	.BYTE $1B,$24,$15,$3C,$24,$31,$21,$24
	.BYTE $5A,$36,$29,$29,$29,$29,$29,$29
	.BYTE $29,$29,$29,$29,$29,$29,$29,$55
	.BYTE $29,$2D,$24,$1C,$4B,$43,$34,$31
	.BYTE $29,$2C,$44,$4D,$29,$44,$2B,$29
	.BYTE $21,$44,$23,$24,$5A,$24,$22,$1C
	.BYTE $3A,$4D,$4B,$24,$1B,$29,$44,$2B
	.BYTE $29,$1C,$1B,$1B,$24,$3A,$32,$4B
	.BYTE $35,$29,$43,$31,$1B,$2C,$2D,$3C
	.BYTE $21,$2C,$43,$44,$31,$1B,$4C,$5A
	.BYTE $31,$44,$4D,$5A,$43,$31,$21,$29
	.BYTE $1C,$5A,$4B,$23,$1C,$29,$26,$25
	.BYTE $6B,$6B,$5A,$1C,$23,$21,$29,$25
	.BYTE $6B,$6B,$6B,$6B,$5A,$1B,$2C,$1C
	.BYTE $29,$25,$6B,$6B,$6B,$6B,$41,$22
	.BYTE $5A,$3B,$3A,$4D,$29,$46,$25,$6B
	.BYTE $6B,$6B,$6B,$45,$5A,$5A,$4D,$2D
	.BYTE $24,$1B,$1B,$29,$24,$1B,$21,$1C
	.BYTE $4D,$24,$29,$42,$24,$35,$29,$2C
	.BYTE $44,$29,$2D,$24,$1B,$24,$2C,$FF


; ascii key values
; these are NOT real "ascii" values, but rather
; they are PS/2 keyboard hex values.
; I say 'ascii' because... that made sense to me.
; this is probably not a full list, I have been
; adding to it as I needed

ascii_0			.EQU $70
ascii_1			.EQU $69
ascii_2			.EQU $72
ascii_3			.EQU $7A
ascii_4			.EQU $6B
ascii_5			.EQU $73
ascii_6			.EQU $74
ascii_7			.EQU $6C
ascii_8			.EQU $75
ascii_9			.EQU $7D
ascii_A			.EQU $1C
ascii_B			.EQU $32
ascii_C			.EQU $21
ascii_D			.EQU $23
ascii_E			.EQU $24
ascii_F			.EQU $2B
ascii_G			.EQU $34
ascii_H			.EQU $33
ascii_I			.EQU $43
ascii_J			.EQU $3B
ascii_K			.EQU $42
ascii_L			.EQU $4B
ascii_M			.EQU $3A
ascii_N			.EQU $31
ascii_O			.EQU $44
ascii_P			.EQU $4D
ascii_Q			.EQU $15
ascii_R			.EQU $2D
ascii_S			.EQU $1B
ascii_T			.EQU $2C
ascii_U			.EQU $3C
ascii_V			.EQU $2A
ascii_W			.EQU $1D
ascii_X			.EQU $22
ascii_Y			.EQU $35
ascii_Z			.EQU $1A
ascii_space		.EQU $29
ascii_period		.EQU $49
ascii_period2		.EQU $71
ascii_comma		.EQU $41
ascii_colon		.EQU $4C
ascii_slash		.EQU $5D
ascii_apple		.EQU $1E
ascii_caret		.EQU $36
ascii_ampersand		.EQU $3D
ascii_asterisk		.EQU $3E
ascii_return		.EQU $5A
ascii_backspace		.EQU $66
ascii_escape		.EQU $76
ascii_parenthesis_left	.EQU $46
ascii_parenthesis_right	.EQU $45
ascii_bracket_left	.EQU $54
ascii_bracket_right	.EQU $5B
ascii_exclamation	.EQU $16
ascii_equal		.EQU $55
ascii_question		.EQU $4A
ascii_quote		.EQU $52
ascii_pound		.EQU $26
ascii_dollar		.EQU $25
ascii_percent		.EQU $2E
ext_arrow_up		.EQU $75
ext_arrow_down		.EQU $72
ext_arrow_left		.EQU $6B
ext_arrow_right		.EQU $74
ext_page_up		.EQU $7D
ext_page_down		.EQU $7A
ext_return		.EQU $5A

; memory locations
; these are just places to store data

screen			.EQU $8000
screen_last_one		.EQU $F400

via			.EQU $0200
via_pb			.EQU via+$00
via_pa			.EQU via+$01
via_db			.EQU via+$02
via_da			.EQU via+$03
via_pcr			.EQU via+$0C
via_ifr			.EQU via+$0D
via_ier			.EQU via+$0E

expansion		.EQU $0300

; notice these variables are not in zero page,
; the main reason being that I have not yet
; made the zero page assembler/disassembler codes

sub_copy		.EQU $0400
sub_read		.EQU $0410
sub_read2		.EQU $0420
sub_write		.EQU $0430
sub_jump		.EQU $0440

key_code		.EQU $0450
key_counter		.EQU $0451
key_extended		.EQU $0452
key_release		.EQU $0453
key_read_pos		.EQU $0454
key_write_pos		.EQU $0455
key_value		.EQU $0456

printchar_invert	.EQU $0457

command_length		.EQU $0458
command_mode		.EQU $0459

display_low		.EQU $045A
display_high		.EQU $045B
display_highlight	.EQU $045C

disassembler_low	.EQU $045D
disassembler_high	.EQU $045E
disassembler_pos	.EQU $045F
disassembler_height	.EQU $0460
disassembler_code	.EQU $0461
disassembler_code_low	.EQU $0462
disassembler_code_high	.EQU $0463
disassembler_letter1	.EQU $0464
disassembler_letter2	.EQU $0465
disassembler_letter3	.EQU $0466
disassembler_select	.EQU $0467

audio_value		.EQU $0468
audio_count		.EQU $0469

assembler_cursor_low	.EQU $046A
assembler_cursor_high	.EQU $046B
assembler_code		.EQU $046C
assembler_code_low	.EQU $046D
assembler_code_high	.EQU $046E
assembler_pos_low	.EQU $046F
assembler_pos_high	.EQU $0470
assembler_bytes		.EQU $0471
assembler_data		.EQU $0472
assembler_mode		.EQU $0473

execute_var1_low	.EQU $0474
execute_var1_high	.EQU $0475
execute_var2_low	.EQU $0476
execute_var2_high	.EQU $0477
execute_var3_low	.EQU $0478
execute_var3_high	.EQU $0479
execute_var4_low	.EQU $047A
execute_var4_high	.EQU $047B

spi_cs_enable		.EQU $047C ; 0XXXXX00 bit pattern, determines which SPI module is enabled

key_array		.EQU $0500 ; full page
command_array		.EQU $0600 ; full page

; there should be about 512 bytes remaining between the lookup tables
; and this actual start of the code

	.ORG $9000

; start of program upon reset

vector_reset
; turn off interrupts
; not sure if I need CLD or not
	SEI
	CLD

; setup via
; this is derived from hardware
; PB is almost all outputs because it controls the SPI stuff
; PB7 is the only SPI input MISO
; PA is again almost all outputs, mainly video modes, RAM and ROM banks
; PB6 is the audio input
; PB7 is the keyboard data line
; PA1 is the keyboard clock line
	LDA #%01111111
	STA via_db
	LDA #%00000000
	STA via_pb
	LDA #%00111111
	STA via_da
	LDA #%00000000 
	STA via_pa
	LDA #%00000000
	STA via_pcr
	LDA #%10000010
	STA via_ier

; turn interrupts back on
	CLI

; setup sub programs
; these are used all throughout the program
; there are two copies of 'read' because that was needed
; I put a lot of NOP's between them for no reason at all honestly
	LDA #$A9 ; LDA#
	STA sub_copy
	LDA #$03 ; 16-color
	STA sub_copy+$01
	LDA #$8D ; STAa
	STA sub_copy+$02
	LDA #<via_pa
	STA sub_copy+$03
	LDA #>via_pa
	STA sub_copy+$04
	LDA #$4C ; JMPa
	STA sub_copy+$05
	LDA #<copypicture
	STA sub_copy+$06
	LDA #>copypicture
	STA sub_copy+$07
	LDA #$EA ; NOP
	STA sub_copy+$08
	STA sub_copy+$09
	STA sub_copy+$0A
	STA sub_copy+$0B
	STA sub_copy+$0C
	STA sub_copy+$0D
	STA sub_copy+$0E
	STA sub_copy+$0F
	LDA #$AD ; LDAa
	STA sub_read
	STZ sub_read+$01
	STZ sub_read+$02
	LDA #$60 ; RTS
	STA sub_read+$03
	LDA #$EA ; NOP
	STA sub_read+$04
	STA sub_read+$05
	STA sub_read+$06
	STA sub_read+$07
	STA sub_read+$08
	STA sub_read+$09
	STA sub_read+$0A
	STA sub_read+$0B
	STA sub_read+$0C
	STA sub_read+$0D
	STA sub_read+$0E
	STA sub_read+$0F
	LDA #$AD ; LDAa
	STA sub_read2
	STZ sub_read2+$01
	STZ sub_read2+$02
	LDA #$60 ; RTS
	STA sub_read2+$03
	LDA #$EA ; NOP
	STA sub_read2+$04
	STA sub_read2+$05
	STA sub_read2+$06
	STA sub_read2+$07
	STA sub_read2+$08
	STA sub_read2+$09
	STA sub_read2+$0A
	STA sub_read2+$0B
	STA sub_read2+$0C
	STA sub_read2+$0D
	STA sub_read2+$0E
	STA sub_read2+$0F
	LDA #$8D ; STAa
	STA sub_write
	STZ sub_write+$01
	STZ sub_write+$02
	LDA #$60 ; RTS
	STA sub_write+$03
	LDA #$EA ; NOP
	STA sub_write+$04
	STA sub_write+$05
	STA sub_write+$06
	STA sub_write+$07
	STA sub_write+$08
	STA sub_write+$09
	STA sub_write+$0A
	STA sub_write+$0B
	STA sub_write+$0C
	STA sub_write+$0D
	STA sub_write+$0E
	STA sub_write+$0F
	LDA #$4C ; JMPa
	STA sub_jump
	STZ sub_jump+$01
	STZ sub_jump+$02
	LDA #$EA ; NOP
	STA sub_jump+$03
	STA sub_jump+$04
	STA sub_jump+$05
	STA sub_jump+$06
	STA sub_jump+$07
	STA sub_jump+$08
	STA sub_jump+$09
	STA sub_jump+$0A
	STA sub_jump+$0B
	STA sub_jump+$0C
	STA sub_jump+$0D
	STA sub_jump+$0E
	STA sub_jump+$0F

; initialize keyboard and audio stuff
; just setting everything to zero
; will have to do this at other times occasionally
	STZ key_counter
	STZ key_release
	STZ key_extended
	STZ key_read_pos
	STZ key_write_pos

	STZ audio_value
	STZ audio_count

; this puts the VGA display into monochrome mode
; very handy because you can get 80-column text on it
	LDA #%00000001 ; monochrome mode
	STA via_pa

; more initialization of variables
	STZ display_low
	STZ display_high
	STZ display_highlight
	STZ disassembler_low
	STZ disassembler_high
	STZ assembler_cursor_low
	STZ assembler_cursor_high
	STZ command_length
	STZ command_mode

; when you press the Escape key, you end up here
; just clears the screen before doing anything else
; more of a safety precaution really

main_refresh
	JSR clearscreen

; when you press the Return key, you end up here
; instead of clearing the screen, THEN going back and drawing (which is slow)
; here you just print right on top of what is there,
; this makes it faster (though redrawing the memory dump area is pretty slow still

main_print
	LDX #$00
	LDA #$00
main_print1
	STA command_array,X			; clear out command_array
	INX
	CPX #$00
	BNE main_print1
	LDA command_mode			; if in coding mode, put current address into command_array
	BEQ main_print2
	LDX #$00
	LDA assembler_cursor_high
	PHX
	TAX
	LDA printchar_key_high,X
	PLX
	STA command_array,X
	INX
	LDA assembler_cursor_high
	PHX
	TAX
	LDA printchar_key_low,X
	PLX
	STA command_array,X
	INX
	LDA assembler_cursor_low
	PHX
	TAX
	LDA printchar_key_high,X
	PLX
	STA command_array,X
	INX
	LDA assembler_cursor_low
	PHX
	TAX
	LDA printchar_key_low,X
	PLX
	STA command_array,X
	INX
	LDA #ascii_colon
	STA command_array,X
	INX
	LDA #ascii_space
	STA command_array,X
	LDA #$06
	STA command_length
	JMP main_print3
main_print2
	STZ command_length			; else, just set command_length to zero
main_print3
	LDA command_mode			; if not in coding mode, call printpage, which is the memory dump
	BNE main_print4
	JSR printpage
	JMP main_print5
main_print4
	JSR disassembler			; else, print the disassembler instead
main_print5
	LDA command_mode
	BEQ main_print6
	JMP main_print7
main_print6					; if in memory dump, print a small 'help' message
	LDY #>screen_last_one
	DEY
	DEY
	DEY
	DEY
	DEY
	DEY
	DEY
	DEY
	LDX #$00
	LDA #ascii_T				; so I know this is silly, but whatever, it works
	JSR printchar
	LDA #ascii_Y
	JSR printchar
	LDA #ascii_P
	JSR printchar
	LDA #ascii_E
	JSR printchar
	LDa #ascii_space
	JSR printchar
	LDA #ascii_quote
	JSR printchar
	LDA #ascii_H
	JSR printchar
	LDA #ascii_E
	JSR printchar
	LDA #ascii_L
	JSR printchar
	LDA #ascii_P
	JSR printchar
	LDA #ascii_quote
	JSR printchar
	LDA #ascii_space
	JSR printchar
	LDA #ascii_F
	JSR printchar
	LDA #ascii_O
	JSR printchar
	LDA #ascii_R
	JSR printchar
	LDA #ascii_space
	JSR printchar
	LDA #ascii_C
	JSR printchar
	LDA #ascii_O
	JSR printchar
	LDA #ascii_M
	JSR printchar
	LDA #ascii_M
	JSR printchar
	LDA #ascii_A
	JSR printchar
	LDA #ascii_N
	JSR printchar
	LDA #ascii_D
	JSR printchar
	LDA #ascii_S
	JSR printchar
main_print7
	LDY #>screen_last_one			; go to the bottom of the screen and print the cursor
	LDX #$00
	LDA #ascii_space
main_print8
	JSR printchar				; this prints a bunch of blanks on the bottom row, visibly clearing what would be the command_array
	CPX #$00
	BNE main_print8
main_print9
	CPX command_length			; then reprint characters that are actually in the command array (sometimes it's empty)
	BEQ main_printA
	LDA command_array,X
	JSR printchar
	JMP main_print9
main_printA
	LDA command_mode			; the cursor is usually the 'apple' symbol, but if in coding mode it is an 'ampersand' instead
	BNE main_printB
	LDA #ascii_apple
	JSR printchar
	DEX
	JMP main_loop
main_printB
	LDA #ascii_ampersand
	JSR printchar
	DEX

; this is the main loop
; essentially it waits for a key to be pressed, and then acts on that key
; sometimes that key is just a character, so it puts it in command_array and prints it out
; somtimes that key is Return, so it has to compute stuff
; sometimes that key is an extended key, particularly the Arrow keys, and the Page Up/Down keys
; and if so, it redraws the memory dump

main_loop
	LDA key_read_pos			; keep checking to see if there is a new key in the buffer
	CMP key_write_pos			; and when there is grab that key, and do stuff with it
	BEQ main_loop
	PHX
	TAX
	LDA key_array,X
	PLX
	INC key_read_pos
	STA key_value				; store in key_value, where you can grab it anytime you like later
	CMP #$F0 ; release			; release values are always $F0 and extended values are always $E0
	BEQ main_release			; always comes in this order - Extended - Release - Key Value
	CMP #$E0 ; extended
	BEQ main_extended
	LDA key_release				; any released keys are completely ignored
	BEQ main_loop1
	JMP main_exit
main_loop1
	LDA key_extended			; extended keys are special, jump to where you can decode them
	BEQ main_loop2
	JMP main_ext_keys
main_loop2
	LDA key_value
	CMP #ascii_return			; Return is special and will run commands, extended Return does the same thing but is found later
	BNE main_loop3
	JMP main_return
main_loop3
	CMP #ascii_backspace			; Backspace deletes things visibly and also from command_array
	BNE main_loop4
	JMP main_backspace
main_loop4
	CMP #ascii_escape			; Escape refreshes the screen, and if in coding mode, will exit to memory dump
	BNE main_loop5
	JMP main_escape
main_loop5
	JMP main_character			; else, it must be a regular ol' character
main_release
	STA key_release				; if the current key is $F0, then just store it for later, will be ignored and erased soon
	JMP main_loop
main_extended
	STA key_extended			; if the current key is $E0, then just store it for later, don't do anything else right now
	JMP main_loop
main_escape
	STZ command_mode			; make sure to exit coding mode and refresh the screen (that is, clear it, then re-draw it)
	JMP main_refresh
main_backspace
	LDA command_length			; don't back up past zero!
	BNE main_backspace1
 	JMP main_exit
main_backspace1					; this just removes the last character in the command_array and puts a zero in it's place
	PHA					; it also deletes the cursor, backs up, and then redraws the cursor again
	PHX
	LDX command_length
	LDA #$00
	STA command_array,X
	PLX
	PLA
	DEC command_length
	LDA #ascii_space
	JSR printchar
	DEX
	DEX
	LDA command_mode			; memory dump uses apple for cursor, coding mode uses ampersand
	BNE main_backspace2
	LDA #ascii_apple
	JSR printchar
	DEX
	JMP main_exit
main_backspace2
	LDA #ascii_ampersand
	JSR printchar
	DEX
	JMP main_exit
main_return					; some commands actually, like GOTO, will go jump somewhere else in memory after being completed
	LDA #<main_return1			; to make sure this works well, set the sub_jump to just after the 'executecommand' subroutine
	STA sub_jump+1				; but allow 'executecommand' to change sub_jump to whatever it wants
	LDA #>main_return1
	STA sub_jump+2 
	LDA #ascii_slash			; the slash character just says 'currently computing!', it is handy to know
	JSR printchar				; later, if there is an error, it will print a question mark quickly before being re-drawn
	LDA command_mode			; but if you hit Return while in coding mode, jump ahead some
	BNE main_return2
	JSR executecommand			; run the 'executecommand' if in the memory dump
	JMP sub_jump
main_return1
	JMP main_print				; after executing the command_array, if you haven't left the monitor program, just reprint screen
main_return2					; here it is adding 8 extra $00 values to the command_array at the end,
	PHX					; this is... because it works better with the assembler.  I don't know exactly why!
	PHY					; I think it is because it wants to exit early before it has actually finished the assembly process
	LDA #$00
	LDY #$08
main_return3
	LDX command_length
	STA command_array,X
	INC command_length
	DEY
	CPY #$00
	BNE main_return3
	PLY
	PLX
	JSR assembler				; now run the 'assembler' program on the command_array, only when in coding mode
	JMP main_print
main_ext_keys					; extended keys being weeded out here, extended Return works exactly like regular Return
	LDA key_value
	CMP #ext_return
	BNE main_ext_keys1
	JMP main_return
main_ext_keys1
	LDA command_mode			; but any other extended keys do not work in coding mode.
	BEQ main_ext_keys2
	JMP main_exit
main_ext_keys2					; if in memory dump, arrow keys and page up/down work.
	LDA key_value
	CMP #ext_page_up
	BNE main_ext_keys3
	JMP main_page_up
main_ext_keys3
	CMP #ext_page_down
	BNE main_ext_keys4
	JMP main_page_down
main_ext_keys4
	CMP #ext_arrow_up
	BNE main_ext_keys5
	JMP main_arrow_up
main_ext_keys5
	CMP #ext_arrow_down
	BNE main_ext_keys6
	JMP main_arrow_down
main_ext_keys6
	CMP #ext_arrow_left
	BNE main_ext_keys7
	JMP main_arrow_left
main_ext_keys7
	CMP #ext_arrow_right
	BNE main_ext_keys8
	JMP main_arrow_right
main_ext_keys8
	JMP main_exit				; any other extended key is not used
main_page_up					; page up increments the high nibble
	DEC display_high
	STZ key_release
	STZ key_extended
	JMP main_print
main_page_down					; page down decrements the high nibble
	INC display_high
	STZ key_release
	STZ key_extended
	JMP main_print
main_arrow_up					; arrow up/down sub/add $10 to the low nibble
	LDA display_low
	SEC
	SBC #$10
	STA display_low
	JMP main_print
main_arrow_down
	LDA display_low
	CLC
	ADC #$10
	STA display_low
	JMP main_print
main_arrow_left					; arrow left/right sub/add $01 to the low nibble
	DEC display_low
	JMP main_print
main_arrow_right
	INC display_low
	JMP main_print
main_character					; any other regular character is put into the command_array, and printed on the screen
	PHX
	LDX command_length
	STA command_array,X
	INC command_length
	PLX
	JSR printchar
	LDA command_mode			; again, memory dump uses apple, coding mode uses ampersand
	BNE main_character1
	LDA #ascii_apple
	JSR printchar
	DEX
	JMP main_exit
main_character1
	LDA #ascii_ampersand
	JSR printchar
	DEX
main_exit
	STZ key_release				; this only happens when a key value has been found, so the extended and release flags are now useless
	STZ key_extended
	JMP main_loop


; printchar sub-routine
; A = character value
; X = low screen address
; Y = high screen address
; this function is super important to the entire program, it prints characters onto the screen
; there are only characters from 0-127, most of them blank, but if you have a character from 128-255 
; it is the same as the original but inverted, pretty neat!
printchar
	PHA
	PHX
	PHY
	STX sub_write+1				; sub_write and sub_read are used here, so later sub_read2 is used in programs that also need to run 'printchar'
	STY sub_write+2
	LDX #<charrom
	LDY #>charrom
	STX sub_read+1
	STY sub_read+2
	STZ printchar_invert
	CMP #%10000000				; if it is a character from 128-255, flag it for inverting
	BCC printchar_limit
	INC printchar_invert
printchar_limit
	AND #%01111111 				; only 128 typical characters available, most are blank
	TAX
	LDY #$04
printchar_search				; this adds $08 as many times as is the hex value, so to find the data wanted on the lookup table
	CPX #$00
	BEQ printchar_loop
	DEX
	LDA sub_read+1
	CLC
	ADC #$08
	STA sub_read+1
	BNE printchar_search
	INC sub_read+2
	JMP printchar_search	
printchar_loop					; this is the actual printing loop, should be only 8 bytes printed to the screen
	JSR sub_read				; read the byte from lookup table
	PHA
	LDA printchar_invert
	BEQ printchar_continue
	PLA
	EOR #$FF 				; invert with 'not' logic (using EOR #$FF) beyond the original 128 characters
	PHA
printchar_continue
	PLA
	JSR sub_write				; write that byte to the screen coordinates given from X and Y
	INC sub_read+1
	LDA sub_write+1
	CLC
	ADC #$80				; move 128 bytes in video memory (that is one horizontal line)
	STA sub_write+1
	BCC printchar_loop
	INC sub_write+2
	DEY	
	CPY #$00				; because Y was set to $04 above, and 128 bytes per line, that makes 8 vertical lines total
	BNE printchar_loop
	PLY
	PLX
	INX					; increment horizontally one after printing a character
	PLA
	RTS


; printline sub-routine
; A = address low byte
; X = address high byte
; Y = screen high byte
; this prints a horizontal line in the memory dump
; so that would be the address of the start of the line, 16 bytes of data, then 16 ascii equivalents
; this is used in 'printpage' to print out the entire contents of the 256 byte page (along with some from previous and next pages)
printline
	PHY
	PHX
	PHA
	AND #%11110000				; divide the value by 16 essentially, because the lowest nibble should always start with zero 
	STA sub_read2+1				; notice sub_read2 here, because sub_read will be used later for 'printchar'
	STX sub_read2+2				; these sub_read and sub_read2 are used to retain locations of where you are memory, at the same
	LDX #$01				; time as actually reading or writing data in memory
	PHX
	LDX sub_read2+2				; here it is printing the 4 nibbles in the starting address line
	LDA printchar_key_high,X
	PLX
	JSR printchar
	PHX
	LDX sub_read2+2
	LDA printchar_key_low,X
	PLX
	JSR printchar
	PHX
	LDX sub_read2+1
	LDA printchar_key_high,X
	PLX
	JSR printchar
	LDA #ascii_0
	JSR printchar
	LDA #ascii_colon			; you can type 'colon' any time here in this code, but DO NOT TYPE THE COLON SYMBOL!!!
	JSR printchar
	LDA #ascii_space
	JSR printchar
printline_loop					; this loop is for the 16 bytes in memory
	LDA sub_read2+2
	CMP display_high
	BNE printline_byte
	LDA sub_read2+1
	CMP display_low
	BNE printline_byte
	DEX
	LDA #ascii_parenthesis_left		; the cursor is indicated with a parenthesis
	JSR printchar
printline_byte
	JSR sub_read2
	CMP display_highlight			; what's going on here is we are wanting to invert the byte color from the FIND command
	BNE printline_continue1
	PHX
	TAX
	LDA printchar_key_high,X
	PLX
	ORA #%10000000 ; invert
	JSR printchar
	JMP printline_continue2
printline_continue1
	PHX
	TAX
	LDA printchar_key_high,X
	PLX
	JSR printchar
printline_continue2
	JSR sub_read2
	CMP display_highlight			; and do it again for the second nibble
	BNE printline_continue3
	PHX
	TAX
	LDA printchar_key_low,X
	PLX
	ORA #%10000000 ; invert
	JSR printchar
	LDA #ascii_space			; to make it easier to see, the next space is also inverted to white
	ORA #%10000000 ; invert
	JSR printchar
	JMP printline_continue4
printline_continue3
	PHX
	TAX
	LDA printchar_key_low,X
	PLX
	JSR printchar
	LDA #ascii_space			; or it's just a regular space
	JSR printchar
printline_continue4
	LDA sub_read2+2
	CMP display_high
	BNE printline_last
	LDA sub_read2+1
	CMP display_low
	BNE printline_last
	DEX
	JSR sub_read2
	CMP display_highlight			; but now we need the right parenthesis if it is selected, and it ALSO needs to be inverted when applicable
	BNE printline_continue5
	LDA #ascii_parenthesis_right
	ORA #%10000000
	JSR printchar
	JMP printline_last
printline_continue5
	LDA #ascii_parenthesis_right
	JSR printchar
printline_last					; this is detecting if we are at the end of the 16 byte memory dump, that's all
	INC sub_read2+1
	LDA sub_read2+1
	AND #%00001111
	BEQ printline_chars
	JMP printline_loop
printline_chars
	PLA
	PLX
	PHX
	PHA
	AND #%11110000				; start all over again, now to print the ascii equivalent on the far right side
	STA sub_read2+1
	STX sub_read2+2
	LDX #$3A
	LDA #ascii_percent			; the percent symbol is used to delimit the ascii characters (so you know exactly what is what)
	JSR printchar
printline_next
	JSR sub_read2
	JSR printchar
	INC sub_read2+1
	LDA sub_read2+1
	AND #%00001111				; and again check the same way if we printed 16 characters or not
	BEQ printline_exit
	JMP printline_next
printline_exit
	LDA #ascii_percent			; the and stop the area with another percent sign
	JSR printchar
	PLA
	PLX
	PLY					; increment the row being printed on, so that is why you have 4x INY
	INY
	INY
	INY
	INY
	RTS

; printpage sub-routine
; this prints the entire memory dump page.
; it basically will use the 'printline' function a lot, and then exit
printpage
	PHA
	PHX
	PHY
	LDY #>screen				; start at the top of the screen
	LDX display_high
	DEX
	LDA #$C0				; this is the smallest value of the previous page that will be displayed, 4 lines basically
printpage_loop1
	JSR printline
	CLC
	ADC #$10				; prints 16 memory bytes to the screen, so when starting at $C0 and adding $10 each time, you will hit $00 eventually
	BNE printpage_loop1
	INY
	INY
	INY
	INY
	INX
	LDA #$00				; now for the current page, start at lower address byte $00
printpage_loop2
	JSR printline
	CLC
	ADC #$10				; again 16 memory bytes per row, eventually you will hit $00 again
	BNE printpage_loop2
	INY
	INY
	INY
	INY
	INX
	LDA #$00				; start the next page at $00 of course, but we will have to stop early
printpage_loop3
	JSR printline
	CLC
	ADC #$10
	CMP #$40				; stop early at $40, that is 4 lines
	BNE printpage_loop3
	PLY
	PLX
	PLA
	RTS


; disassembler sub-routine
; prints the 'assembly' language from the code location and onwards
; the basic idea here is that you manually compare values and print out the 3 letter mnemonic instruction
; then you check which addressing mode it is, from either #, (, A, or a lack thereof
; finally you print the address, the byte values associated with the code, and then the actual assembly code itself
disassembler
	PHA
	PHX
	PHY
	STZ disassembler_pos			; initialize stuff
	STZ disassembler_code			; the disassembler_code and so on are actually really important for later
	STZ disassembler_code_low		; it is possible to simply RUN the code with it's low and high bytes, kind of like a BASIC command without a number in the front
	STZ disassembler_code_high		; this does not do that, but is possible to do so if you really want to, later?
	LDA #>screen
	STA disassembler_height
	LDA disassembler_low
	STA sub_read2+1				; this also uses sub_read2 as a sequencer
	LDA disassembler_high
	STA sub_read2+2
disassembler_loop				; the start of the loop, it will come back here for each line of code, so 26 total
	STZ disassembler_select
	LDX #$00
	LDY disassembler_height
	LDA #ascii_space			; shift it one from the side, so that cursor has room
	JSR printchar
	LDA command_mode
	BEQ disassembler_print
	LDA sub_read2+2
	CMP assembler_cursor_high
	BNE disassembler_print
	LDA sub_read2+1
	CMP assembler_cursor_low
	BNE disassembler_print
	DEX
	LDA #ascii_bracket_left			; see how DEX was used right before, so it backed up one, and printed on top of that previous space character
	JSR printchar
	INC disassembler_select
disassembler_print
	LDA sub_read2+2				; now print out the 4 nibbles in the address
	PHX
	TAX
	LDA printchar_key_high,X
	PLX
	JSR printchar
	LDA sub_read2+2
	PHX
	TAX
	LDA printchar_key_low,X
	PLX
	JSR printchar
	LDA sub_read2+1
	PHX
	TAX
	LDA printchar_key_high,X
	PLX
	JSR printchar
	LDA sub_read2+1
	PHX
	TAX
	LDA printchar_key_low,X
	PLX
	JSR printchar
	LDA #ascii_colon			; then type the colon character, will be replaced with brackets if it is the cursor location
	JSR printchar
	LDA sub_read2+2
	CMP assembler_cursor_high
	BNE disassembler_continue
	LDA sub_read2+1
	CMP assembler_cursor_low
	BNE disassembler_continue
	DEX
	LDA #ascii_bracket_right		; and again, DEX before so it prints on top of the colon character
	JSR printchar
disassembler_continue
	LDA #ascii_space
	JSR printchar
	JSR sub_read2				; now we actually read from sub_read2 finally.  We then start the long process of comparing it to each byte value possible
	STA disassembler_code			; we also know that it is the real code we will use later when printing byte values
	CMP #$00 ; BRKs				; notice, each single possiblity is checked here, one by one.  The zero page commands are missing, but you will see that anyways
	BNE disassembler_01			; I used to print these letters immediately, but now I store them for later, so that I can print the byte values first
	LDA #ascii_B				; I will not comment on each of these along the way, only special ones			
	STA disassembler_letter1
	LDA #ascii_R
	STA disassembler_letter2
	LDA #ascii_K
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_01					; our first zero-page instruction is missing!  Because it will never be CMP'd, it will end up as 'incomplete' at the bottom.
disassembler_02
	CMP #$02 ; illegal			; our first illegal instruction, I actually denoted each of these just in case
	BNE disassembler_03			; my board does not have hardware to use the illegal instructions, so mainly here just ignore that stuff
	JMP disassembler_illegal
disassembler_03
	CMP #$03 ; illegal
	BNE disassembler_04
	JMP disassembler_illegal
disassembler_04
disassembler_05
disassembler_06
disassembler_07
disassembler_08
	CMP #$08 ; PHPs				; this same pattern for regular instructions will be repeated again and again, and again!
	BNE disassembler_09
	LDA #ascii_P
	STA disassembler_letter1
	LDA #ascii_H
	STA disassembler_letter2
	LDA #ascii_P
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_09
	CMP #$09 ; ORA#
	BNE disassembler_0A
	LDA #ascii_O
	STA disassembler_letter1
	LDA #ascii_R
	STA disassembler_letter2
	LDA #ascii_A
	STA disassembler_letter3
	JMP disassembler_addr_immediate
disassembler_0A
	CMP #$0A ; ASLA
	BNE disassembler_0B
	LDA #ascii_A
	STA disassembler_letter1
	LDA #ascii_S
	STA disassembler_letter2
	LDA #ascii_L
	STA disassembler_letter3
	JMP disassembler_addr_accumulator
disassembler_0B
	CMP #$0B ; illegal
	BNE disassembler_0C
	JMP disassembler_illegal
disassembler_0C
	CMP #$0C ; TSBa
	BNE disassembler_0D
	LDA #ascii_T
	STA disassembler_letter1
	LDA #ascii_S
	STA disassembler_letter2
	LDA #ascii_B
	STA disassembler_letter3
	JMP disassembler_addr_absolute
disassembler_0D
	CMP #$0D ; ORAa
	BNE disassembler_0E
	LDA #ascii_O
	STA disassembler_letter1
	LDA #ascii_R
	STA disassembler_letter2
	LDA #ascii_A
	STA disassembler_letter3
	JMP disassembler_addr_absolute
disassembler_0E
	CMP #$0E ; ASLa
	BNE disassembler_0F
	LDA #ascii_A
	STA disassembler_letter1
	LDA #ascii_S
	STA disassembler_letter2
	LDA #ascii_L
	STA disassembler_letter3
	JMP disassembler_addr_absolute
disassembler_0F
disassembler_10
	CMP #$10 ; BPLr
	BNE disassembler_11
	LDA #ascii_B
	STA disassembler_letter1
	LDA #ascii_P
	STA disassembler_letter2
	LDA #ascii_L
	STA disassembler_letter3
	JMP disassembler_addr_relative
disassembler_11
disassembler_12
disassembler_13
	CMP #$13 ; illegal
	BNE disassembler_14
	JMP disassembler_illegal
disassembler_14
disassembler_15
disassembler_16
disassembler_17
disassembler_18
	CMP #$18 ; CLCi
	BNE disassembler_19
	LDA #ascii_C
	STA disassembler_letter1
	LDA #ascii_L
	STA disassembler_letter2
	LDA #ascii_C
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_19
	CMP #$19 ; ORAay
	BNE disassembler_1A
	LDA #ascii_O
	STA disassembler_letter1
	LDA #ascii_R
	STA disassembler_letter2
	LDA #ascii_A
	STA disassembler_letter3
	JMP disassembler_addr_absolute_y
disassembler_1A
	CMP #$1A ; INCA
	BNE disassembler_1B
	LDA #ascii_I
	STA disassembler_letter1
	LDA #ascii_N
	STA disassembler_letter2
	LDA #ascii_C
	STA disassembler_letter3
	JMP disassembler_addr_accumulator
disassembler_1B
	CMP #$1B ; illegal
	BNE disassembler_1C
	JMP disassembler_illegal
disassembler_1C
	CMP #$0C ; TRBa
	BNE disassembler_1D
	LDA #ascii_T
	STA disassembler_letter1
	LDA #ascii_R
	STA disassembler_letter2
	LDA #ascii_B
	STA disassembler_letter3
	JMP disassembler_addr_absolute
disassembler_1D
	CMP #$1D ; ORAax
	BNE disassembler_1E
	LDA #ascii_O
	STA disassembler_letter1
	LDA #ascii_R
	STA disassembler_letter2
	LDA #ascii_A
	STA disassembler_letter3
	JMP disassembler_addr_absolute_x
disassembler_1E
	CMP #$1E ; ASLax
	BNE disassembler_1F
	LDA #ascii_A
	STA disassembler_letter1
	LDA #ascii_S
	STA disassembler_letter2
	LDA #ascii_L
	STA disassembler_letter3
	JMP disassembler_addr_absolute_x
disassembler_1F
disassembler_20
	CMP #$20 ; JSRa
	BNE disassembler_21
	LDA #ascii_J
	STA disassembler_letter1
	LDA #ascii_S
	STA disassembler_letter2
	LDA #ascii_R
	STA disassembler_letter3
	JMP disassembler_addr_absolute
disassembler_21
disassembler_22
	CMP #$22 ; illegal
	BNE disassembler_23
	JMP disassembler_illegal
disassembler_23
	CMP #$23 ; illegal
	BNE disassembler_24
	JMP disassembler_illegal
disassembler_24
disassembler_25
disassembler_26
disassembler_27
disassembler_28
	CMP #$28 ; PLPs
	BNE disassembler_29
	LDA #ascii_P
	STA disassembler_letter1
	LDA #ascii_L
	STA disassembler_letter2
	LDA #ascii_P
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_29
	CMP #$29 ; AND#
	BNE disassembler_2A
	LDA #ascii_A
	STA disassembler_letter1
	LDA #ascii_N
	STA disassembler_letter2
	LDA #ascii_D
	STA disassembler_letter3
	JMP disassembler_addr_immediate
disassembler_2A
	CMP #$2A ; ROLA
	BNE disassembler_2B
	LDA #ascii_R
	STA disassembler_letter1
	LDA #ascii_O
	STA disassembler_letter2
	LDA #ascii_L
	STA disassembler_letter3
	JMP disassembler_addr_accumulator
disassembler_2B
	CMP #$2B ; illegal
	BNE disassembler_2C
	JMP disassembler_illegal
disassembler_2C
	CMP #$2C ; BITa
	BNE disassembler_2D
	LDA #ascii_B
	STA disassembler_letter1
	LDA #ascii_I
	STA disassembler_letter2
	LDA #ascii_T
	STA disassembler_letter3
	JMP disassembler_addr_absolute
disassembler_2D
	CMP #$2D ; ANDa
	BNE disassembler_2E
	LDA #ascii_A
	STA disassembler_letter1
	LDA #ascii_N
	STA disassembler_letter2
	LDA #ascii_D
	STA disassembler_letter3
	JMP disassembler_addr_absolute
disassembler_2E
	CMP #$2E ; ROLa
	BNE disassembler_2F
	LDA #ascii_R
	STA disassembler_letter1
	LDA #ascii_O
	STA disassembler_letter2
	LDA #ascii_L
	STA disassembler_letter3
	JMP disassembler_addr_absolute
disassembler_2F
disassembler_30
	CMP #$30 ; BMIr
	BNE disassembler_31
	LDA #ascii_B
	STA disassembler_letter1
	LDA #ascii_M
	STA disassembler_letter2
	LDA #ascii_I
	STA disassembler_letter3
	JMP disassembler_addr_relative
disassembler_31
disassembler_32
disassembler_33
	CMP #$33 ; illegal
	BNE disassembler_34
	JMP disassembler_illegal
disassembler_34
disassembler_35
disassembler_36
disassembler_37
disassembler_38
	CMP #$38 ; SECi
	BNE disassembler_39
	LDA #ascii_S
	STA disassembler_letter1
	LDA #ascii_E
	STA disassembler_letter2
	LDA #ascii_C
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_39
	CMP #$39 ; ANDay
	BNE disassembler_3A
	LDA #ascii_A
	STA disassembler_letter1
	LDA #ascii_N
	STA disassembler_letter2
	LDA #ascii_D
	STA disassembler_letter3
	JMP disassembler_addr_absolute_y
disassembler_3A
	CMP #$3A ; DECA
	BNE disassembler_3B
	LDA #ascii_D
	STA disassembler_letter1
	LDA #ascii_E
	STA disassembler_letter2
	LDA #ascii_C
	STA disassembler_letter3
	JMP disassembler_addr_accumulator
disassembler_3B
	CMP #$3B ; illegal
	BNE disassembler_3C
	JMP disassembler_illegal
disassembler_3C
	CMP #$3C ; BITax
	BNE disassembler_3D
	LDA #ascii_B
	STA disassembler_letter1
	LDA #ascii_I
	STA disassembler_letter2
	LDA #ascii_T
	STA disassembler_letter3
	JMP disassembler_addr_absolute_x
disassembler_3D
	CMP #$3D ; ANDax
	BNE disassembler_3E
	LDA #ascii_A
	STA disassembler_letter1
	LDA #ascii_N
	STA disassembler_letter2
	LDA #ascii_D
	STA disassembler_letter3
	JMP disassembler_addr_absolute_x
disassembler_3E
	CMP #$3E ; ROLax
	BNE disassembler_3F
	LDA #ascii_R
	STA disassembler_letter1
	LDA #ascii_O
	STA disassembler_letter2
	LDA #ascii_L
	STA disassembler_letter3
	JMP disassembler_addr_absolute_x
disassembler_3F
disassembler_40
	CMP #$40 ; RTIs
	BNE disassembler_41
	LDA #ascii_R
	STA disassembler_letter1
	LDA #ascii_T
	STA disassembler_letter2
	LDA #ascii_I
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_41
disassembler_42
	CMP #$42 ; illegal
	BNE disassembler_43
	JMP disassembler_illegal
disassembler_43
	CMP #$43 ; illegal
	BNE disassembler_44
	JMP disassembler_illegal
disassembler_44
	CMP #$44 ; illegal
	BNE disassembler_45
	JMP disassembler_illegal
disassembler_45
disassembler_46
disassembler_47
disassembler_48
	CMP #$48 ; PHAs
	BNE disassembler_49
	LDA #ascii_P
	STA disassembler_letter1
	LDA #ascii_H
	STA disassembler_letter2
	LDA #ascii_A
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_49
	CMP #$49 ; EORay
	BNE disassembler_4A
	LDA #ascii_E
	STA disassembler_letter1
	LDA #ascii_O
	STA disassembler_letter2
	LDA #ascii_R
	STA disassembler_letter3
	JMP disassembler_addr_absolute_y
disassembler_4A
	CMP #$4A ; LSRA
	BNE disassembler_4B
	LDA #ascii_L
	STA disassembler_letter1
	LDA #ascii_S
	STA disassembler_letter2
	LDA #ascii_R
	STA disassembler_letter3
	JMP disassembler_addr_accumulator
disassembler_4B
	CMP #$4B ; illegal
	BNE disassembler_4C
	JMP disassembler_illegal
disassembler_4C
	CMP #$4C ; JMPa
	BNE disassembler_4D
	LDA #ascii_J
	STA disassembler_letter1
	LDA #ascii_M
	STA disassembler_letter2
	LDA #ascii_P
	STA disassembler_letter3
	JMP disassembler_addr_absolute
disassembler_4D
	CMP #$4D ; EORa
	BNE disassembler_4E
	LDA #ascii_E
	STA disassembler_letter1
	LDA #ascii_O
	STA disassembler_letter2
	LDA #ascii_R
	STA disassembler_letter3
	JMP disassembler_addr_absolute
disassembler_4E
	CMP #$4E ; LSRa
	BNE disassembler_4F
	LDA #ascii_L
	STA disassembler_letter1
	LDA #ascii_S
	STA disassembler_letter2
	LDA #ascii_R
	STA disassembler_letter3
	JMP disassembler_addr_absolute
disassembler_4F
disassembler_50
	CMP #$50 ; BVCr
	BNE disassembler_51
	LDA #ascii_B
	STA disassembler_letter1
	LDA #ascii_V
	STA disassembler_letter2
	LDA #ascii_C
	STA disassembler_letter3
	JMP disassembler_addr_relative
disassembler_51
disassembler_52
disassembler_53
	CMP #$53 ; illegal
	BNE disassembler_54
	JMP disassembler_illegal
disassembler_54
	CMP #$54 ; illegal
	BNE disassembler_55
	JMP disassembler_illegal
disassembler_55
disassembler_56
disassembler_57
disassembler_58
	CMP #$58 ; CLIi
	BNE disassembler_59
	LDA #ascii_C
	STA disassembler_letter1
	LDA #ascii_L
	STA disassembler_letter2
	LDA #ascii_I
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_59
	CMP #$59 ; EORay
	BNE disassembler_5A
	LDA #ascii_E
	STA disassembler_letter1
	LDA #ascii_O
	STA disassembler_letter2
	LDA #ascii_R
	STA disassembler_letter3
	JMP disassembler_addr_absolute_y
disassembler_5A
	CMP #$5A ; PHYs
	BNE disassembler_5B
	LDA #ascii_P
	STA disassembler_letter1
	LDA #ascii_H
	STA disassembler_letter2
	LDA #ascii_Y
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_5B
	CMP #$5B ; illegal
	BNE disassembler_5C
	JMP disassembler_illegal
disassembler_5C
	CMP #$5C ; illegal
	BNE disassembler_5D
	JMP disassembler_illegal
disassembler_5D
	CMP #$5D ; EORax
	BNE disassembler_5E
	LDA #ascii_E
	STA disassembler_letter1
	LDA #ascii_O
	STA disassembler_letter2
	LDA #ascii_R
	STA disassembler_letter3
	JMP disassembler_addr_absolute_x
disassembler_5E
	CMP #$5E ; LSRax
	BNE disassembler_5F
	LDA #ascii_L
	STA disassembler_letter1
	LDA #ascii_S
	STA disassembler_letter2
	LDA #ascii_R
	STA disassembler_letter3
	JMP disassembler_addr_absolute_x
disassembler_5F
disassembler_60
	CMP #$60 ; RTSs
	BNE disassembler_61
	LDA #ascii_R
	STA disassembler_letter1
	LDA #ascii_T
	STA disassembler_letter2
	LDA #ascii_S
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_61
disassembler_62
	CMP #$62 ; illegal
	BNE disassembler_63
	JMP disassembler_illegal
disassembler_63
	CMP #$63 ; illegal
	BNE disassembler_64
	JMP disassembler_illegal
disassembler_64
disassembler_65
disassembler_66
disassembler_67
disassembler_68
	CMP #$68 ; PLAs
	BNE disassembler_69
	LDA #ascii_P
	STA disassembler_letter1
	LDA #ascii_L
	STA disassembler_letter2
	LDA #ascii_A
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_69
	CMP #$69 ; ADC#
	BNE disassembler_6A
	LDA #ascii_A
	STA disassembler_letter1
	LDA #ascii_D
	STA disassembler_letter2
	LDA #ascii_C
	STA disassembler_letter3
	JMP disassembler_addr_immediate
disassembler_6A
	CMP #$6A ; RORA
	BNE disassembler_6B
	LDA #ascii_R
	STA disassembler_letter1
	LDA #ascii_O
	STA disassembler_letter2
	LDA #ascii_R
	STA disassembler_letter3
	JMP disassembler_addr_accumulator
disassembler_6B
	CMP #$6B ; illegal
	BNE disassembler_6C
	JMP disassembler_illegal
disassembler_6C
	CMP #$6C ; JMP(a)
	BNE disassembler_6D
	LDA #ascii_J
	STA disassembler_letter1
	LDA #ascii_M
	STA disassembler_letter2
	LDA #ascii_P
	STA disassembler_letter3
	JMP disassembler_addr_absolute_indirect
disassembler_6D
	CMP #$6D ; ADCa
	BNE disassembler_6E
	LDA #ascii_A
	STA disassembler_letter1
	LDA #ascii_D
	STA disassembler_letter2
	LDA #ascii_C
	STA disassembler_letter3
	JMP disassembler_addr_absolute
disassembler_6E
	CMP #$6E ; RORa
	BNE disassembler_6F
	LDA #ascii_R
	STA disassembler_letter1
	LDA #ascii_O
	STA disassembler_letter2
	LDA #ascii_R
	STA disassembler_letter3
	JMP disassembler_addr_absolute
disassembler_6F
disassembler_70
	CMP #$70 ; BVSr
	BNE disassembler_71
	LDA #ascii_B
	STA disassembler_letter1
	LDA #ascii_V
	STA disassembler_letter2
	LDA #ascii_S
	STA disassembler_letter3
	JMP disassembler_addr_relative
disassembler_71
disassembler_72
disassembler_73
	CMP #$73 ; illegal
	BNE disassembler_74
	JMP disassembler_illegal
disassembler_74
disassembler_75
disassembler_76
disassembler_77
disassembler_78
	CMP #$78 ; SEIi
	BNE disassembler_79
	LDA #ascii_S
	STA disassembler_letter1
	LDA #ascii_E
	STA disassembler_letter2
	LDA #ascii_I
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_79
	CMP #$79 ; ADCay
	BNE disassembler_7A
	LDA #ascii_A
	STA disassembler_letter1
	LDA #ascii_D
	STA disassembler_letter2
	LDA #ascii_C
	STA disassembler_letter3
	JMP disassembler_addr_absolute_y
disassembler_7A
	CMP #$7A ; PLYs
	BNE disassembler_7B
	LDA #ascii_P
	STA disassembler_letter1
	LDA #ascii_L
	STA disassembler_letter2
	LDA #ascii_Y
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_7B
	CMP #$7B ; illegal
	BNE disassembler_7C
	JMP disassembler_illegal
disassembler_7C					; this is where JMP(ax) would go, but... I didn't include it because I didn't care
	; this is where JMP(ax) would go
disassembler_7D
	CMP #$7D ; ADCax
	BNE disassembler_7E
	LDA #ascii_A
	STA disassembler_letter1
	LDA #ascii_D
	STA disassembler_letter2
	LDA #ascii_C
	STA disassembler_letter3
	JMP disassembler_addr_absolute_x
disassembler_7E
	CMP #$7E ; RORax
	BNE disassembler_7F
	LDA #ascii_R
	STA disassembler_letter1
	LDA #ascii_O
	STA disassembler_letter2
	LDA #ascii_R
	STA disassembler_letter3
	JMP disassembler_addr_absolute_x
disassembler_7F
disassembler_80					; halfway there!
	CMP #$80 ; BRAr
	BNE disassembler_81
	LDA #ascii_B
	STA disassembler_letter1
	LDA #ascii_R
	STA disassembler_letter2
	LDA #ascii_A
	STA disassembler_letter3
	JMP disassembler_addr_relative
disassembler_81
disassembler_82
	CMP #$82 ; illegal
	BNE disassembler_83
	JMP disassembler_illegal
disassembler_83
	CMP #$83 ; illegal
	BNE disassembler_84
	JMP disassembler_illegal
disassembler_84
disassembler_85
disassembler_86
disassembler_87
disassembler_88
	CMP #$88 ; DEYi
	BNE disassembler_89
	LDA #ascii_D
	STA disassembler_letter1
	LDA #ascii_E
	STA disassembler_letter2
	LDA #ascii_Y
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_89
	CMP #$89 ; BIT#
	BNE disassembler_8A
	LDA #ascii_B
	STA disassembler_letter1
	LDA #ascii_I
	STA disassembler_letter2
	LDA #ascii_T
	STA disassembler_letter3
	JMP disassembler_addr_immediate
disassembler_8A
	CMP #$8A ; TXAi
	BNE disassembler_8B
	LDA #ascii_T
	STA disassembler_letter1
	LDA #ascii_X
	STA disassembler_letter2
	LDA #ascii_A
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_8B
	CMP #$8B ; illegal
	BNE disassembler_8C
	JMP disassembler_illegal
disassembler_8C
	CMP #$8C ; STYa
	BNE disassembler_8D
	LDA #ascii_S
	STA disassembler_letter1
	LDA #ascii_T
	STA disassembler_letter2
	LDA #ascii_Y
	STA disassembler_letter3
	JMP disassembler_addr_absolute
disassembler_8D
	CMP #$8D ; STAa
	BNE disassembler_8E
	LDA #ascii_S
	STA disassembler_letter1
	LDA #ascii_T
	STA disassembler_letter2
	LDA #ascii_A
	STA disassembler_letter3
	JMP disassembler_addr_absolute
disassembler_8E
	CMP #$8E ; STXa
	BNE disassembler_8F
	LDA #ascii_S
	STA disassembler_letter1
	LDA #ascii_T
	STA disassembler_letter2
	LDA #ascii_X
	STA disassembler_letter3
	JMP disassembler_addr_absolute
disassembler_8F
disassembler_90
	CMP #$90 ; BCCr
	BNE disassembler_91
	LDA #ascii_B
	STA disassembler_letter1
	LDA #ascii_C
	STA disassembler_letter2
	LDA #ascii_C
	STA disassembler_letter3
	JMP disassembler_addr_relative
disassembler_91
disassembler_92
disassembler_93
	CMP #$93 ; illegal
	BNE disassembler_94
	JMP disassembler_illegal
disassembler_94
disassembler_95
disassembler_96
disassembler_97
disassembler_98
	CMP #$98 ; TYAi
	BNE disassembler_99
	LDA #ascii_T
	STA disassembler_letter1
	LDA #ascii_Y
	STA disassembler_letter2
	LDA #ascii_A
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_99
	CMP #$99 ; STAay
	BNE disassembler_9A
	LDA #ascii_S
	STA disassembler_letter1
	LDA #ascii_T
	STA disassembler_letter2
	LDA #ascii_A
	STA disassembler_letter3
	JMP disassembler_addr_absolute_y
disassembler_9A
	CMP #$9A ; TXSi
	BNE disassembler_9B
	LDA #ascii_T
	STA disassembler_letter1
	LDA #ascii_X
	STA disassembler_letter2
	LDA #ascii_S
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_9B
	CMP #$9B ; illegal
	BNE disassembler_9C
	JMP disassembler_illegal
disassembler_9C
	CMP #$9C ; STZa
	BNE disassembler_9D
	LDA #ascii_S
	STA disassembler_letter1
	LDA #ascii_T
	STA disassembler_letter2
	LDA #ascii_Z
	STA disassembler_letter3
	JMP disassembler_addr_absolute
disassembler_9D
	CMP #$9D ; STAax
	BNE disassembler_9E
	LDA #ascii_S
	STA disassembler_letter1
	LDA #ascii_T
	STA disassembler_letter2
	LDA #ascii_A
	STA disassembler_letter3
	JMP disassembler_addr_absolute_x
disassembler_9E
	CMP #$9E ; STZax
	BNE disassembler_9F
	LDA #ascii_S
	STA disassembler_letter1
	LDA #ascii_T
	STA disassembler_letter2
	LDA #ascii_Z
	STA disassembler_letter3
	JMP disassembler_addr_absolute_x
disassembler_9F
disassembler_A0
	CMP #$A0 ; LDY#
	BNE disassembler_A1
	LDA #ascii_L
	STA disassembler_letter1
	LDA #ascii_D
	STA disassembler_letter2
	LDA #ascii_Y
	STA disassembler_letter3
	JMP disassembler_addr_immediate
disassembler_A1
disassembler_A2
	CMP #$A2 ; LDX#
	BNE disassembler_A3
	LDA #ascii_L
	STA disassembler_letter1
	LDA #ascii_D
	STA disassembler_letter2
	LDA #ascii_X
	STA disassembler_letter3
	JMP disassembler_addr_immediate
disassembler_A3
	CMP #$A3 ; illegal
	BNE disassembler_A4
	JMP disassembler_illegal
disassembler_A4
disassembler_A5
disassembler_A6
disassembler_A7
disassembler_A8
	CMP #$A8 ; TAYi
	BNE disassembler_A9
	LDA #ascii_T
	STA disassembler_letter1
	LDA #ascii_A
	STA disassembler_letter2
	LDA #ascii_Y
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_A9
	CMP #$A9 ; LDA#
	BNE disassembler_AA
	LDA #ascii_L
	STA disassembler_letter1
	LDA #ascii_D
	STA disassembler_letter2
	LDA #ascii_A
	STA disassembler_letter3
	JMP disassembler_addr_immediate
disassembler_AA
	CMP #$AA ; TAXi
	BNE disassembler_AB
	LDA #ascii_T
	STA disassembler_letter1
	LDA #ascii_A
	STA disassembler_letter2
	LDA #ascii_X
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_AB
	CMP #$AB ; illegal
	BNE disassembler_AC
	JMP disassembler_illegal
disassembler_AC
	CMP #$AC ; LDYa
	BNE disassembler_AD
	LDA #ascii_L
	STA disassembler_letter1
	LDA #ascii_D
	STA disassembler_letter2
	LDA #ascii_Y
	STA disassembler_letter3
	JMP disassembler_addr_absolute
disassembler_AD
	CMP #$AD ; LDAa
	BNE disassembler_AE
	LDA #ascii_L
	STA disassembler_letter1
	LDA #ascii_D
	STA disassembler_letter2
	LDA #ascii_A
	STA disassembler_letter3
	JMP disassembler_addr_absolute
disassembler_AE
	CMP #$AE ; LDXa
	BNE disassembler_AF
	LDA #ascii_L
	STA disassembler_letter1
	LDA #ascii_D
	STA disassembler_letter2
	LDA #ascii_X
	STA disassembler_letter3
	JMP disassembler_addr_absolute
disassembler_AF
disassembler_B0
	CMP #$B0 ; BCSr
	BNE disassembler_B1
	LDA #ascii_B
	STA disassembler_letter1
	LDA #ascii_C
	STA disassembler_letter2
	LDA #ascii_S
	STA disassembler_letter3
	JMP disassembler_addr_relative
disassembler_B1
disassembler_B2
disassembler_B3
	CMP #$B3 ; illegal
	BNE disassembler_B4
	JMP disassembler_illegal
disassembler_B4
disassembler_B5
disassembler_B6
disassembler_B7
disassembler_B8
	CMP #$B8 ; CLVi
	BNE disassembler_B9
	LDA #ascii_C
	STA disassembler_letter1
	LDA #ascii_L
	STA disassembler_letter2
	LDA #ascii_V
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_B9
	CMP #$B9 ; LDAay
	BNE disassembler_BA
	LDA #ascii_L
	STA disassembler_letter1
	LDA #ascii_D
	STA disassembler_letter2
	LDA #ascii_A
	STA disassembler_letter3
	JMP disassembler_addr_absolute_y
disassembler_BA
	CMP #$BA ; TSXi
	BNE disassembler_BB
	LDA #ascii_T
	STA disassembler_letter1
	LDA #ascii_S
	STA disassembler_letter2
	LDA #ascii_X
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_BB
	CMP #$BB ; illegal
	BNE disassembler_BC
	JMP disassembler_illegal
disassembler_BC
	CMP #$BC ; LDYax
	BNE disassembler_BD
	LDA #ascii_L
	STA disassembler_letter1
	LDA #ascii_D
	STA disassembler_letter2
	LDA #ascii_Y
	STA disassembler_letter3
	JMP disassembler_addr_absolute_x
disassembler_BD
	CMP #$BD ; LDAax
	BNE disassembler_BE
	LDA #ascii_L
	STA disassembler_letter1
	LDA #ascii_D
	STA disassembler_letter2
	LDA #ascii_A
	STA disassembler_letter3
	JMP disassembler_addr_absolute_x
disassembler_BE
	CMP #$BE ; LDXay
	BNE disassembler_BF
	LDA #ascii_L
	STA disassembler_letter1
	LDA #ascii_D
	STA disassembler_letter2
	LDA #ascii_X
	STA disassembler_letter3
	JMP disassembler_addr_absolute_y
disassembler_BF
disassembler_C0
	CMP #$C0 ; CPY#
	BNE disassembler_C1
	LDA #ascii_C
	STA disassembler_letter1
	LDA #ascii_P
	STA disassembler_letter2
	LDA #ascii_Y
	STA disassembler_letter3
	JMP disassembler_addr_immediate
disassembler_C1
disassembler_C2
	CMP #$C2 ; illegal
	BNE disassembler_C3
	JMP disassembler_illegal
disassembler_C3
	CMP #$C3 ; illegal
	BNE disassembler_C4
	JMP disassembler_illegal
disassembler_C4
disassembler_C5
disassembler_C6
disassembler_C7
disassembler_C8
	CMP #$C8 ; INYi
	BNE disassembler_C9
	LDA #ascii_I
	STA disassembler_letter1
	LDA #ascii_N
	STA disassembler_letter2
	LDA #ascii_Y
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_C9
	CMP #$C9 ; CMP#
	BNE disassembler_CA
	LDA #ascii_C
	STA disassembler_letter1
	LDA #ascii_M
	STA disassembler_letter2
	LDA #ascii_P
	STA disassembler_letter3
	JMP disassembler_addr_immediate
disassembler_CA
	CMP #$CA ; DEXi
	BNE disassembler_CB
	LDA #ascii_D
	STA disassembler_letter1
	LDA #ascii_E
	STA disassembler_letter2
	LDA #ascii_X
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_CB
	CMP #$CB ; WAIi
	BNE disassembler_CC
	LDA #ascii_W
	STA disassembler_letter1
	LDA #ascii_A
	STA disassembler_letter2
	LDA #ascii_I
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_CC
	CMP #$CC ; CPYa
	BNE disassembler_CD
	LDA #ascii_C
	STA disassembler_letter1
	LDA #ascii_P
	STA disassembler_letter2
	LDA #ascii_Y
	STA disassembler_letter3
	JMP disassembler_addr_absolute
disassembler_CD
	CMP #$CD ; CMPa
	BNE disassembler_CE
	LDA #ascii_C
	STA disassembler_letter1
	LDA #ascii_M
	STA disassembler_letter2
	LDA #ascii_P
	STA disassembler_letter3
	JMP disassembler_addr_absolute
disassembler_CE
	CMP #$CE ; DECa
	BNE disassembler_CF
	LDA #ascii_D
	STA disassembler_letter1
	LDA #ascii_E
	STA disassembler_letter2
	LDA #ascii_C
	STA disassembler_letter3
	JMP disassembler_addr_absolute
disassembler_CF
disassembler_D0
	CMP #$D0 ; BNEr
	BNE disassembler_D1
	LDA #ascii_B
	STA disassembler_letter1
	LDA #ascii_N
	STA disassembler_letter2
	LDA #ascii_E
	STA disassembler_letter3
	JMP disassembler_addr_relative
disassembler_D1
disassembler_D2
disassembler_D3
	CMP #$D3 ; illegal
	BNE disassembler_D4
	JMP disassembler_illegal
disassembler_D4
	CMP #$D4 ; illegal
	BNE disassembler_D5
	JMP disassembler_illegal
disassembler_D5
disassembler_D6
disassembler_D7
disassembler_D8
	CMP #$D8 ; CLDi
	BNE disassembler_D9
	LDA #ascii_C
	STA disassembler_letter1
	LDA #ascii_L
	STA disassembler_letter2
	LDA #ascii_D
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_D9
	CMP #$D9 ; CMPay
	BNE disassembler_DA
	LDA #ascii_C
	STA disassembler_letter1
	LDA #ascii_M
	STA disassembler_letter2
	LDA #ascii_P
	STA disassembler_letter3
	JMP disassembler_addr_absolute_y
disassembler_DA
	CMP #$DA ; PHXs
	BNE disassembler_DB
	LDA #ascii_P
	STA disassembler_letter1
	LDA #ascii_H
	STA disassembler_letter2
	LDA #ascii_X
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_DB
	CMP #$DB ; STPi
	BNE disassembler_DC
	LDA #ascii_S
	STA disassembler_letter1
	LDA #ascii_T
	STA disassembler_letter2
	LDA #ascii_P
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_DC
	CMP #$DC ; illegal
	BNE disassembler_DD
	JMP disassembler_illegal
disassembler_DD
	CMP #$DD ; CMPax
	BNE disassembler_DE
	LDA #ascii_C
	STA disassembler_letter1
	LDA #ascii_M
	STA disassembler_letter2
	LDA #ascii_P
	STA disassembler_letter3
	JMP disassembler_addr_absolute_x
disassembler_DE
	CMP #$DE ; DECax
	BNE disassembler_DF
	LDA #ascii_D
	STA disassembler_letter1
	LDA #ascii_E
	STA disassembler_letter2
	LDA #ascii_C
	STA disassembler_letter3
	JMP disassembler_addr_absolute_x
disassembler_DF
disassembler_E0
	CMP #$E0 ; CPX#
	BNE disassembler_E1
	LDA #ascii_C
	STA disassembler_letter1
	LDA #ascii_P
	STA disassembler_letter2
	LDA #ascii_X
	STA disassembler_letter3
	JMP disassembler_addr_immediate
disassembler_E1
disassembler_E2
	CMP #$E2 ; illegal
	BNE disassembler_E3
	JMP disassembler_illegal
disassembler_E3
	CMP #$E3 ; illegal
	BNE disassembler_E4
	JMP disassembler_illegal
disassembler_E4
disassembler_E5
disassembler_E6
disassembler_E7
disassembler_E8
	CMP #$E8 ; INXi
	BNE disassembler_E9
	LDA #ascii_I
	STA disassembler_letter1
	LDA #ascii_N
	STA disassembler_letter2
	LDA #ascii_X
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_E9
	CMP #$E9 ; SBC#
	BNE disassembler_EA
	LDA #ascii_S
	STA disassembler_letter1
	LDA #ascii_B
	STA disassembler_letter2
	LDA #ascii_C
	STA disassembler_letter3
	JMP disassembler_addr_immediate
disassembler_EA
	CMP #$EA ; NOPi
	BNE disassembler_EB
	LDA #ascii_N
	STA disassembler_letter1
	LDA #ascii_O
	STA disassembler_letter2
	LDA #ascii_P
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_EB
	CMP #$EB ; illegal
	BNE disassembler_EC
	JMP disassembler_illegal
disassembler_EC
	CMP #$EC ; CPXa
	BNE disassembler_ED
	LDA #ascii_C
	STA disassembler_letter1
	LDA #ascii_P
	STA disassembler_letter2
	LDA #ascii_X
	STA disassembler_letter3
	JMP disassembler_addr_absolute
disassembler_ED
	CMP #$ED ; SBCa
	BNE disassembler_EE
	LDA #ascii_S
	STA disassembler_letter1
	LDA #ascii_B
	STA disassembler_letter2
	LDA #ascii_C
	STA disassembler_letter3
	JMP disassembler_addr_absolute
disassembler_EE
	CMP #$EE ; INCa
	BNE disassembler_EF
	LDA #ascii_I
	STA disassembler_letter1
	LDA #ascii_N
	STA disassembler_letter2
	LDA #ascii_C
	STA disassembler_letter3
	JMP disassembler_addr_absolute
disassembler_EF
disassembler_F0					; so close!
	CMP #$F0 ; BEQr
	BNE disassembler_F1
	LDA #ascii_B
	STA disassembler_letter1
	LDA #ascii_E
	STA disassembler_letter2
	LDA #ascii_Q
	STA disassembler_letter3
	JMP disassembler_addr_relative
disassembler_F1
disassembler_F2
disassembler_F3
	CMP #$F3 ; illegal
	BNE disassembler_F4
	JMP disassembler_illegal
disassembler_F4
	CMP #$F4 ; illegal
	BNE disassembler_F5
	JMP disassembler_illegal
disassembler_F5
disassembler_F6
disassembler_F7
disassembler_F8
	CMP #$F8 ; SEDi
	BNE disassembler_F9
	LDA #ascii_S
	STA disassembler_letter1
	LDA #ascii_E
	STA disassembler_letter2
	LDA #ascii_D
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_F9
	CMP #$F9 ; SBCay
	BNE disassembler_FA
	LDA #ascii_S
	STA disassembler_letter1
	LDA #ascii_B
	STA disassembler_letter2
	LDA #ascii_C
	STA disassembler_letter3
	JMP disassembler_addr_absolute_y
disassembler_FA
	CMP #$FA ; PLXs
	BNE disassembler_FB
	LDA #ascii_P
	STA disassembler_letter1
	LDA #ascii_L
	STA disassembler_letter2
	LDA #ascii_X
	STA disassembler_letter3
	JMP disassembler_addr_none
disassembler_FB
	CMP #$FB ; illegal
	BNE disassembler_FC
	JMP disassembler_illegal
disassembler_FC
	CMP #$FC ; illegal
	BNE disassembler_FD
	JMP disassembler_illegal
disassembler_FD
	CMP #$FD ; SBCax
	BNE disassembler_FE
	LDA #ascii_S
	STA disassembler_letter1
	LDA #ascii_B
	STA disassembler_letter2
	LDA #ascii_C
	STA disassembler_letter3
	JMP disassembler_addr_absolute_x
disassembler_FE
	CMP #$FE ; INCax
	BNE disassembler_FF
	LDA #ascii_I
	STA disassembler_letter1
	LDA #ascii_N
	STA disassembler_letter2
	LDA #ascii_C
	STA disassembler_letter3
	JMP disassembler_addr_absolute_x
disassembler_FF					; apparenty I also didn't include those weird RMB, SMB, BBR, and BBS commands.  Hm! 
disassembler_incomplete				; ok, if it wasn't above, just put ??? down for now.  It's legal, but I just don't know what it could be.
	LDA #ascii_question
	STA disassembler_letter1
	STA disassembler_letter2
	STA disassembler_letter3		; notice the incomplete codes fall directly into the 'none' addressing mode.  This will defintely mess with code further on the stack
disassembler_addr_none				; each one of those above jumped to it's particular addressing mode.  This one includes the implied and stack addressing modes
	LDA disassembler_code			; print the byte code only
	PHX
	TAX
	LDA printchar_key_high,X
	PLX
	JSR printchar
	LDA disassembler_code
	PHX
	TAX
	LDA printchar_key_low,X
	PLX
	JSR printchar
	LDA #ascii_space			; put some spaces on it
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR disassembler_mini_select_left	; see if it's selected, and if so, put some brackets around it
	LDA disassembler_letter1		; print out the 3 letters
	JSR printchar
	LDA disassembler_letter2
	JSR printchar
	LDA disassembler_letter3
	JSR printchar
	LDA #ascii_space			; and nothing else after it!
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR disassembler_mini_select_right	; if selected, end with a bracket
	JMP disassembler_increment		; jump to the increment portion, which will just go back into the loop 26 times.
disassembler_addr_absolute			; absolute addressing mode, $XXXX and whatnot
	JSR disassembler_mini_inc		; this 'mini_inc' is a sub-sub-routine to jump to the next byte in memory
	JSR sub_read2				; and then read it
	STA disassembler_code_low		; and then store it for later
	JSR disassembler_mini_inc
	JSR sub_read2
	STA disassembler_code_high
	LDA disassembler_code			; print the code byte, then the lower byte, then the higher byte
	PHX
	TAX
	LDA printchar_key_high,X
	PLX
	JSR printchar
	LDA disassembler_code
	PHX
	TAX
	LDA printchar_key_low,X
	PLX
	JSR printchar
	LDA #ascii_space
	JSR printchar
	LDA disassembler_code_low
	PHX
	TAX
	LDA printchar_key_high,X
	PLX
	JSR printchar
	LDA disassembler_code_low
	PHX
	TAX
	LDA printchar_key_low,X
	PLX
	JSR printchar
	LDA #ascii_space
	JSR printchar
	LDA disassembler_code_high
	PHX
	TAX
	LDA printchar_key_high,X
	PLX
	JSR printchar
	LDA disassembler_code_high
	PHX
	TAX
	LDA printchar_key_low,X
	PLX
	JSR printchar
	LDA #ascii_space			; print some spaces in there
	JSR printchar
	JSR printchar
	JSR printchar
	JSR disassembler_mini_select_left	; brackets if selected, code letters, etc.
	LDA disassembler_letter1
	JSR printchar
	LDA disassembler_letter2
	JSR printchar
	LDA disassembler_letter3
	JSR printchar
	LDA #ascii_space
	JSR printchar
	LDA #ascii_dollar			; this particular addressing mode wants a $ sign, but you don't have to type that into the assembler
	JSR printchar
	LDA disassembler_code_high
	JSR disassembler_mini_hex		; 'mini_hex' is a sub-sub-routine to just print the hex code in the accumulator. I probably should have used that in other places...
	LDA disassembler_code_low
	JSR disassembler_mini_hex
	LDA #ascii_space
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR disassembler_mini_select_right	; if selected, end with a bracket
	JMP disassembler_increment		; and increment to next row/line of code
disassembler_addr_absolute_x			; absolute,X has a comma then X at the end, other than that it's pretty much the same
	JSR disassembler_mini_inc
	JSR sub_read2
	STA disassembler_code_low
	JSR disassembler_mini_inc
	JSR sub_read2
	STA disassembler_code_high
	LDA disassembler_code
	PHX
	TAX
	LDA printchar_key_high,X
	PLX
	JSR printchar
	LDA disassembler_code
	PHX
	TAX
	LDA printchar_key_low,X
	PLX
	JSR printchar
	LDA #ascii_space
	JSR printchar
	LDA disassembler_code_low
	PHX
	TAX
	LDA printchar_key_high,X
	PLX
	JSR printchar
	LDA disassembler_code_low
	PHX
	TAX
	LDA printchar_key_low,X
	PLX
	JSR printchar
	LDA #ascii_space
	JSR printchar
	LDA disassembler_code_high
	PHX
	TAX
	LDA printchar_key_high,X
	PLX
	JSR printchar
	LDA disassembler_code_high
	PHX
	TAX
	LDA printchar_key_low,X
	PLX
	JSR printchar
	LDA #ascii_space
	JSR printchar
	JSR printchar
	JSR printchar
	JSR disassembler_mini_select_left
	LDA disassembler_letter1
	JSR printchar
	LDA disassembler_letter2
	JSR printchar
	LDA disassembler_letter3
	JSR printchar
	LDA #ascii_space
	JSR printchar
	LDA #ascii_dollar
	JSR printchar	
	LDA disassembler_code_high
	JSR disassembler_mini_hex
	LDA disassembler_code_low
	JSR disassembler_mini_hex
	LDA #ascii_comma			; commas are ignored the assembler portion, so this is here to just look good
	JSR printchar
	LDA #ascii_X				; there's your X
	JSR printchar
	LDA #ascii_space
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR disassembler_mini_select_right
	JMP disassembler_increment
disassembler_addr_absolute_y			; copy/paste with absolute,Y
	JSR disassembler_mini_inc
	JSR sub_read2
	STA disassembler_code_low
	JSR disassembler_mini_inc
	JSR sub_read2
	STA disassembler_code_high
	LDA disassembler_code
	PHX
	TAX
	LDA printchar_key_high,X
	PLX
	JSR printchar
	LDA disassembler_code
	PHX
	TAX
	LDA printchar_key_low,X
	PLX
	JSR printchar
	LDA #ascii_space
	JSR printchar
	LDA disassembler_code_low
	PHX
	TAX
	LDA printchar_key_high,X
	PLX
	JSR printchar
	LDA disassembler_code_low
	PHX
	TAX
	LDA printchar_key_low,X
	PLX
	JSR printchar
	LDA #ascii_space
	JSR printchar
	LDA disassembler_code_high
	PHX
	TAX
	LDA printchar_key_high,X
	PLX
	JSR printchar
	LDA disassembler_code_high
	PHX
	TAX
	LDA printchar_key_low,X
	PLX
	JSR printchar
	LDA #ascii_space
	JSR printchar
	JSR printchar
	JSR printchar
	JSR disassembler_mini_select_left
	LDA disassembler_letter1
	JSR printchar
	LDA disassembler_letter2
	JSR printchar
	LDA disassembler_letter3
	JSR printchar
	LDA #ascii_space
	JSR printchar
	LDA #ascii_dollar
	JSR printchar	
	LDA disassembler_code_high
	JSR disassembler_mini_hex
	LDA disassembler_code_low
	JSR disassembler_mini_hex
	LDA #ascii_comma
	JSR printchar
	LDA #ascii_Y				; there's your Y
	JSR printchar
	LDA #ascii_space
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR disassembler_mini_select_right
	JMP disassembler_increment
disassembler_addr_absolute_indirect		; only JMP can have ($4444) absolute indirect
	JSR disassembler_mini_inc		; the assembler will only recognize the ( symbol, the ) symbol is ignored
	JSR sub_read2				; also, there is the other ($4444,X) addressing mode that I completely ignored, oh well
	STA disassembler_code_low
	JSR disassembler_mini_inc
	JSR sub_read2
	STA disassembler_code_high
	LDA disassembler_code
	PHX
	TAX
	LDA printchar_key_high,X
	PLX
	JSR printchar
	LDA disassembler_code
	PHX
	TAX
	LDA printchar_key_low,X
	PLX
	JSR printchar
	LDA #ascii_space
	JSR printchar
	LDA disassembler_code_low
	PHX
	TAX
	LDA printchar_key_high,X
	PLX
	JSR printchar
	LDA disassembler_code_low
	PHX
	TAX
	LDA printchar_key_low,X
	PLX
	JSR printchar
	LDA #ascii_space
	JSR printchar
	LDA disassembler_code_high
	PHX
	TAX
	LDA printchar_key_high,X
	PLX
	JSR printchar
	LDA disassembler_code_high
	PHX
	TAX
	LDA printchar_key_low,X
	PLX
	JSR printchar
	LDA #ascii_space
	JSR printchar
	JSR printchar
	JSR printchar
	JSR disassembler_mini_select_left
	LDA disassembler_letter1
	JSR printchar
	LDA disassembler_letter2
	JSR printchar
	LDA disassembler_letter3
	JSR printchar
	LDA #ascii_space
	JSR printchar
	LDA #ascii_parenthesis_left
	JSR printchar
	LDA #ascii_dollar
	JSR printchar	
	LDA disassembler_code_high
	JSR disassembler_mini_hex
	LDA disassembler_code_low
	JSR disassembler_mini_hex
	LDA #ascii_parenthesis_right
	JSR printchar
	LDA #ascii_space
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR disassembler_mini_select_right
	JMP disassembler_increment
disassembler_addr_accumulator			; the accumlator addressing mode doesn't use any extra bytes, but it does have an A character after the letters
	LDA disassembler_code
	PHX
	TAX
	LDA printchar_key_high,X
	PLX
	JSR printchar
	LDA disassembler_code
	PHX
	TAX
	LDA printchar_key_low,X
	PLX
	JSR printchar
	LDA #ascii_space
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar	
	JSR printchar
	JSR disassembler_mini_select_left
	LDA disassembler_letter1
	JSR printchar
	LDA disassembler_letter2
	JSR printchar
	LDA disassembler_letter3
	JSR printchar
	LDA #ascii_space
	JSR printchar
	LDA #ascii_A				; there's your A character
	JSR printchar
	LDA #ascii_space
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR disassembler_mini_select_right
	JMP disassembler_increment
disassembler_addr_immediate			; immediate addressing is always defined with # symbol, followed by a single byte
	JSR disassembler_mini_inc
	JSR sub_read2
	STA disassembler_code_low
	LDA disassembler_code
	PHX
	TAX
	LDA printchar_key_high,X
	PLX
	JSR printchar
	LDA disassembler_code
	PHX
	TAX
	LDA printchar_key_low,X
	PLX
	JSR printchar
	LDA #ascii_space
	JSR printchar
	LDA disassembler_code_low
	PHX
	TAX
	LDA printchar_key_high,X
	PLX
	JSR printchar
	LDA disassembler_code_low
	PHX
	TAX
	LDA printchar_key_low,X
	PLX
	JSR printchar
	LDA #ascii_space
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR disassembler_mini_select_left
	LDA disassembler_letter1
	JSR printchar
	LDA disassembler_letter2
	JSR printchar
	LDA disassembler_letter3
	JSR printchar
	LDA #ascii_space
	JSR printchar
	LDA #ascii_pound			; there's your # symbol
	JSR printchar
	LDA #ascii_dollar
	JSR printchar
	LDA disassembler_code_low
	JSR disassembler_mini_hex
	LDA #ascii_space
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR disassembler_mini_select_right
	JMP disassembler_increment
disassembler_addr_relative			; relative addressing has only one byte after the code byte, nothing special I suppose
	JSR disassembler_mini_inc
	JSR sub_read2
	STA disassembler_code_low
	LDA disassembler_code
	PHX
	TAX
	LDA printchar_key_high,X
	PLX
	JSR printchar
	LDA disassembler_code
	PHX
	TAX
	LDA printchar_key_low,X
	PLX
	JSR printchar
	LDA #ascii_space
	JSR printchar
	LDA disassembler_code_low
	PHX
	TAX
	LDA printchar_key_high,X
	PLX
	JSR printchar
	LDA disassembler_code_low
	PHX
	TAX
	LDA printchar_key_low,X
	PLX
	JSR printchar
	LDA #ascii_space
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR disassembler_mini_select_left
	LDA disassembler_letter1
	JSR printchar
	LDA disassembler_letter2
	JSR printchar
	LDA disassembler_letter3
	JSR printchar
	LDA #ascii_space
	JSR printchar
	LDA #ascii_pound
	JSR printchar
	LDA #ascii_dollar			; $ symbols are ignored in the assembler, but it makes it look better here
	JSR printchar
	LDA disassembler_code_low
	JSR disassembler_mini_hex
	LDA #ascii_space
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR disassembler_mini_select_right
	JMP disassembler_increment
disassembler_illegal				; oh no!  illegal instructions go here, it just prints "ILLEGAL" all up in your face, just like that.
	LDA disassembler_code
	PHX
	TAX
	LDA printchar_key_high,X
	PLX
	JSR printchar
	LDA disassembler_code
	PHX
	TAX
	LDA printchar_key_low,X
	PLX
	JSR printchar
	LDA #ascii_space
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR disassembler_mini_select_left
	LDA #ascii_I				; let me do my thing, ya know.  Some things are special cases.
	JSR printchar
	LDA #ascii_L
	JSR printchar
	LDA #ascii_L
	JSR printchar
	LDA #ascii_E
	JSR printchar
	LDA #ascii_G
	JSR printchar
	LDA #ascii_A
	JSR printchar
	LDA #ascii_L
	JSR printchar
	LDA #ascii_space
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR printchar
	JSR disassembler_mini_select_right
disassembler_increment				; here the sub_read2 is incremented, as well as the vertical position of the characters that will be printed
	INC disassembler_height
	INC disassembler_height
	INC disassembler_height
	INC disassembler_height
	INC sub_read2+1
	LDA sub_read2+1
	BNE disassembler_restart
	INC sub_read2+2
disassembler_restart				; disassembler_pos the amount of lines of code down you are at
	INC disassembler_pos
	LDA disassembler_pos
	CMP #$1A 				; 26 lines total in the disassembler, exit when you hit that mark
	BEQ disassembler_exit
	JMP disassembler_loop
disassembler_exit
	PLY
	PLX
	PLA
	RTS

disassembler_mini_inc				; this is the sub-sub-routine 'mini_inc', it just increments the sub_read2 stuff
	INC sub_read2+1
	LDA sub_read2+1
	BNE disassembler_mini_inc_exit
	INC sub_read2+2
disassembler_mini_inc_exit
	RTS

disassembler_mini_hex				; and this sub-sub-routine just prints the hex byte in the accumulator onto the screen at X and Y coordinates
	PHA
	PHX
	TAX
	LDA printchar_key_high,X
	PLX
	JSR printchar
	PLA
	PHA
	PHX
	TAX
	LDA printchar_key_low,X
	PLX
	JSR printchar
	PLA
	RTS

disassembler_mini_select_left			; these check to see if brackets should be used on the assembly code, and if so, print them, and if not, use a space
	LDA disassembler_select
	BEQ disassembler_mini_select_left_continue
	LDA #ascii_bracket_left
	JSR printchar
	RTS
disassembler_mini_select_left_continue
	LDA #ascii_space
	JSR printchar
	RTS

disassembler_mini_select_right			; same thing again, only on the far right side
	LDA disassembler_select
	BEQ disassembler_mini_select_left_continue
	LDA #ascii_bracket_right
	JSR printchar
	RTS
disassembler_mini_select_right_continue
	LDA #ascii_space
	JSR printchar
	RTS



; assembler sub-routine
; this is where you type actual assembly code into command_array, and this will make it turn into hex code and write that into memory
; it uses a the assembler_lookup table far above, with $FF as an 'end of code' value, and the last value in the 8 byte code is the actual hex code for the... code
; $01 and $00 are the high and low byte lookups.  The assembler is picky in that it wants to actually find values there, and really close together
; it ignores commas, spaces, and dollar signs, and other things.  It tries to be flexible
assembler
	PHA
	PHX
	PHY
	STZ assembler_code			; initialize parameters and stuff
	STZ assembler_code_low			; again this assembler_code and its low and high could be actually run directly and not just stuck into memory
	STZ assembler_code_high			; I will not be implementing that here and now, but just thinking of the future
	STZ assembler_bytes
	STZ assembler_mode
	LDA #<assembler_lookup
	STA assembler_pos_low
	LDA #>assembler_lookup
	STA assembler_pos_high
	LDX #$00
	LDA command_array,X			; start reading from the command_array, it is looking for the 4 address nibbles first
	INX
	PHX
	TAX
	LDA printchar_value,X
	PLX
	CMP #$FF
	BNE assembler_continue1
	JMP assembler_error			; and if it doesn't see them, 'error' out and leave immediately
assembler_continue1
	CLC
	ROL A					; this 'ROL A' stuff is to move the $0F value from the table to something like $F0 instead
	ROL A
	ROL A
	ROL A
	STA assembler_cursor_high
	LDA command_array,X
	INX
	PHX
	TAX
	LDA printchar_value,X
	PLX
	CMP #$FF
	BNE assembler_continue2
	JMP assembler_error
assembler_continue2
	CLC
	ADC assembler_cursor_high		; and then later you ADC them together to make your full byte value
	STA assembler_cursor_high
	LDA command_array,X			; repeat again for the 2 lower nibbles
	INX
	PHX
	TAX
	LDA printchar_value,X
	PLX
	CMP #$FF
	BNE assembler_continue3
	JMP assembler_error
assembler_continue3
	CLC
	ROL A
	ROL A
	ROL A
	ROL A
	STA assembler_cursor_low
	LDA command_array,X
	INX
	PHX
	TAX
	LDA printchar_value,X
	PLX
	CMP #$FF
	BNE assembler_continue4
	JMP assembler_error
assembler_continue4
	CLC
	ADC assembler_cursor_low
	STA assembler_cursor_low
	LDY #$00				; Y is the counter to which character in the assembler_lookup table you are currently looking at
assembler_loop1					; it will go back to zero quite often, and will not increment when looking at skipped characters
	CPX command_length
	BNE assembler_loop2
	JMP assembler_end1			; this is the only way to exit the assembler loop!  once you get to the end of command_array, NOW you can exit
assembler_loop2
	LDA command_array,X
	CMP #ascii_space			; spaces are skipped
	BNE assembler_loop3
	JMP assembler_skip
assembler_loop3
	CMP #ascii_dollar			; $ symbols are skipped
	BNE assembler_loop4
	JMP assembler_skip
assembler_loop4
	CMP #ascii_comma			; commas are skipped
	BNE assembler_loop5
	JMP assembler_skip
assembler_loop5
	CMP #ascii_parenthesis_right		; right parenthesis are skipped (left ones are good enough)
	BNE assembler_loop6
	JMP assembler_skip
assembler_loop6
	CMP #ascii_colon			; colons are skipped
	BNE assembler_loop7
	JMP assembler_skip
assembler_loop7
	CMP #ascii_caret			; carets realign the top of the code, jump there
	BNE assembler_loop8
	JMP assembler_realign
assembler_loop8
	CMP #ascii_equal			; equal sign is data sequences, which automatically exit after running through it, no assembly code will be inserted
	BNE assembler_loop9
	JMP assembler_data1
assembler_loop9
	CMP #ascii_quote			; quote marks are string sequences, again automatically exiting after running through it, no assembly code will be inserted
	BNE assembler_loopA
	JMP assembler_string1
assembler_loopA
	LDA assembler_pos_low			; get the sub_read ready
	STA sub_read+1
	TYA
	CLC
	ADC sub_read+1
	STA sub_read+1
	LDA assembler_pos_high
	STA sub_read+2
	JSR sub_read				; and now read a character from the assembly lookup table
	CMP #$00				; $00 indicates it wants to find the low byte argument (or the only byte argument, depending)
	BNE assembler_loopB
	JMP assembler_byte_low1
assembler_loopB
	CMP #$01				; $01 indicates it wants to find the high byte argument
	BNE assembler_loopC
	JMP assembler_byte_high1
assembler_loopC
	CMP #$FF				; $FF says we are done with looking up the value.  Basically, we found a match in the assembler lookup table!
	BNE assembler_loopD
	INC assembler_mode			; so flag that for later use, say, "hey, we are done here guys", soon when you reach the end of the command_array it will know what to do
	JMP assembler_skip			; some assembly lines have multiple $FF values, so just skip any extra stuff for now, wait and be patient
assembler_loopD
	CMP command_array,X			; now compare what you just read in sub_read vs the actual command_array, do they match?
	BEQ assembler_increment			; if so, good, INY and keep looking around
	JMP assembler_next1			; else we skip that instruction and see if we can find another one that might match
assembler_increment
	INX					; INX to move to the next character in the command_array
	INY					; INY to move to the next character in the assembly lookup table
	JMP assembler_loop1			; back to the beginning
assembler_realign				; you used a ^ symbol, so tell the disassembler to alter it's 'start of code' position
	LDA assembler_cursor_low
	STA disassembler_low
	LDA assembler_cursor_high
	STA disassembler_high
	JMP assembler_skip			; and keep moving, you can use this along with assembly and data/string sequences
assembler_data1					; you wanted a sequence of hex values
	CPX command_length			; keep looping until the end of the command_array
	BNE assembler_data2
	JMP assembler_exit
assembler_data2
	INX
	LDA command_array,X			; read the command_array for the high nibble
	PHX
	TAX
	LDA printchar_value,X
	PLX
	CMP #$FF				; if it's not a hex value, ignore it, back to loop
	BNE assembler_data3
	JMP assembler_data1
assembler_data3
	CLC
	ROL A					; move the $0F to $F0 value and store for later
	ROL A
	ROL A
	ROL A
	STA assembler_data
	INX
	LDA command_array,X			; read the lower nibble
	PHX
	TAX
	LDA printchar_value,X
	PLX
	CMP #$FF				; ignore weird characters
	BNE assembler_data4
	JMP assembler_data1
assembler_data4
	CLC
	ADC assembler_data			; add $F0 to $0F to get $FF basically (not really $FF here, just an example of what's going on)
	STA assembler_data
	LDA assembler_cursor_low		; setup the sub_write program
	STA sub_write+1	
	LDA assembler_cursor_high
	STA sub_write+2
	LDA assembler_data
	JSR sub_write				; and store that data byte in memory
	INC assembler_cursor_low		; jump to the next place in memory
	LDA assembler_cursor_low
	BEQ assembler_data5
	JMP assembler_data1
assembler_data5
	INC assembler_cursor_high
	JMP assembler_data1			; back to the loop
assembler_string1				; here you wanted a literal/string sequence, it is much easier
	CPX command_length			; only exit at the end of the command_array though
	BNE assembler_string2
	JMP assembler_exit
assembler_string2
	INX
	LDA command_array,X			; load that character value
	CMP #$00				; if you hit $00 character (which cannot come from the keyboard itself btw), and is only put in far above in the main_return area...
	BNE assembler_string3
	JMP assembler_exit			; then exit!  This keeps it from writing a bunch of $00 values into memory, that YOU didn't type, but was put there to help the assembler
assembler_string3
	STA assembler_data
	LDA assembler_cursor_low
	STA sub_write+1
	LDA assembler_cursor_high
	STA sub_write+2
	LDA assembler_data
	JSR sub_write				; again setup sub_write, and then write to memory
	INC assembler_cursor_low
	LDA assembler_cursor_low
	BEQ assembler_string4
	JMP assembler_string1
assembler_string4
	INC assembler_cursor_high
	JMP assembler_string1			; back to the loop
assembler_skip					; skipping only increments command_array, not INY because we didn't check that against the assembler lookup table (it was ignored/skipped!)
	INX
	JMP assembler_loop1
assembler_next1					; go to the next 8 bytes in the assembly lookup table, see if that will match (because this one did not)
	LDX #$04
	LDY #$00
	STZ assembler_mode			; make sure to let everyone know that NO it did not work, it was not a valid assembly code
	LDA assembler_pos_low
	CLC
	ADC #$08				; 8 bytes per code in the assembly lookup table
	STA assembler_pos_low
	BEQ assembler_next2
	JMP assembler_loop1
assembler_next2
	INC assembler_pos_high
	JMP assembler_loop1			; back to the loop
assembler_byte_low1				; expecting the lower byte here ($00 in the lookup table), that is 2 nibbles
	INC assembler_bytes			; we are expecting to print out at least one byte at the end here, flag that for later
	LDA command_array,X
	INX
	PHX
	TAX
	LDA printchar_value,X
	PLX
	CMP #$FF
	BNE assembler_byte_low2
	JMP assembler_error			; if you got something weird here, error.  We want nice and clean and connected nibbles!
assembler_byte_low2
	CLC
	ROL A
	ROL A
	ROL A
	ROL A
	STA assembler_code_low
	LDA command_array,X			; this is all repeated stuff here, I should make a better sub-routin for all of this honestly.
	INX
	PHX
	TAX
	LDA printchar_value,X
	PLX
	CMP #$FF
	BNE assembler_byte_low3
	JMP assembler_error
assembler_byte_low3
	CLC
	ADC assembler_code_low			; add in the lower nibble to the higher nibble
	STA assembler_code_low
	INY					; we fulfilled our purpose here, that lower byte was captures, good, so INY
	JMP assembler_loop1			; back to loop
assembler_byte_high1				; we wanted a high byte ($01 in the lookup table)
	INC assembler_bytes			; here again we want to flag the fact that we want to write another instruction byte
	LDA command_array,X			; thing is, the high byte always comes second, so the only way to make this happen (here) is to now have TWO bytes that need to be written
	INX					; repeat everything else below like usual
	PHX
	TAX
	LDA printchar_value,X
	PLX
	CMP #$FF
	BNE assembler_byte_high2
	JMP assembler_error
assembler_byte_high2
	CLC
	ROL A
	ROL A
	ROL A
	ROL A
	STA assembler_code_high
	LDA command_array,X
	INX
	PHX
	TAX
	LDA printchar_value,X
	PLX
	CMP #$FF
	BNE assembler_byte_high3
	JMP assembler_error
assembler_byte_high3
	CLC
	ADC assembler_code_high
	STA assembler_code_high
	INY
	JMP assembler_loop1			; back to loop
assembler_end1					; this is the ONLY exit (besides 'error' I guess)
	LDA assembler_mode			; check the 'mode', basically did we get a legit assembly code?
	BNE assembler_end2
	JMP assembler_error			; we didn't actually, so error for sure
assembler_end2					; and here we did!  So now we want to take the code values we have and put those into memory
	LDA #$07				; notice the $07 here, that is the 8th byte in the assembler lookup table for that particular instruction, it is the instruction byte itself
	CLC
	ADC assembler_pos_low
	STA assembler_pos_low
	STA sub_read+1
	LDA assembler_pos_high
	STA sub_read+2
	JSR sub_read				; setup the sub_read to read that code byte
	STA assembler_code
	LDA assembler_cursor_low
	STA sub_write+1
	LDA assembler_cursor_high
	STA sub_write+2
	LDA assembler_code
	JSR sub_write				; and then write it using sub_write, but we aren't done
	INC sub_write+1
	LDA sub_write+1
	BNE assembler_end3
	INC sub_write+2
assembler_end3
	LDA assembler_bytes			; do we need to print a lower byte argument now?
	BNE assembler_end4
	JMP assembler_end7			; if not, skip ahead
assembler_end4
	DEC assembler_bytes			; if so, then decrement the amount of bytes we need (we might only need one, but might also need two)
	LDA assembler_code_low			; and write that byte as well
	JSR sub_write
	INC sub_write+1
	LDA sub_write+1
	BNE assembler_end5
	INC sub_write+2
assembler_end5
	LDA assembler_bytes			; do we have a high byte argument also?
	BNE assembler_end6
	JMP assembler_end7			; if no, skip ahead
assembler_end6					; if yes, then write out that byte as well
	DEC assembler_bytes
	LDA assembler_code_high
	JSR sub_write
	INC sub_write+1
	LDA sub_write+1
	BNE assembler_end7
	INC sub_write+2
assembler_end7					; make sure the new cursor is where we ended off, that will be important for the disassembler later
	LDA sub_write+1
	STA assembler_cursor_low
	LDA sub_write+2
	STA assembler_cursor_high
	JMP assembler_exit			; and finally exit, yay!
assembler_error					; and if we errored, make sure to print a ? mark real quick like.  It goes fast, but is there for a second, and it's helpful to the user
	PLY
	PLX
	PHX
	PHY
	LDA #ascii_question
	JSR printchar
assembler_exit					; remember to clean up the stack (though I don't know why I needed to do that here anyways)
	PLY
	PLX
	PLA
	RTS

; executecommand sub-routine
; this is only used from the memory dump
; it basically decodes 4 letter commands and then does something with them
; extra parameters to these commands follow as byte values, and this program will look for those as well
; and if it doesn't match, then just error and wait for the next command
executecommand
	PHA
	PHX
	PHY
	STZ execute_var1_low			; initialize all of the possible parameters to zero
	STZ execute_var1_high			; (so that if there is no parameters to be found, they would at least default to something ok)
	STZ execute_var2_low			; thing is, I will re-initialize some of these to the memory dump cursor position
	STZ execute_var2_high
	STZ execute_var3_low
	STZ execute_var3_high
	STZ execute_var4_low
	STZ execute_var4_high
executecommand_code1
	LDX #$00
executecommand_code2				; mini loop for each command starts here
	CPX command_length			; only can exit at the end of the command_array
	BEQ executecommand_page1
	LDA command_array,X
	INX
	CMP #ascii_C
	BNE executecommand_code2		; keep ignoring stuff until you find the start of 'CODE' then it must all have all the letters put together
	LDA command_array,X
	INX
	CMP #ascii_O
	BNE executecommand_page1
	LDA command_array,X
	INX
	CMP #ascii_D
	BNE executecommand_page1
	LDA command_array,X
	INX
	CMP #ascii_E
	BNE executecommand_page1		; all of these "page1" jumps are basically saying "it's not CODE, but maybe it's PAGE?"
	LDA display_low				; this is the specific code that happens whenever you type PAGE, this here is re-initializing the variables to the mem dump cursor pos
	STA execute_var1_low
	LDA display_high
	STA execute_var1_high
	JSR executecommand_mini_two		; this 'mini_two' is reading two bytes and storing them into execute_var1, very simple
	LDA execute_var1_low
	STA disassembler_low			; store those new values as the start of code for the disassembler, and the assembler
	STA assembler_cursor_low
	LDA execute_var1_high
	STA disassembler_high
	STA assembler_cursor_high
	LDA #$01
	STA command_mode			; make sure that you are now in the coding mode instead of memory dump
	JSR clearscreen				; clear the screen because we will redraw it with a new looking mode
	JMP executecommand_exit			; and exit
executecommand_page1
	LDX #$00
executecommand_page2				; repeat this process for each command, this one is 'PAGE'
	CPX command_length
	BEQ executecommand_move1
	LDA command_array,X
	INX
	CMP #ascii_P
	BNE executecommand_page2
	LDA command_array,X
	INX
	CMP #ascii_A
	BNE executecommand_move1
	LDA command_array,X
	INX
	CMP #ascii_G
	BNE executecommand_move1
	LDA command_array,X
	INX
	CMP #ascii_E
	BNE executecommand_move1
	LDA display_low
	STA execute_var1_low
	LDA display_high
	STA execute_var1_high
	JSR executecommand_mini_two		; expects two bytes for an address, stores them into display_low and display_high
	LDA execute_var1_high
	STA display_high
	LDA execute_var1_low
	STA display_low
	JMP executecommand_exit
executecommand_move1
	LDX #$00
executecommand_move2				; the 'MOVE' command
	CPX command_length
	BEQ executecommand_fill1
	LDA command_array,X
	INX
	CMP #ascii_M
	BNE executecommand_move2
	LDA command_array,X
	INX
	CMP #ascii_O
	BNE executecommand_fill1
	LDA command_array,X
	INX
	CMP #ascii_V
	BNE executecommand_fill1
	LDA command_array,X
	INX
	CMP #ascii_E
	BNE executecommand_fill1
	LDA display_low
	STA execute_var1_low
	LDA display_high
	STA execute_var1_high
	JSR executecommand_mini_two		; expect two bytes
	LDA execute_var1_high
	STA execute_var3_high			; move them to var3
	LDA execute_var1_low
	STA execute_var3_low
	LDA display_low
	STA execute_var1_low
	LDA display_high
	STA execute_var1_high
	JSR executecommand_mini_two		; expect two more bytes
	LDA execute_var1_high
	STA execute_var2_high			; move them to var2
	LDA execute_var1_low
	STA execute_var2_low
	LDA display_low
	STA execute_var1_low
	LDA display_high
	STA execute_var1_high
	JSR executecommand_mini_two		; expect two final bytes
	JSR multimove				; then run the 'multimove' subroutine
	JMP executecommand_exit
executecommand_fill1
	LDX #$00
executecommand_fill2				; 'FILL' command
	CPX command_length
	BEQ executecommand_goto1
	LDA command_array,X
	INX
	CMP #ascii_F
	BNE executecommand_fill2
	LDA command_array,X
	INX
	CMP #ascii_I
	BNE executecommand_goto1
	LDA command_array,X
	INX
	CMP #ascii_L
	BNE executecommand_goto1
	LDA command_array,X
	INX
	CMP #ascii_L
	BNE executecommand_goto1
	LDA display_low
	STA execute_var1_low
	LDA display_high
	STA execute_var1_high
	JSR executecommand_mini_two		; expect two bytes
	LDA execute_var1_high
	STA execute_var3_high			; move to var3
	LDA execute_var1_low
	STA execute_var3_low
	LDA display_low
	STA execute_var1_low
	LDA display_high
	STA execute_var1_high
	JSR executecommand_mini_two		; expect two more bytes
	LDA execute_var1_high
	STA execute_var2_high			; move to var2
	LDA execute_var1_low
	STA execute_var2_low
	STZ execute_var1_low
	STZ execute_var1_high
	JSR executecommand_mini_one		; expect only 1 more byte, the fill byte, it goes into var1_high
	JSR multifill				; run 'multifill' subroutine
	JMP executecommand_exit
executecommand_goto1
	LDX #$00
executecommand_goto2				; 'GOTO' command
	CPX command_length
	BEQ executecommand_tape1
	LDA command_array,X
	INX
	CMP #ascii_G
	BNE executecommand_goto2
	LDA command_array,X
	INX
	CMP #ascii_O
	BNE executecommand_tape1
	LDA command_array,X
	INX
	CMP #ascii_T
	BNE executecommand_tape1
	LDA command_array,X
	INX
	CMP #ascii_O
	BNE executecommand_tape1
	LDA display_low
	STA execute_var1_low
	LDA display_high
	STA execute_var1_high
	JSR executecommand_mini_two		; expect two bytes
	LDA execute_var1_low
	STA sub_jump+1				; store them into sub_jump, which will be jumped to after we exit
	LDA execute_var1_high
	STA sub_jump+2
	JMP executecommand_exit
executecommand_tape1
	LDX #$00
executecommand_tape2				; 'TAPE' command.  This will wait around until all of the bytes are filled.
	CPX command_length			; Garth Wilson made the audio input circuit for me, it works GREAT.  VERY GOOD.  
	BEQ executecommand_save1		; It can at least run at 880 baud, possibly higher.
	LDA command_array,X
	INX
	CMP #ascii_T
	BNE executecommand_tape2
	LDA command_array,X
	INX
	CMP #ascii_A
	BNE executecommand_save1
	LDA command_array,X
	INX
	CMP #ascii_P
	BNE executecommand_save1
	LDA command_array,X
	INX
	CMP #ascii_E
	BNE executecommand_save1
	LDA display_low
	STA execute_var1_low
	LDA display_high
	STA execute_var1_high
	JSR executecommand_mini_two		; expect two bytes
	LDA execute_var1_high
	STA execute_var3_high			; move to var3
	LDA execute_var1_low
	STA execute_var3_low
	LDA display_low
	STA execute_var1_low
	LDA display_high
	STA execute_var1_high
	JSR executecommand_mini_two		; expect two more bytes
	LDA execute_var1_high
	STA execute_var2_high			; move to var2
	LDA execute_var1_low
	STA execute_var2_low
	LDA execute_var3_high			; move var3 to var1
	STA execute_var1_high
	LDA execute_var3_low
	STA execute_var1_low
	JSR audioinput				; run the 'audioinput' subroutine, and then exit (this hangs for quite some time, waiting for all of the bytes to be filled)
	JMP executecommand_exit			; only a hard reset will fix it if something goes wrong
executecommand_save1
	LDX #$00
executecommand_save2				; 'SAVE' command, saves data into the SPI EEPROM A
	CPX command_length
	BEQ executecommand_load1
	LDA command_array,X
	INX
	CMP #ascii_S
	BNE executecommand_save2
	LDA command_array,X
	INX
	CMP #ascii_A
	BNE executecommand_load1
	LDA command_array,X
	INX
	CMP #ascii_V
	BNE executecommand_load1
	LDA command_array,X
	INX
	CMP #ascii_E
	BNE executecommand_load1
	LDA display_low
	STA execute_var1_low
	LDA display_high
	STA execute_var1_high
	JSR executecommand_mini_two		; expect two bytes
	LDA execute_var1_high
	STA execute_var3_high
	LDA execute_var1_low
	STA execute_var3_low
	LDA display_low
	STA execute_var1_low
	LDA display_high
	STA execute_var1_high
	JSR executecommand_mini_two		; expect two more bytes (lots of repeating here)
	LDA execute_var1_high
	STA execute_var2_high
	LDA execute_var1_low
	STA execute_var2_low
	LDA execute_var3_high
	STA execute_var1_high
	LDA execute_var3_low
	STA execute_var1_low
	JSR spi_eeprom_write			; run 'spi_eeprom_write' subroutine
	JMP executecommand_exit
executecommand_load1
	LDX #$00
executecommand_load2				; 'LOAD' command, loads data from SPI EEPROM A into memory
	CPX command_length
	BEQ executecommand_help1
	LDA command_array,X
	INX
	CMP #ascii_L
	BNE executecommand_load2
	LDA command_array,X
	INX
	CMP #ascii_O
	BNE executecommand_help1
	LDA command_array,X
	INX
	CMP #ascii_A
	BNE executecommand_help1
	LDA command_array,X
	INX
	CMP #ascii_D
	BNE executecommand_help1
	LDA display_low
	STA execute_var1_low
	LDA display_high
	STA execute_var1_high
	JSR executecommand_mini_two		; expect two bytes
	LDA execute_var1_high
	STA execute_var3_high
	LDA execute_var1_low
	STA execute_var3_low
	LDA display_low
	STA execute_var1_low
	LDA display_high
	STA execute_var1_high
	JSR executecommand_mini_two		; expect two more bytes
	LDA execute_var1_high
	STA execute_var2_high
	LDA execute_var1_low
	STA execute_var2_low
	LDA execute_var3_high
	STA execute_var1_high
	LDA execute_var3_low
	STA execute_var1_low
	JSR spi_eeprom_read			; run 'spi_eeprom_read' subroutine
	JMP executecommand_exit
executecommand_help1
	LDX #$00
executecommand_help2				; 'HELP' command, very different, because it just prints a ton of stuff to the screen and waits for a key press
	CPX command_length
	BEQ executecommand_byte1
	LDA command_array,X
	INX
	CMP #ascii_H
	BNE executecommand_help2
	LDA command_array,X
	INX
	CMP #ascii_E
	BNE executecommand_byte1
	LDA command_array,X
	INX
	CMP #ascii_L
	BNE executecommand_byte1
	LDA command_array,X
	INX
	CMP #ascii_P
	BNE executecommand_byte1
	JSR clearscreen				; first, clear the screen
	LDY #>screen				; start at top of the screen
	LDX #$00
	LDA #<help_text				; and start reading using sub_read2 for all of the help_text available
	STA sub_read2+1
	LDA #>help_text
	STA sub_read2+2
executecommand_help3
	JSR sub_read2				; read in a character
	PHA
	INC sub_read2+1				; increment where you are reading from
	LDA sub_read2+1
	BNE executecommand_help4
	INC sub_read2+2
executecommand_help4 
	PLA
	CMP #$FF				; if you get $FF character, that is the end of the help_text, so exit
	BNE executecommand_help6
	STZ key_counter 			; reset keys and wait for any input, so Escape will work, but really ANY key will work
	STZ key_release
	STZ key_extended
	STZ key_read_pos
	STZ key_write_pos
	STZ audio_value
	STZ audio_count
executecommand_help5				; this is the waiting loop, waiting for any key to appear
	LDA key_read_pos
	CMP key_write_pos
	BEQ executecommand_help5		; jump back to loop until you find a key was pressed
	JMP main_refresh			; but when you do, clear the screen and start fresh, as if Escape was pressed (if Escape WAS pressed, it will do this twice basically)
executecommand_help6
	CMP #ascii_return			; if the printed character is $5A, that means it's a new-line character, so 4x INY and start over at the left side of the screen
	BNE executecommand_help7
	LDX #$00
	INY
	INY
	INY
	INY
	JMP executecommand_help3
executecommand_help7
	JSR printchar				; any other character, just print it
	JMP executecommand_help3
executecommand_byte1
	LDX #$00
executecommand_byte2				; 'BYTE' command, writes a single byte into the cursor memory dump location, and does NOT increment
	CPX command_length
	BEQ executecommand_find1
	LDA command_array,X
	INX
	CMP #ascii_B
	BNE executecommand_byte2
	LDA command_array,X
	INX
	CMP #ascii_Y
	BNE executecommand_find1
	LDA command_array,X
	INX
	CMP #ascii_T
	BNE executecommand_find1
	LDA command_array,X
	INX
	CMP #ascii_E
	BNE executecommand_find1
	JSR executecommand_mini_one		; expects one byte
	LDA display_low
	STA sub_write+1
	LDA display_high
	STA sub_write+2
	LDA execute_var1_high
	JSR sub_write				; write that byte into memory and exit
	JMP executecommand_exit
executecommand_find1
	LDX #$00
executecommand_find2				; 'FIND' command, just inverts the color of any byte desired in the memory dump
	CPX command_length
	BEQ executecommand_card1
	LDA command_array,X
	INX
	CMP #ascii_F
	BNE executecommand_find2
	LDA command_array,X
	INX
	CMP #ascii_I
	BNE executecommand_card1
	LDA command_array,X
	INX
	CMP #ascii_N
	BNE executecommand_card1
	LDA command_array,X
	INX
	CMP #ascii_D
	BNE executecommand_card1
	JSR executecommand_mini_one		; expects one byte
	LDA execute_var1_high
	STA display_highlight			; make that the 'highlighted' byte in the memory dump
	JMP executecommand_exit
executecommand_card1
	LDX #$00
executecommand_card2				; 'CARD' command, initializes the sdcard
	CPX command_length			; for parameters, the first two bytes are the beginning BLOCKS on the sdcard
	BEQ executecommand_card3		; the second two bytes are the ending BLOCKS on the sdcard
	LDA command_array,X			; the third two bytes is the starting address location in regular BYTES on the computer
	INX
	CMP #ascii_C
	BNE executecommand_card2
	LDA command_array,X
	INX
	CMP #ascii_A
	BNE executecommand_card3
	LDA command_array,X
	INX
	CMP #ascii_R
	BNE executecommand_card3
	LDA command_array,X
	INX
	CMP #ascii_D
	BNE executecommand_card3
	JMP executecommand_card4
executecommand_card3
	JMP executecommand_play1
executecommand_card4
	LDA display_low
	STA execute_var1_low
	LDA display_high
	STA execute_var1_high
	JSR executecommand_mini_two		; expect two bytes
	LDA execute_var1_high
	STA execute_var3_high			; move them to var3
	LDA execute_var1_low
	AND #%11111110				; only blocks of 512 bytes allowed
	STA execute_var3_low
	LDA display_low
	STA execute_var1_low
	LDA display_high
	STA execute_var1_high
	JSR executecommand_mini_two		; expect two more bytes
	LDA execute_var1_high
	STA execute_var2_high			; move them to var2
	LDA execute_var1_low
	AND #%11111110				; only blocks of 512 bytes allowed
	STA execute_var2_low
	LDA display_low
	STA execute_var1_low
	LDA display_high
	STA execute_var1_high
	JSR executecommand_mini_two		; expect two final bytes
	JSR spi_sdcard_init			; initialize SD card
executecommand_card5
	JSR spi_sdcard_read			; read 512 bytes from sdcard
	LDA execute_var2_high			; if var3 and var2 are the same, exit
	AND #%11111110
	CMP execute_var3_high
	BNE executecommand_card6
	LDA execute_var2_low
	AND #%11111110
	CMP execute_var3_low
	BNE executecommand_card6
	JMP executecommand_exit
executecommand_card6				; else increment var3 twice (that is 2 blocks of 256 bytes each)
	INC execute_var3_low
	INC execute_var3_low
	LDA execute_var3_low
	BNE executecommand_card7
	INC execute_var3_high
executecommand_card7				; and then increment var1_high twice (that is 512 bytes)
	INC execute_var1_high
	INC execute_var1_high
	JMP executecommand_card5
executecommand_play1
	LDX #$00
executecommand_play2
	CPX command_length
	BEQ executecommand_done1
	LDA command_array,X
	INX
	CMP #ascii_P
	BNE executecommand_play2
	LDA command_array,X
	INX
	CMP #ascii_L
	BNE executecommand_done1
	LDA command_array,X
	INX
	CMP #ascii_A
	BNE executecommand_done1
	LDA command_array,X
	INX
	CMP #ascii_Y
	BNE executecommand_done1
	JSR executecommand_mini_one		; expects one byte
	STA sub_read+2
	STZ sub_read+1
	LDY #$10
executecommand_play3
	DEY
	CPY #$00
	BNE executecommand_play4
	LDY #$10
	INC sub_read+1
	JSR sub_read
	STA execute_var1_low
executecommand_play4
	LDA #%01111110
	STA via_pb
	LDX #$00
executecommand_play5
	CPX execute_var1_low
	BEQ executecommand_play6
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	INX
	JMP executecommand_play5
executecommand_play6
	LDA #%01111111
	STA via_pb
	LDX #$00
executecommand_play7
	CPX execute_var1_low
	BEQ executecommand_play8
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	INX
	JMP executecommand_play7
executecommand_play8
	JMP executecommand_play3
executecommand_done1
	LDX #$00
executecommand_done2				; this is blank, but if you had more commands, you would put them here, follow the same pattern as before
executecommand_error				; if we had an error, as in, we did not understand the command or something, print a question mark where the original cursor was located
	PLY
	PLX
	PHX
	PHY
	LDA #ascii_question
	JSR printchar				; and it falls into exit
executecommand_exit				; exit by cleaning up the stack
	PLY
	PLX
	PLA	
	RTS

executecommand_mini_one				; 'mini_one' expects one byte following.  It ignores a lot of other characters before and after, but these two must be together.
	CPX command_length			; if we reached the end of the command_array, exit, I guess...  The initial value of var1 is retained
	BNE executecommand_mini_one2
	JMP executecommand_mini_one_exit
executecommand_mini_one2
	LDA command_array,X			; read from the command_array
	INX
	PHX
	TAX
	LDA printchar_value,X			; find it's hex value
	PLX
	CMP #$FF				; if it's not a hex character, ignore it, go back to loop
	BEQ executecommand_mini_one
	CLC
	ROL A					; move lower nibble to higher nibble
	ROL A
	ROL A
	ROL A
	STA execute_var1_high
	LDA command_array,X			; read second byte
	INX
	PHX
	TAX
	LDA printchar_value,X
	PLX
	CMP #$FF				; ignore weird characters, start over
	BNE executecommand_mini_one3
	JMP executecommand_mini_one_exit
executecommand_mini_one3
	CLC
	ADC execute_var1_high			; add lower nibble to higher nibble
	STA execute_var1_high			; store in var1_high, that is where that one byte value will be located for later use
executecommand_mini_one_exit
	RTS

executecommand_mini_two				; 'mini_two' repeats the exact same process, but twice, nothing new here
	CPX command_length
	BNE executecommand_mini_two2
	JMP executecommand_mini_two_exit
executecommand_mini_two2
	LDA command_array,X
	INX
	PHX
	TAX
	LDA printchar_value,X
	PLX
	CMP #$FF
	BEQ executecommand_mini_two
	CLC
	ROL A
	ROL A
	ROL A
	ROL A
	STA execute_var1_high
	LDA command_array,X
	INX
	PHX
	TAX
	LDA printchar_value,X
	PLX
	CMP #$FF
	BNE executecommand_mini_two3
	JMP executecommand_mini_two_exit
executecommand_mini_two3
	CLC
	ADC execute_var1_high
	STA execute_var1_high			; store the first byte in var1_high
	LDA command_array,X
	INX
	PHX
	TAX
	LDA printchar_value,X
	PLX
	CMP #$FF
	BNE executecommand_mini_two4
	JMP executecommand_mini_two_exit
executecommand_mini_two4
	CLC
	ROL A
	ROL A
	ROL A
	ROL A
	STA execute_var1_low
	LDA command_array,X
	INX
	PHX
	TAX
	LDA printchar_value,X
	PLX
	CMP #$FF
	BNE executecommand_mini_two5
	JMP executecommand_mini_two_exit
executecommand_mini_two5
	CLC
	ADC execute_var1_low
	STA execute_var1_low			; store the second byte in var1_low, now you can use those for whatever function you want
executecommand_mini_two_exit
	RTS


; multimove sub-routine
; copies things from execute_var3 to execute_var2 into execute_var1 onwards
multimove
	PHA
	PHX
	PHY
	LDA execute_var3_high			; do not try to do this if the second byte is lower than the first byte
	CMP execute_var2_high			; instead, just exit if that's the case, we don't to mess anything up
	BCC multimove_go
	BNE multimove_exit
	LDA execute_var3_low
	CMP execute_var2_low
	BCC multimove_go
	BNE multimove_exit
multimove_go
	LDA execute_var3_low			; set up sub_read and sub_write for the copying process
	STA sub_read+1
	LDA execute_var3_high
	STA sub_read+2
	LDA execute_var1_low
	STA sub_write+1
	LDA execute_var1_high
	STA sub_write+2
multimove_loop					; the actual loop
	JSR sub_read				; read from memory
	JSR sub_write				; then write immediately to memory
	LDA sub_read+2				; then compare the location to see if we are at the end of the selected section of memory
	CMP execute_var2_high
	BNE multimove_continue
	LDA sub_read+1
	CMP execute_var2_low
	BNE multimove_continue
	JMP multimove_exit			; if the sub_read is at the end of the selected memory, exit
multimove_continue				; increment both sub_read and sub_write
	INC sub_read+1
	LDA sub_read+1
	BNE multimove_next
	INC sub_read+2
multimove_next
	INC sub_write+1
	LDA sub_write+1
	BNE multimove_loop
	INC sub_write+2
	JMP multimove_loop			; start over with the loop
multimove_exit
	PLY
	PLX
	PLA
	RTS


; multifill sub-routine
; fills things from execute_var3 to execute_var2 with execute_var1_high
multifill
	PHA
	PHX
	PHY
	LDA execute_var3_high			; this is nearly a copy/paste of multimove, but instead of reading, we are only writing a single byte value
	CMP execute_var2_high
	BCC multifill_go
	BNE multifill_exit
	LDA execute_var3_low
	CMP execute_var2_low
	BCC multifill_go
	BNE multifill_exit
multifill_go
	LDA execute_var3_low
	STA sub_write+1
	LDA execute_var3_high
	STA sub_write+2
multifill_loop
	LDA execute_var1_high
	JSR sub_write				; only write, no reading here
	LDA sub_write+2
	CMP execute_var2_high
	BNE multifill_continue
	LDA sub_write+1
	CMP execute_var2_low
	BNE multifill_continue
	JMP multifill_exit			; exit at the end of the memory
multifill_continue
	INC sub_write+1
	LDA sub_write+1
	BNE multifill_loop
	INC sub_write+2
	JMP multifill_loop			; increment and loop back
multifill_exit
	PLY
	PLX
	PLA
	RTS


; audioinput sub-routine
; loads from the audio input for the entire selection area,
; if it does not fill the selection area, it will hang until 
; the reset button is pressed
; also any extra data past the selection area will not be read
; right now it only works with 1000 Hz sine wave being a long, thus 0
; and a 2000 Hz sine wave with zero volume, a short quiet, followed by a 2000 Hz sine wave being a short, thus 1
; it would run at about 880 baud with this setup
; it is also good to have two 'long' quiets beforehand to help with computation times and all that
audioinput
	PHA
	PHX
	PHY
audioinput_loop					; this is the waiting loop, waiting waiting for some audio signal
	LDA via_pa
	AND #%01000000				; reading from PA6 (I know I can use BIT instruction instead, this works though, so I'm ok with it for now)
	BEQ audioinput_loop
	LDA #$0F				; this is an arbitrary value, it will just NOP-loop 15 times
audioinput_nop_loop_one
	NOP
	NOP
	NOP
	NOP
	DEC A
	BNE audioinput_nop_loop_one
	LDX #$00				; we set X to zero because we will use it to determine if it's a short or long signal
audioinput_wait_loop
	INX
	CPX #$40 				; VERY arbitrary value here.  It works specifically for 1000 Hz long, and 2x 2000 Hz shorts (that is, a quiet and then a loud)
	BEQ audioinput_zero			; if we hit our arbitrary value before seeing a zero, it's a long (here a value of 0), jump there
	LDA via_pa
	AND #%01000000				; read from PA6
	BNE audioinput_wait_loop		; if we hit a zero early, it's a short (here a value of 1), otherwise keep looping
	LDA #%00000001				; this is a 1 value
	CLC
	ROL audio_value				; shift it into 'audio_value'
	CLC
	ADC audio_value
	STA audio_value
	INC audio_count				; count how many bits we have had
	LDA #$0F
	JMP audioinput_nop_loop_two
audioinput_zero					; this is a 0 value
	CLC
	ROL audio_value				; shift it into 'audio_value'
	INC audio_count				; count how many bits
	LDA #$0F				; another arbitrary value, another NOP-loop 15 times
audioinput_nop_loop_two
	NOP
	NOP
	NOP
	NOP
	DEC A
	BNE audioinput_nop_loop_two
	LDA audio_count
	CMP #$08				; if we got 8 bits of data, good, lets do something with it, otherwise back to the loop
	BNE audioinput_loop
	LDA execute_var1_low			; setup sub_write subroutine
	STA sub_write+1
	LDA execute_var1_high
	STA sub_write+2
	LDA audio_value
	JSR sub_write				; write byte into memory
	STZ audio_value				; zero out the values and counts
	STZ audio_count
	LDA execute_var1_high			; if we are at the end of the memory range we wanted, exit
	CMP execute_var2_high
	BNE audioinput_increment
	LDA execute_var1_low
	CMP execute_var2_low
	BNE audioinput_increment		; otherwise increment
	JMP audioinput_exit
audioinput_increment				; just increments what sub_write will have, I guess I could have incremented sub_write instead?  Eh.
	INC execute_var1_low
	LDA execute_var1_low
	BNE audioinput_loop
	INC execute_var1_high
	JMP audioinput_loop			; back to the main loop
audioinput_exit
	STZ key_counter 			; this is so cheezy, why does it mess up the keyboard?
	STZ key_release				; it's whatever, I have been doing this for any weird 'hanging' command
	STZ key_extended
	STZ key_read_pos
	STZ key_write_pos
	STZ audio_value
	STZ audio_count
	PLY
	PLX
	PLA
	RTS


; spi_eeprom_read sub-routine
; reads selected data from the EEPROM
; there is a specific configuration and commands needed for this particular EEPROM
; This one is a 25LC64 8K EEPROM, but I'm sure larger ones will act the same
; This is just like the 'write' function
spi_eeprom_read
	PHA
	PHX
	PHY
	LDA #%11111011				; says we are trying to work with SPI-EEPROM-A, that is PB2 is low, the rest are high
	STA spi_cs_enable
	JSR spi_base_disable			; disable
	JSR spi_base_delay			; delay
spi_eeprom_read_loop				; loop until done
	JSR spi_base_enable			; enable
	LDA #%00000011 ; read command		; read command
	JSR spi_base_send_byte
	LDA execute_var1_high ; high addr	; send high address
	JSR spi_base_send_byte
	LDA execute_var1_low ; low addr		; send low address
	JSR spi_base_send_byte
	JSR spi_base_receive_byte ; data	; receive data byte
	JSR spi_base_disable			; disable
	JSR spi_base_delay			; delay
	PHA
	LDA execute_var1_low
	STA sub_write+1
	LDA execute_var1_high
	STA sub_write+2
	PLA
	JSR sub_write				; write data byte into memory with sub_write
	LDA execute_var1_high
	CMP execute_var2_high
	BNE spi_eeprom_read_increment
	LDA execute_var1_low
	CMP execute_var2_low
	BNE spi_eeprom_read_increment		; increment until the end, then exit
	JMP spi_eeprom_read_exit
spi_eeprom_read_increment
	INC execute_var1_low
	BNE spi_eeprom_read_loop
	INC execute_var1_high
	JMP spi_eeprom_read_loop
spi_eeprom_read_exit
	STZ key_counter 			; this is so cheezy
	STZ key_release				; again, shouldn't need to do this, but it is safe
	STZ key_extended
	STZ key_read_pos
	STZ key_write_pos
	STZ audio_value
	STZ audio_count
	PLY
	PLX
	PLA
	RTS


; spi_eeprom_write sub-routine
; writes selected data into the EEPROM
; there is a specific configuration and commands needed for this particular EEPROM
; This one is a 25LC64 8K EEPROM, but I'm sure larger ones will act the same
; one thing I found out is that because it's only 8K, you can save $2000-$3FFF perfectly fine
; but you can also 'save' $2000-$5FFF, but it just duplicates twice over,  so really only $4000-$5FFF was saved
; same thing with 'load'
spi_eeprom_write
	PHA
	PHX
	PHY
	LDA #%11111011				; says we are trying to work with SPI-EEPROM-A, that is PB2 is low, the rest are high
	STA spi_cs_enable
	JSR spi_base_disable			; disable
	JSR spi_base_delay			; delay
	JSR spi_base_enable			; enable
	LDA #%00000001 ; status			; send status byte
	JSR spi_base_send_byte
	LDA #%00000000 ; enable writing		; this enables writing, something to do with the status flags
	JSR spi_base_send_byte
	JSR spi_base_disable			; disable
	JSR spi_base_delay
spi_eeprom_write_loop				; loop for as much memory as specified
	JSR spi_base_enable			; enable
	LDA #%00000110 ; initialize writing	; initalize writing byte
	JSR spi_base_send_byte
	JSR spi_base_disable			; disable
	JSR spi_base_delay			; delay
	JSR spi_base_enable			; enable
	LDA #%00000010 ; write command		; write command
	JSR spi_base_send_byte
	LDA execute_var1_high ; high addr	; send high address
	JSR spi_base_send_byte
	LDA execute_var1_low; low addr		; send low address
	JSR spi_base_send_byte			
	LDA execute_var1_low
	STA sub_read+1
	LDA execute_var1_high
	STA sub_read+2
	JSR sub_read ; data			; read data using sub_read
	JSR spi_base_send_byte			; send data byte
	JSR spi_base_disable			; disable
	JSR spi_base_delay			; delay
	LDA execute_var1_high
	CMP execute_var2_high
	BNE spi_eeprom_write_increment
	LDA execute_var1_low
	CMP execute_var2_low
	BNE spi_eeprom_write_increment		; increment memory location, exit when at the end
	JMP spi_eeprom_write_exit
spi_eeprom_write_increment
	INC execute_var1_low
	BNE spi_eeprom_write_loop
	INC execute_var1_high
	JMP spi_eeprom_write_loop
spi_eeprom_write_exit
	STZ key_counter 			; this is so cheezy
	STZ key_release				; shouldn't need to do it, but it is safer
	STZ key_extended
	STZ key_read_pos
	STZ key_write_pos
	STZ audio_value
	STZ audio_count
	PLY
	PLX
	PLA
	RTS


; spi_sdcard_init sub-routine
; initializes sdcard
spi_sdcard_init
	PHA
	PHX
	PHY
	LDA #%11101111				; says we are trying to work with SPI SD CARD, that is PB4 is low, the rest are high
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
	JSR spi_base_disable			; disable sdcard
	CMP #$01				; expecting $01, not initialized
	BEQ spi_sdcard_init_continue1
	JMP spi_sdcard_init_error		; else, error!
spi_sdcard_init_continue1
	PLY
	PLX
	LDA #ascii_period			; print a period for each success
	JSR printchar
	PHX
	PHY
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
	JSR spi_base_disable			; disable sdcard
	CMP #$01				; expecting $01, not initialized
	BEQ spi_sdcard_init_continue2
	JMP spi_sdcard_init_error		; else, error!
spi_sdcard_init_continue2
	JSR spi_base_enable			; enable
	JSR spi_base_receive_byte		; 32-bit return value, ignored
	JSR spi_base_receive_byte
	JSR spi_base_receive_byte
	JSR spi_base_receive_byte
	JSR spi_base_disable
spi_sdcard_init_acmd41				; this is the ACMD41 loop
	PLY
	PLX
	LDA #ascii_period			; print a period for each loop
	JSR printchar
	PHX
	PHY
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
	JSR spi_base_disable			; disable sdcard
	CMP #$01				; expecting $01, not initialized
	BEQ spi_sdcard_init_continue3
	JMP spi_sdcard_init_error		; else, error!
spi_sdcard_init_continue3
	PLY
	PLX
	LDA #ascii_period			; print a period for each loop
	JSR printchar
	PHX
	PHY
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
	JSR spi_base_disable			; disable sdcard
	CMP #$00				; $00 is initialized finally
	BEQ spi_sdcard_init_continue5
	CMP #$01				; $01 is still not initialized, back to loop
	BEQ spi_sdcard_init_continue4
	JMP spi_sdcard_init_error		; else, error!
spi_sdcard_init_continue4
	JSR spi_base_longdelay
	JMP spi_sdcard_init_acmd41
spi_sdcard_init_continue5
	JSR spi_base_longdelay			; delay
	JMP spi_sdcard_init_exit		; at this point, it is initialized, good!
spi_sdcard_init_error
	PLY
	PLX
	PHA
	LDA #ascii_exclamation			; if errors, print exclamation mark where cursor used to be
	JSR printchar				; and also print what was in the accumlator
	PLA
	PHA	
	PHX
	TAX
	LDA printchar_key_high,X
	PLX
	JSR printchar
	PLA
	PHX
	TAX
	LDA printchar_key_low,X
	PLX
	JSR printchar
	PHX
	PHY
spi_sdcard_init_exit
	PLY
	PLX
	PLA
	RTS


; spi_sdcard_read sub-routine
; reads 512 bytes from sdcard
; it reads from execute_var3 on the SD card (being blocks of 256 bytes, not just byte addresses), 
; and puts them into execute_var1 in the computer's memory (being actual byte memory addresses)
spi_sdcard_read
	PHA
	PHX
	PHY
	LDA #%11101111				; says we are trying to work with SPI SD CARD, that is PB4 is low, the rest are high
	STA spi_cs_enable
	JSR spi_base_pump			; pump clock 80 times
	JSR spi_base_longdelay			; delay
	JSR spi_base_enable			; enable sdcard
	LDA #$51				; send CMD17 (read block)
	JSR spi_base_send_byte
	LDA #$00
	JSR spi_base_send_byte
	LDA execute_var3_high
	JSR spi_base_send_byte
	LDA execute_var3_low
	AND #%11111110
	JSR spi_base_send_byte
	LDA #$00
	JSR spi_base_send_byte
	LDA #$01
	JSR spi_base_send_byte
	JSR spi_base_waitresult			; wait until non-$FF result is read
	CMP #$00				; expecting $00, success
	BEQ spi_sdcard_read_continue1
	JMP spi_sdcard_read_error		; else, error!
spi_sdcard_read_continue1
	PLY
	PLX
	LDA #ascii_period			; print a period for each loop
	JSR printchar
	CPX #$50				; if past column 80, start over
	BCC spi_sdcard_read_continue3
	LDX #$00
	LDA #ascii_space
spi_sdcard_read_continue2
	JSR printchar
	CPX #$00
	BNE spi_sdcard_read_continue2
	LDA #ascii_period
	JSR printchar
spi_sdcard_read_continue3
	PHX
	PHY
	JSR spi_base_waitresult			; wait until non-$FF result is read
	CMP #$FE				; expecting $FE, success
	BEQ spi_sdcard_read_continue4
	JMP spi_sdcard_read_error		; else, error!
spi_sdcard_read_continue4
	PLY
	PLX
	LDA #ascii_period			; print a period for each loop
	JSR printchar
	CPX #$50				; if past column 80, start over
	BCC spi_sdcard_read_continue6
	LDX #$00
	LDA #ascii_space
spi_sdcard_read_continue5
	JSR printchar
	CPX #$00
	BNE spi_sdcard_read_continue5
	LDA #ascii_period
	JSR printchar
spi_sdcard_read_continue6
	PHX
	PHY
	LDA execute_var1_low			; start writing at execute_var3
	STA sub_write+1
	LDA execute_var1_high
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
	PLY
	PLX
	PHA
	LDA #ascii_exclamation			; if errors, print exclamation mark where cursor used to be
	JSR printchar				; and also print what was in the accumlator
	PLA
	PHA	
	PHX
	TAX
	LDA printchar_key_high,X
	PLX
	JSR printchar
	PLA
	PHX
	TAX
	LDA printchar_key_low,X
	PLX
	JSR printchar
	PHX
	PHY
spi_sdcard_read_exit
	PLY
	PLX
	PLA
	RTS


; spi_base_delay sub-routine
; short delay for spi stuff
; I could delay in other ways, but hey, this works
spi_base_delay
	PHA
	PHX
	PHY
	LDA #$FF
spi_base_delay_loop
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	DEC A
	CMP #$00
	BNE spi_base_delay_loop
	PLY
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
	LDX #$FF
	LDY #$02
spi_base_longdelay_loop
	NOP
	NOP
	NOP
	NOP
	DEC A
	CMP #$00
	BNE spi_base_longdelay_loop
	DEX
	CPX #$00
	BNE spi_base_longdelay_loop
	DEY
	CPY #$00
	BNE spi_base_longdelay_loop
	PLY
	PLX
	PLA
	RTS


spi_base_enable
	PHA
	LDA spi_cs_enable
	AND #%01111100				; this enables only whatever CS lines were designated in spi_cs_enable
	STA via_pb
	PLA
	RTS

spi_base_disable
	PHA
	LDA #%01111100				; this disables ALL SPI modules
	STA via_pb
	PLA
	RTS

spi_base_send_zero
	LDA spi_cs_enable
	AND #%01111100				; already enabled, send zero on MOSI
	STA via_pb
	INC via_pb				; INC/DEC to trigger the clock
	DEC via_pb
	RTS

spi_base_send_one
	LDA spi_cs_enable
	AND #%01111100				; already enabled, send one on MOSI
	CLC
	ADC #%00000010
	STA via_pb
	INC via_pb				; INC/DEC to trigger the clock
	DEC via_pb
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
	LDA via_pb
	AND #%10000000				; MISO is PB7				
	INC via_pb				; INC/DEC to cycle clock
	DEC via_pb
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
	CMP #%10000000				; compare with a 1 bit
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

spi_base_waitresult				; will keep reading bytes as long as $FF,
	JSR spi_base_receive_byte		; then will exit with value in accumulator
	CMP #$FF
	BEQ spi_base_waitresult
	RTS

spi_base_pump					; this pumps the clock a lot while everything is disabled
	PHA
	LDA #%01111110				; both CS and MOSI must be high to work!!!
	STA via_pb				
	JSR spi_base_longdelay			; delay
	LDA #$50
spi_base_pump_loop				; pump sclk 80 times while sdcard is disabled
	INC via_pb
	DEC via_pb
	DEC A
	BNE spi_base_pump_loop
	PLA
	RTS


; copypicture, NOT a sub-routine
; just a place in memory to copy stuff
; and then infinite loop
; you MUST press the reset button to get out of this
; purely for demo purposes
; this just copies all of user RAM into video RAM
copypicture
	LDA #$00
	STA sub_write+1
	LDA #>screen
	STA sub_write+2
	LDA #$00
	STA sub_read+1
	LDA #$00 				; these $00's are because we are looking at the beginning of user RAM
	STA sub_read+2
copypicture_loop
	JSR sub_read
	JSR sub_write
	INC sub_read+1
	BNE copypicture_next
	INC sub_read+2
copypicture_next
	INC sub_write+1
	BNE copypicture_loop
	INC sub_write+2
	BNE copypicture_loop
copypicture_inf					; literally just wait around in an infinite loop.  Must use a hard reset to get out.  Again, only for demo purposes.
	JMP copypicture_inf


; clearscreen sub-routine
; just like 'copypicture' but writing $00 to the video memory
clearscreen
	PHA
	PHX
	PHY
	LDY #>screen
	LDX #$00
	LDA #$00
clearscreen_loop
	STX sub_write+1
	STY sub_write+2
	JSR sub_write				; write $00 to the video memory
	INX
	CPX #$00
	BNE clearscreen_loop
	INY
	CPY #$FF
	BNE clearscreen_loop			; exit when completely through video memory
	PLY
	PLX
	PLA
	RTS


; interrupts and vectors

	.ORG $F000

; the IRQ interrupt looks for keyboard clock/data input, and stores it in the buffer.  That is it.
; this needs to be as short as possible, I have had issues in the past where it was too long and then ignoring some of the key input signals
vector_irq
	PHA
	LDA via_pa
	AND #%10000000				; read PA7
	CLC	
	ROR key_code				; shift key_code
	CLC
	ADC key_code				; add the PA7 bit into key_code
	STA key_code
	INC key_counter				; increment key_counter
	LDA key_counter
	CMP #$09 ; data ready			; 1 start bit, 8 data bits = 9 bits until real data ready
	BNE vector_irq_check
	LDA key_code
	PHX
	LDX key_write_pos
	STA key_array,X				; store in key_array
	PLX
	INC key_write_pos			; increment the position
	JMP vector_irq_exit			; and exit
vector_irq_check
	CMP #$0B ; reset counter		; 1 start bit, 8 data bits, 1 parity bit, 1 stop bit = 11 bits to complete a full signal
	BNE vector_irq_exit
	STZ key_counter				; reset the counter
vector_irq_exit
	PLA
	RTI

; does nothing here
vector_nmi
	NOP
	RTI

vectors
	.ORG $FFFA
	.WORD vector_nmi
	.WORD vector_reset
	.WORD vector_irq


