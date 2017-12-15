options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: pickapart-filename.sa
  *
  *  Summary: Parse a filename for data.
  *
  *           Compare with perlregex.capturing.sas (v9 required)
  *
  *  Created: Thu 30 Sep 2004 13:48:41 (Bob Heckel)
  * Modified: Wed 20 Apr 2005 15:01:07 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data _null_;
  s='BF19.INX03012.FETMER';

  p1=scan(s, 1, '.');
  p2=scan(s, 2, '.');
  p3=scan(s, 3, '.');

  yr=substr(p2, 3, 2);
  ship=substr(p2, 6);

  file PRINT; 
  put p1= p2= p3= yr= ship=;
run;


 /**************************************/


filename IN 'BF19.MEX0302.MORMER';

data _null_;
  length fname $80;
  infile IN filename=fname obs=0;
  /* MOR */
  call symput('EVT',substr(scan(fname,3,'.'),1,3));
  /* 04 */
  call symput('YR',substr(scan(fname,2,'.'),4,2));
  /* 2004 */
  call symput('YEAR',trim('20'||substr(scan(fname,2,'.'),4,2)));
  /* ID */
  call symput('STABBR',substr(scan(fname,2,'.'),1,2));
  /* BF19.MEX0302.MORMER */
  call symput('FNAME',trim(fname));
run;

%put !!!&EVT;
%put !!!&YR;
%put !!!&YEAR;
%put !!!&STABBR;
%put !!!&FNAME;
