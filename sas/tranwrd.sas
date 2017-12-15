options nosource;
 /*---------------------------------------------------------------------
  *     Name: tranwrd.sas (s/b symlined as replace.sas)
  *
  *  Summary: Substitute part of string (like Perl's s/foo/bar' regex or
  *           Oracle's REPLACE() )
  *
  *           Also see compress() for removing chars from strings.
  *
  *           Also see translate.sas for single chars to single chars 
  *           substitutions using ...DO OVER chars...
  *
  *           Better:
  *           %let reportlocationconverted=%sysfunc(prxchange(s/ /\\ /, -1, &reportlocation));
  *
  *  Created: Tue 22 Oct 2002 14:39:32 (Bob Heckel)
  * Modified: Wed 12 Mar 2014 16:06:30 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options source;

data _NULL_;
  length tmp $11;  /* not required unless new str > old str */
  %let the_word='sample str';
  /*                      old     new        */
  tmp=tranwrd(&the_word, 'ple', 'XXXX');
  put tmp;                       /* datastep */
  call symput('new_word', tmp);
  /* TODO is there a better way to get new string directly to macrovar? */
  %put &new_word;                /* macro */
run;


 /* New example. */
data work.sample;
  input fname $1-10  lname $15-25  @30 numb 3.;
  fname=tranwrd(fname, 'o', 'O');
  lname=tranwrd(lname, 'ia', 'ie');
  datalines;
mario         lemiaux        123
ron           francis        123
jerry         garcia         123
larry         wallo          345
  ;
run;
proc print; run;


endsas;

Stability_Samp_Stor_Cond=tranwrd(Stability_Samp_Stor_Cond, 'C', 'ºC');

data prescribers_update;
  set prescribers_update;
  /* Fix 'FAMILY CEN TER' */
  if indexw(prescriber_lname, 'CEN TER') then
    prescriber_lname=tranwrd(prescriber_lname, 'CEN TER', 'CENTER');
run;
