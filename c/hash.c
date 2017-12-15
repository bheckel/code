/*****************************************************************************
 *     Name: hash.c
 *
 *  Summary: Simulate a Perl hash in C by using two dimensional array of
 *           pointers.
 *
 *  Created: Sat 23 Feb 2002 11:37:24 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>

int main(int argc, char *argv[]) {
  char *keywords[][2] = {
    // key    value
    "for",    "for ( initialization; condition; increment )",
    "if",     "if ( condition ) ... else ...",
    "switch", "switch ( value ) { case-list }",
    "while",  "while ( condition ) ...",
    // Terminate the list with nulls.
    "",       ""
  };

  // print $keywords{'if'};
  printf("%s\n", keywords[1][1]);

  return 0;
}
