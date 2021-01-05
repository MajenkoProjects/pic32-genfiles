#include <errno.h>
#include <sys/stat.h>
#include <sys/times.h>

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


