/*****************************************************************************
 *     Name: getline.c
 *
 *  Summary: Demo of getting lines of stdin.  See fgline.c for getting lines
 *           from a file.
 *
 *  Adapted: Thu, 11 Jan 2001 15:28:17 (Bob Heckel -- Steve Summit)
 * Modified: Sun 04 Aug 2002 10:46:58 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>

/* Read one line from standard input.
 * Does not return terminating \n in line.
 * Returns line length: 0 for empty line, EOF for end-of-file.
 *
 * Sample usage: while ( getline(line, MAXLINE ) != EOF ) { ... }
 * Get similar behavior from: while ( fgets(line, MAXLINE, stdin) ) { ... }
 */
int mygetline(char line[], int max) {
  int nch = 0;
  int c;

  max = max - 1;			/* leave room for '\0' */

  while ( (c = getchar()) != EOF ) {
    if ( c == '\n' )
      break;

    if ( nch < max ) {
      line[nch] = c;
      nch = nch + 1;
    }
  }

  if ( c == EOF && nch == 0 )
    return EOF;

  line[nch] = '\0';

  return nch;
}


int main(void) {
  char line[80];

  puts("Ctrl-c to exit.");

  while ( mygetline(line, 80) != EOF ) {
    fprintf(stderr,"ok xx%syy\n", line);
  }

  return 0;
}
