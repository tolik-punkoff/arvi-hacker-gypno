
NAME	HypnoICE
TITLE	World first 128 byte psionic intro with hypnotic & brain-damage effects
SUBTTL	(C) 1997, Arvi the Hukker (AtH//HPG), 2:5020/287@fidonet.org
;.............................................................................;
; Hypnotize operator and envoke mind alpha rythm (7-8Hz) resonance by both	  ;
; audio and visual effects.	 I know the ways to improve influence, but this	  ;
; hack is not a weapon, just a small demonstration of the Art.				  ;
;										  ;
; WARNING!	Intro style codeing, so Real World suxxx...	 Requires really 100% ;
;	PC and MS-DOS compatible with at least VGA and at least 80386 CPU.		  ;
;.............................................................................;
; ВНИМАНИЕ!	 HypnoICE содержит материал, способный причинить психический и,
; возможно, физический ущерб человеку.	Цель HypnoICE -- обратить внимание
; людей на нестандартные способы использования компьютера, а не причинение
; вреда людям.	Автор советует не запускать эту программу, а лишь исследовать
; ее исходный текст.  Решив запустить эту программу, всю ответственность за ее
; действия вы принимаете на себя.
;
; ГАРАНТИЯ.	 Единственное, что гарантирует автор -- что эта программа будет
; занимать место на диске.	Автор не гарантирует даже то, что программа будет
; успешно откомпилирована.	Автор не несет никакой ответственности за
; умышленный или неумышленный вред, вызванный использованием данной программы
; или технологией, в ней используемой.

;FREQ		EQU	7	; 10.0 Hz (almost harmless)
FREQ		EQU	8	; 8.75 Hz
;FREQ		EQU	9	;  7.8 Hz (most dangerous)
;FREQ		EQU	10	;  7.0 Hz (also dangerous)
;FREQ		EQU	11	; 6.36 Hz
;FREQ		EQU	70	;  1.0 Hz (harmless demo?)

RADIUS		EQU	100	; 26..100

setalc MACRO
	db	0D6h
ENDM
;__USE32__	equ <>

.model	tiny, stdcall
IFDEF __USE32__
.386
ELSE
.186
ENDIF
SIZE_MEM	equ 63*1024

.code
org	100h
; ---  Part I  ---	Prepare script.
;sp = 0FFFEh, cx=255, ax=0, es=, di=-2, si=256
Start:
	mov		si, offset FreeMemory
	push	si
IFDEF __USE32__
	mov		edx, 0FF1F1F1Fh
ELSE
	mov		dx, 1F1Fh
ENDIF
	.repeat
IFDEF __USE32__
		and		[si], edx
ELSE
		and		[si], dx
		and		[si+2], dl
ENDIF
		dec		cx
		.if (!cx)
IFDEF __USE32__
			sub		[si], edx	; Can change return address :(
ELSE
			sub		[si], dx
			sbb		[si+2], dl
ENDIF
			mov		cl, FREQ
		.endif
		add		si, 3
	.until (si>offset FreeMemory[SIZE_MEM]);
; ---  Part ][	---	 Draw scene.
	mov		al, 13h		; граф. режим 320х200 256 цветов, 70 Гц
	int		10h
	;es:di = 0A000h:0000h	;адрес экраного буфера
	push	0A000h
	pop		es
	xor		di, di
	mov		si, RADIUS*2-1	;y = 
	.repeat
		mov		cx, 320		;x
		.repeat	
			;x1 = iabs(160-x);
			mov		ax, 160
			sub		ax, cx
			.if (sign?);sword ax<0
				neg		ax
			.endif
			push	ax
			;y1 = y-RADIUS;
			;color = isqrt(x1*x1+y1*y1);
			mul		ax			; 25600 max
			mov		bx, ax
			lea		ax, [si-RADIUS]
			imul	ax			; 10000 max,  DX=0
			add		bx, ax		; 35600 max.
			;вычисление квадратного корня
			.if (bx>1)
				push	cx
				push	di
				mov		cx, 128		;// initial guess
				mov		di, cx
				.repeat
					;ax=(bx/cx+cx)/2;
					mov		ax, bx
					xor		dx, dx
					div		cx
					add		ax, cx
					shr		ax, 1	;/=2;
					.break .if (ax==cx)
					cmp		ax, di
					mov		di, cx
					mov		cx, ax
				.until (zero?)
				pop		di
				pop		cx
				mov		bx, ax
			.endif
			pop		ax
			xchg	ax, bx
			.if (sbyte ptr al>=RADIUS);(color>=RADIUS)
				xchg	ax, bx	;color = x1
			.endif
			stosb
			dec		cx
		.until (zero?)
		dec		si
	.until (zero?)
; ---  Part ]I[	 ---  Animation.
	pop		si		;= offset FreeMemory
	.repeat
		mov		ch, 2;FFh
		;пауза, Ждём вертикальный синхронизирующий импульс.
		mov		dx, 3DAh	;Input Status Register 1 - ISR0
		.repeat
			in		al, dx
			and		al, 8	;Бит обратного вертикального хода 
		.until (!zero?)
		;al=8, cx=2FFh
		push	si
		mov		dl, 0C8h	;=3C8h	Индекс записываемого регистра таблицы цветов (Look-up Table Write Index Register - LTWIR)
		out		dx, al
		inc		dx			;=3C9h	Регистр данных таблицы цветов (Look-up Table Data Register - LTDR)
		rep	outsb			;while(--cx) port[dx] = [si++];
		pop		si
		;outportb(0x61, ([si]==0x1F) ? 2 : 0); si+=3;
		lodsb				;al=[si++];
		add		si, 2
		.if (si > offset FreeMemory[SIZE_MEM])
			mov		si, offset FreeMemory
		.endif
		cmp		al, 1Fh
		setalc
		and		al, 2
		out		61h, al		;звук динамика
		in		al, 60h		;проверяем клавишу Esc, скан код = 1
		xchg	ax, cx	;dec		al;	
	.untilcxz; (zero?)
	mov		ax, 3		;вернём текстовый режим
	int		10h
	ret			; Stack Okay! ;-)
.data
align 2
FreeMemory	db SIZE_MEM dup (?)
END	Start

;--- MakeICE.Bat ---
;tasm/ml/z/q/zi/m9/la HypnoICE
;tlink/x/c/t HypnoICE
;--- Cut here ---

;P.S. Thank you for useing my software. ;)

;	 Luck !
;Arvi the Hukker						  1 Dec 1997
;  (AtH//HPG)						Moscow,	 Russia