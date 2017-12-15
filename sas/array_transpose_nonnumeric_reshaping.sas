options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: array_transpose_nonnumeric_reshaping.sas
  *
  *  Summary: Flip non-numeric long data to wide.  What product is produced
  *           by plant.
  *
  *  Created: Thu 24 Oct 2013 10:30:58 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err ls=max ps=max;

/*
"PLANT_COD","SITE_NAME","PROD_BRAND_NAME"
"1200","N Dame de Bondeville","RAIXTRA"
"1200","N Dame de Bondeville","TOHER VACCINES"
"1200","N Dame de Bondeville","EVNTOLIN"
"1200","N Dame de Bondeville",""
"1500","Montrose","EBCOTIDE/BECLOFORTE"
"1700","Jurong","752 - MONO"
"1700","Jurong","ADRAPLADIB"
"1700","Jurong","PEIVIR"
...
*/
filename F "C:\Documents and Settings\rsh86800\Desktop\t2.csv";

data t;
  infile F DLM=',' DSD MISSOVER LRECL=1048576 FIRSTOBS=3;
  input Plant :$10.                             
        Site  :$40.                              
        Brand :$40.                          
        ;
  if Brand ne '';
run;
proc sort; by Brand; run;
proc print data=_LAST_(obs=10) width=minimum; run;


 /* FAIL - we must use arrays */
/***proc transpose;***/
/***  by Brand;***/
/***  id Site;***/
/***run;***/


 /* Find max for array dim */
proc sql;
  select count(distinct Site) into :SCNT from t;
quit;
%put _global_;


data t2(drop=Site);
  retain Brand Site1-Site12;
  set t(drop=Plant);
  by Brand;

  array asite[12] $40 Site1-Site12;

  if first.Brand then do;
    i=1;  /* Brand counter */
    do j=1 to 12; asite[j]=''; end;
  end;

  /* Populate Site1, Site2, ... with the site name when that Site produces that Brand */
  asite[i]=Site;

  if last.Brand then output;
  i+1;
run;
/*
Obs   Brand              Site1                  Site2            Site3            Site4            Site5            Site6            Site7            Site8            Site9            Site10    Site11   Site12    Site13    i    j

  1   752 - MONO         Jurong                 Aranda           Ware             Zebulon                                                                                                                                      4    .
  2   752 - TRII         Aranda                                                                                                                                                                                                1   14
  3   CATIFED            Mississauga            Mississauga                                                                                                                                                                    2    .
  4   DAEFOVIR           Mississauga                                                                                                                                                                                           1   14
  5   DAJUVANT           Barnard Castle                                                                                                                                                                                        1   14
  ...
*/
proc sort; by i; run;
proc print data=_LAST_(obs=max) width=minimum; run;
