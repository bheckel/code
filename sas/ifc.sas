options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: ifc.sas
  *
  *  Summary: Demo of v9.1.3 ifc()
  *
  *  Created: Thu 21 Apr 2005 09:41:16 (Bob Heckel)
  * Modified: Mon 15 Aug 2016 14:31:13 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* The optional missing clause doesn't seem to work, not shown here */
data t;
  length y $11;
  ***x= 'no';
  x= 'yes';
  y = ifc(x eq 'no', 'x is no', 'x is not no');

  file PRINT;
  put y=;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;

 /* y length is 200 if not specified */
proc contents;run;
