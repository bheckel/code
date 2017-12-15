options nosource;
 /*---------------------------------------------------------------------------
  *     Name: print_header_title.sas
  *
  *  Summary: Print a header line above the data lines to get the
  *           functionality of TITLE when writing a file.
  *
  *  Created: Thu 16 Jan 2003 13:05:07 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data work.sample;
  input fname $1-10  lname $15-25  @30 numb 3.;
  datalines;
mario         lemieux        123
jerry         garcia         123
richard       feynman        678
  ;
run;


data _NULL_;
  set work.sample;

  file PRINT HEADER=myhdrgoto;
  put @1 fname  @20 numb;
  return;  /* avoid a header line for each obs. */

  myhdrgoto:
    put @1 'TitleFname'  @20 'Title Numb' /
        @1 '=========='  @20 '==========';
run;
