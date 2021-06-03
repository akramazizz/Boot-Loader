%define PIT_DATA0       0x40
%define PIT_DATA1       0x41
%define PIT_DATA2       0x42
%define PIT_COMMAND     0x43

pit_counter dq    0x0               ; A variable for counting the PIT ticks

handle_pit:
;;;;;this is written asln (this is used to print the pit_counter for every interrupt hence we need to comment it out and print for every 1000 interrupts
;mov rdi,[pit_counter]         ; Value to be printed in hexa
;push qword [start_location]
;mov qword [start_location],0
;call bios_print_hexa          ; Print pit_counter in hexa
;pop qword [start_location]
;inc qword [pit_counter]       ; Increment pit_counter
;popaq
;ret

;;;;;;in order to modify the pit handler to print the pit_counter every 1000 interrupts, the same logic that we used in rcx=50 was followed here 
;but instead of 50, its 1000

pushaq

xor rdx,rdx ;rdx=0 will be used to store the remainder
;mov rbx,1193180
mov rax,[pit_counter] ;rcx=[pit_counter]
mov rcx,1000 ;for 1000 interrupts 
div rcx ;divide [pit_counter]/1000
cmp rdx, 0
jne .increment ;if its not equal then this means we still did not reach a 1000 interrupt so increment the counter but do not print yet
;otherwise, if it the remainder is 0 then this means we have reached 1000 interrupts so print the counter so jump to done to print 
jmp .done
jmp handle_pit ;then loop again till it is 1000 interrupts
.done:
mov dl, 0x3F
mov rdi,[pit_counter]
call video_print_hexa ;The PIT counter is 16-bit wide hence it is printed using hexa
mov rsi, newline
call video_print
.increment:
inc qword [pit_counter]       ; Increment pit_counter
popaq
ret


;;;;;;;;;some information for me (erase later)
;The PIT counter is 16-bit wide, so it can hold values 0 → 65535.
;Since we cannot divide by 0, a value of zero represents 65536.


;;;;;;;;;;;;;;;;;



configure_pit:
pushaq
      ; This function need to be written by you.
mov rdi,32 ;the PIT channel 0 is connected to the PIC IRQ0 and it fires interrupt 32 to the processor
mov rsi, handle_pit ;to be able to see IRQs firing we need to configure the handle_pit
call register_idt_handler ;we need to invoke register_idt_handler in order to configur the PIT
mov al,00110110b ;from left to right: 00 because channel 0, 11 because we need both high and low bytes, 011 because mode 3 
out PIT_COMMAND,al ;write only command port 
xor rdx,rdx ;rdx=0
mov rcx,50 ;rcx=50 (the output will be low 50% of the time and high 50% of the time)
mov rax,1193180 ;frequency of the PIT oscillator is 1193180 Hz (1.193182 MHz)
div rcx ;divide 1193180/50 
out PIT_DATA0,al ;send low byte
mov al,ah ;al has the high 8 bytes 
out PIT_DATA0,al ;send high byte


popaq
ret


;The output of channel 0 is connected to the IRQ0 of the PIC.
