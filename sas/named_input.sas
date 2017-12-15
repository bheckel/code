options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: named_input.sas
  *
  *  Summary: Demo of using the named input feature of the INPUT statement.
  *
  *  Created: Fri 10 Jul 2009 13:53:26 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data t;
  input var1= $ var2= $;

  /* DEBUG - display each line as it's read-in */
  put '!!!' _INFILE_;

  if index(_INFILE_, 'INI') then delete;

  cards;
INI data starts below
var1=foo
var1=bar
var2=baz
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
