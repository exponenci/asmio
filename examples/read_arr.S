#include <sys/syscall.h>
    /*  printing input in reversed order in hex 
        input: n a1 ... an; 
              `n` - count of numbers to reverse
        output: an ... a1;  */
    .global main
main:
    call readu32
    mov %eax, %edi           // size of incoming array
    push %edi
    call readu32_arr
    mov %eax, %esi           // uint32_t array beginning
    dec %edi      
main__loop:
    cmp $0xffffffff, %edi    // -1 = 0xffffffff
    je main__end
    push (%esi, %edi, 4)
    call writeh32
    call print_newline
    add $0x4, %esp
    dec %edi
    jmp main__loop
main__end:
    push %esi
    call free_mem
    add $0x4, %esp
    mov $SYS_exit, %eax      // SYS_exit = 1
    mov $0x0, %ebx
    int $0x80
