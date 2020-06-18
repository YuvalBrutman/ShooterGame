; moveObject(offset(dw) x, offset(dw) y, dw velX, dw velY)- moves an object in x,y by velX, velY
proc moveObject
  push bp
  mov bp, sp
  mov bx, [bp+10]
  mov ax, [bp+6]
  add [word ptr bx], ax ; x+=velX
  mov bx, [bp+8]
  mov ax, [bp+4]
  add [word ptr bx], ax ; y+=velY
  pop bp
  ret 8
endp moveObject

; gravitate(offset(dw) velY)- changes velY by g
proc gravitate
  push bp
  mov bp, sp
  mov bx, [bp+4]
  add [word ptr bx], G
  pop bp
  ret 2
endp gravitate




;isColliding(dw x1, y1, w1, h1, x2, y2, w2, h2 )-
;returns 1 in ax if object1 is colliding  with object2, 0 otherwise
proc isColliding
  push bp
  mov bp, sp

  mov ax, FALSE

  ; colliding if( x1<x2+w2 && x1+w1 > x2  )
  ; and if(y1<y2+h2 && y1+h1>y2 )

  mov dx, [bp+10] ; mov dx, x2
  add dx, [bp+6] ; add x2, w2
  cmp [bp+18], dx ; cmp x1, x2+w2
  ja isCollidingRet
  mov dx, [bp+18] ; mov dx, x1
  add dx, [bp+14] ; add x1, w1
  cmp dx, [bp+10] ; cmp x1+w1, x2
  jb isCollidingRet
  mov dx, [bp+8]; mov dx, y2
  add dx, [bp+4]; add y2, h2
  cmp [bp+16], dx; cmp y1, y2+h2
  ja isCollidingRet
  mov dx, [bp+16]; mov dx, y1
  add dx, [bp+12]; add y1, h1
  cmp dx, [bp+8]; cmp y1+h1, y2
  jb isCollidingRet

  mov ax, TRUE

isCollidingRet:
  pop bp
  ret 16
endp isColliding
