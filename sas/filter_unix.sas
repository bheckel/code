options nosource;
 /*---------------------------------------------------------------------------
  *     Name: filter_unix.sas
  *
  *  Summary: Use SAS as a filter to uppercase a file instead of using tr(1).
  *           $ cat foo.txt | tr "[a-z]" "[A-Z]"
  *           Unix only!
  *
  *           Sample call:
  *           $ cat foo.txt | /apps/sas8.2/sas filter_unix.sas | head -n2
  *
  *  Adapted: Fri 22 Nov 2002 09:35:37 (Bob Heckel --
  *           http://www.sas.com/service/techtips/quicktips/pipes_0702.html)
  *---------------------------------------------------------------------------
  */
options source;


 /* Convert input read from STDIN to uppercase and write to STDOUT -- acting
  * like a filter.
  */
data NULL;
  infile STDIN length=lg;
  file STDOUT;
  * Get record length;
  input @;
  input letter $varying200. lg;
  u_letter=upcase(letter);
  put u_letter;
run;
