%define VIDEO_BUFFER_SEGMENT                    0xB000   ;0xB8000 this is the address that the video text mode MMIO buffer is mapped at 
%define VIDEO_BUFFER_OFFSET                     0x8000 
%define VIDEO_BUFFER_EFFECTIVE_ADDRESS          0xB8000 
%define VIDEO_SIZE      0X0FA0    ; 25*80*2
    video_cls_16:
            pusha                                   ; Save all general purpose registers on the stack
xor bx, bx ;bx=0
mov bx, VIDEO_BUFFER_OFFSET ;bx= address of VIDEO_BUFFER_OFFSET 
;the next two lines are to set video mode to 0x10 VGA mode 
mov ax, VIDEO_BUFFER_EFFECTIVE_ADDRESS
int 0x10
mov ax, VIDEO_BUFFER_SEGMENT ;ax= VIDEO_BUFFER_SEGMENT
mov es, ax ;es=ax
mov al, 0x00 ;0x00 is used to display or output a black screen 
mov ah, ' ' ;empty character to be stored in al 
mov cx, VIDEO_SIZE ;cx=VIDEO_SIZE
;the next two lines are used to copy the value of ax into es:di and repeat it vx counter by 2 on each iteration  
mov word [es:bx], ax 
add bx, 2

                  ; This function need to be written by you.

            popa                                ; Restore all general purpose registers from the stack
            ret

