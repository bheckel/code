options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: ifn.sas
  *
  *  Summary: Demo of v9.1.3 if function ifn()
  *
  *  Created: Thu 21 Apr 2005 09:41:16 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* The optional missing clause doesn't seem to work, not shown here */
data _null_;
  x = 67;
  y = ifn(x eq 66, x, 99);

  file PRINT;
  put y=;
run;

 /* same */

data _null_;
  x = 67;
  if x eq 66 then
    y = x;
  else
    y = 99;

  file PRINT;
  put y=;
run;


