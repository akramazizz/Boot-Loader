%define PAGE_PRESENT_WRITE 0x3 ; 011b
%define PAGE_SIZE 0x8000_0000_0000_0000

;rcx will be passed as a parameter from the page walk function to indicate which level the fault occured
;si will be passed as a parameter to so we can modify the page size bit if needed
pusha

pagefault:
mov es, 0x2000
cmp rcx, 21
je pte_build

cmp rcx, 30
je pd_build

pdp_build:
lea eax, [es:si]                ; load the address of the pdp from the pml4 entry
call bit_map_scanner
mov [eax], es:si                 ;move into the mem location of eax which is the pdp, the scanned address of the pd


;the flag of the bitmapscanner will indicate if I should go to pte build or should I skip to the end
pd_build:
;building a pd from the slides
; if the flag is set, then set the 7th bit of the page size to 1
lea eax, [es:si]                 ; load the address of the pd from the pdp entry
call bit_map_scanner
cmp r15, 1
je .SetSizeBit
mov [eax], es:si                 ;move into the mem location of eax which is the pd, the scanned address of the pte


pte_build:
;building a pte from the slides
lea eax, [es:si]                ; load the address of the pdp from the pml4 entry
call bit_map_scanner
mov [eax], es:si                 ;move into the mem location of eax which is the pdp, the scanned address of the pd
jmp .end

SetSizeBit:  ;jump here in case we are mapping 2MB
or eax, PAGE_SIZE

.end:
popa
ret