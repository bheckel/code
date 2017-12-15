/*****************************************************************************
 *     Name: shift_assign.c
 *
 *  Summary: Demo of using shift >>  Count using powers of 2.
 *
 *  Created: Sun Aug 25 13:49:01 2002 (Bob Heckel)
 *****************************************************************************
*/
#include <stdlib.h> 
#include <stdio.h> 

int main(void) {
  int i;

  i = 4;
  i >>= 2;
  printf("shifted %d	", i);

  i = 8;
  i >>= 2;
  printf("shifted %d	", i);

  i = 16;
  i >>= 2;
  printf("shifted %d	", i);

  i = 32;
  i >>= 2;
  printf("shifted %d	", i);

  i = 64;
  i >>= 2;
  printf("shifted %d\n", i);

  return 0;
}
