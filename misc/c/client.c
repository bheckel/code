#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <stdio.h>

#define NSTRS   3             /* no. of strings  */
#define ADDRESS "the_socket"  /* addr to connect */

/* Strings we send to the server. */
char *strs[NSTRS] = {
  "This is the first string sent from the client.\n",
  "This is the second string sent from the client.\n",
  "This is the third string sent from the client.\n"
};


int main(void) {
  char c;
  FILE *fp;
  register int i, s, len;
  struct sockaddr_un saun;

  /* Get a socket to work with.  This socket will be in the UNIX domain, and
   * will be a stream socket.
   */
  if ( (s = socket(AF_UNIX, SOCK_STREAM, 0)) < 0 ) {
    perror("client: socket");
    exit(__LINE__);
  }

  /* Create the address we will be connecting to. */
  saun.sun_family = AF_UNIX;
  strcpy(saun.sun_path, ADDRESS);

  /* Try to connect to the address.  For this to succeed, the server must
   * already have bound this address, and must have issued a listen() request.
   *
   * The third argument indicates the "length" of the structure, not just the
   * length of the socket name.
   */
  len = sizeof(saun.sun_family) + strlen(saun.sun_path);

  if ( connect(s, &saun, len) < 0 ) {
    perror("client: connect");
    exit(__LINE__);
  }

  /* We'll use stdio for reading the socket. */
  fp = fdopen(s, "r");

  /* First we read some strings from the server and print them out. */
  for ( i = 0; i < NSTRS; i++ ) {
    while ( (c = fgetc(fp)) != EOF ) {
      putchar(c);
      if ( c == '\n' )
        break;
    }
  }

  /* Now we send some strings to the server. */
  for ( i = 0; i < NSTRS; i++ ) {
    send(s, strs[i], strlen(strs[i]), 0);
    sleep(2);
  }

  /* We can simply use close() to terminate the connection, since we're done
   * with both sides. 
   */
  puts("client closing...\n");
  close(s);

  exit(0);
}

