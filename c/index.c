/*****************************************************************************
 *     Name: index.c
 *
 *  Summary: Sort indirectly via an index.  Access data in a certain order
 *           without actually disturbing its contents.  This is especially
 *           important if you need multiple orderings repeatedly in the same
 *           program, you don't want to have to sort more than once for each
 *           ordering. 
 *
 * Adapted: Sat 06 Jul 2002 13:14:28 (Bob Heckel -- Code Capsules Chuck
 *                                    Allison 199300f2.htm)
 *****************************************************************************
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define NELEMS 4

static int comp(const void *, const void *);
// Unfortunately must be global because the compare function needs access to
// it. 
static int some_ints[NELEMS] = { 40, 12, 37, 15 };


int main(void) {
  size_t i;
  size_t idx[NELEMS] = { 0, 1, 2, 3 };

  qsort(idx, NELEMS, sizeof idx[0], comp);

  printf("Sorted array:\n");
  for ( i=0; i<NELEMS; ++i )
    printf("%d\n", some_ints[idx[i]]);

  printf("\nOriginal array:\n");
  for ( i=0; i<NELEMS; ++i )
    printf("%d\n", some_ints[i]);

  return 0;
}


static int comp(const void *pl, const void *p2) {
  size_t i = *(size_t *) pl;
  size_t j = *(size_t *) p2;

  return some_ints[i] - some_ints[j];
}
