
bit_map_scanner:
mov rsi,  scanning_bitmap                ;print that we are scanning the bitmap
call video_print
pushaq                    ;take a snapshot of all the registers

xor r8, r8                             ;zero out r8
xor rcx,rcx                             ;use it as a counter for consecutive bytes in the bitmap that are empty until we reach 512, or not
xor r15, r15                            ;use it as a flag, if set we will map 2 MB, if not we will map 4 KB 
mov rax, BIT_MAP_START                  ;store the start address of the bitmap in rax

.compare:
cmp byte [rax], 1                          ;compare the value in the entry of the bitmap with 1
jne .reset_counter

.loop:
inc rcx
inc rax
cmp rcx, 512
je .return_2MB                           ;if it's one then we found the 4K frame we can use
inc r8                                ;increment counter
cmp r8, BIT_MAP_END                  ;if the counter is not equal to to the end address of the bitmap keep looping
jne .compare

.return_4KB:
mov r15, 0
jmp .end

.reset_counter:
inc rax
xor rcx,rcx
jmp .compare

.return_2MB:
mov r15, 1
jmp .end


.end:

mov rbx, 0x1000                        ;store 4096 in rbx
sub  rax, 512
imul  rax, rbx                     ;multiply the address of the bitmap entry with 4K to get how much bytes we need to add to the end address of the bitmap
add  rax, BIT_MAP_END              ;add those bytes to the end address of the bitmap entry
mov rsi, rax                            ;return value of the start address of the region is in si
popaq                                   ;make sure the return value in si is not overwritten when we pop, also make sure that si is the offset in the segment 0x2000                                
ret

;if we want to map 2 MB then we have to find 512 consecutive bits in the bitmap, for that we will have a counter, once it hits 512 then we will have our 2 MB and we will return the address and the flag will be
;set to true