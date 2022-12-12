/*****************************************************************************
 *     Name: port.c
 *
 *  Summary: Give port number based on name and protocol method.
 *           E.g. port http tcp
 *
 *           TODO crashes if invalid data passed in
 *
 *  Adapted: Tue 04 Dec 2001 15:58:08 (Bob Heckel--Sean Walton,
 *                                     Linux Socket Programming)
 *****************************************************************************
*/
#include <stdio.h>
#include <netinet/in.h>
#include <netdb.h>

int main(int argc, char *argv[]) {
  struct servent *srv;

  if ( argc < 3 ) {
    fprintf(stderr,"usage: %s wellknownportname protocol\n", argv[0]);
    exit(__LINE__);
  } 


  // E.g. getservbyname("http", "tcp");
  srv = getservbyname(argv[1], argv[2]);
  ///srv->s_name  = "http";
  ///srv->s_proto = "tcp";
  printf("%s: port=%d\n", srv->s_name, ntohs(srv->s_port));
  
  return 0;
}

