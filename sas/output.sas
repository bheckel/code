options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: output.sas
  *
  *  Summary: Demo of the output statement.
  *
  *           Every datastep has an implied OUTPUT statement at the end
  *           which tells SAS to write the current obs to the output
  *           dataset before returning to the beginning of the data step
  *           to process the next obs.  You can override this behavior
  *           with your own OUTPUT statement.
  *
  *           Control is returned to the beginning of the data step after the
  *           bottom of the step is reached, NOT when an OUTPUT statement is
  *           executed.
  *
  *           Can use OUTPUT statement to:
  *           1) write obs to multiple datasets in one DATA step.  
  *           2) create 2 or more SAS obs from ea line of input data.  
  *           3) write obs to a SAS dataset without any input data.
  * 
  *           Don't do this:
  *           DATA FOO EXXON; ...
  *             IF BRAND='EXXON' THEN OUTPUT EXXON;
  *             OUTPUT; ...
  *           both ds get all obs plus EXXON gets doubled obs
  *
  *  Created: Fri 16 May 2003 08:33:57 (Bob Heckel)
  * Modified: Tue 11 Jun 2013 15:28:12 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

 /* Add a record to dataset */
data tmp;
  set SASHELP.shoes(obs=10) end=e;
  if e then do;
    output;        /* original obs */
    region='foo';  /* new obs 1 (with new region) */
    output;
    region='bar';  /* new obs 2 (with new region) */
    output;
  end;
  else
    output;  /* if you mess with your own OUTPUTs you then need one here */
run;
proc print data=_LAST_; run;



 /* Duplicate a row */
data tmp;
  set SASHELP.shoes(obs=10);
  if _N_ eq 4 then
    output;

  output;  /* you then need one here, no longer implicit */
run;
proc print data=_LAST_; run;



 /* Duplicate specific product types */
data boot slip all;
  set SASHELP.shoes;

  if Product eq: 'Boo' then
    output boot;
  else if Product eq: 'Slip' then
    output slip;

  output;  /* defaults output to all 3 ds */
run;
title 'boot:';
proc print data=boot(obs=10); run;
title 'slip:';
***proc print data=slip(obs=10); run;
***title 'all:';
***proc print data=all(obs=10); run;


data lelimsgist03e; 
  set lelimsgist03e; 
  if Meth_Spec_Nm=:'ATM02047' and Summary_Meth_Stage_Nm eq 'MASS' then do;
    output;  /* orig */
    Meth_Var_Nm='WEIGHTSTBL';Summary_Meth_Stage_Nm='SUSPENSION'; output;  /* new */
    Meth_Var_Nm='WEIGHTSTBL';Summary_Meth_Stage_Nm='CANWALL'; output;  /* new */
    Meth_Var_Nm='WEIGHTSTBL';Summary_Meth_Stage_Nm='VALVE'; output;  /* new */
  end;
  else output;
run;



data tmp;
  set SASHELP.shoes;
  x+1;
  if _n_ < 4 then
    output;
  put 'reached but no data written to dataset tmp' x=;
run;
proc print data=_LAST_(obs=max); run;


 /* i keeps going past 5! */
data loop1;
  foo = 0;
  do i = 1 to 5  by  2;
    foo = i;
  end;
run;
proc print; run;


data loop2;
  foo = 0;
  do i = 1 to 5  by  2;
    foo = i;
    output;
    put "in loop " i=;
  end;
    put "after loop " i=;
run;
proc print; run;



data work.demo1 work.demo2 work.demo3;
  /* OK to have multiple delimiters, e.g. comma AND colon delimited input. */
  infile cards DLM=',:' MISSOVER;
  input namea $  nameb $  var1-var4  mydt yymmdd8.;

  select (var4);
    when (11) output work.demo1;
    when (13) output work.demo2;
    otherwise output work.demo3;
  end;

  cards;
one, aaa,3,6,9,11,19981012
two,  bbb,10,12,14,11,600102
three,ccc,15,17:19,11,981012
three,ccc,15,17,19,11,981012
three,xcc:15,17,19,11,981012
four,ddd,21,24,28,12,981012
five,ddd:32,33,34,12,981012
five,ddd,32,33,34,13,981212
  ;
run;

proc print data=work.demo1; 
  title 'work.demo1'; 
  * Avoid the default 'days since the epoch' format;
  format mydt yymmdd8.; 
run;
proc print data=work.demo2; title 'work.demo2'; run;
proc print data=work.demo3; title 'work.demo3'; run;



endsas;
 /* Break out NC's single dataset into 3 datasets by month */
data nc0507 nc0508 nc0509;
  set L.NC050709;
  if phfrsrdt le '31JUL2005:00:00:00'dt then 
    output nc0507;
  else if (phfrsrdt ge '01AUG2005:00:00:00'dt) and (phfrsrdt le '31AUG2005:00:00:00'dt) then 
    output nc0508;
  else if phfrsrdt ge '01SEP2005:00:00:00'dt then
    output nc0509;
run;



endsas;
data work.regular work.exception work.allofthem;
  infile cards;
  ***input x1-x3 F4.;
  input x1-x3  @10 dummych $5.;

  if x2 = '' then 
    output work.exception;

  if x2 ^= '' then 
    output work.regular;

  /* Output regardless of the previous 2 OUTPUTs. */
  output work.allofthem;

  /* Second card word starts with a tab. */
  cards;
1 2  3   aord1
10 20 30 	ord2
99 .  88 word3
21 22 23 word4
  ;
run;

title 'regular';
proc print data=work.regular; run;
title 'exception';
proc print data=work.exception; run;
title 'all 4';
proc print data=work.allofthem; 
  format dummych $HEX.;
run;
