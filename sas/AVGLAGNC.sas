 /* Average lag counts by county then by month. */

%include 'BQH0.PGM.LIB(TABDELIM)';

filename IN 'BF19.NVX0417.NATMER';

  /* Must change yearly! */
proc format;
  value $f_rdate
    '20040101'-'20040115'='01152004'
    '20040116'-'20040131'='01312004'
    '20040201'-'20040215'='02152004'
    '20040216'-'20040229'='02282004'
    '20040301'-'20040315'='03152004'
    '20040316'-'20040331'='03312004'
    '20040401'-'20040415'='04152004'
    '20040416'-'20040430'='04302004'
    '20040501'-'20040515'='05152004'
    '20040516'-'20040531'='05312004'
    '20040601'-'20040615'='06152004'
    '20040616'-'20040630'='06302004'
    '20040701'-'20040715'='07152004'
    '20040716'-'20040731'='07312004'
    '20040801'-'20040815'='08152004'
    '20040816'-'20040831'='08312004'
    '20040901'-'20040915'='09152004'
    '20040916'-'20040930'='09302004'
    '20041001'-'20041015'='10152004'
    '20041016'-'20041031'='10312004'
    '20041101'-'20041115'='11152004'
    '20041116'-'20041130'='11302004'
    '20041201'-'20041215'='12152004'
    '20041216'-'20041231'='12312004'
    OTHER = '99'
    ;
run;


data work.lags;
  infile IN;
  length rcptmo $ 2  rdate $ 8  rcptdy $ 2  repyr $ 4;

  input @9 monb $CHAR2.    @11 dob $CHAR2.  @224 yob $CHAR4.
        @241 monrcpt $CHAR1.  @242 dyrcpt $CHAR2. @244 yrrcpt $CHAR1.
        @18 occurcounty $CHAR3.
        ;

  if occurcounty = '' then
    delete;

  if substr(monb, 2, 1) eq '' then
    monb = '0'||substr(monb, 2, 1);

  if dob = '99' and monb ne '99' then
    dob = '01';

  if substr(dob, 2, 1) = '' then
    dob = '0'||substr(dob, 2, 1);

  if monrcpt ge '1' and monrcpt le '9' then
    rcptmo = '0'||monrcpt;
  else if monrcpt = '0' then
    rcptmo = '10';
  else if monrcpt = '-' then
    rcptmo = '11';
  else if monrcpt = '&' then
    rcptmo = '12';

  if substr(dyrcpt, 2, 1) = '' then
    rcptdy = '0'||substr(dyrcpt, 1, 1);
  else 
    rcptdy = dyrcpt;

  /* Must change yearly! */
  if yrrcpt eq '1' then
    repyr = '2001';
  if yrrcpt eq '2' then
    repyr = '2002';
  if yrrcpt eq '3' then
    repyr = '2003';
  if yrrcpt eq '4' then
    repyr = '2004';

  rdate = input(rcptmo||rcptdy||repyr, MMDDYY10.);

  bdat  = put(yob||monb||dob, $f_rdate.);

  bdate = input(bdat, MMDDYY10.);

  if bdate = '99' then
    delete;

  /* Determine the number of days between the date of occurrence and the date
   * the data was received by nchs.
   */
  dydiff=intck('days', bdate, rdate);
run;


 /* DEBUG */
***proc print; run;


options NOcenter;
title '2004 Nevada Natality Lag by County';

proc sql;
  create table tmp as
  select occurcounty as COUNTY, monb as MONTH, avg(dydiff) format 8.2 as MEAN
  from work.lags
  group by occurcounty, monb
  ;
quit;


%Tabdelim(work.tmp, 'BQH0.TMPTRAN2');
