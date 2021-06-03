;************************************** bios_print.asm **************************************      
      bios_print:       ; A subroutine to print a string on the screen using the bios int 0x10.
                    ;Expects si to have the address of the string to be printed.
                    ;Will loop on the string characters, printing one by one. 
                    ;Will Stop when encountering character 0.
        ;This function need to be written by you.    

pusha ;this function is to pushes the content of the general purpose registers onto the stack 
.print_loop:
xor ax,ax ;ax=0
lodsb ;load byte at address DS:(E)SI into al (take a byte from SI and load the byte into register al)
or al, al ;al=0 and hence if al is 0 then set the zero flag 
jz .done ;if the result is 0 then jumo to .done 
mov ah, 0x0E ;it prints one character of text in the console in text mode and moves the cursor to the next position
int 0x10 ;interrupt function to print the character
jmp .print_loop ;loop to move the cursor onto the next position or character
.done:
popa ;restore all contents of the general purpose registers
ret ;return 
