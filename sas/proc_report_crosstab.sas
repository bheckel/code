options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_report_crosstab.sas
  *
  *  Summary: Demo of using proc report to crosstabulate data.
  *
  *  Adapted: Wed 26 May 2010 10:39:32 (Bob Heckel--SUGI 079-2008)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data mnthly_sales;
  length zip $ 5 cty $ 8 var $ 10;
  input zip $ cty $ var $ sales;
  label zip="Zip Code" cty="County" var="Variety" sales="Monthly Sales";
  datalines;
52423 Scott Merlot 186.
52423 Scott Chardonnay 156.61
52423 Scott Zinfandel 35.5
52423 Scott Merlot 55.3
52388 Scott Merlot 122.89
52388 Scott Chardonnay 78.22
52388 Scott Zinfandel 15.4
52200 Adams Merlot 385.51
52200 Adams Chardonnay 246
52200 Adams Zinfandel 151.1
52200 Adams Chardonnay 76.24
52199 Adams Merlot 233.03
52199 Adams Chardonnay 185.22
52199 Adams Zinfandel 95.84
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

/*
                 --------- Grape Variety ----------
  County  Zip        Merlot  Chardonnay   Zinfandel
  Name    Code      Revenue     Revenue     Revenue
  -------------------------------------------------
                                                   
  Adams   52199      233.03      185.22       95.84
          52200      385.51      322.24      151.10
  Scott   52388      122.89       78.22       15.40
          52423      241.30      156.61       35.50
 */
proc report data=_LAST_ HEADLINE HEADSKIP;
  title 'crosstab';
  column cty zip var,sales;
  define cty / group width=6 'County/Name';
  define zip / group;
  define var / across order=freq descending ' - Grape Variety - ';
  define sales / analysis sum format=6.2 width=10 'Revenue';
run;
