options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: grep_datasets_in_dir.sas
  *
  *  Summary: Search for string in all datasets in a directory, returning
  *           the dsname(s) on success.
  *
  *  Adapted: Wed 12 Mar 2014 09:03:28 (Bob Heckel--http://support.sas.com/kb/50/806.html?appid=37935)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

%macro grep_datasets_in_dir(dir, searchstr, dsn);
  %local filrf librf rc1 rc2 rc3 rc4 did memcnt nvars i varlist extens basename dsid typ;
  data &dsn;
    stop;
  run;
 
  %let filrf=mydir;
  %let librf=temp;
 
  /* Assigns the libref of temp to the directory passed in */
  %let rc1=%sysfunc(libname(&librf,&dir));
 
  /* Assigns the fileref of mydir to the directory passed in */
  %let rc2=%sysfunc(filename(filrf,&dir));
 
  /* Opens the directory to be read */
  %let did=%sysfunc(dopen(&filrf));
 
  /* Returns the number of members in the directory passed in */
  %let memcnt=%sysfunc(dnum(&did));
  %put !!!searching &memcnt datasets;
 
  %let nvars=0;
  %do i = 1 %to &memcnt;
    %let varlist=;
 
    /* Return the extension of the dataset found */
    %let extens=%qupcase(%qscan(%sysfunc(dread(&did,&i)),2,.));
 
    /* Return the first name of the dataset found */
    %let basename=%qscan(%qsysfunc(dread(&did,&i)),1,.);
 
    %if %upcase(&extens) eq SAS7BDAT %then %do;
      %let dsid=%sysfunc(open(&librf..&basename));
 
      /* The variable nvars will contain the number of variables that are in
       * the dataset that is passed in
       */
      %let nvars=%sysfunc(attrn(&dsid,nvars));
 
      /* Create a macro variable that contains all dataset character variables */
      %do ii = 1 %to &nvars;
        %let typ=%sysfunc(vartype(&dsid,&ii));
        /* Looking for only character variables */
        %if &typ eq C %then %do;
          %let varlist=&varlist %sysfunc(varname(&dsid,&ii));
          %put !!!&varlist;
        %end;
        %let cntvars=%sysfunc(countw(%bquote(&varlist)));
      %end;
 
      %let rc3=%sysfunc(close(&dsid));
 
      /* If the searchstr was found run this step */
      %if %superq(varlist) ne  %then %do;
        data final(keep=datasetname);
          length datasetname $ 30;
          set &librf..&basename;
           %do j=1 %to &cntvars;
             if %scan(&varlist,&j) = "&searchstr" then do;
               datasetname="&basename";
               output;
               stop;
             end;
           %end;
        run;
 
        data &dsn;
          length datasetname $ 30;
          set &dsn final;
        run;
      %end;
    %end;
  %end;

  %let rc4=%sysfunc(dclose(&did));

%mend grep_datasets_in_dir;

 /* TODO recurse a dir */
 /* TODO wildcarding */
%grep_datasets_in_dir(C:\datapost\data\GSK\Zebulon\SolidDose\zantac, Content Uniformity Level Evaluated, TMPgrep_datasets_in_dir)

proc print data=TMPgrep_datasets_in_dir; run;
