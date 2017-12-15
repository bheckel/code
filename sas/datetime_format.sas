options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: datetime_format.sas
  *
  *  Summary: Demo of datetime format
  *
  *  Created: Fri 22 Nov 2013 12:58:35 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

data t;
  file PRINT;
  x=1000000;
  y=1000000000;
  z='30OCT65:00:00:00'DT;

  put x DATETIME.;
  put x DATETIME10.;
  put x DATETIME15.;
  put y DATETIME.;
  put z;
run;

endsas;
12JAN60:13:46:40
12JAN60:13
  12JAN60:13:46
09SEP91:01:46:40
183945600

