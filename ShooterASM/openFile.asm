IDEAL
MODEL small
STACK 100h
DATASEG

filename db 'player.bmp', 0
filehandle dw ?
OpenErrorMsg db 'error: could not open file $' 

BufferSize equ 4406
buffer db BufferSize dup (?)

CODESEG
proc OpenFile
	; Open file
	push bp
	mov bp, sp
		
	mov ah, 3Dh
	xor al, al
	mov dx, [bp + 4]
	int 21h
	jc openerror
	mov [filehandle], ax
	jmp openFileret
openerror:
	mov dx, offset OpenErrorMsg
	mov ah, 9h
	int 21h
openFileret:
	pop bp 
	ret	2
endp OpenFile

proc ReadFile
	; Read file
	mov ah,3Fh
	mov bx, [filehandle]
	mov cx, BufferSize
	mov dx, offset buffer
	int 21h
	ret
endp ReadFile
 
start:

	mov ax, @data
	mov ds, ax
	push offset filename
	call OpenFile
	call ReadFile
	
exit:
	mov ax, 4c00h
	int 21h
END start







