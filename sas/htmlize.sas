/*----------------------------------------------------------------------------
 * Program Name: htmlize.sas
 *
 *      Summary: Turn dataset into HTML page.  From Semicolon June 1999.
 *
 *               See ~/code/sas/ods_html.sas for an ODS approach
 *
 *      Adapted: Fri, 05 Nov 1999 09:11:26 (Bob Heckel)
 *----------------------------------------------------------------------------
 */
options linesize=80 pagesize=32767 nodate source source2 notes mprint
        symbolgen mlogic obs=max errors=5 nostimer number serror merror
        noreplace;

title; footnote;

data work.demo;
  infile cards missover;
  input name $  sales  commiss;
  cards;
Sales1 1000 1.343
Sales2 2000 2.343
Sales4 3000 3.347
Sales3 4000 4.349
;
run;

data _null_;
  set work.demo (obs=3) end=lastone;
  file '~/test.html' notitle;

  if _N_ = 1 then put 
    '<html>'/
    '<title>Acme Sales Leaders</title>'/
    '<h2>Top 5</h2>'/
    '<body>'/
    '<pre>'/
    @1 'Name'
    @25 'Total sale'
    @45 'Commis';

  put @1 name
      @25 sales comma11.
      @45 commiss comma10.2;

  if lastone then put
    '</pre>'/
    'Copyright 1999.'/
    '</body>'/
    '</html>';
run;

