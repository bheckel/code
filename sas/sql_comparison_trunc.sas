options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: sql_comparison_trunc.sas
  *
  *  Summary: Truncation comparison operator.  
  *           Like SAS datastep's equal colon.
  *
  *  Created: Sat 28 May 2005 08:43:23 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;


data sample;
  input density  crimerate  state $ 14-27  stabbrev $ 29-30;
  cards;
264.3 3163.2 Pennsylvania   PA
51.2 4615.8  Minnesota      MN
55.2 4271.2  Vermont        VT
9.1 2678.0   South Dakota   SD
102.4 3371.7 North Carolina NC
9.4 2833.0   North Dakota   ND
120.4 4649.9 North Carolina NC
  ;
run;

proc sql;
  select *
  from sample
  /* This will not work: */
  /*** where state eq: 'North' ***/
  /* ...but this will - first truncates to 'North' then compares */
  where state eqt 'North'
  ;
run;
