options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: strip.sas
  *
  *  Summary: Comparison of string blank handling
  *
  *  Adapted: Thu 18 Jan 2018 11:34:22 (Bob Heckel -- SAS Communities post)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

data t;
   /* length text $15; */
   /* Need this for cats otherwise 200 char default */
   length text cat $15;  /* 1 too short for demo purposes */

   format text $char15.;
   text = '  ab   cde  f   ';

   none = '*' || text || '*';
   cat = cats('*', text, '*');
   trim = '*'||trim(text)||'*';
   compress = '*'||compress(text)||'*';
   strip = '*'||strip(text)||'*';

   put @6 none= ;
   put @7 cat= ;
   put @6 trim= ;
   put @2 compress= ;
   put @5 strip=;
run;
/*
     none=*  ab   cde  f
      cat=*ab   cde  f*
     trim=*  ab   cde  f*
 compress=*abcdef*
    strip=*ab   cde  f*
*/

proc contents; run;
