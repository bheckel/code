/*****************************************************************************
 *     Name: str2uppercase.c
 *
 *  Summary: Uppercase a string.  Alternative is to use C Library's strupr()
 *
 *  Created: Thu 01 Aug 2002 15:08:58 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>
#include <string.h>

void str2upper(char* lcstr) {
	int i;

	for ( i=0; lcstr[i] != '\0'; ++i ) {
		lcstr[i] = (char) toupper(lcstr[i]);
  }
}


int main() {
  char s[] = "so very low"; 

  str2upper(s);
  
  printf("DEBUG: %s\n", s);

  return 0;
}
