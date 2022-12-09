/*****************************************************************************
 *     Name: socket_talker.c -- a datagram sockets "server" demo
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
 *           !! Run after starting socket_listener.exe (in separate xterm) !!
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
#include <netdb.h>

#define MYPORT 4950    // the port users will be connecting to

int main(int argc, char *argv[]) {
  int sockfd;
  struct sockaddr_in their_addr; // connector's address information
  struct hostent *he;
  int numbytes;

  if (argc != 3) {
    fprintf(stderr,"usage: talker hostname message\n");
    exit(1);
  }

  // Use the resolver library.  The term resolver refers not to a special
  // application, but to the resolver library. This is a collection of
  // functions that can be found in the standard C library. The central
  // routines are gethostbyname(2) and gethostbyaddr(2), which look up all IP
  // addresses associated with a host name, and vice versa. They may be
  // configured to simply look up the information in hosts, to query a number
  // of DNS name servers, or to use the hosts database of Network Information
  // Service (NIS).
  //
  // The resolver functions read configuration files when they are invoked.
  // From these configuration files, they determine what databases to query,
  // in which order, and other details relevant to how you've configured your
  // environment. The older Linux standard library, libc, used /etc/host.conf
  // as its master configuration file, but Version 2 of the GNU standard
  // library, glibc, uses /etc/nsswitch.conf. 
  if ( (he = gethostbyname(argv[1])) == NULL ) {  // get the host info
    perror("gethostbyname");
    exit(1);
  }

  if ( (sockfd = socket(AF_INET, SOCK_DGRAM, 0)) == -1 ) {
    perror("socket");
    exit(1);
  }

  their_addr.sin_family = AF_INET;           // host byte order
  their_addr.sin_port   = htons(MYPORT);     // short, network byte order
  their_addr.sin_addr   = *((struct in_addr *)he->h_addr);
  memset(&(their_addr.sin_zero), '\0', 8);   // zero the rest of the struct

  if ( (numbytes = sendto(sockfd, argv[2], strlen(argv[2]), 0,
           (struct sockaddr *)&their_addr, sizeof(struct sockaddr)) ) == -1) {
    perror("sendto");
    exit(1);
  }

  printf("sent %d bytes to %s\n", numbytes, inet_ntoa(their_addr.sin_addr));

  close(sockfd);

  return 0;
}
