options NOcenter ls=max ps=max;

 /* Manual cp 30 days of D:\logfiles\W3SVC1 then cat *.log >junk */

data links dp;
  infile 'junk' DSD DLM=' ';
  /* 2013-06-19 13:03:43 W3SVC1 RTPSAWN323 10.139.9.219 GET /datapost/data/GSties_123W79.png - 443 WMSERVICE\ksb28014 143.193.13.158 HTTP/1.1 Mozilla/4.0 zdatapost.gsk.com 200 0 6407 1171 31 */
  input a :$50. b :$50. c :$50. d :$50. e :$50. f :$50. g :$50. h :$200. i :$50. j :$50.;

  if a ne: '#';

  dt = input(a, YYMMDD10.);

  drop a b c d e f i;

  if index(g, 'sasweb') and index(h, 'UID=') then do;
    uid = substr(scan(h, 4, '&'), 5);
    output links;
  end;
  else if index(g, 'datapost') and j ne '-' then do;
    uid = scan(j, 2, '\');
    output dp;
  end;
run;
/***proc contents;run;endsas;***/
proc print data=links(obs=5) width=minimum; run;
proc print data=dp(obs=5) width=minimum; run;

proc sql;
  title 'DEBUG LINKS unique visitors';
  select count(distinct uid)
  from links
  ;
  title 'DEBUG LINKS detail';
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
  select count(distinct uid), min(dt), max(dt) into :IGNORE, :MINDT, :MAXDT
  from dp
  ;
  title 'DEBUG DP detail';
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
  set linksplot(in=ina) dpplot(in=inb);
  if ina then source = 'links';
  else source = 'dp';
run;

goptions reset=all ftext=swissl device=png cback=white border htitle=12pt ctext=gray gsfname=outpng gsfmode=replace xpixels=750 ypixels=750;
filename outpng 'junk.png';
proc gplot data=bothplot;
  title 'Datapost and LINKS - each dot is an identifiable visitor for that day';
  symbol v=dot c=vibg h=0.4;
  axis1 order=(&MINDT to &MAXDT) label=none;
  axis2 logbase=10 logstyle=expand label=(angle=90 "Webserver requests for user");
  plot cuid*dt=source / haxis=axis1 vaxis=axis2;
  where uid not in('rsh86800','dmh74758');
  footnote f=simplex j=l h=0.7 "&SYSDATE";
run;
%put _all_;
