
 /* Note: "NMissLevels" indicates AT LEAST ONE missing but displays a '1' e.g. 2 Mazdas have missing cylinders */
proc freq data= SASHELP.cars nlevels;
  tables _ALL_ / noprint;
  *ods output nlevels=WORK.nlevels;
run;


title '...............compare';

/*
	Name:        getcardinality macro
	Purpose:     Calculate cardinality and percent-unique for each
               variable in input data set
	Results:     Output data set with cardinalities per variable
	             (Optional) ODS report for display
	Usage:  %getcardinality(inputDataSet, outputDataSet, createReport);
	          inputDataSet:   LIBREF.MEMBER of input data
	          outputDataSet:  LIBREF.MEMBER location of new data to create with summary
	          createReport:   1: create a report, 0: do not create report
	Sample:
      %getcardinality(SASHELP.CARS, WORK.CARDS, 1);
*/
%macro getcardinality(inputData, outputData, createReport);
	%local cnt tot outlib outds;
	%let outlib=%sysfunc(substr(&inputData.,1,%sysfunc(index(&inputData.,.))-1));
	%let outds =%sysfunc(substr(&inputData.,1+%sysfunc(index(&inputData.,.))));

	/* Assemble list of variables from data */
	/* Keep track of their attributes       */
	proc datasets library=&outlib. nolist;
		contents data=&outds. out=work._ds_variables(keep=name type format length) noprint;
	run;

	quit;

	/* Count the records in input (for percentage calc) */
  data _null_;
    set &outlib..&outds. nobs=total;
    call symput('tot',strip(total));
    stop;
  run;

/* Count number of variables */
  data _null_;
    set work._ds_variables nobs=total;
    call symput('cnt',strip(total));
    stop;
  run;

  /* NOTE: 9.3 and later you can use :char1- open-ended */
  /* and &sqlobs to count variables */ 
  proc sql noprint;
    select trim(name) into :char1-:char&cnt. from work._ds_variables;
  quit;

  /* Use PROC FREQ and NLEVELS for each variable */
  ods output nlevels=work.char_freqs;
  ods noproctitle;
  title "Summary of levels in &outlib..&outds.";

  proc freq data=&outlib..&outds. nlevels;
    tables
      %do i=1 %to &cnt.;
    &&char&i.
    %end;
    / noprint;
  run;

  ods proctitle;

  /* Create output data for result */
  proc sql noprint;
    create table &outputdata. as
      select c.*, 
        ifc(c.type=1,'Numeric','Character') label='Type' as vartype ,
        r.nlevels, r.nlevels / &tot. as PCT_UNIQUE format=percent9.1
      from work._ds_variables c, work.char_freqs r
        where c.name=r.tablevar
          order by r.nlevels descending;
    drop table work._ds_variables;
    drop table work.char_freqs;
  quit;

  /* Optionally create the report */
  %if (&createReport) %then
    %do;
      title "Cardinality of variables in &outlib..&outds.";
      title2 "Data contains &tot. rows";
      proc print data=&outputData. label noobs;
        label NLevels="Cardinality" pct_unique="Pct Unique";
        var name vartype length format nlevels pct_unique;
      run;

    %end;
%mend;

%getcardinality(SASHELP.CARS, WORK.CARDS, 1)
