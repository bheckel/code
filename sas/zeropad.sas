options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: zeropad.sas
  *
  *  Summary: Convert numbers to a leading zero output format.
  *
  *  Created: Tue 10 Jun 2003 14:49:09 (Bob Heckel)
  * Modified: Mon 20 Jun 2016 08:58:43 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data sids;
  infile cards;
  input sid $30.;
  sid1=cats("'",compress(put(input(sid,4.),z4.)),"'");
  /* same */
  sid2=quote(compress(put(input(sid,4.),z4.)),"'");
  sid3=compress(put(input(sid,8.),z4.));
  cards;
10
1041
1216
1217
1219
1225
1238
1263
1284
1297
1298
14
    ;
run;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;



data _NULL_;
  do i=1 to 20;
    z = put(i, Z2.);
    put "padded with a leading zero: " z;
  end;
run;

 /* This will fail.  Must be numeric. */
data _NULL_;
  do i='1', '2', '3';
    z = put(i, Z2.);
    put "padded with a leading zero: " z;
  end;
run;
