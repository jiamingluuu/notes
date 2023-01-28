#include "mmu.h"
#include "../memory/dram.h"

/*
 * convert virtual address to physcial address
 */
uint64_t va2pa(uint64_t vaddr) {
    return vaddr % MM_LEN;
}
