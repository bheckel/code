options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: leave.sas
  *
  *  Summary: Demo of leave function.
  *
  *  Adapted: (http://support.sas.com/documentation/cdl/en/syntaxidx/65757/HTML/default/index.htm#/documentation/cdl/en/lestmtsref/63323/HTML/default/n03wnjww9jjpm8n1q16exvgtoae9.htm)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err ls=max;

data week;
   input name $ idno start_yr status $ dept $;
   datalines;
Jones 9011 1990 PT PUB
Thomas 876 1976 PT HR
Barnes 7899 1991 FT TECH
Harrell 1250 1975 FT HR
Richards 1002 1990 FT DEV
Kelly 85 1981 PT PUB
Stone 091 1990 PT MAIT
;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

title 'The LEAVE statement causes processing of the current loop to end';
data week;
  input name $ idno start_yr status $ dept $;
  bonus=0;
  do year=start_yr to 1991;
    if bonus ge 500 then leave;
    bonus+50;
  end;
  datalines;
Jones 9011 1990 PT PUB
Thomas 876 1976 PT HR
Barnes 7899 1991 FT TECH
Harrell 1250 1975 FT HR
Richards 1002 1990 FT DEV
Kelly 85 1981 PT PUB
Stone 091 1990 PT MAIT
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

title 'The CONTINUE statement stops the processing of the current iteration of a loop and resumes with the next iteration';
data week;
  input name $ idno start_yr status $ dept $;
  bonus=0;
  do year=start_yr to 1991;
     if bonus ge 500 then continue;
     bonus+50;
  end;
  datalines;
Jones 9011 1990 PT PUB
Thomas 876 1976 PT HR
Barnes 7899 1991 FT TECH
Harrell 1250 1975 FT HR
Richards 1002 1990 FT DEV
Kelly 85 1981 PT PUB
Stone 091 1990 PT MAIT
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
