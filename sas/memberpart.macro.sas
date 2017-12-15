options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: memberpart.macro.sas
  *
  *  Summary: Extract the member name.
  *
  *  Adapted: Wed 09 Jun 2004 14:32:38 (Bob Heckel -- Ian Whitlock SUGI 29
  *                                     244-29)
  *---------------------------------------------------------------------------
  */
options source;

data tmp; set SASHELP.shoes; if region in:('A', 'E'); run;

%macro MemPart(ds=&SYSLAST);
  %local memname;
  
  %let ds=&ds;  /* force evaluation of &SYSLAST */
  %if %index(&ds, .) = 0 %then
    %let memname = %upcase("%scan(&ds, 1)");
  %else
    %let memname = %upcase("%scan(&ds, 2)");

  &memname 
%mend MemPart;

data _null_;
  ***put %MemPart();
  put %MemPart(ds=SASHELP.shoes);
run;
