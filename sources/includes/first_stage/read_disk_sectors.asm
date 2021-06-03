 ;************************************** read_disk_sectors.asm **************************************
      read_disk_sectors: ; This function will read a number of 512-sectors stored in DI 
                         ; The sectors should be loaded at the address starting at [disk_read_segment:disk_read_offset]
            ; This function need to be written by you.
pusha ;this function is to pushes the content of the general purpose registers onto the stack 
add di, [lba_sector] ;di=lba_sector 
mov ax, [disk_read_segment] ;ax=disk_read_segment
mov es, ax ;es=ax
add bx, [disk_read_offset] ;bx=disk_read_offset (will contain the offset)
mov dl, [boot_drive] ;move the number of the boot drive into boot_drive
.read_sector_loop:
call lba_2_chs ;call the function lba_2_chs
mov ah, 0x2 ;function 2 means read sectors
mov al, 0x1 ;function 1 means read only one sector 
mov cx, [Cylinder] ;store cylinder into cx
shl cx, 0x8 ;shift left  bits in cx
or cx, [Sector] ;store sector into cx
mov dh, [Head] ;store head into dh
int 0x13 ;interrupt function 0x13
jc .read_disk_error ;jump to read disk error if the carry is set (c=1) 
mov si, dot ;si='dot' ('.')
call bios_print ;call the function bios_print 
inc word [lba_sector] ;move on to the next sector 
add bx, 0x200 ;move on to the next memory location 
cmp word [lba_sector],di ;compare lba_sector to di 
jl .read_sector_loop ;if less than then loop again
jmp .finish ;jump to finish 
.read_disk_error:
mov si, disk_error_msg ;si=disk_error_msg (move the address of disk_error_msg into si)
call bios_print  ;call the function bios_print to print messagge that is stored in si on the screen
jmp hang ;jump to han to halt 
.finish:
popa ;restore all contents of the general purpose registers
ret ;return 



