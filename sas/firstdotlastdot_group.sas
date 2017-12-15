options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: firstdotlastdot_group.sas
  *
  *  Summary: Demo of first dot and capping
  *
  *  Created: Thu 11 May 2017 09:30:20 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

data t;
 input brkdndt $char6. +1 vehicle $char3. anum;
 cards;
1jun94 AAA 8
2nov94 AAA 8
3nov94 AAA 8
4XXXXX AAA 8
5XXXXX AAA 8
1mar94 AAA 9
2may94 AAA 9
1jul94 BBB 9
1may94 CCC 8
2may94 CCC 8
3may94 CCC 8
4XXXXX CCC 8
5XXXXX CCC 8
1may94 CCC 9
2dec94 CCC 9
;
run;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;

proc sort data=t; by vehicle anum;run;

 /* Set a cap of 3 vehicles */
data capby1var;
   set t;
   by vehicle;
   if first.vehicle then do;
     n=1;
   end;
   else do;
     n+1;
     if n =< 3;
    end;
run;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;


 /* Set a cap of 3 by vehicles/anum */
data capby2vars;
   set t;
   put _all_;
   by vehicle anum;
   if first.vehicle then do;
     n=1;
     output;
   end;
   else do;
     /* Reset the counter on each change of anum */
     if first.anum then do;
       n = 1;
     end;
     else do;
       n+1;
     end;

     if n =<3 then output;
   end;
run;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;
/*
WORK    CAPBY2VARS                      

Obs    brkdndt    vehicle    anum    n

  1    1jun94       AAA        8     1
  2    2nov94       AAA        8     2
  3    3nov94       AAA        8     3
  4    1mar94       AAA        9     1
  5    2may94       AAA        9     2
  6    1jul94       BBB        9     1
  7    1may94       CCC        8     1
  8    2may94       CCC        8     2
  9    3may94       CCC        8     3
 10    1may94       CCC        9     1
 11    2dec94       CCC        9     2
*/

/*DEBUG*/
data t ; set t; by vehicle anum; put _all_; run;
/*  XXXXX are skipped due to cap of 3
brkdndt=1jun94 vehicle=AAA anum=8 FIRST.vehicle=1 LAST.vehicle=0 FIRST.anum=1 LAST.anum=0 _ERROR_=0 _N_=1  <--AAA/8
brkdndt=2nov94 vehicle=AAA anum=8 FIRST.vehicle=0 LAST.vehicle=0 FIRST.anum=0 LAST.anum=0 _ERROR_=0 _N_=2
brkdndt=3nov94 vehicle=AAA anum=8 FIRST.vehicle=0 LAST.vehicle=0 FIRST.anum=0 LAST.anum=0 _ERROR_=0 _N_=3
brkdndt=4XXXXX vehicle=AAA anum=8 FIRST.vehicle=0 LAST.vehicle=0 FIRST.anum=0 LAST.anum=0 _ERROR_=0 _N_=4
brkdndt=5XXXXX vehicle=AAA anum=8 FIRST.vehicle=0 LAST.vehicle=0 FIRST.anum=0 LAST.anum=1 _ERROR_=0 _N_=5
brkdndt=1mar94 vehicle=AAA anum=9 FIRST.vehicle=0 LAST.vehicle=0 FIRST.anum=1 LAST.anum=0 _ERROR_=0 _N_=6  <--AAA/9
brkdndt=2may94 vehicle=AAA anum=9 FIRST.vehicle=0 LAST.vehicle=1 FIRST.anum=0 LAST.anum=1 _ERROR_=0 _N_=7
brkdndt=1jul94 vehicle=BBB anum=9 FIRST.vehicle=1 LAST.vehicle=1 FIRST.anum=1 LAST.anum=1 _ERROR_=0 _N_=8  <--BBB/9
brkdndt=1may94 vehicle=CCC anum=8 FIRST.vehicle=1 LAST.vehicle=0 FIRST.anum=1 LAST.anum=0 _ERROR_=0 _N_=9  <--CCC/8
brkdndt=2may94 vehicle=CCC anum=8 FIRST.vehicle=0 LAST.vehicle=0 FIRST.anum=0 LAST.anum=0 _ERROR_=0 _N_=10
brkdndt=3may94 vehicle=CCC anum=8 FIRST.vehicle=0 LAST.vehicle=0 FIRST.anum=0 LAST.anum=0 _ERROR_=0 _N_=11
brkdndt=4XXXXX vehicle=CCC anum=8 FIRST.vehicle=0 LAST.vehicle=0 FIRST.anum=0 LAST.anum=0 _ERROR_=0 _N_=12
brkdndt=5XXXXX vehicle=CCC anum=8 FIRST.vehicle=0 LAST.vehicle=0 FIRST.anum=0 LAST.anum=1 _ERROR_=0 _N_=13
brkdndt=1may94 vehicle=CCC anum=9 FIRST.vehicle=0 LAST.vehicle=0 FIRST.anum=1 LAST.anum=0 _ERROR_=0 _N_=14
brkdndt=2dec94 vehicle=CCC anum=9 FIRST.vehicle=0 LAST.vehicle=1 FIRST.anum=0 LAST.anum=1 _ERROR_=0 _N_=15  <--CCC/9
*/



endsas;
data breakdwn;
 input brkdndt date7. +1 vehicle $char3.;
 format brkdndt date7.;
 cards;
2mar94  AAA
20may94 AAA
19jun94 AAA
29nov94 AAA
4jul94  BBB
31may94 CCC
24dec94 CCC
;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;

data brkkey;
   set breakdwn;
   by vehicle;
   retain first1;
   if first.vehicle then first1=_n_;
   if last.vehicle then
      do;
         last1=_n_;
         output;
      end;
run;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;

data _null_;
  set brkkey;
  do i=first1 to last1;
    put _all_;
  end;
run;
