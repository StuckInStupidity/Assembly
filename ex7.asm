; Architecture: x86-64
; Assembler syntax: Intel syntax
; regs for x86-32: EAX, EBX, ECX, EDX, EBP, ESP
; regs for x86-64: RAX, RBX, RCX, RDX, RBP, RSP, RDI, RSI, R8-R15

global _start

section .data
	pathname DB "file.txt", 0
	
	nl db 10
	prompt db "Your name ? "
	len equ $ - prompt
	hello db "Hello "
	len2 equ $ - hello

section .bss
	buffer resb 1024

section .text
_start:
	mov rax, 2             ; sys_open
	mov rdi, pathname
	mov rsi, 0             ; read-only flag
	mov rdx, 0             ; mode not used for read only
	syscall
	cmp rax, 0             ; file could not be opened if rax is negative
	jl end
	mov r12, rax           ; save file descriptor

	mov rax, 0             ; sys_read
	mov rdi, r12
	mov rsi, buffer
	mov rdx, 1024
	syscall
	mov r13, rax           ; to keep the nb of bytes read

	mov rax, 1             ; sys_write
	mov rdi, 1             ; file descriptor : 1 => stdout
	mov rsi, buffer
	mov rdx, r13
	syscall

	mov rax, 3             ; sys_close
	mov rdi, r12
	syscall

chat_loop:
	mov rax, 1
	mov rdi, 1
	mov rsi, prompt
	mov rdx, len
	syscall
	
	mov rax, 0
	mov rdi, 0             ; stdin
	mov rsi, buffer
	mov rdx, 1024
	syscall

	mov r13, rax

	cmp r13, 5    ; quit + newline
	jne func
	cmp byte [buffer], 'q'
	jne func
	cmp byte [buffer+1], 'u'
	jne func
	cmp byte [buffer+2], 'i'
	jne func
	cmp byte [buffer+3], 't'
	jne func
	jmp end

func:
	mov rax, 1
	mov rdi, 1
	mov rsi, hello
	mov rdx, len2
	syscall

	mov rax, 1
	mov rdi, 1
	mov rsi, buffer
	mov rdx, r13
	syscall
	
	mov rax, 1
	mov rdi, 1
	mov rsi, nl
	mov rdx, 1
	syscall
	jmp chat_loop
	
end:
	mov rax, 60            ; sys_exit
	mov rdi, 0             ; exit code 0
	syscall
