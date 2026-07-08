@ Architecture: ARM (32-bit ARM)
@ Assembler syntax: GNU AS ARM syntax
@ regs for ARM32: R0, R1, R2, R7
@ regs for ARM64: X0, X1, X2, X8

.global _start
.equ endlist, list + 20    @ 5 elements × 4 bytes
_start:
	LDR R0, =list
	LDR R3, =endlist
	MOV R2, #0
loop:
	CMP R0, R3
	BEQ exit
	LDR R1, [R0], #4 
	ADD R2, R2, R1
	B loop
exit:
	MOV R7, #1
	SWI 0

.data
list:
	.word 1,2,3,4,5   @ 1 is at offset 0 => 5 is at offset 16

@ LDR R1, [R0, #4]    @ just offset access, address unchanged
@ LDR R1, [R0, #4]!   @ move R0 pointer by +4 then load from this new address
@ LDR R1, [R0], #4    @ load from the current address then move R0 pointer by +4
