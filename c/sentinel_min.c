/*****************************************************************************
 *     Name: sentinel_min.c
 *
 *  Summary: Using arrays with pointer notation.  Also returns the minimum 
 *           value in an array that contains a known number of elements.
 *
 *  Adapted: Sat 30 Mar 2002 18:51:40 (Bob Heckel -- Code Capsules Chuck
 *                                     Allison)
 *****************************************************************************
*/
#include <stdio.h>
// Or, probably better, int nums[]
int min(int* nums, int nelems) {
  // Address of 'end' is one past the end (just DON'T dereference *end).
  int* end = nums + nelems;	 
  int small = *nums;

  printf("so far, small is: %d\n", small);

  // Here sizeof doesn't know what size of original array was...
  printf("in min(): sizeof nums == %u BYTES in this context\n", sizeof nums);
  // ...so it will report 4 (usually).
  
  // ++nums advances pointer to next element of num.
  while ( ++nums < end )
    if ( *nums < small )
        small = *nums;

  return small;
}


int main(void) {
  int a[] = {56,34,89,12,9};

  printf("min(a, 5) is: %d\n", min(a, 5));	// 9
  printf("in main(): sizeof a == %u ELEMENTS in this context\n", sizeof a);

  return 0;
}
