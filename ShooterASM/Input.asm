proc getKey
WaitForKey:
  ; check if there is a a new key in buffer
  in al, 64h
  cmp al, 10b
  je retZero

  in al, 60h
  jmp retKey
retZero:
  xor al, al
retKey:
  ret
endp getKey
