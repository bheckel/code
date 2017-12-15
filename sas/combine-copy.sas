options compress=yes NOxwait;
 /* 2006-07-31 not sure why i moved newer files in place */

 /* Just in case */
proc datasets library=L; delete LeLimsSumRes01a LeLimsIndres01a; run;

 /* NNN */
 /* 1,018,641 / 61,393 KB */
proc append base=L.LeLimsIndres01a data=L.indagenerase01a; run;
proc append base=L.LeLimsSumRes01a data=L.sumagenerase01a; run;
proc append base=L.LeLimsIndres01a data=L.indamerge01a; run;
proc append base=L.LeLimsSumRes01a data=L.sumamerge01a; run;
proc append base=L.LeLimsIndres01a data=L.indadvairhfa01a; run;
proc append base=L.LeLimsSumRes01a data=L.sumadvairhfa01a; run;
proc append base=L.LeLimsIndres01a data=L.indavandaryl01a; run;
proc append base=L.LeLimsSumRes01a data=L.sumavandaryl01a; run;
proc append base=L.LeLimsIndres01a data=L.indbupropion01a; run;
proc append base=L.LeLimsSumRes01a data=L.sumbupropion01a; run;
proc append base=L.LeLimsIndres01a data=L.indcombivir01a_2004_06_16; run;
proc append base=L.LeLimsSumRes01a data=L.sumcombivir01a_2004_06_16; run;
proc append base=L.LeLimsIndres01a data=L.indepivir01a_2004_06_26; run;
proc append base=L.LeLimsSumRes01a data=L.sumepivir01a_2004_06_26; run;
proc append base=L.LeLimsIndres01a data=L.indimitrex01a_2004_06_24_NA; run;
proc append base=L.LeLimsSumRes01a data=L.sumimitrex01a_2004_06_24_NA; run;
proc append base=L.LeLimsIndres01a data=L.indalbuterol01a; run;
proc append base=L.LeLimsSumRes01a data=L.sumalbuterol01a; run;
 
 /* NNN */
 /* 1,500,481 / 105,409 KB */
*proc append base=L.LeLimsIndres01a data=L.indlamictal01a_2004_06_26; run;
*proc append base=L.LeLimsSumRes01a data=L.sumlamictal01a_2004_06_26; run;
*proc append base=L.LeLimsIndres01a data=L.indlanoxin01a_2004_12_28; run;
*proc append base=L.LeLimsSumRes01a data=L.sumlanoxin01a_2004_12_28; run;
*proc append base=L.LeLimsIndres01a data=L.indlotronex01a_2004_12_29; run;
*proc append base=L.LeLimsSumRes01a data=L.sumlotronex01a_2004_12_29; run;
*proc append base=L.LeLimsIndres01a data=L.indretrovir01a_2004; run;
*proc append base=L.LeLimsSumRes01a data=L.sumretrovir01a_2004; run;
*proc append base=L.LeLimsIndres01a data=L.indtrizivir01a_2004_06_25; run;
*proc append base=L.LeLimsSumRes01a data=L.sumtrizivir01a_2004_06_25; run;
*proc append base=L.LeLimsIndres01a data=L.indvaltrex01a; run;
*proc append base=L.LeLimsSumRes01a data=L.sumvaltrex01a; run;
*proc append base=L.LeLimsIndres01a data=L.indventolin01a; run;
*proc append base=L.LeLimsSumRes01a data=L.sumventolin01a; run;
*proc append base=L.LeLimsIndres01a data=L.indsal_fp01a; run;
*proc append base=L.LeLimsSumRes01a data=L.sumsal_fp01a; run;

 /* NYN */
 /* 977,377 / 69,585 KB */
*proc append base=L.LeLimsIndres01a data=L.indwatson01a; run;
*proc append base=L.LeLimsSumRes01a data=L.sumwatson01a; run;
*proc append base=L.LeLimsIndres01a data=L.indwellbutrin01a; run;
*proc append base=L.LeLimsSumRes01a data=L.sumwellbutrin01a; run;
*proc append base=L.LeLimsIndres01a data=L.indzantac01a; run;
*proc append base=L.LeLimsSumRes01a data=L.sumzantac01a; run;
*proc append base=L.LeLimsIndres01a data=L.indziagen01a_2004_06_26; run;
*proc append base=L.LeLimsSumRes01a data=L.sumziagen01a_2004_06_26; run;
*proc append base=L.LeLimsIndres01a data=L.indzofran01a_2004_06_26; run;
*proc append base=L.LeLimsSumRes01a data=L.sumzofran01a_2004_06_25; run;
*proc append base=L.LeLimsIndres01a data=L.indzovirax01a_2004_06_23; run;
*proc append base=L.LeLimsSumRes01a data=L.sumzovirax01a_2004_06_23; run;
*proc append base=L.LeLimsIndres01a data=L.indzyban01a_2004_06_24; run;
*proc append base=L.LeLimsSumRes01a data=L.sumzyban01a_2004_06_24; run;
*proc append base=L.LeLimsIndres01a data=L.indondansetron2006; run;
*proc append base=L.LeLimsSumRes01a data=L.sumondansetron2006; run;

endsas;
x "move /Y LeLimsSumRes01a.sas7bdat \\rtpsawn321\d\sql_loader\LeLimsSumRes01a.sas7bdat";
x "move /Y LeLimsIndres01a.sas7bdat \\rtpsawn321\d\sql_loader\LeLimsIndres01a.sas7bdat";
