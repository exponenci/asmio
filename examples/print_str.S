#include <sys/syscall.h>
    /*  reading some input of size less 256 bytes, 
        printing count of read bytes and read string  */
    .global main
main:
    mov $0xff, %eax          // we assume that will not recieve input > 255 bytes
    push %eax
    call input_strz
    add $0x4, %esp
    mov %eax, %esi           // address of buffer
    push %eax
    call str_len
    add $0x4, %esp
    mov %eax, %edi           // length of string
    push %edi
    call writeu32
    call print_newline
    push %esi
    call print
    add $0x8, %esp
    push %esi
    call free_mem
    add $0x4, %esp
    mov $SYS_exit, %eax      // SYS_exit = 1
    mov $0x0, %ebx
    int $0x80
