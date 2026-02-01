
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
;USE_386	equ <>

.model	tiny, stdcall
IFDEF USE_386
.386
ELSE
.186
ENDIF

.code
org	100h
; ---  Part I  ---	Prepare script.
;sp = 0FFFEh, cx=255, ax=0, es=ss=ds=cs, di=0FFFEh
Start:
	mov		si, ((FreeMemory-Start+102h)/3)*3
IFDEF USE_386
	mov		edx, 0FF1F1F1Fh
ELSE
	mov		dx, 1F1Fh
ENDIF
	.repeat
IFDEF USE_386
		and		[si], edx
ELSE
		and		[si], dx
		and		[si+2], dl
ENDIF
		loop	nQue
IFDEF USE_386
			sub		[si], edx	; Can change return address :(
ELSE
			sub		[si], dx
			sbb		[si+2], dl
ENDIF
			mov		cl, FREQ
		nQue:
;		add		si, 3
		outsw				;si+=3;
		outsb
	.until (si>=sp)
; ---  Part II	---	 Draw scene.
	push	0A000h
	stosw				; DI<=0,  Restore return address
	mov		al, 13h		; граф. режим 320х200 256 цветов
	int		10h
	pop		es
	mov		si, RADIUS*2-1	;y = 
	.repeat
		mov		cx, 320		;x
		.repeat
			;x1 = iabs(160-x);
			mov		ax, 160
			sub		ax, cx
			.if (sign?)
				neg		ax
			.endif
			push	ax
			;y1 = y-RADIUS;
			;color = isqrt(x1*x1+y1*y1);
			mul		ax			; 25600 max
			xchg	bp, ax
			lea		ax, [si-RADIUS]
			imul	ax			; 10000 max,  DX=0
			add		bp, ax		; 35600 max.
			;Медленое вычисление квадратного корня (time delay)
			.repeat
				dec		dx
				mov		al, dl
				mul		dl
			.until (ax<=bp)
			pop		ax
			xchg	ax, dx
			.if (sbyte ptr al>=RADIUS);(color>=RADIUS)
				xchg	ax, dx	;color = x1
			.endif
			stosb				;[di++] = color
		.untilcxz
		dec		si
	.until (zero?)
; ---  Part III	 ---  Animation.
	;si=0
	.repeat
		mov		ch, 2
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
		rep	outsb			;while(--cx) outportb(3C9h, [si++]);
		pop		si
		;outportb(0x61, ([si]<0x1F) ? 2 : 0); si+=3;
		lodsb				;al=[si++];
		cmpsw				;si+=2; di+=2;
		cmp		al, 1Fh
		setalc
		and		al, 2
		out		61h, al		;звук динамика
		in		al, 60h		;проверяем клавишу Esc, скан код = 1
		xchg	ax, cx
	.untilcxz
	mov		ax, 3		;вернём текстовый режим
	int		10h
	ret			; Stack Okay! ;-)
FreeMemory:
END	Start

;--- MakeICE.Bat ---
;tasm/ml/z/q/zi/m9/la HypnoICE
;tlink/x/c/t HypnoICE
;--- Cut here ---

;P.S. Thank you for useing my software. ;)

;	 Luck !
;Arvi the Hukker						  1 Dec 1997
;  (AtH//HPG)						Moscow,	 Russia