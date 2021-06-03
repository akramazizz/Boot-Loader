%define IDT_BASE_ADDRESS            0x40000 ;  0x4000:0x0000 which is free
%define IDT_HANDLERS_BASE_ADDRESS   0x41000 ;  0x4000:0x1000 which is free ;just after the idt, it will store the handler at the next 4KB 
%define IDT_P_KERNEL_INTERRUPT_GATE 0x8E; 1 00 0 1110 -> P DPL Z Int_Gate

struc IDT_ENTRY
.base_low         resw  1
.selector         resw  1
.reserved_ist     resb  1
.flags            resb  1
.base_mid         resw  1
.base_high        resd  1
.reserved         resd  1
endstruc

ALIGN 4                 ; Make sure that the IDT starts at a 4-byte aligned address    
IDT_DESCRIPTOR:         ; The label indicating the address of the IDT descriptor to be used with lidt
      .Size dw    0x1000                   ; Table size is zero (word, 16-bit) -> 256 x 16 bytes
      .Base dq    IDT_BASE_ADDRESS         ; Table base address is NULL (Double word, 64-bit)


load_idt_descriptor:
    pushaq
    lidt [IDT_DESCRIPTOR]  ; This function need to be written by you.
    popaq
    ret


init_idt:         ; Intialize the IDT which is 256 entries each entry corresponds to an interrupt number
                  ; Each entry is 16 bytes long
                  ; Table total size if 4KB = 256 * 16 = 4096 bytes
;pushaq
      ; This function need to be written by you.

;loop:
;xor rdi,rdi
;mov rdi, IDT_BASE_ADDRESS ;store IDT_BASE_ADDRESS in rdi
;xor rax, rax ;rax=0
;mov rax, ,0x80 ;add 0x4000 in rax in order (16 bytes)
;cld
;dec eax ;decrement eax  
;mov rcx, eax ;then move eax into rdi
;cmp rcx, 0 ;compare rdi to 0, if its equal to 0 then this means that rdi will be added to it 16 bytes again
;IF rdi = 0
;THEN rdi ← rdi + 16 bytes;
;jne loop ;if not equal loop again
;.out:
;popaq
;ret

pushaq
xor rdi, rdi ;rdi=0
xor rax, rax ;rax=0;
mov rdi, IDT_BASE_ADDRESS
mov rcx, 0x10   ;add 0x80 in rax in order (16 bytes)
cld               
rep stosq ;IF rdi = 0
;THEN rdi ← rdi + 16 bytes hence repeat till all 16 bytes are added
;compare rdi to 0, if its equal to 0 then this means that rdi will be added to it 16 bytes agai
popaq
ret 


register_idt_handler: ; Store a handler into the handler array
                        ; RDI contains the interrupt number
                        ; RSI contains the handler address
pushaq            ; SSave all general purpose registers
     ; This function need to be written by you.
shl rdi,3 ;this is an array of addresses so every address is 8 bytes so to identify the location where i need to store the handler address i multiply by 8 
mov [rdi+IDT_HANDLERS_BASE_ADDRESS],rsi ;store it in  [rdi+IDT_HANDLERS_BASE_ADDRESS]
popaq             
ret

setup_idt: ;this function is to call anything that has to do with setting up the interrupt descriptor table hence call all functions in idt.asm
            ; This function need to be written by you.
pushaq
call configure_pic
call setup_idt_exceptions
call setup_idt_irqs
call setup_idt_entry
call load_idt_descriptor
popaq
ret


setup_idt_entry:  ; Setup and interrupt entry in the IDT
                  ; RDI: Interrupt Number
                  ; RSI: Address of the handler
;this function sets an entry to point to some code address, an address that the isr code is located at
pushaq
            ; This function need to be written by you.
shl rdi,4 ;shift rdi by 4 which multiplies rdi by 16 because rdi is a number that refers to an index (hence for example if i
;want entry number 10 then this 10 is located at 10*16  becayuse each entry is 16 bytes
add rdi,IDT_BASE_ADDRESS ;add to rdi the IDT_BASE_ADDRESS because rdi now contains how far the entry im interested in is from some base address (hence this is the location of entry in bytes)
;what I will do next is calculate the lower 16-bit of base address and store it 
mov rax,rsi ;rax=rsi (rsi is the address)
and ax,0xFFFF ;by anding this will extract the lowest 16 bit of the address 
mov [rdi+IDT_ENTRY.base_low],ax ;then move the lowest 16 bits into [rdi+IDT_ENTRY.base_low] hence this will store the lowest 16 bit in the correct place inside the memory area 
mov rax,rsi  ;move into the original rsi again 
shr rax, 16 ;shift rax with 16 which will push the 16 bit that i already used and stored in the right place away from the register
and ax,0xFFFF ;extract the next 16 bits which is the middle 
mov [rdi+IDT_ENTRY.base_mid],ax ;store it in [rdi+IDT_ENTRY.base_mid]
mov rax,rsi ;move into the original rsi again 
shr rax, 32 ;shift right 32 which will push the 32 bits that i already used and stored in the right place away from the register
and eax,0xFFFFFFFF ;;extract the next 16 bits which is the high
mov [rdi+IDT_ENTRY.base_high],eax ;store it in [rdi+IDT_ENTRY.base_high] (we used eax because its 32 bits)
mov [rdi+IDT_ENTRY.selector], byte 0x8 ;set [rdi+IDT_ENTRY.selector] to 8 because in the gdt the code segment of the kernel is at location 8 
mov [rdi+IDT_ENTRY.reserved_ist], byte 0x0 ;set [rdi+IDT_ENTRY.reserved_ist] to 0
mov [rdi+IDT_ENTRY.reserved], dword 0x0 ;set [rdi+IDT_ENTRY.reserved] to 0
mov [rdi+IDT_ENTRY.flags], byte IDT_P_KERNEL_INTERRUPT_GATE ;the flags will be set to 0x8E which is equavalent to 10001110  
popaq
ret

idt_default_handler: ;this is just in case if i have some entries in this array ([IDT_HANDLERS_BASE_ADDRESS])that is not set up correctly  
      pushaq
           ;This is the default
      popaq
      ret


isr_common_stub:
      pushaq                  ; Save all general purpose registers
       ; This function need to be written by you.
cli ;clear interrupt 
mov rdi,rsp ;move into rdi rsp, this will set rdi to be the stack pointer 
mov rax,[rdi+120] ;rax=[rdi+120] this will get us the interrupt number that was pushed by the macro, why is it ar rdi+120 because i need to go back 120 locations to fetch the interrupt number
shl rax,3 ;multiply it by 8 so shift left by 3
mov rax,[IDT_HANDLERS_BASE_ADDRESS+rax] ;move the address that is stored at the [IDT_HANDLERS_BASE_ADDRESS+rax] into rax 
cmp rax,0 ;compare rax with 0 
je .call_default ;if equal then jump to the default handler which will do nothing 
;otherwise if rax is 0 then this entry is not configured 
call rax ;call the value stored in rax 
jmp .out ;jump to .out
.call_default:
call idt_default_handler 
.out:
popaq                   
add rsp,16 ;add 16 to rsp to move the rsp back 16            
sti  ;then set interrupts again                   
iretq ;this removes the value from the stack and restores them to where they were then continue and rsume execution          


irq_common_stub: ;this is exactly the same as isr but when we call it, we call it in case of hardware interrupts (interrupts ggenerated by the pic
;so we need to send the pic after executing the handler so the pic can continue to serve several interruots of the same interrupt that im handling right now
pushaq                  ; Save all general purpose registers
      ; This function need to be written by you.
cli ;clear interrupt
mov rdi,rsp ;move into rdi rsp, this will set rdi to be the stack pointer
mov rax,[rdi+120] ;rax=[rdi+120] this will get us the interrupt number that was pushed by the macro, why is it ar rdi+120 because i need to go back 120 locations to fetch the interrupt number
shl rax,3 ;multiply it by 8 so shift left by 3
mov rax,[IDT_HANDLERS_BASE_ADDRESS+rax] ;move the address that is stored at the [IDT_HANDLERS_BASE_ADDRESS+rax] into rax 
cmp rax,0 ;compare rax with 0 
je .call_default  ;if equal then jump to the default handler which will do nothing
;otherwise if rax is 0 then this entry is not configured 
call rax ;call the value stored in rax 
mov al,0x20 ;move in al 0x20 
out MASTER_PIC_COMMAND_PORT,al ;then out on the master port the value 0x20 which indicates end of interrupt
out SLAVE_PIC_COMMAND_PORT,al ;out on the slave port the value 0x20 which indicates end of interrupt
jmp .out 
.call_default:
call idt_default_handler 
.out:
popaq                  
add rsp,16  ;add 16 to rsp to move the rsp back 16               
sti     ;then set interrupts again                 
iretq   ;this removes the value from the stack and restores them to where they were then continue and rsume execution       



setup_idt_irqs: ; setup_idt_entry expects that RDI = address of handler, and RDI = interrupt number
      pushaq
      ; This function need to be written by you.
;irq starts from interrupt 32 to 47
;this is the 16 interrupts that are being geenrated by the pic 
mov rsi,irq0
mov rdi,32
call setup_idt_entry

mov rsi,irq1
mov rdi,33
call setup_idt_entry
      
mov rsi,irq2
mov rdi,34
call setup_idt_entry
      
mov rsi,irq3
mov rdi,35
call setup_idt_entry
      
mov rsi,irq4
mov rdi,36
call setup_idt_entry

mov rsi,irq5
mov rdi,37
call setup_idt_entry
      
mov rsi,irq6
mov rdi,38
call setup_idt_entry
      
mov rsi,irq7
mov rdi,39
call setup_idt_entry
      
mov rsi,irq8
mov rdi,40
call setup_idt_entry
      
mov rsi,irq9
mov rdi,41
call setup_idt_entry

mov rsi,irq10
mov rdi,42
call setup_idt_entry
      
mov rsi,irq11
mov rdi,43
call setup_idt_entry
      
mov rsi,irq12
mov rdi,44
call setup_idt_entry
      
mov rsi,irq13
mov rdi,45
call setup_idt_entry
      
mov rsi,irq14
mov rdi,46
call setup_idt_entry
      
mov rsi,irq15
mov rdi,47
call setup_idt_entry ;by calling this function, it will do push all and load the idt descriptor which loads the address of the ID descriptor into rdi 
popaq
ret


setup_idt_exceptions: ;setup_idt_entry expects that RSI = address of handler, and RDI = interrupt number
pushaq
      ; This function need to be written by you.
;isr0 starts from interrupt 0 till interrupt 31
mov rsi,isr0
mov rdi,0
call setup_idt_entry
      
mov rsi,isr1
mov rdi,1
call setup_idt_entry
    
mov rsi,isr2
mov rdi,2
call setup_idt_entry
    
mov rsi,isr3
mov rdi,3
call setup_idt_entry
      
mov rsi,isr4
mov rdi,4
call setup_idt_entry
      
mov rsi,isr5
mov rdi,5
call setup_idt_entry
      
mov rsi,isr6
mov rdi,6
call setup_idt_entry
      
mov rsi,isr7
mov rdi,7
call setup_idt_entry
      
mov rsi,isr8
mov rdi,8
call setup_idt_entry
      
mov rsi,isr9
mov rdi,9
call setup_idt_entry
      
mov rsi,isr10
mov rdi,10
call setup_idt_entry
      
mov rsi,isr11
mov rdi,11
call setup_idt_entry
      
mov rsi,isr12
mov rdi,12
call setup_idt_entry
      
mov rsi,isr13
mov rdi,13
call setup_idt_entry
      
mov rsi,isr14
mov rdi,14
call setup_idt_entry
      
mov rsi,isr15
mov rdi,15
call setup_idt_entry
      
mov rsi,isr16
mov rdi,16
call setup_idt_entry
      
mov rsi,isr17
mov rdi,17
call setup_idt_entry
      
mov rsi,isr18
mov rdi,18
call setup_idt_entry
     
mov rsi,isr19
mov rdi,19
call setup_idt_entry
      
mov rsi,isr20
mov rdi,20
call setup_idt_entry
      
mov rsi,isr21
mov rdi,21
call setup_idt_entry
      
mov rsi,isr22
mov rdi,22
call setup_idt_entry

mov rsi,isr23
mov rdi,23
call setup_idt_entry
  
mov rsi,isr24
mov rdi,24
call setup_idt_entry
   
mov rsi,isr25
mov rdi,25
call setup_idt_entry
     
mov rsi,isr26
mov rdi,26
call setup_idt_entry

mov rsi,isr27
mov rdi,27
call setup_idt_entry
      
mov rsi,isr28
mov rdi,28
call setup_idt_entry
      
mov rsi,isr29
mov rdi,29
call setup_idt_entry
      
mov rsi,isr30
mov rdi,30
call setup_idt_entry
      
mov rsi,isr31
mov rdi,31
call setup_idt_entry
popaq
ret

; This macro will be used with exceptions that does not push error codes on the stack
; NOtice that we push first a zero on the stack to make it consistent with other excptions
; that pushes an error code on the stack
%macro ISR_NOERRCODE 1
  [GLOBAL isr%1]
  isr%1:
      cli
      push qword 0
      push qword %1
      jmp isr_common_stub
%endmacro

; This macro will be used with exceptions that push error codes on the stack
; Notice that we here push only the interrupt number which is passed as a parameter to the macro
%macro ISR_ERRCODE 1
  [GLOBAL isr%1]
  isr%1:
      cli
      push qword %1
      jmp isr_common_stub
%endmacro


; This macro will be used with the IRQs generated by the PIC
%macro IRQ 2
  global irq%1
  irq%1:
      cli
      push qword 0
      push qword %2
      jmp irq_common_stub
%endmacro



ISR_NOERRCODE 0
ISR_NOERRCODE 1
ISR_NOERRCODE 2
ISR_NOERRCODE 3
ISR_NOERRCODE 4
ISR_NOERRCODE 5
ISR_NOERRCODE 6
ISR_NOERRCODE 7
ISR_ERRCODE   8
ISR_NOERRCODE 9
ISR_ERRCODE   10
ISR_ERRCODE   11
ISR_ERRCODE   12
ISR_ERRCODE   13
ISR_ERRCODE   14
ISR_NOERRCODE 15
ISR_NOERRCODE 16
ISR_NOERRCODE 17
ISR_NOERRCODE 18
ISR_NOERRCODE 19
ISR_NOERRCODE 20
ISR_NOERRCODE 21
ISR_NOERRCODE 22
ISR_NOERRCODE 23
ISR_NOERRCODE 24
ISR_NOERRCODE 25
ISR_NOERRCODE 26
ISR_NOERRCODE 27
ISR_NOERRCODE 28
ISR_NOERRCODE 29
ISR_NOERRCODE 30
ISR_NOERRCODE 31


IRQ   0,    32
IRQ   1,    33
IRQ   2,    34
IRQ   3,    35
IRQ   4,    36
IRQ   5,    37
IRQ   6,    38
IRQ   7,    39
IRQ   8,    40
IRQ   9,    41
IRQ  10,    42
IRQ  11,    43
IRQ  12,    44
IRQ  13,    45
IRQ  14,    46
IRQ  15,    47


isr255:
        iretq
