options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: putn.sas
  *
  *  Summary: Demo of using putn() to specify a numeric format at runtime.
  *
  *           %put ended %sysfunc(putn(%sysfunc(datetime()),DATETIME.));
  *
  *  Adapted: Wed 12 Nov 2003 09:51:40 (Bob Heckel --
  *                            file:///C:/bookshelf_sas/lgref/z0212564.htm)
  * Modified: Fri 28 Mar 2008 13:43:53 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

proc format;
   value writfmt 1='DATE9.' 
                 2='MMDDYY10.';
run;

data dates;
  input number fmtkey;

  date_fmt_to_use = put(fmtkey, writfmt.);

  formatted_date = putn(number, date_fmt_to_use);

  datalines;
15756 1
14552 2
  ;
run;
proc print; run;
proc contents; run;
