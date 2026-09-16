# Native Windows CPU libCEED

Base: 39f259f89332e936122f7e02d6088a1dae3fb628 (BSD-2-Clause).
The overlay CMake recipe mirrors upstream's mandatory ref/blocked/opt CPU source
sets and gallery. IntelLLVM C99 compiles existing VLAs without rewriting kernels.
GPU and optional optimized backends are outside the V1 feature set.

`windows-cpu-registration.patch` registers exactly those four compiled backends.
`windows-allocation.patch` routes Windows aligned malloc/free/realloc through
`cmake/libceed/windows_alloc.c`. The adapter preserves CEED_ALIGN=64, tracks only
its own aligned allocations under an SRW lock, and dispatches ordinary calloc and
caller-owned malloc inputs to the normal CRT family. It never reads metadata
before an unowned pointer. Reallocation failure retains the original pointer.
There is no library-wide allocator replacement or reduced alignment assumption.

The focused allocator test covers alignment, grow/preserved contents, zero size,
calloc, ordinary caller-owned memory, and CEED_OWN_POINTER destruction. Four
upstream vector/restriction/operator tests run on each of the four CPU backends;
their mismatch output is treated as failure even when their exit status is zero.
These are scoped native tests, not the entire libCEED suite or Palace numerics.
