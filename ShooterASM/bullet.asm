;clearBullet(offset(dw) buffer, dw x, dw y )
proc clearBullet
  push bp
  mov bp, sp
  push [bp+8] ; push offset buffer
  push [bp+6] ; push x
  push [bp+4] ; push y
  push bulletW ;push w
  push bulletH ; push h
  push FALSE ; dont flip x
	call printBMPArray
  pop bp
	ret 6
endp clearBullet


;readBulletBG(offset(dw) buffer, dw x, dw y)- reads bullet background
proc readBulletBG
  push bp
  mov bp, sp
  push [bp+8]; push offset buffer
  push [bp+6]
  push [bp+4]
  push bulletW
  push bulletH
  call readUpsideDownRect
  pop bp
  ret 6
endp readBulletBG



;printBullet{dw x, dw y}- prints the bullet
proc printBullet
  push bp
  mov bp, sp
  push [bp+6]
  push [bp+4]
  push bulletW
  push bulletH
  push BLACK
  call printRect
  pop bp
  ret 4
endp printBullet




; moveBullet(offset(dw) x, offset(dw) y, offset(dw) buffer, dw FlipX)- shoots the bullet in agiven x, y
proc moveBullet
  push bp
  mov bp, sp

  push [bp+6] ; push offset buffer
  mov bx, [bp+10]
  push [bx]
  mov bx, [bp+8]
  push [bx]
  call clearBullet

  push [bp+10]
  push [bp+8]
  cmp [word ptr bp+4], TRUE
  je moveBulletLeft
  push bulletSpeed
  jmp doMoveBullet
moveBulletLeft:
  push -bulletSpeed
doMoveBullet:
  push 0
  call moveObject

  mov bx, [bp+10]
  push [bx] ; push x
  mov bx, [bp+8]
  push [bx] ; push y
  call tryBulletHit
  cmp ax, TRUE
  je moveBulletRet

  push [bp+6]
  mov bx, [bp+10]
  push [bx]
  mov bx, [bp+8]
  push [bx]
  call readBulletBG

  mov bx, [bp+10]
  push [bx]
  mov bx, [bp+8]
  push [bx]
  call printBullet

moveBulletRet:
  pop bp
  ret 8
endp moveBullet

; tryBulletHit(dw bulletX, bulletY)
; Check if bullet hits wall
; Check if bullet is colliding with a zombie. if so, hurt him
; Returns in ax if hit something
proc tryBulletHit
  push bp
  mov bp, sp

  cmp [word ptr bp+6], 319-bulletW ; cmp x, right wall
  jae BulletHit
  cmp [word ptr bp+6], bulletW ; cmp x, left wall
  jbe BulletHit

  mov cx, numZombies
zombiesHitLoop:
  mov ax, cx
  dec ax
  shl ax, 1

  mov bx, offset zombieHandler
  add bx, ax
  cmp [word ptr bx], TRUE ; is zombie alive
  jne zombiesHitContinue

  push [bp+6]
  push [bp+4]
  push bulletW
  push bulletH
  mov bx, offset zombieXs
  add bx, ax
  push [bx]
  mov bx, offset zombieYs
  add bx, ax
  push [bx]
  push zombieW
  push zombieH
  call isColliding
  cmp ax, TRUE
  jne zombiesHitContinue

  mov ax, cx
  dec ax
  shl ax, 1
  ; Hurt zombie
  mov bx, offset zombieHealths
  add bx, ax
  sub [word ptr bx], ShotgunDamage
  jmp BulletHit

zombiesHitContinue:
  loop zombiesHitLoop

BulletNotHit:
  xor ax, ax ; ax = FALSE
  jmp BulletHitRet
BulletHit:
  ; mov dx, offset OpenErrorMsg
  ; mov ah, 9h
  ; int 21h
  mov [isBulletInAir], FALSE
  mov ax, TRUE
BulletHitRet:
  pop bp
  ret 4
endp tryBulletHit
