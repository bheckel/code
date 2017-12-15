options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: hash_inner_join.sas
  *
  *  Summary: Using hashes instead of proc sql for inner join
  *
  *           found=(rc=0);  '0' is success in hash-land!
  *
  *  Created: Tue 21 Nov 2017 08:26:19 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

data large;
  input key key2 adata adata2;
  cards;
1 11 11 101
1 111 12 102
3 33 31 301
4 99 4 401
4 44 4000 402
4 44 4001 403
6 66 61 601
6 66 62 602
6 99 63 603
7 77 701 701
  ;
run;
title "&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H NOobs; run;title;

 /* Won't work if we have duplicate keys */
data small;
  input key key2 bdata bdatamore;
  cards;
1 11 1 100
2 22 2 200
3 33 3 300
4 44 4 400
5 55 5 500
  ;
run;
title "&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H NOobs; run;title;

data innerjoin;
  if 0 then set small;  /* make hash out of smaller ds without needing LENGTH statement */
  dcl hash sh(dataset: 'small', multidata: 'y', hashexp:10);
  sh.definekey('key','key2');
  sh.definedata('bdata','bdatamore');
  sh.definedone();

  do until ( eof );
    set large end=eof;
    if sh.find() eq 0 then output;
  end;
  stop;
run;
data innerjoin; retain key key2 adata adata2 bdata bdatamore; set innerjoin; run;
title "Inner join &SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H NOobs; run;title;


title 'compare proc sql';
proc sql;
  select a.key, a.key2, adata, adata2, bdata, bdatamore
  from large a JOIN small b on a.key=b.key and a.key2=b.key2
  ;
quit;
