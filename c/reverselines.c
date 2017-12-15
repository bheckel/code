/****************************************************************************
 * Read multiple lines from standard input then prints them (whole lines) in
 * reverse order.
 * 
 * Good demo of pointers to pointers because we want to simulate an array of
 * strings (i.e. an array of pointers to characters).  Contrast this with
 * using pointers to simulate an array of integers, which is easier.
 *
 * Adapted: Thu, 11 Jan 2001 15:28:17 (Bob Heckel -- Steve Summit)
 ****************************************************************************
 */
#include <stdio.h>
#include <stdlib.h>
#include "getline.c"

extern int getline(char [], int);

#define MAXLINE 100

int main() {
  int i;
  char line[MAXLINE];
  char **lines;
  int nalloc, nitems;

  // Bytes to allocate...
  nalloc = 10;
  // ...mult by the size of chars.
  lines = malloc(nalloc * sizeof(char *));
  if ( lines == NULL ) {
    printf("out of memory\n");
    exit(1);
  }

  nitems = 0;

  while ( getline(line, MAXLINE) != EOF ) {
    if ( nitems >= nalloc ) {
      char **newp;
      nalloc += 10;
      newp = realloc(lines, nalloc * sizeof(char *));
      if ( newp == NULL ) {
        printf("out of memory\n");
        exit(1);
      }
      lines = newp;
    }

    lines[nitems] = malloc(strlen(line) + 1);
    strcpy(lines[nitems], line);
    nitems++;
  }

  for ( i=nitems-1; i>=0; i-- )
    printf("%s\n", lines[i]);

  return 0;
}

