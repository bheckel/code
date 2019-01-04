2005-11-17 manually adjusted scan.l (deleted line) then ran
$ ./configure --with-readline
$ make
$ cp bc/bc.exe ~/bin


Readline patch (TODO how to get set -o vi style readline?):
$ cd bc-1.06/bc
$ patch < thispatch


--- scan.l.orig 2002-10-03 10:45:18.000000000 -0400
+++ scan.l      2002-10-03 10:43:23.000000000 -0400
@@ -143,7 +143,7 @@
 
 /* Definitions for readline access. */
 extern FILE *rl_instream;
-_PROTOTYPE(char *readline, (char *));
+/* _PROTOTYPE(char *readline, (char *)); */
 
 /* rl_input puts upto MAX characters into BUF with the number put in
    BUF placed in *RESULT.  If the yy input file is the same as
