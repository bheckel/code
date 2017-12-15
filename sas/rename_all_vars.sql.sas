options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: rename_all_vari.sql.sas
  *
  *  Summary: Demo of using the SQL dictionary to rename all variables at
  *           once.
  *
  *
  *            Make sure sasautos is in any options statement or %trim won't be
  *            available.  E.g.
  *
  * options compress=yes source source2 fullstimer ls=180 ps=max mautosource 
  *         sasautos=(SASAUTOS, "&CODE/lib") 
  *         ;
  *           
  *  Adapted: Fri 24 Oct 2003 14:27:25 (Bob Heckel -- SUGI 28 Paper 118-28 
  *                                     Ravi)
  * Modified: Thu 30 Apr 2009 10:40:17 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data one;
  U=1;
  V=2;
  X=3;
  Y=4;
  Z=5;
run;

%macro Renameall(lib, dsn);
  options pageno=1 nodate;

  proc contents data=&lib..&dsn;
    title "Before Renaming All Variables";
  run;

  proc sql noPRINT;
    select nvar into :NUM_VARS
    from dictionary.tables
    where libname="&LIB" and memname="&DSN"
    ;
    select distinct(name) into :VAR1-:VAR%TRIM(%LEFT(&NUM_VARS))
    from dictionary.columns
    where libname="&LIB" and memname="&DSN"
    ;
  quit;

  proc datasets library=&LIB;
    modify &DSN;
    rename %do i=1 %to &NUM_VARS;
             &&VAR&i=NEWNAME_&&VAR&i.
           %end;
           ;
  run;

  proc contents data=&lib..&dsn;
    title "After Renaming All Variables";
  run;
%mend Renameall;
 /* Both parms must be uppercase! */
%Renameall(WORK,ONE);
