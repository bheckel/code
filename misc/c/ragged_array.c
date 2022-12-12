/*****************************************************************************
 *     Name:  ragged_array.c
 *
 *  Summary:  Use malloc to create an array of differing lengths.  This will
 *            almost always be arrays of strings.  Then print the strings in
 *            the reverse order that they were input.
 *
 *  Adapted: Sat 30 Mar 2002 17:04:30 (Bob Heckel -- Thinking In C CDROM)
 *****************************************************************************
*/
#include <stdio.h>
#include <stdlib.h>  // heap functions
#include <string.h>

// Max lines in array.
#define MAXLINES 100
// Include the terminating null '\0'
#define MAXWIDTH 81

int main(void) {
  char *lines[MAXLINES];   // array of pointers to char
  char linebuf[MAXWIDTH];  // buffer to read in lines one at a time
  int i, n;

  puts("EOF (usually Ctrl-d) to finish data input.");

  // Store in a ragged array by reading a line at a time, if there's room).
  //                    gets() throws away newline
  for ( n=0; n<MAXLINES && gets(linebuf)!=NULL; n++ ) {
    // Ask malloc() for enough space to store the line just read in.
    //    pointer                         '\0'
    if ( (lines[n] = malloc(strlen(linebuf)+1)) == NULL )
      exit(EXIT_FAILURE);

    // Copy linebuf into the area on the heap.
    //     pointer   pointer
    strcpy(lines[n], linebuf);
  }

  for ( i=0; i<n; ++i ) {
    puts(lines[n-i-1]);
    free(lines[n-i-1]);
  }

  return 0;
}
