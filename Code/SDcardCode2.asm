; Testing Code for the SDcard

; First, plug in the Micro SDcard through a USB adapter.

; Second, run 
; sudo fdisk -l
; to see what drive it is on.  Let's assume /dev/sdc for this one.

; Third, run
; ~/dev65/bin/as65 SDcardCode.asm ; ./Parser.o SDcardCode.lst SDcardCode.bin 1024 0 262144 0
; which compiles the assembly code, this creates a 1K file, can of course go larger

; Fourth, run
; sudo dd if=SDcardCode.bin of=/dev/sdc bs=1M conv=fsync

; Then just pull out the SDcard and pop it into the Acolyte Computer!

	.65C02

	.ORG $00400 ; this is the actual memory location, even on the SDcard

	PHA
	PHX
	PHY

	LDA #"T"
	JSR $0360
	LDA #"e"
	JSR $0360
	LDA #"s"
	JSR $0360
	LDA #"t"
	JSR $0360
	LDA #"i"
	JSR $0360
	LDA #"n"
	JSR $0360
	LDA #"g"
	JSR $0360
	LDA #"."
	JSR $0360
	JSR $0360
	JSR $0360
	LDA #$0D ; carriage return
	JSR $0360 ; printchar

wait
	JSR $0368 ; inputchar
	CMP #$00
	BEQ wait
	CMP #$1B ; escape
	BNE wait

exit
	LDA #$FF
	STA $0308 ; key_alt_control
	LDA #$0C ; form feed
	JSR $0360 ; printchar
	STZ $0308 ; key_alt_control

	PLY
	PLX
	PLA
	RTS
