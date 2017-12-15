 /*---------------------------------------------------------------------------
  *     Name: file_print_custom.sas
  *
  *  Summary: Write a custom report with FILE and PUT statements to an
  *           external file.
  *
  *  Adapted: Thu 11 Apr 2002 14:41:23 (Bob Heckel -- Little SAS Book sect 4.8)
  * Modified: Tue 24 Jan 2012 15:12:57 (Bob Heckel)
  *---------------------------------------------------------------------------
  */

data _NULL_;
  input Name $ 1-11 Class @15 DateReturned MMDDYY10. CandyType $ Quantity;
  Profit = Quantity * 1.25;
  /* Print to external file.  junk need not exist already. */
  file 'junk' PRINT;
  /* PUT tells SAS exactly what to write and where, like an INPUT statement in
   * reverse.  Name, Class, Quantity are list style.  Profit is formatted
   * style.  Slash is a carriage return.
   */
  put @1 'BEGIN';
  put @5 'Candy sales report for ' Name 'from classroom ' Class
      // @5 'Congratulations!  You sold ' Quantity 'boxes of candy' /
      @5 'and earned ' Profit DOLLAR6.2 ' for our field trip.';
  put _PAGE_;   /* page break */

  cards;
Adriana    21  3/21/2000 MP  7
Nathan     14  3/21/2000 CD 19
Matthew    14  3/21/2000 CD 14
Claire     14  3/22/2000 CD 11
Caitlin    21  3/24/2000 CD  9
Ian        21  3/24/2000 MP 18
Chris      14  3/25/2000 CD  6
Anthony    21  3/25/2000 MP 13
Stephen    14  3/25/2000 CD 10
Erika      21  3/25/2000 MP 17
  ;
run;

data _NULL_;
  infile 'junk';
  file 'junk';
  /* TODO how to append to last line of old file (MOD doesn't seem to work? */
  put 'i forgot to add this line (appends to first line of old file)' /
      'u forgot to add this line'
      ;
run;
 /* Now can  $ vi junk  */


 /* Goes back to file LOG default (from file PRINT). */
data work.sample;
   input Density CrimeRate State $ 14-27 PostalCode $ 29-30;
   cards;
264.3 3163.2 Pennsylvania   PA
51.2 4615.8  Minnesota      MN
120.4 4649.9 North Carolina NC
  ;
run;
proc print; run;


endsas;
  /* Can't use PROC EXPORT - requirements specify custom headers */
  data _null_;
    set &OUTPUTFILE;
    file "&DPPATH\&OUTPUTDIR\&OUTPUTFILE..csv" DLM=',' lrecl=32676;
    if _N_ eq 1 then do;
      put 'Index,Product,Material-Batch Number,Manufacture Date,Test Method Description,' @;
      put 'Numeric Result,Numeric Results (units),Device,Impactor #,Character Result,Method Number,' @;
      put 'LIFT Data Status,Test Date,Analyst,Blend Number,Blend Nbr Manufacture Date,' @;
      put 'Blend Nbr Description (MDPI ONLY),Fill Number,Fill Nbr Manufacture Date,Fill Nbr Description (MDPI ONLY),' @;
      put 'Assembled Number,Assembled Nbr Manufacture Date,Assembled Nbr Description (MDPI ONLY)';
    end;
    put (_ALL_)(+0);
  run;
