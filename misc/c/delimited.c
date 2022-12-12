/*****************************************************************************
 *     Name: delimited.c
 *
 *  Summary: Parse a '@' delimited line of user input.
 *           This even supports whitespace in the string.
 *           gets() is usually preferable to scanf().
 *
 *  Adapted: Sat 23 Mar 2002 18:58:42 (Bob Heckel -- C++ in Plain English, 
 *                                     Brian Overland)
 *****************************************************************************
*/
#include <stdio.h>

char str[81];
// Each parsed string is read into a different row of the two-dimensional
// array.
char sarray[50][81];

int main(int argc, char *argv[]) {
  int i   = 0;
  char *p = str;
  char *s;

  gets(str);

  while ( *p != '\0' ) {
    // Set s equal to the next string in array.
    s = sarray[i++];
    // Read characters into string, up to next '@'.
    while ( *p != '\0' && *p != '@' ) {
      *s++ = *p++;
    }
    // Stop reading.  Terminate string and advance pointer past the '@'.
    *s = '\0';
    p++;
  }

  // TODO zero-length input foo@@bar fails to display.
  // Print contents of all strings read in.
  i = 0;
  s = sarray[0];

  while ( *s != '\0' ) {
    s = sarray[i++];
    puts(s);
  }

  return 0;
}
