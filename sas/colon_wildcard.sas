options nosource;
 /*---------------------------------------------------------------------------
  *     Name: colon_wildcard.sas
  *
  *  Summary: Use the colon operator modifier to specify several variables.
  *
  *           Use EQT, GTT, LTT, GET, LET, NET in proc sql.
  *
  *           Complicated example:
  *      if '010'<=: zip_code <=:'0131' or zip_code in:('0133','0134','0138');
  *
  *  Adapted: Fri 21 Feb 2003 17:17:33 (Bob Heckel -- SAS Tips & Techniques
  *                                     Phil Mason)
  * Modified: Wed 23 Jun 2010 12:38:19 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

 /* Only works on the end of the variable to wildcard suffixes.  See print.sas
  * for a proc sql method using LIKE to wildcard either prefix or suffix.
  */
data work.tmp;
  length avar avarother dropme $6;

  avar='00001';
  avarother='';
  dropme='';
  output;

  avar='00002';
  avarother='';
  dropme='';
  output;

  avar='10';
  avarother='';
  dropme='';
  output;

  avar='100';
  avarother='';
  dropme='';
  output;

  avar='';
  avarother='foo';
  dropme='';
  output;

  avar='';
  avarother='';
  dropme='ok';
  output;
run;
proc print; run;

data work.tmp (keep= avar:);
  set work.tmp;
  ***if avar eq: '10';
  if avar in:('10','0');
run;
proc print; run;

