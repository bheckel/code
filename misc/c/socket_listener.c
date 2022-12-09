/*****************************************************************************
 *     Name: socket_listener.c -- a datagram sockets "server" demo
 *
 *  Summary: listener sits on a machine waiting for an incoming packet on
 *           port 4950.  talker sends a packet to that port, on the
 *           specified machine, that contains whatever the user enters on
 *           the command line.
 *
 *           No listen() or accept() required since we're using unconnected
 *           datagram sockets.
 *
 *           netstat will not show any activity for this type of connection.
 *
 *           !! Run before starting socket_talker.exe (in separate xterm) !!
 *
 *  Adapted: Mon 15 Oct 2001 16:17:01 (Bob Heckel -- Beej's Network Sockets)
 *****************************************************************************
*/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define MYPORT 4950    // the port users will be connecting to
#define MAXBUFLEN 80

int main(void) {
  int sockfd;
  struct sockaddr_in my_addr;    // my address information
  struct sockaddr_in their_addr; // connector's address information
  int addr_len, numbytes;
  char buf[MAXBUFLEN];

  // The socket may seem very primitive is its design. However, it hooks right
  // into the file I/O subsystem, making it a very powerful primitive. 
  //
  // Because sockets hang off of the file I/O subsystem, you can use the
  // standard read()/write() system calls or use specialized recv()/send()
  // system calls. 
  //                    domain,   network  protocol
  if ( (sockfd = socket(AF_INET, SOCK_DGRAM, 0) ) == -1 ){
    // Can't create connection point.
    perror("socket file descriptor creation error");
    exit(1);
  }

  my_addr.sin_family = AF_INET;         // host byte order
  my_addr.sin_port = htons(MYPORT);     // short, network byte order
  my_addr.sin_addr.s_addr = INADDR_ANY; // automatically fill with my IP
  memset(&(my_addr.sin_zero), '\0', 8); // zero the rest of the struct

  if ( bind(sockfd, (struct sockaddr *)&my_addr,
      sizeof(struct sockaddr)) == -1 ) {
    perror("bind");
    exit(1);
  }

  addr_len = sizeof(struct sockaddr);

  /* recvfrom() "blocks" (sleeps) until data arrives.  Using non-blocking
   * approach sucks up CPU cycles.
   */
  if ( (numbytes = recvfrom(sockfd, buf, MAXBUFLEN-1 , 0,
      (struct sockaddr *)&their_addr, &addr_len)) == -1 ) {
    perror("recvfrom");
    exit(1);
  }

  printf("Got packet from %s\n", inet_ntoa(their_addr.sin_addr));
  printf("Packet is %d bytes long\n", numbytes);
  buf[numbytes] = '\0';
  printf("Packet contains \"%s\"\n", buf);

  close(sockfd);

  return 0;
}
