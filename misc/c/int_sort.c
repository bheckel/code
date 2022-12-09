/*****************************************************************************
 *     Name: int_sort.c
 *
 *  Summary: Demo of sorting integers with qsort().  Also see string_sort.c
 *
 * Adapted: Sat 29 Jun 2002 21:56:51 (Bob Heckel -- Code Capsules Chuck
 *                                    Allison)
 *****************************************************************************
*/
#include <stdio.h>
#include <stdlib.h>   // for qsort()

#define NELEMS 4

// A compare function to be passed to qsort must have this prototype: A
// int f(const void *p1, const void *p2).
static int icomp(const void *, const void *);


int main(void) {
  size_t i;
  int int_array[NELEMS] = {40, 12, 37, 15};
 
  qsort(int_array, NELEMS, sizeof int_array[0], icomp);
 
  for ( i = 0; i < NELEMS; ++i )
     printf("%d\n", int_array[i]);
 
  return 0;
}


// Called repeated by qsort(), each time receiving two pointers to two array
// elements.  Behaves like strcmp, i.e., it must return a negative number if
// the value that p1 represents precedes that of p2, 0 if the values are
// equal, and a positive number otherwise. 
static int icomp(const void *p1, const void *p2) {
  // The incoming pointers must be cast to the appropriate type (int * in this
  // case) in order to reference the values to compare.
  int a = *(int *)p1;
  int b = *(int *)p2;

  return a - b;
}

