/*****************************************************************************
 *     Name: nslook.c (formerly whois.c)
 *
 *  Summary: Hostname lookup via DNS (domain name service) similar to whois
 *           (which is lacking in Cygwin).
 *
 *  Adapted: Fri 12 Oct 2001 15:13:36 (Bob Heckel -- Beej's Sockets)
 *****************************************************************************
*/

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <netdb.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

int main(int argc, char *argv[]) {
///  struct hostent {
///    char    *h_name;            // official name of host
///    char    **h_aliases;        // NULL-terminated array of alternate names
///    int     h_addrtype;         // usually AF_INET
///    int     h_length;           // length of address in bytes
///    char    **h_addr_list;      // 0-terminated array of addresses (in
///  };                            // Network Byte Order)
///  #define h_addr h_addr_list[0]
  struct hostent *h;

  if ( argc != 2 ) {
    fprintf(stderr,"usage: %s yahoo.com\n", argv[0]);
    exit(__LINE__);
  }

  if ( (h = gethostbyname(argv[1])) == NULL ) {  // get the host info
    herror("gethostbyname");  // can't use perror()
    exit(__LINE__);
  }

  printf("Host name:\t%s\n", h->h_name);
  // h->h_addr is a char*, but inet_ntoa() wants a struct in_addr passed to
  // it. So (1) cast h->h_addr to a struct in_addr*, then dereference it (2)
  // to get at the data.
  //                                      ________1_________
  printf("IP Address:\t%s\n", inet_ntoa(*((struct in_addr *)h->h_addr)));
  //                                    2
 
 return 0;
} 
