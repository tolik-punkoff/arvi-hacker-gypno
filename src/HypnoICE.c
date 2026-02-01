/*===========================================================================
ВНИМАНИЕ!	HypnoICE содержит материал, способный причинить психический и,
возможно, физический ущерб человеку.	Цель HypnoICE -- обратить внимание
людей на нестандартные способы использования компьютера, а не причинение
вреда людям.	Автор советует не запускать эту программу, а лишь исследовать
ее исходный текст.  Решив запустить эту программу, всю ответственность за ее
действия вы принимаете на себя.

Porting to TurboC (c) NanoBot		6.05.2020
===========================================================================*/
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <dos.h>
/* #include <math.h> */

#define		FREQ		7	/* =70/ALFA */
#define		RADIUS		100
#define		SIZE_TABLE	21000*3	/* небольше 65535 байт */

char	TableColor[SIZE_TABLE];

unsigned int	isqrt(unsigned int num)
{
	unsigned int	div1, div2, res;
	res = num;
	if (num>1) {
		char b;
		div1 = 128;
		div2 = div1;
		do {
			res = (num/div1 + div1)/2;
			if (res==div1) break;
			b = res==div2;
			div2 = div1;
			div1 = res;
		} while (b);
		if (div2<res)
			res=div2;
	}
	return res;
}

void main()
{
	union REGS	regset;
	int		x,y,x1,y1,color,i,n;
	char	b, *pVidMem;
	for (i=0; i<SIZE_TABLE; i++)
		TableColor[i] = random(255);
	/* Инициализация массива цвета */
	for (i=0, n=255; i<SIZE_TABLE; i+=3){
		(long*)TableColor[i] &= 0xFF1F1F1F;
		if (--n==0){
			(long*)TableColor[i] -= 0xFF1F1F1F;
			n = FREQ;
		}
	}
	/* Отрисовка сцены */
	/* режим 320x200 256 color */
	regset.x.ax = 0x13;
	int86(0x10, &regset, &regset);
	pVidMem = 0;
	for (y = RADIUS*2-1; y; y--)
		for (x = 320; x; x--){
			x1 = 160-x;
			if (x1<0)	/* iabs */
				x1=-x1;
			y1 = y-RADIUS;
			color = isqrt(x1*x1+y1*y1);
			if ((char)color>=RADIUS)
				color = x1;
			/* *pVidMem++ = (char)color; */
			putpixel(x, y, color);
		}
	/* Анимация сцены */
	for (i=0, b=0;; i+=3){
		register char	a;
		/* пауза, Ждём вертикальный синхронизирующий импульс. */
		do {
			a = inportb(0x3DA);
		} while (!a & 8);
		/* перенастройка таблицы цветов */
		outportb(0x3C8, 8);
		for (n = 0x200+b; n; n--)
			outportb(0x3C9, TableColor[i+n]);
		/* щелчки динамика */
		outportb(0x61, (TableColor[i]<0x1F) << 1);
		b = inportb(0x60);	/* опрос клавиатуры */
		if (--b==0) break;	/* =1 нажали Esc */
	}
	/* вернём текстовый режим */
	regset.x.ax = 3;
	int86(0x10, &regset, &regset);
}