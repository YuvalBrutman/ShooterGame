IDEAL
MODEL small
STACK 300h
DATASEG


	TRUE equ 1
	FALSE equ 0

	BLACK equ 0

	G equ 2

	bulletW equ 7
	bulletH equ 4

	legsW equ 52
	legsH equ 25

	upperBodyW equ 52
	upperBodyH equ 40

	playerW equ 52
	playerH equ 65

	playerXSpeed equ 5
	playerYSpeed equ -15

	zombieXSpeed equ 2

	NullColor equ 5h

	playerX dw 120
	playerY dw 190 - playerH
	playerVelX dw 0
	playerVelY dw 0
	playerBG db playerW*playerH dup (?)
	playerFlipX db FALSE
	playerHealth dw 100
	isPlayerHurt db FALSE


	bulletX dw 52
	bulletY dw 190 - playerH + 19
	bulletBG db bulletW*bulletH dup (?)
	bulletSpeed equ 25
	isBulletInAir db FALSE
	gunRecoil equ 6
	ShotgunDamage equ 50


	LegsStandFN db 'assets/stand.bmp',0,'$'
	LegsWalk1FN db 'assets/walk1.bmp',0,'$'
	LegsWalk2FN db 'assets/walk2.bmp',0,'$'
	LegsWalk3FN db 'assets/walk3.bmp',0,'$'

	LegsStand db legsW*legsH dup (?)
	LegsWalk1 db legsW*legsH dup (?)
	LegsWalk2 db legsW*legsH dup (?)
	LegsWalk3 db legsW*legsH dup (?)
	legsAnimation dw 4 dup (?)
	playerLegsState db 0
	playerScore dw 0

	bodyRegFN db 'assets/reg.bmp',0,'$'
	bodyDownFN db 'assets/down.bmp',0,'$'
	bodyUpFN db 'assets/up.bmp',0,'$'

	bodyReg db upperBodyW*upperBodyH dup (?)
	bodyDown db upperBodyW*upperBodyH dup (?)
	bodyUp db upperBodyW*upperBodyH dup (?)

	zombieW equ 52
	zombieH equ 64
	zombieDamage equ 10
	bulletFlipX db FALSE

	numZombies equ 4

	zombieMaxHealth equ 100

	zombieXs dw numZombies dup (?)
	zombieYs dw numZombies dup (190 - zombieH)
	zombieVelXs dw numZombies dup (0)
	zombieVelYs dw numZombies dup (0)
	zombieFlipXs dw numZombies dup (?)
	zombieBGs db numZombies*zombieW*zombieH dup (?)
	zombieBGAddresses dw numZombies dup (?)
	zombieHealths dw numZombies dup (zombieMaxHealth)

	zombieHandler dw numZombies dup (FALSE)

	; zombieX dw 250
	; zombieY dw 190 - zombieH
	; zombieVelX dw 0
	; zombieVelY dw 0
	; zombieBG db zombieW*zombieH dup (?)
	zombieArr db zombieW*zombieH dup (?)
	; zombieHealth dw 100
	; zombieFlipX db TRUE
	zombieFileName db 'assets/zombie.bmp',0,'$'

	Clock equ es:6Ch
	walkTime dw 0
	walkInterval equ 3
	playerHurtTime dw 0
	playerHurtInterval equ 18
	zombieGenTime dw 0
	zombieGenInterval equ 36

	BGfilename db 'assets/bgsmall.bmp',0,'$'


	filehandle dw ?
	Header db 54 dup (0)
	Palette db 256*4 dup (0)
	ScrLine db 320 dup (0)
	OpenErrorMsg db 'error: could not open file $'
	HealthMsg db 'Health: $'
	ScoreMsg db 'Score: $'
	TabMsg db '  $'
	GameOverMsg db 'Game Over! you loser :]',10,13,'$'


CODESEG

include "time.asm"
include "readbmp.asm"
include "Graphics.asm"
include "playerG.asm"
include "Input.asm"
include "movement.asm"
include "zombie.asm"
include "bullet.asm"
include "random.asm"


start:
	mov ax, @data
	mov ds, ax

	mov ax, 13h
	int 10h

	call printBG
	call DisplayPlayerStats
	call setClock
	mov ax, [Clock]
	mov [playerHurtTime], ax
	call loadZombieBMPs
	call CopyPal

	call loadPlayerBMPs

	; mov [zombieHandler], TRUE
	; mov [zombieXs], 100
	; mov [zombieYs], 190-zombieH
	;
	; mov [zombieHandler+2], TRUE
	; mov [zombieXs+2], 200
	; mov [zombieYs+2], 190-zombieH

	;call readZombieBGs

	call showZombies

	call readPlayerBG
	call showPlayer
	call readZombieBGs
inputLoop:
	push [playerHurtTime]
	call ticksSince
	cmp ax, playerHurtInterval
	jb checkKey
	mov [isPlayerHurt], FALSE

checkKey:
	call getKey ; ax = corrent key (0 if no key prresed)
	cmp ax, 0
	je noChange

	cmp al, 1
	jne dontExit
	jmp GameOver
dontExit:

	cmp al, 04Dh ; hit up (down)
	je moveRight
	cmp al, 04Bh ; hit up (down)
	je moveLeft
	cmp al, 048h ; hit up (down)
	je moveUp
	cmp al, 039h ; hit space (down)
	je shoot

noChange:
	mov [playerVelX], 0
	jmp showMove

moveRight:
	mov [playerVelX], playerXSpeed
	mov [playerFlipX], FALSE

doWalkAnim:
	push [walkTime]
	call ticksSince
	cmp ax, walkInterval
	jb DontWalkYet
	mov ax, [Clock]
	mov [walkTime], ax

	inc [playerLegsState]
	cmp [playerLegsState], 3
	ja resetWalk
DontWalkYet:
	jmp showMove
resetWalk:
	mov [playerLegsState], 1
	jmp showMove

moveLeft:
	mov [playerVelX], -playerXSpeed
	mov [playerFlipX], TRUE
	jmp doWalkAnim
moveUp:
	cmp [playerY], 190-playerH
	jb showMove
	mov [playerVelY], playerYSpeed
	mov [playerLegsState], 1
	jmp showMove

shoot:
	cmp [isBulletInAir], FALSE
	jne showMove
	mov al, [playerFlipX]
	mov [bulletFlipX], al
	cmp al, TRUE
	je resetBulletXLeft
	mov ax, [playerX]
	add ax, 52
	mov [bulletX], ax
	add [playerVelX], -gunRecoil
	jmp resetBulletY
resetBulletXLeft:
	mov ax, [playerX]
	sub ax, bulletW
	mov [bulletX], ax
	add [playerVelX], gunRecoil


resetBulletY:
	mov ax, [playerY]
	add ax, 19
	mov [bulletY], ax
	mov [isBulletInAir], TRUE

	push offset bulletBG
	push [bulletX]
	push [bulletY]
	call readBulletBG

showMove:
	cmp [isBulletInAir], TRUE
	jne DoClearZombie

	push offset bulletX
	push offset bulletY
	push offset bulletBG
	xor ax, ax
	mov al, [bulletFlipX]
	push ax
	call moveBullet

DoClearZombie:
	; cmp [zombieHealth], 0
	; jle checkPlayerMovement

	call ClearZombies
	call allZombiesAI


checkPlayerMovement:
	cmp [playerVelX], 0
	jne hasMoved
	cmp [playerVelY], 0
	jne hasMoved

	cmp [playerLegsState], 0
	je MoveReadZombies
	mov [playerLegsState], 0

hasMoved:
	call ClearPlayer

	push offset playerX
	push offset playerY
	push [playerVelX]
	push [playerVelY]
	call moveObject
	call checkPlayerBounderies
	call readPlayerBG

	call createNewZombie

	call showPlayer

	call moveZombies
	call readZombieBGs

	jmp endMove

MoveReadZombies:
	call moveZombies
	call readZombieBGs

endMove:
	call createNewZombie

	call checkzombiesHealth

doMoveZombie:
	call showZombies

checkPlayerHealth:
	cmp [playerHealth], 0
	jle GameOver

	call waitOneTick

	jmp inputLoop

	waitKey:
		; Wait for key press
		mov ah,1
		int 21h

GameOver:
	; Back to text mode
	mov ah, 0
	mov al, 2
	int 10h

	mov dx, offset GameOverMsg
	mov ah, 9h
	int 21h

	mov dx, offset ScoreMsg
	mov ah, 9h
	int 21h

	push [playerScore]
  call printDecimal

exit:
	mov ax, 4c00h
	int 21h
	END start
