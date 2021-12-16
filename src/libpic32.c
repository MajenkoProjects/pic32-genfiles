#include <errno.h>
#include <sys/stat.h>
#include <sys/times.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>

#define STACK_BUFFER 32
void *sbrk(int nbytes) {
    extern int  _end;
    static void *heap_ptr = (void *)&_end;
    int stack;

    if (((void *)&stack - (heap_ptr + nbytes)) > STACK_BUFFER ) {
        void *base = heap_ptr;
        heap_ptr += nbytes;

        return base;
    } else {
        errno = ENOMEM;
        return (void *)-1;
    }
}


void __cxa_pure_virtual() { while (1); }

void __attribute__((weak)) _nmi_handler() {
}

void __attribute__((weak)) _on_reset() {
}


void __attribute__((weak)) _exit(int rc) {
    asm volatile("di");
    while(1);
}

int __attribute__((weak)) close(int file) {
    errno = EBADF;
    return -1;
}

int __attribute__((weak)) execve(const char *name, char * const *argv, char * const *env) {
    errno = ENOMEM;
    return -1;
}

int __attribute__((weak)) fork() {
    errno = EAGAIN;
    return -1;
}

int __attribute__((weak)) fstat(int file, struct stat *st) {
    st->st_mode = S_IFCHR;
    return 0;
}

int __attribute__((weak)) getpid() {
    return 1;
}

int __attribute__((weak)) isatty(int file) {
    return 1;
}

int __attribute__((weak)) kill(int pid, int sig) {
    errno = EINVAL;
    return -1;
}

int __attribute__((weak)) link(const char *old, const char *new) {
    errno = EMLINK;
    return -1;
}

int __attribute__((weak)) lseek(int file, int offset, int whence) {
    return 0;
}

int __attribute__((weak)) open(const char *name, int flags, int mode) {
    errno = ENOSYS;
    return -1;
}

int __attribute__((weak)) read(int file, char *ptr, int len) {
    return 0;
}

int __attribute__((weak)) stat(const char *file, struct stat *st) {
    st->st_mode = S_IFCHR;
    return 0;
}

clock_t __attribute__((weak)) times(struct tms *buf) {
    errno = EACCES;
    return -1;
}

int __attribute__((weak)) unlink(const char *name) {
    errno = ENOENT;
    return -1;
}

int __attribute__((weak)) wait(int *status) {
    errno = ECHILD;
    return -1;
}

int __attribute__((weak)) write(int file, char *buf, int nbytes) {
    return 0;
}

void reverse(char* begin, char* end) {
    char *is = begin;
    char *ie = end - 1;
    while(is < ie) {
        char tmp = *ie;
        *ie = *is;
        *is = tmp;
        ++is;
        --ie;
    }
}

char* ltoa(long value, char* result, int base) {
    if(base < 2 || base > 16) {
        *result = 0;
        return result;
    }

    char* out = result;
    long quotient = abs(value);

    do {
        const long tmp = quotient / base;
        *out = "0123456789abcdef"[quotient - (tmp * base)];
        ++out;
        quotient = tmp;
    } while(quotient);

    // Apply negative sign
    if(value < 0)
        *out++ = '-';

    reverse(result, out);
    *out = 0;
    return result;
}

char* ultoa(unsigned long value, char* result, int base) {
    if(base < 2 || base > 16) {
        *result = 0;
        return result;
    }

    char* out = result;
    unsigned long quotient = value;

    do {
        const unsigned long tmp = quotient / base;
        *out = "0123456789abcdef"[quotient - (tmp * base)];
        ++out;
        quotient = tmp;
    } while(quotient);

    reverse(result, out);
    *out = 0;
    return result;
}

char * dtostrf(double number, signed char width, unsigned char prec, char *s) {
    bool negative = false;

    if (isnan(number)) {
        strcpy(s, "nan");
        return s;
    }
    if (isinf(number)) {
        strcpy(s, "inf");
        return s;
    }

    char* out = s;

    int fillme = width; // how many cells to fill for the integer part
    if (prec > 0) {
        fillme -= (prec+1);
    }

    // Handle negative numbers
    if (number < 0.0) {
        negative = true;
        fillme--;
        number = -number;
    }

    // Round correctly so that print(1.999, 2) prints as "2.00"
    // I optimized out most of the divisions
    double rounding = 2.0;
    uint8_t i;
    for (i = 0; i < prec; ++i)
        rounding *= 10.0;
    rounding = 1.0 / rounding;

    number += rounding;

    // Figure out how big our number really is
    double tenpow = 1.0;
    int digitcount = 1;
    while (number >= 10.0 * tenpow) {
        tenpow *= 10.0;
        digitcount++;
    }

    number /= tenpow;
    fillme -= digitcount;

    // Pad unused cells with spaces
    while (fillme-- > 0) {
        *out++ = ' ';
    }

    // Handle negative sign
    if (negative) *out++ = '-';

    // Print the digits, and if necessary, the decimal point
    digitcount += prec;
    int8_t digit = 0;
    while (digitcount-- > 0) {
        digit = (int8_t)number;
        if (digit > 9) digit = 9; // insurance
        *out++ = (char)('0' | digit);
        if ((digitcount == prec) && (prec > 0)) {
            *out++ = '.';
        }
        number -= digit;
        number *= 10.0;
    }

    // make sure the string is terminated
    *out = 0;
    return s;
}

void __attribute__((weak)) on_bootstrap() {
}
