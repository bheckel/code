options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: transpose_long2wide_denormalize.mcr.sas
  *
  *  Summary: Use proc sql to transpose / denormalize even when number of
  *           elements is huge
  *
  *  Adapted: Fri 15 Aug 2014 09:20:35 (Bob Heckel--SUGI 089-2008)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

 /*********************************************************************/
 /* Macro below this example solves the problem where VISITs is huge, i.e. not just "1" or "2" */
data t;
  infile cards;
  input subject visit ldl hdl;
  cards;
1 1 115 33
1 2 112 43
2 1 136 51
2 2 121 50
3 1 99 57
3 2 100 59
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
/*
Obs    subject    visit    ldl    hdl

 1        1         1      115     33
 2        1         2      112     43
 3        2         1      136     51
 4        2         2      121     50
 5        3         1       99     57
 6        3         2      100     59
*/

proc sql noprint;
  create table ttp as
    select subject, 
           /* max is 1-required by the GROUP BY  2-required to remove the '.'s  Could also use sum() */
           max(case when visit=1 then ldl else . end) as ldl_1,
           max(case when visit=2 then ldl else . end) as ldl_2,
           max(case when visit=1 then hdl else . end) as hdl_1,
           max(case when visit=2 then hdl else . end) as hdl_2
    from t
    group by subject
    ;
  quit;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
/*
Obs    subject    ldl_1    ldl_2    hdl_1    hdl_2

 1        1        115      112       33       43 
 2        2        136      121       51       50 
 3        3         99      100       57       59 
*/
 /*********************************************************************/


 /*                                    to be transposed      */
 /*                                         _____            */
%macro long2wide(data=_LAST_, by=, months=, vars=, out=_DATA_);
  proc sql NOprint;
    CREATE TABLE &out AS SELECT &by
      %let dv=%scan(&months,1);  /* pick off var with month data in it */
      %let i=1;
      %let v=%scan(&vars,1);  /* iterate actual and predict vars */
      %do %while ("&v"^="");
        %let j=2;
        %let mo=%scan(&months,2," ");
        %do %while ("&mo"^="");
          %let lmo="01%scan(&mo,1,"-")"d;
          %let hmo="01%scan(&mo,2,"-")"d;
          %if &hmo="01"d %then %let hmo=&lmo;
          %let nmo=%sysfunc(intck(month,&lmo,&hmo));
            %do m2=0 %to &nmo;
              %let mo1=%sysfunc(intnx(month,&lmo,&m2),DATE9.);  /* criteria */
              %let mo2=%sysfunc(intnx(month,&lmo,&m2),YYMMN6.);  /* var label suffix */
              /* Note: there is no actual SUMming going on */
              , sum(CASE WHEN &dv="&mo1"d THEN &v ELSE . END) as &v&mo2
            %end;
          %let j=%eval(&j+1);
          %let mo=%scan(&months,&j," ");
        %end;
        %let i=%eval(&i+1); %let v=%scan(&vars,&i);  /* iterate actual and predict vars */
      %end;
    FROM &data 
    GROUP BY &by 
    ORDER BY &by;
  quit;
%mend;
/*
Builds:
proc sql;
  create table prdsalesum as select product ,
  sum(case when month="01JAN1993"d then actual end) as actual199301 ,
  sum(case when month="01FEB1993"d then actual end) as actual199302 ,
  sum(case when month="01MAR1993"d then actual end) as actual199303 ,
  ...
from sashelp.prdsale group by product order by product;
*/

proc print data=sashelp.prdsale(obs=25) width=minimum; run;
/*
 Obs    ACTUAL     PREDICT    COUNTRY    REGION    DIVISION     PRODTYPE     PRODUCT    QUARTER    YEAR    MONTH

   1    $925.00    $850.00    CANADA      EAST     EDUCATION    FURNITURE     SOFA         1       1993     Jan 
   2    $999.00    $297.00    CANADA      EAST     EDUCATION    FURNITURE     SOFA         1       1993     Feb 
   3    $608.00    $846.00    CANADA      EAST     EDUCATION    FURNITURE     SOFA         1       1993     Mar 
   4    $642.00    $533.00    CANADA      EAST     EDUCATION    FURNITURE     SOFA         2       1993     Apr 
   5    $656.00    $646.00    CANADA      EAST     EDUCATION    FURNITURE     SOFA         2       1993     May 
   ...
 */

 /* For each of the 5 products, give actual and predict dollars by year/month */
%long2wide(data=sashelp.prdsale(drop= quarter region division prodtype), by=product, months= month jan1993-dec1994, vars= actual predict, out=prdsaleflip);
proc print data=_LAST_(obs=max) width=minimum; run;
/*
          a    a    a    a    a    a    a    a    a    a    a    a    a    a    a    a    a    a    a    a    a    a    a    a    r    r    r    r    r    r    r    r    r    r    r    r    r    r    r    r    r    r    r    r    r    r    r    r
          c    c    c    c    c    c    c    c    c    c    c    c    c    c    c    c    c    c    c    c    c    c    c    c    e    e    e    e    e    e    e    e    e    e    e    e    e    e    e    e    e    e    e    e    e    e    e    e
          t    t    t    t    t    t    t    t    t    t    t    t    t    t    t    t    t    t    t    t    t    t    t    t    d    d    d    d    d    d    d    d    d    d    d    d    d    d    d    d    d    d    d    d    d    d    d    d
          u    u    u    u    u    u    u    u    u    u    u    u    u    u    u    u    u    u    u    u    u    u    u    u    i    i    i    i    i    i    i    i    i    i    i    i    i    i    i    i    i    i    i    i    i    i    i    i
          a    a    a    a    a    a    a    a    a    a    a    a    a    a    a    a    a    a    a    a    a    a    a    a    c    c    c    c    c    c    c    c    c    c    c    c    c    c    c    c    c    c    c    c    c    c    c    c
    P     l    l    l    l    l    l    l    l    l    l    l    l    l    l    l    l    l    l    l    l    l    l    l    l    t    t    t    t    t    t    t    t    t    t    t    t    t    t    t    t    t    t    t    t    t    t    t    t
    R     1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1
    O     9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9
    D     9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9    9
O   U     3    3    3    3    3    3    3    3    3    3    3    3    4    4    4    4    4    4    4    4    4    4    4    4    3    3    3    3    3    3    3    3    3    3    3    3    4    4    4    4    4    4    4    4    4    4    4    4
b   C     0    0    0    0    0    0    0    0    0    1    1    1    0    0    0    0    0    0    0    0    0    1    1    1    0    0    0    0    0    0    0    0    0    1    1    1    0    0    0    0    0    0    0    0    0    1    1    1
s   T     1    2    3    4    5    6    7    8    9    0    1    2    1    2    3    4    5    6    7    8    9    0    1    2    1    2    3    4    5    6    7    8    9    0    1    2    1    2    3    4    5    6    7    8    9    0    1    2

1 BED   4085 5025 4918 6999 5727 7615 8189 5754 4038 5284 4890 6939 5820 6100 5601 5401 6581 6100 6747 5895 5876 7109 5825 5519 5612 6510 5135 5640 6122 5415 6802 7680 5026 4431 7407 5143 7259 6394 4958 5161 6271 6412 5986 5101 2842 5536 5888 5136
2 CHAIR 5174 6306 5620 5383 4000 5484 6560 6873 6781 7464 6561 6814 6490 5887 5800 7821 8377 5082 6032 6976 5013 4791 6513 6478 5939 6586 6419 5910 6082 5815 7230 4792 4954 4230 4910 6631 7291 4875 5756 5501 5093 4469 5844 6629 4796 6189 4406 5763
3 DESK  7303 4855 5819 6526 7663 6951 5796 6269 6948 7682 6140 4215 6947 6381 5616 5657 6414 3769 5530 6223 6027 6486 6803 7212 5960 4392 5516 5404 6361 4895 5360 4731 6142 7805 6722 5539 5613 7000 7092 5699 6204 6225 4827 8025 7714 4386 7064 7519
4 SOFA  6802 7290 7317 6019 6337 6581 7387 6541 6699 6410 5301 6748 7136 4933 4749 7879 6092 5401 4747 4891 6869 2979 7586 5894 8610 6513 7432 5811 6287 4794 6012 6959 5813 7175 6162 4910 6964 4980 6035 5858 5689 5567 5461 5053 4777 4914 5093 3582
5 TABLE 6449 6108 6199 5654 7890 6974 5646 5723 4230 4515 4767 7240 7311 4412 6580 5511 5882 7392 5550 6416 6257 4007 4667 6820 6264 5162 7316 4664 5411 6715 7816 4712 6535 6621 6233 7036 5586 6248 6784 7691 5370 5654 7775 4212 4390 7686 4083 5708
*/
