#include <stdio.h>
#include <string.h>

// Adapted: Sat, 12 Aug 2000 15:01:12 (Bob Heckel--from "Teach Yourself C 2nd
//                                     Edition)

int main() {
  ////int stats[], i, j;
  char str[80];

  gets(str);
  while ( strcmp(str, "quit") ) {
    printf("%s\n", str);
    gets(str);
  }

  return 0;
}
