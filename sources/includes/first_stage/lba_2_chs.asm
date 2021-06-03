 ;************************************** lba_2_chs.asm **************************************
 lba_2_chs:  ; Convert the value store in [lba_sector] to its equivelant CHS values and store them in [Cylinder],[Head], and [Sector]
              ; This function need to be written by you.
pusha ;this function is to pushes the content of the general purpose registers onto the stack 
xor dx, dx ;dx=0
mov ax, [lba_sector] ;ax= lba_sector (move lba_sector into ax)
div word [spt] ;divide (lba_sector)/spt
inc dx ;dx will store the remainder of the division and hence we will increment it to get the sector
mov [Sector], dx ;sector=remainder of the above division
xor dx,dx ;dx=0
div word [hpc] ;divide (lba_sector/spt)/hpc
mov [Cylinder], ax ;Cylinder=ax which means that Cylinder=quotient of the division
mov [Head], dl ;Head=remainder of the division
popa ;restore all contents of the general purpose registers
ret ;return 
