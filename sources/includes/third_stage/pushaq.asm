;*******************************************************************************************************************
%macro pushaq 0
   ;Save registers to the stack.
   ;--------------------------------
    push rax      ;save current rax
    push rbx      ;save current rbx
    push rcx      ;save current rcx
    push rdx      ;save current rdx
    push rbp      ;save current rbp
    push rsi      ;save current rsi
    push rdi      ;save current rdi
    push r8       ;save current r8
    push r9       ;save current r9
    push r10      ;save current r10
    push r11      ;save current r11
    push r12      ;save current r12
    push r13      ;save current r13
    push r14      ;save current r14
    push r15      ;save current r15
    ;pushf
%endmacro


