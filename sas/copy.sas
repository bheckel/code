
options NOxwait NOsgen NOmlogic;

 /* Copy and rename a set of LINKS datasets to sql_loader\ */

libname K '.';
libname X 'X:\SQL_Loader';

 /* All: */
*%let prod=%upcase(advairh);
*%let prod=%upcase(avanda);
*%let prod=%upcase(bupro);
*%let prod=%upcase(combivi);
*%let prod=%upcase(epivir);
 /* normal and FDT */
*%let prod=%upcase(imitrex);
 /* normal, CD and XR */
*%let prod=%upcase(lamicta);
*%let prod=%upcase(lanoxin);
%let prod=%upcase(lotrone);
*%let prod=%upcase(retrovi);
*%let prod=%upcase(trizivi);
*%let prod=%upcase(valtrex);
*%let prod=%upcase(ventoli);
*%let prod=%upcase(watson);
*%let prod=%upcase(wellbut);
*%let prod=%upcase(zantac);
*%let prod=%upcase(ziagen);
*%let prod=%upcase(zofran);
*%let prod=%upcase(zovirax);
*%let prod=%upcase(zyban);

 /* One level: */
*%let prod=%upcase(combivi);
*%let prod=%upcase(trizivi);
*%let prod=%upcase(ziagen);
*%let prod=%upcase(zyban);

 /* Two or more levels: */
*%let prod=%upcase(avandaryl);
*%let prod=%upcase(epivir);
*%let prod=%upcase(imitrex);
*%let prod=%upcase(lamictal);
*%let prod=%upcase(lanoxin);
*%let prod=%upcase(lotrone);
*%let prod=%upcase(retrovir);
*%let prod=%upcase(ventolin);
*%let prod=%upcase(zantac);
*%let prod=%upcase(zofran);
*%let prod=%upcase(zovirax);

 /* Capsules & tablets: */
*%let prod=%upcase(retrovi);
*%let prod=%upcase(zovirax);

 /* Share methods: */
*%let prod=%upcase(advairh);
*%let prod=%upcase(bupro);
*%let prod=%upcase(epivir);
*%let prod=%upcase(imitrex);
*%let prod=%upcase(retrovi);
*%let prod=%upcase(ventoli);
*%let prod=%upcase(watson);
*%let prod=%upcase(wellbut);
*%let prod=%upcase(zantac);
*%let prod=%upcase(ziagen);
*%let prod=%upcase(zofran);
*%let prod=%upcase(zovirax);
*%let prod=%upcase(zyban);


%let prodI=IND&prod;

proc sql NOPRINT;
  select memname into :DSETI
  from dictionary.members
  where libname like 'K' and memname like "&prodI.%";
quit;


%let prodS=SUM&prod;

proc sql NOPRINT;
  select memname into :DSETS
  from dictionary.members
  where libname like 'K' and memname like "&prodS.%";
quit;


proc copy in=K out=X;
  select &DSETI;
  select &DSETS;
run;

%let DSETI=%left(%trim(&DSETI));
%let DSETS=%left(%trim(&DSETS));
x "move /Y \\rtpsawn321\d\sql_loader\&DSETI..sas7bdat \\rtpsawn321\d\sql_loader\LeLimsIndres01a.sas7bdat";
x "move /Y \\rtpsawn321\d\sql_loader\&DSETS..sas7bdat \\rtpsawn321\d\sql_loader\LeLimsSumres01a.sas7bdat";

