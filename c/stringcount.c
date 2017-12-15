#include <stdio.h>
#include <string.h>

// Adapted: Mon 06 Aug 2001 15:18:22 (Bob Heckel)

// Count the length of a string. From eskimo sect 10.5
int main(void) {
  char stringy[100] = "a string";  // length is 8
  int len;
  char *p;

  // Whenever you mention the name of an array in a context where the
  // `value' of the array would be needed, C automatically generates a
  // pointer to the first element of the array, as if you had written
  // &array[0].  So...
  //
  ///for ( p = stringy; *p != '\0'; p++ );
  //       &string[0]
  for ( p = stringy; *p != '\0'; p++ )
    printf("Contents (address) held in p: %x\n", p);

  printf("Address of stringy: %x\n", &stringy);

  // Now we've moved to the end of p (e.g. address 0x240fd1c)
  // Since stringy 's address is at the start of the string (e.g. address
  // 0x240fd14), you can subtract from p to get length.
  // 0x240fd1c - 0x240fd14 is 8

  //       &string[0]
  len = p - stringy;

  printf("here %i", len);

  return(0);
}
