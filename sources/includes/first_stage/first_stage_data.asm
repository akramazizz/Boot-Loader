;************************************** first_stage_data.asm **************************************
      ; This function need to be written by you.
boot_drive db 0x0 ;boot_drive will store the boot drive number 
lba_sector dw 0x1 ;lba_sector will store the next sector 
spt dw 0x12 ;stores the number of sectors per track
hpc dw 0x2 ;stores the number of head per cylinders 
Cylinder dw 0x0 ;these three variables will be used when converting from logical block addressing to sylinders, heads, and sectors 
Head db 0x0
Sector dw 0x0
;these are all the strings to be read and printed based on the functions of the other programs 
disk_error_msg db 'Disk Error', 13, 10, 0
fault_msg db 'Unknown Boot Device', 13, 10, 0 
booted_from_msg db 'Booted from', 0
floppy_boot_msg db 'floppy', 13, 10, 0
drive_boot_msg db 'Disk', 13, 10, 0
greeting_msg db '1st Stage Loader', 13, 10, 0 
second_stage_loaded_msg db 13,10,'2nd Stage Loaded, press any key to resume', 0
dot db '.',0
newline db 13,10,0 
disk_read_segment dw 0
disk_read_offset dw 0 
