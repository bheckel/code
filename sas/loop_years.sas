options nosource;
 /*---------------------------------------------------------------------------
  *     Name: loop_years.sas
  *
  *  Summary: Demo of using year dates as the do loop iterator.
  *
  *  Adapted: Wed 05 Mar 2003 16:11:23 (Bob Heckel --
  *                            file:///C:/bookshelf_sas/lrcon/z0998889.htm)
  * Modified: Tue 11 Mar 2003 08:37:51 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;


data work.tmp;
  beginyr='01JAN1990'd;
  endyr='31DEC2009'd;

  do year=year(beginyr) to year(endyr);
    Capital+2000 + .07*(Capital+2000);
    output;
  end;

  put 'The number of DATA step iterations is only '_N_;
run; 

 /* or to loop over the most recent 4 years: */
data _NULL_;
  call symput("CYR", substr(put("&SYSDATE9"d,mmddyy10.),7,4));
run;

data work.tmp;
  do i=%eval(&CYR-4) to &CYR;
    foo=i;
    /* output required or it only writes last loop to work.tmp */
    output;
  end;
run;
proc print; run;
