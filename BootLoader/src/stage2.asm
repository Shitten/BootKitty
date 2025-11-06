  [org 0x8000]
  [bits 32]





  protected_mode_entry:
  cli
  mov ax,0x10
  mov ds,ax
  mov es,ax
  mov ss,ax
  mov esp, 0x90000

vga_print1:
mov edi,0xB8000
mov esi,msg

.loops
mov al,[esi]
inc esi
or al,al
jz hangs
mov ah,0x05
 mov [edi], ax 
  add edi, 2
jmp .loops

hangs:
jmp long_mode_start


msg db "32 bit",0



long_mode_start:
cli

PML4T_ADDR equ 0x2000
PDPT_ADDR equ 0x3000
PDT_ADDR equ 0x4000
PT_ADDR equ 0x5000
Paging_size equ 4096
PT_ADDR_MASK equ 0xffffffffff000
PT_PRESENT equ 1                 ; marks the entry as in use
PT_READABLE equ 2                ; marks the entry as r/w
 
 mov edi,PML4T_ADDR    ;copy the addr to edi
 mov cr3,edi           ;paste the addr to cr3 for the cpu to know where the paging at

 xor eax,eax
 mov ecx,Paging_size
 rep stosd

 mov edi,cr3






 
 PML4T_ADDR equ 0x2000
PDPT_ADDR equ 0x3000
PDT_ADDR equ 0x4000
PD_ADDR equ 0x5000

PT_ADDR_MASK equ 0xffffffffff000
PT_PRESENT equ 1                 ; marks the entry as in use
PT_READABLE equ 2  

 mov DWORD [edi], PDPT_ADDR & PT_ADDR_MASK | PT_PRESENT | PT_READABLE

    mov edi, PDPT_ADDR
    mov DWORD [edi], PDT_ADDR & PT_ADDR_MASK | PT_PRESENT | PT_READABLE

    mov edi, PDT_ADDR
    mov DWORD [edi], PT_ADDR & PT_ADDR_MASK | PT_PRESENT | PT_READABLE



ENTRIES_PER_PT equ 512
SIZEOF_PT_ENTRY equ 8
PAGE_SIZE equ 0x1000

    mov edi, PT_ADDR
    mov ebx, PT_PRESENT | PT_READABLE
    mov ecx, ENTRIES_PER_PT      ; 1 full page table addresses 2MiB

.SetEntry:
    mov DWORD [edi], ebx
    add ebx, PAGE_SIZE
    add edi, SIZEOF_PT_ENTRY
    loop .SetEntry               ; Set the next entry.

CR4_PAE_ENABLE equ 1 << 5

    mov eax, cr4
    or eax, CR4_PAE_ENABLE
    mov cr4, eax


    EFER_MSR equ 0xC0000080
    EFER_LM_ENABLE equ 1 << 8

    mov ecx, EFER_MSR
    rdmsr
    or eax, EFER_LM_ENABLE
    wrmsr

    CR0_PM_ENABLE equ 1 << 0
CR0_PG_ENABLE equ 1 << 31

    mov eax, cr0
    or eax, CR0_PG_ENABLE | CR0_PM_ENABLE   ; ensuring that PM is set will allow for jumping
                                            ; from real mode to compatibility mode directly
    mov cr0, eax


lgdt [GDT.Pointer]
jmp 0x08:long_mode_entry



; Access bits
PRESENT        equ 1 << 7
NOT_SYS        equ 1 << 4
EXEC           equ 1 << 3
DC             equ 1 << 2
RW             equ 1 << 1
ACCESSED       equ 1 << 0

; Flags bits
GRAN_4K       equ 1 << 7
SZ_32         equ 1 << 6
LONG_MODE     equ 1 << 5

GDT:
    .Null: equ $ - GDT
        dq 0
    .Code: equ $ - GDT
        .Code.limit_lo: dw 0xffff
        .Code.base_lo: dw 0
        .Code.base_mid: db 0
        .Code.access: db PRESENT | NOT_SYS | EXEC | RW
        .Code.flags: db GRAN_4K | LONG_MODE | 0xF   ; Flags & Limit (high, bits 16-19)
        .Code.base_hi: db 0
    .Data: equ $ - GDT
        .Data.limit_lo: dw 0xffff
        .Data.base_lo: dw 0
        .Data.base_mid: db 0
        .Data.access: db PRESENT | NOT_SYS | RW
        .Data.Flags: db GRAN_4K | SZ_32 | 0xF       ; Flags & Limit (high, bits 16-19)
        .Data.base_hi: db 0
    .Pointer:
        dw $ - GDT - 1
        dq GDT


[bits 64]

long_mode_entry:
 
  vga_print:


  mov rdi, 0xB8000
  mov rsi, msgss

  
  .loop3:
  mov al,[rsi]
  inc rsi
  or al,al
  jz .hang1
  mov ah,0x05
  mov [rdi], ax
  add rdi, 2
  jmp .loop3
  .hang1:
  jmp $

  .hang4:
  jmp $



    msgss db "LONG MODE COMPLETE",0
    hlt


  times 512*7 - ($-$$) db 0

    
