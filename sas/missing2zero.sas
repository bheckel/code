options nosource;
 /*---------------------------------------------------------------------------
  *     Name: missing2zero.sas
  *
  *  Summary: Convert missings to zeros to avoid 'nulls missings propagate'
  *           problems.
  *
  *  Created: Wed 30 Oct 2002 13:00:15 (Bob Heckel)
  * Modified: Mon 27 Feb 2012 10:20:49 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;


data work.sample;
  input fname $1-10  lname $15-25  @30 numb 3.;
  datalines;
mario         lemieux        .
ron           francis        123
jerry         garcia         123
larry         wall           .
richard       dawkins        345
richard       feynman        678
  ;
run;


data work.converted;
  set work.sample;
  /* Note: mandatory no '{*}' */
  array numarray _NUMERIC_;
  do over numarray;
    if numarray eq . then
      numarray = 0;
  end;
run;
proc print; run;

 /* Better if we only have one numeric variable. */
data work.converted;
  set work.sample;
  numb = sum(0, numb);
run;
proc print; run;

 /* Same */
data work.converted2;
  set work.sample;
  numb+0;
run;
proc print; run;
proc contents; run;



 /* Or missings NOT to zero: */
data t;
  infile cards;
  input recorded_text $10.;
  cards;
1
2
0

NPI
-5
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

data t2;
  set t;

  if not missing(recorded_text) then do;
    /* Force to numeric to compare */
    _recorded_text = input(recorded_text, BEST. -L);
    if _recorded_text lt 0 then do;
      recorded_text='0';
    end;
  end;
run;
/***proc contents data=work._all_;run;***/
proc print data=_LAST_(obs=max) width=minimum; run;
