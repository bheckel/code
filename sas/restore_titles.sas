options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: restore_titles.sas
  *
  *  Summary: Determine current settings and restore later.
  *
  *  Adapted: Tue 25 May 2004 16:02:46 (Bob Heckel -- SUGI 055-29)
  *---------------------------------------------------------------------------
  */
options source pagesize=20;

title 'origtitle1';
title2 'origtitle2';
footnote 'origfoot1';

proc sql;
  create table currtitles as
  select *
  from DICTIONARY.titles
  ;
quit;

proc print data=_LAST_; run;

title2 'CHANGED!';

data _null_;
  set currtitles;
  length etype $11;

  if type eq 'T' then
    etype = 'title';
  else
    etype = 'footnote';

  call execute(left(trim(etype)) || left(trim(number)) || text || ';');
run;

proc print data=_LAST_; run;
