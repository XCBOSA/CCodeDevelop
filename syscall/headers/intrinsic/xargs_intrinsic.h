#ifndef XARGS_INTRINSIC_H
#define XARGS_INTRINSIC_H

typedef char* xa_list;
const long XA_ALIGN = 8;

long xa_align_of(long size) {
    if (size <= 0) return 0;
    long base = (size / XA_ALIGN) * XA_ALIGN;
    if (size % XA_ALIGN) {
        base += XA_ALIGN;
    }
    return base;
}

long xa_test_internal(int a, int b) {
    void *aPtr = &a;
    void *bPtr = &b;
    return (long)bPtr - (long)aPtr;
}

void xa_start(xa_list &list, void* begin, long begin_size) {
    list = begin;
    list += xa_test_internal(1, 2);
    list -= XA_ALIGN;
    list += xa_align_of(begin_size);
}

void xa_arg(xa_list &list, long size, void* copyto) {
    char *ptr = copyto;
    for (int i = 0; i < size; i++) {
        *(ptr++) = list[i];
    }
    list += xa_test_internal(1, 2);
    list -= XA_ALIGN;
    list += xa_align_of(size);
}

void xa_end(xa_list &list) {
    list = NULL;
}

#endif
