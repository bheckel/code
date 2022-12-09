/*****************************************************************************
 *     Name: split2.c
 *
 *  Summary: Extract substrings from a delimited string.  Improves on split.c
 *           because you don't need to know how many delimiters your string
 *           should have.
 *
 *  Created: Tue 06 Aug 2002 13:59:15 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>
#include <string.h>

void split(char *src, int start, char *delim) {
  char *tmp;
  char *token;
  int i;
  int ctr = 0;  // string length

  tmp = src;
  while ( *tmp++ )
    ctr++;

  token = strtok(src, delim);     // only pass variable on 1st call
  printf("0 %s\n", token);
  for ( i=1; i<ctr; i++ ) {
    token = strtok(NULL, delim);  // then use NULL for the others
    if ( token )  // skip garbage
      printf("%d %s\n", i, token);
  }
}


int main(void) {
  char s[] = "one,two,3,four"; 
  int startpos = 0;

  split(s, startpos, ",");

  return 0;
}
