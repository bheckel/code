/*****************************************************************************
 *     Name: strip_chars.c
 *
 *  Summary: Remove all occurrences of s2 from s1.
 *
 *  Adapted: Wed 07 Aug 2002 15:00:33 (Bob Heckel -- Al Bower's usenet post
 *                                     2000)
 *****************************************************************************
*/
#include <stdio.h>
#include <string.h>

char *strip_chars(char *s1, const char *s2) {
  char *s;
  
  for ( ; *s2; s2++ ) {
   s = s1;
   while ( (s = strchr(s,*s2)) != NULL )
      strcpy(s, s+1);
  }

  return s1;     
}



int main(void){
  char eml[]="Software@somewhere.mesh";
  char *ret;

  ret = strip_chars(eml, ".");

  printf("%s", ret);

  return 0;
}

