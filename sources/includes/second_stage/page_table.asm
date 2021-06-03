%define PAGE_TABLE_BASE_ADDRESS 0x0000
%define PAGE_TABLE_BASE_OFFSET 0x1000
%define PAGE_TABLE_EFFECTIVE_ADDRESS 0x1000
%define PAGE_PRESENT_WRITE 0x3  ; 011b
%define MEM_PAGE_4K         0x1000

build_page_table:
    pusha                                   ; Save all general purpose registers on the stack
; This function need to be written by you.
mov ax,PAGE_TABLE_BASE_ADDRESS ;ax= address of PAGE_TABLE_BASE_ADDRESS
mov es,ax ;es=ax
xor eax,eax ;eax=0 
mov edi,PAGE_TABLE_BASE_OFFSET ;edi=address of PAGE_TABLE_BASE_OFFSET
mov ecx, 0x1000 ;ecx is used as a counter and here we set it up at 4096
xor eax, eax ;eax=0
cld ;clear the direction flag
rep stosd ;ecx will be incremented each time by 4 bytes hence it will map 4 memory pages 
mov edi,PAGE_TABLE_BASE_OFFSET ;edi=address of PAGE_TABLE_BASE_OFFSET which will contain 0x1000 which is where PLM4 is 
lea eax, [es:di + MEM_PAGE_4K] ;store the address of [es:di + MEM_PAGE_4K] into eax
or eax, PAGE_PRESENT_WRITE ;or eax with page present write to create bits 0 and 1
mov [es:di], eax ;[es:di]=eax which will contain 0x2000 which is where PDP is 
add di,MEM_PAGE_4K ;di=MEM_PAGE_4K
lea eax, [es:di + MEM_PAGE_4K] ;store the address of [es:di + MEM_PAGE_4K] (which contains the address of the next page) into eax
or eax, PAGE_PRESENT_WRITE ;or eax with page present write to create bits 0 and 1
mov [es:di], eax ;[es:di]=eax which will contain 0x3000 which is where PD is
add di,MEM_PAGE_4K ;di=MEM_PAGE_4K
lea eax, [es:di + MEM_PAGE_4K] ;eax= PAGE_PRESENT_WRITE
or eax, PAGE_PRESENT_WRITE ;or eax with page present write to create bits 0 and 1
mov [es:di], eax ;[es:di]=eax which will contain 0x4000 which is where PT is
add di,MEM_PAGE_4K ;di=MEM_PAGE_4K
mov eax, PAGE_PRESENT_WRITE  ;store 0x3 into eax 
.pte_loop: ;this loop will map 2MB of physical memory by filling 512 entries of the PT 
mov [es:di], eax
add eax, MEM_PAGE_4K
add di, 0x8
cmp eax, 0x200000 ;compare eax with 2MB to check if they are equal
jl .pte_loop ;if less than then loop again till they are equal 
mov si, pml4_page_table_msg ;print PML4 page table created successfully
call bios_print
popa ;Restore all general purpose registers from the stack
ret ;return 
