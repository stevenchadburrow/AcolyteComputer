; Testing Code for the SDcard

; First, plug in the Micro SDcard through a USB adapter.

; Second, run 
; sudo fdisk -l
; to see what drive it is on.  Let's assume /dev/sdd for this one.

; Third, run
; ~/dev65/bin/as65 SDcardCode.asm ; ./Parser.o SDcardCode.lst SDcardCode.bin 1024 0 1024 0
; which compiles the assembly code, this creates a 1K file, can of course go larger

; Fourth, run
; sudo dd if=SDcardCode.bin of=/dev/sdd bs=1M conv=fsync

; Because this particular one is the bootloader code, it will load upon boot.
; Another set of code that looks identical in nature (using .org $00400) is needed for
; loading SDcard from menu.  To combine these you need to run
; cat SDcardCode1.bin > Temp.bin ; cat SDcardCode2.bin >> Temp.bin

; Then you can run
; sudo dd if=Temp.bin of=/dev/sdd bs=1M conv=fsync

; Then just pull out the SDcard and pop it into the Acolyte Computer!

	.65C02

	.ORG $00400 ; this is the bootloaded code, will be at $0000 on the SDcard

	PHA
	PHX

	LDX #$00
loop
	LDA text,X
	CMP #$FF
	BEQ exit
	JSR $0360 ; printchar
	INX
	BNE loop
exit
	
	PLX
	PLA

	RTS ; go back to normal operations

text
	.BYTE "Acolyte "
	.BYTE "Computer"
	.BYTE $0D
	.BYTE $FF

