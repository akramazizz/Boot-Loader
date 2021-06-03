call get_key_stroke ;get key stroke from user before execution of step   
GDT64:
    .Null: equ $ - GDT64         ; The null descriptor.
    ; This function need to be written by you.
;in the null label we just set everything to 0
dw 0 ;low limit
dw 0 ;base low
db 0 ;base middle
db 0 ;access byte
db 0 ;flags with high limit
db 0 ;base high

.Code: equ $ - GDT64         ; The Kernel code descriptor.
    ; This function need to be written by you.
;the base and limit are set to 0 which means we're pointing to the whole memory
dw 0 
dw 0 
db 0
;the access byte and the flags are being used to determine what is set and what is not 
db 10011000b ;here we set the the present bit, ring 0, and the executable bit
db 00100000b ;here we set the long bit mode
db 0

.Data: equ $ - GDT64         ; The Kernel data descriptor.
    ; This function need to be written by you.
dw 0 
dw 0
db 0
db 10010011b ;in the data section, in addition to the previously set bits, the read/write bit also needs to be set
db 00000000b
db 0
ALIGN 4 ;we need padding at the end of the table on a 4 byte base
;the GDT size needs to be padded such that the GDT table is on a 4 byte boundary
dw 0
.Pointer: ;this is the GDT descriptor
    ; This function need to be written by you.
dw $ - GDT64 - 1 ;this value has the size of the GDT table (we calculate it by subtracting the begining of the GDT table from $
;this will return the size of the whole table 
dd GDT64 ;this is the address of the GDT table which is the address corresponding to that label 
