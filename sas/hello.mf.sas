//BQH0HELL  JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=(,10),CLASS=E,
//          MSGLEVEL=(0,0)
//STEP1     EXEC SAS,TIME=100,OPTIONS='MSGCASE,MEMSIZE=0'
//WORK      DD SPACE=(CYL,(100,100),,,ROUND)
//SYSIN     DD *

options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: hello.mf.sas
  *
  *  Summary: Bloated Hellooooooooo world for mainframe.
  *
  *  Created: Wed 06 Nov 1999 12:29:41 (Bob Heckel)
  * Modified: Mon 17 Apr 2006 13:18:33 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

 /* Prints to the SAS Log, nothing to the Output window. */
data _NULL_;
  put 'Hello' +5 'Mainframe SAS World';
  /* Put a gap in the SAS Log. */
  skip 15;
  put 'ok';
  call symput("CYR4", substr(put("&sysdate9"d,mmddyy10.),7,4));
run;

%put !!! &CYR4;

 /* Implicit creation of dataset data1, the DATAn naming convention. */
data;
  label fname='First Name';
  input fname $1-10  lname $15-25  @30 numb 3.;
  /* Instream data. */
  datalines;
mario         lemieux        123
ron           francis        123
jerry         garcia         123
  ;
run;
proc print data=data1; run;


title10 'Highest numbered title statement';
footnote10 'Highest numbered footnote statement';


data work.tmp (label= bob thing);
  label fname='First Name';
  input fname $1-10  lname $ 15-25  @30 numb 3.;
  datalines;
mario         lemieux        123
ron           francis        123
jerry         garcia         123
  ;
run;
proc print; run;


data _NULL_;
  set work.tmp;
  put 'fname is ' fname=;
  /* Doesn't work, can only use &FOO */
  ***%put Fname is   fname=;
run;
