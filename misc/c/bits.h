/* bit.h:    Bitwise functions for unsigned ints */
#ifndef BIT_H
#define BIT_H

#include <stdio.h>
#include <limits.h>

#define mask1(i)    (1u << i)
#define mask0(i)   (~(1u << i))

#define set(n,i)     ((n) | mask1(i))
#define reset(n,i)   ((n) & mask0(i))
#define toggle(n,i)  ((n) ^ mask1(i))
#define test(n,i)    !!((n) & mask1(i))

#define nbits(x) (sizeof(x) * CHAR_BIT)

unsigned fputb(unsigned, FILE *);
unsigned fgetb(FILE *);
unsigned count(unsigned);

#endif
