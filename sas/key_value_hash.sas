options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: key_value_hash.sas
  *
  *  Summary: Poor-man's associative array a.k.a. Perl hash implemented via
  *           informats.
  *
  *  Created: Thu 13 May 2010 09:44:55 (Bob Heckel)
  * Modified: Mon 14 Oct 2013 13:46:28 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

proc format;
  invalue $hash 'bqh0' = 'bob'
                'bhb6' = 'brenda'
                'vpm1' = 'van'
                OTHER = .
                ;
run;

data _NULL_;
  userid_key = 'bqh0';
  passwd_val = input(userid_key, $hash.);

  put userid_key= passwd_val=;
run;



endsas;
 /* More complicated, data-driven example: */
proc contents data=SASHELP.shoes out=t(keep= name type) NOprint; run;

data t(drop=type);
  set t;
  chartype = put(type, F8.);
run;
proc contents; run;

data ctrl(rename=(name=START chartype=LABEL));
  set t;
  retain fmtname '$myhash';
run;
proc print data=_LAST_(obs=max) width=minimum; run;


 /* Use the dataset to build the temporary format */
proc format library=work cntlin=ctrl; run;

 /* Print it for debug */
proc format library=work FMTLIB;

data _null_;
  mykey = 'Region';
  myval = put(mykey, $myhash.);
  put _all_;
run;


endsas;
proc format;
  invalue $hash 'bqh0' = 'bob0'
                'bhb6' = 'brenda6'
                'vpm1' = 'van1'
                OTHER = .
                ;
run;
proc format library=work FMTLIB;

data _NULL_;
  userid_key = 'bqh0';
  passwd_val = input(userid_key, $hash.);

  put userid_key= passwd_val=;
run;



endsas;
 /* Key-value pairs */
data dummy;
  length meth $40;
  input id  meth $;
  cards;
188400 WEIGHTPERMETEREDDOSE
288400 xEIGHTPERMETEREDDOSE
  ;
run;

data _null_;
  set dummy end=e;
  call symput('KEY'||compress(put(_N_,5.)), trim(left(compress(id))));
  call symput('VAL'||compress(put(_N_,5.)), trim(left(compress(meth))));
  if e then call symput('NOBS', _N_);
run;

%macro loop;
  %local i k v;

  %do i=1 %to &NOBS;
    %let k=&&KEY&i; 
    %let v=&&VAL&i; 
    data l.foo;
      set l.lelimsindres01a(/*debug*/where=(samp_id=188400));
      if proccancelflag ne '1' then delete;
      if samp_id eq &k and specname ne: "&v" then delete;
    run;
  %end;
%mend;
%loop;

%put _all_;



endsas;
 /* In Macro: */
let s=wi 01;
%let key=%upcase(%scan(&s, 1, ' '));
%let val=%upcase(%scan(&s, 2, ' '));
