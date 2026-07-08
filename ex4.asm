; Architecture: x86-64
; Assembler syntax: Intel syntax
; regs for x86-32: EAX, EBX, ECX, EDX, EBP, ESP
; regs for x86-64: RAX, RBX, RCX, RDX, RBP, RSP, RDI, RSI, R8-R15

extern printf
extern exit
global main

section .data
    msg2 DB "After HW", 0
    msg  DB "Hello World!", 0
    fmt  DB "output is: %s %s", 10, 0    ; 10 => add \n

section .text
main:
    MOV RDI, fmt       ; 1st argument: format string
    MOV RSI, msg       ; 2nd argument: "Hello World!"
    MOV RDX, msg2      ; 3rd argument: "After HW"
    CALL printf
    MOV RDI, 1         ; exit status
    CALL exit

; old way of doing it for linux x86-32bit cuz PUSH uses the stack (RAM) instead of registers (RDI...) :
;   PUSH msg2
;   PUSH msg      
;   PUSH fmt
;   CALL printf
;   PUSH 1
;   CALL exit


; CPU
; |----------------|
; | Registers      |
; |                |
; | EAX/RDI        |
; | ESP -----------|----------------+
; | EBP            |                |
; |----------------|                |
;                                   v
;                              RAM (Memory)
;                          |----------------|
;                          |     Stack      |
;                          | pointer vars   |
;                          | local vars     |
;                          | saved regs     |
;                          | return addr    |
;                          |----------------|
;                          |     Heap       |
;                          | malloc data    |
;                          | pointer values |
;                          |----------------|
; The register ESP/RSP contains an address in RAM where the top of the stack currently is.
