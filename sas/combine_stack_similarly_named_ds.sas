options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: combine_stack_similarly_named_ds.sas
  *
  *  Summary: Stack datasets named similarly in the same library
  *
  *  Adapted: http://www.sas.com/offices/NA/canada/downloads/presentations/TASS-June2011/Macrovarlist.pdf
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

proc sql noprint ;
  select 'SASHELP.'||left(memname) into :memlist separated by ' '
  from DICTIONARY.members
  where libname = 'SASHELP'
  and memname like 'NVST%' ;
quit ;

data all_nvst ;
  set &memlist ;
run ;
proc print data=_LAST_(obs=10) width=minimum; run;
