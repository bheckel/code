/* http://support.sas.com/kb/36/898.html */

/* Using the NLEVELS option beginning with SAS 9.2 along */
/* with the ODS SELECT statement to capture the NLEVELS. */
ods select nlevels;

title 'Number of distinct values for each variable'; 
proc freq data=sashelp.class nlevels;
  tables name age sex;
run; 

/* Using PROC SQL to count the number of levels for a variable. */

proc sql;
  create table new as 
  select count(distinct(name)) as namecount,
         count(distinct(age)) as agecount,
         count(distinct(sex)) as sexcount 
  from sashelp.class
  ;
quit;

title 'Number of distinct values for each variable'; 
proc print; run;
