#include <inttypes.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>

void print_newline();
void *alloc_mem(uint32_t);
void free_mem(void*);
uint32_t str_len(char *);

void writeu32(uint32_t);
void writei32(int32_t);
void writeh32(uint32_t);
void writeb32(uint32_t);
void writeb32_zf(uint32_t);

uint32_t readu32();
int32_t readi32();
uint32_t *readu32_arr(uint32_t);
int32_t *readi32_arr(uint32_t);

void print(char *, uint32_t);
void print_strz(char *);
char *input_str(uint32_t);
char *input_strz(uint32_t);    
char *input_str_buf(char *, uint32_t);

int main() {
    {   //    some samples of string input/output functions            //
        int fd = open("samples/print_str.txt", O_RDONLY);
        dup2(fd, 0);
        char *dataz = input_strz(14);
        print_strz(dataz);
        free_mem(dataz);
        char *data = input_str(15);
        print(data, str_len(data));
        print_newline();
        free_mem(data);
        close(fd);
    }
    {   //    some samples of 32-bit integers input/output functions    //
        int fd = open("samples/read_int.txt", O_RDONLY);
        dup2(fd, 0);
        uint32_t unsigned_value = readu32();
        int32_t signed_value = readi32();
        writeu32(unsigned_value);
        print_newline();
        writei32(signed_value);
        print_newline();
        writeh32(0x324AFED0);
        print_newline();
        writeb32(0b000101001011110);
        print_newline();
        writeb32_zf(0b000101001011110);
        print_newline();
        close(fd);
    }
    {   //    some samples of 32-bit integers array input functions    //
        int fd = open("samples/read_arr.txt", O_RDONLY);
        dup2(fd, 0);
        uint32_t n = 3;
        int32_t *arri = readi32_arr(n);
        for (int i = 0; i < n; ++i) {
            writei32(arri[i]); print_newline();
        }
        free_mem((void*)arri);
        uint32_t *arru = readu32_arr(n);
        for (int i = 0; i < n; ++i) {
            writeu32(arru[i]); print_newline();
        }
        free_mem((void*)arru);
        close(fd);
    }
    return 0;
}
