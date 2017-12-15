options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: ck_value_of_several_vars.sas
  *
  *  Summary: Check for zeros in several vars.
  *
  *  Created: Mon 25 Apr 2005 15:35:32 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;


data t;
  input nm $ yr1 dontcare yr2 yr3 yr4;
  cards;
A 1 0 2 3 4
b 0 9 0 0 0
C 1 9 2 3 4
d 0 0 0 0 0
E 0 0 0 0 1
  ;
run;

data u;
  set t;
  if yr0--yr4 eq 0 then 
    delete;
run;
proc print data=_LAST_(obs=max); run;


 /* Don't think this is necessary. */
data v;
  set t;
  cntzero=0;
  numv=0;
  do v=yr1, yr2, yr3, yr4;
    numv+1;
    if v eq 0 then 
      cntzero+1;
  end;
  if cntzero eq numv then delete;
run;
proc print data=_LAST_(obs=max); run;
