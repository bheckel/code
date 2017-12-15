options NOcenter ls=max ps=max;

%macro bobh2708133908; /* {{{ */
filename f 'flist.txt';
data fnames;
  infile f;
  input ls :$80.;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
%mend bobh2708133908; /* }}} */

/***filename q PIPE "ls -1 .";***/
filename p PIPE "dir /B .";
data fnames;
  infile p;
  input ls :$80.;
  /* SAS .log interferes so we need 2 conditions */
  if index(ls, 'ex'); * and index(ls, '.log');
  /* DEBUG */
/***  if index(ls, 'ex1208') and index(ls, '3');***/
/***  if index(ls, 'ex120830');***/
run;
/***proc print data=_LAST_(obs=max) width=minimum; run;***/

data alllogs;
  set fnames;
  infile TMP DELIMITER=' ' MISSOVER DSD LRECL=32767 FILEVAR=ls FILENAME=currinfile END=done;
  do while ( not done );
    input a :$50. b :$50. c :$50. d :$50. e :$50. f :$50. g :$50. h :$200. i :$50. j :$50.;
    output;
  end;
run;
/***proc print data=_LAST_(obs=max) width=minimum; run;***/

data links dp;
  set alllogs;

  if a ne: '#';

  dt = input(a, YYMMDD10.);

  drop a b c d e f i;

  if index(g, 'sasweb') and index(h, 'UID=') then do;
    uid = upcase(substr(scan(h, 4, '&'), 5));
    output links;
  end;
  else if index(g, 'datapost') and j ne '-' then do;
    uid = upcase(scan(j, 2, '\'));
    output dp;
  end;
run;
/***proc print data=alllogs(obs=max) width=minimum; run;***/

proc sql;
  title 'DEBUG LINKS unique visitors';
  select count(distinct uid)
  from links
  ;
  title 'DEBUG LINKS user detail';
  select uid format=$10., count(uid) as cuid
  from links
  group by uid
  order by cuid desc
  ;

  create table linksplot as
  select dt format=DATE., uid format=$10., count(uid) as cuid
  from links
  group by dt, uid
  ;

  title 'DEBUG DP unique visitors';                           /* also get X axis info */
/***  select count(distinct uid), min(dt), max(dt) into :IGNORE, :MINDT, :MAXDT***/
  select count(distinct uid)
  from dp
  ;
  title 'DEBUG DP user detail';
  select uid format=$10., count(uid) as cuid
  from dp
  group by uid
  order by cuid desc
  ;

  create table dpplot as
  select dt format=DATE., uid format=$10., count(uid) as cuid
  from dp
  group by dt, uid
  ;
quit;

data bothplot(keep= cuid dt uid source);
  retain _mindt _maxdt;
  format _mindt _maxdt DATE9.;
  set linksplot(in=ina) dpplot(in=inb) end=e;
  if ina then source = 'links';
  else source = 'dp';

  _mindt = min(of _mindt dt);
  _maxdt = max(of _maxdt dt);

  if e then do;
    call symput('MINDT', _mindt);
    put _mindt DATE9.;  /* DEBUG */
    /* To get data thru final month we have to go 30 days past it */
    _maxdt=_maxdt+30;
    call symput('MAXDT', _maxdt);
    put _maxdt DATE9.;  /* DEBUG */
  end;
run;
/***proc contents;run;***/
/***%put _all_;***/
/***proc print data=_LAST_(obs=max) width=minimum; run;***/


goptions reset=all ftext='Andale Mono' device=png cback=white htitle=15pt htext=0.9 ctext=black gsfname=outpng gsfmode=replace xpixels=750 ypixels=750;
filename outpng 'usage_DP_LINKS.png';
proc gplot data=bothplot;
/***  title ' ';***/
  title1 h=1.25 '
  12 Months DP & LINKS Usage';
  symbol1 value=dot c=vibg h=0.1;
  symbol2 value=x c=vibg h=1.0;
  axis1 order=(&MINDT to &MAXDT by month) label=none;
/***  axis1 order=(&MINDT to &MAXDT);***/
  axis2 logbase=10 logstyle=expand label=(angle=90 "Count of webserver requests by user");
  plot cuid*dt=source / haxis=axis1 vaxis=axis2 legend=legend1;

  where uid not in('rsh86800','dmh74758','sb50680');

  legend1 label=("Application") value=(j=left "Datapost" j=left "LINKS") cborder=gray;
  footnote f='Andale Mono' j=r h=0.8 "&SYSDATE";
run;
%put _all_;
proc print data=_LAST_(obs=max) width=minimum; run;
