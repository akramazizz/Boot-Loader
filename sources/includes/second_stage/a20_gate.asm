 
;call get_key_stroke ;get key stroke from user before execution of step   

check_a20_gate:
pusha                                   ; Save all general purpose registers on the stack
;This function need to be written by you.
;the next two lines are used to check if the a20 gate is disabled or not 
mov ax, 0x2402
int 0x15 ;interrupt 15
jc .error ;jump to error if the carry is set (c=1) 
cmp al, 0x0 ;comapre al with 0x0
je .enable_a20 ;if equal jump to enable a20 in order to enable the gate 
jmp .enable_message ;jump to enable message to print that a20 is enabled 
.check_a20_gate_again: ;to check if a20 is disabled 

;the next two lines are used to check if the a20 gate is disabled or not 
mov ax, 0x2402
int 0x15 ;interrupt 15
jc .error ;jump to error if the carry is set (c=1) 
cmp al, 0x0 ;comapre al with 0x0
je .not_enabled_message ;if equal jump to print that a20 is not enabled
.enable_a20:
;interrupt 0x15 function 0x2401 are used to enable a20 gate 
mov ax, 0x2401
int 0x15 ;interrupt 15
jc .error ;if equal jump to enable a20 in order to enable the gate 
.enable_message:
mov si, a20_enabled_msg ;print that a20 is enabled
call bios_print
;jmp check_a20_gate ;repeat the loop 
jmp .done ;if done go to .done 
.not_enabled_message:
mov si, a20_not_enabled_msg ;print that a20 is not enabled
call bios_print
jmp hang
.error:
cmp ah, 0x1 ;compare ah with 1, if equal then keyboard controller error
je .keyboard_controller_error
cmp ah, 0x86 ;comapre ah with 0x86 if equal then a20 function is not supported 
je .a20_function_not_supported
.unknown_error:
mov si, unknown_a20_error
call bios_print
jmp hang 
.a20_function_not_supported:
mov si, a20_function_not_supported_msg ;print that a20 function is not supported
jmp hang
.keyboard_controller_error:
mov si, keyboard_controller_error_msg ;print that keyboard contoller error message has occured
call bios_print
jmp hang
.done:
popa ; Restore all general purpose registers from the stack
ret ;return 

