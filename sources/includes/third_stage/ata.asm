; The Command Register and trhe BASE I/O ports can be retrieved from the PCI BARs, but they are kind of standard and we will define them here for better code presentability
; When we write it is considered CR, and when we read what is returned is the AS Register
%define ATA_PRIMARY_CR_AS        0x3F6 ; ATA Primary Control Register/Alternate Status Port
%define ATA_SECONDARY_CR_AS      0x376 ; ATA Secondary Control Register/Alternate Status Port

%define ATA_PRIMARY_BASE_IO          0x1F0 ; ATA Primary Base I/O Port, up to 8 ports available to 0x1F7
%define ATA_SECONDARY_BASE_IO          0x170 ; ATA Primary Base I/O Port, up to 8 ports available to 0x177

%define ATA_MASTER              0x0     ; Mastrer Drive Indicator
%define ATA_SLAVE               0x1     ; SLave Drive Indicator

%define ATA_MASTER_DRV_SELECTOR    0xA0     ; Sent to ATA_REG_HDDEVSEL for master
%define ATA_SLAVE_DRV_SELECTOR     0xB0     ; sent to ATA_REG_HDDEVSEL for slave


; Commands to issue to the controller channels
%define ATA_CMD_READ_PIO          0x20      ; PIO LBA-28 Read
%define ATA_CMD_READ_PIO_EXT      0x24      ; PIO LBA-48 Read
%define ATA_CMD_READ_DMA          0xC8      ; DMA LBA-28 Read
%define ATA_CMD_READ_DMA_EXT      0x25      ; DMA LBA-48 Read
%define ATA_CMD_WRITE_PIO         0x30      ; PIO LBA-28 Write
%define ATA_CMD_WRITE_PIO_EXT     0x34      ; PIO LBA-48 Write
%define ATA_CMD_WRITE_DMA         0xCA      ; DMA LBA-28 Write
%define ATA_CMD_WRITE_DMA_EXT     0x35      ; DMA LBA-48 Write
%define ATA_CMD_IDENTIFY          0xEC      ; Identify Command

; Different Status values where each bit represents a status
%define ATA_SR_BSY 0x80             ; 10000000b     Busy
%define ATA_SR_DRDY 0x40            ; 01000000b     Drive Ready
%define ATA_SR_DF 0x20              ; 00100000b     Drive Fault
%define ATA_SR_DSC 0x10             ; 00010000b     Overlapped mde
%define ATA_SR_DRQ 0x08             ; 00001000b     Set when the drive has PIO data to transfer
%define ATA_SR_CORR 0x04            ; 00000100b     Corrected Data; always set to zero
%define ATA_SR_IDX 0x02             ; 00000010b     Index Status always set to Zero
%define ATA_SR_ERR 0x01             ; 00000001b     Error


; Ports offsets that can be used relative to the I/O base ports above.
; The use of the offset is defined by the ATA data sheet specifications.
%define ATA_REG_DATA       0x00
%define ATA_REG_ERROR      0x01
%define ATA_REG_FEATURES   0x01
%define ATA_REG_SECCOUNT0  0x02     ; Used to send the number of sectors to read, max 256
%define ATA_REG_LBA0       0x03     ; LBA0,1,2 are used to store the address of the first sector (24-bits)
%define ATA_REG_LBA1       0x04     ; Incase of LBA-28 the remaining 4 bits are sent as the higher 4 bits of
%define ATA_REG_LBA2       0x05     ; ATA_REG_HDDEVSEL when selecting the drive
%define ATA_REG_SECCOUNT1  0x02     ; Used for LBA-48 which allows 16 bit for the number of sector to be read, max 65536 
%define ATA_REG_LBA3       0x03     ; The rmaining 20-bit to acheive LBA-48 and nothing is written to  ATA_REG_HDDEVSEL
%define ATA_REG_LBA4       0x04
%define ATA_REG_LBA5       0x05
%define ATA_REG_HDDEVSEL   0x06     ; The register for selecting the drive, master of slave
%define ATA_REG_COMMAND    0x07     ; This register for sending the command to be performed after filling up the rest of the registers
%define ATA_REG_STATUS     0x07     ; This register is used to read the status of the channel

ata_pci_header times 1024 db 0  ; A memroy space to store ATA Controller PCI Header (4*256)
; Indexed values
ata_control_ports dw ATA_PRIMARY_CR_AS,ATA_SECONDARY_CR_AS,0
ata_base_io_ports dw ATA_PRIMARY_BASE_IO,ATA_SECONDARY_BASE_IO,0
ata_slave_identifier db ATA_MASTER,ATA_SLAVE,0
ata_drv_selector db ATA_MASTER_DRV_SELECTOR,ATA_SLAVE_DRV_SELECTOR,0

ATA_disk_print db 'ATA disk stats:',13,0
ata_error_msg       db "Error Identifying Drive",13,10,0
ata_identify_msg    db "Found Drive",0
ata_identify_buffer times 2048 db 0  ; A memroy space to store the 4 ATA devices identify details (4*512)
ata_identify_buffer_index dw 0x0
ata_channel db 0
ata_slave db 0  
lba_48_supported db 'LBA-48 Supported',0
align 4

;this struct defines the configuration space of a single disk, it contains a lot of things like device type, etc.  
struc ATA_IDENTIFY_DEV_DUMP                    ; Starts at
.device_type                resw              1
.cylinders                  resw              1 ; 1
.gap0                       resw              1 ; 2
.heads                      resw              1 ; 3
.gap1                       resw              2 ; 4
.sectors                    resw              1 ; 6
.gap2                       resw              3 ; 7
.serial                     resw              10 ; 10
.gap3                       resw              3  ; 20
.fw_version                 resw              4  ; 23
.model_number               resw              20 ; 27
.gap4                       resw              2  ; 47
.capabilities               resw              1  ; 49       Bit-9 set for LBA Support, Bit-8 for DMA Support
.gap5                       resw              3  ; 50
.avail_bf                   resw              1  ; 53
.current_cyl                resw              1  ; 54
.current_hdr                resw              1  ; 55
.current_sec                resw              1  ; 56
.total_sec_obs              resd              1  ; 57
.gap6                       resw              1  ; 59
.total_sec                  resd              1  ; 60       Number of sectors when in LBA-28 mode
.gap7                       resw              1  ; 62
.dma_mode                   resw              1  ; 63
.gap8                       resw              16 ; 64
.major_ver_num              resw              1  ; 80
.minor_ver_num              resw              1  ; 81
.command_set1               resw              1  ; 82
.command_set2               resw              1  ; 83
.command_set3               resw              1  ; 84
.command_set4               resw              1  ; 85
.command_set5               resw              1  ; 86       Bit-10 is set if LBA-48 is supported
.command_set6               resw              1  ; 87
.ultra_dma_reporting        resw              1  ; 88
.gap9                       resw              11 ; 89
.lba_48_sectors             resq              1  ; 100      Number of sectors when in LBA-48 mode
.gap10                      resw              23 ; 104
.rem_media_status_notif     resw              1  ; 127
.gap11                      resw              48 ; 128
.curret_media_serial_number resw              1  ; 176
.gap12                       resw             78 ; 177
.integrity_word             resw              1  ; 255      Checksum
endstruc
;;;;;notes for me
;;;First we need to introduce some macro definitions for different values which will make our lives much easier.
;;;We then need to issue the famous IDENTIFY command to detect different connected devices and inquire about their attributes; e.g. serial #, fw_version, no. of sectors, LBA support, DMA support.
;;;We can then issue read and write commands to the drives to store and retrieve sectors from the storage

ata_copy_pci_header: ;this function will copy the pci header from the pci_header to a special memory buffer which is the ata_pci_header upon finding a device with classcode=1 and subclass code=1
pushaq
      ; This function need to be written by you.
mov rdi,ata_pci_header ;move rdi=ata_pci_header
mov rsi,pci_header ;move rsi= pci_header
mov rcx, 0x20 ;rcx will act as a coutner which will initially store the value 256 
xor rax, rax ;rax=0
cld ;clear direction flag and decrement rcx, the counter, in order to know how many times are left 
rep stosq ;store address rax at address rdi in order to obtain the ATA channel 
popaq
ret

;this function is responsible for selecting a disk from a channel so it takes two
;parameters: the channel (rdi) and an rsi value that indicates whether master or slave (1 meaning slave, 0 meaning master)
select_ata_disk:              ; rdi = channel, rsi = master/slave
pushaq
    ; This function need to be written by you.
xor rax,rax ;rax=0
mov dx,[ata_base_io_ports+rdi] ; we define the ata base port and by adding to it rdi we obtain the i/o port for the corresponding channel
;(ata_base is an array hence if the rdi contains 0, it will take the first value of the array, if 1 then the second)
add dx,ATA_REG_HDDEVSEL ;add into dx the value of port for the HDDEV select (0x06)
mov al,byte [ata_drv_selector+rsi] ;ata_drv_selector+rsi tells us if its a slave or master,
;if rsi 0 then the first part of the array will be selected which is master, if 1 then the second part of the array which is slave
out dx,al ;then we will out to the port number the selector of a specific device so this will set the controller to operate on that specific device for subsequent operations 
popaq
ret

;this function will print the ata_info has some of the fields we read 
ata_print_size:
pushaq
        ; This function need to be written by you.

mov rsi, newline
call video_print

mov dl, 0x84
mov rsi,ATA_disk_print                   
call video_print

mov byte [ata_identify_buffer+39],0x0
mov dl, 0x84
mov rsi, ata_identify_buffer+ATA_IDENTIFY_DEV_DUMP.serial ;it will print the serial number 
call video_print
mov dl, 0x84
mov rsi,comma ;print a comma
call video_print
mov byte [ata_identify_buffer+50],0x0
mov dl, 0x84
mov rsi, ata_identify_buffer+ATA_IDENTIFY_DEV_DUMP.fw_version ;print the firmware version
call video_print
mov dl, 0x84
mov rsi,comma ;print a comma
call video_print
xor rdi,rdi ;rdi=0
mov dl, 0x84
mov rdi, qword [ata_identify_buffer+ATA_IDENTIFY_DEV_DUMP.lba_48_sectors] ;print the number of LBA sectors
call video_print_hexa
mov ax, 0000010000000000b
and ax,word [ata_identify_buffer+ATA_IDENTIFY_DEV_DUMP.command_set5] ;it will check whether LBA48 is supported or not
cmp ax,0x0 ;compare ax with 0
je .out ;if equal then jump to out to print newline
mov dl, 0x84  ;
mov rsi,comma
call video_print
mov dl, 0x84
mov rsi,lba_48_supported ;print that lba48 is supported 
call video_print
.out:
mov dl, 0x84
mov rsi,newline
call video_print

;mov rsi,hello_world_str2 ;print newline
;call video_print


popaq
ret

;this function is used to identify the disk hence we need to read the data of the disk
;so we need to reinitialize and refresh that channel that we want to read from a disk 
ata_identify_disk:              ; rdi = channel, rsi = master/slave
pushaq
;we write 0s to the control port of the corresponding channel and this way we are refreshing the channel
xor rax,rax 
mov dx,[ata_control_ports+rdi]
out dx,al
call select_ata_disk ;by calling the select_ata_disk, we will select the disk we want to identify 
;then here we will 0 out all of these ports: the sector number (ATA_REG_SECCOUNT0), ATA_REG_LBA0, ATA_REG_LBA1, and ATA_REG_LBA2
xor rax,rax 
mov dx,[ata_base_io_ports+rdi] 
add dx,ATA_REG_SECCOUNT0 ;zero ATA_REG_SECCOUNT0
out dx,al
mov dx,[ata_base_io_ports+rdi]
add dx,ATA_REG_LBA0 ;zero ATA_REG_LBA0 
out dx,al
mov dx,[ata_base_io_ports+rdi]
add dx,ATA_REG_LBA1 ;zero ATA_REG_LBA1
out dx,al
mov dx,[ata_base_io_ports+rdi]
add dx,ATA_REG_LBA2 ;zero ATA_REG_LBA2
out dx,al
mov dx,[ata_base_io_ports+rdi] 
add dx,ATA_REG_COMMAND ;then send to the ATA_REG_COMMAND, the identify command 
mov al,ATA_CMD_IDENTIFY
out dx,al
mov dx,[ata_base_io_ports+rdi] 
add dx,ATA_REG_STATUS ;then read the status from the same drive 
in al, dx
cmp al, 0x2 ;compare the status (al) with 2 
jl .error ;if the status is less than 2 then this means an error happened hence jump to error to print that an error occured 

.check_ready: ;else we need to wait until the disk controller is ready hence we keep reading the status if any one of the errors occur then we will keep on looping.
mov dx,[ata_base_io_ports+rdi]
add dx,ATA_REG_STATUS
in al, dx
xor rcx,rcx
;if ATA_SR_ERR and ATA_SR_ERR are errors then I will jump to .error 
mov cl,ATA_SR_ERR ;comparing to see if they are equal
and cl,al
cmp cl,ATA_SR_ERR
je .error ;if equal then jump to .error 
mov cl,ATA_SR_DRQ ;if I read ATA_SR_DRQ which is set when the drive has PIO data to transfer then this means that its still moving data from the drive
;hence I will keep looping till it is not equal to DRQ or ERR then I will continue 
and cl,al
cmp cl,ATA_SR_DRQ ;comparing to see if they are equal 
jne .check_ready ;if not equal keep looping till they are 
jmp .ready ;if equal jump to .ready 
.error: 
mov dl, 0x84
mov rsi,ata_error_msg ;for printing that there is an error 
call video_print
jmp .out
.ready: 
mov dl, 0xCF
mov rsi,ata_identify_msg ;print message 
call video_print
mov rdx,[ata_base_io_ports+rdi] ;fetch the port number 
mov si,word [ata_identify_buffer_index] ;fetch the buffer that i am going to read to 
mov rdi,ata_identify_buffer ;rdi=ata_identify_buffer
mov rcx, 256 ;rcx= 256 
xor rbx,rbx ;rbx=0
rep insw ;rep in single word, this will read the 256 words from the port in a loop that will
;retrieve 512 bytes into ata_identify_buffer_index hence now we have the whole configuration stored in this buffer of that specific disk 
add word [ata_identify_buffer_index],256
call ata_print_size  ;hence here i will print the ata_info which will some of the fields we read 
        ; This function need to be written by you.

.out:
popaq
ret
