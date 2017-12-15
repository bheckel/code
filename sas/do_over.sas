options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: do_over.sas
  *
  *  Summary: Loop over and modify each observation's variables without 
  *           worrying about counting array elements and subscripts
  *
  *  Created: Mon 17 May 2010 14:52:14 (Bob Heckel)
  * Modified: Tue 12 Apr 2016 15:47:59 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data t;
  input var_1 var_2 var_3 var_4 charvar_1 $;
  cards;
1 -100 5 99 abc
 -2 200 6 999 def
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

title 'add 1 to each variable var_N';
data t;
  set t;
  /* Most flexible */
  array arr var_:;
  /* Limit the range */
/***  array arr var_1-var_3;***/
  do over arr;
    arr+1;
  end;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
