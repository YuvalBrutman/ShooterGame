; setClock() - Sets es to clock position (40h)
proc setClock
	mov ax, 40h
	mov es, ax
	ret
endp setClock

; waitOneTick() - waits one tick (55 ms)
proc waitOneTick
	mov ax, [Clock]
tick:
	cmp ax, [Clock]
	je tick
	ret
endp waitOneTick

; waitTicks(dw nTicks) - waits a given number of ticks (55 ms)
proc waitTicks
	push bp
	mov bp, sp

	call waitOneTick

	mov cx, [bp + 4]
DelayLoop:
	call waitOneTick
	loop DelayLoop
	pop bp
	ret 2
endp waitTicks

; ticksSince(dw time) returns num of ticks since given time
proc ticksSince
	pop bx ; ip

	pop dx; dx = time
	mov ax, [Clock]
	sub ax, dx ; ax = clock - time

	push bx
	ret
endp ticksSince
