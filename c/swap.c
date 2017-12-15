/*****************************************************************************
 *     Name: swap.c
 *
 *  Summary: Swap two variables without using a temporary variable.
 *
 *  Adapted: Fri 14 Jun 2002 09:51:40 (Bob Heckel -- Portico tips)
 *****************************************************************************
*/
#include <stdio.h>

int main(int argc, char *argv[]) {
  int a = 5;
  int b = 6;

  printf("before a: %d b: %d\n", a, b);

  /* Use exclusive OR */
  a = a ^ b;                                                                                                  
  b = a ^ b;                                                                                                  
  a = b ^ a;

  printf("after  a: %d b: %d\n", a, b);

  return 0;
}
