/*****************************************************************************
 *     Name: lseek.c
 *
 *  Summary: Demo of moving around in a file (low-level).  There is no
 *           low-level rewind().
 *
 *  Adapted: Wed 09 Oct 2002 10:10:17 (Bob Heckel  -- Using C on the Unix
 *                                     System)
 *****************************************************************************
*/
#include <stdio.h>    // for sprintf(), perror()
#include <stdlib.h>   // for getenv()
#include <unistd.h>   // for write(), read(), close(), lseek()
#include <fcntl.h>    // for open()
///#include <sys/file.h> // for L_XTND

#define STDIN  0
#define STDOUT 1
#define STDERR 2

int main(int argc, char *argv[]) {
  int n;
  char buf[1024];
  char the_file[256];
  int descriptor;

  sprintf(the_file, "%s/%s", getenv("HOME"), "tmp/testing/junk.txt");
  
  /* Use low-level access to files. */
  /* STDERR                             str length */
  write(2, "I'm using low-level file access\n", 32);

  /* Open. */
  if ( (descriptor = open(the_file, O_RDONLY)) < 0 ) {
    perror(the_file);
    exit(__LINE__);
  }
   
  /* Read. */
  while ( (n=read(descriptor, buf, sizeof(buf))) > 0 ) 
    ///write(1, buf, n);
    write(STDOUT, buf, n);

  /* Move around. */
  write(2, "\nNow move around\n", 18);

  ///lseek(descriptor, 0L, L_XTND);
  lseek(descriptor, 2L, SEEK_SET);

  /* Read again. */
  while ( (n=read(descriptor, buf, sizeof(buf))) > 0 ) 
    ///write(1, buf, n);
    write(STDOUT, buf, n);

  close(descriptor);

  return 0;
}
