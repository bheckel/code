/*****************************************************************************
 *     Name: strcp.c
 *
 *  Summary: My version of strcpy.  Copy a string.
 *
 *  Adapted: Sat 23 Mar 2002 18:58:42 (Bob Heckel -- C++ in Plain English, 
 *                                     Brian Overland)
 *****************************************************************************
*/
#include <stdio.h>

int main(int argc, char *argv[]) {
  char src[]  = "Mulholland";                                                               
  char dest[] = "Drive";                                                               
  char *psrc  = src;
  char *pdest = dest;

  // Either works here.
  ///printf("before %s %s\n", psrc, pdest);
  printf("before %s %s\n", src, dest);

  // First two only go to Mullh (then they crash into the null).  Third does
  // the right thing.

  // Light compactness.
///  while ( *pdest != '\0' ) {
///    *pdest = *psrc;
///    pdest++; 
///    psrc++;
///  }
///  *pdest = '\0';

  // Medium compactness.
///  while ( *pdest != '\0' ) {
///    *pdest++ = *psrc++;
///  }
///  *pdest = '\0';

  // Maximum compactness.
  while ( *pdest++ = *psrc++ ) {}
  *pdest = '\0';

  // This doesn't work here.
  ///printf("after %s %s\n", psrc, pdest);
  printf("after %s %s\n", src, dest);

  return 0;
}
