/*
 * File name: 02.c
 * Description: 2rd lecture on CSAPP. It demonstrates the rounding of floatings
 */

#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<stdint.h>
/**
 * an ideal format of the scientific natation of a binary float number is:
 *                  (-1)^s   *   1.f    *   2^E
 * 
 * a floating number m has 32 bits, indexed 31 - 0
 *      - m[31]         for s
 *      - m[30 - 23]    for E   = e - 127
 *      - m[22 - 0]     for f
 * 
 * four cases of floating number representation:
 *  - case 1: normalized
 *      e != 0 & E != 11111111
 *  - case 2: denormalized
 *      e == 0
 *      E == 1 - 127
 *      we have denormalized ofr the sake of 
 *          representing number 0.0 and representing the number close to 0.0
 *  - case 3: infinity
 *      e == 1111111 & f == 0
 *  - case 4: NaN (Not a Number)
 *      e == 1111111 & f != 0
 */ 

// unsigned int 32 bits type
uint32_t uint2float(uint32_t u){
    /**
     * convert an unsigned int to float
     * 
     * e.g. uint32_t x = 1u;        // u is used to represent a buch of 0
     *                 = 0x00000001
     * x is equivalent to 1.0
     * which is     (-1)^0    *    1.0    *    2^(127-127)
     */

    // assume there are n bits for 1.f

    // 32 zeros
    if(u == 0x00000000){
        return 0x00000000;
    }

    // counting the position of leading 1 in the binary of u
    int n = 31;
    while(0 <= n && (((u >> n) & 0x1) == 0x0)){
        n = n - 1;
    }

    uint32_t f, e;
    /**
     *      seee eeee efff ffff ffff ffff ffff ffff
     * <=   0000 0000 1111 1111 1111 1111 1111 1111
     */
    if(u <= 0x00ffffff){
        // no rounding 
        /**
         *               leading 1 and n - 1 bits of f
         *                 |--------|
         * u    = 0000000001xxxxxxxx
         * mask   00000000011111111
         *        |-------|
         *         32 - n bits of 0
         */

        uint32_t mask = 0xffffffff >> (32 - n);

        f = (u & mask) << (23 - n);
        e = n + 127;

        /**
         *    s    = x0000000
         * e << 23 = 0xxx0000
         *    f    = 0000xxxx
         */
        return (e << 23) | f;
    }
    else{
        // need rounding

        /**
         *          Rounding of float numbers
         * a float number has from:
         *                       xxXG.RSSSSS
         *                  Guard bit   Round bit   Sticky bit
         *      X     |     G.    |     R     |     S     |     Operation
         *  ----------|-----------|-----------|-----------|------------------
         *     0/1    |     0     |    0/1    |    0/1    |     Round down
         *      0     |     1     |     0     |     0     |     Round down
         *      1     |     1     |     0     |     0     |     Round up
         *     0/1    |     1     |     0     |     1     |     Round up
         *     0/1    |     1     |     1     |     0     |     Round up
         *     0/1    |     1     |     1     |     1     |     Round up
         * 
         */

        // expand to 64 bits for situations like 0xffffffff
        uint64_t a = 0;
        a += u;

        // comput g, r, s
        uint32_t g = (a >> (n - 23)) & 0x1;
        uint32_t r = (a >> (n - 24)) & 0x1;
        uint32_t s = 0x0;

        for(int j = 0; j < n - 24; j++){
            s = s | ((u >> j) & 0x1);
        }

        // compute carry bit
        a = a >> (n - 23);

        if((a >> 23) == 0x1){
            // 0       1      ?   ... ?
            // [24]   [23]   [22]    [0]

            f = a & 0x007fffff;
            e = n + 127;

            // carry = R & (G | S) by K-Map
            return (e << 23) | f;
        }
        else if((a >> 23) == 0x2){
            //  1      0      0   ... 0
            // [24]   [23]   [22]    [0]

            e = n + 1 + 127;
            return (e << 23);
        }

    }

    // return inf as defualt error
    return 0x7f800000;
}

int main(){
    

    return 0;
}
