%define MASTER_PIC_COMMAND_PORT     0x20
%define SLAVE_PIC_COMMAND_PORT      0xA0
%define MASTER_PIC_DATA_PORT        0x21
%define SLAVE_PIC_DATA_PORT         0xA1


    configure_pic:
pushaq
                  ; This function need to be written by you.
mov al,11111111b ;disable all IRQs by masking them (by writing all 1s to all data ports: MASTER_PIC_DATA_PORT and SLAVE_PIC_DATA_PORT)
out MASTER_PIC_DATA_PORT,al
out SLAVE_PIC_DATA_PORT,al
mov al,00010001b ;to set the first ICW we use bit 0 and by setting the 4th bit to 1 we are setting ICW4, 00010001b will be written to al 
out MASTER_PIC_COMMAND_PORT,al ;write 00010001b to command port: MASTER_PIC_COMMAND_PORT
out SLAVE_PIC_COMMAND_PORT,al ;write 00010001b to command port: SLAVE_PIC_COMMAND_PORT
mov al,0x20 ;I want the master to start its first pin at interrupt 32 hence we will move into al 0x20
out MASTER_PIC_DATA_PORT,al ;then move into the data port al, thats ICW2 which is setting the mapping 
mov al,0x28 ;to send the mapping of the slave, we store interrupt 40 (0x28) into al 
out SLAVE_PIC_DATA_PORT,al ;then move into the data port al
;now we need to set ICW3 by using a bitmap to tell the master that the slave will communicate with you on IRQ2 and vice versa
mov al,00000100b ;bit number 2 will be set which indicates that the slave will communicate with the master on pin number 2
out MASTER_PIC_DATA_PORT,al
mov al,00000010b ;now i need to send the slave the pin number hence by sending this 00000010b we are telling the slave that the communication is happening on pin 2
out SLAVE_PIC_DATA_PORT,al
;finally i need to tell the oic that i have finished the configuration by sending icw4
mov al,00000001b ;hence icw4 is basically writing to the data port the value 1 into al
out MASTER_PIC_DATA_PORT,al ;out it to MASTER_PIC_DATA_PORT
out SLAVE_PIC_DATA_PORT,al ;out it to SLAVE_PIC_DATA_PORT
mov al,0x0 ;I write 0 into all data ports in order to unmask all pins 
out MASTER_PIC_DATA_PORT,al ;out it to MASTER_PIC_DATA_PORT
out SLAVE_PIC_DATA_PORT,al ;out it to SLAVE_PIC_DATA_PORT
popaq
ret


    set_irq_mask: ;this function selectively masks a pin inside the pic (in the pic i have pin 0 to 15 hence
                  ;in this routine i will receive value 0 to 15 and accordingly we will try to set the IMR)
pushaq                              ;Save general purpose registers on the stack
        ; This function need to be written by you.
mov rdx,MASTER_PIC_DATA_PORT ;move the data port of the master into rdx
cmp rdi,15 ;compare rdi with 15
jg .out ;if greater then there is something wrong so jump to out to exit
cmp rdi,8 ;otherwise compare rdi with 8 
jl .master ;if rdi is less than 8 this means that the pin i want to set is in the master so jump to .master
sub rdi,8 ;otherwise substract from rdi 8
mov rdx,SLAVE_PIC_DATA_PORT ;set rdx to slave hence we will access the port of the slave
.master:
in eax,dx ;read imr of the port i want to configure (either slave or master)
mov rcx,rdi ;move rdi into rcx
mov rdi,0x1 ;move 0x1 into rdi hence set the first bit of rdi to 1
shl rdi,cl ;shift left rdi by cl (which is the number that was originally stored in rdi which is 1)
or rax,rdi ;or rax with rdi (rax contains the value of the imr) which will set the bit inside rax that needs to be set
out dx,eax ;out eax back into dx which will set the mask
.out:    
popaq
ret


    clear_irq_mask: ;in order to clear we need to instead of setting to 1, we set to 0
;hence instead of oring rax and rdi, we and them
        pushaq
        ; This function need to be written by you.
mov rdx,MASTER_PIC_DATA_PORT ;move the data port of the master into rdx
cmp rdi,15 ;compare rdi with 15
jg .out ;if greater then there is something wrong so jump to out to exit
cmp rdi,8 ;otherwise compare rdi with 8 
jl .master ;if rdi is less than 8 this means that the pin i want to set is in the master so jump to .master
sub rdi,8 ;otherwise substract from rdi 8
mov rdx,SLAVE_PIC_DATA_PORT ;set rdx to slave hence we will access the port of the slave
.master:
in eax,dx ;read imr of the port i want to configure (either slave or master)
mov rcx,rdi ;move rdi into rcx
mov rdi,0x0 ;move 0x0 into rdi hence set the first bit of rdi to 0
shl rdi,cl ;shift left rdi by cl (which is the number that was originally stored in rdi which is 1)
and rax,rdi ;or rax with rdi (rax contains the value of the imr) which will set the bit inside rax that needs to be set
out dx,eax ;out eax back into dx which will set the mask
.out:    
popaq
ret
