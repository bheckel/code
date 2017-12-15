options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: file.sas
  *
  *  Summary: The FILE statement specifies the output file for PUT 
  *           statements.  By comparison, the INFILE statement specifies the
  *           input file for INPUT statements.
  *
  *           FILE refers to files to be written, INFILE refers to files to be
  *           read.
  *
  *           Also see put.sas, read_ds_write_txt.sas
  *
  *           In the SAS IDE FILE lets you write (save) a file, the complement
  *           of INCLUDE
  *
  *  Created: Thu 05 Jun 2003 14:26:56 (Bob Heckel)
  * Modified: Tue 06 Nov 2007 15:39:29 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data sample;
   input density  crimerate  state $ 14-27  stabbrev $ 29-30;
   cards;
264.3 3163.2 Pennsylvania   PA
51.2 4615.8  Minnesota      MN
55.2 4271.2  Vermont        VT
9.1 2678.0   South Dakota   SD
9.4 2833.0   North Dakota   ND
9.9 9678.0   South Dakota   SD
102.4 3371.7 New Hampshire  NH
120.4 4649.9 North Carolina NC
  ;
run;
proc sort;
  by state;
run;

data _NULL_;
  put 'goes to Log';
  /* SAS could have called the FILE fileref OUTFILE instead. */
  file PRINT;
  put 'reserved fileref, goes to List';
  file LOG;
  put 'back to Log';
run;

title 'should not show if NOTITLES is set';

 /* Output a comma delimited file. */
options pagesize=15;
data _NULL_;
  set sample;
  by state;
  ***file 'junk' FILENAME=fn DELIMITER=',' N=2 NOTITLES;
  ***file PRINT FILENAME=fn DELIMITER=',' N=2 NOTITLES;
  ***file PRINT FILENAME=fn DELIMITER=',' NOTITLES;
  mydelim='|';
  ***file PRINT FILENAME=fn DELIMITER=',' NOTITLES;
  file PRINT FILENAME=fn DELIMITER=mydelim NOTITLES;
  put state stabbrev density fn;
  put @5 state @30 stabbrev @50 density;
  if last.state then
    put 'theend' _PAGE_;
run;


filename FIRST 'junk';
filename SECOND 'junk2';
data _NULL_;
  set sample;

  file FIRST;
  put state;

  file SECOND DLM=',' DSD;
  put state stabbrev;
run;
