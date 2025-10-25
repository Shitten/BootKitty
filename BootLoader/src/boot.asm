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


idt_start:
times 256 dq 0
idt_descriptor:
dw 256 * 8 -1
dd idt_start

lidt [idt_descriptor]

ret
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
cli
 mov ax,0x10
 mov ds,ax
 mov es,ax
 mov ss,ax
 mov esp, 0x90000

 call cpuid_start
jmp cpuid_test


cpuid_start:
pushfd
pushfd
xor dword [esp],0x00200000
popfd
pushfd
 pop eax                              ;eax = modified EFLAGS (ID bit may or may not be inverted)
    xor eax,[esp]                        ;eax = whichever bits were changed
    popfd                                ;Restore original EFLAGS
    and eax,0x00200000                   ;eax = zero if ID bit can't be changed, else non-zero
    ret

cpuid_test:

test eax,eax
jz .no_cpuid
jmp cpuid_ok

.no_cpuid:
jmp $

cpuid_ok:
mov eax,0x0
cpuid
jmp vga_print

vga_print:


mov edi, 0xB8000
mov [msgss+0],ebx
mov [msgss+4],edx
mov [msgss+8],ecx
mov esi, msgss
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



  msgss db 13 dup(0),0

 times 510 - ($-$$) db 0      ;just padding it to print 0 until it reach 510 bytes the last 2 bytes is for the signature for bios
 dw 0xAA55                    ;this means this is a valid bootloader (non negotiable)


