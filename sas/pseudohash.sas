options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: pseudohash.sas
  *
  *  Summary: Poor-man's associative array a.k.a. Perl hash implemented via
  *           informats and macro.
  *
  *  Created: Mon 12 May 2003 13:12:22 (Bob Heckel)
  * Modified: Mon 09 Nov 2015 09:28:39 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

proc format;
  invalue $hash 'bqh0' = 'bob0'
                'bhb6' = 'brenda6'
                'vpm1' = 'van1'
                OTHER = .
                ;
run;

data _NULL_;
  userid_key = 'bqh0';
  passwd_val = input(userid_key, $hash.);

  put userid_key= passwd_val=;
run;



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



 /* In Macro: */
let s=wi 01;
%let key=%upcase(%scan(&s, 1, ' '));
%let val=%upcase(%scan(&s, 2, ' '));
