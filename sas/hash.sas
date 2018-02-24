options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: hash.sas (see also perlregex.hash.sas)  see also lookup_hash.sas
  *
  *  Summary: v9 hash tables
  *
  * data subset; if _N_=1 then do; declare hash h(dataset:'small'); h.defineKey('id'); h.defineDone(); end; set large; if h.find() = 0 then output; run;
  *
  *           https://support.sas.com/rnd/base/datastep/dot/hash-tip-sheet.pdf
  *
  *  See http://support.sas.com/resources/papers/proceedings14/1482-2014.pdf
  *  for more complicated options
  *
  *           Error if find() used instead of e.g. h.find()
  *
  *  Adapted: Fri 30 Jan 2004 18:10:38 (Bob Heckel)
  * Modified: Thu 01 Feb 2018 11:47:36 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;


 /* Lookup */
data largefile;
  infile cards;
  input drug_code $;
  cards;
k1
k3
k5
k7
k3
  ;
run;

 /* We only care about data in largefile that relates to the drug codes we have here */
data smallfile;
  infile cards;
  input drug_code $ price name $;
  cards;
k66 10 lexapro
k3 100 advair
  ;
run;

data subset;
  if _N_=1 then do;
    set smallfile;
    declare hash h(dataset:'smallfile', multidata:'y');
    h.defineKey('drug_code'); 
    h.definedata("price","name"); 
    h.defineDone();
  end;
  set largefile; if h.find() = 0 then output;
run;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;
endsas;




 /* SESUGI 2015 Dorfman duplicate key hashes */
 %macro bobh0911151455; /* {{{ */
data multi;
  input K D;
  cards;
1 11
2 21
2 22
3 31
3 32
3 33
  ;
run;
title "ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H; run;title;

data _null_;
  if 0 then set multi (keep = K D);
  dcl hash h(dataset:"multi", ordered:"A");
  h.definekey("K");
  h.definedata("D");
  h.definedone();
  h.output(dataset: "H");
  stop;
run;
title "fail ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H; run;title;

 /* Print hash */
data _null_;
  if 0 then set multi (keep = K D);
  dcl hash h(dataset:"multi", ordered:"A", multidata:"Y");
  h.definekey("K");
  h.definedata("D");
  h.definedone();
  h.output(dataset:"H");
  stop;
run;
title "ok but why no K var? ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H; run;title;

  /* Print hash - better */
data _null_;
  dcl hash h(ordered:"A", multidata:"Y");
  h.definekey("K");
  h.definedata("K","D");
  h.definedone();

  do until (end);
    set multi end=end;
    h.add();
  end;

  h.output(dataset:"H");
run;
title "works ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H; run;title;
 %mend bobh0911151455; /* }}} */



data a;
  input key adata;
  cards;
1 1
2 2
3 3
4 4
5 5
6 6
7 7
  ;
run;
title "ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H NOobs; run;title;
data b;
  input key bdata;
  cards;
1 11
1 12
3 31
4 4
6 61
6 62
6 63
7 701
  ;
run;
title "ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H NOobs; run;title;

 /* Equi join using hash */
data c;
  if _n_ = 1 then do;
    if 0 then set b;
    dcl hash b(dataset: "b", multidata: "y");
    b.definekey("key");
    b.definedata("bdata");
    b.definedone();
  end;
  set a;
  /* Returning a 0 indicates a match.  _iorc_ is used to avoid having to DROP anything */
  do _iorc_ = b.find() by 0 while (_iorc_ = 0);
    /* We found something */
    output;
    _iorc_ = b.find_next();  /* always works in tandem with h.find() */
    /* If _iorc_ here is 0 i.e. success then there exists another entry with the same key value, and program control is now pointing at this entry */
  end;
  /* If we reach, there are no more entries with the same key, and the pointer has moved past the last entry with this key value. Stop. Next obs in A. */
run;
title "The non-matching KEY=2 and KEY=5 from ds A are absent from the output - exactly what is expected from an equijoin ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H NOobs; run;title;


 /* Left join */
data c;
  if _n_ = 1 then do;
    if 0 then set b;
    dcl hash b(dataset: "b", multidata: "y");
    b.definekey("key");
    b.definedata("bdata");
    b.definedone();
  end;
  set a;  /* larger left ds */
  _iorc_ = b.find();
  /* If call missing were omitted, it would result in incorrect output because BDATA is auto-retained because of the SET B statement */
  if _iorc_ ne 0 then call missing(bdata);
  output;
  do while (b.find_next() = 0);
    output;
  end;
run;
title "Left join ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H NOobs; run;title;


 /* Full join using hash - we now need: (1) all records from A with BDATA
  * missing where there is no match in B and (2) all records from B with ADATA
  * missing where there is no match in A
  */
data aa;
  input key adata;
  cards;
1 1
2 2
3 3
4 4
5 5
6 6
7 7
  ;
run;
title "ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H NOobs; run;title;
data bb;
  input key bdata;
  cards;
1 11
1 12
1.5 1.51
3 31
4 4
6 61
6 62
6 63
6.5 6.51
6.5 6.52
7 701
  ;
run;
title "ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H NOobs; run;title;

data c;
  if _n_ = 1 then do;
    if 0 then set bb;

    dcl hash b(dataset: "bb", multidata: "y");
    b.definekey("key");
    b.definedata("key","bdata");
    b.definedone();

    dcl hash x();
    x.definekey("key");
    x.definedone();

    dcl hiter ib("B");
  end;
  
  do until (eof);
    set aa end=eof;
    x.replace();
    if b.find() ne 0 then call missing(bdata);
    output;
    do while (b.find_next() = 0);
      output;
    end;
  end;

/***  call missing(adata);***/
  /* Safer */
  call missing(of _ALL_);

  /* After the left join is complete, go through hash B (already containing the data from file B) one entry at a time */
  do while (ib.next() = 0);
    if x.check() ne 0 then output;
  end;
  stop;
run;
title "Full join ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H NOobs; run;title;



endsas;
 /* Demo #1 -- load a small dataset into a hash then use that hash to retrieve data
  * from a large dataset which has the same key and data. 
  */

data small;
  input k v;
  cards;
1 100
3 300
9 999
  ;
run;
title "ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H NOobs; run;title;

data large;
  input k  v  other $;
  cards;
1 100 x
3 300 y
5 500 z
7 700 z
  ;
run;
title "ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H NOobs; run;title;

data match;
/***  length k v  8;***/

  if _N_ eq 1 then 
    do;
      /* Load SMALL data set into the hash object.  Experiment with adjusting
       * hashexp to increase performance.
       */
      declare hash h(dataset: "work.small", hashexp: 6);  /* max 20 */
      /* Define SMALL data set's variable K as key and V as value */
      h.defineKey('k');
      h.defineData('v');
      h.defineDone();
      /* Avoid uninitialized variable NOTES: */
/***      call missing(v);***/
    end;

  /* Use the SET statement to iterate over the LARGE data set using keys in
   * the LARGE data set to match keys in the hash object 
   */
  set large;

  rc = h.find();
  if rc eq 0 then do  /* success, found */
    x = catx('_', k, v);
    output;
  end;
  else do;
    put '!!!no match on large ' k=;
  end;
run;
title "ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H NOobs; run;title;

 /* Compare */
proc sql;
  create table sqlmatch as
  select a.*, b.other, catx('_', a.k, b.v) as x
  from small a JOIN large b ON a.k=b.k
  ;
quit;
title "ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H NOobs; run;title;



endsas;
 /* Demo #2 -- store and retrieve data in hashes. */
data _NULL_;
  length first last titl  $16;
  length born died  8;

  if _N_ eq 1 then
    do;
      /* One-step declare and instantiate */
      ***declare Hash ht();
      /* Two-step (same) */
      declare Hash ht;
      ht = _NEW_ hash();

      ht.defineKey('first', 'last');
      ht.defineData('born', 'died', 'titl');
      ht.defineDone();
    end;

  infile cards eof=SEARCH;

  input first last born died titl & $16.;

  /* Load data into hash object */
  ***ht.add();
  /* Same as the verbose: */
  if ( ht.add(key:first, key:last, data:born, data:died, data:titl) ) then
    put 'ERROR: add failed';

  return;

SEARCH:
  /* Must use 2 keys in this example.  Single key examples work but it is more
   * useful to use SAS hashes if you need to find data based on 2 keys.
   */
  rc = ht.find(key: "John", key: "Keats");
  if rc eq 0 then do;
    put "!!! based on 2 keys, found value " titl $QUOTE.;
    /* Attributes don't have parens */
    is = ht.item_size;
    put "!!! item size " is;
    ni = ht.num_items;
    put "!!! number of items " ni;
  end;
 
  cards;
William Blake 1757 1827 Spring
John Keats    1795 1821 To Autumn
Mary Shelley  1797 1851 Frankenstein
  ;
run;
