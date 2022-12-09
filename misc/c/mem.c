/*****************************************************************************
 *     Name: mem.c
 *
 *  Summary: Determine memory usage.  Windows specific!
 *           TODO use this as a starting point for a taskbar tray applet
 *
 *  Created: Sat, 23 Mar 2002 13:33:11 (Bob Heckel -- MSDN Library example)
 *****************************************************************************
*/
#include <stdio.h>
#include <windows.h>
///#define DIV 1
///#define DIV 1024  // 2^10
// Change the divisor from Kb to Mb.
#define DIV 1048576  // 2^20
// Handle the width of the field in which to print numbers this way to
// make changes easier. The asterisk in the print format specifier
// "%*ld" takes an int from the argument list, and uses it to pad and
// right-justify the number being formatted.
///#define WIDTH 7


int main(int argc, char *argv[]) {
  MEMORYSTATUS stat;
  ///char *divisor = "";
  ///char *divisor = "K";
  char *divisor = "M";

  GlobalMemoryStatus (&stat);

  if ( stat.dwLength != sizeof stat ) {
    printf("The MemoryStatus structure is %ld bytes long.\n", stat.dwLength);
    printf("This is a problem.  It should be %d.\n", sizeof stat);
  }

  printf("%ld%% of memory is in use.\n", stat.dwMemoryLoad);

  printf("   %ld free out of %ld total %sbytes physical memory.\n",
          stat.dwAvailPhys/DIV, stat.dwTotalPhys/DIV, divisor);

  printf("   %ld free out of %ld total %sbytes paging memory.\n",
          stat.dwAvailPageFile/DIV, stat.dwTotalPageFile/DIV, divisor);

  printf("   %ld free out of %ld total %sbytes virtual memory.\n",
          stat.dwAvailVirtual/DIV, stat.dwTotalVirtual/DIV, divisor);

  return 0;
}
