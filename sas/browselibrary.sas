options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: browselibrary.sas
  *
  *  Summary: Poke 'n' sniff at a SAS data library, obtaining number of 
  *           observations and a look at the first few records of each.
  *
  *           An improved proc contents.
  *
  *           Good demo of dynamically running a macro on each obs in a
  *           dataset.
  *
  *  Adapted: Fri 04 Jun 2004 13:26:52 (Bob Heckel -- SUGI 'You Could Look
  *                                     It Up' Michael Davis)
  *---------------------------------------------------------------------------
  */
options source NOcenter ls=180 NOreplace;

%macro BrowseLib(path, prtobs);
  libname L "&path";
  filename FLEX CATALOG 'work.temp.flex.source';

  proc sql;
    create table libdata as
    select libname, memname, nobs
    from dictionary.tables
    where libname = 'L'
    ;
  quit;

  title "!!!=-=-=-= DATASETS for &path =-=-=-=!!!";
  proc print data=libdata; run;

  %macro NameAndObs(memname, nobs);
    options pageno=1 ps=60 obs=&prtobs NOcenter;
    title "!!!=-=-=-= DATA SET=&memname NOBS=&nobs =-=-=-=!!!";
    proc print data=L.&memname; run;
  %mend NameAndObs;

  %macro PrtFirstFew;
    /* TODO set this back to whatever user had it set to */
    options obs=max NOcenter;
    data _null_;
      set libdata;
      file FLEX;
      /***  put '%NameAndObs('MEMNAME $8.','NOBS 8.')'; ***/
      put '%NameAndObs(' MEMNAME ',' NOBS ')';
    run;
    %include FLEX / source2;
  %mend PrtFirstFew;
  %PrtFirstFew;
%mend BrowseLib;

***%BrowseLib(c:/temp, 10);
***%BrowseLib(BQH0.SASLIB, 10);
/* TODO doesnt work */
%BrowseLib(SASHELP, 5);
