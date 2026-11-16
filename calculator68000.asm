	org $0

vector_000	dc.l $ffb500
vector_001	dc.l Main

	org $500

Main	movea.l #sPrompt,a0
	jsr Print
	movea.l #sBuffer,a0
	jsr GetInput
	jsr RemoveSpace
	jsr GetExpr
	bne \error
	movea.l #sResult,a0
	jsr Print
	jsr PrintNum
	bra \end
\error	movea.l #sError,a0
	jsr Print
\end	illegal

;===========================================

StrLen	movem.l a0,-(a7)
	clr.l d0
\loop	tst.b (a0)+
	beq \quit
	addq.l #1,d0
	bra \loop
\quit	movem.l (a7)+,a0
	rts

;===========================================

Atoui	movem.l d1/a0,-(a7)
	clr.l d0
	clr.l d1
\loop	move.b (a0)+,d1
	beq \quit
	subi.b #'0',d1
	mulu.w #10,d0
	add.l d1,d0
	bra \loop
\quit	movem.l (a7)+,d1/a0
	rts

;===========================================

Print	movem.l d0/a0,-(a7)
\loop	move.b (a0)+,d0
	beq \quit
	jsr PrintChar
	bra \loop
\quit	movem.l (a7)+,d0/a0
	rts

;===========================================

PrintChar	movem.l d0-d1,-(a7)
	move.b d0,d1
	moveq #6,d0
	trap #15              ; sorte d'appel systeme
	movem.l (a7)+,d0-d1
	rts

;===========================================

GetInput	movem.l d0-d1/a0-a1,-(a7)
	movea.l a0,a1
	moveq #2,d0
	trap #15              ; sorte d'appel systeme
	movem.l (a7)+,d0-d1/a0-a1
	rts

;===========================================
; Mul32 : d1 = d1 * d0   (d1 signe 32 bits, d0 entre 0 et 32767)
Mul32	movem.l d2,-(a7)
	move.l d1,d2
	swap d2                    ; d2.w = mot haut de d1 (signe)
	muls.w d0,d2
	swap d2
	clr.w d2                   ; d2 = (haut*d0) << 16
	mulu.w d0,d1               ; mot bas (non signe) * d0
	add.l d2,d1
	movem.l (a7)+,d2
	rts

;===========================================
; Div32 : division NON SIGNEE d1 / d0 (d0 entre 1 et 65535)
; retour d1 = quotient, d2 = reste
Div32	movem.l d3,-(a7)
	move.l d1,d2
	swap d2
	andi.l #$ffff,d2           ; d2 = mot haut de d1
	divu.w d0,d2               ; d2 = reste:quotient1
	moveq #0,d3
	move.w d2,d3
	swap d3                    ; d3 = quotient1 << 16
	move.w d1,d2               ; d2 = reste:mot bas de d1
	divu.w d0,d2               ; d2 = reste:quotient2
	move.w d2,d3               ; d3 = quotient complet
	swap d2
	andi.l #$ffff,d2           ; d2 = reste
	move.l d3,d1
	movem.l (a7)+,d3
	rts

;===========================================

PrintNum	movem.l d0-d3,-(a7)
	move.l d0,d1
	bpl \pos
	move.b #'-',d0
	jsr PrintChar
	neg.l d1
\pos	moveq #0,d3 
	moveq #10,d0
\div	jsr Div32
	move.w d2,-(a7)
	addq.b #1,d3
	tst.l d1
	bne \div
\out	move.w (a7)+,d0
	addi.b #'0',d0
	jsr PrintChar
	subq.b #1,d3
	bne \out
	move.b #13,d0
	jsr PrintChar
	move.b #10,d0
	jsr PrintChar
	movem.l (a7)+,d0-d3
	rts

;===========================================

RemoveSpace	movem.l d0/a0/a1,-(a7)
	movea.l a0,a1
\loop	move.b (a0)+,d0
	cmpi.b #' ',d0
	beq \loop
	move.b d0,(a1)+
	bne \loop
\quit	movem.l (a7)+,d0/a0/a1
	rts

;============================================

IsCharError	movem.l d0/a0,-(a7)
\loop	move.b (a0)+,d0
	beq \false
	cmpi.b #'0',d0
	blo \true
	cmpi.b #'9',d0
	bls \loop
; ============================
; 7 6 5 4 3 2 1 0
;CCR :  X N Z V C
;=============================
\true	ori.b #%00000100,ccr       ; put zero flag at 1
	bra \quit
\false	andi.b #%11111011,ccr      ; put zero flag at 0
\quit	movem.l (a7)+,d0/a0
	rts

;=============================================

IsMaxError	movem.l d0/a0,-(a7)
	jsr StrLen
	cmpi.l #5,d0
	bhi \true
	blo \false
	cmpi.b #'3',(a0)+
	bhi \true
	blo \false
	cmpi.b #'2',(a0)+
	bhi \true
	blo \false
	cmpi.b #'7',(a0)+
	bhi \true
	blo \false
	cmpi.b #'6',(a0)+
	bhi \true
	blo \false
	cmpi.b #'7',(a0)
	bhi \true
\false	andi.b #%11111011,ccr
	bra \quit
\true	ori.b #%00000100,ccr
\quit	movem.l (a7)+,d0/a0
	rts

;===============================================

Convert	tst.b (a0)
	beq \false
	jsr IsCharError
	beq \false
	jsr IsMaxError
	beq \false
	jsr Atoui
\true	ori.b #%00000100,ccr
	rts
\false	andi.b #%11111011,ccr
	rts

;===============================================

NextOp	tst.b (a0)
	beq \quit
	cmpi.b #'+',(a0)
	beq \quit
	cmpi.b #'-',(a0)
	beq \quit
	cmpi.b #'*',(a0)
	beq \quit
	cmpi.b #'/',(a0)
	beq \quit
	addq.l #1,a0
	bra NextOp
\quit	rts

;===============================================

GetNum	movem.l d1/a1-a2,-(a7)
	movea.l a0,a1
	jsr NextOp
	movea.l a0,a2
	move.b (a2),d1
	clr.b (a2)
	movea.l a1,a0
	jsr Convert
	beq \true
\false	move.b d1,(a2)
	movea.l a2,a0
	andi.b #%11111011,ccr
	bra \quit
\true	move.b d1,(a2)
	movea.l a2,a0
	ori.b #%00000100,ccr
\quit	movem.l (a7)+,d1/a1-a2
	rts

;================================================

GetExpr	movem.l d1-d3/a0,-(a7)
	jsr GetNum
	bne \false
	move.l d0,d1
\loop	move.b (a0)+,d2
	beq \true
	jsr GetNum
	bne \false
	cmp.b #'+',d2
	beq \addit
	cmp.b #'-',d2
	beq \subtract
	cmp.b #'*',d2
	beq \multiply
\divide	tst.l d0
	beq \false 
	moveq #0,d3
	tst.l d1
	bpl \dpos
	neg.l d1
	moveq #1,d3
\dpos	jsr Div32
	tst.b d3
	beq \loop
	neg.l d1
	bra \loop
\addit	add.l d0,d1
	bra \loop
\subtract	sub.l d0,d1
	bra \loop
\multiply	jsr Mul32
	bra \loop
\false	andi.b #%11111011,ccr
	bra \quit
\true	move.l d1,d0
	ori.b #%00000100,ccr
\quit	movem.l (a7)+,d1-d3/a0
	rts

;=================================================

sPrompt	dc.b 'Veuillez saisir une expression :',13,10,0
sResult	dc.b 'Resultat :',13,10,0
sError	dc.b 'Erreur',13,10,0
sBuffer	ds.b 82
