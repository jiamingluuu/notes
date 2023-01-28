/*
 * File name: 01.c
 *
 * Description: This is the first lecture on Computer System: A Programmer's
 * Perspective (abbr. CSAPP). It is an intro to C, that illustrates the 
 * low_bit function, and gives some implementation on this function.
 */

#include<stdio.h>

unsigned low_bit(unsigned x){
    /** 
     * return the value of the lowest bit of x
     *      x       ~x      ~x + 1
     *  aaaaaaa1 bbbbbbb0 bbbbbbb1
     *  one of a and b is 0, a & b = 0. and the last digit of x and 
     *  ~x + 1 is 1.
     * 
     *  also, for 
     * x    =   aaaa1000
     * ~x   =   bbbb0111
     * ~x+1 =   bbbb1000
     */

    return x & (~x + 1);
}

unsigned Letter(unsigned x){
    // return 0 if and only if the hexadecimal of x contains letter only

    // e.g.
    // Letter(0xa0a0a0a0) will return 0x10101010
    
    /**
     *             the core idea of this function:
     * the hexadecimal abcd is letter, i.e. abcd >= a if and only if 
     *                      a & (c | d) == 1
     * 
     * so for a hex:
     *          a   b   c   d
     * if we want to get the digit of c, we can use 
     *        & 0   0   1   0   =   & 2
     * so for each digit in x = yyyyyyyy, we can use &22222222 to get
     * the digit on c
     * 
     */

    unsigned x1 = x & 0x22222222;
    unsigned x2 = x & 0x44444444;
    unsigned x3 = x & 0x88888888;

    /**
     * however, notice that 
     * x1       x2      x3
     * 00x0     0x00    x000
     * 
     * their bits are stagger, so we need to bit shift them to the following
     * x1       x2      x3
     * 000x     000x    000x
     * 
     */

    unsigned a = (x3 >> 3) & ((x2 >> 2) | x1 >> 1);

    return a;
}

int main(){
    // int type has range [-2147483648, 2147483647]
    int a = 2147483647;

    printf("%d\n", a);

    // use %x for the place holder of 16 bit
    printf("0x%x\n", a);

    // a + 1 = -2147483647, this is called overflow
    printf("%d\n", a+1);

    printf("0x%x\n", low_bit(0x2));

    // the following array S[n] is called binary indexed array, which is
    // used to record the sum of T[i], where 0 <= i <= n
    // time complexity to create array S: O(log N)
    unsigned n = 7;
    printf("S[%u] = \n", n);
    printf("    T[%u]\n", n);
    n = n - low_bit(n);
    printf("  + T[%u]\n", n);
    n = n - low_bit(n);
    printf("  + T[%u]\n", n);
    n = n - low_bit(n);
    printf("  + T[%u]\n", n);

    return 0;
}
