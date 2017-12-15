options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: diskspacefree.sas
  *
  *  Summary: Determine free space by hacking dir.  Windows only
  *
  *  Created: Thu 07 Dec 2006 08:57:49 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* Must use Windows style backslashes for the pipe */ 
filename DIRINFO PIPE 'dir c:\cygwin\home\bheckel\tmp\testing';

data _null_;
  retain rx;
  format byt 8.;

  if _N_ eq 1 then 
    rx = rxparse("$f");  /* floating point nums */

  infile DIRINFO PAD end=e;
  input ln $80.;

  if e then do;
    put _all_;
    rc = rxmatch(rx, ln);
    /* Convert 'Dir(s) 1,234,567 blah blah' into the number 1234567 */
    byt = input(compress(upcase(substr(ln, rc)),' ()ABCDEFGHIJKLMNOPQRSTUVWXYZ,'), F8.); 
    put byt=;
    if byt lt 10000000 then do;
      put 'low disk space - less than 10GB';
      abort;
    end;
  end;
run;


endsas;


 Volume in drive C has no label.
 Volume Serial Number is 547C-8B38

 Directory of C:\

10/18/2006  12:26    <DIR>          aaalimsrpts
12/05/2006  08:00                72 epamch.amz
12/07/2006  12:51    <DIR>          WINDOWS
               3 File(s)             72 bytes
              12 Dir(s)  13,578,374,656 bytes free
