
 /* If output can't have quotes around char vars like ODS does by default, use this: */
proc export outfile="&path.&sp_name./&jobtype./&daten_exec./Output/imm_del_&daten_exec._&clid._&type..csv" data=del_&type dbms=dlm replace;
  delimiter='|';
  putnames=no;
run;



 /* Can't use (drop=foo), see ODS instead */
proc export data=&OUTPUTFILE OUTFILE="&OUTPUTDIR\&OUTPUTFILE..csv" DBMS=CSV LABEL REPLACE; run;


%macro bobh0903093409; /* {{{ */
proc export data=sasuser.cust
  outtable="customers"
  dbms=access replace;
  database="c:\myfiles\mydatabase.mdb";
run;



proc export data=VenHFA_analytical_individuals 
  OUTFILE= "\\rtpsawnv0312\pucc\VENTOLIN_HFA\Output Compiled Data\CSV VenHFA_analytical_individuals.csv" 
  DBMS=CSV replace;
run;
%mend bobh0903093409; /* }}} */


 /* If proc export is not available or need VAR & WHERE statements option A: */
data _null_;
  file "junk.csv";
  set SASHELP.shoes;
  put (_all_) (',');
run;



 /* If proc export is not available or need VAR & WHERE statements option B:
  * Better, it doublequotes char vars.
  */
ODS CSV file='junk2.csv';
proc print data=SASHELP.shoes NOOBS; run;
ODS CSV close;
