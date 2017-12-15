/*****************************************************************************
 *     Name: floatingpt_division.c
 *
 *  Summary: Demo of coercision of types for floating point division.
 *
 *  Created: Mon 05 Aug 2002 11:10:54 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>

int main(void) {
  int x = 2;
  int y = 9;

  printf("ok %.3g\n", (float)x / (float)y);  

  return 0;
}
