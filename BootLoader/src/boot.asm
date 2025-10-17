[org 0x7C00]                  ;initialzation of bios (non negoiable since some ibm enginners chosed this)
 mov si,msg                   ;gets the msg and copies it to si(cant change register name since 16 bit)
 .loop:
 mov al, [si]                 ;al is the printf but primitive and dereferences si(pointers 101)
 or al,al                     ;fancy way of saying if msg == 0 then flags it with zero flag that activates the jz(yeah ik its implicit which is why i hate it)
 jz a20_activate
 inc si                       ;moves on to the next string ( can use lodsd but i dont like black boxes)
 mov ah,0x0E                  ;ah is the command of what the bios will do 0x0E means teletype mode (must use this so that the bios knows its printing before using al which is the printf itself)
 int 0x10                     ;fancy way to start the command in bios
 jmp .loop                    ;repeats back to the loop

a20_activate:
in al, 0x92                   ;reads the byte from the system control a
or al, 2                      ;changes bit 1 to activate a20
out 0x92, al                  ;writes the saved changes back to the byte
test al,0x02                  ;checks the byte to see if its 0 or 1
jz print0                     ;activates if the byte is 0
jnz print                     ;activates if the byte is 1

print:
mov si, output
.loop1:
mov al,[si]
or al,al
jz .hang
inc si
mov ah,0x0E
int 0x10
jmp .loop1
.hang:                       ;loops to halt the program once it finishes reading the message buffer
 jmp $
  msg db "BOOT KITTY",0x0D,0x0A,0 
  output db "A3 gate activated",0x0D,0x0A,0

  print0:
mov si, output0
.loop0:
mov al,[si]
inc si
or al,al
jz .hang0
mov ah,0x0E
int 0x10
jmp .loop0
.hang0:                       ;loops to halt the program once it finishes reading the message buffer
 jmp $

  output0 db "A3 gate not activated",0
 
 

 times 510 - ($-$$) db 0      ;just padding it to print 0 until it reach 510 bytes the last 2 bytes is for the signature for bios
 dw 0xAA55                    ;this means this is a valid bootloader (non negotiable)


