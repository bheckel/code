/*****************************************************************************
 *     Name: gdbm.c
 *
 *  Summary: Demo of creating and searching a GDBM file.
 *
 *  Adapted: Sat 10 Aug 2002 17:27:29 (Bob Heckel --
 *                 http://studentweb.providence.edu/~lwilkens/unix/htmlfiles/
 *                 ClassActivity_gdbm.html
 *****************************************************************************
*/
#include <stdlib.h> 
#include <stdio.h> 
#include <gdbm.h> 

int main(void){ 
  GDBM_FILE dbf; 
  datum key, data; 
  datum result; 
  char *keystr;
  char *valstr;

  keystr  = "thekey";

  ///key.dsize = strlen("thekey")+1; 
  key.dsize = strlen(keystr)+1; 
  key.dptr = (char*)malloc(sizeof(char)*key.dsize); 
  ///strcpy(key.dptr, "thekey"); 
  strcpy(key.dptr, keystr); 
  key.dptr[key.dsize-1] = '\0';

  valstr = "the test value";

  ///data.dsize = strlen("test thevalue")+1; 
  data.dsize = strlen(valstr)+1; 
  data.dptr = (char*)malloc(sizeof(char)*data.dsize); 
  strcpy(data.dptr, valstr); 
  data.dptr[data.dsize-1] = '\0';

  if ( (dbf=gdbm_open("test.dbm", 512, GDBM_WRCREAT, 0700, NULL))==NULL ){ 
    printf("error num: %d\n", gdbm_errno); 
    exit(1); 
  } 
  // Insert one record.
  gdbm_store(dbf, key, data, GDBM_INSERT);

  // Search the db.
  result = gdbm_fetch(dbf, key);

  printf("%s\n", result.dptr); 

  free(result.dptr);

  gdbm_close(dbf);

  return 0;
} 
