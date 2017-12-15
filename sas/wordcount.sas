 /*---------------------------------------------------------------------------
  *     Name: wordcount.sas
  *
  *  Summary: Count number of words in a textfile.
  *
  *  Adapted: Mon 20 May 2002 10:03:22 (Bob Heckel -- Professional SAS
  *                                     Rick Aster)
  *---------------------------------------------------------------------------
  */
options linesize=92 pagesize=32767 nodate source source2 notes mprint
        symbolgen mlogic obs=max errors=5 nostimer number serror merror
        noreplace datastmtchk=allkeywords;

title; footnote;

data _NULL_;
  length word $ 64;  * TODO is this an arbitrary max length of word?;
  infile 'testdoc.txt' eof=EOF flowover;

  input word @@;
  * Like traditional wc utility;
  ***count + 1;
  * If word has to contain at least one letter;
  if indexc(word, 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz') then
    count + 1;

  return;

  EOF: 
  * Print to LOG;
  put 'Word count: ' count :comma14.;
  * Carriage return (decimal 13), linefeed (decimal 10);
  put '13'x;
  put '10'x;
  stop;
run;
