options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_format_multilabel.sas
  *
  *  Summary: Demo of overlapping SAS formats.
  *
  *  Adapted: Wed 01 Apr 2009 12:39:34 (Bob Heckel -- SUGI 041-2008)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

proc format;
  value AGEGROUP (multilabel)
        0 - <20 = '0 to <20'
        20 - <40 = '20 to <40'
        40 - <60 = '40 to <60'
        60 - <80 = '60 to <80'
        80 - high = '80 +'

        0 - <50 = 'Less than 50'
        50 - high = '> or = to 50'
        ;
run;

data tmp;
  set sashelp.air(obs=20);
  shrunken = air - 100;
/***  fmtshrunken = put(shrunken, AGEGROUP.);***/
run;
/***title "ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum; run;***/

proc tabulate;
  where date < '01JAN53'd;
  class shrunken date / MLF;
  table shrunken, date;
  format shrunken AGEGROUP.;
run;
