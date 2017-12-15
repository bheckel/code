options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: datdif.sas
  *
  *  Summary: Calculate the days between.  yrdif() has 'ACT/360'
  *
  *  Created: Tue 15 Jun 2010 09:48:48 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data _NULL_;
/***  x = datdif('01jan2000'D, '15jan2000'D, '30/360');***/
  x = datdif('01jan2000'D, '15jun2000'D, 'ACT/ACT');
  y = yrdif('01jan2000'D, '15jun2000'D, 'ACT/360');
  z = yrdif('01jan2000'D, '15jun2000'D, 'ACT/365');
  zz = yrdif('01jan2000'D, '15jun2000'D, 'ACT/ACT');
  put x= y= z= zz=;
run;
