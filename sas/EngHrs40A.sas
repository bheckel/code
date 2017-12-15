 /*------------------------------------------------------------------*
  |                  EngHrs40A.sas                                   |
  |                                                                  |
  | Summary:  Takes COSTTIME and creates a temporary                 |
  |           dataset then sorts and sums for < 40 hr engineers.     |
               MUST 3 CHANGE DATES!!
  |                 Created 9Jan98 (RSH)   Modified 09Mar98 (RSH)    |
  *------------------------------------------------------------------*/

   options linesize=80 pagesize=32767 notes error=3 obs=max nonumber source;

   title "Engineers Submitting < 40 Hours for a Specific Production Week";
   footnote;

   data temp1;
     set DART.COSTTIME;
     where PROD_WK=9814;     /* 2 wks. prior to current wk. */
   run;


   data temp2;
     set temp1;
     where CONT_IND in('N', ' ', '') and
          EMP_CLS in('DFT', 'EAE', 'FE', 'PAE', 'PJE', 'SAE', 'SDE', 'SSE') and
          EMP_STAT='A';
    run;


    proc sort data=temp2;
      by EMP_NBR;
    run;


    /***proc sql;
      select EMP_NBR, sum(HOURS) from temp2
      group by EMP_NBR
      having sum(HOURS)<40;
    quit;***/


    proc means data=temp2 noprint;
      by EMP_NBR;
      var HOURS;
      output out=temp3 sum=LESSFRTY;
    run;


    data temp4;
      merge temp2 temp3;
      by EMP_NBR;
      if (LESSFRTY<40);
    run;


    proc sort data=temp4 out=temp5;             /* Do I need this sort? */
      by EMP_DEPT;
    run;


    proc sort data=temp5 nodupkey out=temp6;
      by EMP_NBR LESSFRTY;
    run;

    proc sort data=temp6;
      by EMP_DEPT;
    run;

    proc printto file='/DART/users/bh1/Eng40Hrs/9814OUT';

    proc print data=temp6 noobs split='*';
      by EMP_DEPT;
      var LNAME FNAME LESSFRTY;
      label LESSFRTY = 'Hrs Submitted*For Wk9814';
    run;

    proc printto;
    run;

    /*==================================EOJ===============================*/
