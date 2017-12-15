options NOreplace;

 /* Make a quick local backup of an Oracle table prior to making destructive
  * changes.
  */
 
 /***** EDIT *****/
***%let db=sdev388;
***%let usr=ks;
***%let pw=ev123dba;

%let db=sprd409;
%let usr=ks_user;
%let pw=ksu409;

%let tbl=samp;
%let saveto='c:/temp';  /* must be quoted */
 /***** EDIT *****/


libname l &saveto;
libname ORA oracle user=&usr password=&pw path=&db;

proc sql;
  create table l.samp_&db._&SYSDATE as
  select *
  from ORA.&tbl
  ;
quit;
