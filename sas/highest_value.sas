options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: highest_value.sas
  *
  *  Summary: Select the highest (maximum) number of a var and place it in a
  *           macrovariable.
  *
  *  Created: Mon 17 Mar 2003 14:49:31 (Bob Heckel)
  * Modified: Thu 22 May 2003 21:20:55 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data work.commadelimited;
  infile cards DLM=',' DSD MISSOVER;
  informat state $2.  yr $2.  type $4.  ship $2.  extension $2.;
  input state yr type ship extension;
  cards;
nm,03,mor,1,a
nd,03,mor,9,,
ad,03,mor,9,,
xp,02,mor,2,a
xz,01,mor,2,a
nd,03,mor,8,,
nm,03,nat,1,a,
  ;
run;

%let the_state=nd;
%let yeara=03;
%let the_type=mor;

%macro Hiship(s,y,t);
  %global hifilenum;
  proc sql NOPRINT;
    select distinct max(ship) into : hifilenum
    from work.commadelimited
    where state = "&s" and yr = "&y" and type = "&t";
  quit;
%mend;
%Hiship(&the_state, &yeara, &the_type)

%put !!! &hifilenum;


 /* Pick the latest line in the file if there are duplicates. */
proc sort;
  by ship;
run;
data work.tmp;
  set work.commadelimited;
  by ship;
  if last.ship;
run;
proc print; run;
