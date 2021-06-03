      call get_key_stroke ;get key stroke from user before execution of step     
check_long_mode:
            pusha                           ; Save all general purpose registers on the stack
            call check_cpuid_support        ; Check if cpuid instruction is supported by the CPU
            call check_long_mode_with_cpuid ; check long mode using cpuid
            popa                            ; Restore all general purpose registers from the stack
            ret

        check_cpuid_support:
            pusha               ; Save all general purpose registers on the stack
; This function need to be written by you.
pushfd ;save the eflags register 
pushfd ; save them again in order to use them with comparison in register eax
pushfd
pop eax ; copy the flags to eax
xor eax, 0x0200000 ;bit flip bit 21 from 0 to 1 or vice versa
push eax ;push the value of the eax register into the eflags
popfd ;pop the eflags
pushfd 
pop eax ;copy eflags to eax
pop ecx ;copy eflags to ecx
xor eax, ecx ;equal to 1 because bit 21 in eax is different than ecx
and eax, 0x0200000 ;ignore all bits except bit 21
cmp eax, 0x0 ;compare eax and 0 to check if eax is equal to 0 
jne .cpuid_supported ;if not equal jump to cpuid supported 
mov si, cpuid_not_supported
call bios_print ;call the function bios_print to print that the cpuid is not supported 
jmp hang ;jump to halt 
.cpuid_supported:
mov si, cpuid_supported
call bios_print ;call the function bios_print to print that the cpuid is supported 
popfd ;restore the eflags register 
 popa     ;Restore all general purpose registers from the stack
ret

        check_long_mode_with_cpuid:
            pusha                                   ; Save all general purpose registers on the stack
;This function need to be written by you.
mov eax, 0x80000000 ;this is the function that determines whether long mode is availabe or not 
cpuid ;cpu identification 
cmp eax, 0x80000001 ;this function returns the extended features bits of the processor into edx hence if it is smaller than 0x80000001 then it is not supported 
jl .long_mode_not_supported ;if it is less than then jump to long mode not supported
mov eax, 0x80000001 ;get the processor extended features bits 
cpuid ;cpu identification
and edx, 0x20000000 ;ignore or hide all other bits in edx except bit 29 as this is the long mode bit 
cmp edx, 0 ;compare edx with 0 to check if it is 0
je .long_mode_not_supported ;jump if equal to long mode not supported 
mov si, long_mode_supported_msg
call bios_print ;call bios_print to print that long mode is supported message 
jmp .exit_check_long_mode_with_cpuid
.long_mode_not_supported:
mov si, long_mode_not_supported_msg
call bios_print ;call function bios_print to print that the long mode is not supported message
jmp hang ;jump to halt 
.exit_check_long_mode_with_cpuid:
popa ;Restore all general purpose registers from the stack
ret ;return
