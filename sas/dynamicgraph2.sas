%let dogplot = 1;
%let doxschart = 0;
%let doshewhart = 0;
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  PROGRAM NAME:     dynamicgraph2.sas
 *
 *  CREATED BY:       Bob Heckel (rsh86800)
 *                                                                            
 *  DATE CREATED:     19-Apr-13
 *                                                                            
 *  SAS VERSION:      8.2
 *
 *  PURPOSE:          
 *
 *  INPUT:            XML configuration file
 *
 *  PROCESSING:       
 *
 *  OUTPUT:           
 *------------------------------------------------------------------------------
 *                     HISTORY OF CHANGE
 *-------------+---------+--------------------+---------------------------------
 *     Date    | Version | Modification By    | Nature of Modification
 *-------------+---------+--------------------+---------------------------------
 *  11-Apr-13  |    1.0  | Bob Heckel         | Original. CCF ?????.
 *-------------+---------+--------------------+---------------------------------
 *******************************************************************************
 */
/* This code goes in x:/datapostdemo/code */
/* DEBUG Run: https://rtpsawn321/datapostDEMO/t.html */
%macro dg2;
/***  %let DRIVEPATH=e:\datapost\data;***/
  %let DRIVEPATH=e:\datapostdemo\data;

  %if &_SRVNAME eq rtpsawn321 %then %do;
    %let URL=http://zdatapostd.gsk.com/DataPostDEMO/data;
  %end;
  %else %if &_SRVNAME eq kopsawn557 %then %do;
    %let URL=http://zdatapostd.gsk.com/DataPostDEMO/data;
  %end;
  %else %if &_SRVNAME eq rtpsawn323 %then %do;
    %let URL=http://zdatapostd.gsk.com/DataPostDEMO/data;
  %end;

  %let UNIQID=&SYSPROCESSID;
  %let TMPIMG=e:\datapostdemo\data\t_&UNIQID..gif;

  /*TODO*/
  libname TMPLIB 'e:/temp';

  filename GRAFOUT "&TMPIMG";
/***  goptions reset=all htext=3 gunit=pct ctext=green device=gif gsfname=GOUT xpixels=1024 ypixels=768;***/
	goptions device=png gsfname=grafout gsfmode=append xpixels=1200 ypixels=800;

%macro bobh1604132215; /* {{{ */
  proc sort data=TMPLIB.xcondition out=xcondition; by columnname columnvalue; run;
  data _null_;
    set xcondition(where=(upcase(columnname) eq 'LONG_PRODUCT_NAME'));
    by columnname columnvalue;
    if first.columnvalue then do;
      i+1;
    end;
    call symput('xTHE_PROD'||compress(i), columnvalue);
    call symput('CNTPROD', i);
  /***  put '!!!wtf '(_all_)(=);run;  ***/
  run;

  proc sort data=TMPLIB.xcondition out=xcondition;
    by conditions_ordinal condition_ordinal columnname columnvalue;
  run;
  data t2;
    retain myprd;
    length myprd $80;
    set xcondition;
    by conditions_ordinal condition_ordinal columnname columnvalue;
    if first.conditions_ordinal then do;
      myprd = columnvalue;
    end;
  run;

  proc sort data=t2 NODUPKEY; by columnvalue; run;
  data t3;
    set t2(where=(upcase(columnname) eq 'LONG_TEST_NAME' and myprd eq: "&the_product"));
      i+1;
    call symput('xTHE_METH'||compress(i), columnvalue);
    call symput('CNTMETH', i);
  run;
/***data _null_; set t3; put (_all_)(=); run;***/
%mend bobh1604132215; /* }}} */

  %macro bobh2103134511; /* {{{ */
  /* grep -i 'LimitPattern_1_1 resolv' /cygdrive/z/Datapost/code/DataPost_Trend.log */
  %let i=1; %let Axis_X=mrp_batch_id; %let BatchCnt=2; %let NOCTL=; %let Title1=Bupropion SR 150 mg Purple Tablets;
  %let OutputTrendType_1_1=XsChart; %let PlotMessage1=Plot generated at; %let LimitPattern=1 2 3 4 5 6 7 8;
    proc shewhart data=DataPost_Data limits=xs_table;
        xchart resultn1*&Axis_X /tests= &LimitPattern testlabel=testindex
              test2run=8 test3run=7
                ctests=(1 red 2 purple 3 orange 4 brown 5 blue 6 green 7 cyan 8 magenta)						 
              cconnect=grey
              tableall(exceptions)
              npanelpos=850
              TURNHLABELS
              LIMITN=&BatchCnt 
              alln 
              NDECIMAL=3
              nmarkers
              &&NOCTL  ;
          ods output xchart=tempX;
        label &Axis_X='Batch Number (by Manufacture Date)'  resultn1='Mean';
  /***   		title &Title1 &Title2 &Title3; footnote j=l "&&OutputTrendType_&I._1 TrendId : %UPCASE(&TrendID) &&PlotMessage1 &&ExecutionStopTime&I &&PlotMessage2 &&PlotDateMIN &&PlotMessage3 &&PlotDateMAX";;***/
    run;
  %mend bobh2103134511; /* }}} */

    /***    libname TMPLIB2 'E:\DataPostDEMO\data\GSK\Zebulon\SolidDose\Bupropion';***/
    libname TMPLIB2 "E:\DataPostDEMO\&cbofilename";

    proc sql;
      select memname into :OLS
      from dictionary.members
      where libname eq 'TMPLIB2' and memname like 'OLS_%'
      ;
    quit;
%put !!! &OLS;

    %let txtNumDays = %sysevalf(&txtNumMonths*30);

    data DataPost_Data;
      set TMPLIB2.&OLS;
      rename /***recorded_text=resultn1***/
             mrp_batch_id=BatchN
             ;

      if test_date gt today()-&txtNumDays and
         long_product_name eq "&lstProduct" and
         long_test_name eq "&lstTestMethod" and
         upcase(data_type) eq "&lstDataType" and
         test_status eq "&lstStatus"
         ;

       date=INPUT(Mfg_dt,YYMMDD10.);
       if date>=(today()-1080) and date<=(today()-0);
       /*TODO date mvar for footnote */

       ResultN1=input(recorded_text, ?? COMMA9.);
       if mrp_batch_id='' or ResultN1=. then delete;

%put !!! &lstProduct;
put '!!!wtf '(_all_)(=);run;  
    run;




	PROC MEANS DATA=DataPost_data NOPRINT;
	BY Batchn;
	VAR ResultN1;
	OUTPUT OUT=DataPost_mean2;
 	RUN;

	data DataPost_Data;
	set DataPost_mean2;
/***		_LCLX_=&&LimitLCLX_&I._1;***/
/***		_UCLX_=&&LimitUCLX_&I._1;***/
	where _stat_ = 'MEAN';
put '!!!wtfmean '(_all_)(=);run;  
	run;





    /*TODO if limits ds not exist in e:/temp, build it from cfg.xml */
/***data xs_table;***/
/***call symput('LowerLimit1', 90);***/
/***call symput('UpperLimit1', 100);***/
/***run;***/
   data xs_table;
   _LCLX_=97.51;
   _UCLX_=102.57;
   _MEAN_ = 100.04;
   _VAR_='Dissolution - 4 Hour';
   _SUBGRP_='';
   run;
/***    data xs_table;***/
/***      set TMPLIB.xs_table;***/
/***    run;***/

  %if &dogplot eq 1 %then %do;
    proc gplot data=DataPost_Data;	
      plot resultn1*Batchn; 
      label BatchN="Batch Number (by Manufacture Date) &lstProduct" resultn1='resultn1';
      symbol v=dot h=.75 c=grey interpol=join;
      label BatchN='Batch Number (by Manufacture Date)' resultn1='Mean';
      title "&lstProduct &lstTestMethod";
    /***	format BatchN $xbatch.;***/
      footnote j=l "%upcase(&TrendID) &&PlotDateMIN &&PlotDateMAX";;
      footnote2 j=l "&PlotMessage1 at &SYSDATE &SYSTIME";
    run;
  %end;
  %else %if &doxschart eq 1 %then %do;
    %put TODO;
  %end;
  %else %if &doshewhart eq 1 %then %do;
    proc shewhart data=DataPost_Data limits=xs_table;
   		xchart resultn1*BatchN /tests=1 2 3 4 5 6 7 8 testlabel=testindex
					  test2run=8 test3run=7
				      ctests=(1 red 2 purple 3 orange 4 brown 5 blue 6 green 7 cyan 8 magenta)						 
					  cconnect=grey
					  tableall(exceptions)
					  npanelpos=850
					  TURNHLABELS
					  LIMITN=2
					  alln 
					  NDECIMAL=3
					  nmarkers
/***					  &&NOCTL***/
            ;
/***      ods output xchart=tempX;***/
/***      label mrp_batch_id='Batch Number (by Manufacture Date)' resultn1='Mean';***/
/***      title Bupropion SR 150 mg Purple Tablets Assay ;***/
/***      footnote j=l "XsChart TrendId : TR_00020010 Plot generated at ExecutionStopTime1 Plot Date Range from 06-JUN-12 to 18-MAR-13";***/
      ;
   run;
  %end;
  ods html body=_WEBOUT (dynamic title='FINISHED') style=brick rs=none;
    data _null_;
      file _WEBOUT;
      put "<img src='&URL/t_&UNIQID..gif'>";
    run;
  ods html close;

  data _null_;
    rc=sleep(5);
    put rc=;
    %put !!!! &TMPIMG;
    rc2=system("del &TMPIMG");
    put rc2=;
  run;
%mend dg2;
/***options nosource2;***/
%dg2;
