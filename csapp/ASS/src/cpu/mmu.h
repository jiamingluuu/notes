// memory management unit

// include guard
#ifndef mmu_guard
#define mmu_guard

#include<stdint.h>

// virtual address to physical address
uint64_t va2pa(uint64_t vaddr);

#endif      // mmu_guard
