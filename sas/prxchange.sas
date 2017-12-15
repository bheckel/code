options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: prxchange.sas
  *
  *  Summary: Demo of Perl Regular Expressions regex
  *
  *           prxparse is not mandatory!!!!!!!!!!!!!
  *           E.g. remove surrounding parens:
  *                                            match max times
  *                                            __
  *             phone = prxchange('s/\(|\)//', -1, TMPphone);
  *
  *  Adapted: Wed 09 Jan 2013 10:20:27 (Bob Heckel--SESUG CT-03 Ken Borowiak)
  * Modified: Thu 31 Mar 2016 13:47:03 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

%macro m;
  /* Escape spaces in path for Linux cp */
  %let reportlocation=/foo bar/baz;
  %let reportlocationconverted=%sysfunc(prxchange(s/ /\\ /, -1, &reportlocation));
  %put &=reportlocationconverted;
%mend;
%m;



%macro m;
  %let RFDPATH=/Drugs/RFD/2016/02/AN-3097;
  /* AN-3097 */
  %let RFD=%sysfunc(prxchange(s/(.*)\/(.*)$/$2/, 1, &RFDPATH));
%mend;
%m;



data names;
   input name & $32.;
   datalines;
Ron Turley
Judy Donnelly
Kate Kavich
Tully Sanchez
;
data ReversedNames;
   input name & $32.;
   datalines;
Jones, Fred
Kavich, Kate
Turley, Ron
Dulix, Yolanda
;
proc sql;
  create table NewNames as
  select a.name from names as a, ReversedNames as b
  where a.name=prxchange('s/(\w+), (\w+)/$2 $1/', -1, b.name);
quit;
proc print data=NewNames;
run;



data t;
  x='hopko - 19'; output;
run;
data t;
  set t;
  rx=prxparse('s/(\w+) - (\d+)/$1/');
  rx2=prxparse('s/(\w+) - (\d+)/$2/');

  fname=prxchange(rx, -1, x);
  fnum=prxchange(rx2, -1, x);
run;
proc print data=_LAST_(obs=max) width=minimum; run;



data names;
  name='Jones, Fred'; output;
  name='Kavich, Kate'; output;
  name='Dulix, Yolanda'; output;
run;

  /* Reverse last and first names */
data ReversedNames;
  set names;
  name=prxchange('s/(\w+), (\w+)/$2 $1/', -1, name);
run;



proc sql outobs=5;
  select name,
         prxchange('s/[aeiou]//i', -1, name) as name2,
         compress(name, 'aeiou', 'i') as name3
  from SASHELP.class
  order by name2
  ;
quit;

proc sql outobs=5;
  select name,
         /* Remove vowels preceded by l, m or n (positive look-behind assertion) */
         /*            ___                                                       */
         prxchange('s/(?<=[lmn])[aeiou]//i', -1, name) as name2
         /* If used COMPRESS, we need a DO LOOP with SUBSTR (can't use proc sql) */
  from SASHELP.class
  order by name2
  ;
quit;


data SSN;
  input SSN $20.;
  datalines;
123-54-2280
#987-65-4321
S.S. 666-77-8888
246801357
soc # 133-77-2000
ssnum 888_22-7779
919-555-4689
call me 1800123456
  ;
run;
proc sql feedback;
  /* Maintain dashes and underscores in social security number dedaction */
  select ssn, prxchange('s/(?<!\d)\d{3}(-|_)?\d{2}(-|_)?\d{4}(?!\d)/xxx$1xx$2xxxx/io', -1 , ssn ) as ssn2
  from ssn
  ;
quit;

