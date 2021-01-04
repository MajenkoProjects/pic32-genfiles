#include <errno.h>

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
