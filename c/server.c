#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <stdio.h>

#define NSTRS   3             /* no. of strings  */
#define ADDRESS "the_socket"  /* addr to connect */

/* Strings we send to the client. */
char *strs[NSTRS] = {
  "This is the first string sent from the server.\n",
  "This is the second string sent from the server.\n",
  "This is the third string sent from the server.\n"
};

int main(void) {
  char c;
  FILE *fp;
  int fromlen;
  register int i, s, ns, len;
  struct sockaddr_un saun, fsaun;

  /* Get a socket to work with.  This socket will be in the UNIX domain, and
   * will be a stream socket.  This newly created socket (a.k.a. stream) will
   * require the use of listen() and accept() in a receiver, and connect() in
   * a sender.
   */
  if ( (s = socket(AF_UNIX, SOCK_STREAM, 0)) < 0 ) {
    perror("server: socket");
    exit(__LINE__);
  }

  /* Create the address we will be binding to. */
  saun.sun_family = AF_UNIX;
  strcpy(saun.sun_path, ADDRESS);

  /* Try to bind the address to the socket.  We unlink the name first so that
   * the bind won't fail.
   *
   * The third argument indicates the "length" of the structure, not just the
   * length of the socket name.
   */
  unlink(ADDRESS);
  len = sizeof(saun.sun_family) + strlen(saun.sun_path);

  if ( bind(s, &saun, len) < 0 ) {
    perror("server: bind");
    exit(__LINE__);
  }

  /* Listen on the socket. */
  if ( listen(s, 5) < 0 ) {
    perror("server: listen");
    exit(__LINE__);
  }

  /* Accept connections.  When we accept one, ns will be connected to the
   * client.  fsaun will contain the address of the client.
   */
  if ( (ns = accept(s, &fsaun, &fromlen)) < 0 ) {
    perror("server: accept");
    exit(__LINE__);
  }

  /* We'll use stdio for reading the socket. */
  fp = fdopen(ns, "r");

  /* First we send some strings to the client. */
  for ( i = 0; i < NSTRS; i++ ) {
    send(ns, strs[i], strlen(strs[i]), 0);
    sleep(3);
  }

  /* Then we read some strings from the client and print them out. */
  for ( i = 0; i < NSTRS; i++ ) {
    while ( (c = fgetc(fp)) != EOF ) {
      putchar(c);
      if ( c == '\n' )
        break;
    }
  }

  /* We can simply use close() to terminate the connection, since we're done
   * with both sides.
   */
  puts("server closing...\n");
  close(s);

  exit(0);
}
