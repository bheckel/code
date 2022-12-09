/*****************************************************************************
 *     Name: getbit.c
 *
 *  Summary: Determine if a bit is set.
 *
 *  Created: Fri 02 Aug 2002 18:23:17 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>

#define mask1(i)      (1u << i)
#define mask0(i)     ~(1u << i)
#define getbit(n,i)   !!((n) & mask1(i))

int main(void) {
  int x;

  x = getbit(32, 5);

  // 32 base 10 is 100000 base 2
  printf("bit 4 is %d\n", getbit(32, 4));
  printf("bit 5 is %d\n", x);

  return 0;
}
