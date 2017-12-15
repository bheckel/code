options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: footnote.sas
  *
  *  Summary: How to get more than 10 footnotes using a PROC REPORT hack.
  *
  *  Adapted: Tue 24 Apr 2012 13:22:19 (Bob Heckel -- SUGI 058-2011)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

options ps=20;

footnote 'normal';

proc report data=sashelp.shoes;
  column region sales;
  compute after _PAGE_;
    line @1 "[1] foot note1 ";
    line @1 "[2] foot note2 ";
    line @1 "[3] foot note3 ";
    /* ... */
    line @1 "[15]  foot note15";
  endcomp;
run;
