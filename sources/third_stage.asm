[ORG 0x10000]
%define ATA_COLOR  0x84
[BITS 64] 


call video_cls



;mov rsi, bitmap_start
;call video_print
;call BitMap
;mov rsi, bitmap_end
;call video_print



Kernel:

mov dl, 0x1F
mov rsi, hello_world_str
call video_print
mov dl, 0x1F
mov rsi, hello_world_str
call video_print
mov dl, 0x1F
mov rsi, hello_world_str
call video_print
mov dl, 0x1F
mov rsi, hello_world_str
call video_print
mov dl, 0x1F
mov rsi, hello_world_str
call video_print
mov dl, 0x1F
mov rsi, hello_world_str
call video_print
 mov rsi, msg_scan_device
mov dl, 0xaf
call video_print
bus_loop:
    device_loop:
        function_loop:
            call get_pci_device
            mov ax, word[pci_header+PCI_CONF_SPACE.device_id]       ;get the device ID from the struct
            cmp ax,0xffff                                           ;check if the value of the device ID is 0xffff meaning there is no device conected
            je .no_device
            mov r8, qword[memory_pci_header]            ;this will have the value of 100_000
            add r8, qword[memory_pci_header_size]       ; will indicate the size of used bits
            mov r9,r8                                   ; r9 will have the summation of 100_000 and moving the same amount of bits used
            mov r10, pci_header                         ; r10 will have the address of pci_header. (the buffer)
            mov r11, 32                                 ; move the value of 32 into r11
            .loop:
            mov r12,qword[r10]                          ;r12 will have the qword stored in the buffer
            mov qword[r9], r12                          ;move the value fetched, into the memory alocation
            add r9,8                                    ;advance r9
            add r10,8                                   ;advanve r10
            dec r11                                     ;decrement r11 by 1
            cmp r11,0                                   ;check if the counter reaches 0
            je .exit                                    
            jmp .loop                                   

            .exit:
            add qword[memory_pci_header_size], 256     ;add the value of 256 (32*8)

            .no_device:
            inc byte [function]
            cmp byte [function],8
        jne device_loop
        inc byte [device]
        mov byte [function],0x0
        cmp byte [device],32
        jne device_loop
    inc byte [bus]
    mov byte [device],0x0
    cmp byte [bus],255
    jne bus_loop

channel_loop:
    mov qword [ata_master_var],0x0
    master_slave_loop:
        mov rdi,[ata_channel_var]
        mov rsi,[ata_master_var]
        call ata_identify_disk
        inc qword [ata_master_var]
        cmp qword [ata_master_var],0x2
        jl master_slave_loop

    inc qword [ata_channel_var]
    inc qword [ata_channel_var]
    cmp qword [ata_channel_var],0x4
    jl channel_loop

    ;call BitMap
    ;call get_key_stroke


call init_idt
call setup_idt
call configure_pit

mov dl, 0x1F
mov rsi, hello_world_str
call video_print
mov dl, 0x1F
mov rsi, hello_world_str
call video_print
mov dl, 0x1F
mov rsi, hello_world_str
call video_print
mov dl, 0x1F
mov rsi, hello_world_str
call video_print
;mov dl, 0x1F
;mov rsi, hello_world_str
;call video_print
;mov dl, 0x1F
;mov rsi, hello_world_str
;call video_print
;mov dl, 0x1F
;mov rsi, hello_world_str
;call video_print


;we should put here a test to pass an address to dissect

kernel_halt: 
    hlt
    jmp kernel_halt


;*******************************************************************************************************************
      %include "sources/includes/third_stage/pushaq.asm"
      %include "sources/includes/third_stage/popaq.asm"
      ;%include "sources/includes/third_stage/memory_testing.asm" ;memory testing, a new file added in the third stage 
      %include "sources/includes/third_stage/pic.asm"
      %include "sources/includes/third_stage/idt.asm"
      %include "sources/includes/third_stage/pci.asm"
      %include "sources/includes/third_stage/video.asm"
      %include "sources/includes/third_stage/pit.asm"
      %include "sources/includes/third_stage/ata.asm"
     ; %include "sources/includes/third_stage/BitMap.asm"
     ; %include "sources/includes/third_stage/BitMapScanner.asm"
     ; %include "sources/includes/third_stage/Page_Walk.asm"
     ; %include "sources/includes/third_stage/PageFault.asm"
    
;*******************************************************************************************************************



colon db ':',0
comma db ',',0
newline db 13,0

end_of_string  db 13        ; The end of the string indicator
start_location   dq  0x0  ; A default start position (Line # 8)

    hello_world_str db 'Hello all here',13, 0



    bitmap_start    db 'Bit Map is being created', 13, 0
    bitmap_end    db 'Bit Map created successfully ', 13, 0
    scanning_bitmap    db 'Scanning bitmap for available frames ', 13, 0
    Create_PML4    db ' Creating the PML4 entries of the page table ', 13, 0


    ata_channel_var dq 0
    ata_master_var dq 0

    bus db 0
    device db 0
    function db 0
    offset db 0
    hexa_digits       db "0123456789ABCDEF"         ; An array for displaying hexa decimal numbers
    ALIGN 4


times 9000-($-$$) db 0
