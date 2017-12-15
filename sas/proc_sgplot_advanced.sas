
data runs/*(keep=date distance totalmiles)*/;
/***retain year ' ';***/
input d $ Distance @@;
if distance eq . then do; put _all_; year = '/' || d; return; end;
Date = input(trim(d) || year, mmddyy10.);
TotalMiles + distance;
if date ge '29apr2014'd - 364 then PastYear + distance;
call symputx('t', put(pastyear, 4.));
output;
datalines;
2013 . 1/1 7.6 1/3 7.6 1/5 10.4 1/7 7.6 1/9 7.6 1/13 10.4 1/24 7.6 1/28 10.4
1/30 7.6 2/1 7.6 2/3 12.2 2/5 7.6 2/10 7.6 2/12 8.2 2/14 8.2 2/16 13.1 2/19 8.2
2/21 8.2 2/24 10.4 2/26 7.6 2/28 8.2 3/2 13.65 3/4 8.2 3/6 8.2 3/8 13.9 3/10
10.4 3/12 8.2 3/14 8.2 3/16 8.2 3/17 5.2 3/19 8.2 3/21 8.2 3/23 8.2 3/27 8.2
3/28 5.2 3/30 14 4/1 5.2 4/3 8.2 4/5 5.2 4/6 10.4 4/8 8.2 4/10 8.2 4/11 5.2 4/13
10.4 4/15 8.2 4/17 5.2 4/20 8.2 4/22 8.2 4/24 8.2 4/26 8.2 4/27 3 4/28 4 4/29
4.25 4/30 5.2 5/1 4.1 5/2 4.1 5/4 8.2 5/6 5.2 5/7 8.2 5/9 5.2 5/11 10.4 5/13
4.35 5/14 4.25 5/15 4.25 5/22 5.2 5/25 10.4 5/27 10.4 5/29 10.4 5/31 14 6/2 10.4
6/4 10.4 6/6 10.4 6/8 10.4 6/9 10.4 6/11 10.4 6/15 8.2 6/19 5.2 6/23 10.4 6/25
8.2 6/26 5.2 6/28 15 6/30 11.2 7/2 3 7/3 8.2 7/5 8.2 7/6 8.2 7/7 8.2 7/9 8.2
7/10 8.2 7/12 16 7/15 8.2 7/16 8.2 7/17 5.2 7/19 14 7/20 8.2 7/22 8.2 7/23 5.2
7/24 10.4 7/26 8.2 7/28 4.1 7/29 6.3 7/30 10.4 7/31 8.2 8/3 11.9 8/4 4.5 8/5 5
8/6 6.1 8/7 4.2 8/9 5.2 8/10 4 8/11 12 8/13 5.2 8/16 5.2 8/17 10.4 8/18 8.2 8/19
5.2 8/20 5.2 8/21 8.2 8/23 5.4 8/27 5.2 8/28 5.2 8/29 3 9/1 5.2 9/3 5.2 9/4 8.2
9/5 10.4 9/6 5.2 9/7 5.2 9/8 8.9 9/9 7 9/12 5.2 9/14 18 9/17 5.2 9/18 10.4 9/19
5.2 9/20 6.75 9/21 10.4 9/23 8.2 9/24 8.2 9/27 8.2 9/28 20 10/2 5.2 10/3 8.2
10/4 5.2 10/5 14 10/8 9.8 10/10 10 10/11 5.2 10/13 20 10/15 8.2 10/16 5.2 10/17
8.2 10/22 21.3 10/24 8 10/25 5.2 10/26 14 10/30 5.2 10/31 5.2 11/1 5.2 11/2 10.4
11/5 3.1 11/7 3.1 11/9 27.36 11/11 5.2 11/12 5.2 11/13 5.2 11/15 14 11/16 8.2
11/17 5.2 11/18 5.2 11/20 10.4 11/21 5.24 11/24 10.4 11/25 8.2 11/26 5.2 11/28
10.4 12/2 5.2 12/3 8.2 12/4 10.4 12/5 5.2 12/6 10.4 12/7 10.4 12/8 5.2 12/9 8.3
12/11 10.5 12/12 8.2 12/13 5.3 12/14 10.4 12/15 8.2 12/16 5.2 12/17 5.3 12/18
10.4 12/19 8.4 12/20 5.2 12/22 8.2 12/23 8.2 12/24 8.2 12/25 8.2 12/26 8.2 12/27
8.2 12/28 5.2 12/30 14 12/31 5.2 2014 . 1/1 5.2 1/2 5.2 1/3 5.2 1/4 5.2 1/5
10.2 1/9 5.2 1/10 5.2 1/11 6.8 1/14 5.2 1/17 5.2 1/18 6.8 1/19 6.8 1/20 5.2 1/21
5.2 1/23 5.2 1/24 5.3 1/25 5.2 1/26 10.4 1/27 7.6 1/28 8.2 1/29 3.3 2/1 10.4 2/2
10.4 2/4 5.2 2/5 8.2 2/6 5.2 2/8 14 2/10 5.2 2/11 5.2 2/12 8.3 2/15 5.2 2/16 8.2
2/18 8.2 2/20 5.2 2/23 18.2 2/25 5.2 2/27 5.2 2/28 21 3/2 8.2 3/4 5.2 3/8 10.4
3/10 3.1 3/12 3.1 3/16 26.3 3/20 3.1 3/21 5.2 3/22 5.2 3/27 5.2 3/28 5.2 3/30 14
3/31 8.2 4/2 5.2 4/4 5.2 4/5 14 4/6 10.4 4/8 5.2 4/10 8.2 4/11 3 4/12 14 4/13
9.1 4/14 5.2 4/16 5.2 4/17 5.2 4/18 14 4/20 14 4/21 5.2 4/22 8.2 4/23 5.2 4/24
5.2 4/25 14 4/27 14 4/29 5.3
;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;

endsas;
data x(drop=i);
    do i = 1 to 10 by 3;
    x = i + uniform(104);
    y = 11 - x + uniform(104);
    x2 = i + 10 + uniform(104);
    y2 = x2 + uniform(104);
    x3 = i + uniform(104);
    y3 = 15.5 + uniform(104);
    x4 = 15.5 + uniform(104);
    y4 = x3 + uniform(104);
    output;
  end;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;

ods _all_ close;
ods graphics on;
ods printer printer=pngt file="~/bob/t.png";

proc sgplot noautolegend;
  title 'Four Groups of Observations';
  scatter y=y x=x / markerattrs=(symbol=diamondfilled);
  scatter y=y2 x=x2 / markerattrs=(symbol=circlefilled);
  scatter y=y3 x=x3 / markerattrs=(symbol=squarefilled);
  scatter y=y4 x=x4 / markerattrs=(symbol=trianglefilled);
run;

ods printer printer=pngt file="~/bob/t2.png";
proc sgplot noautolegend;
  title 'Two Groups of Observations with Droplines';
  scatter y=y x=x / markerattrs=(symbol=diamondfilled);
  scatter y=y2 x=x2 / markerattrs=(symbol=circlefilled);
  dropline y=y x=x / dropto=both lineattrs=graphdata1(pattern=3);
  dropline y=y2 x=x2 / dropto=both lineattrs=graphdata2(pattern=3);
run;

ods printer close;
ods listing;

