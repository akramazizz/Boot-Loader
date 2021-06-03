%define PTR_MEM_REGIONS_COUNT       0x21000
%define MEM_REGIONS_TABLE           0x21018
%define BIT_MAP_START              0x0              ; those addresses are calculated within the file
%define BIT_MAP_END                0x0
%define PTR_PML4                   0x0
BitMap:

mov rsi, bitmap_start
call video_print

pushaq

xor rax, rax
mov ax, word [PTR_MEM_REGIONS_COUNT]                  ;in rax we have the counter of the mem regions
mov bx, 0x18                                                                 
imul ax, bx                                      ;multiply regions count by 24
add ax, bx    
xor rbx, rbx                                   
add rbx, 0x20100                                          
or rbx, rax
mov qword [BIT_MAP_START], rbx
mov ecx,dword [PTR_MEM_REGIONS_COUNT]        ;ecx is the loop counter
mov esi, MEM_REGIONS_TABLE             

.create_bit_map_loop:

mov rax, qword [esi+8]
mov rbx, 0x1000                     ; store 4096 in rbx
xor rdx, rdx                         ;clear up rdx for the remainder of the division
div rbx                             ; divide the length of the mem region by 4k to determine how many bits it will take up in the bit map

mov edx, dword [esi+16]                ; store in rdx the region type of the mem region
xor r8, r8                       ;clear out r8 to be a counter for the loops
mov r9, BIT_MAP_START            ;use r9 as a pointer to the current bit 
cmp edx, 1                       ;cmp the region type with 1 to see if it is RAM so we put 1 for the corresponding bits in the bit map
je .one_loop                      ;if region type is 1, jump to one_loop

.zero_loop:                        ;to initilaze bitmap for the invalid mem regions

add r9, 1                             ; ++address
mov qword [r9], 0                           ; store in the location pointed to by BIT_MAP_ADDR 0 because it's an invalid mem region
inc r8                                              ; increment the counter
cmp r8, rax                                         ; compare the counter to max bound of the loop (number of 4K segments in this mem region)
jne .zero_loop                                       ; if not equal keep on looping
jmp .end_patting                                     ; if this region represented in the bit map, jmp to map another region

  
.one_loop:                          ; to initliaze bitmap for type 1 region (RAM)

add r9, 1                              ; ++address
mov word [r9], 1                               ; store in the location pointed to by BIT_MAP_ADDR 1 because it's RAM
inc r8                                              ; increment the counter
cmp r8, rax                                         ; compare the counter to max bound of the loop (number of 4K segments in this mem region)
jne .one_loop                                        ; if not equal keep on looping

.end_patting:                                        ;label to jump to when we finish padding the bitmao for a certain region to continue looping on other regions
add esi, 0x18                                         ; move to the next region in the mem regions table
dec ecx                                             ; decrement the count of mem regions
cmp ecx,0x0                                         ;check if the count is equal to zero
jne .create_bit_map_loop                     ; if not then continue looping, if it is ==0, then restore the registers

mov qword[BIT_MAP_END], r9

mov rsi, bitmap_end                      ;print that we finished the bitmap
call video_print 
ret

