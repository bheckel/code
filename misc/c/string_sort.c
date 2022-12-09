/*****************************************************************************
 *     Name: string_sort.c
 *
 *  Summary: Demo of sorting strings with qsort().  Also see int_sort.c
 *
 * Adapted: Sat 29 Jun 2002 21:56:51 (Bob Heckel -- Code Capsules Chuck
 *                                    Allison)
 *****************************************************************************
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define NELEMS 4

static int scomp(const void *, const void *);


int main(void) {
  size_t i;
  // An array of pointers to char.
  char *some_strings[NELEMS] = {"who", "would", "fartles", "bear"};
  
  // Since some_strings[] is an array of char *, qsort passes pointers 
  // to char * (i.e., char **) to the compare function scomp().
  //
  // Don't overlook the fact that it is the pointers that qsort reorders, and
  // not the strings themselves.
  qsort(some_strings, NELEMS, sizeof some_strings[0], scomp);
  
  for ( i=0; i<NELEMS; ++i )
    puts(some_strings[i]);

  return 0;
}


static int scomp(const void *p1, const void *p2) {
  // Do typecast then dereference once and pass the pointers to char to
  // strcmp.
  char *a = *(char **)p1;
  char *b = *(char **)p2;

  
  ///return -strcmp(a, b);   /* negate for descending order */
  return strcmp(a, b);
}
