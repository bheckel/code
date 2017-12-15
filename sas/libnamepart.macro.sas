options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: libnamepart.macro.sas
  *
  *  Summary: Extract the libname.
  *
  *           TODO check USER for unusual default lib other than WORK
  *
  *  Adapted: Wed 09 Jun 2004 14:32:38 (Bob Heckel -- Ian Whitlock SUGI 29
  *                                     244-29)
  *---------------------------------------------------------------------------
  */
options source;

data tmp; set SASHELP.shoes; if region in:('A', 'E'); run;

%macro LibPart(ds=&SYSLAST);
  %local libnm;
  
  %let ds=&ds;  /* force evaluation of &SYSLAST */
  %if %index(&ds, .) = 0 %then
    %let libnm = 'WORK';   /* assumes user hasn't set USER sys opt */
  %else
    %let libnm = %upcase("%scan(&ds, 1)");

  &libnm 
%mend LibPart;

data _null_;
  ***put %LibPart();
  put %LibPart(ds=SASHELP.shoes);
run;
