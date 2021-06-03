%define MEM_REGIONS_SEGMENT         0x2000
%define PTR_MEM_REGIONS_COUNT       0x1000
%define PTR_MEM_REGIONS_TABLE       0x1018
%define MEM_MAGIC_NUMBER            0x0534D4150      

;call get_key_stroke ;get key stroke from user before execution of step             
    memory_scanner:
            pusha                                       ; Save all general purpose registers on the stack
; This function need to be written by you.
mov ax, MEM_REGIONS_SEGMENT ;ax=0x2000
mov es, ax ;es=ax
xor ebx, ebx ;ebx=0
mov [es:PTR_MEM_REGIONS_COUNT], word 0x0 ;the word that is located at address es:PTR_MEM_REGIONS_COUNT (hence 0x0000:0x2000) will be used as a counter in order to count memory regions 
mov di, PTR_MEM_REGIONS_TABLE ; di=address of PTR_MEM_REGIONS_TABLE
.memory_scanner_loop:
mov edx, MEM_MAGIC_NUMBER ;edx= address of MEM_MAGIC_NUMBER
mov word [es:di+20], 0x1 ;the address at es:di+20 is set to 0x1
;the next 3 lines which represent the function 0xE820 int 0x15 are used to read different memory regions 
mov eax, 0xE820 ;eax=0xE820
mov ecx, 0x18 ;the size memory to use for storage (ecx=24)
int 0x15 ;interrupt 15
jc .memory_scan_failed ;jump to memory scan failed if the carry is set (c=1) 
cmp eax, MEM_MAGIC_NUMBER ;check if eax is equal to memory magic number
jnz .memory_scan_failed ;if not equal jump to memory scan failed
add di, 0x18 ;increment di by 24 bytes to move on tot he next entry in the memory region table 
inc word [es:PTR_MEM_REGIONS_COUNT] ;increment the counter
cmp ebx, 0x0 ;compare ebx and 0x0
jne .memory_scanner_loop ;if not equal then loop again 
jmp .finish_memory_scan ;if equal then jump to finish memory scan 
.memory_scan_failed:
mov si, memory_scan_failed_msg
call bios_print
jmp hang
.finish_memory_scan:
 popa                                        ; Restore all general purpose registers from the stack
 ret

    print_memory_regions:
            pusha
            mov ax,MEM_REGIONS_SEGMENT                  ; Set ES to 0x0000
            mov es,ax       
            xor edi,edi
            mov di,word [es:PTR_MEM_REGIONS_COUNT]
            call bios_print_hexa
            mov si,newline
            call bios_print
            mov ecx,[es:PTR_MEM_REGIONS_COUNT]
            mov si,0x1018 
            .print_memory_regions_loop:
                mov edi,dword [es:si+4]
                call bios_print_hexa_with_prefix
                mov edi,dword [es:si]
                call bios_print_hexa
                push si
                mov si,double_space
                call bios_print
                pop si

                mov edi,dword [es:si+12]
                call bios_print_hexa_with_prefix
                mov edi,dword [es:si+8]
                call bios_print_hexa

                push si
                mov si,double_space
                call bios_print
                pop si

                mov edi,dword [es:si+16]
                call bios_print_hexa_with_prefix


                push si
                mov si,newline
                call bios_print
                pop si
                add si,0x18

                dec ecx
                cmp ecx,0x0
                jne .print_memory_regions_loop
            popa
            ret
