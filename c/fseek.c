/*****************************************************************************
 *     Name: fseek.c
 *
 *  Summary: Move to a specific location in a file.
 *
 *  Adapted: Tue 08 Oct 2002 15:10:17 (Bob Heckel -- Using C on the Unix
 *                                     System)
 *****************************************************************************
*/
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>

struct record {
  int uid;
  char login[9];  /* logins are always max of 8 characters */
};

int putrec(FILE *fp, int i, struct record *r);

char *logins[] = { "user1", "user2", "user3", "user4" };


int main(void) {
  int i;
  FILE *fp;
  struct record rec;
  char the_file[80];

  sprintf(the_file, "%s/%s", getenv("HOME"), "junkfseek.txt");

  ///if ( (fp = fopen("/home/bheckel/tmp/testing/junkfsek.txt", "w")) == NULL ) {
  if ( (fp = fopen(the_file, "w")) == NULL ) {
    perror(the_file);
    exit(1);
  }

  for ( i=3; i>=0; i-- ) {
    rec.uid = i;
    strcpy(rec.login, logins[i]);
    putrec(fp, i, &rec);
  }

  fclose(fp);

  return 0;
}

  
int putrec(FILE *fp, int i, struct record *r) {
  printf("user %d: before fseek:\t %ld ", i+1, ftell(fp));

  ///fseek(fp, (long) 4 * sizeof(struct record), 2);
  fseek(fp, (long) 4 * sizeof(struct record), SEEK_END);

  printf("before fwrite:\t %ld ", ftell(fp));
  fwrite((char *) r, sizeof(struct record), 1, fp);
  printf("after fwrite:\t %ld\n", ftell(fp));

  return 0;
}
