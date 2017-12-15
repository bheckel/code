/*****************************************************************************
 *     Name: grcadfile.c
 *
 *  Summary: Allow user to copy a specific type of file to a specific
 *           directory or delete a single, specific type of file.
 *
 *           Originally used for CADfile IWS Uploader Application.
 *           On hpLdev01:
 *           $ su webshop
 *           $ cd /webshop/bin
 *           $ gcc -O3 -o grcadfile grcadfile.c 
 *           $ strip grcadfile
 *           Should run setuid to gr8xprog to copy successfully to /gr8xprog:
 *           $ chown gr8xprog grcadfile
 *           $ su gr8xprog
 *           $ chmod +s grcadfile
 *
 *  Created: Wed 08 Aug 2001 16:12:44 (Bob Heckel)
 * Modified: Wed 22 Aug 2001 10:03:25 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <dirent.h>
// May need to include <getopt.h> on non-HP systems.
#include <getopt.h>
#define CP "/bin/cp"
#define RM "/bin/rm"

int cpfile(char **the_args, int index, char *filetype, int typelen);
int rmfile(char **the_args, int index, char *filetype, int typelen);
char *substr(char dest[], char src[], int offset, int len);
int usage(char *thispgm);


int main(int argc, char *argv[]) {
  int c;
  int rc = 1;

  // For security (this program will usually run setuid).
  environ = NULL;

  opterr = 0;
  // 'getopt' returns '-1', to indicate no more options are present.
  while ( (c = getopt(argc, argv, "cCnNh")) != -1 ) {
    if ( optind >= argc ) {   // nothing but a switch, eg -c was passed to pgm
      usage(argv[0]);  
      break;
    }
    switch ( c ) {
      case 'c':  // a .cad file to copy
        if ( argc < 4 ) {   // must have 2 params (source, dest) passed
          usage(argv[0]);  
          break;
        }
        rc = 0;  // assume success since execl doesn't return
        // .cad hardcoded for security.
        // optind is the array element where the non-switches begin.
        cpfile(argv, optind, ".cad", 4);
        rc = 1;  // fail
        break;
      case 'C':  // a .cad file to delete
        rc = rmfile(argv, optind, ".cad", 4);
        break;
      case 'n':  // a .nail file to copy
        if ( argc < 4 ) {   // must have 2 params (source, dest) passed
          usage(argv[0]);  
          break;
        }
        rc = 0;  // assume success since execl doesn't return
        cpfile(argv, optind, ".nail", 5);
        rc = 1;  // fail
        break;
      case 'N':  // a .nail file to delete
        rc = rmfile(argv, optind, ".nail", 5);
        break;
      case 'h':
        // Help.
        usage(argv[0]);
        rc = 0;
        break;
      case '?':  // set by getopt
        fprintf(stderr, "Switch -%c is unknown.\n", optopt);
        usage(argv[0]);
        rc = 1;
        break;
      default:  // impossible condition
        fprintf(stderr, "Unknown error.\n");
        usage(argv[0]);
        rc = 1;
        break;
    }
  }

  if ( argc == 1 ) usage(argv[0]);  // nothing passed to pgm

  return rc;  // 1 == error, 0 == success
}


// Copy conforming file to conforming directory.
int cpfile(char **the_args, int index, char *filetype, int typelen) {
  int   rc = 1;
  char  buffer1[80];
  char  buffer2[80];
  char *file_ext;  // demand .cad or .nail extension from user
  char *slash;    // demand trailing slash to prevent user from renaming file
  int   dirok;   // demand that directory exists

  file_ext = substr(buffer1, the_args[index], strlen(the_args[index])-typelen, 
                                                                     typelen);   

  slash = substr(buffer2, the_args[index+1], strlen(the_args[index+1])-1, 1);
 
  opendir(the_args[index+1]) ? (dirok = 1) : (dirok = 0);

  if ( strstr(file_ext, filetype) && strstr(slash, "/") && dirok ) {
    // /bin/cp is supplied once to name the program to execute and a
    // second time to supply a value for 'argv[0]'
    rc = execl(CP, CP, the_args[index], the_args[index+1], NULL);
    // execl *does not* return if successful.  If it fails, make child
    // terminate but don't flush buffers.
    _exit(1);
  }

  return rc;  // execl() will not reach here if it finishes without errors
}


// Allow deletion of specified filetypes only.
int rmfile(char **the_args, int index, char *filetype, int typelen) {
  int rc = 1;
  char buffer[80];
  char *file_ext;  // demand .cad extension from user

  file_ext = substr(buffer, the_args[index], strlen(the_args[index])-typelen, 
                                                                    typelen);   

  if ( strstr(file_ext, filetype) ) {
    // /bin/cp is supplied once to name the program to execute and a
    // second time to supply a value for 'argv[0]'
    rc = execl(RM, RM, the_args[index], NULL);
    // execl *does not* return if successful.  If it fails, make child
    // terminate but don't flush buffers.
    _exit(1);
  } else {
    rc = 1;
  }

  return rc;  // execl() will not reach here if no errors
}


// Return ptr to char substring, given starting point and length.
char *substr(char dest[], char src[], int offset, int len) {
  int i;

  for ( i=0; i<len && src[offset + i]!='\0'; i++ )
    dest[i] = src[i + offset];

  dest[i] = '\0';

  return dest;
}


int usage(char *thispgm) {
  fprintf(stderr, "Usage:\n"
          "       %s -c FILENAME.cad DIRECTORY/ \n"
          "       Copy .cad file to specific directory.\n"
          "  or:\n"
          "       %s -n FILENAME.nail DIRECTORY/ \n"
          "       Copy .nail file to specific directory.\n"
          "  or:\n"
          "       %s -C FILENAME.cad\n"
          "       Delete single cad file.\n"
          "  or:\n"
          "       %s -N FILENAME.nail\n"
          "       Delete single nail file.\n\n"
          " Provides limited functionality file manipulation.\n"
          , thispgm, thispgm, thispgm, thispgm);

  return 0;
}
