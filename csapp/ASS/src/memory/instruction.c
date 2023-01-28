#include "instruction.h"
#include "../cpu/mmu.h"
#include "../cpu/register.h"

#include<stdlib.h>
#include<stdint.h>

/*
 * This is the implementation of memory model. See the following conversion 
 * at p.169 CSAPP.
 */
static uint64_t decode_od(od_t od)
{
    if (od.type == IMM) {
        return *((uint64_t *)&od.imm);
    }
    else if(od.type == REG) {
        return (uint64_t)od.reg1;
    }
    else {
        // mm
        uint64_t vaddr = 0;

        if (od.type == MM_IMM) {
            vaddr = od.imm;
        }
        else if (od.type == MM_REG) {
            vaddr = *(od.reg1);
        }
        else if (od.type == MM_IMM_REG) {
            vaddr = od.imm + *(od.reg1);
        }
        else if (od.type == MM_REG1_REG2) {
            vaddr = *(od.reg1) + *(od.reg2);
        }
        else if (od.type == MM_IMM_REG1_REG2) {
            vaddr = *(od.reg1) + *(od.reg2) + od.imm;
        }
        else if (od.type == MM_REG2_S) {
            vaddr = (*(od.reg2)) * od.scal;
        }
        else if (od.type == MM_IMM_REG2_S) {
            vaddr = od.imm + (*(od.reg2)) * od.scal;
        }
        else if (od.type == MM_REG1_REG2_S) {
            vaddr = *(od.reg1) = (*(od.reg2)) * od.scal;
        }
        else if (od.type == MM_IMM_REG1_REG2_S) {
            vaddr = od.imm + *(od.reg1) + (*(od.reg2)) * od.scal;
        }

        return va2pa(vaddr);
    }
}

void instruction_cycle() {
    inst_t *instr = (inst_t *)reg.rip;

    uint64_t src = decode_od(instr->src);
    uint64_t dst = decode_od(instr->dst);

    // handler is a function-typed array
    // because oprand is an enumerator, so we can use a pointer to access whcih 
    // function are we going to use. 
    handler_t handler = handler_table[instr->op];
    handler(src, dst);
}

void init_handler_table() {
    handler_table[mov_reg_reg] = &mov_reg_reg_handler;
    handler_table[add_reg_reg] = &add_reg_reg_handler;
}

void mov_reg_reg_handler(uint64_t src, uint64_t dst) {
    *(uint64_t *)dst = *(uint64_t *)src;
    reg.rip = reg.rip + sizeof(inst_t);
}

void add_reg_reg_handler(uint64_t src, uint64_t dst) {
    /*
     * add two values on the register
     *
     * rax pmm[0x1234] = 0x1234000
     * rbx pmm[0x1235] = 0xabcs
     * src: 0x1234
     * dst: 0x1235
     *
     * the result is:
     * rax pmm[0x1234] = 0x1234abcd
     * rbx pmm[0x1235] = 0xabcd
     */
    *(uint64_t *)dst = *(uint64_t *)dst + *(uint64_t *)src;
    reg.rip = reg.rip + sizeof(inst_t);
}






