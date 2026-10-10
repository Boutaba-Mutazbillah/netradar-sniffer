#ifndef INLINE_ASM_H
#define INLINE_ASM_H

#include <stdint.h>

static inline uint64_t read_hardware_timestamp(void) {
    uint32_t low, high;
    
    __asm__ __volatile__ (
        "lfence\n\t"
        "rdtsc\n\t"
        : "=a" (low), "=d" (high)
        :
        : "memory"
    );
    
    return ((uint64_t)high << 32) | low;
}

#endif
