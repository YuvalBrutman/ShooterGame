IDEAL
MODEL small
STACK 100h
DATASEG
	Clock equ es:6Ch

	corTime dw ?

CODESEG

; printDecimal(dw number) prints the number in decimal representation
proc printDecimal
	push bp
	mov bp, sp

	push cx

	mov ax, [bp+4]

	xor cx, cx
DivTen:
	xor dx, dx
	mov bx, 10
	div bx ; dx = ax mod 10, ax = ax // 10
	push dx ; add dx to stack
	inc cx

	cmp ax, 0h
	jne DivTen


PrintDecLoop:
; print dl as ascii number
	pop dx
	add dl, '0'

	mov ah, 2
	int 21h
	loop PrintDecLoop

	pop cx
	pop bp
	ret 2
endp printDecimal


include "time.asm"

start:
	mov ax, @data
	mov ds, ax

	; mov ax, 13h
	; int 10h

	call setClock

	mov ax, [clock]
	mov [corTime], ax

	push 18
	call waitTicks

	mov cx, 1000
printTicks:
	push [Clock]
	call printDecimal

	mov ah, 2
	mov dl, '-'
	int 21h

	push [corTime]
	call printDecimal

	mov ah, 2
	mov dl, '='
	int 21h

	push [corTime]
	call ticksSince
	push ax
	call printDecimal

	call waitOneTick


	mov ah, 2 ; new line
	mov dl, 10
	int 21h
	mov dl, 13
	int 21h

	loop printTicks

exit:
	; Back to text mode
	; mov ah, 0
	; mov al, 2
	; int 10h

	mov ax, 4c00h
	int 21h
	END start
