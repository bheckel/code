
 /* 2010-04-20 
  *  Hi All,
  *  Tammy and I met this morning and we have agreed on a few changes.  We
  *  would like the individuals and individual specs removed from the plots.
  *  This should fix our 'Y-axis' issues.  We would like to add standard
  *  deviation plots for all tests.  This will allow us to monitor the
  *  variation in our data over time.  Additionally, the plots representing the
  *  difference in beginning and end of use do not display negative values
  *  (which we know exist).  We are assuming this is due to that axis being
  *  predefined.  We would like to request that no axis be predefined.  This is
  *  what we think will work for now.  We will assess again after a few
  *  meetings to ensure it meets our needs.
  *  Thanks!
  *  Nikki
  */
%macro build(prodname, dsn, varname, strength, duration, duration_string, dateSort, minMeanSpec, maxMeanSpec, minSpec, maxSpec, statlbl, stat);
  data &dsn._&duration._release;
    set INPUTDIR.&dsn._all_data;

    if studyID='Release' and test_date>'01MAY2006'd and index(product_desc,"&strength");

    batchDate = mfg_batch||put(test_date,date7.);

    %if &duration eq oneyear %then %do;
      if test_date gt (today()-365);
    %end;

    %if %upcase(&varname) eq AS_DIFF_DTU %then %do;
      AS_DIFF_DTU = AS_END_DTU-AS_BEG_DTU;
    %end;
    %else %if %upcase(&varname) eq AS_CI_TOTAL_EXDEVICE %then %do;
      AS_CI_Total_ExDevice = AS_CI_SUM345 + AS_CI_SUM012 + AS_CI_SUM67F + AS_CI_Throat;
    %end;
  run;

  /* Calculate means by mfg_batch */
  proc sort data=&dsn._&duration._release;
    by mfg_batch test_date;
  run;
  proc means data=&dsn._&duration._release noprint;
    by mfg_batch test_date;
    var &varname;
    output out=&dsn._&duration._release_&stat(drop= _type_ _freq_) &stat=&statlbl.&varname;
  run;
  /* Combine means with individual values */
  data &dsn._&duration._MI;
    merge &dsn._&duration._release &dsn._&duration._release_&stat;
    by mfg_batch test_date;
  run;

  proc sort data=&dsn._&duration._MI(keep = test_date) out = sortedList_&duration;
    by descending test_date;
  run;
  data maxDate_&duration;
    format max_date DATE8.; 
    set sortedList_&duration(obs=1);
    max_date=test_date;
    call symput("max_date_&duration", max_date);
  run;

  proc sort data=&dsn._&duration._MI; 
    by test_date mfg_batch;
  run;
  data &dsn._&duration._MIsorted; 
    RETAIN BATCHOBS 0; 
    FORMAT BATCHN $10.; 
    SET &dsn._&duration._MI; 
    BY test_date mfg_batch;

    if first.mfg_batch then  BATCHOBS+1; 
    /* make the batchCounter (batchobs) into sortable by alphanumeric: '1' = '01' */
    if batchobs <10 then batchN="0"||left(TRIM(substr(LEFT(BATCHOBS),1)))||"0";
    else if batchobs>99 then batchN="99"||left(TRIM(substr(LEFT(BATCHOBS),1)));
    else batchN=left(TRIM(substr(LEFT(BATCHOBS),1)))||"0";

    keep batchn batchDate mfg_batch test_date &varname &statlbl.&varname datastatus;
  run;

  /* Create format for sorting index */
  DATA FORMATdata;
    length  START  $10.
    label   $20.
    FMTNAME  $8.
    ;
    SET &dsn._&duration._MIsorted;
    RETAIN FMTNAME;
    FMTNAME = "$batch";
    IF _N_ = 1 THEN DO;  
      HLO = 'O'; LABEL = ''; START = ' '; OUTPUT; HLO = ' '; 
    END;
    START = BATCHn;
    LABEL=batchDate;
    KEEP START LABEL HLO FMTNAME;
    OUTPUT;
  RUN;
  proc sort NODUPKEY data=FORMATdata;
    by FMTNAME START HLO;
  run;
  proc format CNTLIN=FORMATdata;
  run;

  %macro plotter();
     data _null_;
       today_date = today();
       call symput('today_date', put(today_date, DATE8.)); 
     run;

     /* Approved vs. unapproved setup */
     proc sort data=&dsn._&duration._MIsorted(keep=datastatus) out=outfreq_&duration;
       by descending datastatus;
     run;
     data outfreq_&duration;
       set outfreq_&duration(obs=1);
       App_status=datastatus;
       call symput('App_status',App_status);
     run;
     proc format;
       value $appstat 'A' = 'Approved'
                      'I' = 'Unapproved'
                      ;
     run;

     /* Min max of averages setup */
     proc sort data=&dsn._&duration._MIsorted NODUPKEY; by batchN mfg_batch; run;

     proc means data=&dsn._&duration._MIsorted noprint;
       var &statlbl.&varname;
       output out=MinMax_&duration(drop= _type_ _freq_) min=minData max=maxData;
     run;

     data MinMax_&duration;
       set MinMax_&duration;

       if maxData eq . then maxData = 0;
       if minData eq . then minData = 0;
       yinc = (maxData-minData)*0.1;

       /* Y-axis minimum */
       if (minData lt &minMeanSpec or &minMeanSpec eq -99) then
         minPlot = minData-yinc;
       else
         minPlot = &minMeanSpec-yinc;

       /* Y-axis maximum */
/***       _max = max(maxData, &maxSpec, &maxMeanSpec);***/
       _max = max(maxData, &maxMeanSpec);
       maxplot = _max + yinc;
       put '!!! ' (_ALL_)(=);  /* for debugging */
       if maxplot eq . then maxplot = 0;

       call symput('minplot', minplot);
       call symput('maxplot', maxplot);

       call symput('yincrement',yinc);
     run;

    /* Don't plot anything if we're missing data */
    %if &yincrement gt 0 %then %do;
      %if &App_status = A %then %Approved;
      %else %Unapproved;
    %end;
  %mend plotter;

  goptions dev=cgmmw6c rotate=landscape htext=0.70 hsize=0 vsize=0 gsfname=gsf2 gsfmode=replace;

  %if %upcase(&dateSort) eq MFG and %upcase(&stat) eq MEAN %then %do;
    filename gsf2 "&OUTCGMS\&varname._&duration._mfg.cgm";
  %end;
  %else %if %upcase(&dateSort) eq TEST and %upcase(&stat) eq MEAN %then %do;
    /* Implied Test date is the default convention for the plots */
    filename gsf2 "&OUTCGMS\&varname._&duration..cgm";
  %end;
  %else %if %upcase(&dateSort) eq MFG and %upcase(&stat) eq STD %then %do;
    filename gsf2 "&OUTCGMS\&varname._&duration._mfg_&statlbl..cgm";
  %end;
  %else %if %upcase(&dateSort) eq TEST and %upcase(&stat) eq STD %then %do;
    /* Implied Test date is the default convention for the plots */
    filename gsf2 "&OUTCGMS\&varname._&duration._&statlbl..cgm";
  %end;
  %else %do;
    %put ERROR: cannot determine output filename;
  %end;

  %macro OLDApproved; /*{{{*/
    proc gplot data=&dsn._&duration._MIsorted;
      title1 h=1.75 "&prodname &strength [ &varname ] by &dateSort date (&duration)";

      footnote1 h=0.70 "Plot created &today_date";
      footnote2 ' ';  /* cosmetic - add space to bottom of graph */

      symbol1 i=none w=0.25 h=0.25 v=dot  c=blue;
      symbol2 i=none w=1.25 h=1.25 v=dot  c=green interpol=join;

      axis1 label=NONE order=(&minPlot to &maxPlot by &yincrement) major=none minor=none;
      axis2 label=NONE value=(height=0.65);
      axis3 label=NONE order=(&minPlot to &maxPlot by &yincrement) value=none major=none minor=none;
      axis4 label=NONE value=(height=0.65);

      plot &varname.*batchn / vaxis=axis1 haxis=axis2 frame
			      vref=&minMeanSpec &maxMeanSpec &minSpec &maxSpec
			      lvref=(3 3 2 2)
			      cvref=(green,green,blue,blue) NOlegend
			      ;

      plot2 avg&varname.*batchn / vaxis=axis3 haxis=axis4 frame
				  vref=&minMeanSpec &maxMeanSpec &minSpec &maxSpec
				  lvref=(3 3 2 2)
				  cvref=(green,green,blue,blue) NOlegend
				  ;
      format batchn $batch.;
    run;
    quit;
  %mend OLDApproved;/*}}}*/
  %macro Approved; 
    proc gplot data=&dsn._&duration._MIsorted;
      title1 h=1.75 "&prodname &strength [ &varname ] &statlbl by &dateSort date (&duration)";

      footnote1 h=0.70 "Plot created &today_date";
      footnote2 ' ';  /* cosmetic - add space to bottom of graph */

      symbol1 i=none w=0.35 h=0.35 v=dot c=green interpol=join;;

      axis1 label=NONE order=(&minPlot to &maxPlot by &yincrement) major=none minor=none;
      axis2 label=NONE value=(height=0.65);

      plot &statlbl.&varname.*batchn / vaxis=axis1 haxis=axis2 frame
				  vref=&minMeanSpec &maxMeanSpec
				  lvref=(3 3)
				  cvref=(green,green) NOlegend
				  ;
      format batchn $batch.;
    run;
    quit;
  %mend Approved;


  %macro OLDUnapproved; /*{{{*/
    proc gplot data=&dsn._&duration._MIsorted;
      title1 h=1.75 "&prodname &strength [ &varname ] by &dateSort date (&duration)";

      footnote1 h=0.70 "Plot created &today_date";
      footnote2 ' ';  /* cosmetic - add space to bottom of graph */

      symbol1 i=none w=0.25 h=0.25 v=dot  c=blue;
      symbol2 i=none w=0.25 h=0.25 v=dot  c=red;
      symbol3 i=none w=1.25 h=1.25 v=dot  c=green interpol=join;
      symbol4 i=none w=1.25 h=1.25 v=dot  c=red   interpol=join;

      axis1 label=NONE order=(&minPlot to &maxPlot by &yincrement) major=none minor=none;
      axis2 label=NONE value=(height=0.65);
      axis3 label=NONE order=(&minPlot to &maxPlot by &yincrement) value=none major=none minor=none;
      axis4 label=NONE value=(height=0.65);

      legend1 label=NONE shape=symbol(15,1) frame;

      plot &varname.*batchn=datastatus / vaxis=axis1 haxis=axis2 frame
					 vref=&minMeanSpec &maxMeanSpec &minSpec &maxSpec
					 lvref=(3 3 2 2)
					 cvref=(green,green,blue,blue) NOlegend
					 ;

      plot2 avg&varname.*batchn=datastatus / vaxis=axis3 haxis=axis4 frame
					     vref=&minMeanSpec &maxMeanSpec &minSpec &maxSpec
					     lvref=(3 3 2 2)
					     cvref=(green,green,blue,blue) legend=legend1
					     ;
      format batchn $batch.;
      format datastatus $appstat.;
    run;
    quit;
  %mend OLDUnapproved;/*}}}*/
  %macro Unapproved; 
    proc gplot data=&dsn._&duration._MIsorted;
      title1 h=1.75 "&prodname &strength [ &varname ] &statlbl by &dateSort date (&duration)";

      footnote1 h=0.70 "Plot created &today_date";
      footnote2 ' ';  /* cosmetic - add space to bottom of graph */

      symbol1 i=none w=0.35 h=0.35 v=dot c=green interpol=join;
      symbol2 i=none w=0.35 h=0.35 v=dot c=red;

      axis1 label=NONE order=(&minPlot to &maxPlot by &yincrement) major=none minor=none;
      axis2 label=NONE value=(height=0.65);

      legend1 label=NONE shape=symbol(15,1);

      plot &statlbl.&varname.*batchn=datastatus / vaxis=axis1 haxis=axis2 frame
                                            vref=&minMeanSpec &maxMeanSpec
                                            lvref=(3 3)
                                            cvref=(green,green) legend=legend1
                                            ;

      format batchn $batch.;
      format datastatus $appstat.;
    run;
  %mend;

  %plotter;
%mend build;
