video_print_hexa:  ; A routine to print a 16-bit value stored in di in hexa decimal (4 hexa digits)
pushaq
mov rbx,0x0B8000                        ;set BX to the start of the video RAM
;mov es,bx                              ;Set ES to the start of teh video RAM
mov r15, 0x0B8000                       ;address of the first byte of the first row
cmp qword [start_location], 0xF9E       ;make sure the cursor did not reach the end of the screen
jg scrolling_hexa                       ;if it reached the end of the screen scroll

    printing_hexa:
    add bx,[start_location]             ; Store the start location for printing in BX
    mov rcx,0x10                        ; Set loop counter for 4 iterations, one for each digit
    ;mov rbx,rdi                        ; DI has the value to be printed and we move it to bx so we do not change ot
    .loop:                                    ; Loop on all 4 digits
            mov rsi,rdi                           ; Move current di into si
            shr rsi,0x3C                          ; Shift SI 60 bits right 
            mov al,[hexa_digits+rsi]              ; get the right hexadcimal digit from the array           
            mov byte [rbx],al                     ; Else Store the charcater into current video location
            inc rbx                               ; Increment current video location
            mov byte [rbx],dl                     ; Store the color passed in dl
            inc rbx                               ; Increment current video location

            shl rdi,0x4                          ; Shift bx 4 bits left so the next digits is in the right place to be processed
            dec rcx                              ; decrement loop counter
            cmp qword [start_location], 0xF9E    ;make sure we did not reach the last byte in the VGA display
            jg scrolling_hexa                     ;if we did, then scroll
            cmp rcx,0x0                          ; compare loop counter with zero.
            jg .loop                            ; Loop again we did not yet finish the 4 digits
            add [start_location],word 0x20       ;move the cursor 32 bits forward (16 for the chars and 16 for colors)
            jmp end                               ; if we finished the loop return from the function
    scrolling_hexa:
    mov r15, 0x0B8000       ;address of the first byte of the first row
    mov r14, 0x0B80A0       ;address of the first byte of the second row
    shift_hexa:             ;shifts each line upward to give illusion of scrolling
    mov bl, byte [r14]      ;mov character from the second line into bl
    mov byte [r15], bl      ;overwrite the character in the first line with the value of bl
    inc r15                 ;point to the next characters
    inc r14
    cmp r14, 0x0B8F9F       ;make sure we did not reach 3999 which is the last byte in the VGA display
    jle shift_hexa          ;if we did not, keep shifting
    
    mov r15, 0x0B8F00
    mov r13, 0x0B8F9F       ;last byte in the VGA
    cll_hexa:             ;a function to clear the last line of the display
    mov byte [r15], ' '   ;clear the current character
    inc r15               ;point to the color of that character
    mov byte [r15], 0x00   ;fill it in with black
    inc r15               ;point to the next character
    cmp r15, r13          ;make sure we still did not finish the first line
    jle cll_hexa
    mov qword [start_location], 0xF00       ;if we did set the cursor to the first character of the last line
    jmp printing_hexa        ;if we finished scrolling jump to continue printing
    
    end:                    ;a label to refer to when we need to return from the function
    popaq
    ret
;***************************************
video_cls:              ;a function that clears the VGA display
pushaq
xor rax, rax            ;zero out rax
xor rcx, rcx            ;used as counter for the loop
mov rax, 0xB8000        ;store the start location of the VGA seg

.cls:
mov byte [rax], ' '     ;print nothing on the first byte of the current pixel
inc rax                 ;point to the next byte presenting the color
inc rcx                 ; increment counter
mov byte [rax], 0x0     ;fill the current pixel with black
inc rax
inc rcx                 ;increment counter again until we finish the video size
cmp rcx, 0x0F9F         ;determine if we finished the video size or not
jle .cls                ; if not keep looping
mov qword [start_location], 0x0         ; if we did, reset the cursor to the top of the screen
popaq
ret

;***************************************************************

video_print:                
    pushaq
    mov rbx,0x0B8000                    ; set BX to the start of the video RAM
    ;mov es,bx                          ; Set ES to the start of teh video RAM
    mov r15, 0x0B8000                   ;address of the first row
    cmp qword [start_location], 0xF9E   ;if the cursor is at the end pof the vga display
    jg scrolling                        ;jump to perform scrolling

    printing:
    add bx,[start_location]             ; else Store the start location for printing in BX and print normally
    xor rcx,rcx
video_print_loop:                       ; Loop for a character by charcater processing
    lodsb                               ; Load character pointer to by SI into al
    cmp al,13                           ; Check  new line character to stop printing
    je out_video_print_loop             ; If so get out
    cmp al,0                            ; Check  new line character to stop printing
    je out_video_print_loop1            ; If so get out
    mov byte [rbx],al                   ; Else Store the charcater into current video location
    inc rbx                             ; Increment current video location
    mov byte [rbx],dl                   ; Store the color passed in dl
    inc rbx                             ; Increment current video location
                            ; Each position on the screen is represented by 2 bytes
                            ; The first byte stores the ascii code of the character
                            ; and the second one stores the color attributes
                            ; Foreground and background colors (16 colors) stores in the
                            ; lower and higher 4-bits
    inc rcx
    inc rcx
    jmp video_print_loop    ; Loop to print next character
out_video_print_loop:
    xor rax,rax
    mov ax,[start_location] ; Store the start location for printing in AX
    mov r8,160
    xor rdx,rdx
    add ax,0xA0             ; Add a line to the value of start location (80 x 2 bytes)
    div r8
    xor rdx,rdx
    mul r8
    mov [start_location],ax
    jmp finish_video_print_loop
out_video_print_loop1:
    mov ax,[start_location] ; Store the start location for printing in AX
    add ax,cx             ; Add a line to the value of start location (80 x 2 bytes)
    mov [start_location],ax

    finish_video_print_loop:    ;a label to jump to when we finish printing
    popaq
    ret

    scrolling: 
    mov r15, 0x0B8000       ;address of the first row
    mov r14, 0x0B80A0       ;address of the second row
    shift:
    mov bl, byte [r14]    ;mov character from the second line into bl
    mov byte [r15], bl    ;overwrite char in first line with value in bl
    inc r15               ;point to the next char on both lines
    inc r14
    cmp r14, 0x0B8F9F     ;make sure we did not reach the end of the VGA display
    jle shift             ;keep shifting until the end of the vga display
    
    mov r15, 0x0B8F00
    mov r13, 0x0B8F9F       ;last byte in the VGA
    cll:                    ;a function to clear the last line of the VGA display
    mov byte [r15], ' '       ;store nothing in the curent location
    inc r15                 ;inc to point to the color of the current char
    mov byte [r15], 0x00    ;store black as a color
    inc r15                 ;increment to point to the next character
    cmp r15, r13            ;make sure we did not finish the first line yet
    jle cll                 ;keep looping until we clear the first line 
    mov qword [start_location], 0xF00   ;if we scrolled, replace the cursor at the beginning of the last line
    jmp printing

    

