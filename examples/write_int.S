#include <sys/syscall.h>
    /*  printing one 32-byte code as signed/unsigned 
        decimal/hex/boolean  */
    .global main
main:
    mov $0xDEADBEAF, %eax
    push %eax                // remember function's argument
    call writei32
    call print_newline
    call writeu32
    call print_newline
    call writeh32
    call print_newline
    call writeb32_zf
    call print_newline
    add $0x4, %esp
    mov $SYS_exit, %eax      // SYS_exit = 1
    mov $0x0, %ebx
    int $0x80
