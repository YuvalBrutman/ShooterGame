proc loadZombieBMPs
  push offset zombieFileName
  push offset zombieArr
  push zombieW
  push zombieH
  call LoadBMP

  mov si, offset zombieBGAddresses
  mov bx, offset zombieBGs
  mov cx, numZombies
zombieBGAddressesLoop:
  mov [si], bx
  add si, 2
  add bx, zombieW*zombieH
  loop zombieBGAddressesLoop

  ret
endp loadZombieBMPs

proc loadZombieBMP
  push offset zombieFileName
  push offset zombieArr
  push zombieW
  push zombieH
  call LoadBMP
  ret
endp loadZombieBMP

; showZombies() prints all zombies
proc showZombies
  mov cx, numZombies
showZombiesLoop:
  mov ax, cx
  dec ax
  shl ax, 1

  mov bx, offset zombieHandler
  add bx, ax
  cmp [word ptr bx], TRUE ; is zombie alive
  jne showZombiesContinue

  mov bx, offset zombieXs
  add bx, ax
  push [bx]
  mov bx, offset zombieYs
  add bx, ax
  push [bx]
  mov bx, offset zombieFlipXs
  add bx, ax
  push [bx]
  call showZombie
showZombiesContinue:
  loop showZombiesLoop
  ret
endp showZombies

; showZombie(dw x, dw y, 0/1 flipX) prints zombieArr on x,y
proc showZombie
  push bp
  mov bp, sp
	push offset zombieArr
  push [bp+ 8]
  push [bp+6]
  push zombieW
  push zombieH
  push [bp+4]
  call printBMPArray
  pop bp
	ret 6
endp showZombie


proc readZombieBGs
  mov cx, numZombies
zombieBGLoop:
  mov ax, cx
  dec ax
  shl ax, 1

  mov bx, offset zombieHandler
  add bx, ax
  cmp [word ptr bx], TRUE ; is zombie alive
  jne zombieBGcontinue
  mov bx, offset zombieBGAddresses
  add bx, ax
  push [bx]
  mov bx, offset zombieXs
  add bx, ax
  push [bx]
  mov bx, offset zombieYs
  add bx, ax
  push [bx]
  call readZombieBG
zombieBGcontinue:
  loop zombieBGLoop
  ret
endp readZombieBGs


;readPlayerBG(offset dw buffer, dw x, dw y)- reads the zombie background
proc readZombieBG
  push bp
  mov bp, sp
  push [bp+8]
  push [bp+6]
  push [bp+4]
  push zombieW
  push zombieH
  call readUpsideDownRect
  pop bp
  ret 6
endp readZombieBG

; ClearZombies() clear all zombies
proc ClearZombies
  mov cx, numZombies
clearZombiesLoop:
  mov ax, cx
  dec ax
  shl ax, 1

  mov bx, offset zombieHandler
  add bx, ax
  cmp [word ptr bx], TRUE ; is zombie alive
  jne clearZombiesContinue

  mov bx, offset zombieBGAddresses
  add bx, ax
  push [bx]
  mov bx, offset zombieXs
  add bx, ax
  push [bx]
  mov bx, offset zombieYs
  add bx, ax
  push [bx]
  call ClearZombie
clearZombiesContinue:
  loop clearZombiesLoop
	ret
endp ClearZombies

; ClearZombie(offset (dw) zombieBG, dw x, dw y) prints zombieBG in x,y
proc ClearZombie
  push bp
  mov bp, sp
  push [bp+8]
  push [bp+6]
  push [bp+4]
  push zombieW
  push zombieH
  push FALSE ; dont flip x
	call printBMPArray
  pop bp
	ret 6
endp ClearZombie

; allZombiesAI() sets all zombies movments depends on the zombies position
proc allZombiesAI
  mov cx, numZombies
zombieAILoop:
  mov ax, cx
  dec ax
  shl ax, 1

  mov bx, offset zombieHandler
  add bx, ax
  cmp [word ptr bx], TRUE ; is zombie alive
  jne zombieAIContinue

  mov bx, offset zombieVelXs
  add bx, ax
  push bx
  mov bx, offset zombieVelYs
  add bx, ax
  push bx
  mov bx, offset zombieFlipXs
  add bx, ax
  push bx
  mov bx, offset zombieXs
  add bx, ax
  push [bx]
  mov bx, offset zombieYs
  add bx, ax
  push [bx]
  call zombieAI
zombieAIContinue:
  loop zombieAILoop
  ret
endp allZombiesAI

; zombieAI(offset (dw) [velx, vely, flipX], dw [x, y])
; sets the zombie's movment depends on the zombie position
proc zombieAI
  push bp
  mov bp, sp

  mov bx, [bp+12]

  push [bp+6]
  push [bp+4]
  push zombieW
  push zombieH
  call isPlayerColliding
  cmp ax, TRUE
  jne checkZombieDirection
  mov [word ptr bx], 0
  push zombieDamage
  call tryHurtPlayer

  jmp zombieAIRet
checkZombieDirection:
  mov ax, [playerX]
  cmp ax, [bp+6]
  jb moveZombieLeft
  jmp moveZombieRight
moveZombieLeft:
  mov [word ptr bx], -zombieXSpeed
  mov si, [bp+8]
  mov [word ptr si], TRUE
  jmp zombieAIRet
moveZombieRight:
  mov [word ptr bx], zombieXSpeed
  mov si, [bp+8]
  mov [word ptr si], FALSE
zombieAIRet:
  pop bp
  ret 10
endp zombieAI

proc checkzombiesHealth
  mov cx, numZombies
zombieHealthLoop:
  mov ax, cx
  dec ax
  shl ax, 1

  mov bx, offset zombieHandler
  add bx, ax
  cmp [word ptr bx], TRUE ; check if alive
  jne zombieHealthContinue


  mov bx, offset zombieHealths
  add bx, ax
  cmp [word ptr bx], 0
  jg zombieHealthContinue

  mov bx, offset zombieHandler
  add bx, ax
  mov [word ptr bx], FALSE ; exterminate zombie

  mov bx, offset zombieBGAddresses
  add bx, ax
  push [bx]
  mov bx, offset zombieXs
  add bx, ax
  push [bx]
  mov bx, offset zombieYs
  add bx, ax
  push [bx]
  call ClearZombie
  add [playerScore], 10
  call DisplayPlayerStats
zombieHealthContinue:
  loop zombieHealthLoop
  ret
endp checkzombiesHealth

proc moveZombies
  mov cx, numZombies
zombieMoveLoop:
  mov ax, cx
  dec ax
  shl ax, 1

  mov bx, offset zombieHandler
  add bx, ax
  cmp [word ptr bx], TRUE ; is zombie alive
  jne zombieMoveContinue

  mov bx, offset zombieXs
  add bx, ax
  push bx
  mov bx, offset zombieYs
  add bx, ax
  push bx
  mov bx, offset zombieVelXs
  add bx, ax
  push [bx]
  mov bx, offset zombieVelYs
  add bx, ax
  push [bx]
  call moveObject
zombieMoveContinue:
  loop zombieMoveLoop
  ret
endp moveZombies

proc createNewZombie
  push [zombieGenTime]
  call ticksSince
  cmp ax, zombieGenInterval
  jb zombieCreateRet

  call allocateZombie ; bx = index
  cmp bx, -1
  je zombieCreateRet ; too many zombies
  shl bx, 1

  mov si, offset zombieXs
  add si, bx
  call genRandom
  sub al, 96
  xor ah, ah
  ; TODO: add random position
  mov [word ptr si], ax ; x = random possition

  mov si, offset zombieHealths
  add si, bx
  mov [word ptr si], zombieMaxHealth

  ; TODO: add readBG(not really )
  mov di, offset zombieBGAddresses
  add di, bx
  push [di]
  mov si, offset zombieXs
  add si, bx
  push [si]
  mov si, offset zombieYs
  add si, bx
  push [si]
  call readZombieBG

  mov ax, [Clock]
  mov [zombieGenTime], ax
  jmp zombieCreateRet
zombieCreateRet:
  ret
endp createNewZombie

; allocateZombie() searchs for an available zombie memory and returns the index in bx
; returns -1 if no zombies left
proc allocateZombie
  push cx
  mov cx, numZombies
searchIndexLoop:
  mov ax, cx
  dec ax
  shl ax, 1

  mov bx, offset zombieHandler
  add bx, ax
  cmp [word ptr bx], FALSE ; is place free
  je allocateIndex
  loop searchIndexLoop
  jmp allocateZombieRet
allocateIndex:
  mov [word ptr bx], TRUE
allocateZombieRet:
  dec cx ; -1 if finished loop
  mov bx, cx
  pop cx
  ret
endp allocateZombie
