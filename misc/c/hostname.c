/*****************************************************************************
 *     Name: hostname.c
 *
 *  Summary: Determine hostname on local machine.
 *
 *  Created: Fri 18 Oct 2002 11:00:15 (Bob Heckel -- Using C on The Unix Sys)
 *****************************************************************************
*/
#include <stdio.h> 
#include <unistd.h> 
#include <netdb.h> 


int main(void) {
  char hname[80];
  struct hostent *hp;
  
  gethostname(hname, sizeof hname);

  fprintf(stderr, "current machine hostname: %s\n", hname);

  /* Or */

  hp = gethostbyname(hname);
  fprintf(stderr, "hp->h_name: %s\n", hp->h_name);
  fprintf(stderr, "hp->h_addrtype: %d\n", hp->h_addrtype);
  fprintf(stderr, "hp->h_length in bytes: %d\n", hp->h_length);

  return 0;
}
