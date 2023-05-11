options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: datetime_format.sas
  *
  *  Summary: Demo of datetime format
  *
  *  Created: 22-Nov-2013 (Bob Heckel)
  * Modified: 09-May-2023 (Bob Heckel)
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

---

proc format;
  picture mydate other='%0d%b%y' (datatype=date);
run;

/* convert seconds from epoch to DDMONYY format */
data example;
  input datetime_num;
  datalines;
  1620522622
  1632744723
  1643399456
  ;
run;

data example;
  set example;
  date_num = datetime_num/(60*60*24);   /* convert seconds to days */
  format date_num mydate.;              /* format as custom DDMONYY format */
  date_char = put(date_num, mydate.);   /* format as DDMONYY character string */
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;
