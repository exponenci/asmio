# asmio.S

Все испытывают сложности, когда только начинают учиться писать на языке `Assembler`.
Одна из основных - хочется посмотреть, что хранится в каком-нибудь регистре или блоке памяти, с которым мы оперируем (да, я про "дебаг" через принт, для начинающего, по-моему, это то, что нужно). 
Смотреть на эти значения через какой-то дебаггер, например, `gdb`, не имеет особого смысла, т.к. человек только начинает изучать `Assembler`, а такого рода дебаггеры могут его только испугать и их использование требует некоторых знаний языка (с другой стороны, читать код обязательно нужно!).

Цель `asmio.S`: облегчить начинание программиста, который только окунется в эти дебри. Помочь ему с вводом/выводом строк определенной длины и 32-битных чисел в 2/10/16-ричной системе.

Используемый синтаксис AT&T, архитектура x86.

Собрать `asmio.S` с произвольным файлом можно с помощью: ```gcc -m32 <code>.S asmio.S```. 
Может понадобиться установка ``` sudo apt-get install gcc-multilib```.

Представленные в `asmio.S` функции функции:

```
void print_newline();       // prints new line
void *alloc_mem(uint32_t);  // allocates memory of given size aligned to 4
void free_mem(void*);       // frees memory allocated from alloc_mem
uint32_t str_len(char *);   // returns length of given string

void writeu32(uint32_t);    // prints 32-bit unsinged value in decimal
void writei32(int32_t);     // prints 32-bit singed value in decimal
void writeh32(uint32_t);    // prints 32-bit value in hex
void writeb32(uint32_t);    // prints 32-bit value in boolean
void writeb32_zf(uint32_t); // prints 32-bit value in boolean w/o prefix 0'z

uint32_t readu32();         // reads 32-bit unsigned value in decimal
int32_t readi32();          // reads 32-bit signed value in decimal
uint32_t *readu32_arr(uint32_t); // reads array of 32-bit unsigned value in decimal of given size
int32_t *readi32_arr(uint32_t);  // reads array of 32-bit signed value in decimal of given size

void print(char *, uint32_t); // prints size bytes from char array
void print_strz(char *);      // prints char array till first '\0'
char *input_str(uint32_t);    // allocates buffer of given size and fills it by read bytes
char *input_strz(uint32_t);   // same to input_str, but allocates incremented given size
char *input_str_buf(char *, uint32_t); // fills of given buffer with given size of bites
```

Примеры использования функций можно посмотреть в `example.S`. В `sample.c` можно посмотреть сигнатуру функций и их работу в принципе; поиграться с ними можно, меняя содержимое соответствующих файлов в `samples`.

Для вызова функции используется инструкция `call`. 
Для того, чтобы передать аргументы в функцию, нужно сохранить их в стек (в обратном от сигнатуры порядке), а после вызова аргументы должны быть убраны со стека (это можно сделать с помощью инструкции `pop`, или же изменив значение `%esp` на __n__, где __n__ - занятая аргументами память; подробную информацию можете найти в интернете или по ссылкам в футере). 

Наример, функция `writeh32` может вызываться следующим образом:
```
    push %eax
    call writeh32
    pop %eax
```
а функция `print` следующим:
```
    push %eax    // uint32_t
    push %ebx    // char *
    call print
    pop %ebx
    pop %eax
```

___
Полезные ссылки:
1. [Assembler x86 AT&T cheetsheet](https://github.com/kam3nskii/CheatSheets/tree/master/Assembly)
2. [WikiBooks](https://ru.wikibooks.org/wiki/%D0%90%D1%81%D1%81%D0%B5%D0%BC%D0%B1%D0%BB%D0%B5%D1%80_%D0%B2_Linux_%D0%B4%D0%BB%D1%8F_%D0%BF%D1%80%D0%BE%D0%B3%D1%80%D0%B0%D0%BC%D0%BC%D0%B8%D1%81%D1%82%D0%BE%D0%B2_C)
3. [Справочник инструкций](https://www.felixcloutier.com/x86/)
