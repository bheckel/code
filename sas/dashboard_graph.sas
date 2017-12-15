 /* from http://robslink.com/SAS/Home.htm 2007-10-19 */
 /* TODO not working 2009-03-11 */

%let name=royal;
filename odsout '.';

/* 
This is a sas imitation/enhancement of the dasbhoard at...
http://www.exceluser.com/dash/samples/db1_royaldutch.htm
*/

%let compname=Royal Dutch Petroleum Company;
%let greenish=cx3d7165;
%let ltgrnish=cxC8d4C8;
%let tanish=cxFDF5E6;
%let whiteish=cxF3F3F3;
%let darkgray=cx444444;
%let vrefgray=cx999999;
%let hrefgray=cxdddddd;


proc format;
   value time_fmt
   0='03'
   1='I'
   2='II'
   3='III'
   4='04'
   ;
run;

data mydata;
input time revenue gpm npm dps dpr roa roe sgr wc dsoiar dcii at tdte nocf nicf nfcf ncic fcf;
format time time_fmt.;
format gpm percentn7.1;
format npm percentn6.0;
format roa percentn6.0;
format roe percentn6.0;
format sgr percentn7.1;
datalines;
0 30 .220 .030 0.02 3.9 .072 .170 -.50 -7.0 41.0 29.0 1.20 1.310 13 -5.0 -7.5 0.25 -8.0 
1 34 .221 .080 0.02 0.0 .063 .155  .15 -3.5 47.0 24.5 1.19 1.275  5 -1.0 -2.0 2.25  2.5
2 38 .223 .064 0.90 1.0 .069 .170 -.05 -3.0 46.5 26.5 1.27 1.275  7 -2.5 -4.3 0.25 -2.5
3 42 .214 .080 0.90 1.6 .082 .190 -.10  0.0 48.2 26.6 1.31 1.255 11 -4.0 -7.0 0.35 -6.0
4 46 .    .000  .    .  .    .     .     .    .    .   .    .     .   .    .   .    2.5
;
run;

data mydata2;
input year soir ipm;
datalines;
2002  9.0 5.2
2003  8.0 7.5
2004 11.0 4.8
;
run;


data titlanno;
length function $8 style color $12;
length html $ 500 text $200;
xsys='3'; ysys='3'; hsys='3'; 
function='label'; position='6';
color="&darkgray"; style='"arial/bold"'; size=2.0;
x=1; y=89.4; text="Revenues, Earnings, & Dividends"; output;
x=40.5; y=71.4; text="Profitability"; output;
x=1; y=53.4; text="Balance Sheet"; output;
x=1; y=35.4; text="Cash Flow"; output;
x=1; y=17.4; text="Industry"; output;
x=41; y=17.4; text="Useful Facts"; output;
when='b'; 
function='move'; x=0; y=0; output;
function='bar'; x=100; y=91; color="&whiteish"; style='solid'; line=0; output;
when='a'; 
function='move'; x=0; y=0; output;
function='bar'; x=100; y=91; color="&darkgray"; style='empty'; line=0; size=.1; output;
function='move'; x=0; y=91; output;
function='bar'; x=100; y=93.5; color="&darkgray"; style='solid'; output;
function='label'; x=.5; y=93.5; position='3'; size=3; style='"arial/bold"'; color="&greenish";
html='title="'||"&compname"||'" href="http://www.google.com/search?hl=en&q='||"&compname"||'"';
 text="&compname"; output;
html='';
function='label'; x=99.5; y=94.0; position='1'; size=1.5; style='"arial/bold"'; color="&darkgray";
 text='December, 2004'; output;
function='label'; x=50; y=92.5; position='5'; size=1.5; style='"arial/bold"'; color="white";
html='title="'||"exceluser.com"||'" href="http://www.exceluser.com/dash/xstd2.htm"';
 text="SAS/Graph Imitation of Charley Kyd's ExcelUser Dashboard"; output;
/*
html='title="'||"sas.com"||'" href="http://www.sas.com"';
 text='sas.com dashboard'; output;
*/
run;

/* Annotate the tan & green colored areas behind the charts, and gray border around them */
data cbackanno;
length html $ 500;
xsys='3'; ysys='3'; hsys='3'; when='b';
function='move'; x=0; y=0; output;
function='bar'; x=100; y=90; color="&tanish"; style='solid'; line=0; output;
function='move'; x=0; y=90; output;
function='bar'; x=100; y=100; color="&greenish"; style='solid'; line=0; output;
function='move'; x=0; y=0; output;
function='bar'; x=100; y=90; color='gray'; style='empty'; line=0; output;
function='move'; x=0; y=90; output;
function='bar'; x=100; y=100; color='gray'; style='empty'; line=0; output;
run;

/* Cback for the table (no tanish area) */
data cbacktable;
length function $ 8;
length style $ 12;
xsys='3'; ysys='3'; hsys='3'; when='b';
function='move'; x=0; y=90; output;
function='bar'; x=100; y=100; color="&greenish"; style='solid'; line=0; output;
function='move'; x=0; y=0; output;
function='bar'; x=100; y=90; color='gray'; style='empty'; line=0; output;
function='move'; x=0; y=90; output;
function='bar'; x=100; y=100; color='gray'; style='empty'; line=0; output;
run;

/*
data mydata; set mydata;
length htmlvar $500;
htmlvar='title='||quote( 
 trim(left(description)) || ' :  ' || trim(left(revenue))  
)
||' '||
 'href="eis.htm"';
run;
*/


 GOPTIONS DEVICE=gif;
 
 ODS LISTING CLOSE;
 ODS HTML path=odsout body="&name..htm"
 (title="&compname")
 style=minimal
 gtitle gfootnote
 ;

goptions nodisplay;


goptions xpixels=800 ypixels=1200;
goptions gunit=pct htitle=3 ftitle="arial" htext=4 ftext="arial";
title " ";
proc gslide des="" name="titles" anno=titlanno;
run;



goptions xpixels=150 ypixels=185;
goptions gunit=pct ftitle="arial/bold" ftext="arial" htitle=10 htext=7 ctitle=&darkgray ctext=&darkgray;
goptions cback=white;

/* Custom annotated table at top/left of dashboard */

/* I'm hard-coding these macro variables for this proof-of-concept, but
   in real-life these macro variables would be calculated directly
   from data on-the-fly.  I'm not sure exactly what data and how
   these were calculated in the original dashboard I'm imitating,
   so I'm just hard-coding the values so they will be the same
   as the original.
*/
%let qtrrev=45,854;
%let ytdrev=160,837;
%let qtrcogs=0;
%let ytdcogs=89,803;
%let qtrgp=0;
%let ytdgp=25,180;
%let qtroi=0;
%let ytdoi=12,707;
%let qtroipos=0%;
%let ytdoipos=8%;
%let qtrnpm=2,687;
%let ytdnpm=10,986;
%let qtrnppos=6%;
%let ytdnppos=7%;


data plot1anno; 
length function $ 8;
length style $ 12;
length text $ 100;
xsys='3'; ysys='3'; hsys='3'; when='a';

color="&darkgray"; style="solid";
function='move';  x=2; y=76; output; function='bar'; x=54; y=86; output;
function='move'; x=56; y=76; output; function='bar'; x=76; y=86; output;
function='move'; x=78; y=76; output; function='bar'; x=98; y=86; output;

color="&ltgrnish"; style="solid";
function='move';  x=2; y=46; output; function='bar'; x=54; y=74; output;
function='move'; x=56; y=46; output; function='bar'; x=76; y=74; output;
function='move'; x=78; y=46; output; function='bar'; x=98; y=74; output;

function='move';  x=2; y=4; output; function='bar'; x=54; y=44; output;
function='move'; x=56; y=4; output; function='bar'; x=76; y=44; output;
function='move'; x=78; y=4; output; function='bar'; x=98; y=44; output;

color="&vrefgray"; size=.1; 
y=55;
function='move'; x=2; output; function='draw'; x=54; output;
function='move'; x=56; output; function='draw'; x=76; output;
function='move'; x=78; output; function='draw'; x=98; output;
y=24;
function='move'; x=2; output; function='draw'; x=54; output;
function='move'; x=56; output; function='draw'; x=76; output;
function='move'; x=78; output; function='draw'; x=98; output;

function='label';
size=8; style='"arial/bold"'; 
color="white";
y=83;
x=5; position='6'; text="(Millions of $)"; output;
x=75; position='4'; text="Qtr"; output;
x=97; position='4'; text="YTD"; output;
color="&darkgray";
y=y-11;
x=5; position='6'; text="Revenue"; output;
x=75; position='4'; text="&qtrrev"; output;
x=97; position='4'; text="&ytdrev"; output;
y=y-10;
x=5; position='6'; text="Cost of Goods Sold"; output;
x=75; position='4'; text="&qtrcogs"; output;
x=97; position='4'; text="&ytdcogs"; output;
y=y-10;
x=5; position='6'; text="Gross Profit"; output;
x=75; position='4'; text="&qtrgp"; output;
x=97; position='4'; text="&ytdgp"; output;
y=y-11;
x=5; position='6'; text="Operating Income"; output;
x=75; position='4'; text="&qtroi"; output;
x=97; position='4'; text="&ytdoi"; output;
y=y-10;
x=30; position='6'; text="% of Sales"; output;
x=75; position='4'; text="&qtroipos"; output;
x=97; position='4'; text="&ytdoipos"; output;
y=y-10;
x=5; position='6'; text="Net Profit Margin"; output;
x=75; position='4'; text="&qtrnpm"; output;
x=97; position='4'; text="&ytdnpm"; output;
y=y-10;
x=30; position='6'; text="% of Sales"; output;
x=75; position='4'; text="&qtrnppos"; output;
x=97; position='4'; text="&ytdnppos"; output;

run;

data plot1anno; set cbacktable plot1anno;
run;

title1 color=&whiteish "1";
footnote;
proc gslide des="" name="plot1" anno=plot1anno;
run;


symbol1 interpol=join color=black width=2 value=dot height=2.75;

axis2 color=&darkgray label=none minor=none offset=(10,10);

%let titlstr=Revenues;
data cbackanno; set cbackanno;
html='title="'||"&titlstr"||'" href="http://www.google.com/search?hl=en&q='||"&titlstr &compname"||'"';
run;

title1 color=&whiteish "2";
title2 h=8 ls=2.0 font="arial/bold" "&titlstr";
title3 a=90 h=3 " "; /* left */
title4 a=-90 h=3 " "; /* right */
footnote j=l "  Billions of $";
axis1 color=&darkgray label=none minor=none order=(0 to 50 by 10) offset=(0,0);
proc gplot data=mydata anno=cbackanno;
plot revenue*time=1 /
 vaxis=axis1 autovref cvref=&vrefgray
 haxis=axis2 autohref chref=&hrefgray
 cframe=&whiteish
 des="" name="plot2" ;
run;


%let titlstr=Gross Profit Margin;
data cbackanno; set cbackanno;
html='title="'||"&titlstr"||'" href="http://www.google.com/search?hl=en&q='||"&titlstr &compname"||'"';
run;

title1 color=&whiteish "3";
title2 h=8 ls=2.0 font="arial/bold" "&titlstr";
title3 a=90 h=3 " "; /* left */
title4 a=-90 h=3 " "; /* right */
footnote j=l "  % of Revenues";
axis1 color=&darkgray label=none minor=none order=(.205 to .225 by .005) offset=(0,0);
proc gplot data=mydata anno=cbackanno;
plot gpm*time=1 /
 vaxis=axis1 autovref cvref=&vrefgray
 haxis=axis2 autohref chref=&hrefgray
 cframe=&whiteish
 des="" name="plot3" ;
run;


%let titlstr=Net Profit Margin;
data cbackanno; set cbackanno;
html='title="'||"&titlstr"||'" href="http://www.google.com/search?hl=en&q='||"&titlstr &compname"||'"';
run;

title1 color=&whiteish "4";
title2 h=8 ls=2.0 font="arial/bold" "&titlstr";
title3 a=90 h=3 " "; /* left */
title4 a=-90 h=3 " "; /* right */
footnote j=l "  % of Revenues";
axis1 color=&darkgray label=none minor=none order=(0 to .1 by .02) offset=(0,0);
proc gplot data=mydata anno=cbackanno;
plot npm*time=1 /
 vaxis=axis1 autovref cvref=&vrefgray
 haxis=axis2 autohref chref=&hrefgray
 cframe=&whiteish
 des="" name="plot4" ;
run;


%let titlstr=Dividends Per Share;
data cbackanno; set cbackanno;
html='title="'||"&titlstr"||'" href="http://www.google.com/search?hl=en&q='||"&titlstr &compname"||'"';
run;

title1 color=&whiteish "5";
title2 h=8 ls=2.0 font="arial/bold" "&titlstr";
title3 a=90 h=3 " "; /* left */
title4 a=-90 h=3 " "; /* right */
footnote j=l "  Dollars per Share";
axis1 color=&darkgray label=none minor=none order=(0 to 1.0 by .2) offset=(0,0);
proc gplot data=mydata anno=cbackanno;
plot dps*time=1 /
 vaxis=axis1 autovref cvref=&vrefgray
 haxis=axis2 autohref chref=&hrefgray
 cframe=&whiteish
 des="" name="plot5" ;
run;


%let titlstr=Dividends Payout Ratio;
data cbackanno; set cbackanno;
html='title="'||"&titlstr"||'" href="http://www.google.com/search?hl=en&q='||"&titlstr &compname"||'"';
run;

title1 color=&whiteish "6";
title2 h=8 ls=2.0 font="arial/bold" "&titlstr";
title3 a=90 h=3 " "; /* left */
title4 a=-90 h=3 " "; /* right */
footnote j=l "  Dividends to Net Income";
axis1 color=&darkgray label=none minor=none order=(0 to 5 by 1) offset=(0,0);
proc gplot data=mydata anno=cbackanno;
plot dpr*time=1 /
 vaxis=axis1 autovref cvref=&vrefgray
 haxis=axis2 autohref chref=&hrefgray
 cframe=&whiteish
 des="" name="plot6" ;
run;


%let titlstr=Return on Assets;
data cbackanno; set cbackanno;
html='title="'||"&titlstr"||'" href="http://www.google.com/search?hl=en&q='||"&titlstr &compname"||'"';
run;

title1 color=&whiteish "7";
title2 h=8 ls=2.0 font="arial/bold" "&titlstr";
title3 a=90 h=3 " "; /* left */
title4 a=-90 h=3 " "; /* right */
footnote j=l "  (Uses 4-quarter average income)";
axis1 color=&darkgray label=none minor=none order=(0 to .1 by .02) offset=(0,0);
proc gplot data=mydata anno=cbackanno;
plot roa*time=1 /
 vaxis=axis1 autovref cvref=&vrefgray
 haxis=axis2 autohref chref=&hrefgray
 cframe=&whiteish
 des="" name="plot7" ;
run;


%let titlstr=Return on Equity;
data cbackanno; set cbackanno;
html='title="'||"&titlstr"||'" href="http://www.google.com/search?hl=en&q='||"&titlstr &compname"||'"';
run;

title1 color=&whiteish "8";
title2 h=8 ls=2.0 font="arial/bold" "&titlstr";
title3 a=90 h=3 " "; /* left */
title4 a=-90 h=3 " "; /* right */
footnote j=l "  (Uses 4-quarter average income)";
axis1 color=&darkgray label=none minor=none order=(0 to .2 by .05) offset=(0,0);
proc gplot data=mydata anno=cbackanno;
plot roe*time=1 /
 vaxis=axis1 autovref cvref=&vrefgray
 haxis=axis2 autohref chref=&hrefgray
 cframe=&whiteish
 des="" name="plot8" ;
run;


%let titlstr=Sustainable Growth Rate;
data cbackanno; set cbackanno;
html='title="'||"&titlstr"||'" href="http://www.google.com/search?hl=en&q='||"&titlstr &compname"||'"';
run;

title1 color=&whiteish "9";
title2 h=8 ls=2.0 font="arial/bold" "&titlstr";
title3 a=90 h=3 " "; /* left */
title4 a=-90 h=3 " "; /* right */
footnote j=l "  ";
axis1 color=&darkgray label=none minor=none order=(-.6 to .2 by .2) offset=(0,0);
proc gplot data=mydata anno=cbackanno;
plot sgr*time=1 /
 vaxis=axis1 autovref cvref=&vrefgray
 haxis=axis2 autohref chref=&hrefgray
 cframe=&whiteish
 des="" name="plot9" ;
run;


%let titlstr=Working Capital;
data cbackanno; set cbackanno;
html='title="'||"&titlstr"||'" href="http://www.google.com/search?hl=en&q='||"&titlstr &compname"||'"';
run;

title1 color=&whiteish "10";
title2 h=8 ls=2.0 font="arial/bold" "&titlstr";
title3 a=90 h=3 " "; /* left */
title4 a=-90 h=3 " "; /* right */
footnote j=l "  Billions of $";
axis1 color=&darkgray label=none minor=none order=(-8 to 0 by 2) offset=(0,0);
proc gplot data=mydata anno=cbackanno;
plot wc*time=1 /
 vaxis=axis1 autovref cvref=&vrefgray
 haxis=axis2 autohref chref=&hrefgray
 cframe=&whiteish
 des="" name="plot10" ;
run;


%let titlstr=Day Sales;
%let titlstr2=Outstanding in AR;
data cbackanno; set cbackanno;
html='title="'||"&titlstr &titlstr2"||'" href="http://www.google.com/search?hl=en&q='||"&titlstr &titlstr2 &compname"||'"';
run;

title1 color=&whiteish "11";
title2 h=8 font="arial/bold" "&titlstr";
title3 h=8 font="arial/bold" "&titlstr2";
title4 a=90 h=3 " "; /* left */
title5 a=-90 h=3 " "; /* right */
footnote j=l "  Days";
axis1 color=&darkgray label=none minor=none order=(38 to 50 by 2) offset=(0,0);
proc gplot data=mydata anno=cbackanno;
plot dsoiar*time=1 /
 vaxis=axis1 autovref cvref=&vrefgray
 haxis=axis2 autohref chref=&hrefgray
 cframe=&whiteish
 des="" name="plot11" ;
run;



%let titlstr=Days COGS in Inventory;
data cbackanno; set cbackanno;
html='title="'||"&titlstr"||'" href="http://www.google.com/search?hl=en&q='||"&titlstr &compname"||'"';
run;

title1 color=&whiteish "12";
title2 h=8 ls=2.0 font="arial/bold" "&titlstr";
title3 a=90 h=3 " "; /* left */
title4 a=-90 h=3 " "; /* right */
footnote j=l "  Days";
axis1 color=&darkgray label=none minor=none order=(22 to 30 by 2) offset=(0,0);
proc gplot data=mydata anno=cbackanno;
plot dcii*time=1 /
 vaxis=axis1 autovref cvref=&vrefgray
 haxis=axis2 autohref chref=&hrefgray
 cframe=&whiteish
 des="" name="plot12" ;
run;



%let titlstr=Assets Turnover;
data cbackanno; set cbackanno;
html='title="'||"&titlstr"||'" href="http://www.google.com/search?hl=en&q='||"&titlstr &compname"||'"';
run;

title1 color=&whiteish "13";
title2 h=8 ls=2.0 font="arial/bold" "&titlstr";
title3 a=90 h=3 " "; /* left */
title4 a=-90 h=3 " "; /* right */
footnote j=l "  Revenues to Assets";
axis1 color=&darkgray label=none minor=none order=(1.10 to 1.35 by .05) offset=(0,0);
proc gplot data=mydata anno=cbackanno;
plot at*time=1 /
 vaxis=axis1 autovref cvref=&vrefgray
 haxis=axis2 autohref chref=&hrefgray
 cframe=&whiteish
 des="" name="plot13" ;
run;



%let titlstr=Total Debt to Equity;
data cbackanno; set cbackanno;
html='title="'||"&titlstr"||'" href="http://www.google.com/search?hl=en&q='||"&titlstr &compname"||'"';
run;

title1 color=&whiteish "14";
title2 h=8 ls=2.0 font="arial/bold" "&titlstr";
title3 a=90 h=3 " "; /* left */
title4 a=-90 h=3 " "; /* right */
footnote j=l "  Times";
axis1 color=&darkgray label=none minor=none order=(1.22 to 1.32 by .02) offset=(0,0);
proc gplot data=mydata anno=cbackanno;
plot tdte*time=1 /
 vaxis=axis1 autovref cvref=&vrefgray
 haxis=axis2 autohref chref=&hrefgray
 cframe=&whiteish
 des="" name="plot14" ;
run;




%let titlstr=Net Operating Cash Flow;
data cbackanno; set cbackanno;
html='title="'||"&titlstr"||'" href="http://www.google.com/search?hl=en&q='||"&titlstr &compname"||'"';
run;

title1 color=&whiteish "15";
title2 h=8 ls=2.0 font="arial/bold" "&titlstr";
title3 a=90 h=3 " "; /* left */
title4 a=-90 h=3 " "; /* right */
footnote j=l "  Billions of $";
axis1 color=&darkgray label=none minor=none order=(0 to 15 by 5) offset=(0,0);
proc gplot data=mydata anno=cbackanno;
plot nocf*time=1 /
 vaxis=axis1 autovref cvref=&vrefgray
 haxis=axis2 autohref chref=&hrefgray
 cframe=&whiteish
 des="" name="plot15" ;
run;


%let titlstr=Net Investing Cash Flow;
data cbackanno; set cbackanno;
html='title="'||"&titlstr"||'" href="http://www.google.com/search?hl=en&q='||"&titlstr &compname"||'"';
run;

title1 color=&whiteish "16";
title2 h=8 ls=2.0 font="arial/bold" "&titlstr";
title3 a=90 h=3 " "; /* left */
title4 a=-90 h=3 " "; /* right */
footnote j=l "  Billions of $";
axis1 color=&darkgray label=none minor=none order=(-6 to 0 by 1) offset=(0,0);
proc gplot data=mydata anno=cbackanno;
plot nicf*time=1 /
 vaxis=axis1 autovref cvref=&vrefgray
 haxis=axis2 autohref chref=&hrefgray
 cframe=&whiteish
 des="" name="plot16" ;
run;


%let titlstr=Net Financing Cash Flow;
data cbackanno; set cbackanno;
html='title="'||"&titlstr"||'" href="http://www.google.com/search?hl=en&q='||"&titlstr &compname"||'"';
run;

title1 color=&whiteish "17";
title2 h=8 ls=2.0 font="arial/bold" "&titlstr";
title3 a=90 h=3 " "; /* left */
title4 a=-90 h=3 " "; /* right */
footnote j=l "  Billions of $";
axis1 color=&darkgray label=none minor=none order=(-8 to 0 by 2) offset=(0,0);
proc gplot data=mydata anno=cbackanno;
plot nfcf*time=1 /
 vaxis=axis1 autovref cvref=&vrefgray
 haxis=axis2 autohref chref=&hrefgray
 cframe=&whiteish
 des="" name="plot17" ;
run;


%let titlstr=Net Change in Cash Flow;
data cbackanno; set cbackanno;
html='title="'||"&titlstr"||'" href="http://www.google.com/search?hl=en&q='||"&titlstr &compname"||'"';
run;

title1 color=&whiteish "18";
title2 h=8 ls=2.0 font="arial/bold" "&titlstr";
title3 a=90 h=3 " "; /* left */
title4 a=-90 h=3 " "; /* right */
footnote j=l "  Billions of $";
axis1 color=&darkgray label=none minor=none order=(0 to 2.5 by .5) offset=(0,0);
proc gplot data=mydata anno=cbackanno;
plot ncic*time=1 /
 vaxis=axis1 autovref cvref=&vrefgray
 haxis=axis2 autohref chref=&hrefgray
 cframe=&whiteish
 des="" name="plot18" ;
run;


%let titlstr=Free Cash Flow;
data cbackanno; set cbackanno;
html='title="'||"&titlstr"||'" href="http://www.google.com/search?hl=en&q='||"&titlstr &compname"||'"';
run;

title1 color=&whiteish "19";
title2 h=8 ls=2.0 font="arial/bold" "&titlstr";
title3 a=90 h=3 " "; /* left */
title4 a=-90 h=3 " "; /* right */
footnote j=l "  Billions of $";
axis1 color=&darkgray label=none minor=none order=(-10 to 5 by 5) offset=(0,0);
proc gplot data=mydata anno=cbackanno;
plot fcf*time=1 /
 vaxis=axis1 autovref cvref=&vrefgray
 haxis=axis2 autohref chref=&hrefgray
 cframe=&whiteish
 des="" name="plot19" ;
run;


%let titlstr=Share of Industry;
%let titlstr2=Revenue;
data cbackanno; set cbackanno;
html='title="'||"&titlstr &titlstr2"||'" href="http://www.google.com/search?hl=en&q='||"&titlstr &titlstr2 &compname"||'"';
run;

title1 color=&whiteish "20";
title2 h=8 font="arial/bold" "&titlstr";
title3 h=8 font="arial/bold" "&titlstr2";
title4 a=90 h=3 " "; /* left */
title5 a=-90 h=3 " "; /* right */
footnote j=l "  % of Industry";
axis1 color=&darkgray label=none minor=none order=(0 to 15 by 5) offset=(0,0);
proc gplot data=mydata2 anno=cbackanno;
plot soir*year=1 /
 vaxis=axis1 autovref cvref=&vrefgray
 haxis=axis2 autohref chref=&hrefgray
 cframe=&whiteish
 des="" name="plot20" ;
run;


%let titlstr=Industry Profit Margin;
data cbackanno; set cbackanno;
html='title="'||"&titlstr"||'" href="http://www.google.com/search?hl=en&q='||"&titlstr &compname"||'"';
run;

title1 color=&whiteish "21";
title2 h=8 ls=2.0 font="arial/bold" "&titlstr";
title3 a=90 h=3 " "; /* left */
title4 a=-90 h=3 " "; /* right */
footnote j=l "  % of Sales";
axis1 color=&darkgray label=none minor=none order=(0 to 8 by 2) offset=(0,0);
proc gplot data=mydata2 anno=cbackanno;
plot ipm*year=1 /
 vaxis=axis1 autovref cvref=&vrefgray
 haxis=axis2 autohref chref=&hrefgray
 cframe=&whiteish
 des="" name="plot21" ;
run;



/* Annotated table at the bottom/right */

%let phone=+31-70-377-911;
%let fax=+31-70-377-3115;
%let tollfree=na;
%let address1=Carel van Bylandtlaan 30;
%let address2=, 2596 HR The Hague;
%let comp1=BP;
%let comp2=Exxon Mobil;
%let comp3=TOTAL;
%let website=www.shell.com;
%let symbol=RD [ADR] (NYSE);
%let quarter=December, 2004;
%let fyend=December, 2005;
%let industry=Oil & Gas Refining, Marketing & Distribution;

data plot22anno; 
length function $ 8;
length style $ 12;
length text $ 100;
length html $ 500;
xsys='3'; ysys='3'; hsys='3'; when='a';

color="&darkgray"; style="solid";
function='move';  x=2; y=76; output; function='bar'; x=49.5; y=86; output;
function='move';  x=50.5; y=56; output; function='bar'; x=65; y=86; output;
function='move';  x=2; y=44; output; function='bar'; x=49.5; y=54; output;
function='move';  x=50.5; y=16; output; function='bar'; x=65; y=54; output;
function='move';  x=2; y=2; output; function='bar'; x=15; y=14; output;
color="&ltgrnish"; style="solid";
function='move';  x=2; y=56; output; function='bar'; x=49.5; y=76; output;
function='move';  x=65; y=56; output; function='bar'; x=98; y=86; output;
function='move';  x=2; y=16; output; function='bar'; x=49.5; y=44; output;
function='move';  x=65; y=16; output; function='bar'; x=98; y=54; output;
function='move';  x=15; y=2; output; function='bar'; x=98; y=14; output;

function='label';
size=8; style='"arial/bold"'; 
color="white";
y=83; x=3; position='6'; text="Royal Dutch Petroleum Company"; output;
color="&darkgray";
html='title="'||"&address1"||'" href="http://www.google.com/search?hl=en&q='||"&address1 &address2"||'"';
y=y-11; x=3; position='6'; text="&address1"; output;
y=y-10; x=3; position='6'; text="&address2"; output;
html='title="'||"&comp1"||'" href="http://www.google.com/search?hl=en&q='||"&comp1"||' oil"';
y=40; x=3; position='6'; text="&comp1"; output;
html='title="'||"&comp2"||'" href="http://www.google.com/search?hl=en&q='||"&comp2"||' oil"';
y=y-9; x=3; position='6'; text="&comp2"; output;
html='title="'||"&comp3"||'" href="http://www.google.com/search?hl=en&q='||"&comp3"||' oil"';
y=y-9; x=3; position='6'; text="&comp3"; output;
html='title="'||"&website"||'" href="http://'||"&website"||'"';
y=51; x=66; position='6'; text="&website"; output;
html='title="'||"&symbol"||'" href="http://finance.yahoo.com/q?s=RD&d=t"';
y=y-9; x=66; position='6'; text="&symbol"; output;
html='';
y=y-9; x=66; position='6'; text="&quarter"; output;
y=y-9; x=66; position='6'; text="&fyend"; output;
y=10; x=16; position='6'; text="&industry"; output;
color="white";
y=83;   x=64; position='4'; text="Phone:"; output;
y=y-10; x=64; position='4'; text="Fax:"; output;
y=y-10; x=64; position='4'; text="Toll Free:"; output;
color="&darkgray";
y=83;   x=66; position='6'; text="&phone"; output;
y=y-10; x=66; position='6'; text="&fax"; output;
y=y-10; x=66; position='6'; text="&tollfree"; output;
color="white";
y=51; x=3; position='6'; text="Top Competitors"; output;
y=51;  x=64; position='4'; text="Web Site:"; output;
y=y-9; x=64; position='4'; text="Symbol:"; output;
y=y-9; x=64; position='4'; text="Quarter:"; output;
y=y-9; x=64; position='4'; text="FY Ends:"; output;
y=10; x=3; position='6'; text="Industry:"; output;



/*
function='label';
size=8; style='"arial/bold"'; 
color="white";
color="&darkgray";
y=y-11; x=3; position='6'; text="Carel van Bylandtlaan 30"; output;
y=y-10; x=3; position='6'; text=", 2596 HR The Hague"; output;
color="white";
y=43;   x=52; position='6'; text="Phone:"; output;
y=y-10; x=52; position='6'; text="Fax:"; output;
y=y-10; x=52; position='6'; text="Toll Free:"; output;
color="&darkgray";
y=43;   x=66; position='6'; text="+31-70-377-911"; output;
y=y-10; x=66; position='6'; text="+31-70-377-3115"; output;
y=y-10; x=66; position='6'; text="na"; output;
*/


run;

data plot22anno; set cbacktable plot22anno;
run;

title1 color=&whiteish "22";
footnote;
proc gslide des="" name="plot22" anno=plot22anno;
run;


goptions xpixels=800 ypixels=1200;
goptions display;
goptions noborder;

proc greplay tc=tempcat nofs igout=work.gseg;
  tdef rdpgrid des='Royal Dutch Petroleum'
   0/llx = 0   lly =  0
     ulx = 0   uly =100
     urx =100  ury =100
     lrx =100  lry =  0

   1/llx =1.0  lly = 73
     ulx =1.0  uly = 88
     urx =39.5 ury = 88
     lrx =39.5 lry = 73

   2/llx =40.5 lly = 73
     ulx =40.5 uly = 88
     urx =59.5 ury = 88
     lrx =59.5 lry = 73
   3/llx =60.5 lly = 73
     ulx =60.5 uly = 88
     urx =79.5 ury = 88
     lrx =79.5 lry = 73
   4/llx =80.5 lly = 73
     ulx =80.5 uly = 88
     urx =99.0 ury = 88
     lrx =99.0 lry = 73

   5/llx =1.0  lly = 55
     ulx =1.0  uly = 70
     urx =19.5 ury = 70
     lrx =19.5 lry = 55
   6/llx =20.5 lly = 55
     ulx =20.5 uly = 70
     urx =39.5 ury = 70
     lrx =39.5 lry = 55
   7/llx =40.5 lly = 55
     ulx =40.5 uly = 70
     urx =59.5 ury = 70
     lrx =59.5 lry = 55
   8/llx =60.5 lly = 55
     ulx =60.5 uly = 70
     urx =79.5 ury = 70
     lrx =79.5 lry = 55
   9/llx =80.5 lly = 55
     ulx =80.5 uly = 70
     urx =99.0 ury = 70
     lrx =99.0 lry = 55

  10/llx =1.0  lly = 37
     ulx =1.0  uly = 52
     urx =19.5 ury = 52
     lrx =19.5 lry = 37
  11/llx =20.5 lly = 37
     ulx =20.5 uly = 52
     urx =39.5 ury = 52
     lrx =39.5 lry = 37
  12/llx =40.5 lly = 37
     ulx =40.5 uly = 52
     urx =59.5 ury = 52
     lrx =59.5 lry = 37
  13/llx =60.5 lly = 37
     ulx =60.5 uly = 52
     urx =79.5 ury = 52
     lrx =79.5 lry = 37
  14/llx =80.5 lly = 37
     ulx =80.5 uly = 52
     urx =99.0 ury = 52
     lrx =99.0 lry = 37

  15/llx =1.0  lly = 19
     ulx =1.0  uly = 34
     urx =19.5 ury = 34
     lrx =19.5 lry = 19
  16/llx =20.5 lly = 19
     ulx =20.5 uly = 34
     urx =39.5 ury = 34
     lrx =39.5 lry = 19
  17/llx =40.5 lly = 19
     ulx =40.5 uly = 34
     urx =59.5 ury = 34
     lrx =59.5 lry = 19
  18/llx =60.5 lly = 19
     ulx =60.5 uly = 34
     urx =79.5 ury = 34
     lrx =79.5 lry = 19
  19/llx =80.5 lly = 19
     ulx =80.5 uly = 34
     urx =99.0 ury = 34
     lrx =99.0 lry = 19

  20/llx =1.0  lly = 1
     ulx =1.0  uly = 16
     urx =19.5 ury = 16
     lrx =19.5 lry = 1
  21/llx =20.5 lly = 1
     ulx =20.5 uly = 16
     urx =39.5 ury = 16
     lrx =39.5 lry = 1
  22/llx =40.5 lly = 1
     ulx =40.5 uly = 16
     urx =99.0 ury = 16
     lrx =99.0 lry = 1
   ;
run;

template = rdpgrid;
treplay
              0:titles

     1:plot1         2:plot2   3:plot3   4:plot4

 5:plot5   6:plot6   7:plot7   8:plot8   9:plot9
 
10:plot10 11:plot11 12:plot12 13:plot13 14:plot14

15:plot15 16:plot16 17:plot17 18:plot18 19:plot19

20:plot20 21:plot21           22:plot22

 des='' name="&name";
run;



 quit;
 ODS HTML CLOSE;
 ODS LISTING;
