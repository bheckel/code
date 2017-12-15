/*****************************************************************************
 *     Name: modulus.c
 *
 *  Summary: Demo of printing a 10 column grid.
 *
 *  Created: Tue 23 Oct 2001 11:14:54 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>

int main(void) {
  int i;

  for ( i = 1; i < 100; i++ ) {
    printf("%d ", i);
    if ( i % 10 == 0 ) {
      printf("\n");
    }
  }

  printf("\n");

  return 0;
}
