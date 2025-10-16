[org 0x7C00]                  ;initialzation of bios (non negoiable since some ibm enginners chosed this)

 mov si,msg                   ;gets the msg and copies it to si(can change register name since 16 bit)
 .loop:
 mov al, [si]                 ;al is the printf but primitive and dereferences si(pointers 101)
 inc si                       ;moves on to the next string ( can use lodsd but i dont like black boxes)
 or al,al                     ;fancy way of saying if msg == 0 then flags it with zero flag that activates the jz(yeah ik its implicit which is why i hate it)
 jz .hang
 mov ah,0x0E                  ;ah is the command of what the bios will do 0x0E means teletype mode (must use this so that the bios knows its printing before using al which is the printf itself)
 int 0x10                     ;fancy way to start the command in bios
 jmp .loop                    ;repeats back to the loop
 .hang:                       ;loops to halt the program once it finishes reading the message buffer
 jmp $
 msg db "OKDOKI",0 
 times 510 - ($-$$) db 0      ;just padding it to print 0 until it reach 510 bytes the last 2 bytes is for the signature for bios
 dw 0xAA55                    ;this means this is a valid bootloader (non negotiable)
