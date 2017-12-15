/*****************************************************************************
 *     Name: sinsert.c
 *
 *  Summary: Insert a character at a specific point in a given string.
 *
 *   Adapted: Thu 01 Aug 2002 13:13:47 (Bob Heckel James P. Williams usenet
 *                                      1996 posting)
 *****************************************************************************
*/
#include <stdio.h>
#include <assert.h>   /* assert macro */
#include <string.h>   /* strlen */

/* Inserts the characters in the null-terminated string starting at "from"
 * into that starting at "to".  Characters in "to" that follow the insertion
 * position, "where", are shifted first to make room.  On output, the first
 * character of "from" will have been copied to the character at "to[where]".
 * Thus, the following call,
 *
 *    char to[20]="abcdef";
 *
 *    sinsert(to,"1234",3);
 *
 * causes "to" to become "abc1234def".  "to" must be large enough to contain
 * the inserted string, and "where" must lie within the bounds of "to" on
 * input, i.e., from 0 to strlen(to), inclusive.  Results are undefined if
 * "to" and "from" overlap.
 */
char * sinsert(char *to, const char *from, int where) {
  int i, lt=strlen(to), lf=strlen(from);

  assert(where >= 0 && where <= lt);   /* within bounds of "to" */

  if ( lf != 0 ) {
    /* Shift characters out of the way to make room for inserted string.  Note
     * that first iteration copies null character to its new location.
     */
     for ( i=lt; i>=where; i-- )
       to[i+lf] = to[i];

    /* Copy inserted string into "hole" just made. */
     for ( i=0; i<lf; i++ )
       to[where+i] = from[i];
  }

  return to;
}


int main(void) {
  char origstr[] = "feynman";
  ///char *origstr = "feynman";    // don't even think about it
  int position = 3;  // zero-based
  
  sinsert(origstr, "XZ", position);

  printf("Converted to: %s\n", origstr);

  return 0;
}
