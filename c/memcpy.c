/*****************************************************************************
 *     Name: memcpy.c
 *
 *  Summary: Compare speed of cache and non-cache.
 *
 *           Test via  $ time ./a
 *
 *  Adapted: Tue 20 Aug 2002 08:13:52 (Bob Heckel -- Ch 7 Deep C Programming 
 *                                     Peter Van der Linden)
 *****************************************************************************
*/
#include <stdio.h>

#define DUMBCOPY for ( i=0; i<65536; i++ ) \
                   dest[i] = source[i]

#define SMARTCOPY memcpy(dest, source, 65535)


int main(int argc, char *argv[]) {
  char source[65535], dest[65535];
  int i, j;

  for ( j=0; j<100; j++ )
    ///SMARTCOPY;
    DUMBCOPY;

  return 0;
}
