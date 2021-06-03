;*******************************************************************************************************************
%define CONFIG_ADDRESS  0xcf8
%define CONFIG_DATA     0xcfc

ata_device_msg db 'Found ATA Controller',13,10,0
pci_header times 512 db 0
msg_scan_device db ' Scanning PCI Devices ',13,0   
memory_pci_header            dq   0x100000      ;this memory alocation is used to save the header information
memory_pci_header_size       dq   0x0           ;indicates the last bit used while writing in the memory_pci_header  




struc PCI_CONF_SPACE 
.vendor_id          resw    1
.device_id          resw    1
.command            resw    1
.status             resw    1
.rev                resb    1
.prog_if            resb    1
.subclass           resb    1
.class              resb    1
.cache_line_size    resb    1
.latency            resb    1
.header_type        resb    1
.bist               resb    1
.bar0               resd    1
.bar1               resd    1
.bar2               resd    1
.bar3               resd    1
.bar4               resd    1
.bar5               resd    1
.reserved           resd    2
.int_line           resb    1
.int_pin            resb    1
.min_grant          resb    1
.max_latency        resb    1
.data               resb    192
endstruc


get_pci_device:
    ;Compose the Config Address Register (32-bis):
    ;  Bit 23-16 : bus (so we shift left 16 bits))
    ;  Bit 15-11 : device (so we shift left 11 bits))
    ;  Bit 10-8 : function (so we shift left 8 bits))
    ;  Bit 7-2 : so we clear the last two bytes by & 0xfc
    ;  Bit 31 : Enable bit, and to set it we | 0x80000000
    ;  ((bus << 16) | (device << 11) | (function << 8) | (offset & 0xfc) | ( 0x80000000))    
    pushaq
    xor rax,rax       ;zero out rax
      xor rbx,rbx       ;zero out rbx    
      mov bl,[bus]      ;move the value of bus into bl
      shl ebx,16        ;shift left the 8-bits to reach the right position 
      or eax,ebx        ;store the value of ebx to eax 
      xor rbx,rbx       ;zero out rbx to be used again.
      mov bl,[device]       ;move the value of device into bl
      shl ebx,11       ;shift left the 5-bits of the device to reach the right position 
      or eax,ebx       ;store the added part to eax, to get updated.  
      xor rbx,rbx       ;zero out rbx to be used again.   
      mov bl,[function]      ;move the value of function into bl
      shl ebx,8              ;shift left the 3-bits of the device to reach the right position 
      or eax,ebx             ;store the added part to eax, to get updated.  
      or eax,0x80000000      ;or eax with the hexa value of "0x80000000", which is of a value 1 followed by 31 0s
      xor rsi,rsi            ;set the value of rsi to 0, to be used by the offset
      ;this loop will go over all the offsets 
      .pci_config_space_read_loop:
      push rax              ; push the value of rax on the stack to save it.    
      ;| (offset & 0xfc)
      or rax,rsi            ;add the offset part
      and al,0xfc           ;making sure that the last two bits are 0s
      mov dx,CONFIG_ADDRESS ; move the value of config address into dx
      out dx,eax            ;use out command to write eax on dx
      mov dx,CONFIG_DATA    ;move in dx the config data
      xor rax,rax           ;zero out rax    
      in eax,dx             ;read from it the 4 bytes, I need. 
      mov[pci_header+rsi],eax   ;copy eax to some memory buffer
      add rsi,0x4                   ;increment the value of rsi by 4
      pop rax                       ;restore the value of rax back
      cmp rsi,0xff                  ;compare if the value of rsi equals to 255, to read the full 256
      jl .pci_config_space_read_loop ;jump if the value of rsi is less than 255

  popaq
  ret

