options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: symget.sas
  *
  *  Summary: Demo of grabbing macrovariables from within a data step.
  *
  *  Created: Wed 12 Mar 2003 10:38:00 (Bob Heckel)
  * Modified: Mon 04 Aug 2014 14:35:59 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data dusty;
  input dept $ name $ salary @@;
  datalines;
bedding Watlee 18000    bedding Ives 16000
bedding Parker 9000     bedding George 8000
bedding Joiner 8000     carpet Keller 20000
carpet Ray 12000        carpet Jones 9000
gifts Johnston 8000     gifts Matthew 19000
kitchen White 8000      kitchen Banks 14000
kitchen Marks 9000      kitchen Cannon 15000
tv Jones 9000           tv Smith 8000
tv Rogers 15000         tv Morse 16000
  ;
run;
proc means noprint;
  class dept;
  var salary;
  output out=stats sum=s_sal;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
data _null_;
  set stats;
  if _n_=1 then call symput('s_tot',s_sal);
  else call symput('s_'||dept,s_sal);
run;
%put _user_;
data new;
  set dusty;
  pctdept=(salary/symget('s_'||dept))*100;
  pcttot=(salary/&s_tot)*100;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


endsas;
%let s=01|02||04|05;
  
data work.foo;
  x=symget('s');
  output;
run;
proc print; run;


data work.sample;
   input density  crimerate  state $ 14-27  stabbrev $ 29-30;
   cards;
264.3 3163.2 Pennsylvania   PA
9.4 2833.0   North Dakota   ND
120.4 4649.9 North Carolina NC
  ;
run;

data work.foo2;
  ***if x=symget('t') ne '' then ;
  if x=symget('s') ne '' then
    set work.sample;
  else
    set work.foo;
run;
proc print; run;
