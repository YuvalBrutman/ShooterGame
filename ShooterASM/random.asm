;proc genRandom()- generates 0 or 1 to al
proc genRandom
  call setClock
  mov ax, [Clock]
  and ax, 111111111b
  ret
endp genRandom
