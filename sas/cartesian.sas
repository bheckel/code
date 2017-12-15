options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: cartesian.sas
  *
  *  Summary: Not always useless - if we want to know all possible combinations.
  *
  *           E.g. One such a case is where you want to create a list of all
  *           the possible screws that could be manufactured. You have several
  *           different characteristics for a screw. Some of the
  *           characteristics are head type, material, and size. You want a
  *           table with all the possible combinations of these
  *           characteristics.
  *
  *           This is hard to do without using PROC SQL
  *
  *           DATA CART(rename=(ID1=ID) drop=ID);
  *             SET ONE (rename=(ID=ID1));
  *             DO i=1 TO NN;
  *               SET TWO point=i nobs=NN;
  *               OUTPUT;
  *             END;
  *           RUN;
  *
  *  Adapted: Fri 08 Apr 2005 17:19:54 (Bob Heckel - TS800 Mal Foley)
  * Modified: Wed 08 Mar 2006 15:21:08 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data h;
  input head $;
  cards;
Pan
Flat
Oval
  ;
run;
data m;
  input matl $;
  cards;
Brass
Steel
  ;
run;
data s;
  input size $;
  cards;
#6
#8
  ;
run;

proc sql;
  select * 
  from h, m, s
  ;
quit;

proc sql;
  select *
  from h a, h b, h c
  ;
quit;


 /****************************************************************/ 
 /*          S A S   S A M P L E   L I B R A R Y                 */ 
 /*                                                              */ 
 /*    NAME: SQLFUN07                                            */ 
 /*   TITLE: Demonstrates Use of Cartesian Product with PROC SQL */ 
 /* PRODUCT: BASE                                                */ 
 /*  SYSTEM: ALL                                                 */ 
 /*    KEYS: SQL DATMAN SELECT WHERE ORDER BY CREATE TABLE       */ 
 /*   PROCS: SQL                                                 */ 
 /*    DATA:                                                     */ 
 /* SUPPORT: pmk                         UPDATE:                 */ 
 /*     REF:                                                     */ 
 /*    MISC: this example was contributed by Howard Schreier     */ 
 /*          of the US Dept. of Commerce, via BITNET             */ 
 /*                                                              */ 
 /*          it demonstrates a case where the cartesian          */ 
 /*          product formed by an SQL join is useful.            */ 
 /*                                                              */ 
 /*          you can contribute your interesting samples.        */ 
 /*          send internet email to KENT@UNX.SAS.COM or          */ 
 /*          USmail to SAS Institute.                            */ 
 /*                                                              */ 
 /* Adapted: Fri 01 Nov 2013 10:48:29 (Bob Heckel)               */
 /****************************************************************/ 
 /* 
  * A User asked: 
  * 
  *  I have the following data set: 
  * 
  *          VAR             POSANS 
  *          0001            010203041213 
  *          0006            04012425 
  *          0003            030608 
  * 
  * 
  *  POSANS is a list of the possible responses to VAR. Each 
  *  response has a length of 2.  TOTRESP is the total number 
  *  of possible responses. What I need to do is to create another 
  *  data set of all the possible combinations of responses to 
  *  these three variables. 
  * 
  */ 
 
 
 /* 
  * Here is one way to  tackle  the  problem.   The  first  step 
  * breaks  out the substrings, as in your code, and creates one 
  * observation for each (6+4+3=13 in total): 
  * 
  */ 
 
   data forsql; 
/***     length posans $20.; ***/
     input var $ posans :$20.; 
     keep var ans; 
     do i = 1 to length(posans)-1 by 2; 
        ans = substr(posans,i,2); 
        output; 
        end; 
     cards; 
0001  010203041213 
0006  04012425 
0003  030608 
; 
run;
proc print data=_LAST_(obs=max) width=minimum; run;
/*
Obs    var     ans

  1    0001    01 
  2    0001    02 
  3    0001    03 
  4    0001    04 
  5    0001    12 
  6    0001    13 
  7    0006    04 
  8    0006    01 
  9    0006    24 
 10    0006    25 
 11    0003    03 
 12    0003    06 
 13    0003    08 
*/
 
 /* 
  * Now, use SQL to form the combinations: 
  * 
  * The three SELECT clauses in  parentheses  set  up  temporary 
  * tables,  one  for  each  VAR value; these are then joined to 
  * form the 6x4x3=72 combinations. 
  * 
  */ 
 
   proc sql; 
   create table matrix as select * from 
    (select ans as ans0001 from forsql where var='0001'), 
    (select ans as ans0006 from forsql where var='0006'), 
    (select ans as ans0003 from forsql where var='0003') 
    order by ans0001, ans0006, ans0003 
    ; 
 
 
 /* 
  * display the result 
  * 
  */ 
 
   title2 'All possible combinations'; 
   select * from matrix; 
   quit; 
/*
ans0001               ans0006               ans0003
----------------------------------------------------------------
01                    01                    03                  
01                    01                    06                  
01                    01                    08                  
01                    04                    03                  
01                    04                    06                  
01                    04                    08                  
01                    24                    03                  
01                    24                    06                  
01                    24                    08                  
01                    25                    03                  
01                    25                    06                  
01                    25                    08                  
02                    01                    03                  
02                    01                    06                  
02                    01                    08                  
02                    04                    03                  
02                    04                    06                  
02                    04                    08                  
02                    24                    03                  
02                    24                    06                  
02                    24                    08                  
02                    25                    03                  
02                    25                    06                  
02                    25                    08                  
03                    01                    03                  
03                    01                    06                  
03                    01                    08                  
03                    04                    03                  
03                    04                    06                  
03                    04                    08                  
03                    24                    03                  
03                    24                    06                  
03                    24                    08                  
03                    25                    03                  
03                    25                    06                  
03                    25                    08                  
04                    01                    03                  
04                    01                    06                  
04                    01                    08                  
04                    04                    03                  
04                    04                    06                  
04                    04                    08                  
04                    24                    03                  
04                    24                    06                  
04                    24                    08                  
04                    25                    03                  
04                    25                    06                  
04                    25                    08                  
12                    01                    03                  
12                    01                    06                  
12                    01                    08                  
12                    04                    03                  
12                    04                    06                  
12                    04                    08                  
12                    24                    03                  
12                    24                    06                  
12                    24                    08                  
12                    25                    03                  
12                    25                    06                  
12                    25                    08                  
13                    01                    03                  
13                    01                    06                  
13                    01                    08                  
13                    04                    03                  
13                    04                    06                  
13                    04                    08                  
13                    24                    03                  
13                    24                    06                  
13                    24                    08                  
13                    25                    03                  
13                    25                    06                  
13                    25                    08                  
*/
