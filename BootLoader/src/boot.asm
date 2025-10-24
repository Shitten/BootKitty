[org 0x7C00]                  ;initialzation of bios (non negoiable since some ibm enginners chosed this)
[bits 16]
.start:
cli
xor ax,ax
mov ds,ax
mov es,ax
mov ss,ax
mov sp,0x7C00

call a20_activate
call load_gdt

cli
lgdt [gdtr]
mov eax, cr0     ; copy Control Register 0 (CR0) → EAX
or eax, 1        ; set bit 0 (the PE bit, “Protectgiion Enable”)
mov cr0, eax     ; write it back into CR0
jmp 0x08:flush 




a20_activate:
in al, 0x92                   ;reads the byte from the system control a
or al, 2                      ;changes bit 1 to activate a20
out 0x92, al                  ;writes the saved changes back to the byte
ret


load_gdt:
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    ret



  gdt_start:
  dq 0x0000000000000000
  
   gdt_code:
   dw 0xFFFF
   dw 0x0000
   db 0x00
   db 0x9A
   db 0xCF
   db 0x00  
   

   gdt_data:
   dw 0xFFFF                    ; Limit 0-15
    dw 0x0000                    ; Base 0-15
    db 0x00                      ; Base 16-23  
    db 0x92                      ; Access byte
    db 0xCF                      ; Flags + Limit 16-19
    db 0x00                      ; Base 24-31
   
   gdt_end:
    gdtr:
    dw gdt_end - gdt_start - 1 
    dd gdt_start
    
    mov ah, 0x00       ; BIOS function: Set video mode
    mov al, 0x03       ; Mode 03h: 80x25 text mode, VGA, 16 colors
    int 0x10           ; Execute the command





 [bits 32]
flush:
jmp protected_mode_entry

protected_mode_entry:
 mov ax,0x10
 mov ds,ax
 mov es,ax
 mov ss,ax
 mov esp, 0x90000

mov edi, 0xB8000
mov ecx,80*25
mov esi,msgss
.loop3:
mov al,[esi]
inc esi
or al,al
jz .hang1
mov ah,0x0F
mov [edi], ax
add edi, 2
jmp .loop3
.hang1:
jmp $

msgss db "BOOT KITTY",0


 times 510 - ($-$$) db 0      ;just padding it to print 0 until it reach 510 bytes the last 2 bytes is for the signature for bios
 dw 0xAA55                    ;this means this is a valid bootloader (non negotiable)


