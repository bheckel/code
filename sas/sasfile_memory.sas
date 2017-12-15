options nosource;
 /*---------------------------------------------------------------------------
  *     Name: sasfile_memory.sas
  *
  *  Summary: Load a dataset into memory.  Good for using the same, large 
  *           ds in many steps and procs.
  *
  *           Statement is only for reading or updating data. If you want to
  *           rebuild/rewrite a data set that's been opened with SASFILE using
  *           the DATA step, or change the descriptor portion using the
  *           DATASETS procedure, or use any other procedure that rebuilds
  *           your data set, you need to close it with another SASFILE
  *           statement first.
  *
  *  Adapted: Wed 13 Nov 2002 16:32:25 (Bob Heckel -- SAS Programming
  *                                     Shortcuts Rick Aster p. 354)
  * Modified: Thu 20 Mar 2003 15:26:13 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data work.sample;
  input fname $1-10  lname $15-25  @30 numb 3.;
  datalines;
mario         lemieux        123
jerry         garcia         123
richard       dawkins        345
richard       feynman        678
  ;
run;

 /* Make sure your ds won't use up all available memory.  Calc 'Data Set Page
  * Size' x 'Number of Data Set Pages' to get bytes used.
  */
proc contents; run;

 /* Load a dataset into memory.  Better for servers.  See proc server */
***SASFILE work.sample LOAD;
 /* Load a dataset into memory only when dataset is used. */
SASFILE work.sample OPEN;
data work.sample2;
  set work.sample;
run;
proc print; run;
SASFILE work.sample CLOSE;
