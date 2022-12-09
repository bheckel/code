/*****************************************************************************
 *     Name: bitfiddle2.c
 *
 *  Summary: Test to see if a bit is set by using bitwise AND.
 *
 *  Adapted: Sun 24 Feb 2002 20:54:17 (Bob Heckel--C++ From the Ground Up 
 *                                     Herbert Shildt)
 *****************************************************************************
*/
#include <stdio.h>

// Convert a base 10 number to base 2.
void dec2bin(int dec) {
  int i;
  int j = 0;

  for ( i=128; i>0; i=i/2 ) {
    if ( dec & i ) {
      printf("1");
    } else {
      printf("0");
    }
    if ( ++j % 4 == 0 ) printf(" ");
  }
  printf("\n");
}

    
int main(void) {
  int status;

  status = 223;
  
  dec2bin(status);
  dec2bin(32);
  // 1101 1111       <---223
  // 0010 0000 AND   <---32
  // ---------
  // 0010 0000
  //
  // The number 32 translated to binary has bit 6 set.  Therefore the 'if'
  // statement can only succeed when bit 6 of 'status' is also on.
  if ( status & 32 ) {
    printf("status' bit 6 is on\n");
  } else {
    printf("status' bit 6 is off\n");
  }

  printf("status is still %d\n", status);
  // Turn on bit 6.
  status = (status | 32);
  printf("Now status is %d\n", status);

  return 0;
}
