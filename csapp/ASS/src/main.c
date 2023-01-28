#include<stdio.h>

#include "cpu/register.h"
#include "memory/instruction.h"
#include "memory/dram.h"
#include "cpu/mmu.h"
#include "disk/elf.h"

int main(){
    init_handler_table();

	return 0;
}
