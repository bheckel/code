options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: only_certain_datasets.sas (s/b symlinked as dictionary.sas)
  *
  *  Summary: Choose by pattern, only specific datasets in a SAS lib.
  *
  *  Created: Tue 17 Aug 2004 12:34:11 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter mlogic mprint sgen;

libname MVDS1 'DWJ2.MED2003.MVDS.LIBRARY.NEW' DISP=SHR;
libname MVDS2 'DWJ2.MED2004.MVDS.LIBRARY.NEW' DISP=SHR;

proc sql;
   ***describe table dictionary.catalogs;
   ***describe table dictionary.columns;
   ***describe table dictionary.extfiles;
   ***describe table dictionary.indexes;
   ***describe table dictionary.macros;
   describe table dictionary.members;
   ***describe table dictionary.options;
   ***describe table dictionary.tables;
   ***describe table dictionary.titles;
   ***describe table dictionary.views;
quit;

proc sql NOPRINT;
  select memname into :DSETS separated by ' '
  from dictionary.members
  /* Case sensitive! */
  where libname like 'MVDS%' and memname like '%NEW'
  ;
quit;

%put !!! &DSETS;
