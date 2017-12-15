options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_report_group.sas
  *
  *  Summary: Demo of using proc report to group data.
  *
  *  Adapted: Wed 26 May 2010 10:39:32 (Bob Heckel--SUGI 079-2008 & hw07.pdf)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data mnthly_sales;
  length zip $ 5 cty $ 8 variety $ 10;
  input zip $ cty $ variety $ sales;
  label zip="Zip Code" cty="County" variety="Variety" sales="Monthly Sales";
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
grouped

  County  Zip                   Monthly
  Name    Code   Variety          Sales
  -------------------------------------
                                       
  Adams   52199  Merlot          233.03
                 Chardonnay      185.22
                 Zinfandel        95.84
          52200  Merlot          385.51
                 Chardonnay      322.24
                 Zinfandel       151.10
  Scott   52388  Merlot          122.89
                 Chardonnay       78.22
                 Zinfandel        15.40
          52423  Merlot          241.30
                 Chardonnay      156.61
                 Zinfandel        35.50
 */
proc report data=_LAST_ HEADLINE HEADSKIP;
  title 'grouped';
  column cty zip variety sales;
  define cty     / group width=6 'County/Name';
  define zip     / group;
  define variety / group order=freq descending;
  define sales   / format=6.2 width=10;
run;


/*
grouped by county and variety with means

  County              ---- Month Sale ----
  Name    Variety             N       MEAN
  ----------------------------------------
  Adams   Chardonnay          3  169.15333
          Merlot              2     309.27
          Zinfandel           2     123.47
  Scott   Chardonnay          2    117.415
          Merlot              3  121.39667
          Zinfandel           2      25.45
 */
proc report data=_LAST_ HEADLINE;
  title 'grouped by county and variety with count & means';
/***  column cty variety sales,MEAN;***/
  column cty variety sales,(N MEAN);
  define cty     / group width=6 'County/Name';
  define variety / group;
  define sales   / analysis '- Month Sale -';
run;


/*
grouped by DEFINE TYPES GROUP & ACROSS

  County  ------------ Variety -------------  ---- Month Sale ----
  Name    Chardonnay  Merlot      Zinfandel           N       MEAN
  ----------------------------------------------------------------
  Adams           3           2           2           7  196.13429
  Scott           2           3           2           7  92.845714
 */
proc report data=_LAST_ HEADLINE;
  title 'grouped by DEFINE TYPES GROUP & ACROSS';
/***  column cty variety sales,MEAN;***/
  column cty variety sales,(N MEAN);
  define cty     / group width=6 'County/Name';
  define variety / across '- Variety -';
  define sales   / analysis '< Month Sale >';
run;

