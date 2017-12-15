/*****************************************************************************
 *     Name: perror.c
 *
 *  Summary: Demo of perror.  perror uses errno
 *           TODO does perror only work for system calls (not library calls)?
 *
 *  Created: Thu 11 Oct 2001 17:19:13 (Bob Heckel)
 * Modified: Tue 08 Oct 2002 14:28:34 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[]) {
  open("idonotexist");
  perror("perror spewed this");  // colon added automatically to the_errmsg

  return 0;
}
