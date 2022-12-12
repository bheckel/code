/*****************************************************************************
 *     Name: read_parse.c
 *
 *  Summary: Demo of opening, reading, parsing on a character and excluding
 *           lines based on a starting character.
 *
 *           It will look for LOGINBOX in file bwrc to determine success.
 *
 *  Created: Fri, 27 Oct 2000 13:41:49 (Bob Heckel)
 * Modified: Tue Jul 09 13:03:21 2002 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>
#include <strings.h>

int get_param(char *pname, char *pval);


int main(void) {
  puts("start search");

  if ( ! get_param("LOGINBOX", "NO") ) {
  ///if ( ! get_param("CLOGINBOX", "NO") ) {
    puts("succeeded");

    return 0;
  } else {
    puts("failed");

    return 1;
  }
}


int get_param(char *pname, char *pval) {
  char *fname = "/home/bqh0/tmp/testing/bwrc";
  ///char *fname = "bwrc";
  ///char *card;  <---don't use this declaration
  char card[80];
  FILE *fd;
  int caught;
  char *token;

  if ( (fd = fopen(fname, "r") ) == NULL) {
    printf("cannot open %s.  Exiting\n", fname);

    return 1;
  }

  caught = 0;
  // For each line in *fname ...
  while ( feof(fd) == NULL ) {
    // Treat chunk of characters as a line.
    if ( fgets(card, 80, fd) != NULL ) {
      if ( strcmp(card, "[yes]\n") == NULL ) {
        printf("Found section: %s", card);
        // Now start looking at the key/value pairs.
        ///continue;
      }
      // Until see next [foo] or EOF...
      ///if ( caught ) {
      token = strtok(card, "=");
      // The next [bracket pair] means you're done with the section.
      ///if ( !strncmp(card, "[", 1) ) {
      ///printf("DEBUG xx%sxx xx%sxx\n", token, pname);
      if ( !strcmp(token, pname) ) {
        printf("key: %s", token);
        token = strtok(NULL, "=");
        printf("  value: %s\n", token);
        return 0;
      }
    }
  }
  fclose(fd);

  return 1;
}

// Contents of bwrc:
// BWHOST		= NTVAX6
// SERVICE		= BW$HOME:BWSERVER_NULL_TCPD
// INET_PORT	= 1202
// ROUTING		= ON
// REPAIR		= ON
// [yes]
// LOGINBOX=NO
// OPERATOR	= 104986
// PASSWORD=NATIONAL
// STAGENAME	= GENRAD
// DEBUG		= ON
// #SPOOLFILE	= bwspool%m%d%H%M
// [no]
// SPOOLFILE	= bwspool
// #LOGFILE         = %m%d%-%H%M.bwlog
// LOGFILE         = bwlog
// DEF_WINDOWSIZE  = 5
// DEF_MAXERRS_WDW = 5
