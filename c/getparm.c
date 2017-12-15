/*****************************************************************************
 *     Name: getparm.c
 *
 *  Summary: Extract one substring from a delimited string, src, starting at
 *           start position.
 *
 *  Created: Tue 06 Aug 2002 13:59:15 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>
#include <string.h>

char * getparm(char *src, int start, char *delim) {
  src = src + start;             // move to desired start in string

  return strtok(src, delim);     // only pass variable on 1st call
}


int main(void) {
  char s[] = "one,two,3,four"; 
  int startpos = 5;

  printf("%s", getparm(s, startpos, ","));

  return 0;
}
