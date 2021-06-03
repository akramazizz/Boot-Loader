;************************************ popaq.asm ******************************************
%macro popaq 0
 ;Restore registers from the stack.
 ;--------------------------------
 pop r15 ;restore current r15
 pop r14 ;restore current r14
 pop r13 ;restore current r13
 pop r12 ;restore current r12
 pop r11 ;restore current r11
 pop r10 ;restore current r10
 pop r9 ;restore current r9
 pop r8 ;restore current r8
 pop rdi ;restore current rdi
 pop rsi ;restore current rsi
 pop rbp ;restore current rbp
 pop rdx ;restore current rdx
 pop rcx ;restore current rcx
 pop rbx ;restore current rbx
 pop rax ;restore current rax
%endmacro