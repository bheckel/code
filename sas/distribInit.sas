
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process LIMS data
 *  DESIGN COMPONENT: Macro
 *  INPUT:            Method on which to distribute Initial storage condition
 *  PROCESSING:       Modify dataset to distribute the INT condition
 *  OUTPUT:           Modified input dataset
 *******************************************************************************
 */
%macro distribInit(meth);
  %local study study_num stor_cond nstudies numconds currcond;
  %let nstudies = 0;
  %let numconds = 0;

  proc sort NODUPKEY data=base_&meth out=sortedbase; 
    by study storage_condition;
  run;

  /* Determine studies with more than one storage_condition */
  data studylist(keep= study morethanone);
    set sortedbase;
    by study;

    if first.study then
      condcnt = 0;

    condcnt+1;

    if condcnt eq 2 then do;
      morethanone = 'Y';
      output studylist;
    end;
  run;

  data multcondits;
    merge sortedbase(in=in1) studylist(in=in2);
    by study;
    if in1 and morethanone eq 'Y';
  run;

  data _null_; 
    set multcondits; 
    where storage_condition ne 'INT';

    call symput('study_num'||compress(put(_N_,5.)), upcase(compress(study)));

    call symput('stor_cond'||compress(put(_N_,5.)), upcase(compress(storage_condition)));

    call symput('nstudies',put(_N_,5.));
  run;

  %if &nstudies gt 0 %then %do;
    %do l1 = 1 %to &nstudies;
      %local study_num&l1 stor_cond&l1;
    %end;
                                    
    data allcond;
      set multcondits(where=(upcase(compress(storage_condition)) eq 'INT'));
      %do i = 1 %to &nstudies;
        storage_condition= upcase(compress("&&stor_cond&i"));
        if study eq upcase(compress("&&study_num&i")) then 
          output allcond;
      %end;
    run;
  %end;
  %else %do;
    data allcond; 
      set multcondits;
      if upcase(compress(storage_condition)) ne 'INT' then 
        output allcond;
    run;
  %end;

  data allcond;
    set allcond nobs=numconds;
    obs+1;
    call symput('numconds', numconds);
  run;

  proc sql; create index study on base_&meth(study); quit;
  data base_&meth;
    merge base_&meth(in=in1) studylist(in=in2);
    by study;
    if in1;
  run;

  data base_&meth init; 
    set base_&meth;
    if upcase(compress(storage_condition)) ne 'INT' or morethanone ne 'Y' then 
      output base_&meth;
    else 
      output init;
  run;

  %local i;
  %if &numconds gt 0 %then %do;
    %do i = 1 %to &numconds;
      data _null_; 
        set allcond;
        /* Skip the '0's */
        where obs eq &i;
        call symput('currcond', storage_condition);
        call symput('study', study);
      run;

      data cond&i; 
        set init;
        where study eq "&study";
        storage_condition = "&currcond";
      run;
    %end;

    data base_&meth;
      set base_&meth %do i=1 %to &numconds;
                       cond&i
                     %end;
      ;
    run;
  %end;

  data base_&meth;
    length time_point $20;
    set base_&meth(drop= morethanone);
    if time_point eq 'INT' then
      time_point = '0';

    if storage_condition eq 'INT' then
      delete;
  run;
%mend distribInit;
