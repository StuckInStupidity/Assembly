; Architecture: x86 (32-bit)
; Assembler syntax: Intel syntax
; regs for x86-32: EAX, EBX, ECX, EDX, EBP, ESP
; regs for x86-64: RAX, RBX, RCX, RDX, RBP, RSP, RDI, RSI, R8-R15

global _start

section .text
addTwo:
    PUSH ebp
    MOV ebp, esp        ; EBP = ESP (EBP becomes a stable reference for this stack frame) 
    MOV eax, [ebp + 8]
    MOV ebx, [ebp + 12]
    ADD eax, ebx        ; eax = 5
    POP ebp             ; POP ebp => restores old ebp (MOV ebp, [esp]) and update pointeur ESP -> RET addr (ADD esp, 4)
    RET                 ; pops the return address into EIP and resumes execution after CALL

; old ebp still exist but will eventually be overwritten by a push

_start:
    PUSH 4
    PUSH 1
    CALL addTwo
    MOV ebx, eax        ; eax = 5 => ebx = exit status (arg for syscall)
    MOV eax, 1          ; syscall number for exit
    INT 80h             ; call kernel



;     Higher addresses
;           |
;           v
; |---------------------|
; | EBP +12 : arg2 = 4  | <- créé dans start par PUSH 4
; |---------------------|
; | EBP + 8 : arg1 = 1  | <- créé dans start par PUSH 1
; |---------------------|
; | EBP + 4 : RET addr  | <- créé automatiquement par CALL addTwo
; |---------------------|
; | EBP + 0 : old EBP   | <- créé dans addTwo par PUSH EBP
; |---------------------| <- esp pointe par défault sur le current "top" du stack
;           ^
;           |
;      Lower addresses

; ESP tells you where the top of the stack currently is. EBP tells you where this function's stack frame starts. 
; If we can guarantee ESP will not move, we use ESP directly and save EBP, one more register for calculation.
