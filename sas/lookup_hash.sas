options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: lookup_hash.sas
  *
  *  Summary: Using a v9 hash, if two vars match another ds then update a var
  *           to 'match'
  *
  *  Created: Thu 11 Aug 2005 11:47:34 (Bob Heckel)
  * Modified: Wed 14 Jan 2009 13:58:56 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data lookuphere;
  input a b c $;
  cards;
10 20 unk
30 40 unk
50 60 unk
  ;
run;

data incoming;
  input a b c $;
  cards;
10 20 unk
30 40 unk
70 80 unk
90 99 unk
  ;
run;

data incoming;
  set incoming;

  if _N_ eq 1 then
    do;
      declare hash h_looka(dataset:'WORK.lookuphere');
      h_looka.definekey('a');
      h_looka.definedata('a');
      h_looka.definedone();

      declare hash h_lookb(dataset:'WORK.lookuphere');
      h_lookb.definekey('b');
      h_lookb.definedata('b');
      h_lookb.definedone();
    end;

  if not (h_looka.check()) or not (h_lookb.check()) then
    c = 'match';
run;
proc print data=incoming(obs=max); run;



 /* Better? merge alternative from NESUG pm16 */
data both(drop=rc);
  length member_id $ 12 admit_dt discharge_dt 8;
  declare associativearray hh ();
  rc = hh.DefineKey ('member_id');
  rc = hh.DefineData ('admit_dt','discharge_dt');
  rc = hh.DefineDone ();
  do until (eof1) ;
    set libc.admissions end = eof1;
    rc = hh.add ();
  end;
  do until (eof2) ;
    set liba.members end = eof2;
    rc = hh.find ();
    if rc = 0 then output;
  end;
  stop;
run;
 /* Hash tables are as fast as formats, and they allow joins between datasets
  * where you want to keep multiple data fields from both datasets. They do not
  * require that either dataset be sorted.  They take advantage of memory,
  * which is often abundant but not unlimited. Since hash tables must fit into
  * existing memory, huge joins may not work using the hash technique.  In this
  * version of the hash technique above only member_ids found on both datasets
  * will be kept in the dataset BOTH. All records from the members table can be
  * kept if desired, but the use of hash tables exhibited above does not easily
  * keep records from admissions that are not found on members (in other words,
  * it is not set up for outer joins).
  */



 /* Best? from SUGI 037-2008 Hash Crash and Beyond */
data match ;
  set small point = _n_ ; * get key/data attributes for parameter type matching ;
  * set small (obs = 1) ; * this will work, too :-)! ;
  * if 0 then set small ; * and so will this :-)! ;
  * set small (obs = 0) ; * but for some reason, this will not :-( ;
  dcl hash hh (dataset: 'work.small', hashexp: 10) ;  /* max 16 */
  hh.DefineKey ( 'key' ) ;
  hh.DefineData ( 's_sat' ) ;
  hh.DefineDone () ;
  do until ( eof2 ) ;
    set large end = eof2 ;
    if hh.find () eq 0 then output ;
  end ;
  stop ;
run ;
