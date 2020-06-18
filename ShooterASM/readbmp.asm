; OpenFile(offset(dw) filename) - opens a file located in filename
proc OpenFile

	push bp
	mov bp, sp

	mov ah, 3Dh
	xor al, al
	mov dx, [bp + 4] ; mov dx, [filename]
	int 21h
	jc openerror
	mov [filehandle], ax
	jmp openFileret
openerror:
	mov dx, offset OpenErrorMsg
	mov ah, 9h
	int 21h
	mov dx, [bp + 4]
	mov ah, 9h
	int 21h
	jmp waitKey
openFileret:
	pop bp
	ret	2
endp OpenFile

; ReadFile(offset(dw) buffer, dw size) - Reads size bytes from a file into buffer
proc ReadFile
	push bp
	mov bp, sp

	mov ah,3fh
	mov bx, [filehandle]
	mov cx, [bp + 4]
	mov dx, [bp + 6]
	int 21h

	pop bp
	ret 4
endp ReadFile

proc ReadHeader
	; Read BMP file header, 54 bytes
	push offset Header
	push 54
	call ReadFile
	ret
endp ReadHeader

proc ReadPalette
	; Read BMP file color palette, 256 colors * 4 bytes (400h)
	push offset Palette
	push 400h
	call ReadFile
	ret
endp ReadPalette

proc CopyPal
	; Copy the colors palette to the video memory
	; The number of the first color should be sent to port 3C8h
	; The palette is sent to port 3C9h
	mov si, offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0
	; Copy starting color to port 3C8h
	out dx,al
	; Copy palette itself to port 3C9h
	inc dx
PalLoop:
	; Note: Colors in a BMP file are saved as BGR values rather than RGB .
	mov al,[si+2] ; Get red value .
	shr al,2 ; Max. is 255, but video palette maximal
	; value is 63. Therefore dividing by 4.
	out dx,al ; Send it .
	mov al,[si+1] ; Get green value .
	shr al,2
	out dx,al ; Send it .
	mov al,[si] ; Get blue value .
	shr al,2
	out dx,al ; Send it .
	add si,4 ; Point to next color .
	; (There is a null chr. after every color.)
	loop PalLoop
	ret
endp CopyPal

; CopyBMPToBuffer(offset(dw) buffer, dw width, dw height)
; Copies the width*height bytes of a .bmp file into a given buffer
proc CopyBMPToBuffer
	push bp
	mov bp, sp

	push [bp + 8] ; offset buffer (should be big enough to hold height*width bytes)

	; ax = height * width
	mov ax, [bp + 4]
	mul [word ptr bp + 6]
	push ax
	call ReadFile

	pop bp
	ret 6
endp CopyBMPToBuffer

; LoadBMP(offset(dw) filename, offset(dw) pixelBuffer, dw width, dw height)
proc LoadBMP
	push bp
	mov bp, sp
	push [bp+10] ; push [filename]
	call OpenFile
	call ReadHeader
	call ReadPalette
	push [bp+8]; push [pixelBuffer]
	push [bp+6]; push [width]
	push [bp+4]; push [height]
	call CopyBMPToBuffer
	pop bp
	ret 8
endp LoadBMP

; printBMPArray(offset(dw) buffer, dw x, dw y, dw width, dw height, 0/1 (db) flipX)
; Prints an array of colors with size w*h in position x, y
; in VGA format(upside down)
proc printBMPArray
	; BMP graphics are saved upside-down .
	; Read the graphic line by line (heights lines in VGA format),
	; displaying the lines from bottom to top.
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push si

	mov si, [bp+14]; si= offset buffer
	mov dx, [bp+10]
	add dx, [bp+6]
	dec dx ; dx= y + height - 1
	mov cx, [bp+6]; cx = height
BufYLoop:
	push cx
	mov cx, [bp+8]; mov cx, width
BufXLoop:
	cmp [byte ptr si], NullColor
	je dontPrint

	mov ax, [bp+12] ; ax = x
	cmp [byte ptr bp+4], TRUE
	jne dontFlipX
	add ax, cx
	dec ax ; ax = x + cx - 1 (x+width-1 -> x)
	jmp doPrintPoint
dontFlipX:
	add ax, [bp + 8]
	sub ax, cx ; ax = x + cx (x -> x+width-1)
doPrintPoint:
	push ax ; push corrent x
	push dx ; push corrent y
	mov bl, [si] ; bl = corrent color
	push bx
	call printPoint
dontPrint:
	inc si ; inc offset buffer
	loop BufXLoop
	dec dx
	pop cx
	loop BufYLoop

	pop si
	pop dx
	pop cx
	pop bx
	pop ax

	pop bp
	ret 12
endp printBMPArray

; CopyBmpToScreen (dw filehandle) - prints a 320*200 bmp to screen
proc CopyBmpToScreen
; BMP graphics are saved upside-down .
; Read the graphic line by line (200 lines in VGA format),
; displaying the lines from bottom to top.
	push bp
	mov bp, sp
	mov ax, 0A000h
	mov es, ax
	mov cx,200
	PrintBMPLoop :
	push cx
	; di = cx*320, point to the correct screen line
	mov di,cx
	shl cx,6
	shl di,8
	add di,cx
	; Read one line

	push offset ScrLine
	push 320
	call ReadFile
	; Copy one line into video memory
	cld ; Clear direction flag, for movsb
	mov cx,320
	mov si,offset ScrLine

	rep movsb ; Copy line to the screen
	 ;rep movsb is same as the following code :
	 ;mov es:di, ds:si
	 ;inc si
	 ;inc di
	 ;dec cx
	 ;loop until cx=0
	pop cx
	loop PrintBMPLoop

	pop bp
	ret 2
endp CopyBmpToScreen
