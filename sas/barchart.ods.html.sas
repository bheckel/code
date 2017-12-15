
%let name=bar1;
filename ODSOUT '.';

data a(drop=_max);
  infile 'junk' DLM=',' DSD MISSOVER FIRSTOBS=2;  
  input name :$32.
        count :8.
        ;
  _max=max(_max, count);
  call symput('MAX', _max);
run;

data a;
  set a;
  length htmlvar $500;
  htmlvar='title='||quote('Item: '|| trim(left(name)) ||'0D'x|| 'Amount: '|| trim(left(count))) ||' '|| 'href="bar2.htm"';
run;



GOPTIONS DEVICE=gif;

ODS LISTING CLOSE;
ODS HTML path=ODSOUT body="&name..htm" (title="Simple Bar Chart") style=minimal gtitle gfootnote;
goptions noborder;

goptions gunit=pct htitle=6 ftitle="swissb" htext=5 ftext="swiss";

axis1 label=none;
axis2 label=('AMOUNT') order=(0 to &MAX by 2) minor=(number=1) offset=(0,0);

/* pattern v=solid color=red; */
pattern v=solid color=cx43a2ca;  /* this is the hex rgb color for mild blue */

title "Simple Bar Chart";
proc gchart data=a; 
  hbar name / discrete 
  type=sum sumvar=count 
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
 
endsas;
junk looks like:

name, count
one, 10
two, 20
three, 30
