options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: lookup_sql.sas
  *
  *  Summary: Avoid "WARNING: Variable price already exists on file WORK.COMBINE"
  *           - see final two steps - if the p2 alias and the datastep aren't 
  *           used, we get the warning.  But apparently a good value ISN'T
  *           overwritten by a missing one though if there's a collision and
  *           that warning spews to Log.
  *
  *  Created: Thu 08 May 2008 16:12:53 (Bob Heckel)
  * Modified: Tue 10 Nov 2009 11:12:17 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /****************************************************************/
data master;
   input item $ price;
   format price dollar5.2;
   datalines;
apple  1.99
grapes 2.46
mango .
orange 6.19
  ;
run;
title 'master';proc print data=_LAST_(obs=max) width=minimum; run;

data trans;
   input item $ price;
   format price dollar5.2;
   datalines;
banana 1.05
grapes 2.99
mango 1.12
orange   .
  ;
run;
title 'trans';proc print data=_LAST_(obs=max) width=minimum; run;
 /****************************************************************/


proc sql;
  create table combine(drop=price rename=(_TEMA001=price)) as
  select m.*, coalesce(t.price, m.price)
  from master m LEFT JOIN trans t ON m.item=t.item
  ;
quit;
 /* We care about all changes to existing master fruit - we find that grapes went up in price and that mango now has a price */
title "overwrite/update master with trans price only where trans has data";proc print data=_LAST_(obs=max) width=minimum; run;

 /* Same */
proc sql;
  update master m
  set price = coalesce( (SELECT DISTINCT t.price
                         FROM trans t
                         WHERE m.price=t.price), m.price )
  ;
quit;
title "BETTER?-overwrite/update master with trans price only where trans has data";proc print data=_LAST_(obs=max) width=minimum; run;


 /* This is better defined as a careful update rather than a lookup: */
 /* TODO can do in single step?? */
proc sql;
  create table combine as
  select m.*, t.price as p2
  from master m LEFT JOIN trans t ON m.item=t.item
  ;
quit;
title 'temp tbl';proc print data=_LAST_(obs=max) width=minimum; run;
data combine(drop=p2);
  set combine;
  if price eq . then
    price = p2;
run;
 /* We are only interested in mango lookup because we don't have a mango price in master - ignore all other fruit changes */
title "do NOT overwrite master with trans price unless master has no price";proc print data=_LAST_(obs=max) width=minimum; run;
