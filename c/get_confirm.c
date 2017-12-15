/*****************************************************************************
 *    Name: get_confirm.c
 *
 * Summary: Prompt user for yes or no.
 *
 * Adapted: Sat 28 Jul 2001 23:22:20 (Bob Heckel -- from Beginning Linux Prog)
 *****************************************************************************
*/
#include <stdio.h>

static int get_confirm(const char *question);


int main(void) {
  int y_or_n;

  y_or_n = get_confirm("oknow?\n");

  printf("Result %d\n", y_or_n);

  return 0;
}


static int get_confirm(const char *question) {
  char tmp_str[80];
  
  printf("%s", question);

  fgets(tmp_str, 80, stdin);

  if ( tmp_str[0] == 'Y' || tmp_str[0] == 'y' ) {
    return(1);
  }

  return(0);
}
