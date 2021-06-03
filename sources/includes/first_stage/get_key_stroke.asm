;************************************** get_key_stroke.asm **************************************      
        get_key_stroke: ; A routine to print a confirmation message and wait for key press to jump to second boot stage
        ; This function need to be written by you.
pusha ;this function is to pushes the content of the general purpose registers onto the stack
;these next 2 lines are used to wait for keystroke and read , when ah is 0, int 0x16 will wait for the keystroke  
mov ah, 0x0
int 0x16 ;interrupt function 16
popa ;restore all contents of the general purpose registers
ret ;return
