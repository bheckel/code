/*****************************************************************************
 *     Name: ptr_to_multiarray.c
 *
 *  Summary: Use a pointer to access a multi-dimensional array.
 *
 *  Adapted: Sat 30 Mar 2002 18:51:40 (Bob Heckel -- Code Capsules Chuck
 *                                     Allison)
 *****************************************************************************
*/
#include <stdio.h>

int main(void) {
  /* Pointer to array of 4 ints. */ 
  int a[][4] = {{0,1,2,3},{4,5,6,7},{8,9,0,1}};
  int (*p)[4] = a;
  int i, j;
  size_t nrows = sizeof a / sizeof a[0];
  size_t ncols = sizeof a[0] / sizeof a[0][0]; 

  printf("sizeof(*p) == %d\n", sizeof *p);

  for ( i=0; i<nrows; ++i ) {
    for ( j=0; j<ncols; ++j )
      printf("%d ", p[i][j]);
    putchar('\n');
  }

  return 0;
}
