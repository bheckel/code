#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>

/* Low-level I/O */
int main(void) {
  int n;             /* number of characters read by read() */
  int from, to;      /* file descriptors */
  char buf[1024];

  /* Write. */
  write(0, "stdin\n", 7);
  write(1, "stdout\n", 8);
  write(2, "stderr\n", 8);
  write(2, "emily\n", 7);

  /**************************************************************/
  /* Get file descriptor for an existing textfile. */
  if ( (from = open("/home/bheckel/junk.txt", O_RDONLY)) < 0  ) {
    perror("Can't open junk.txt");
    exit(1);
  } else {
    printf("File descriptor for junk.txt is %d\n", from);
  }

  /* Append.  Or create new 0640 file if not already existing. */
  if ( (to = open("junkvivify.txt", O_WRONLY|O_CREAT|O_APPEND, 0640)) < 0 ) {
    perror("Can't append (or create) junkvivify.txt");
    exit(1);
  } else {
    printf("File descriptor for junkvivify.txt is %d\n", to);
  }

  while ( (n = read(from, buf, sizeof(buf))) > 0 ) {
    /* Only write the number of characters read() read in, instead of always
     * writing the 1024 buffer characters.
     */
    write(to, buf, n);
  }

  close(from); close(to);

  return 0;
}
  
