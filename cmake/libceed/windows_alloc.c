/* SPDX-License-Identifier: Apache-2.0
 * Windows CRT aligned allocations must use the matching free/realloc family.
 * Track only our aligned allocations; calloc and CEED_OWN_POINTER inputs remain
 * ordinary CRT allocations. Never probe memory preceding a foreign pointer.
 */
#include "pw_windows_alloc.h"
#include <windows.h>
#include <malloc.h>
#include <stdlib.h>
#include <errno.h>

typedef struct PwAllocation {
  void *pointer;
  size_t alignment;
  struct PwAllocation *next;
} PwAllocation;
static SRWLOCK allocation_lock = SRWLOCK_INIT;
static PwAllocation *allocations;

int PwCeedAlignedAlloc(void **p, size_t alignment, size_t bytes) {
  if (!bytes) { *p = NULL; return 0; }
  void *value = _aligned_malloc(bytes, alignment);
  if (!value) return ENOMEM;
  PwAllocation *entry = malloc(sizeof(*entry));
  if (!entry) { _aligned_free(value); return ENOMEM; }
  entry->pointer = value;
  entry->alignment = alignment;
  AcquireSRWLockExclusive(&allocation_lock);
  entry->next = allocations;
  allocations = entry;
  ReleaseSRWLockExclusive(&allocation_lock);
  *p = value;
  return 0;
}

void PwCeedFree(void *p) {
  if (!p) return;
  AcquireSRWLockExclusive(&allocation_lock);
  PwAllocation **slot = &allocations;
  while (*slot && (*slot)->pointer != p) slot = &(*slot)->next;
  PwAllocation *entry = *slot;
  if (entry) *slot = entry->next;
  ReleaseSRWLockExclusive(&allocation_lock);
  if (entry) { _aligned_free(p); free(entry); }
  else free(p);
}

void *PwCeedRealloc(void *p, size_t bytes) {
  if (!bytes) { PwCeedFree(p); return NULL; }
  AcquireSRWLockExclusive(&allocation_lock);
  PwAllocation *entry = allocations;
  while (entry && entry->pointer != p) entry = entry->next;
  void *value = entry ? _aligned_realloc(p, bytes, entry->alignment) : realloc(p, bytes);
  if (entry && value) entry->pointer = value;
  ReleaseSRWLockExclusive(&allocation_lock);
  return value;
}
