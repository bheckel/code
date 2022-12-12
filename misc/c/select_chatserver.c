/*****************************************************************************
 *     Name: select_chatserver.c
 *
 *  Summary: A cheezy multiperson chat server.
 *
 *           $ telnet hostname 9034  <---on two other xterms to run
 *
 *  Adapted: Tue 16 Oct 2001 08:51:00 (Bob Heckel -- Beej's Network Sockets)
 *****************************************************************************
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define PORT 9034   // port we're listening on


int main(void) {
  // master holds all the socket descriptors that are currently connected, as
  // well as the socket descriptor that is listening for new connections.
  // The reason I have the master set is that select() actually changes the
  // set you pass into it to reflect which sockets are ready to read. Since I
  // have to keep track of the connections from one call of select() to the
  // next, I must store these safely away somewhere. At the last minute, I
  // copy the master into the read_fds, and then call select().
  fd_set master;    // master file descriptor list
  fd_set read_fds;  // temp file descriptor list for select()
  struct sockaddr_in myaddr;     // server address
  struct sockaddr_in remoteaddr; // client address
  int fdmax;        // maximum file descriptor number
  int listener;     // listening socket descriptor
  int newfd;        // newly accept()ed socket descriptor
  char buf[256];    // buffer for client data
  int nbytes;
  int yes=1;        // for setsockopt() SO_REUSEADDR, below
  int addrlen;
  int i, j;

  FD_ZERO(&master);    // clear the master and temp sets
  FD_ZERO(&read_fds);

  // Get the listener.
  if ( (listener = socket(AF_INET, SOCK_STREAM, 0)) == -1 ) {
    perror("socket");
    exit(1);
  }

  // Lose the pesky "address already in use" error message.
  if ( setsockopt(listener, SOL_SOCKET, SO_REUSEADDR, &yes,
                                                      sizeof(int)) == -1 ) {
    perror("setsockopt");
    exit(1);
  }

  // Bind.
  myaddr.sin_family      = AF_INET;
  myaddr.sin_addr.s_addr = INADDR_ANY;
  myaddr.sin_port        = htons(PORT);
  memset(&(myaddr.sin_zero), '\0', 8);
  if ( bind(listener, (struct sockaddr *)&myaddr, sizeof(myaddr)) == -1 ) {
    perror("bind");
    exit(1);
  }

  // Listen.
  if ( listen(listener, 10) == -1 ) {
    perror("listen");
    exit(1);
  }

  // Add the listener to the master set.
  FD_SET(listener, &master);

  // Keep track of the biggest file descriptor.
  fdmax = listener; // so far, it's this one

  // Main loop.
  for ( ;; ) {
    read_fds = master; // copy it
    if ( select(fdmax+1, &read_fds, NULL, NULL, NULL) == -1 ) {
      perror("select");
      exit(1);
    }

    // Run through the existing connections looking for data to read.
    for ( i=0; i<=fdmax; i++ ) {
      if ( FD_ISSET(i, &read_fds) ) { // we got one!!
        if (i == listener) {
          // Handle new connections.
          addrlen = sizeof(remoteaddr);
          if ( (newfd = accept(listener, (struct sockaddr *)&remoteaddr,
                                                   &addrlen)) == -1 ) { 
            perror("accept");
          } else {
            FD_SET(newfd, &master); // add to master set
            if (newfd > fdmax) {    // keep track of the maximum
              fdmax = newfd;
            }
            printf("selectserver: new connection from %s on "
                   "socket %d\n", inet_ntoa(remoteaddr.sin_addr), newfd);
          }
        } else {
          // Handle data from a client.
          if ( (nbytes = recv(i, buf, sizeof(buf), 0)) <= 0 ) {
            // Got error or connection closed by client.
            if (nbytes == 0) {
                // connection closed
              printf("selectserver: socket %d hung up\n", i);
            } else {
              perror("recv");
            }
            close(i); // bye!
            FD_CLR(i, &master); // remove from master set
          } else {
            // We got some data from a client.
            // If the client recv() returns non-zero, though, I know some data
            // has been received. So I get it, and then go through the master
            // list and send that data to all the rest of the connected
            // clients.
            for ( j = 0; j <= fdmax; j++ ) {
              // Send to everyone!
              if ( FD_ISSET(j, &master) ) {
                // Except the listener and ourselves.
                if ( j != listener && j != i ) {
                  if ( send(j, buf, nbytes, 0) == -1 ) {
                    perror("send");
                  }
                }
              }
            }
          }
        } // it's SO UGLY!
      }
    }
  }
  
  return 0;
} 
