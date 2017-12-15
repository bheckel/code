options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: time_format.sas
  *
  *  Summary: Demo of SAS TIME format
  *
  *  Created: Fri 22 Nov 2013 14:31:02 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;
data _null_;
  file PRINT;
  x='9:35'T;
  y=1000000000;

  put x TIME5.;
  put x TIME6.;
  /* Zero pad single-digit hours */
  put x TOD5.;
  put x TOD6.;
  put;
  put y DATETIME.;
  put y TIME5.;  /* TODO strange - only accepts time not datetime numbers?? */
  put y TIME6.;  /* TODO strange - only accepts time not datetime numbers?? */
  /* Zero pad single-digit hours */
  put y TOD5.;  /* works */
  put y TOD6.;  /* works */
run;

endsas;
 9:35
  9:35
09:35
 09:35

*****
277777
01:46
 01:46
