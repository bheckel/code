/*****************************************************************************
 *     Name: compare_file_timestamps.c
 *
 *  Summary: Determine if file1 is newer than file 2.
 *
 *           Most popular operating systems (including MS-DOS and VAX/VMS)
 *           provide the UNIX function stat, which returns pertinent file
 *           information, including the time last modified expressed as a
 *           time_t. 
 *            
 *  Adapted: Sun 05 May 2002 10:19:37 (Bob Heckel -- Code Capsules Chuck
 *                                     Allison)
 *****************************************************************************
*/
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <time.h>

int main(void) {
  struct stat fs1, fs2;

  if ( stat("compare_file_timestamps.c", &fs1) == 0 && 
      stat("time.c", &fs2) == 0 ) {
    double interval = difftime(fs2.st_mtime, fs1.st_mtime);

    printf("time1.c %s newer than time2.c\n",
                                       (interval < 0.0) ? "is" : "is not");

    return EXIT_SUCCESS;
  } else {
    return EXIT_FAILURE;
  }
}
