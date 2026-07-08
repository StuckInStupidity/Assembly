; Architecture: x86-64
; Assembler syntax: Intel syntax
; regs for x86-32: EAX, EBX, ECX, EDX, EBP, ESP
; regs for x86-64: RAX, RBX, RCX, RDX, RBP, RSP, RDI, RSI, R8-R15

; DB (1 Byte)
; DW (2 bytes)
; DD (4 bytes)
; DQ (8 bytes)
; DT (10 bytes)

; EAX (32 bits)
; +----------------+----------------+
; |      high      |      low       |
; |   16 bits      |    16 bits     |
; +----------------+----------------+
;                      AX (16 bits)
;                   +--------+------+
;                   |   AH   |  AL  |
;                   | 8 bits |8 bits|
;                   +--------+------+
; EAX -> full 32-bit register
; AX -> lower 16 bits of EAX
; AH -> upper 8 bits of AX
; AL -> lower 8 bits of AX
; same for b,c,d

global main

section .text
main:
	MOV eax, 128
	MOV ebx, 80h          ; 128
	MOV ecx, 10000000b    ; 00000000 00000000 00000000 10000000 = 128
	NOT ecx               ; ecx = 11111111 11111111 11111111 01111111 (signed : -129, unsigned : alot lol)
	AND ecx, 10010110b    ; ecx = 00000000 00000000 00000000 00010110 = 22
	ADD eax, ecx          ; eax = 150, ecx = 22;
	SHR eax, 1            ; eax = 75    (use SAR for signed numbers)
	SHL ecx, 3            ; ecx = 176
	SUB ecx, ebx          ; ecx = 48
	MOV eax, 8
	MOV ebx, 5
	MUL ebx               ; eax = 40, edx = 0  (use IMUL for signed numbers)
	MOV edx, 0
	INC ebx               ; ebx = 6
	DIV ebx               ; eax = 6, edx = 4  (use IDIV for signed numbers and add CDQ instruction before using it)
	INT 80h
	
; AND, OR, NOT act as AND, OR, NOT tables between each bit of the same weight

; CF	Carry Flag	        Unsigned overflow/carry out of the most significant bit
; OF	Overflow Flag	        Signed overflow
; ZF	Zero Flag	        Result is zero
; SF	Sign Flag	        Result is negative (copies the most significant bit)
; PF	Parity Flag	        Number of 1 bits in the low byte is even
; AF	Auxiliary Carry Flag	Carry from bit 3 to bit 4 (used mainly for BCD)
