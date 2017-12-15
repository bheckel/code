options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: inplace_edit.ds.sas
  *
  *  Summary: Edit a dataset on the fly.
  *
  *  Created: Fri 04 Apr 2008 09:40:34 (Bob Heckel)
  * Modified: Wed 17 Feb 2016 11:04:34 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data t; set sashelp.shoes(obs=5 keep=region stores); run;

data t;
  set t end=e;
  if e then do;
    output;  /* orig obs */
    region = 'Africa'; stores=99;
    output;  /* new obs */
  end;
  else do;
    output;  /* orig obs */
  end;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;



endsas;
data tmp;
  n1=1; a1="beticall1"; n2=1; a2="cally1";
  output;
  n1=50; a1="betical0"; n2=50; a2="cal5";
  output;
  n1=60; a1="betical6"; n2=60; a2="cal6";
  output;
run;

data tmp;
  set tmp;
  if n1 eq 50 then do;
    output;  /* orig obs */
    /* Duplicate the obs with '50' except for these 2 vars */
    n1=99; a1="betical99";
    output;
  end;
  else
    output;  /* orig obs */
run;
proc print data=_LAST_(obs=max) width=minimum; run;
