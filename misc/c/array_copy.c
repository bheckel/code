/*****************************************************************************
 *     Name: array_copy.c
 *
 *  Summary: Copy one array to another.
 *
 * Adapted: Tue 12 Mar 2002 11:01:40 (Bob Heckel -- Stroustroup's summary on 
 *                                    Informit)
 *****************************************************************************
*/
#include <stdio.h>

int main(void) {
  int v1[] = { 0,1,2,3,4,5,6,7,8,9 };
  int v2[10];

  // ...

  int i;
  for ( i=0; i<10; ++i ) v2[i] = v1[i];

  printf("v2's 2nd element: %d\n", v2[3]);

  return 0;
}
