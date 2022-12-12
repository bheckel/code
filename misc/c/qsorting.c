/*****************************************************************************
 *     Name: qsorting.c
 *
 *  Summary: Demo of using qsort and void (generic) pointers.
 *
 *  Adapted: Sat 30 Mar 2002 18:51:40 (Bob Heckel -- Code Capsules Chuck
 *                                     Allison)
 * Modified: Sat 30 Aug 2003 13:42:18 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>
#include <stdlib.h>   // for qsort()
#include <string.h>

int compare(const void*, const void*);


int main(void) {
  // Ragged array of ptrs to null terminated strings.
  char* strings[] = {"how", "now", "brown", "cow"};  
  const unsigned int nstr = sizeof strings / sizeof strings[0];
  unsigned int i;
  
  // Best all-around algorithm for sorting (but arrays are held in memory).
  //    address  nelems   each element    callback
  qsort(strings, nstr, sizeof strings[0], compare);

  for ( i=0; i<nstr; ++i )
    puts(strings[i]);

  return 0;
}


//          2 void ptrs are required by qsort()
int compare(const void* p1, const void* p2) {
  char* a = *(char **) p1;
  char* b = *(char **) p2;

  ///return (a < b) ? -1 : (a > b) ? 1 : 0;
  // Better?
  // Ascending.
  return strcmp(a, b);
  // Descending.
  ///return -strcmp(a, b);
}
