;************************************** detect_boot_disk.asm **************************************      
      detect_boot_disk: ; A subroutine to detect the the storage device number of the device we have booted from
                        ; After the execution the memory variable [boot_drive] should contain the device number
                        ; Upon booting the bios stores the boot device number into DL
            ; This function need to be written by you.
pusha ;this function is to pushes the content of the general purpose registers onto the stack
mov si, fault_msg ;si= fault_msg (move fault message into si)
xor ax,ax ;ax=0 
int 0x13 ;interrupt function for resetting drive
jc .exit_with_error ;jump to exit with error if the carry is set (c=1) 
mov si, booted_from_msg ;si=booted_from_msg (move booted from msg to si)
call bios_print ;call the function bios_print to print on the screen 
mov [boot_drive], dl ;move the number of the boot drive into boot_drive
cmp dl, 0 ;compare 0 and dl, if 0 then it is the floppy disk
je .floppy ;if dl=0 then jump to .floppy
call load_boot_drive_params ;call the function load_boot_drive_params
mov si, drive_boot_msg ;si= address of drive_boot_msg (move drive boot msg into si)
jmp .finish ;jump to .finish 
.floppy: ;this function means that it is floppy
mov si, floppy_boot_msg ;si= address of floppy_boot_msg (move floppy_boot_msg into si)
jmp .finish ;jump to .finish 
.exit_with_error:
jmp hang ;jump to han to halt 
.finish: ;this function is to print message on the screen
call bios_print ;call the function bios_print to print messagge that is stored in si on the screen 
popa ;restore all contents of the general purpose registers
ret ;return
