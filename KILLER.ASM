code segment para
   assume cs:code
   org 100h
   Begin:
		jmp main
;-----------------------------------------------------------------------;
;			Seccion de variables
;-----------------------------------------------------------------------;
variables:
		respaldo1 dd ?
		last_interrupt_1c dd ?
		last_interrupt_9 dd ?
		last_interrupt_10 dd ?
		last_interrupt_21 dd ?
;-----------------------------------------------------------------------;
;		Codigo que remplazara la int 8H
;			(CODIGO ACTIVO)
;-----------------------------------------------------------------------;
   codigo_int1C:
		push ax
		push cx
		push es
		pushf
		mov ax,0B800h
		mov es,ax
		mov al,220		;ASCII Ü
		mov es:[0CE2h],al	;renglon 20 columna 49
		mov al,223		;ASCII ß
		mov es:[0CE2h],al	;renglon 20 columna 49
		call delay
		call delay
		mov al,255		;ASCII ÿ
		mov es:[0CE2h],al	;renglon 20 columna 49
		popf
		pop es
		pop cx
		pop ax
		iret
		;jmp cs:last_interrupt_1c
		; procedimiento de retardo
		delay proc near
			mov cx,04fffh
		d_rep:	loop d_rep
			ret
		delay endp
   fin_int_1C:
;-----------------------------------------------------------------------;
;		Codigo que remplazara la int 5H
;-----------------------------------------------------------------------;
   codigo_int5:	
		push ax
		push es
		pushf
		xor ax,ax
		mov es,ax
		cli
		mov ax, offset codigo_int1C
		mov es:[70h],ax
		mov es:[72h],cs
		sti
		popf
		pop es
		pop ax
		iret
;-----------------------------------------------------------------------;
;		Codigo que remplazara la int 10H
;-----------------------------------------------------------------------;
   codigo_int10:	
		push ax
		push es
		pushf
		xor ax,ax
		mov es,ax
		cli
		mov ax, offset codigo_int1C
		mov es:[70h],ax
		mov es:[72h],cs
		sti
		popf
		pop es
		pop ax
		jmp cs:last_interrupt_10
;-----------------------------------------------------------------------;
;		Codigo que remplazara la int 09H
;-----------------------------------------------------------------------;
   codigo_int9:	
		push ax
		push es
		pushf
		in al,60h
		cmp al,42
		jne int9_continuar
		xor ax,ax
		mov es,ax
		cli
		mov ax, offset codigo_int1C
		mov es:[70h],ax
		mov es:[72h],cs
		sti
   int9_continuar:
		popf
		pop es
		pop ax
		jmp cs:last_interrupt_9

;-----------------------------------------------------------------------;
; Codigo que remplazara la int 21H
;-----------------------------------------------------------------------;
   codigo_int21:
		pushf
		push ax
		push bx
		push cx
		push dx
		push si
		push di
		push ds
		push es		

		cmp ah,4bh
		jne salir
		mov si,dx	;ahora SI contiene la direccion del nombre
				;del programa que se va a ejecutar
		dec si
   buscar:
		inc si
		cmp [si], byte ptr '.'
		jne buscar
		cmp [si-1], byte ptr 'X'
		jne salir
		cmp [si-2], byte ptr 'I'
		jne salir
		cmp [si-3], byte ptr 'N'
		jne salir
		cmp [si-4], byte ptr 'E'
		jne salir
		cmp [si-5], byte ptr 'F'
		jne salir
		;mov ax,0b800h
		;mov es,ax
		;mov al,01
		;mov es:[0],al
		pop es
		pop ds
		pop di
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		popf
		iret


   salir:
		pop es
		pop ds
		pop di
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		popf
		jmp cs:last_interrupt_21

   Main:
		
;-----------------------------------------------------------------------;
; 			Remplazar la int 5H
;-----------------------------------------------------------------------;
		xor ax,ax
		mov es,ax
		cli
		mov ax, offset codigo_int5
		mov es:[14h],ax
		mov es:[16h],cs
		sti
;-----------------------------------------------------------------------;
; 			Remplazar la int 21H
;-----------------------------------------------------------------------;
		xor ax,ax
		mov es,ax
		mov ax,es:[84h]
		mov word ptr last_interrupt_21,ax
		mov ax,es:[86h]
		mov word ptr last_interrupt_21 + 2,ax
		cli
		mov ax, offset codigo_int21
		mov es:[84h],ax
		mov es:[86h],cs
		sti
;-----------------------------------------------------------------------;
; 			Remplazar la int 10H
;-----------------------------------------------------------------------;
		xor ax,ax
		mov es,ax
		mov ax,es:[40h]
		mov word ptr last_interrupt_10,ax
		mov ax,es:[42h]
		mov word ptr last_interrupt_10 + 2,ax
		cli
		mov ax, offset codigo_int10
		mov es:[40h],ax
		mov es:[42h],cs
		sti
;-----------------------------------------------------------------------;
; 			Remplazar la int 9H
;-----------------------------------------------------------------------;
		xor ax,ax
		mov es,ax
		mov ax,es:[36d]
		mov word ptr last_interrupt_9,ax
		mov ax,es:[38d]
		mov word ptr last_interrupt_9 + 2,ax
		cli
		mov ax, offset codigo_int9
		mov es:[36d],ax
		mov es:[38d],cs
		sti

;-----------------------------------------------------------------------;
; 			Remplazar la int 1CH
;-----------------------------------------------------------------------;
		xor ax,ax
		mov es,ax
		mov ax,es:[70h]
		mov word ptr last_interrupt_1c,ax
		mov ax,es:[72h]
		mov word ptr last_interrupt_1c + 2,ax
		cli
		mov ax, offset codigo_int1C
		mov es:[70h],ax
		mov es:[72h],cs
;-----------------------------------------------------------------------;
; 			Dejar Residente
;-----------------------------------------------------------------------;
		mov ah,31h
		mov dx, offset main	;tama¤o del programa
		sti
		int 21h			;dejar residente
code ends
   end Begin