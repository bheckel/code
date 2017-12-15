options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: nodup.sas
  *
  *  Summary: Demo of removing duplicates.
  *
  *           The NODUP option in the SORT procedure eliminates observations
  *           that are exactly the same across ALL variables. The NODUPKEY
  *           option eliminates observations that are exactly the same across
  *           only the BY variables.
  *
  *           NODUP is an alias for NODUPRECS
  *
  *  Adapted: Wed 29 Jun 2005 16:15:55 (Bob Heckel --
  *                      http://www2.sas.com/proceedings/sugi30/037-30.pdf)
  * Modified: Wed 31 Jul 2013 15:14:53 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;


data t; 
  input patient 1-2 arm $ 4-5 bestres $ 6-7 delay 9-10; 
  datalines; 
01 A CR 0
02 A PD 1
03 B PR 1
04 B CR 2 
05 C SD 1 
06 C SD 3 
07 C PD 2 
01 A CR 0 
03 B PD 1 
  ;
run;
title 'For this data we want to order the data by the variable PATIENT '
      'and eliminate any observations that have the exact same information '
      'for all variables.';

proc print data=t; run;
proc sort data=t out=ex0;
  by patient;
run;
proc print data=ex0; run;


 /* NODUP[RECS] */
 /* All vars must be the same for an obs to be removed.  But caution, the
  * observations that are the same must be ADJACENT during your sort.
  */

title 'BY PATIENT works and properly leaves the duplicate "3"s';
proc sort data=t NODUP out=ex1;
  by patient;
run;
proc print data=ex1; run;


title 'BY ARM does not work as desired (have 2 "1"s and sort order is '
      'incorrect) b/c patient obs are not adjacent';
proc sort data=t NODUP out=ex2;
  by arm;
run;
proc print data=ex2; run;


title 'BY ARM PATIENT works and is sorted properly b/c obs are adjacent';
proc sort data=t NODUP out=ex3;
  by arm patient;
run;
proc print data=ex3; run;

title 'BY _ALL_ works and is sorted properly b/c obs are adjacent';
proc sort data=t NODUP out=ex4;
  by _ALL_;
run;
proc print data=ex4; run;
endsas;


 /* NODUPKEY */
title 'BY PATIENT - NODUPKEY option is only looking at the BY variable of '
      'PATIENT so it ignores the difference in all other variables';
proc sort data=t NODUPKEY out=ex4;
  by patient;
run;
proc print data=ex4; run;


 /* Another (simpler?) example */

data lelimsgist05e;
  Samp_Id=14110;
  Meth_Spec_Nm='AM0908CASCA';
  Meth_Peak_Nm='FLUTIC';
  Indvl_Tst_Rslt_Device=1;
  Indvl_Meth_Stage_Nm='6-F';
  Res_Id='11875547';
  output;
  Samp_Id=14110;
  Meth_Spec_Nm='AM0908CASCA';
  Meth_Peak_Nm='FLUTIC';
  Indvl_Tst_Rslt_Device=1;
  Indvl_Meth_Stage_Nm='6-F';
  Res_Id='11875547';
  output;
  Samp_Id=14110;
  Meth_Spec_Nm='AM0908CASCA';
  Meth_Peak_Nm='FLUTIC';
  Indvl_Tst_Rslt_Device=1;
  Indvl_Meth_Stage_Nm='1-5';
  Res_Id='11875548';
  output;
  Samp_Id=14110;
  Meth_Spec_Nm='AM0908CASCA';
  Meth_Peak_Nm='FLUTIC';
  Indvl_Tst_Rslt_Device=1;
  Indvl_Meth_Stage_Nm='6-F';
  Res_Id='11875549';
  output;
run;
title;
proc print; run;

title 'NODUP';
proc sort data=lelimsgist05e nodup out=l1; 
  by Meth_Peak_Nm Indvl_Meth_Stage_Nm;
run;
proc print data=l1; run;

title 'NODUPKEY';
proc sort data=lelimsgist05e nodupkey out=l2; 
  by Meth_Peak_Nm Indvl_Meth_Stage_Nm;
run;
proc print data=l2; run;



filename f 't.dat';
/*
id 	Q1 	Q2 	Q3 	Q4 	Q5 	Q6 	Q7 	mode 	subdt 	 
10 	1 	5 	1 	3 	. 	. 	. 	e 	12/1/2010	 
10 	1 	5 	1 	3 	1 	7 	4 	p 	1/3/2011 	 
11 	3 	6 	2 	. 	2 	. 	5 	e 	1/7/2011 	 
11 	3 	6 	2 	. 	2 	. 	5 	p 	2/7/2011 	 
12 	4 	3 	2 	. 	1 	6 	3 	p 	1/15/2011	 
12 	4 	3 	2 	. 	. 	. 	. 	p 	4/2/2011 	 
15 	2 	4 	1 	2 	2 	. 	6 	p 	3/21/2011	 
21 	2 	3 	1 	4 	1 	3 	4 	e 	3/1/2011 	 
22 	1 	5 	2 	. 	1 	4 	5 	p 	2/2/2011 	 
*/
data t;
  infile f firstobs=2 TRUNCOVER;
  input id q1-q7 mode $ subdt $15.;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

data unique_obs;
  set t;
  by id;
  if first.id and last.id;
run;



 /* If dataset is huge */
data t; 
  input patient 1-2 arm $ 4-5 bestres $ 6-7 delay 9-10; 
  datalines; 
01 A CR 0
02 A PD 1
03 B PR 1
01 A CR 0 
03 B PD 1 
  ;
run;
/* Fast, no sorting */
data t2;
  /*        max nobs in t         */
  array seen {1000000} _TEMPORARY_;
  set t;
  if seen{patient} eq . then do;
    output;
    seen{patient} = 1;
  end;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
