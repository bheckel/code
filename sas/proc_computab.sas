options NOsource;
  /****************************************************************/
  /*          SAS SAMPLE LIBRARY                                  */
  /*                                                              */
  /*    NAME: ctabex7                                             */
  /*   TITLE: COMPUTAB: Cash Flows                                */
  /* PRODUCT: ETS                                                 */
  /*  SYSTEM: ALL                                                 */
  /*    KEYS: financial reporting,                                */
  /*   PROCS: COMPUTAB                                            */
  /*    DATA:                                                     */
  /*     REF:                                                     */
  /*    MISC:                                                     */
  /* Adapted: Wed May 28 10:07:51 2003 (Bob Heckel)               */
  /****************************************************************/
options source;

 /* Example 6.7 Cash Flows */
 /* Chapter 6 page 320 */

data cashflow;
  input date date7. netinc depr borrow invest tax div adv ;
  cards;
30MAR82 65 42 32 126 43 51 41
30JUN82 68 47 32 144 45 54 46
30SEP82 70 49 30 148 46 55 47
30DEC82 73 49 30 148 48 55 47
  ;
run;

title1 'Blue Sky Endeavors';
title2 'Financial Summary';
title4 '(Dollar Figures in Thousands)';

proc computab data=cashflow;
  cols qtr1 qtr2 qtr3 qtr4 / 'Quarter' f=7.1;
  col  qtr1 / 'One';
  col  qtr2 / 'Two';
  col  qtr3 / 'Three';
  col  qtr4 / 'Four';
  row  begcash / 'Beginning Cash';
  row  netinc  / 'Income' '   Net income';
  row  depr    / 'Depreciation';
  row  borrow;
  row  subtot1 / 'Subtotal';
  row  invest  / 'Expenditures' '   Investment';
  row  tax     / 'Taxes';
  row  div     / 'Dividend';
  row  adv     / 'Advertising';
  row  subtot2 / 'Subtotal';
  row  cashflow/  skip;
  row  irret   / 'Internal Rate' 'of Return' zero=' ';
  rows depr borrow subtot1 tax div adv subtot2 / +3;

  retain cashin -5;

  _col_ = qtr(date);

  rowblock:

  subtot1 = netinc + depr + borrow;

  subtot2 = tax + div + adv;

  begcash = cashin;

  cashflow = begcash + subtot1 - subtot2;

  irret = cashflow;

  cashin = cashflow;

  colblock:
  if begcash then cashin = qtr1;

  if irret then 
    do;
      temp = irr( 4, cashin, qtr1, qtr2, qtr3, qtr4 );
      qtr1 = temp;
      qtr2 = 0; qtr3 = 0; qtr4 = 0;
    end;
run;
