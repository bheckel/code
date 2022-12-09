/* Loosely based on InformIT's C in 21 Days.
 *
 * Adapted: Wed May 19 11:31:28 2004 (Bob Heckel --  Linux Programming by
 *                                    Example Arnold Robbins)
 */

/* Geoff Collyer instead recommends the following technique for allocating
 * memory: 
 *
 * some_type *pointer;
 * pointer = malloc(count * sizeof(*pointer));
 * 
 * This approach guarantees that the malloc() will allocate the correct amount
 * of memory without your having to consult the declaration of pointer. If
 * pointer's type later changes, the sizeof operator automatically ensures
 * that the count of bytes to allocate stays correct. (Geoff's technique omits
 * the cast that we just discussed. Having the cast there also ensures a
 * diagnostic if pointer's type changes and the call to malloc() isn't
 * updated).
 */
#include <stdlib.h>
#include <string.h>   /* for strcpy */
#include <stdio.h>

#define BYTES 80

int main(void) {
  char *str;   // wait until runtime to define
  char *fullstr = "placeholder";
  int *numbers, *blanks;

  // Allocate a contiguous block of memory for a 80-character string or
  // you'll get a core dump.
  if ( ( str = (char *)malloc(BYTES)) == NULL ) {
    printf( "Not enough memory to allocate buffer.\n");
    exit(1);
  } else {
    printf("String was allocated!\n");
    /* The pointer is initialized to garbage, so clear it to be safe: */
    memset(str, '\0', BYTES);  /* use calloc to avoid this hassle */
  }

  // Now fill the allocated space.
  strcpy(str, fullstr);
  printf("%s\n", str);

  free(str);
  str = NULL;  /* not mandatory but a good idea */

  // Had we used  char dest[80];  we would not need malloc b/c it has room for
  // 80 char, so, assuming  char source[] = "foo" has been setup previously,
  // something like this:  strcpy(dest, source);  would work.
  //
  // Had the destination been set up like this:  char *dest;  you would have
  // needed to do:  dest = (char *)malloc(strlen(source)+1)  first, then do a
  // strcpy(dest, source);

  // Allocate memory for an array of 50 integers.  Unused.
  numbers = (int *)malloc(50 * sizeof(int));
  free(numbers);

  // Allocate memory for an array of 5 integers and zero-fill it.  Unused.
  blanks = (int *)calloc(5, sizeof(int));

  return 0;
}
