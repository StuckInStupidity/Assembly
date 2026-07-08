@ Architecture: ARM (32-bit ARM)
@ Assembler syntax: GNU AS ARM syntax
@ regs for ARM32: R0, R1, R2, R7
@ regs for ARM64: X0, X1, X2, X8

.global _start
_start:
	MOV R0, #1           @ Put value 1 into R0 => R0 = 1 => file descriptor used is stdout
	LDR R1, =message     @ also argument needed for syscall
	LDR R2, =len         @ also argument needed for syscall
	MOV R7, #4           @ Put syscall number 4 into R7 => ARM Linux syscall 4 = sys_write
	SWI 0                @ enter kernel mode and execute the syscall, the return value from the syscall is placed in R0

	MOV R7, #1           @ sys_exit
	SWI 0

@ originally, the value after SWI (SWI #X) was used to identify the requested service/interrupt
@ this value is no longer used to select the syscall; it is usually set to 0, and the syscall number is provided in register R7 instead

.data
message:
	.asciz "Hello World!\n" @ "asciz" creates a null-terminated string

len = .-message          @ Current address(".") - address of message(message) = # bytes of the string
