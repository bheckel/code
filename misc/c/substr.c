/*****************************************************************************
 *     Name: substr.c
 *
 *  Summary: Substring demo.  Pass two arrays.
 *
 *  Created: Wed 31 Jul 2002 15:18:05 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>

// Return the substring in a user-supplied empty array , given starting point
// and length.
int substr(char dest[], char src[], int offset, int len) {
  int i;

  for ( i=0; i<len && src[offset+i]!='\0'; i++ )
    dest[i] = src[i+offset];

  dest[i] = '\0';

  return sizeof dest;
}


int main(void) {
  char oldstr[] = "foobar ";
  char newstr[80];
  int nextract;

  nextract = substr(newstr, oldstr, 2, 3);
  //                                                      don't count the \0
  printf("Start at 2, go for 3: %s.  Tot chars: %d\n", newstr, nextract-1);

  if ( nextract > 0 )
    return 0;
  else
    return nextract-1;
}
