;************************************** load_boot_drive_params.asm **************************************
      load_boot_drive_params: ; A subroutine to read the [boot_drive] parameters and update [hpc] and [spt]
            ; This function need to be written by you.
pusha ;this function is to pushes the content of the general purpose registers onto the stack 
xor di,di ;di=0
mov es, di ;es=di
mov ah, 0x8 ;this function reads how many cylinders, heads per cylinder, sectors per track (disk parameters) 
mov dl, [boot_drive] ;dl=the disk number that we want to get the parameters of
int 0x13 ;interrupt 13 
inc dh ;increment dh
mov word [hpc], 0x0 ;hpc=0
mov [hpc+1], dh ;store dh in the position hpc+1
and cx, 0000000000111111b ;by anding cx and this vector we will be able to obtain the sector per track by taking the 6 right most bits of cx
mov word [spt], cx ;move the number of sectors which is stored in cx into spt
popa ;restore all contents of the general purpose registers
ret ;return

