/*****************************************************************************
 *     Name: ptr_arithmetic.c
 *
 *  Summary: Pointer arithmetic.  It only applies when you're INSIDE AN 
 *           ARRAY.  Adding a number to a ptr advances it that many elements.
 *           I.e. a + i == &a[i]
 *
 *  Adapted: Sat 30 Mar 2002 18:51:40 (Bob Heckel -- Code Capsules Chuck
 *                                     Allison)
 *****************************************************************************
*/
#include <stdio.h>
#include <stddef.h> // for ptrdiff_t

int main(void) {
  ///float a[] = {1.0, 2.0, 3.0}, *p = &a[0];
  float a[] = {1.0, 2.0, 3.0}, *p = a;  // same
  ptrdiff_t diff;  // a signed int (usually) which holds result of subtraction

  printf("sizeof(float) == %u\n", sizeof(float));  // probably 4

  printf("p == %p, *p == %f\n", p, *p);
  p += 2;
  printf("p == %p, *p == %f\n", p, *p);  // address s/b advanced 4 * 2 bytes
  
  diff = p - a;     // a == &a[0]
  printf("diff == %d\n", diff);  // s/b 2

  diff = (char*)p - (char*)a;    // not floats anymore
  printf("diff == %d\n", diff);  // s/b 8

  return 0;
}
