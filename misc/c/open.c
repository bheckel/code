/*****************************************************************************
 *     Name: open.c
 *
 *  Summary: Read a file from hard drive.  Poor man's cat.
 *
 *  Adapted: Fri, 31 Dec 1999 13:47:57 (Bob Heckel)
 * Modified: Tue 08 Oct 2002 14:39:12 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>

#define STDOUT 1


int main(void) {
  FILE *fp;
  char letter;
  char line[80];
  char fname[] = "junk.txt";
  int n;
  char buf[1024];
  int descriptor;

  if ( (fp = fopen(fname, "r")) == NULL ) {
    perror(fname);
    exit(__LINE__);
  }

  /* Work is done one character at a time. */
  while ( (letter = fgetc(fp)) != EOF ) {
    printf("%c", letter);
  }

  ///fclose(fp);

  printf("\nNext demo\n");

  /* Open the same file again. */

  ///  if ( (fp = fopen(fname, "r")) == NULL ) {
  ///    perror(fname);
  ///    exit(__LINE__);
  ///  }

  ///fseek(fp, 0L, 0);
  rewind(fp);

  /* Work is done one line at a time. */
  while ( fgets(line, BUFSIZ, fp ) != NULL ) {
    printf("%s", line);
  }

  fclose(fp);


  /* Now use low-level access to files. */
  /* STDERR               str length */
  write(2, "I'm using STDERR\n", 17);

  puts("\nLow-level demo:");

  if ( (descriptor = open(fname, O_RDONLY)) < 0 ) {
    perror(fname);
    exit(__LINE__);
  }
   
  while ( (n=read(descriptor, buf, sizeof(buf))) > 0 ) 
    ///write(1, buf, n);
    write(STDOUT, buf, n);

  return 0;
}
