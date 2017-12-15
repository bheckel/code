options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: convert_all_charvars_to_numvars.sas
  *
  *  Summary: Change all of the variables from character variables to numeric
  *           variables
  *
  *  Created: Tue 24 Jan 2006 10:40:24 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;


/* Get count of numeric variables */
data _null_ ;
  set old;
  array num _NUMERIC_ ;
  call symput('varcnt',dim(num)) ;
run;

/* Generate code to rename and drop the numeric vars */
data _null_ ;
  file 'c:\temp\temp.sas' ;
  set SASHELP.vcolumn ;
  where libname = 'WORK' & memname='OLD' & type = 'num';
  length line $ 80 ;
  line =  'drop ' || trim(name)  || ';' ;
  put line ;
  line =  'rename ' || trim(name)  ||
          ' = char' || trim(left(put(_n_,8.))) || ';' ;
  put line ;
run;

/* Set character values and include the drop/rename code */
data NEW ;
  set old;
  array num _numeric_ ;
  array char(&varcnt) $ ;
  %include 'c:\temp\temp.sas' ;
  do i = 1 to &varcnt ;
    char(i) = put(num(i),8.) ;
  end;
run;
