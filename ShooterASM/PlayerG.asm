proc loadPlayerBMPs
  push offset LegsStandFN
  push offset LegsStand
  push legsW
  push legsH
  call LoadBMP

  push offset LegsWalk1FN
  push offset LegsWalk1
  push legsW
  push legsH
  call LoadBMP

  push offset LegsWalk2FN
  push offset LegsWalk2
  push legsW
  push legsH
  call LoadBMP

  push offset LegsWalk3FN
  push offset LegsWalk3
  push legsW
  push legsH
  call LoadBMP

  mov [legsAnimation], offset LegsStand
  mov [legsAnimation + 2], offset LegsWalk1
  mov [legsAnimation + 4], offset LegsWalk2
  mov [legsAnimation + 6], offset LegsWalk3

  push offset bodyRegFN
  push offset bodyReg
  push upperBodyW
  push upperBodyH
  call LoadBMP

  ret
endp loadPlayerBMPs

; ClearPlayer() prints playerBG in x,y
proc ClearPlayer
  push offset playerBG
  push [playerX]
  push [playerY]
  push playerW
  push playerH
  push FALSE ; dont flip x
	call printBMPArray
	ret
endp ClearPlayer

; showLegs(dw x, dw y) - prints legs in corrent animation
proc showLegs
  push bp
  mov bp, sp

  mov bx, offset legsAnimation
  mov al, [playerLegsState]
  shl al, 1
  add bl, al
  push [bx] ; corrent animation offset
  push [bp + 6]
  push [bp + 4]
  push legsW
  push legsH
  xor ah, ah
  mov al, [playerFlipX]
  push ax
  call printBMPArray

  pop bp
  ret 4
endp showLegs

; showBody(dw x, dw y) - prints upper body
proc showBody
  push bp
  mov bp, sp

  push offset bodyReg
  push [bp + 6]
  push [bp + 4]
  push upperBodyW
  push upperBodyH
  xor ah, ah
  mov al, [playerFlipX]
  push ax
  call printBMPArray

  pop bp
  ret 4
endp showBody


; showPlayer() Prints the player on x,y
proc showPlayer
; print upper-body in corrent animation on x,y
  push [playerX]
  push [playerY]
  call showBody
; print legs in corrent animation on x, y + upperBodyH
  push [playerX]
  mov ax, [playerY]
  add ax, upperBodyH
  push ax
  call showLegs
	ret
endp showPlayer

proc readPlayerBG
  push offset playerBG
  push [playerX]
  push [playerY]
  push playerW
  push playerH
  call readUpsideDownRect
  ret
endp readPlayerBG


;           x1 x2     x1+w1   x2+w2
; __________[__{______]_______}________________________
;               x2 < x1+w1 < x2+w2
;
;
;           x2 x1     x2+w2   x1+w1
; __________{__[______}_______]________________________
;               x1 < x2+w2 < x1+w1
;
;
;

; isPlayerColliding(dw otherX, dw otherY, dw otherW, dw otherH )
;returns 1 in ax if player is colliding  with other, 0 otherwise
proc isPlayerColliding
  push bp
  mov bp, sp
  push bx

  push [playerX]
  push [playerY]
  push playerW-8
  push playerH
  push [bp+10]
  push [bp+8]
  mov ax, [bp+6]
  sub ax, 8
  push ax
  push [bp+4]
  call isColliding

  pop bx
  pop bp
  ret 8
endp isPlayerColliding



; DisplayPlayerStats() displays the player's life
proc DisplayPlayerStats
  push 0
  push 0
  push 180
  push 11
  push BLACK

  call printRect

  mov dx, offset HealthMsg
  mov ah, 9h
  int 21h


  push [playerHealth]
  call printDecimal

  mov dx, offset TabMsg
  mov ah, 9h
  int 21h

  mov dx, offset ScoreMsg
  mov ah, 9h
  int 21h

  push [playerScore]
  call printDecimal


  mov dl, 13
  mov ah, 2
  int 21h

  ret
endp DisplayPlayerStats

proc checkPlayerBounderies

  cmp [playerX], 3
  jl atLefttWall
  jmp checkRightWall
atLefttWall:
  mov [playerX], 3
  jmp checkY
checkRightWall:
  cmp [playerX],319-playerW
  jae atRightWall
  jmp checkY
atRightWall:
  mov [playerX], 319-playerW
checkY:
  cmp [playerY], 190-playerH ; is player on floor
  jae  onFloor ; if on floor (or below)
  push offset playerVelY
  call gravitate
  ret
onFloor:
  mov [playerVelY], 0
  mov [playerY], 190-playerH
  ret
endp checkPlayerBounderies

; tryHurtPlayer(dw damage)
; if player is not hurt already, subtract damage from playerHealth
proc tryHurtPlayer
  push bp
  mov bp, sp

  cmp [isPlayerHurt], TRUE
  je TryHurtPlayerRet
  mov ax, [Clock]
  mov [playerHurtTime], ax
  mov [isPlayerHurt], TRUE
  mov ax, [bp+4] ; ax=damage
  sub [playerHealth], ax
  call DisplayPlayerStats
TryHurtPlayerRet:

  pop bp
  ret 2
endp tryHurtPlayer
