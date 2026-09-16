#ifndef PW_WINDOWS_ALLOC_H
#define PW_WINDOWS_ALLOC_H
#include <stddef.h>
int PwCeedAlignedAlloc(void **p, size_t alignment, size_t bytes);
void *PwCeedRealloc(void *p, size_t bytes);
void PwCeedFree(void *p);
#endif
