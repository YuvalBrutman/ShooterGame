;printPoint(dw x, dw y, db color) - prints a point in a given location and color
proc printPoint
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx

	mov al, [byte ptr bp + 4]
	xor bl, bl
	mov cx, [word ptr bp + 8]
	mov dx, [word ptr bp + 6]
	mov ah,0ch
	int 10h

	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 6
endp printPoint

; printRect(dw x, dw y, dw w, dw h, dw color) - prints a rectangle on x,y in
; a given size and color
proc printRect
	push bp
	mov bp, sp

	push ax
	push bx
	push cx

	mov ax, [bp+12]
	mov bx, [bp + 10]

	mov cx, [bp+ 6]
loopY:
	push cx
	mov cx, [bp+8]
loopX:
	push ax
	push bx
	push [bp+4]
	call printPoint
	inc ax
	loop loopX

	inc bx
	mov ax, [bp+12]
	pop cx
	loop loopY

	pop cx
	pop bx
	pop ax
	pop bp
	ret 10
endp printRect

proc printBG

	push offset BGfilename
	call OpenFile
	call ReadHeader
	call ReadPalette
	call CopyPal
	push [filehandle]
	call CopyBmpToScreen
	ret
endp printBG

; readcolor(dw x, dw y)- reads the pixel color in x,y into al
proc readColor
	push bp
	mov bp, sp
	push bx
	push cx
	push dx

	mov bh,0h
	mov cx,[bp+6] ; mov cx, [x]
	mov dx,[bp+4]
	mov ah,0Dh
	int 10h

	pop dx
	pop cx
	pop bx
	pop bp
	ret 4
endp readColor

; readUpsideDownRect(offset(dw) buffer, dw x, dw y, dw w, dw h) - reads a w*h rectangle from x,y into buffer
proc readUpsideDownRect
; BMP graphics are saved upside-down .
; Read the graphic line by line (heights lines in VGA format),
; reading the lines from bottom to top.
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push si

	mov si, [bp+12]; si= offset buffer
	mov dx,[bp+8]
	add dx, [bp+4]
	dec dx ; dx= y + height - 1
	mov cx, [bp+4]; cx = height
readRectYLoop:
	mov bx, [bp+10] ; bx = x

	push cx
	mov cx, [bp+6]; mov cx, width
readRectXLoop:

	push bx ; push corrent x
	push dx ; push corrent y
	call readColor
	mov [byte ptr si], al

	inc bx
	inc si ; inc offset buffer
	loop readRectXLoop
	dec dx
	pop cx
	loop readRectYLoop

	pop si
	pop dx
	pop cx
	pop bx
	pop ax

	pop bp
	ret 10
endp readUpsideDownRect

; printDecimal(dw number) prints the number in decimal representation
proc printDecimal
	push bp
	mov bp, sp

	push bx
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
	pop bx
	pop bp
	ret 2
endp printDecimal
