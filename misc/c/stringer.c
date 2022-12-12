#include <stdio.h>

// Print out strings in table text one character at a time.
// Adapted: Sat, 12 Aug 2000 15:01:12 (Bob Heckel--from "Teach Yourself C 2nd
//                                     Edition)

char text[][80] = {"when", "in", "the", "course", "of", "human"};

int main() {
  int i, j;

  for ( i=0; text[i][0]; i++ ) {
    for ( j=0; text[i][j]; j++ ) {
      printf("%c_", text[i][j]);
    }
    printf("X");
  }
  return 0;
}
