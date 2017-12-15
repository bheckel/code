options nosource;
 /*---------------------------------------------------------------------
  *     Name: htmlencode.sas
  *
  *  Summary: Demo of using a htmlencode to prepare data for
  *           HTMLification.
  *
  *  Adapted: Fri 27 Sep 2002 08:43:41 (Bob Heckel -- SAS Online Docs)
  *---------------------------------------------------------------------
  */
options linesize=72 pagesize=32767 nocenter date nonumber noreplace
        source source2 notes obs=max errors=5 datastmtchk=allkeywords 
        symbolgen mprint mlogic merror serror
        ;
title; footnote;

data _NULL_;
  x1=htmlencode('no special characters here');
  x2=htmlencode('<I want literal angle brackets in my HTML  >');
  x3=htmlencode('&');
  x4=htmldecode(x2);
  put x1;
  put x2;
  put x3;
  put x4;
run;
