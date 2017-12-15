/*****************************************************************************
 *     Name: endian.c
 *
 *  Summary: Comparison of little vs. big endian byte order.
 *
 *  Adapted: Sat 27 Jul 2002 17:37:58 (Bob Heckel -- C++ Primer Plus v4
 *                                     Stephen Prata)
 *****************************************************************************
*/
#include <stdio.h>

int main(void) {
  printf("0xABCD Big Endian: %d\n", 0xABCD);
  printf("0xABCD Little Endian: %d\n", 0xCDAB);

  return 0;
}

