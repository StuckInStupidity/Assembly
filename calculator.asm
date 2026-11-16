; sans ordre de priorite (evaluation de gauche a droite)
; EX :
; Veuillez saisir une expression :
; 2*5-5*2+18/2
; Resultat :
; 14
;
; Convention : les fonctions de test/conversion renvoient CF=0 si OK, CF=1 si erreur.
; Les registres sont sauvegardes (comme les movem.l de la version 68000),
; sauf ceux qui portent un resultat (eax) .
; rsi joue le role de a0 (pointeur sur chaine).

%define SYS_READ    0
%define SYS_WRITE   1
%define SYS_EXIT    60
%define BUFSIZE     64
%define MAXVAL      32767           ; meme limite que IsMaxError (16 bits signe)

section .data
msgPrompt   db "Veuillez saisir une expression :", 10, 0
msgResult   db "Resultat :", 10, 0
msgError    db "Erreur", 10, 0

section .bss
sBuffer     resb BUFSIZE
charBuf     resb 1

section .text
global _start

_start:
    lea     rsi, [rel msgPrompt]
    call    Print

    lea     rsi, [rel sBuffer]
    call    GetInput
    call    RemoveSpace
    call    GetExpr
    jc      .error

    push    rax
    lea     rsi, [rel msgResult]
    call    Print
    pop     rax
    call    PrintNum
    xor     edi, edi
    jmp     .exit

.error:
    lea     rsi, [rel msgError]
    call    Print
    mov     edi, 1

.exit:
    mov     eax, SYS_EXIT
    syscall

;===========================================
; GetInput : lit une ligne sur stdin dans le buffer pointe par rsi
GetInput:
    push    rax
    push    rcx
    push    rdx
    push    rdi
    push    r11
    push    rsi

    xor     eax, eax                ; SYS_READ
    xor     edi, edi                ; stdin
    mov     edx, BUFSIZE - 1
    syscall
    test    rax, rax
    jg      .ok
    xor     eax, eax                ; erreur / EOF : chaine vide
.ok:
    mov     byte [rsi + rax], 0

    mov     rcx, rsi
.scan:
    mov     dl, [rcx]
    test    dl, dl
    jz      .quit
    cmp     dl, 10
    je      .cut
    inc     rcx
    jmp     .scan
.cut:
    mov     byte [rcx], 0

.quit:
    pop     rsi
    pop     r11
    pop     rdi
    pop     rdx
    pop     rcx
    pop     rax
    ret

;===========================================
; PrintChar : affiche le caractere dans al
PrintChar:
    push    rax
    push    rcx
    push    rdx
    push    rsi
    push    rdi
    push    r11

    mov     [rel charBuf], al
    mov     eax, SYS_WRITE
    mov     edi, 1
    lea     rsi, [rel charBuf]
    mov     edx, 1
    syscall

    pop     r11
    pop     rdi
    pop     rsi
    pop     rdx
    pop     rcx
    pop     rax
    ret

;===========================================
; Print : affiche la chaine (terminee par 0) pointee par rsi
Print:
    push    rax
    push    rsi
.loop:
    mov     al, [rsi]
    inc     rsi
    test    al, al
    jz      .quit
    call    PrintChar
    jmp     .loop
.quit:
    pop     rsi
    pop     rax
    ret

;===========================================
; PrintNum : affiche eax (signe) en decimal, suivi d'un retour a la ligne
PrintNum:
    push    rax
    push    rbx
    push    rcx
    push    rdx

    mov     ebx, 10
    xor     ecx, ecx
    test    eax, eax
    jns     .conv
    push    rax
    mov     al, '-'
    call    PrintChar
    pop     rax
    neg     eax
.conv:
    xor     edx, edx
    div     ebx
    add     dl, '0'
    push    rdx
    inc     ecx
    test    eax, eax
    jnz     .conv
.out:
    pop     rdx
    mov     al, dl
    call    PrintChar
    dec     ecx
    jnz     .out

    mov     al, 10
    call    PrintChar

    pop     rdx
    pop     rcx
    pop     rbx
    pop     rax
    ret

;===========================================
; StrLen : rsi = chaine, retour eax = longueur
StrLen:
    push    rsi
    xor     eax, eax
.loop:
    cmp     byte [rsi], 0
    je      .quit
    inc     rsi
    inc     eax
    jmp     .loop
.quit:
    pop     rsi
    ret

;===========================================
; Atoui : rsi = chaine de chiffres, retour eax = valeur
Atoui:
    push    rbx
    push    rsi
    xor     eax, eax
.loop:
    movzx   ebx, byte [rsi]
    inc     rsi
    test    bl, bl
    jz      .quit
    sub     ebx, '0'
    imul    eax, eax, 10
    add     eax, ebx
    jmp     .loop
.quit:
    pop     rsi
    pop     rbx
    ret

;===========================================
; RemoveSpace : supprime les espaces de la chaine rsi (in place)
RemoveSpace:
    push    rax
    push    rsi
    push    rdi
    mov     rdi, rsi
.loop:
    mov     al, [rsi]
    inc     rsi
    cmp     al, ' '
    je      .loop
    mov     [rdi], al
    inc     rdi
    test    al, al
    jnz     .loop
    pop     rdi
    pop     rsi
    pop     rax
    ret

;============================================
; IsCharError : CF=1 si la chaine rsi contient autre chose que des chiffres
IsCharError:
    push    rax
    push    rsi
.loop:
    mov     al, [rsi]
    inc     rsi
    test    al, al
    jz      .false
    cmp     al, '0'
    jb      .true
    cmp     al, '9'
    jbe     .loop
.true:
    stc
    jmp     .quit
.false:
    clc
.quit:
    pop     rsi
    pop     rax
    ret

;=============================================
; IsMaxError : CF=1 si le nombre (rsi) depasse MAXVAL (32767)
IsMaxError:
    push    rax
    call    StrLen
    cmp     eax, 5
    ja      .true
    call    Atoui
    cmp     eax, MAXVAL
    ja      .true
    clc
    jmp     .quit
.true:
    stc
.quit:
    pop     rax
    ret

;===============================================
; Convert : rsi = chaine, retour eax = valeur, CF=1 si erreur
Convert:
    cmp     byte [rsi], 0
    je      .false
    call    IsCharError
    jc      .false
    call    IsMaxError
    jc      .false
    call    Atoui
    clc
    ret
.false:
    stc
    ret

;===============================================
; NextOp : avance rsi jusqu'au prochain operateur ou a la fin de chaine
NextOp:
    push    rdx
.loop:
    mov     dl, [rsi]
    test    dl, dl
    jz      .quit
    cmp     dl, '+'
    je      .quit
    cmp     dl, '-'
    je      .quit
    cmp     dl, '*'
    je      .quit
    cmp     dl, '/'
    je      .quit
    inc     rsi
    jmp     .loop
.quit:
    pop     rdx
    ret

;===============================================
; GetNum : rsi pointe sur un nombre.
; Retour : eax = valeur, rsi pointe sur l'operateur suivant (ou le 0 final),
;          CF=1 si erreur
GetNum:
    push    rbx
    push    rdi

    mov     rdi, rsi                ; debut du nombre
    call    NextOp                  ; rsi -> operateur ou fin
    mov     bl, [rsi]               ; on save l'operateur
    mov     byte [rsi], 0           ; et on termine le nombre par 0
    push    rsi                     ; position de l'operateur
    mov     rsi, rdi
    call    Convert                 ; eax + CF
    pop     rsi                     ; (pop/mov ne touchent pas aux flags)
    mov     [rsi], bl               ; on remet l'operateur

    pop     rdi
    pop     rbx
    ret

;================================================
; GetExpr : rsi = expression sans espaces, evaluee de gauche a droite
; Retour : eax = resultat (signe), CF=1 si erreur (syntaxe, trop grand, /0)
GetExpr:
    push    rbx
    push    rcx
    push    rdx
    push    rsi

    call    GetNum
    jc      .false
    mov     ebx, eax

.loop:
    movzx   ecx, byte [rsi]
    test    cl, cl
    jz      .true
    inc     rsi
    call    GetNum
    jc      .false
    cmp     cl, '+'
    je      .add
    cmp     cl, '-'
    je      .sub
    cmp     cl, '*'
    je      .mul

    test    eax, eax
    jz      .false
    mov     ecx, eax
    mov     eax, ebx
    cdq
    idiv    ecx
    mov     ebx, eax
    jmp     .loop

.add:
    add     ebx, eax
    jmp     .loop
.sub:
    sub     ebx, eax
    jmp     .loop
.mul:
    imul    ebx, eax
    jmp     .loop

.false:
    stc
    jmp     .quit
.true:
    mov     eax, ebx
    clc
.quit:
    pop     rsi
    pop     rdx
    pop     rcx
    pop     rbx
    ret
