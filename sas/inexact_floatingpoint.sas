options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: inexact_floatingpoint.sas
  *
  *  Summary: Lack of precision of operations on floating point numbers.
  *
  *  Adapted: Fri 04 Feb 2005 09:12:57 (Bob Heckel -- Robert Anderson sug-l 
  *                                     mailing list)
  *---------------------------------------------------------------------------
  */
options source NOcenter;


data tmp;
  do i=1.0 to 2.0 by 0.2;
    output;
  end;
run;
proc print data=_LAST_(obs=max); run;
 

data tmp;
  set tmp;
  flag=0;
  i=round(i, .1);  /* w/o this, error occurs */
  if i in (1.6 1.4 2.0) then 
    flag=1; 
run;
proc print data=_LAST_(obs=max); run;
