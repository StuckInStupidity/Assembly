; Architecture: x86-64
; Assembler syntax: Intel syntax
; regs for x86-32: EAX, EBX, ECX, EDX, EBP, ESP
; regs for x86-64: RAX, RBX, RCX, RDX, RBP, RSP, RDI, RSI, R8-R15

global main

section .data              ; static memory region used to store global and static variables
	list DD 1,4,6,8
	len = .-list

section .text
main:
	MOV eax, 0
	MOV ecx, 0
loop:
	CMP eax, len
	JE end                            ; (JE, JNE, JL, JG, JLE, JGE)
	MOV ebx, [list + eax]             ; memory access (mov in ebx, the value stored at address list + eax)
	ADD ecx, ebx
	ADD eax, 4                        ; if it was DB we could have used INC eax
	JMP loop
end:
	MOV eax, 1     ; syscall code fro exit
	MOV ebx, ecx   ; exit code = sum
	INT 80h        ; trigger kernel mode
	
