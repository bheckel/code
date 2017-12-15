options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: hash_sumby.sas
  *
  *  Summary: Using hashes instead of proc sql for sum by group
  *
  *  Created: Tue 21 Nov 2017 08:26:19 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

data t;
  input id transid amt;
  cards;
1 11 100
1 12 100
3 31 300
4 4 400
4 40 400
4 41 400
6 61 600
6 61 600
6 63 600
7 70 700
  ;
run;
title "&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H NOobs; run;title;

data t2;
  length transid sum 8;

  if _n_ eq 1 then do;
    dcl hash ss(hashexp:3, ordered:'a');
    dcl hiter si('ss');
    ss.defineKey('sum');
    ss.defineData('sum','transid');
    ss.defineDone();
    call missing(of _all_);
  end;
ss.output(dataset:'debug');

  do until ( last.id );
    do sum=0 by 0 until ( last.transid );
      set t;
      by id transid;
      sum + amt;
    end;
    rc=ss.replace();
    output;
  end;
run;
title 'debug';proc print data=debug width=minimum heading=H;run;title;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;



title 'compare proc sql';
proc sql;
  select id, transid, sum(amt)
  from t 
  group by id, transid
  ;
quit;
