options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: title.sas
  *
  *  Summary: Demo of title global statement.
  *
  *           "The SAS System" is the title if you don't use a title statement.
  *           ===> titles
  *           to verify
  *
  *           Defining title2 in a second report automatically cancels any
  *           previous title3,4, etc. Obviously  title;  clears all.
  *
  *  Created: Thu 19 Jun 2003 12:05:06 (Bob Heckel)
  * Modified: Wed 02 Jun 2010 12:40:27 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source skip=3 date;

title 'Moved down 3 lines before start printing in the Standard Print File '
      'thanks to the SKIP option'
      ;
title2 ' ';  /* space mandatory */
proc print data=sashelp.shoes(obs=2); run;



%let m=2000;
%let n=3000;
%let foo=bar;

title 'test1';
 /* TODO */
title2 'test2 ' '10'x '13'x 'two line';
title3;  /* force a carriage return */
title4 'test4 '
       'actually this is on one line';
 /* Doesn't look like it'll work but it does. */
title5 "commafy1 %sysfunc(putn(&m, COMMA5.))"
       "commafy2 %sysfunc(putn(&n, COMMA5.))"
       "%sysfunc(upcase(&foo))";

data sample;
   input density  crimerate  state $ 14-27  stabbrev $ 29-30;
   cards;
264.3 3163.2 Pennsylvania   PA
  ;
run;

proc print; run;
 /* Clear all titles */
title1;
proc print; run;


title 'foo' 
      'bar';
proc print data=sashelp.shoes(obs=2); run;
