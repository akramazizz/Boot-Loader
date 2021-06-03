%define PAGE_PRESENT_WRITE 0x3 ; 011b

dissect_addr:
;address will be passed in r11
pusha
mov es, 0x2000
;checking pml4 entry
mov rax, r11                        ;store the address to be dissected in accumulator register rax
and rax, 0x0000FF8000000000         ;mask the address to get the first 9 bits of the PML4 entry
mov rcx, 39                         ;store in rcx 39 to stay as a flag for the page_fault function to indicate which level the fault was in
shr rax, 39                         ;shift right the address to remove the excess zeros after masking
add rax, rax, cr3                   ;add the index in rax to the starting address of PML4 to get the exact address of the entry

mov di, rax
lea r9, [es:di]
cmp [r9], 0                      ;check if the entry of the pml4 is zero or not, if it contains zero it means it's not mapped

je PageFault_Handler                ;if it is not mapped then a page fault occurs
mov r8, r9                       ;store the base address of the next level in rax
mov rax, r11                        ;store the address to be dissected in accumulator register rax
and rax, 0x0000_007F_C000_0000      ;mask the address to get the second 9 bits of the PDP entry
mov rcx, 30                         ;store in rcx 30 to stay as a flag for the page_fault function to indicate which level the fault was in
shr rax, 30                         ;shift right the address to remove the excess zeros after masking
add rax, rax,r8                     ;add the index in rax to the starting address of PDP to get the exact address of the entry

;checking pdp entry

mov di, rax
lea r9, [es:di]
cmp [r9], 0                         ;check if the entry of the pdp is zero or not, if it contains zero it means it's not mapped
je PageFault_Handler                ;if it is not mapped then a page fault occurs
mov r8, r9                          ;store the base address of the next level in rax
mov rax, r11                        ;store the address to be dissected in accumulator register rax
and rax, 0x0000_0000_3FE0_0000      ;mask the address to get the third 9 bits of the PD entry
mov rcx, 21                         ;store in rcx 21 to stay as a flag for the page_fault function to indicate which level the fault was in
shr rax, 21                         ;shift right the address to remove the excess zeros after masking
add rax, rax,r8                     ;add the index in rax to the starting address of PD to get the exact address of the entry
mov r12, rax                        ;move the address of the pd entry in temp reg r12
and r12, 0x8000_0000_0000_0000      ;mask the address to set the seventh bit of the first byte in set or not
cmp r12, 1
je .sizeBitSet                      ; if set then we treat the remaining 21 bits as offset 

;first we will treat the last 21 bits of the address as a offset assuming we are mapping 2 MB, we will call the bit map scanner and according to the flag we will stick to having the last 21 bits as our offset
;if the flag is not set then we will implement the code below for mapping 4KB frames


;checking pd entry 9 bits

mov di, rax
lea r9, [es:di]
cmp [r9], 0                         ;check if the entry of the pd is zero or not, if it contains zero it means it's not mapped
je PageFault_Handler                ;if it is not mapped then a page fault occurs
mov r8, r9                          ;store the base address of the next level in rax
mov rax, r11                        ;store the address to be dissected in accumulator register rax
and rax, 0x0000_0000_001F_F000      ;mask the address to get the fourth 9 bits of the PTE entry
shr rax, 12                         ;shift right the address to remove the excess zeros after masking
add rax, rax, r8                    ;add the index in rax to the starting address of PD to get the exact address of the entry

;checking pte entry

mov di, rax
lea r9, [es:di]
cmp [r9], 0                         ;check if the entry of the pte is zero or not, if it contains zero it means it's not mapped
jne .end                            ;if not zero then it's mapped then return from the function
call bit_map_scanner                ;else scan the bitmap for an empty region to map, the address of the empty region will be returned in si
mov r8, si                          ;store the physical base address in r8
mov rax, r11                        ;store the input address in rax for the masking
and rax, 0x0000_0000_0000_0FFF      ;mask the address to get the offset
or rax, r8                          ;or the physical address with the offset to concatenate them together
jmp .end
;return rax which is the physical frame 

.sizeBitSet:

mov di, rax
lea r9, [es:di]
cmp [r9], 0                         ;check if the entry of the pte is zero or not, if it contains zero it means it's not mapped
jne .end                            ;if not zero then it's mapped then return from the function
call bit_map_scanner                ;else scan the bitmap for an empty region to map, the address of the empty region will be returned in si
mov r8, si                          ;store the physical base address in r8
mov rax, r11                        ;store the input address in rax for the masking
and rax, 0x0000_0000_001F_FFFF      ;mask the address to get the offset
or rax, r8                          ;or the physical address with the offset to concatenate them together
jmp .end
;return rax which is the physical frame 

PageFault_Handler:
; call the bit_scanner and store the return address in the entry I am pointing at right now
call bit_map_scanner
or si, PAGE_PRESENT_WRITE
mov [r9], si
call page_fault

.end:
popa
ret
