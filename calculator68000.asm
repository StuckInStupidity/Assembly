;68000
;sans ordre de prio
;Veuillez saisir une expression :
;2*5-5*2+18/2
;Resultat :
;14
  
org $0
				
vector_000 		dc.l 	$ffb500
vector_001 		dc.l 	Main

				org 	$500
				
Main 			movea.l #sBuffer,a0
				clr.b 	d1
				clr.b 	d2
				move.l 	#60000,d3
				move.l 	#8000,d4
				jsr 	GetInput
				; code here + manque print char
				illegal

;===========================================

StrLen			movem.l d0/a0,-(a7)			
				clr.l 	d0

\loop			tst.b 	(a0)+
				beq 	\quit
				addq.l 	#1,d0
				bra 	\loop
				
\quit			movem.l (a7)+,d0/a0
				rts			
				
;===========================================

Atoui			movem.l d1/a0,-(a7)
				clr.l 	d0
				clr.l 	d1
				
\loop			move.b 	(a0)+,d1
				beq \quit
				subi.b #'0',d1
				mulu.w #10,d0
				add.l d1,d0
				bra \loop

\quit			movem.l (a7)+,d1/a0
				rts

;===========================================

Print			movem.l	d0/d1/a0,-(a7)

\loop			move.b 	(a0)+,d0
				beq 	\quit
				jsr 	PrintChar
				addq.b 	#1,d1
				bra 	\loop
				
\quit			movem.l (a7)+,d0/d1/a0
				rts
				
;===========================================
				
RemoveSpace		movem.l d0/a0/a1,-(a7)
				movea.l a0,a1

\loop			move.b 	(a0)+,d0
				cmpi.b 	#' ',d0
				beq 	\loop
				move.b 	d0,(a1)+
				bne 	\loop

\quit 			movem.l (a7)+,d0/a0/a1
				rts

;============================================

IsCharError		movem.l d0/a0,-(a7)

\loop 			move.b 	(a0)+,d0
				beq 	\false
				cmpi.b 	#'0',d0
				blo 	\true
				cmpi.b 	#'9',d0
				bls 	\loop
; ============================
;		7 6 5 4 3 2 1 0
;CCR : 		  X N Z V C
;=============================
\true 			ori.b 	#%00000100,ccr ; put zero flag at 1
				bra 	\quit

\false			andi.b 	#%11111011,ccr ; put zero flag at 0

\quit			movem.l (a7)+,d0/a0
				rts
				
;=============================================
				
IsMaxError		movem.l d0/a0,-(a7)
				jsr 	StrLen
				cmpi.l 	#5,d0
				bhi 	\true
				blo 	\false
				cmpi.b 	#'3',(a0)+
				bhi 	\true
				blo 	\false
				cmpi.b 	#'2',(a0)+
				bhi 	\true
				blo 	\false
				cmpi.b	#'7',(a0)+
				bhi 	\true
				blo 	\false
				cmpi.b 	#'6',(a0)+
				bhi 	\true
				blo 	\false
				cmpi.b 	#'7',(a0)
				bhi 	\true

\false 			andi.b 	#%11111011,ccr
				bra 	\quit

\true			ori.b 	#%00000100,ccr

\quit			movem.l (a7)+,d0/a0
				rts

;===============================================

Convert			tst.b 	(a0)
				beq 	\false
				jsr 	IsCharError
				beq 	\false
				jsr 	IsMaxError
				beq 	\false
				jsr 	Atoui
				
\true			ori.b 	#%00000100,ccr
				rts
				
\false 			andi.b 	#%11111011,ccr
				rts

;===============================================

NextOp          tst.b 	(a0)
				beq 	\quit
				cmpi.b 	#'+',(a0)
				beq 	\quit
				cmpi.b 	#'-',(a0)
				beq 	\quit
				cmpi.b 	#'*',(a0)
				beq 	\quit
				cmpi.b 	#'/',(a0)
				beq 	\quit
				addq.l 	#1,a0
				bra 	NextOp

\quit			rts

;===============================================

GetNum			movem.l	d1/a1-a2,-(a7)
				movea.l a0,d1
				jsr 	NextOp
				movea.l a0,d1
				move.b 	(a2),d1
				clr.b 	(a2)
				movea.l a1,a0
				jsr 	Convert
				beq 	\true

\false 			move.b 	d1,(a2)
				andi.b 	#%11111011,ccr
				bra 	\quit

\true 			move.b 	d1,(a2)
				movea.l a2,a0
				ori.b 	#%00000100,ccr

\quit			movem.l (a7)+,d1/a1-a2
				rts
				
;================================================				

GetExpr			movem.l d1-d2/a0,-(a7)
				jsr 	GetNum
				bne 	\false
				move.l 	d0,d1
				
\loop			move.b 	(a0)+,d2
				beq 	\true
				jsr 	GetNum
				bne 	\false
				cmp.b 	#'+',d2
				beq 	\addit
				cmp.b 	#'-',d2
				beq 	\subtract
				cmp.b 	#'*',d2
				beq 	\multiply
				bra 	\divide

\addit 			add.l 	d0,d1
				bra 	\loop
\subtract 		sub.l 	d0,d1
				bra 	\loop
\multiply 		muls.w 	d0,d1
				bra 	\loop
\divide			tst.w 	d0
				beq 	\false
				divs.w 	d0,d1
				ext.l 	d1
				bra 	\loop

\false 			andi.b 	#%11111011,ccr
				bra 	\quit

\true			move.l 	d1,d0
				ori.b 	#%00000100,ccr
				
\quit			movem.l (a7)+,d1-d2/a0
				rts

;=================================================

GetInput 		incbin 	"GetInput.bin"
sBuffer 		ds.b 	60
