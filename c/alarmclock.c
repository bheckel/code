/*****************************************************************************
 *     Name: alarmclock.c
 *
 *  Summary: Alarm clock.  Pass hour/min to go off.  Good demo of using time
 *           under C.  Assumes "beep" exists on the system.
 *
 *           Cheap alternative: sleep `echo '60*2'|bc` && beep
 *
 *  Adapted: Sun 19 May 2002 15:52:11 (Bob Heckel -- Beginning Linux Prog)
 * Modified: Tue 28 Oct 2003 16:50:09 (Bob Heckel)
 *****************************************************************************
*/
#define DEBUG 0
#define BELL '\x7'

#include <signal.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#include <stdlib.h>

static int alarm_fired = 0;
int atoi(const char *str);

void ding(int sig) {
  alarm_fired = 1;
}


int main(int argc, char *argv[]) {
  int    pid;
  char  *msg;
  time_t rightnow;
  time_t lateron;
  time_t epoch_fmt_later;
  int    interval_mins;
  struct tm *laterstruct;

  if ( argc < 2 ) {
    puts("error: must pass hour and minute");
    puts("Usage: alarmclock hour minute [optional quoted message]");
    puts("       E.g. alarmclock 16 30 'time to go home'&");
    puts("Exiting.");

    exit(1);
  }

  rightnow = time(NULL);
  lateron = time(NULL);

  laterstruct = localtime(&lateron);  // create broken-down time
  // TODO allow 20:05 and parse it as argv[1] instead of using [1] and [2]
  laterstruct->tm_hour = atoi(argv[1]);
  laterstruct->tm_min = atoi(argv[2]);

  epoch_fmt_later = mktime(laterstruct);  // convert to e.g. 1021852869

  // How many minutes to wait before ringing.
  interval_mins = difftime(epoch_fmt_later, rightnow);

  if ( DEBUG ) {
    printf("DEBUG: %s", ctime(&epoch_fmt_later));
    printf("DEBUG: %ld\n", epoch_fmt_later);
    printf("DEBUG %d\n", interval_mins);
  }

  // TODO use switch to handle specific minutes to run
  ///mins = atoi(argv[1]);
  ///howlong = mins * 60;

  msg = argv[3];

  printf("Alarm has been set for %i minutes.\n", interval_mins/60);

  /*  We tell the child process to wait for X minutes before sending a SIGALRM
   *  signal to its parent.  
   */
  if ( (pid = fork()) == 0 ) {
    if ( DEBUG )
      sleep(3);
    else
      sleep(interval_mins);

    kill(getppid(), SIGALRM);

    exit(0);
  }

  /*  The parent process arranges to catch SIGALRM with a call to signal and
   *  then waits for the inevitable.  
   */
  (void) signal(SIGALRM, ding);

  pause();  // suspend execution of this pgm until a signal is received

  if ( alarm_fired ) {
    system("beep");
    // TODO not working
    ///putchar(BELL);
    printf("\n+----------------------------------~~===~~-----------------------------------+\n");
    printf("+----------------------------------~~^^^~~-----------------------------------+\n");
    printf(" ALARM: %s\n", msg);
    sleep(1);
    ///putchar(BELL);
    printf("+----------------------------------~~^^^~~-----------------------------------+\n");
    printf("+----------------------------------~~===~~-----------------------------------+\n\n");
    ///putchar(BELL);
  }

  exit(0);
}
