/* Determine the IP addresses of the first two adapters on this machine.
 * Probably easier to just use ifconfig on Unix or ipconfig on Win32.
 *
 * Modified: Sat 26 Jul 2003 20:07:53 (Bob Heckel) 
 */
#include <stdio.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <net/if.h>
#include <netdb.h>
#include <netinet/in.h>
#include <arpa/inet.h>


int main(void) {
  struct ifreq ifr;
  struct ifreq ifr2;
  struct sockaddr_in *sin = (struct sockaddr_in *)&ifr.ifr_addr;
  struct sockaddr_in *sin2 = (struct sockaddr_in *)&ifr2.ifr_addr;
  int sockfd;

  bzero(&ifr, sizeof(ifr));
  bzero(&ifr2, sizeof(ifr2));

  if ( (sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0 ) {
    perror("socket()");
    return -1;
  }

  strcpy(ifr.ifr_name, "eth0");
  sin->sin_family = AF_INET;
  strcpy(ifr2.ifr_name, "eth1");
  sin2->sin_family = AF_INET;

  if ( ioctl(sockfd, SIOCGIFADDR, &ifr) == 0 ) {
    printf("%s : [%s]\n", ifr.ifr_name, inet_ntoa(sin->sin_addr));
  }
  if ( ioctl(sockfd, SIOCGIFADDR, &ifr2) == 0 ) {
    printf("%s : [%s]\n", ifr2.ifr_name, inet_ntoa(sin2->sin_addr));
  }

  return 0;
}
