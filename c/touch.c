/*****************************************************************************
 *     Name: 
 *
 *  Summary: Determine if file1 is newer than file 2.
 *
 *           If you need to update the time/date stamp of a file to the
 *           current time, simply overwrite the first byte of a file with
 *           itself. Although the contents haven't changed, your file system
 *           will think it has, and will update the time/date stamp
 *           accordingly. 
 *            
 *  Adapted: Sun 05 May 2002 10:19:37 (Bob Heckel -- Code Capsules Chuck
 *                                     Allison)
 *****************************************************************************
*/
#include <stdio.h>

void mytouch(char *fname) {
   FILE *f = fopen(fname,"r+b");

   if ( f != NULL ) {
     char c = getc(f);
     rewind(f);
     putc(c,f);
   } else {
     fopen(fname,"wb");
   }

   fclose(f);
}


int main(void) {
  mytouch("junk");
  
  return 0;
}
