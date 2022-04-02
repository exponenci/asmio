    .global writeu32, writei32, writeh32, writeb32, writeb32_zf
    .global print_newline, str_len, print, print_strz
    .global alloc_mem, free_mem, readi32, readu32 
    .global readi32_arr, readu32_arr, input_str_buf, input_str, input_strz

    .data
ten:
    .int 0xa
freelist:
    .skip 4, 0
newline:
    .ascii "\n"
hyphen:
    .ascii "-"

    .text
print:
    // void print(char * buf, uint32_t size); 
    // prints `size` bytes beginning from `buf`
    push %ebp
    mov %esp, %ebp
    push %ebx
    mov $0x4, %eax
    mov $0x1, %ebx
    mov 0x8(%ebp), %ecx
    mov 0xc(%ebp), %edx
    int $0x80
    pop %ebx
    pop %ebp
    ret


print_newline:
    // void print_newline(); 
    // prints new line
    push %ebp
    mov %esp, %ebp
    mov $0x1, %eax
    push %eax
    push $newline
    call print
    add $0x8, %esp
    pop %ebp
    ret


print_hyphen:
    // void print_hyphen(); 
    // prints hyphen
    push %ebp
    mov %esp, %ebp
    mov $0x1, %eax
    push %eax
    push $hyphen
    call print
    add $0x8, %esp
    pop %ebp
    ret


writeu32:
    // void writeu32(uint32_t num);
    // prints unsigned 32-bit value `num` in decimal 
    push %ebp
    mov %esp, %ebp
    push %ebx
    push %esi
    push %edi
    mov 0x8(%ebp), %eax // value to print
    mov $0xa, %ecx      // delimiter
    sub $0xa, %esp      // buffer
    mov %esp, %edi      // we will keep buffer in %edi  
    xor %esi, %esi      // counter
    xor %ebx, %ebx
writeu32__loop__get_modul_dec:
    xor %edx, %edx      // clear upper bits
    test %eax, %eax
    jz writeu32__loop__save_to_buffer
    div %ecx
    add $'0', %dl
    push %edx
    inc %esi
    jmp writeu32__loop__get_modul_dec
writeu32__loop__save_to_buffer:
    cmp %ebx, %esi
    je writeu32__loop__end
    pop %edx
    movb %dl, (%edi, %ebx, 1)
    inc %ebx
    jmp writeu32__loop__save_to_buffer
writeu32__loop__end:
    test %ebx, %ebx
    jnz writeu32__end
    movb $'0', (%edi, %ebx, 1)
    inc %ebx
writeu32__end:
    push %ebx
    push %edi
    call print
    add $0x12, %esp
    pop %edi
    pop %esi
    pop %ebx
    pop %ebp
    ret


writei32:
    // void writei32(int32_t num);
    // prints signed 32-bit value `num` in decimal
    push %ebp
    mov %esp, %ebp
    mov 0x8(%ebp), %eax
    test %eax, %eax
    jns writei32_no_sign
    push %eax
    call print_hyphen
    pop %eax
    neg %eax
writei32_no_sign:
    push %eax
    call writeu32
    add $0x4, %esp
    pop %ebp
    ret


writeh32:
    // void writeh32(uint32_t num);
    // prints 32-bit value `num` in hex
    push %ebp
    mov %esp, %ebp
    push %edi
    sub $0x8, %esp
    mov %esp, %edi
    mov 0x8(%ebp), %eax
    mov $0x8, %edx
    xor %ecx, %ecx
writeh32__loop:
    test %edx, %edx
    jz writeh32__end
    mov %eax, %ecx
    and $0xf, %ecx
    add $'0', %ecx
    cmp $'9', %ecx
    jle writeh32__loop__le10
    add $0x7, %ecx 
writeh32__loop__le10:
    dec %edx
    movb %cl, (%edi, %edx, 1)
    shr $0x4, %eax
    jmp writeh32__loop
writeh32__end:
    push $0x8
    push %edi
    call print
    add $0x10, %esp
    pop %edi
    pop %ebp
    ret


writeb32:
    // void writeb32(uint32_t num);
    // prints 32-bit value `num` in boolean
    push %ebp
    mov %esp, %ebp
    push %edi
    sub $0x20, %esp
    mov %esp, %edi
    mov 0x8(%ebp), %eax
    mov $0x20, %edx
    xor %ecx, %ecx
writeb32__loop:
    test %edx, %edx
    jz writeb32__end
    movb %al, %cl
    and $0x1, %cl
    add $'0', %cl
    dec %edx
    movb %cl, (%edi, %edx, 1)
    shr $0x1, %eax
    jmp writeb32__loop
writeb32__end:
    push $0x20
    push %edi
    call print
    add $0x28, %esp
    pop %edi
    pop %ebp
    ret


writeb32_zf:
    // void writeb32_zf(uint32_t num);
    // prints 32-bit value `num` in boolean without prefix zeros
    push %ebp
    mov %esp, %ebp
    push %edi
    push %ebx
    sub $0x20, %esp
    mov %esp, %edi
    mov 0x8(%ebp), %eax
    mov $0x20, %edx
    mov $0x21, %ebx
    xor %ecx, %ecx
writeb32_zf__loop:
    test %edx, %edx
    jz writeb32_zf__end
    movb %al, %cl
    and $0x1, %cl
    add $'0', %cl
    dec %edx
    movb %cl, (%edi, %edx, 1)
    shr $0x1, %eax
    cmp $'0', %cl
    je writeb32_zf__loop
    mov %edx, %ebx
    jmp writeb32_zf__loop
writeb32_zf__end:
    cmp $0x21, %ebx
    jne writeb32_zf__noempty
    mov $0x1f, %ebx
writeb32_zf__noempty:
    mov $0x20, %eax
    sub %ebx, %eax
    add %ebx, %edi
    push %eax
    push %edi
    call print
    add $0x28, %esp
    pop %ebx
    pop %edi
    pop %ebp
    ret


str_len:
    // uint32_t str_len(char *buf);
    // returns the length from `buf` to the first '\0' 
    push %ebp
    mov %esp, %ebp
    push %esi
    xor %eax, %eax
    xor %ecx, %ecx
    mov 0x8(%ebp), %esi
str_len__loop:
    movb (%esi, %eax), %cl
    test %cl, %cl
    jz str_len__end
    inc %eax
    jmp str_len__loop
str_len__cond:
    cmp %eax, %eax
    jz str_len__end
    dec %eax
str_len__end:
    pop %esi
    pop %ebp
    ret


print_strz:
    // void print_strz(char *buf);
    // prints string in `buf` till first '\0'
    push %ebp
    mov %esp, %ebp
    push 8(%ebp)
    call str_len
    add $0x4, %esp
    push %eax
    push 8(%ebp)
    call print
    add $0x8, %esp
    pop %ebp
    ret


memsize:
    // the function, which works with edx as shown below
    //      edx = max(4, ceil(edx / 4) * 4) 
    push %ebp
    mov %esp, %ebp
    xor %ecx, %ecx
    test %edx, %edx
    jz memsize__assign4
    mov %edx, %ecx
    shr $0x2, %ecx
    shl $0x2, %ecx
    cmp %ecx, %edx
    je memsize__not_overflow
memsize__assign4:
    add $0x4, %ecx
    jnc memsize__not_overflow
    xor %eax, %eax
    jmp memsize__end
memsize__not_overflow:
    mov $0x2d, %eax
memsize__end:
    mov %ecx, %edx
    pop %ebp
    ret


alloc_mem:
    // void *alloc_mem(uint32_t size);
    // allocates memory of size `size` aligned by 4
    // returns 0 if error occured
    // mem block size is written to first word of allocated memory, 
    // address of second word is returned
    push %ebp
    mov %esp, %ebp
    push %ebx
    push %esi
    cmpl $0x0, freelist
    je alloc_mem__msys_call_brk
    movl freelist, %eax     // void* next
    lea freelist, %ecx
    mov 0x8(%ebp), %ebx     // needed size
alloc_mem__check_memblock_loop:
    cmpl $0x0, %eax
    je alloc_mem__msys_call_brk
    cmpl %ebx, (%eax)
    jae alloc_mem__chosen_block
    add $0x4, %eax
    mov %eax, %ecx
    movl (%eax), %eax
    jmp alloc_mem__check_memblock_loop
alloc_mem__chosen_block:    // chosen one is stored in eax, making exchange of ptrs
    add $0x4, %eax
    movl (%eax), %edx
    movl %edx, (%ecx)
    jmp alloc_mem__end
alloc_mem__msys_call_brk:
    mov $0x2d, %eax         // remember mem_block_start
    xor %ebx, %ebx
    int $0x80
    mov %eax, %esi
    mov 0x8(%ebp), %edx
    call memsize  
    cmp $0x0, %eax
    je alloc_mem__err
    add $0x4, %edx
    jc alloc_mem__err
    add %esi, %edx
    jc alloc_mem__err
    mov %edx, %ebx
    int $0x80
    cmp %ebx, %eax          // if ebx != eax (aiming mem address != actual mem address)
    jne alloc_mem__err
    mov %esi, %eax          // write actual size in first 4 bytes
    sub $0x4, %ebx
    sub %esi, %ebx
    movl %ebx, (%eax)
    add $0x4, %eax
    jmp alloc_mem__end
alloc_mem__err:
    xor %eax, %eax
alloc_mem__end:
    pop %esi
    pop %ebx
    pop %ebp
    ret


free_mem:
    // void free_mem(void *mem);
    // appends `mem` to free memories list, that can be reused by calling alloc_mem 
    // from size less or equal to size of `mem`
    push %ebp
    movl %esp, %ebp
    movl 0x8(%ebp), %eax
    movl freelist, %ecx
    movl %ecx, (%eax)
    subl $0x4, %eax
    movl %eax, freelist
    pop %ebp
    ret


read_byte:
    // requires ecx to be equal to buffer address; 
    // reads one byte from standart input and writes it to the ecx
    push %ebp
    mov %esp, %ebp
    mov $0x3, %eax
    xor %ebx, %ebx
    mov $0x1, %edx
    int $0x80
    pop %ebp
    ret


readu32:
    // uint32_t readu32();
    // reads unsinged 32-bit value
    push %ebp
    mov %esp, %ebp
    push %ebx
    sub $0x4, %esp
    mov %esp, %ecx    // buffer to input bytes
    xor %eax, %eax    // result will be here
readu32__loop:
    push %eax
    call read_byte
    test %eax, %eax
    pop %eax
    jle readu32__end  // if eof
    xor %ebx, %ebx    // to operate with inputed byte
    movb (%ecx), %bl
    cmp $0xa, %bl     // if is new line
    je readu32__end
    cmp $0x20, %bl    // if is space
    je readu32__end
    sub $'0', %bl
    mull ten          // eax *= 10  // без учета overflow
    add %ebx, %eax    // eax += %dl // без учета overflow
    jmp readu32__loop
readu32__end:
    add $0x4, %esp
    pop %ebx
    pop %ebp
    ret


readi32:
    // int32_t readi32();
    // reads singed 32-bit value
    push %ebp
    mov %esp, %ebp
    push %ebx
    push %edi
    xor %edi, %edi
    sub $0x4, %esp
    mov %esp, %ecx    // buffer to input bytes
    call read_byte
    xor %ebx, %ebx
    movb (%ecx), %bl
    cmp $45, %bl
    je readi32__check_minus
    sub $'0', %bl
    mov %ebx, %eax
    jmp readi32__loop
readi32__check_minus:
    inc %edi
    xor %eax, %eax
readi32__loop:
    push %eax
    call read_byte
    test %eax, %eax
    pop %eax
    jle readi32__set_sign  // if eof
    xor %ebx, %ebx    // to operate with inputed byte
    movb (%ecx), %bl
    cmp $0xa, %bl     // if is new line
    je readi32__set_sign
    cmp $0x20, %bl    // if is space
    je readi32__set_sign
    sub $'0', %bl
    mull ten          // eax *= 10  // без учета overflow
    add %ebx, %eax    // eax += %dl // без учета overflow
    jmp readi32__loop
readi32__set_sign:
    test %edi, %edi
    jz readi32__end
    neg %eax
readi32__end:
    add $0x4, %esp
    pop %edi
    pop %ebx
    pop %ebp
    ret


readz32_arr:
    // void *readi32_arr(void* (*func)(uint32_t), uint32_t size);
    // returns address to the beginning of array of `size` objects read by `func`
    push %ebp
    mov %esp, %ebp
    push %edi
    push %esi
    push %ebx
    xor %edi, %edi
    mov 0xc(%ebp), %eax
    mov 0x8(%ebp), %ebx // указатель на функцию
    shl $0x2, %eax
    push %eax
    call alloc_mem
    mov %eax, %esi // %esi = malloc(n)
    pop %eax
    shr $0x2, %eax // %eax = n
readz32_arr__loop:
    cmp %edi, 0xc(%ebp)
    je readz32_arr__end
    call *%ebx
    movl %eax, (%esi, %edi, 4)
    inc %edi
    jmp readz32_arr__loop
readz32_arr__end:
    mov %esi, %eax
    pop %ebx
    pop %esi
    pop %edi
    pop %ebp
    ret


readi32_arr:
    // int32_t *readi32_arr(uint32_t size);
    // reads `size` singed 32-bit values and stores them in array
    // returns address to the beginning of array
    push %ebp
    mov %esp, %ebp
    push 0x8(%ebp)
    push $readi32
    call readz32_arr
    add $0x8, %esp
    pop %ebp
    ret


readu32_arr:
    // uint32_t *readu32_arr(uint32_t size);
    // reads `size` unsinged 32-bit values and stores them in array
    // returns address to the beginning of array
    push %ebp
    mov %esp, %ebp
    push 0x8(%ebp)
    push $readu32
    call readz32_arr
    add $0x8, %esp
    pop %ebp
    ret

input_str_buf:
    // char *input_str_buf(char *buf, uint32_t size);
    // reads `size` bytes from standart input and writes them to `buf`
    // returns `buf`
    push %ebp
    mov %esp, %ebp
    push %ebx
    mov $0x3, %eax
    xor %ebx, %ebx
    mov 0x8(%ebp), %ecx 
    mov 0xc(%ebp), %edx 
    int $0x80
    mov %ecx, %eax
    pop %ebx
    pop %ebp
    ret


input_str:
    // char *input_str(uint32_t size);
    // allocates memory of size `size` and fills it by 
    // reading `size` bytes from standart input
    // user must free memory after usage by calling free_mem
    push %ebp
    mov %esp, %ebp
    push 0x8(%ebp)
    call alloc_mem
    add $0x4, %esp
    push 0x8(%ebp)  // ptr to size
    push %eax       // ptr to buff
    call input_str_buf
    add $0x8, %esp
    pop %ebp
    ret


input_strz:
    // char *input_strz(uint32_t size);
    // same to input_str, but allocates one more byte
    push %ebp
    mov %esp, %ebp
    mov 0x8(%ebp), %eax
    inc %eax
    push %eax
    call alloc_mem
    add $0x4, %esp
    push 0x8(%ebp)
    push %eax
    call input_str_buf
    add $0x8, %esp
    pop %ebp
    ret
