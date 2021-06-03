%define CODE_SEG     0x0008         ; Code segment selector in GDT
%define DATA_SEG     0x0010         ; Data segment selector in GDT
%define PAGE_TABLE_EFFECTIVE_ADDRESS 0x1000

switch_to_long_mode:
 ; This function need to be written by you.
;enablin control register cr4 which enables/disables the processor operations and extensions
mov eax, 10100000b ;sey bits 5 and 7 which represent the physical address extension and the page global enabled 
mov cr4, eax ;cr4=eax
;enabling the control register cr3 which points to the address of the page table 
mov edx, PAGE_TABLE_EFFECTIVE_ADDRESS ;edi= 0x1000
mov cr3, edx ;cr3=edx
;enabling extended feature enable register 
mov ecx, 0xC0000080 ;ecx= 0xC0000080, 0xC0000080 is the extended feature enable register identifier 
rdmsr ;read from the model specific register (EFER)
or eax, 0x00000100 ;by oring eax with 0x0000010 we are settin the 8th bit which is the long mode enablement bit 
wrmsr ;write to model specific register 
;enabling control register cr0 which in return enables paging and protected mode 
mov ebx, cr0 ;ebx=cr0
or ebx, 0x80000001 ;enabling bit 0 which is the protected mode and bit 31 which is enables paging 
mov cr0, ebx ;cr0=ebx
;to jump to long mode
lgdt[GDT64.Pointer]
jmp CODE_SEG:LongModeEntry
ret ;return 
