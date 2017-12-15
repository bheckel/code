#include <stdio.h>

// Accepts 2 pointers.  Doesn't allow *source to be touched.
char *my_strcpy(char *destination, const char *source) {
  // This is extremely confusing.  It is not saying "value at address p" but
  // rather declaring p as a pointer type and initializing it.
  ////char *p = destination;
  char *p;
  p = destination;

  ////while ( *source != '\0' ) {
  while ( *source ) {
    // Precedence forces this to mean "return the value pointed to by p and
    // then increment the _pointer_ value"
    *p++ = *source++;
    // Precedence forces this to mean "increment that value that the pointer
    // points to"
    ///(*p)++  
  }
  *p = '\0';

  return destination;
}   

int main(void) {
  char strA[80] = "A string to be used for demonstration purposes";
  char strB[80];

  my_strcpy(strB, strA);
  puts(strB);
}    
