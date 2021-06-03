;************************************** bios_cls.asm **************************************      
      bios_cls:   ; A routine to initialize video mode 80x25 which also clears the screen
            ; This function need to be written by you.
pusha ;this function is to pushes the content of the general purpose registers onto the stack 
;the following functions are to set the video mode and text mode, we start by 
;setting the video mode then setting it to text mode 80x25 chars and 16 colors 
mov ah, 0x0 ;set the video mode
mov al, 0x3 ;set the text mode 
int 0x10 ;interrupt function to set video mode
popa ; restore all contents of the general purpose registers 
ret ;return

