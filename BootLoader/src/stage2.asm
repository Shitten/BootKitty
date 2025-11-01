  [org 0x8000]
  [bits 32]





  protected_mode_entry:
  cli
  mov ax,0x10
  mov ds,ax
  mov es,ax
  mov ss,ax
  mov esp, 0x90000




  vga_print:


  mov edi, 0xB8000
  mov esi, msgss

  cld
  .loop3:
  mov al,[esi]
  inc esi
  or al,al
  jz .hang1
  mov ah,0x40
  mov [edi], ax
  add edi, 2
  jmp .loop3
  .hang1:
  jmp $

  .hang4:
  jmp $



    msgss db "FUCK YOU",0


  times 512*7 - ($-$$) db 0

    
