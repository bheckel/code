 /*---------------------------------------------------------------------
  *     Name: TABDELIM.sas
  *
  *  Summary: Output ds as tab delimited textfile (allow Excel to open 
  *           it)
  *
  *           Input: ds name and quoted, fully qualified path for
  *                  output textfile.
  *
  *           If get numvar error it's probably b/c you must use fully
  *           qualified libname.  E.g. 'WORK.foo' not 'foo' in the macro call
  *
  *
  *           IMPORTANT:
  *           To prevent fscking Excel from changing text like "1-60" to
  *           Jan-1960, open the just-created t.xls normally then select all
  *           cells, delete them, right-click Format : Number select Text then
  *           copy 'n' paste ($ catput t.xls) on top of the existing data.
  *
  *           Sample call:
  *           %include "&HOME/code/sas/tabdelim.sas";
  *            ...code that builds WORK.tmp...
  *           options NOmlogic NOmprint NOsgen;%Tabdelim(WORK.tmp, 't.xls');
  * 
  *  Created: Wed Oct  7 10:58:14 1998 (Bob Heckel)
  * Modified: Thu 05 Jan 2006 15:15:44 (Bob Heckel)
  *---------------------------------------------------------------------
  */

%macro Tabdelim(dsname, outfile);
  %local i tab the_blksize the_lrecl libr memb the_label the_var numvar;

  %put <<TABDELIM>> Tabdelim macro starting...;

  /* Handle the non-portable tab char. */
  %macro DetectPlatform;
    %if &SYSSCP = OS %then
      %do;
        /* We're on the Mainframe */
        %let tab='05'x;
        %let the_blksize=%str(BLKSIZE=2560);
        %let the_lrecl=256;
      %end;
    %else
      %do;
        %let tab='09'x;
         %let the_lrecl=32750;
      %end;
  %mend DetectPlatform;
  %DetectPlatform

  %let libr=%upcase(%scan(%quote(&dsname), 1, %str(.)));
  /* library member */
  %let memb=%upcase(%scan(%quote(&dsname), 2, %str(.)));

  /* Get variable info for the header line of output file. */
  proc sql noprint;
    create view WORK.dsdict as
      select *
      from dictionary.columns
      where libname = "&libr" and memname = "&memb"
      ;
  quit;

  data _NULL_;
    set WORK.dsdict END=e;

    /* Use variable's name if SAS label is blank. */
    if label eq ' ' then
      label = name;
    /* Capture all variables in dsname. */
    call symput('the_label' !! left(put(_N_, 3.)), compbl(label));
    call symput('the_var' !! left(put(_N_, 3.)), name);
    /* Determine total number of variables. */
    if e then
      call symput('numvar', left(put(_N_, 3.)));

  run;

  data _NULL_;
    set &dsname;

    file &outfile &the_blksize LRECL=&the_lrecl;

    /* Write header. */
    if _N_ eq 1 then
      do;
        put %do i=1 %to &numvar;
              "&&the_label&i" &tab
            %end;
        ;
      end;

    /* Write data, starting on 2nd line of ds. Backup over trailing space
     * TODO Scan end of field for garbage
     */
    put %do i=1 %to &numvar;
          &&the_var&i +(-1) &tab
        %end;
      ;
  run;
  %put <<TABDELIM>> Total variables: &numvar;
  %put <<TABDELIM>> ...Tabdelim macro finished;
%mend Tabdelim;

