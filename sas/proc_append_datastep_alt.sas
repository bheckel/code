options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_append_datastep_alt.sas
  *
  *  Summary: Append to end of dataset
  *
  *  Created: Tue 03 Dec 2013 13:00:23 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

data base;
  set sashelp.shoes(obs=5);
run;

data one;
  set sashelp.shoes(obs=1);
run;

data two;
  set sashelp.shoes(obs=2);
run;

data base;
  if 0 then modify base;
  set one two open=defer;
  output;
run;
proc print data=base(obs=max) width=minimum; run;



 /* Manual edit */
data base;
  set sashelp.shoes(obs=5);
run;

data base;
  set base end=e;
  output;
  if e then do;
    region='Reg1';
    product='Prod1';
    subsidiary='Subs1';
    /* If remaining vars are not listed here they get same values a last obs */
    output;
    region='Reg2';
    product='Prod2';
    subsidiary='Subs2';
    /* If remaining vars are not listed here they get same values a last obs */
    output;
  end;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
