/*****************************************************************************
 *    Name: env.c
 *
 * Summary: A better version of printenv/env utility.  It avoids the
 *          disfiguring coloration that occurs when normal env hits a 'fg_'
 *          variable (for example fg_red).
 *
 * Adapted: Tue 10 Apr 2001 14:26:41 (Bob Heckel --
 *                             http://www.whitefang.com/unix/faq_2.html#SEC2)
 * Modified: Sat 09 Jun 2001 13:57:54 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>

///extern char **environ;
///
///int main(void) {
///  char **ep = environ;
///  char *p;
///
///  while ( (p = *ep++) )
///    /* Skip the fg_red etc that messes up the screen. */
///    if ( ! strstr(p, "fg") ) {
///      printf("%s\n", p);
///    }
///
///  return 0;
///}

/* Better. */
int main(int argc, char **argv, char **envp) {
  char *p;

  printf("WARNING: Skipping env varis that contain g_ (e.g.fg_ and bg_)");

  while ( (p = *envp++) )
    /* Skip the fg_red etc that messes up the screen. */
    if ( ! strstr(p, "g_") ) {
      printf("%s\n", p);
    }

  printf("WARNING: Skipping env varis that contain g_ (e.g.fg_ and bg_)\n");

  return 0;
}
