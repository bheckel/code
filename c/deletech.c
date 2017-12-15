/*****************************************************************************
 *     Name: deletech.c
 *
 *  Summary: Delete specific number of characters from specific position in a
 *           string.
 *
 *  Created: Thu 01 Aug 2002 14:39:44 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>

///char * delete(char *str, int startch, int size, int ndel) {
char * delete(char *str, int startch, int ndel) {
  int i = 0;
  int ctr = 0;
  char *tmp;

  tmp = str;  // determine sizeof str

  while ( *tmp++ )
    ctr++;
  ///printf("DEBUG: %d\n", ctr);
  
  ///for ( i=startch; i<size; i++ )
  for ( i=startch; i<ctr; i++ )
    str[i] = str[i+ndel];

  return str;
}


int main(void) {
  char s[80] = "teSTYspring";
  ///size_t size = sizeof s;
  int startch = 2;
  int ndel = 3;

  // s is directly modified.
  printf("before: %s\n", s);
  ///delete(s, startch, size, ndel);
  delete(s, startch, ndel);
  printf("after: %s\n", s);

  return 0;
}
