/*****************************************************************************
 *     Name: cgrep.c
 *
 *  Summary: grep (case insensitive) from redirected file.
 *
 *  Adapted: Fri 05 Apr 2002 12:40:19 (Bob Heckel -- Code Capsules Chuck
 *                                     Allison)
 *****************************************************************************
*/
#include <stdio.h>
#include <string.h>  // for strlwr(), strstr()
#include <ctype.h>   // for tolower()

#define WIDTH 128

char *strlwr(char *s);  // use my version instead


int main(int argc, char *argv[]) {
  char line[WIDTH], lline[WIDTH];
  char *search_str;

  if ( argc == 1 ) {
    puts("search string required");
    puts("Usage: cgrep mysearchword < foo.txt");

    return 1;
  }

  search_str = argv[1];
  // Sometimes provided by compiler but we're using my version.
  strlwr(search_str);  

  while ( gets(line) ) {
    strlwr(strcpy(lline, line));
    if ( strstr(lline, search_str) )
      puts(line);
  }

  return 0;
}


char *strlwr(char *s) {
  puts("not found on this line");
  if ( s != NULL ) {
    char *p;

    for ( p = s; *p; ++p )
      *p = tolower(*p);
  }

  return s;
}
