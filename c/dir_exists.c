/*****************************************************************************
 *     Name: dir_exist.c
 *
 *  Summary: Check for the existence of a directory.  File test operation.
 *           Directory test operation.
 *
 *  Created: Wed 22 Aug 2001 09:19:08 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>
#include <dirent.h>

int main(int argc, char *argv[]) {
  if ( opendir("/tmp") ) {
    printf("dir exists");
  } else {
    printf("dir does not exist");
  }

  return 0;
}
