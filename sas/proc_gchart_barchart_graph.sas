
%let name=bar1;
filename odsout '.';

data a;
  input ITEM $ 1-6 AMOUNT;
  cards;
ITEM A 11.8
ITEM B 10.5
ITEM C 8.8
ITEM D 6.8
ITEM E 4.2
ITEM F 2.3
  ;
run;

data a;
  set a;
  length htmlvar $500;
  htmlvar='title='||quote('Item: '|| trim(left(item)) ||'0D'x|| 'Amount: '|| trim(left(amount))) ||' '|| 'href="bar2.htm"';
run;



GOPTIONS DEVICE=gif;

ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" (title="Simple Bar Chart") style=minimal gtitle gfootnote;
goptions noborder;

goptions gunit=pct htitle=6 ftitle="swissb" htext=5 ftext="swiss";

axis1 label=none;
axis2 label=('AMOUNT') order=(0 to 12 by 2) minor=(number=1) offset=(0,0);

/* pattern v=solid color=red; */
pattern v=solid color=cx43a2ca;  /* this is the hex rgb color for mild blue */

title "Simple Bar Chart";
proc gchart data=a; 
  hbar item / discrete 
  type=sum sumvar=amount 
  nostats
  maxis=axis1 /* midpoint axis */
  raxis=axis2 /* response/numeric axis */
  autoref /* reflines at every major axis tickmark */
  clipref /* put reflines behind the bars */
  coutline=black 
  html=htmlvar
  des="" name="&name" ;  
run;


quit;
ODS HTML CLOSE;
ODS LISTING;
 
